#define PublicVersion GetEnv("REFORGED_PUBLIC_VERSION")
#if PublicVersion == ""
  #define PublicVersion "2.0.1"
#endif

[Setup]
AppId={{D726376B-97AA-45E0-A670-56C4D7EC2072}
AppName=Chocolatier: Decadence by Design Reforged
AppVersion={#PublicVersion}
AppVerName=Chocolatier: Decadence by Design Reforged v{#PublicVersion}
DefaultDirName={pf32}\PlayFirst\Chocolatier Decadence by Design
; Reforged installs into an existing game folder. Do not append the default
; folder name again when the user browses to that exact directory.
AppendDefaultDirName=no
DisableProgramGroupPage=yes
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
OutputDir=dist
OutputBaseFilename=Chocolatier-Reforged-v{#PublicVersion}-Setup
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
; The same AppId is intentionally retained across releases so a newer Setup
; upgrades the existing Reforged installation instead of creating a second one.
UsePreviousAppDir=yes
DisableDirPage=auto
AlwaysShowDirOnReadyPage=yes
; The native launcher holds this mutex for the entire game session, so Setup
; cannot replace Reforged files while the game/Community bridge are in use.
AppMutex=ChocolatierReforged_v2_Launcher
SetupMutex=ChocolatierReforged_v2_Setup
UninstallDisplayName=Chocolatier: Decadence by Design Reforged
SetupLogging=yes

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop shortcut"; GroupDescription: "Additional shortcuts:"; Flags: checkedonce

[Files]
Source: "..\assets\*"; DestDir: "{app}\assets"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "bin\Chocolatier Reforged.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\community_bridge\ReforgedCommunityBridge.exe"; DestDir: "{app}\community_bridge"; Flags: ignoreversion
Source: "..\community_bridge\bridge_version.txt"; DestDir: "{app}\community_bridge"; Flags: ignoreversion
Source: "generated\server.txt"; DestDir: "{app}\community_bridge"; DestName: "server.txt"; Flags: ignoreversion
Source: "generated\hiscoreserver.txt"; DestDir: "{app}"; DestName: "hiscoreserver.txt"; Flags: ignoreversion
Source: "generated\CLIENT_VERSION.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "generated\RELEASE_CHANNEL.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "generated\REFORGED_RELEASE.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\README.md"; DestDir: "{app}"; DestName: "README-Reforged.md"; Flags: ignoreversion
Source: "..\CHANGELOG.md"; DestDir: "{app}"; DestName: "CHANGELOG-Reforged.md"; Flags: ignoreversion

[InstallDelete]
Type: files; Name: "{app}\launch-reforged-community.bat"
Type: files; Name: "{app}\community_bridge\bridge_status.txt"
Type: files; Name: "{app}\community_bridge\stop.txt"
Type: files; Name: "{app}\community_bridge\built-version.txt"
Type: files; Name: "{app}\community_bridge\build-native-bridge.bat"
Type: files; Name: "{app}\community_bridge\BUILD_NATIVE_BRIDGE.md"
Type: files; Name: "{app}\community_bridge\community_bridge_source.c"

[Icons]
Name: "{autoprograms}\Chocolatier Reforged"; Filename: "{app}\Chocolatier Reforged.exe"; WorkingDir: "{app}"; IconFilename: "{app}\chocolatier-decadence.exe"
Name: "{autodesktop}\Chocolatier Reforged"; Filename: "{app}\Chocolatier Reforged.exe"; WorkingDir: "{app}"; IconFilename: "{app}\chocolatier-decadence.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\Chocolatier Reforged.exe"; Description: "Launch Chocolatier Reforged"; Flags: nowait postinstall skipifsilent
Filename: "{app}\CHANGELOG-Reforged.md"; Description: "View Reforged v{#PublicVersion} change notes"; Flags: postinstall shellexec skipifsilent unchecked

[Code]
function ValidGameFolder(Path: String): Boolean;
begin
  Result := FileExists(AddBackslash(Path) + 'chocolatier-decadence.exe') and
            FileExists(AddBackslash(Path) + 'CadiApi.dll');
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if CurPageID = wpSelectDir then
  begin
    if not ValidGameFolder(WizardDirValue) then
    begin
      MsgBox(
        'Choose your existing Chocolatier: Decadence by Design installation folder.' + #13#10 + #13#10 +
        'The selected folder must contain chocolatier-decadence.exe and CadiApi.dll.',
        mbError, MB_OK);
      Result := False;
    end;
  end;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  AssetsDir, BackupDir: String;
begin
  Result := '';
  AssetsDir := AddBackslash(WizardDirValue) + 'assets';
  BackupDir := AddBackslash(WizardDirValue) + 'assets_vanilla_backup';

  if not DirExists(BackupDir) then
  begin
    if not DirExists(AssetsDir) then
    begin
      Result := 'The selected game folder has no assets directory.';
      Exit;
    end;
    if not RenameFile(AssetsDir, BackupDir) then
    begin
      Result := 'Could not preserve the original assets folder. Close the game and try again.';
      Exit;
    end;
  end
  else if DirExists(AssetsDir) then
  begin
    if not DelTree(AssetsDir, True, True, True) then
    begin
      Result := 'Could not replace the previous Reforged assets folder. Close the game and try again.';
      Exit;
    end;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  AssetsDir, BackupDir: String;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    AssetsDir := AddBackslash(ExpandConstant('{app}')) + 'assets';
    BackupDir := AddBackslash(ExpandConstant('{app}')) + 'assets_vanilla_backup';
    if DirExists(AssetsDir) then
      DelTree(AssetsDir, True, True, True);
    if DirExists(BackupDir) and not DirExists(AssetsDir) then
      RenameFile(BackupDir, AssetsDir);
  end;
end;
