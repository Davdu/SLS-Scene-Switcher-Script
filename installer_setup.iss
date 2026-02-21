; SLS Scene Switcher Installer Script
; Requires Inno Setup 6.0 or later to compile
; Download from: https://jrsoftware.org/isdl.php

#ifexist "VERSION"
  #define MyAppVersion Trim(ReadFileLines(SourcePath + "\VERSION")[0])
#else
  #define MyAppVersion "1.3-dev"
#endif

#define MyAppName "SLS Scene Switcher"
#define MyAppPublisher "Mads Andersen"
#define MyAppURL "https://github.com/Davdu/SLS-Scene-Switcher-Script"
#define PythonVersion "3.11.9"
#define PythonURL "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe"

[Setup]
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
OutputDir=.
OutputBaseFilename=SLS_Scene_Switcher_{#MyAppVersion}_Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
; The main script file
Source: "sls_scene_switcher.py"; DestDir: "{code:GetOBSScriptPath}"; Flags: ignoreversion
[Code]
var
  PythonInstalled: Boolean;
  PythonPath: String;
  OBSScriptPath: String;
  DownloadPage: TDownloadWizardPage;
  
function GetOBSInstallPath(): String;
var
  InstallPath: String;
begin
  // Try to find OBS installation in registry
  if RegQueryStringValue(HKLM64, 'SOFTWARE\OBS Studio', 'InstallPath', InstallPath) then
    Result := InstallPath
  else if RegQueryStringValue(HKCU64, 'SOFTWARE\OBS Studio', 'InstallPath', InstallPath) then
    Result := InstallPath
  else
    Result := ExpandConstant('{pf}\obs-studio');
end;

function GetOBSScriptPath(Param: String): String;
begin
  // OBS scripts are typically stored in user's AppData
  Result := ExpandConstant('C:\Program Files\obs-studio\data\obs-plugins\frontend-tools\scripts');
end;

function CheckPythonInstalled(): Boolean;
var
  ResultCode: Integer;
  PythonVersionOutput: AnsiString;
  TempFile: String;
begin
  Result := False;
  TempFile := ExpandConstant('{tmp}\python_version.txt');
  
  // Try to run python --version and capture output
  if Exec('cmd.exe', '/c python --version > "' + TempFile + '" 2>&1', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
  begin
    if FileExists(TempFile) then
    begin
      if LoadStringFromFile(TempFile, PythonVersionOutput) then
      begin
        // Check if Python 3.11 is installed
        if Pos('Python 3.11', String(PythonVersionOutput)) > 0 then
        begin
          Result := True;
        end;
      end;
      DeleteFile(TempFile);
    end;
  end;
  
  // Also check in common installation paths
  if FileExists(ExpandConstant('{localappdata}\Programs\Python\Python311\python.exe')) then
  begin
    PythonPath := '{localappdata}\Programs\Python\Python311\python.exe';
    
    Result := True;
  end
  else if FileExists('C:\Program Files\Python311\python.exe') then
  begin
    PythonPath := 'C:\Program Files\Python311\python.exe';
    Result := True;
  end
  else if FileExists('C:\Python311\python.exe') then
  begin
    PythonPath := 'C:\Python311\python.exe';
    Result := True;
  end;
end;

procedure InitializeWizard();
begin
  PythonInstalled := CheckPythonInstalled();
  
  // Create download page for Python if needed
  if not PythonInstalled then
  begin
    DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), nil);
  end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  ResultCode: Integer;
  PythonInstaller: String;
begin
  Result := True;
  
  if (CurPageID = wpReady) and (not PythonInstalled) then
  begin
    DownloadPage.Clear;
    DownloadPage.Add('{#PythonURL}', 'python-{#PythonVersion}-amd64.exe', '');
    DownloadPage.Show;
    
    try
      DownloadPage.Download;
      Result := True;
      
      PythonInstaller := ExpandConstant('{tmp}\python-{#PythonVersion}-amd64.exe');
      
      if MsgBox('Python 3.11.9 needs to be installed. Install now?' + #13#10 + #13#10 + 
                'The installer will:' + #13#10 +
                '  - Install Python 3.11.9 for all users', 
                mbConfirmation, MB_YESNO) = IDYES then
      begin
        // Install Python silently with options
        if not Exec(PythonInstaller, '/quiet InstallAllUsers=1 PrependPath=0 Include_pip=1', '', SW_SHOW, ewWaitUntilTerminated, ResultCode) then
        begin
          MsgBox('Python installation failed. Please install Python 3.11.9 manually from python.org', mbError, MB_OK);
          Result := False;
        end
        else if ResultCode <> 0 then
        begin
          MsgBox('Python installation returned an error. Please try installing manually.', mbError, MB_OK);
          Result := False;
        end;
      end
      else
      begin
        MsgBox('Python is required for this script to work. Installation cancelled.', mbInformation, MB_OK);
        Result := False;
      end;
    except
      MsgBox('Failed to download Python installer. Please check your internet connection.', mbError, MB_OK);
      Result := False;
    finally
      DownloadPage.Hide;
    end;
  end;
  PythonInstalled := CheckPythonInstalled();
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
begin
  if CurStep = ssPostInstall then
  begin
    // Install Python dependencies (requests library)
    if MsgBox('Install Python dependencies (requests library)?' + #13#10 + #13#10 + 
              'This is required for the script to function.', mbConfirmation, MB_YESNO) = IDYES then
    begin
      // Install requests via pip      
      if not Exec(PythonPath,  '-m pip install --upgrade pip', '', SW_SHOW, ewWaitUntilTerminated, ResultCode) then
        MsgBox('Failed to upgrade pip. You may need to install the "requests" library manually.', mbInformation, MB_OK);
      
      if not Exec(PythonPath, '-m pip install requests', '', SW_SHOW, ewWaitUntilTerminated, ResultCode) then
        MsgBox('Failed to install requests library. Please run: pip install requests', mbError, MB_OK)
      else if ResultCode = 0 then
        MsgBox('Dependencies installed successfully!', mbInformation, MB_OK)
      else
        MsgBox('There was an issue installing dependencies. You may need to run: pip install requests', mbInformation, MB_OK);
    end;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  ScriptPath: String;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    ScriptPath := ExpandConstant('C:\Program Files\obs-studio\data\obs-plugins\frontend-tools\scripts\sls_scene_switcher.py');
    if FileExists(ScriptPath) then
      DeleteFile(ScriptPath);
  end;
end;

[Run]
Filename: "https://github.com/Davdu/SLS-Scene-Switcher-Script?tab=readme-ov-file#configuration"; Description: "Open the configuration section on github."; Flags: shellexec postinstall skipifsilent nowait

[Messages]
FinishedHeadingLabel=Finished SLS Scene Switcher Installation.

