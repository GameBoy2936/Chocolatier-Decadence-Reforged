#define UNICODE
#define _UNICODE
#include <windows.h>
#include <winhttp.h>
#include <shellapi.h>
#include <tlhelp32.h>
#include <wchar.h>
#include <stdio.h>
#include <string.h>

#define APP_TITLE L"Chocolatier Reforged"
#define BRIDGE_EXE L"ReforgedCommunityBridge.exe"
#define GAME_EXE L"chocolatier-decadence.exe"
#define CLIENT_VERSION_FILE L"CLIENT_VERSION.txt"
#define UPDATE_MANIFEST_URL L"https://scores.chocolatiercommunity.com/releases/latest-release.json"
#define UPDATE_BODY_MAX 16384

static int file_exists(const wchar_t *path) {
    DWORD a = GetFileAttributesW(path);
    return a != INVALID_FILE_ATTRIBUTES && !(a & FILE_ATTRIBUTE_DIRECTORY);
}

static void copy_text(wchar_t *dst, size_t cap, const wchar_t *src) {
    if (!dst || cap == 0) return;
    if (!src) src = L"";
    wcsncpy_s(dst, cap, src, _TRUNCATE);
}

static void join_path(wchar_t *out, size_t cap, const wchar_t *a, const wchar_t *b) {
    size_t n;
    copy_text(out, cap, a);
    n = wcslen(out);
    if (n && out[n - 1] != L'\\' && out[n - 1] != L'/') wcscat_s(out, cap, L"\\");
    wcscat_s(out, cap, b);
}

static int get_app_dir(wchar_t *out, size_t cap) {
    DWORD n = GetModuleFileNameW(NULL, out, (DWORD)cap);
    wchar_t *p;
    if (!n || n >= cap) return 0;
    p = out + wcslen(out);
    while (p > out && p[-1] != L'\\' && p[-1] != L'/') --p;
    if (p == out) return 0;
    p[-1] = L'\0';
    return 1;
}

static void terminate_processes_named(const wchar_t *exe_name) {
    HANDLE snap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    PROCESSENTRY32W pe;
    if (snap == INVALID_HANDLE_VALUE) return;
    ZeroMemory(&pe, sizeof(pe));
    pe.dwSize = sizeof(pe);
    if (Process32FirstW(snap, &pe)) {
        do {
            if (_wcsicmp(pe.szExeFile, exe_name) == 0) {
                HANDLE p = OpenProcess(PROCESS_TERMINATE | SYNCHRONIZE, FALSE, pe.th32ProcessID);
                if (p) {
                    TerminateProcess(p, 0);
                    WaitForSingleObject(p, 1000);
                    CloseHandle(p);
                }
            }
        } while (Process32NextW(snap, &pe));
    }
    CloseHandle(snap);
}

static int start_process(const wchar_t *exe, const wchar_t *cwd, DWORD flags, PROCESS_INFORMATION *pi) {
    STARTUPINFOW si;
    wchar_t cmd[32768];
    ZeroMemory(&si, sizeof(si));
    ZeroMemory(pi, sizeof(*pi));
    si.cb = sizeof(si);
    _snwprintf_s(cmd, _countof(cmd), _TRUNCATE, L"\"%ls\"", exe);
    return CreateProcessW(exe, cmd, NULL, NULL, FALSE, flags, NULL, cwd, &si, pi) ? 1 : 0;
}

static void write_stop_file(const wchar_t *path) {
    static const char data[] = "stop\r\n";
    DWORD written = 0;
    HANDLE f = CreateFileW(path, GENERIC_WRITE, FILE_SHARE_READ, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
    if (f == INVALID_HANDLE_VALUE) return;
    WriteFile(f, data, (DWORD)(sizeof(data) - 1), &written, NULL);
    CloseHandle(f);
}

static int wait_for_bridge_start(const wchar_t *status_path, HANDLE process) {
    DWORD elapsed = 0;
    while (elapsed < 10000) {
        if (file_exists(status_path)) return 1;
        if (process && WaitForSingleObject(process, 0) == WAIT_OBJECT_0) return 0;
        Sleep(200);
        elapsed += 200;
    }
    return file_exists(status_path);
}

static int read_small_text_file(const wchar_t *path, wchar_t *out, size_t cap) {
    HANDLE f;
    char bytes[256];
    DWORD got = 0;
    int n;
    size_t i;
    if (!out || cap == 0) return 0;
    out[0] = L'\0';
    f = CreateFileW(path, GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    if (f == INVALID_HANDLE_VALUE) return 0;
    if (!ReadFile(f, bytes, (DWORD)(sizeof(bytes) - 1), &got, NULL)) {
        CloseHandle(f);
        return 0;
    }
    CloseHandle(f);
    bytes[got] = '\0';
    while (got && (bytes[got - 1] == '\r' || bytes[got - 1] == '\n' || bytes[got - 1] == ' ' || bytes[got - 1] == '\t')) {
        bytes[--got] = '\0';
    }
    if (!got) return 0;
    n = MultiByteToWideChar(CP_UTF8, 0, bytes, -1, out, (int)cap);
    if (!n) return 0;
    /* Strip a UTF-8 BOM converted into U+FEFF if one ever appears. */
    if (out[0] == 0xFEFF) {
        for (i = 0; out[i]; ++i) out[i] = out[i + 1];
    }
    return out[0] != L'\0';
}

static int semver3(const wchar_t *text, int parts[3]) {
    int i;
    const wchar_t *p = text;
    if (!text || !*text) return 0;
    for (i = 0; i < 3; ++i) {
        int value = 0;
        int digits = 0;
        while (*p >= L'0' && *p <= L'9') {
            if (value > 1000000) return 0;
            value = value * 10 + (int)(*p - L'0');
            ++p;
            ++digits;
        }
        if (!digits) return 0;
        parts[i] = value;
        if (i < 2) {
            if (*p != L'.') return 0;
            ++p;
        }
    }
    return *p == L'\0' || *p == L'-' || *p == L'+';
}

static int version_is_newer(const wchar_t *latest, const wchar_t *current) {
    int a[3], b[3], i;
    if (!semver3(latest, a) || !semver3(current, b)) return 0;
    for (i = 0; i < 3; ++i) {
        if (a[i] > b[i]) return 1;
        if (a[i] < b[i]) return 0;
    }
    return 0;
}

static int json_string_value(const char *json, const char *key, char *out, size_t cap) {
    char pattern[96];
    const char *p;
    size_t n = 0;
    if (!json || !key || !out || cap < 2) return 0;
    out[0] = '\0';
    if (strlen(key) + 3 >= sizeof(pattern)) return 0;
    _snprintf_s(pattern, sizeof(pattern), _TRUNCATE, "\"%s\"", key);
    p = strstr(json, pattern);
    if (!p) return 0;
    p += strlen(pattern);
    while (*p == ' ' || *p == '\t' || *p == '\r' || *p == '\n') ++p;
    if (*p++ != ':') return 0;
    while (*p == ' ' || *p == '\t' || *p == '\r' || *p == '\n') ++p;
    if (*p++ != '"') return 0;
    while (*p && *p != '"' && n + 1 < cap) {
        /* Generated update manifests use simple ASCII/UTF-8 values and no escapes. */
        if (*p == '\\') return 0;
        out[n++] = *p++;
    }
    if (*p != '"' || n == 0) return 0;
    out[n] = '\0';
    return 1;
}

static int utf8_to_wide(const char *src, wchar_t *dst, size_t cap) {
    if (!src || !dst || cap == 0) return 0;
    dst[0] = L'\0';
    return MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, src, -1, dst, (int)cap) > 0;
}

static int fetch_manifest(char *out, DWORD cap) {
    URL_COMPONENTSW parts;
    wchar_t host[256];
    wchar_t path[2048];
    wchar_t extra[1024];
    wchar_t request_path[3072];
    HINTERNET session = NULL, connection = NULL, request = NULL;
    DWORD status = 0, status_size = sizeof(status), available = 0, got = 0, total = 0;
    int ok = 0;

    if (!out || cap < 2) return 0;
    out[0] = '\0';
    ZeroMemory(&parts, sizeof(parts));
    ZeroMemory(host, sizeof(host));
    ZeroMemory(path, sizeof(path));
    ZeroMemory(extra, sizeof(extra));
    parts.dwStructSize = sizeof(parts);
    parts.lpszHostName = host;
    parts.dwHostNameLength = _countof(host) - 1;
    parts.lpszUrlPath = path;
    parts.dwUrlPathLength = _countof(path) - 1;
    parts.lpszExtraInfo = extra;
    parts.dwExtraInfoLength = _countof(extra) - 1;
    if (!WinHttpCrackUrl(UPDATE_MANIFEST_URL, 0, 0, &parts)) goto done;
    if (parts.nScheme != INTERNET_SCHEME_HTTPS) goto done;
    host[parts.dwHostNameLength] = L'\0';
    path[parts.dwUrlPathLength] = L'\0';
    extra[parts.dwExtraInfoLength] = L'\0';
    _snwprintf_s(request_path, _countof(request_path), _TRUNCATE, L"%ls%ls", path, extra);

    session = WinHttpOpen(L"Chocolatier Reforged Launcher/2", WINHTTP_ACCESS_TYPE_DEFAULT_PROXY,
                          WINHTTP_NO_PROXY_NAME, WINHTTP_NO_PROXY_BYPASS, 0);
    if (!session) goto done;
    WinHttpSetTimeouts(session, 1500, 1500, 2000, 2500);
    connection = WinHttpConnect(session, host, parts.nPort, 0);
    if (!connection) goto done;
    request = WinHttpOpenRequest(connection, L"GET", request_path, NULL, WINHTTP_NO_REFERER,
                                 WINHTTP_DEFAULT_ACCEPT_TYPES, WINHTTP_FLAG_SECURE | WINHTTP_FLAG_REFRESH);
    if (!request) goto done;
    if (!WinHttpSendRequest(request, WINHTTP_NO_ADDITIONAL_HEADERS, 0, WINHTTP_NO_REQUEST_DATA, 0, 0, 0)) goto done;
    if (!WinHttpReceiveResponse(request, NULL)) goto done;
    if (!WinHttpQueryHeaders(request, WINHTTP_QUERY_STATUS_CODE | WINHTTP_QUERY_FLAG_NUMBER,
                             WINHTTP_HEADER_NAME_BY_INDEX, &status, &status_size, WINHTTP_NO_HEADER_INDEX)) goto done;
    if (status != 200) goto done;

    for (;;) {
        if (!WinHttpQueryDataAvailable(request, &available)) goto done;
        if (!available) break;
        if (available > cap - 1 - total) goto done;
        if (!WinHttpReadData(request, out + total, available, &got)) goto done;
        if (!got) break;
        total += got;
    }
    out[total] = '\0';
    ok = total > 0;

done:
    if (request) WinHttpCloseHandle(request);
    if (connection) WinHttpCloseHandle(connection);
    if (session) WinHttpCloseHandle(session);
    return ok;
}

static void check_for_update(const wchar_t *root) {
    wchar_t version_path[MAX_PATH * 4];
    wchar_t current[64], latest[64], download_url[2048], release_notes_url[2048];
    char body[UPDATE_BODY_MAX];
    char latest_utf8[64], url_utf8[2048], notes_url_utf8[2048];
    wchar_t message[1400];
    int result;
    int has_release_notes = 0;

    join_path(version_path, _countof(version_path), root, CLIENT_VERSION_FILE);
    if (!read_small_text_file(version_path, current, _countof(current))) return;
    if (!fetch_manifest(body, (DWORD)sizeof(body))) return;
    if (!json_string_value(body, "version", latest_utf8, sizeof(latest_utf8))) return;
    if (!json_string_value(body, "download_url", url_utf8, sizeof(url_utf8))) return;
    if (!utf8_to_wide(latest_utf8, latest, _countof(latest))) return;
    if (!utf8_to_wide(url_utf8, download_url, _countof(download_url))) return;
    if (json_string_value(body, "release_notes_url", notes_url_utf8, sizeof(notes_url_utf8)) &&
        utf8_to_wide(notes_url_utf8, release_notes_url, _countof(release_notes_url))) {
        has_release_notes = 1;
    }
    if (!version_is_newer(latest, current)) return;

    if (has_release_notes) {
        _snwprintf_s(message, _countof(message), _TRUNCATE,
            L"Chocolatier Reforged v%ls is available. You are currently using v%ls.\n\n"
            L"Yes: Open the installer download\n"
            L"No: View the change notes\n"
            L"Cancel: Continue without updating\n\n"
            L"Install the update after closing Reforged.", latest, current);
        result = MessageBoxW(NULL, message, L"Chocolatier Reforged Update", MB_YESNOCANCEL | MB_ICONINFORMATION | MB_SETFOREGROUND);
    } else {
        _snwprintf_s(message, _countof(message), _TRUNCATE,
            L"Chocolatier Reforged v%ls is available. You are currently using v%ls.\n\n"
            L"Would you like to open the installer download in your browser?\n\n"
            L"You can install the update after closing Reforged.", latest, current);
        result = MessageBoxW(NULL, message, L"Chocolatier Reforged Update", MB_YESNO | MB_ICONINFORMATION | MB_SETFOREGROUND);
    }
    if (result == IDYES) {
        ShellExecuteW(NULL, L"open", download_url, NULL, NULL, SW_SHOWNORMAL);
    } else if (result == IDNO && has_release_notes) {
        ShellExecuteW(NULL, L"open", release_notes_url, NULL, NULL, SW_SHOWNORMAL);
    }
}

int WINAPI wWinMain(HINSTANCE instance, HINSTANCE previous, LPWSTR command_line, int show) {
    wchar_t root[MAX_PATH * 4];
    wchar_t bridge_dir[MAX_PATH * 4];
    wchar_t bridge_exe[MAX_PATH * 4];
    wchar_t bridge_status[MAX_PATH * 4];
    wchar_t bridge_stop[MAX_PATH * 4];
    wchar_t game_exe[MAX_PATH * 4];
    PROCESS_INFORMATION bridge_pi, game_pi;
    HANDLE mutex;
    int bridge_started = 0;
    DWORD game_exit = 0;
    (void)instance; (void)previous; (void)show;

    mutex = CreateMutexW(NULL, TRUE, L"ChocolatierReforged_v2_Launcher");
    if (!mutex) return 1;
    if (GetLastError() == ERROR_ALREADY_EXISTS) {
        MessageBoxW(NULL, L"Chocolatier Reforged is already running.", APP_TITLE, MB_OK | MB_ICONINFORMATION);
        CloseHandle(mutex);
        return 0;
    }

    if (!get_app_dir(root, _countof(root))) {
        MessageBoxW(NULL, L"Could not determine the Reforged installation folder.", APP_TITLE, MB_OK | MB_ICONERROR);
        CloseHandle(mutex);
        return 2;
    }

    join_path(bridge_dir, _countof(bridge_dir), root, L"community_bridge");
    join_path(bridge_exe, _countof(bridge_exe), bridge_dir, BRIDGE_EXE);
    join_path(bridge_status, _countof(bridge_status), bridge_dir, L"bridge_status.txt");
    join_path(bridge_stop, _countof(bridge_stop), bridge_dir, L"stop.txt");
    join_path(game_exe, _countof(game_exe), root, GAME_EXE);

    if (!file_exists(game_exe)) {
        MessageBoxW(NULL,
            L"The original chocolatier-decadence.exe was not found beside Chocolatier Reforged.exe.\n\n"
            L"Reinstall Reforged into your existing Chocolatier: Decadence by Design folder.",
            APP_TITLE, MB_OK | MB_ICONERROR);
        CloseHandle(mutex);
        return 3;
    }

    /* Update discovery is best-effort. Offline/failed checks are intentionally silent. */
    if (!command_line || !wcsstr(command_line, L"--no-update-check")) {
        check_for_update(root);
    }

    /* A crashed previous launcher may have left the helper behind. */
    terminate_processes_named(BRIDGE_EXE);
    DeleteFileW(bridge_stop);
    DeleteFileW(bridge_status);

    ZeroMemory(&bridge_pi, sizeof(bridge_pi));
    if (file_exists(bridge_exe) && start_process(bridge_exe, bridge_dir, CREATE_NO_WINDOW, &bridge_pi)) {
        bridge_started = wait_for_bridge_start(bridge_status, bridge_pi.hProcess);
        if (!bridge_started) {
            if (WaitForSingleObject(bridge_pi.hProcess, 0) == WAIT_TIMEOUT)
                TerminateProcess(bridge_pi.hProcess, 2);
            CloseHandle(bridge_pi.hThread);
            CloseHandle(bridge_pi.hProcess);
            ZeroMemory(&bridge_pi, sizeof(bridge_pi));
        }
    }

    if (!bridge_started) {
        MessageBoxW(NULL,
            L"Community services could not be started.\n\n"
            L"The game will still open normally, but Community Accounts, the Community Cookbook, Cloud Saves and Community Scores will be unavailable for this session.",
            APP_TITLE, MB_OK | MB_ICONWARNING);
    }

    ZeroMemory(&game_pi, sizeof(game_pi));
    if (!start_process(game_exe, root, 0, &game_pi)) {
        if (bridge_started) {
            write_stop_file(bridge_stop);
            if (WaitForSingleObject(bridge_pi.hProcess, 1500) == WAIT_TIMEOUT)
                TerminateProcess(bridge_pi.hProcess, 3);
            CloseHandle(bridge_pi.hThread);
            CloseHandle(bridge_pi.hProcess);
        }
        MessageBoxW(NULL, L"Chocolatier: Decadence by Design could not be started.", APP_TITLE, MB_OK | MB_ICONERROR);
        CloseHandle(mutex);
        return 4;
    }

    CloseHandle(game_pi.hThread);
    WaitForSingleObject(game_pi.hProcess, INFINITE);
    GetExitCodeProcess(game_pi.hProcess, &game_exit);
    CloseHandle(game_pi.hProcess);

    if (bridge_started) {
        write_stop_file(bridge_stop);
        if (WaitForSingleObject(bridge_pi.hProcess, 3000) == WAIT_TIMEOUT)
            TerminateProcess(bridge_pi.hProcess, 0);
        CloseHandle(bridge_pi.hThread);
        CloseHandle(bridge_pi.hProcess);
    }

    DeleteFileW(bridge_stop);
    ReleaseMutex(mutex);
    CloseHandle(mutex);
    return (int)game_exit;
}
