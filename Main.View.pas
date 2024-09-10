unit Main.View;

interface

uses
{$REGION '  Winapi''s .. '}
  Winapi.Windows,
  Winapi.Messages,
{$ENDREGION}
{$REGION '  System''s .. '}
  System.SysUtils,
  System.Variants,
  System.Classes,
{$ENDREGION}
{$REGION '  Vcl''s .. '}
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs
{$ENDREGION}
//
, System.IOUtils
, System.StrUtils
//
, Vcl.ExtCtrls
, Vcl.StdCtrls
//
, API.JarBuilder
;


type
  TMainView = class(TForm)
    Btn_Build: TButton;
    Memo_Log: TMemo;
    Pnl_Status: TPanel;
    Edt_JarFilesDir: TEdit;
    Lbl_1: TLabel;
    Btn_LoadJarFilesDir: TButton;
    Pnl_JarFilesDir: TPanel;
    Pnl_AndroidJarPath: TPanel;
    Edt_AndroidJarPath: TEdit;
    Btn_LoadJarLibDir: TButton;
    Lbl_2: TLabel;
    Edt_ResultJarName: TEdit;
    Lbl_3: TLabel;
    Pnl_Process: TPanel;
    Btn_LoadJarFile: TButton;
    procedure Edt_JarFilesDirChange(Sender: TObject);
    procedure Btn_BuildClick(Sender: TObject);
    procedure Btn_LoadJarFilesDirClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Btn_LoadJarFileClick(Sender: TObject);
    procedure Btn_LoadJarLibDirClick(Sender: TObject);
  strict private
    fAndroidJarFullPath: string;
    function GetDir: string; inline;
    function GetFullPath(aFileTypes: TFileTypeItems): string; inline;
    function GetJarLibFullPath: string; inline;
    function IsEmbarcaderoAndroidJarLocated(out aAndroidJarPath: string): Boolean; inline;
  private
    fjarBuilder: IJarBuilder;

    function GetJarBuilder: IJarBuilder;

  public
    { Public declarations }
    property jarBuilder: IJarBuilder read GetJarBuilder;
  end;

implementation

{$R *.dfm}

function TMainView.IsEmbarcaderoAndroidJarLocated(out aAndroidJarPath: string): Boolean;
var
  BaseSDKPath, VersionFolder, SDKFolder, PlatformsPath, JarPath: string;
  StudioFolders, Folders: TArray<string>;
  StudioFolder, Folder, PlatformFolder: string;
  MaxVersion: Integer;
begin
  // Base path where SDK is typically installed
  BaseSDKPath := 'C:\Users\Public\Documents\Embarcadero\Studio\';
  if not TDirectory.Exists(BaseSDKPath) then begin
    Pnl_Status.Caption := BaseSDKPath+' (Base path not found !!)';
    Exit(False);
  end;

  MaxVersion := 0;
  JarPath := '';

  // Search for version folders (like "23.0") in the Studio path
  StudioFolders := TDirectory.GetDirectories(BaseSDKPath, '*', TSearchOption.soTopDirectoryOnly);

  // Iterate through the Studio version folders
  for StudioFolder in StudioFolders do begin

    // Check if the folder contains the CatalogRepository
    VersionFolder := TPath.Combine(StudioFolder, 'CatalogRepository');
    if TDirectory.Exists(VersionFolder) then
    begin
      // Search for AndroidSDK folders within CatalogRepository, but exclude NDK folders
      Folders := TDirectory.GetDirectories(VersionFolder, 'AndroidSDK-*', TSearchOption.soTopDirectoryOnly);

      // Iterate through the AndroidSDK folders
      for Folder in Folders do begin

        // Exclude folders that match the "AndroidSDK-NDK-*" pattern
        if not StartsText('AndroidSDK-NDK-', ExtractFileName(Folder)) then
        begin
          SDKFolder := Folder;

          // Check the platforms folder for android versions
          PlatformsPath := TPath.Combine(SDKFolder, 'platforms');
          if TDirectory.Exists(PlatformsPath) then
          begin
            for PlatformFolder in TDirectory.GetDirectories(PlatformsPath) do
            begin
              // Extract the platform version from the folder name (e.g., android-30, android-31)
              if StartsText('android-', ExtractFileName(PlatformFolder)) then
              begin
                try
                  // Extract the version number
                  var VersionStr := Copy(ExtractFileName(PlatformFolder), 9, MaxInt);
                  var Version := StrToIntDef(VersionStr, 0);

                  // Find the highest version number available
                  if (Version > MaxVersion) then
                  begin
                    MaxVersion := Version;
                    JarPath := TPath.Combine(PlatformFolder, 'android.jar');
                  end;
                except
                  // Skip folders that do not have a valid number in the name
                  Continue;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;


  // Check if a valid android.jar file was found
  if (JarPath <> '') and TFile.Exists(JarPath) then begin
    Result := True;
    aAndroidJarPath := JarPath;
  end else begin
    Result := False;
    aAndroidJarPath := ''; // Return empty if no valid android.jar is found
  end;
end;

{ TMainView }

function TMainView.GetDir: string;
begin
  with TFileOpenDialog.Create(nil) do
  try
    DefaultFolder := ExtractFilePath(ParamStr(0));  // Use current folder as default
    Options := Options + [fdoPickFolders];  // Set to pick folders instead of files
    Title := 'Select Directory';
    if Execute then begin
      Result := FileName;
    end;
  finally
    Free;
  end;
end;

function TMainView.GetFullPath(aFileTypes: TFileTypeItems): string;
begin
  with TFileOpenDialog.Create(nil) do
  try
    Title := 'Select File';
    DefaultExtension := '*.jar';  // Set a default extension
    DefaultFolder := ExtractFilePath(ParamStr(0));  // Use current folder as default
//    Options := Options - [fdoPickFolders];  // Disable folder picking
    FileTypes.Assign(aFileTypes);  // Use the passed file types for filtering
    OkButtonLabel := 'Open Selected File';
    if Execute then
      Result := FileName;  // Return the full path of the selected file
  finally
    Free;
  end;
end;

function TMainView.GetJarLibFullPath: string;
var
  LFileTypeItems: TFileTypeItems;
  LFileTypeItem: TFileTypeItem;
  LFullPath: string;
begin
  LFullPath := '';
  LFileTypeItems := TFileTypeItems.Create(TFileTypeItem);
  try
    LFileTypeItem := LFileTypeItems.Add;
    with LFileTypeItem do begin
      DisplayName := 'Android JAR File';
      FileMask := '*.jar';
    end;
    LFullPath := GetFullPath(LFileTypeItems);
  finally
    LFileTypeItems.Free;
  end;


  Result := LFullPath;
end;

procedure TMainView.FormCreate(Sender: TObject);
var
  LJavaFilesDir: string;
begin
  if IsEmbarcaderoAndroidJarLocated(fAndroidJarFullPath) then
    Edt_AndroidJarPath.Text := fAndroidJarFullPath;

  LJavaFilesDir := ExtractFilePath(ParamStr(0)) + 'JavaClasses';
  if DirectoryExists(LJavaFilesDir) then
    Edt_JarFilesDir.Text := LJavaFilesDir;
end;

procedure TMainView.Btn_LoadJarLibDirClick(Sender: TObject);
begin
  Edt_AndroidJarPath.Text := GetDir;
end;

procedure TMainView.Btn_LoadJarFileClick(Sender: TObject);
begin
  Edt_AndroidJarPath.Text := GetJarLibFullPath;
end;

procedure TMainView.Btn_LoadJarFilesDirClick(Sender: TObject);
begin
  Edt_JarFilesDir.Text := GetDir;
end;

function TMainView.GetJarBuilder: IJarBuilder;
begin
  if not Assigned(fjarBuilder) then
    fjarBuilder := GetTJarBuilder(nil);

  Result := fjarBuilder;
end;

procedure TMainView.Btn_BuildClick(Sender: TObject);
begin
  jarBuilder
    .SetRequiredFiles(Edt_JarFilesDir.Text,
                      Edt_AndroidJarPath.Text,
                      Edt_ResultJarName.Text)
    .SetOnProcessLog(procedure(aOnProcessLog: string)
      begin
        Memo_Log.Lines.Append(aOnProcessLog);
      end)
    .CompileAndCreateJar;
end;

procedure TMainView.Edt_JarFilesDirChange(Sender: TObject);
begin
  Btn_Build.Enabled := (Edt_JarFilesDir.Text <> '') and
                       (Edt_AndroidJarPath.Text <> '') ;
end;

end.
