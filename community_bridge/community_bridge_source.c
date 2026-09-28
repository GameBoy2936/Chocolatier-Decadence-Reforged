// Chocolatier: Decadence by Design Reforged - Community HTTP bridge.
// v0.2.13: authenticated profile presence plus allowlisted external links.
// Playground's Lua ReadFromFile/WriteToFile helpers transparently use
// the engine's virtual "user:" mount, not the process working directory. The
// game writes community_bridge_probe.txt into that mount; this helper locates
// the probe under the normal PlayFirst roaming profile directory and then uses
// that exact physical directory for ready/request/response IPC.
// Native Windows helper; deliberately uses only Win32/WinINet and no CRT.

typedef void *HANDLE;
typedef void *HINTERNET;
typedef unsigned long DWORD;
typedef int BOOL;
typedef unsigned short WORD;
typedef unsigned short INTERNET_PORT;
typedef unsigned long DWORD_PTR;
typedef const char *LPCSTR;
typedef char *LPSTR;
typedef void *LPVOID;
typedef const void *LPCVOID;

typedef struct _FILETIME { DWORD dwLowDateTime; DWORD dwHighDateTime; } FILETIME;
typedef struct _WIN32_FIND_DATAA {
    DWORD dwFileAttributes;
    FILETIME ftCreationTime;
    FILETIME ftLastAccessTime;
    FILETIME ftLastWriteTime;
    DWORD nFileSizeHigh;
    DWORD nFileSizeLow;
    DWORD dwReserved0;
    DWORD dwReserved1;
    char cFileName[260];
    char cAlternateFileName[14];
} WIN32_FIND_DATAA;

#define WINAPI __stdcall
#define INVALID_HANDLE_VALUE ((HANDLE)(long long)-1)
#define GENERIC_READ  0x80000000UL
#define GENERIC_WRITE 0x40000000UL
#define FILE_SHARE_READ 0x00000001UL
#define OPEN_EXISTING 3UL
#define CREATE_ALWAYS 2UL
#define FILE_ATTRIBUTE_NORMAL 0x00000080UL
#define FILE_ATTRIBUTE_DIRECTORY 0x00000010UL
#define FILE_ATTRIBUTE_REPARSE_POINT 0x00000400UL
#define MOVEFILE_REPLACE_EXISTING 0x00000001UL
#define MOVEFILE_WRITE_THROUGH 0x00000008UL

#define INTERNET_OPEN_TYPE_PRECONFIG 0UL
#define INTERNET_SERVICE_HTTP 3UL
#define INTERNET_DEFAULT_HTTPS_PORT 443
#define INTERNET_FLAG_RELOAD         0x80000000UL
#define INTERNET_FLAG_NO_CACHE_WRITE 0x04000000UL
#define INTERNET_FLAG_SECURE         0x00800000UL
#define INTERNET_FLAG_NO_UI          0x00000200UL
#define HTTP_QUERY_STATUS_CODE       19UL
#define HTTP_QUERY_FLAG_NUMBER       0x20000000UL
#define SW_SHOWNORMAL 1
#define PRESENCE_INTERVAL_MS 60000UL
#define ERROR_ALREADY_EXISTS 183UL

__declspec(dllimport) HANDLE WINAPI CreateFileA(LPCSTR,DWORD,DWORD,LPVOID,DWORD,DWORD,HANDLE);
__declspec(dllimport) BOOL WINAPI ReadFile(HANDLE,LPVOID,DWORD,DWORD*,LPVOID);
__declspec(dllimport) BOOL WINAPI WriteFile(HANDLE,LPCVOID,DWORD,DWORD*,LPVOID);
__declspec(dllimport) BOOL WINAPI CloseHandle(HANDLE);
__declspec(dllimport) DWORD WINAPI GetFileSize(HANDLE,DWORD*);
__declspec(dllimport) BOOL WINAPI DeleteFileA(LPCSTR);
__declspec(dllimport) BOOL WINAPI MoveFileExA(LPCSTR,LPCSTR,DWORD);
__declspec(dllimport) DWORD WINAPI GetModuleFileNameA(HANDLE,LPSTR,DWORD);
__declspec(dllimport) DWORD WINAPI GetEnvironmentVariableA(LPCSTR,LPSTR,DWORD);
__declspec(dllimport) BOOL WINAPI CreateDirectoryA(LPCSTR,LPVOID);
__declspec(dllimport) HANDLE WINAPI FindFirstFileA(LPCSTR,WIN32_FIND_DATAA*);
__declspec(dllimport) BOOL WINAPI FindNextFileA(HANDLE,WIN32_FIND_DATAA*);
__declspec(dllimport) BOOL WINAPI FindClose(HANDLE);
__declspec(dllimport) DWORD WINAPI GetLastError(void);
__declspec(dllimport) void WINAPI Sleep(DWORD);
__declspec(dllimport) void WINAPI ExitProcess(unsigned int);
__declspec(dllimport) DWORD WINAPI GetCurrentProcessId(void);
__declspec(dllimport) DWORD WINAPI GetTickCount(void);
__declspec(dllimport) void WINAPI GetSystemTimeAsFileTime(FILETIME*);
__declspec(dllimport) void * WINAPI ShellExecuteA(void*,LPCSTR,LPCSTR,LPCSTR,LPCSTR,int);

__declspec(dllimport) HINTERNET WINAPI InternetOpenA(LPCSTR,DWORD,LPCSTR,LPCSTR,DWORD);
__declspec(dllimport) HINTERNET WINAPI InternetConnectA(HINTERNET,LPCSTR,INTERNET_PORT,LPCSTR,LPCSTR,DWORD,DWORD,DWORD_PTR);
__declspec(dllimport) HINTERNET WINAPI HttpOpenRequestA(HINTERNET,LPCSTR,LPCSTR,LPCSTR,LPCSTR,LPCSTR*,DWORD,DWORD_PTR);
__declspec(dllimport) BOOL WINAPI HttpSendRequestA(HINTERNET,LPCSTR,DWORD,LPVOID,DWORD);
__declspec(dllimport) BOOL WINAPI HttpQueryInfoA(HINTERNET,DWORD,LPVOID,DWORD*,DWORD*);
__declspec(dllimport) BOOL WINAPI InternetReadFile(HINTERNET,LPVOID,DWORD,DWORD*);
__declspec(dllimport) BOOL WINAPI InternetCloseHandle(HINTERNET);

#define REQUEST_MAX 6291456UL
#define RESPONSE_MAX 6291456UL
#define HOST_MAX 256UL
#define PATHBUF_MAX 1024UL
#define PROBE_NAME "community_bridge_probe.txt"

static char g_request[REQUEST_MAX + 1];
static char g_http_body[RESPONSE_MAX + 1];
static char g_response[RESPONSE_MAX + 512];
static char g_host[HOST_MAX];
static char g_method[16];
static char g_path[4096];
static char g_auth[128];
static char g_headers[512];
static char g_control_base[PATHBUF_MAX];
static char g_ipc_base[PATHBUF_MAX];
static char g_request_file[PATHBUF_MAX];
static char g_response_file[PATHBUF_MAX];
static char g_response_tmp[PATHBUF_MAX];
static char g_server_file[PATHBUF_MAX];
static char g_stop_file[PATHBUF_MAX];
static char g_ready_file[PATHBUF_MAX];
static char g_probe_file[PATHBUF_MAX];
static char g_status_file[PATHBUF_MAX];
static char g_presence_id[96];
static char g_account_file[PATHBUF_MAX];
static char g_account_json[8192];
static DWORD g_last_presence_tick=0;
static int g_ipc_ready=0;

static DWORD s_len(const char *s) { DWORD n=0; if (!s) return 0; while (s[n]) n++; return n; }
static int s_eq(const char *a,const char *b){DWORD i=0;while(a[i]&&b[i]){if(a[i]!=b[i])return 0;i++;}return a[i]==0&&b[i]==0;}
static int s_eq_n(const char *a, const char *b, DWORD n) { DWORD i; for(i=0;i<n;i++) if(a[i]!=b[i]) return 0; return 1; }
static void copy_n(char *d, const char *s, DWORD n) { DWORD i; for(i=0;i<n;i++) d[i]=s[i]; }
static void copy_text(char *d,DWORD cap,const char *s){DWORD i=0;if(!cap)return;while(s[i]&&i+1<cap){d[i]=s[i];i++;}d[i]=0;}
static char *find_seq(char *s, DWORD n, const char *needle, DWORD nn) {
    DWORD i; if(nn==0 || n<nn) return 0;
    for(i=0;i<=n-nn;i++) if(s_eq_n(s+i,needle,nn)) return s+i;
    return 0;
}
static DWORD append_text(char *dst, DWORD at, DWORD cap, const char *s) {
    DWORD n=s_len(s), i; if(at+n>cap) n=cap-at; for(i=0;i<n;i++) dst[at+i]=s[i]; return at+n;
}
static DWORD append_uint(char *dst, DWORD at, DWORD cap, DWORD v) {
    char tmp[16]; DWORD n=0,i; if(v==0) tmp[n++]='0'; else { while(v && n<16){tmp[n++]=(char)('0'+(v%10));v/=10;} }
    for(i=0;i<n && at<cap;i++) dst[at++]=tmp[n-1-i]; return at;
}
static int parse_uint_strict(const char *s, DWORD n, DWORD *out) {
    DWORD i,v=0,d; if(!s||!n||!out)return 0;
    for(i=0;i<n;i++){
        if(s[i]<'0'||s[i]>'9')return 0;
        d=(DWORD)(s[i]-'0');
        if(v>429496729UL || (v==429496729UL && d>5UL))return 0;
        v=v*10UL+d;
    }
    *out=v; return 1;
}

static int read_file(const char *path, char *buf, DWORD cap, DWORD *out_n) {
    HANDLE h; DWORD n=0,size;
    h=CreateFileA(path,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
    if(h==INVALID_HANDLE_VALUE) return 0;
    size=GetFileSize(h,0); if(size==0xFFFFFFFFUL || size>=cap){CloseHandle(h);return 0;}
    if(size && !ReadFile(h,buf,size,&n,0)){CloseHandle(h);return 0;}
    CloseHandle(h); buf[n]=0; *out_n=n; return 1;
}
static int file_exists(const char *path){HANDLE h=CreateFileA(path,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);if(h==INVALID_HANDLE_VALUE)return 0;CloseHandle(h);return 1;}
static int write_file(const char *path, const char *buf, DWORD n) {
    HANDLE h; DWORD w=0;
    h=CreateFileA(path,GENERIC_WRITE,0,0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0);
    if(h==INVALID_HANDLE_VALUE) return 0;
    if(n && !WriteFile(h,buf,n,&w,0)){CloseHandle(h);return 0;}
    CloseHandle(h); return w==n;
}
static void join_path(char *dst, DWORD cap, const char *base, const char *leaf) {
    DWORD at=0,n=s_len(base),i;
    for(i=0;i<n && at+1<cap;i++) dst[at++]=base[i];
    if(at && dst[at-1]!='\\' && dst[at-1]!='/' && at+1<cap) dst[at++]='\\';
    n=s_len(leaf); for(i=0;i<n && at+1<cap;i++) dst[at++]=leaf[i]; dst[at]=0;
}
static int ensure_dir(const char *path) {
    DWORD err;
    if(CreateDirectoryA(path,0)) return 1;
    err=GetLastError();
    return err==ERROR_ALREADY_EXISTS;
}
static void init_control_paths(void) {
    char install_base[PATHBUF_MAX],env[PATHBUF_MAX],parent[PATHBUF_MAX],runtime[PATHBUF_MAX];
    DWORD n=GetModuleFileNameA(0,install_base,PATHBUF_MAX-1),i;

    if(!n || n>=PATHBUF_MAX-1) { install_base[0]='.'; install_base[1]=0; }
    else {
        install_base[n]=0;
        for(i=n;i>0;i--) if(install_base[i-1]=='\\' || install_base[i-1]=='/') { install_base[i-1]=0; break; }
        if(i==0) { install_base[0]='.'; install_base[1]=0; }
    }

    /* Configuration remains beside the executable, while mutable launcher/bridge
       control files live under LOCALAPPDATA so normal Program Files installs do
       not require write access to the installation directory. */
    join_path(g_server_file,PATHBUF_MAX,install_base,"server.txt");
    copy_text(g_control_base,PATHBUF_MAX,install_base);

    n=GetEnvironmentVariableA("LOCALAPPDATA",env,PATHBUF_MAX-1);
    if(n && n<PATHBUF_MAX-1) {
        env[n]=0;
        join_path(parent,PATHBUF_MAX,env,"Chocolatier Reforged");
        if(ensure_dir(parent)) {
            join_path(runtime,PATHBUF_MAX,parent,"Community Bridge");
            if(ensure_dir(runtime)) copy_text(g_control_base,PATHBUF_MAX,runtime);
        }
    }

    join_path(g_stop_file,PATHBUF_MAX,g_control_base,"stop.txt");
    join_path(g_status_file,PATHBUF_MAX,g_control_base,"bridge_status.txt");
}
static void init_ipc_paths(const char *base) {
    copy_text(g_ipc_base,PATHBUF_MAX,base);
    join_path(g_request_file,PATHBUF_MAX,g_ipc_base,"request.txt");
    join_path(g_response_file,PATHBUF_MAX,g_ipc_base,"response.txt");
    join_path(g_response_tmp,PATHBUF_MAX,g_ipc_base,"response.tmp");
    join_path(g_ready_file,PATHBUF_MAX,g_ipc_base,"ready.txt");
    join_path(g_probe_file,PATHBUF_MAX,g_ipc_base,PROBE_NAME);
    join_path(g_account_file,PATHBUF_MAX,g_ipc_base,"community_account.json");
    g_ipc_ready=1;
}
static void write_status(const char *stage, DWORD code) {
    char buf[1536]; DWORD at=0;
    at=append_text(buf,at,1535,"Community Bridge v0.2.13\r\nSTATUS: "); at=append_text(buf,at,1535,stage);
    if(code){ at=append_text(buf,at,1535,"\r\nWIN32-ERROR: "); at=append_uint(buf,at,1535,code); }
    at=append_text(buf,at,1535,"\r\nHOST: "); at=append_text(buf,at,1535,g_host);
    if(g_ipc_ready){at=append_text(buf,at,1535,"\r\nIPC-ROOT: ");at=append_text(buf,at,1535,g_ipc_base);}
    at=append_text(buf,at,1535,"\r\n"); write_file(g_status_file,buf,at);
}
static void load_host(void) {
    DWORD n=0,i; const char *fallback="scores.chocolatiercommunity.com";
    if(read_file(g_server_file,g_host,HOST_MAX-1,&n)) {
        while(n && (g_host[n-1]=='\r'||g_host[n-1]=='\n'||g_host[n-1]==' '||g_host[n-1]=='\t')) n--;
        i=0; while(i<n && (g_host[i]==' '||g_host[i]=='\t')) i++;
        if(i && i<n){DWORD j; for(j=0;j<n-i;j++)g_host[j]=g_host[i+j]; n-=i;}
        g_host[n]=0; if(n) return;
    }
    n=s_len(fallback); copy_n(g_host,fallback,n+1);
}

static int find_probe_recursive(const char *dir, DWORD depth, char *out, DWORD out_cap) {
    char direct[PATHBUF_MAX],pattern[PATHBUF_MAX],child[PATHBUF_MAX]; WIN32_FIND_DATAA fd; HANDLE h;
    if(depth>7) return 0;
    join_path(direct,PATHBUF_MAX,dir,PROBE_NAME);
    if(file_exists(direct)){copy_text(out,out_cap,dir);return 1;}
    join_path(pattern,PATHBUF_MAX,dir,"*");
    h=FindFirstFileA(pattern,&fd); if(h==INVALID_HANDLE_VALUE)return 0;
    do {
        if((fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) && !(fd.dwFileAttributes & FILE_ATTRIBUTE_REPARSE_POINT)){
            if(!s_eq(fd.cFileName,".") && !s_eq(fd.cFileName,"..")){
                join_path(child,PATHBUF_MAX,dir,fd.cFileName);
                if(find_probe_recursive(child,depth+1,out,out_cap)){FindClose(h);return 1;}
            }
        }
    } while(FindNextFileA(h,&fd));
    FindClose(h); return 0;
}
static int discover_ipc_root(char *out,DWORD cap){
    char env[PATHBUF_MAX],base[PATHBUF_MAX]; DWORD n;
    n=GetEnvironmentVariableA("APPDATA",env,PATHBUF_MAX-1);
    if(n && n<PATHBUF_MAX-1){env[n]=0;join_path(base,PATHBUF_MAX,env,"PlayFirst");if(find_probe_recursive(base,0,out,cap))return 1;}
    n=GetEnvironmentVariableA("LOCALAPPDATA",env,PATHBUF_MAX-1);
    if(n && n<PATHBUF_MAX-1){env[n]=0;join_path(base,PATHBUF_MAX,env,"PlayFirst");if(find_probe_recursive(base,0,out,cap))return 1;}
    n=GetEnvironmentVariableA("PROGRAMDATA",env,PATHBUF_MAX-1);
    if(n && n<PATHBUF_MAX-1){env[n]=0;join_path(base,PATHBUF_MAX,env,"PlayFirst");if(find_probe_recursive(base,0,out,cap))return 1;}
    return 0;
}

static int field(char *head, DWORD head_n, const char *key, char **value, DWORD *value_n) {
    DWORD key_n=s_len(key); char *p=head; DWORD remain=head_n;
    while(remain){char *e=find_seq(p,remain,"\n",1); DWORD line_n=e?(DWORD)(e-p):remain;
        if(line_n>=key_n+1 && s_eq_n(p,key,key_n) && p[key_n]==':'){
            DWORD off=key_n+1; while(off<line_n && (p[off]==' '||p[off]=='\t'))off++;
            *value=p+off; *value_n=line_n-off; if(*value_n && (*value)[*value_n-1]=='\r')(*value_n)--; return 1;}
        if(!e)break; line_n++; p+=line_n; remain-=line_n;} return 0;
}

static int http_request(const char *method, DWORD method_n, const char *path, DWORD path_n, const char *auth, DWORD auth_n, const char *body, DWORD body_n, DWORD *status, DWORD *response_n, DWORD *winerr, int *too_large) {
    HINTERNET session=0,connect=0,req=0; DWORD i,total=0,got=0,sz=sizeof(DWORD),idx=0,hat=0; BOOL ok=0; *winerr=0;*too_large=0;
    if(method_n==0||method_n>=16||path_n==0||path_n>=4096) return 0;
    if(!((method_n==3&&s_eq_n(method,"GET",3))||(method_n==4&&s_eq_n(method,"POST",4))))return 0;
    if(path[0]!='/')return 0;
    for(i=0;i<path_n;i++)if((unsigned char)path[i]<32U||(unsigned char)path[i]==127U)return 0;
    if(auth&&auth_n){if(auth_n!=64)return 0;for(i=0;i<auth_n;i++)if(!((auth[i]>='0'&&auth[i]<='9')||(auth[i]>='a'&&auth[i]<='f')))return 0;}
    for(i=0;i<method_n;i++)g_method[i]=method[i];g_method[method_n]=0; for(i=0;i<path_n;i++)g_path[i]=path[i];g_path[path_n]=0;
    session=InternetOpenA("Chocolatier Reforged Community Bridge/0.2.13",INTERNET_OPEN_TYPE_PRECONFIG,0,0,0); if(!session){*winerr=GetLastError();goto done;}
    connect=InternetConnectA(session,g_host,INTERNET_DEFAULT_HTTPS_PORT,0,0,INTERNET_SERVICE_HTTP,0,0); if(!connect){*winerr=GetLastError();goto done;}
    req=HttpOpenRequestA(connect,g_method,g_path,0,0,0,INTERNET_FLAG_SECURE|INTERNET_FLAG_RELOAD|INTERNET_FLAG_NO_CACHE_WRITE|INTERNET_FLAG_NO_UI,0); if(!req){*winerr=GetLastError();goto done;}
    if(body_n) hat=append_text(g_headers,hat,511,"Content-Type: application/json; charset=utf-8\r\n");
    hat=append_text(g_headers,hat,511,"Accept: application/json\r\n");
    if(auth && auth_n){
        if(auth_n>=120) goto done;
        hat=append_text(g_headers,hat,511,"Authorization: Bearer ");
        for(i=0;i<auth_n && hat<511;i++) g_headers[hat++]=auth[i];
        hat=append_text(g_headers,hat,511,"\r\n");
    }
    g_headers[hat]=0;
    if(body_n){if(!HttpSendRequestA(req,g_headers,hat,(LPVOID)body,body_n)){*winerr=GetLastError();goto done;}}
    else {if(!HttpSendRequestA(req,g_headers,hat,0,0)){*winerr=GetLastError();goto done;}}
    if(!HttpQueryInfoA(req,HTTP_QUERY_STATUS_CODE|HTTP_QUERY_FLAG_NUMBER,status,&sz,&idx)){*winerr=GetLastError();goto done;}
    while(total<RESPONSE_MAX){DWORD want=RESPONSE_MAX-total;if(want>16384)want=16384;got=0;if(!InternetReadFile(req,g_http_body+total,want,&got)){*winerr=GetLastError();goto done;}if(!got)break;total+=got;}
    if(total>=RESPONSE_MAX){*too_large=1;goto done;}g_http_body[total]=0;*response_n=total;ok=1;
done: if(req)InternetCloseHandle(req);if(connect)InternetCloseHandle(connect);if(session)InternetCloseHandle(session);return ok;
}
static void emit_response(DWORD id, DWORD status, const char *body, DWORD body_n, const char *bridge_error) {
    DWORD at=0; at=append_text(g_response,at,RESPONSE_MAX+511,"CCB1\nID: ");at=append_uint(g_response,at,RESPONSE_MAX+511,id);
    at=append_text(g_response,at,RESPONSE_MAX+511,"\nSTATUS: ");at=append_uint(g_response,at,RESPONSE_MAX+511,status);
    if(bridge_error){at=append_text(g_response,at,RESPONSE_MAX+511,"\nBRIDGE-ERROR: ");at=append_text(g_response,at,RESPONSE_MAX+511,bridge_error);}
    at=append_text(g_response,at,RESPONSE_MAX+511,"\nBODY-LENGTH: ");at=append_uint(g_response,at,RESPONSE_MAX+511,body_n);at=append_text(g_response,at,RESPONSE_MAX+511,"\n\n");
    if(body&&body_n&&at+body_n<=RESPONSE_MAX+511){copy_n(g_response+at,body,body_n);at+=body_n;}at=append_text(g_response,at,RESPONSE_MAX+511,"\nCCB-END\n");
    if(write_file(g_response_tmp,g_response,at)){DeleteFileA(g_response_file);MoveFileExA(g_response_tmp,g_response_file,MOVEFILE_REPLACE_EXISTING|MOVEFILE_WRITE_THROUGH);}
}
static void init_presence_id(void) {
    FILETIME ft; DWORD at=0;
    GetSystemTimeAsFileTime(&ft);
    at=append_text(g_presence_id,at,95,"bridge_");
    at=append_uint(g_presence_id,at,95,GetCurrentProcessId());
    at=append_text(g_presence_id,at,95,"_");
    at=append_uint(g_presence_id,at,95,GetTickCount());
    at=append_text(g_presence_id,at,95,"_");
    at=append_uint(g_presence_id,at,95,ft.dwHighDateTime);
    at=append_text(g_presence_id,at,95,"_");
    at=append_uint(g_presence_id,at,95,ft.dwLowDateTime);
    g_presence_id[at]=0;
}

static int load_presence_auth(char *token, DWORD cap) {
    DWORD n=0,i,j; char *key,*p,*end; const char *needle="\"session_token\""; DWORD needle_n=15;
    if(!token || cap<65 || !g_ipc_ready) return 0;
    token[0]=0;
    if(!read_file(g_account_file,g_account_json,8191,&n) || !n) return 0;
    key=find_seq(g_account_json,n,needle,needle_n);
    if(!key) return 0;
    p=key+needle_n; end=g_account_json+n;
    while(p<end && (*p==' '||*p=='\t'||*p=='\r'||*p=='\n')) p++;
    if(p>=end || *p!=':') return 0; p++;
    while(p<end && (*p==' '||*p=='\t'||*p=='\r'||*p=='\n')) p++;
    if(p>=end || *p!='\"') return 0; p++;
    for(i=0;i<64;i++){
        if(p+i>=end) return 0;
        if(!((p[i]>='0'&&p[i]<='9')||(p[i]>='a'&&p[i]<='f'))) return 0;
        token[i]=p[i];
    }
    j=64;
    if(p+j>=end || p[j]!='\"') return 0;
    token[64]=0;
    return 1;
}

static void heartbeat_presence(void) {
    char body[180],token[65]; DWORD at=0,status=0,response_n=0,winerr=0,auth_n=0; int too_large=0;
    at=append_text(body,at,179,"{\"client_id\":\"");
    at=append_text(body,at,179,g_presence_id);
    at=append_text(body,at,179,"\",\"bridge_version\":\"0.2.13\"}");
    body[at]=0;
    if(load_presence_auth(token,65)) auth_n=64;
    http_request("POST",4,"/api/v1/community/presence",26,auth_n?token:0,auth_n,body,at,&status,&response_n,&winerr,&too_large);
    g_last_presence_tick=GetTickCount();
}

static int open_external_link(const char *path, DWORD path_n) {
    const char *url=0; void *result;
    if(path_n==17 && s_eq_n(path,"/external/discord",17)) url="https://discord.gg/ef3TPaVsmq";
    else if(path_n==14 && s_eq_n(path,"/external/wiki",14)) url="https://the-chocolatier-series.fandom.com/wiki/The_Chocolatier_Series_Wiki";
    else return 0;
    result=ShellExecuteA(0,"open",url,0,0,SW_SHOWNORMAL);
    return ((long long)result)>32;
}

static void process_request(void) {
    DWORD n=0,head_n,id=0,body_declared=0,body_n=0,status=0,http_n=0,winerr=0,sep_n=0,end_marker_n=0;char *sep,*end,*v,*method,*path,*auth=0,*body;DWORD vn,method_n,path_n,auth_n=0;int too_large=0;
    if(!read_file(g_request_file,g_request,REQUEST_MAX,&n))return;

    // Playground's WriteToFile() is a text-mode helper. Even when Lua builds
    // the bridge envelope with LF line endings, Windows receives CRLF bytes.
    // Accept both forms so the wire format is stable across the old engine's
    // newline translation and direct/native test fixtures.
    sep=find_seq(g_request,n,"\r\n\r\n",4); sep_n=4;
    if(!sep){sep=find_seq(g_request,n,"\n\n",2);sep_n=2;}
    if(!sep){DeleteFileA(g_request_file);write_status("MALFORMED REQUEST",0);return;}
    end=find_seq(sep+sep_n,n-(DWORD)((sep+sep_n)-g_request),"\r\nCCB-END\r\n",11);end_marker_n=11;
    if(!end){end=find_seq(sep+sep_n,n-(DWORD)((sep+sep_n)-g_request),"\nCCB-END\n",9);end_marker_n=9;}
    if(!end){DeleteFileA(g_request_file);write_status("MALFORMED REQUEST",0);return;}
    if((DWORD)(end-g_request)+end_marker_n!=n){DeleteFileA(g_request_file);write_status("MALFORMED REQUEST",0);return;}
    head_n=(DWORD)(sep-g_request);body=sep+sep_n;body_n=(DWORD)(end-body);
    if(!field(g_request,head_n,"ID",&v,&vn)||!parse_uint_strict(v,vn,&id)){DeleteFileA(g_request_file);write_status("MALFORMED REQUEST",0);return;}
    if(!field(g_request,head_n,"METHOD",&method,&method_n)||!field(g_request,head_n,"PATH",&path,&path_n)){DeleteFileA(g_request_file);emit_response(id,0,"",0,"Malformed bridge request.");write_status("MALFORMED REQUEST",0);return;}
    if(!field(g_request,head_n,"BODY-LENGTH",&v,&vn)||!parse_uint_strict(v,vn,&body_declared)||body_declared!=body_n){DeleteFileA(g_request_file);emit_response(id,0,"",0,"Bridge body length mismatch.");write_status("BODY LENGTH MISMATCH",0);return;}
    if(field(g_request,head_n,"AUTH",&auth,&auth_n)){
        DWORD ai;if(auth_n!=64){DeleteFileA(g_request_file);emit_response(id,0,"",0,"Malformed bridge auth token.");write_status("MALFORMED AUTH",0);return;}for(ai=0;ai<auth_n;ai++)if(!((auth[ai]>='0'&&auth[ai]<='9')||(auth[ai]>='a'&&auth[ai]<='f'))){DeleteFileA(g_request_file);emit_response(id,0,"",0,"Malformed bridge auth token.");write_status("MALFORMED AUTH",0);return;}
    }
    if(!((method_n==3&&s_eq_n(method,"GET",3))||(method_n==4&&s_eq_n(method,"POST",4))||(method_n==4&&s_eq_n(method,"OPEN",4)))||path_n==0||path_n>=4096||path[0]!='/'){DeleteFileA(g_request_file);emit_response(id,0,"",0,"Malformed bridge request.");write_status("MALFORMED REQUEST",0);return;}
    {DWORD pi;for(pi=0;pi<path_n;pi++)if((unsigned char)path[pi]<32U||(unsigned char)path[pi]==127U){DeleteFileA(g_request_file);emit_response(id,0,"",0,"Malformed bridge request path.");write_status("MALFORMED REQUEST",0);return;}}
    if(method_n==4&&s_eq_n(method,"OPEN",4)){
        DeleteFileA(g_request_file);
        if(body_n!=0 || auth_n!=0 || !open_external_link(path,path_n)){
            emit_response(id,0,"",0,"External link is not allowlisted or could not be opened.");
            write_status("EXTERNAL LINK FAILED",GetLastError());
            return;
        }
        emit_response(id,200,"{\"status\":\"ok\"}",15,0);
        write_status("READY",0);
        return;
    }
    DeleteFileA(g_request_file);write_status("REQUESTING",0);if(!http_request(method,method_n,path,path_n,auth,auth_n,body,body_n,&status,&http_n,&winerr,&too_large)){if(too_large){write_status("RESPONSE TOO LARGE",0);emit_response(id,0,"",0,"Community server response exceeded the bridge size limit.");}else{write_status("NETWORK REQUEST FAILED",winerr);emit_response(id,0,"",0,"Network request failed. See community_bridge/bridge_status.txt.");}return;}emit_response(id,status,g_http_body,http_n,0);write_status("READY",0);
}

void mainCRTStartup(void) {
    HANDLE stop; char discovered[PATHBUF_MAX]; const char *ready="CCB1 READY\r\nVERSION: 0.2.13\r\n";
    init_control_paths();load_host();init_presence_id();write_status("WAITING FOR GAME USER-FILE ROOT",0);
    for(;;){
        stop=CreateFileA(g_stop_file,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
        if(stop!=INVALID_HANDLE_VALUE){CloseHandle(stop);DeleteFileA(g_stop_file);if(g_ipc_ready){DeleteFileA(g_ready_file);DeleteFileA(g_probe_file);}write_status("STOPPED",0);ExitProcess(0);}
        if(!g_ipc_ready){
            if(discover_ipc_root(discovered,PATHBUF_MAX)){init_ipc_paths(discovered);DeleteFileA(g_ready_file);if(!write_file(g_ready_file,ready,s_len(ready))){write_status("READY MARKER FAILED",GetLastError());ExitProcess(2);}DeleteFileA(g_probe_file);write_status("READY",0);}
        } else {
            process_request();
            if(g_last_presence_tick==0 || (DWORD)(GetTickCount()-g_last_presence_tick)>=PRESENCE_INTERVAL_MS) heartbeat_presence();
        }
        Sleep(50);
    }
}
