unit API.JarBuilder;

interface

uses
  System.SysUtils,  // TProc<T>
  System.Classes;

type
  ISetOnProcessLog = interface;
  ICompileJar = interface;

  IJarBuilder = interface ['{85F62E0D-9F2C-481D-8D06-5FC01BF02951}']
    function SetRequiredFiles(const aJavaFilesDir,
                                    aAndroidJarLibFilesDir,
                                    aResultJarName: string): ISetOnProcessLog;
  end;

  ISetOnProcessLog = interface ['{005B58AA-0073-4922-9903-EB5F12E4BB7B}']
    function SetOnProcessLog(aOnProcessLog: TProc<string>): ICompileJar;
  end;

  ICompileJar = interface ['{6F31ACD0-6638-4EDB-B491-DA569CA494D0}']
    function CompileAndCreateJar: Boolean;
  end;

  function GetTJarBuilder(aOwner: TComponent): IJarBuilder;

implementation

uses
  System.IOUtils, DosCommand;

type
  TJarBuilder = class(TInterfacedObject, IJarBuilder, ISetOnProcessLog, ICompileJar)
  protected
    fDosCMD: TDosCommand;
    fJavaFilesDir,
    fAndroidJarLibFilesDir,
    fResultJarName: string;
    fOnProcessLog: TProc<string>;
    fResult: string;
    fOnlyJarLib: Boolean;
    function LoadFilesFromDir(const aDirectory, aExtension: string): TArray<string>;
    procedure OnDosCMD_NewLine(aSender: TObject; const aNewLine: string; aOutputType: TOutputType);
    procedure OnDosCMDTerminate(aSender: TObject);

    constructor Create(aOwner: TComponent); overload; virtual;
  public
    destructor Destroy; override;

    function SetRequiredFiles(const aJavaFilesDir,
                                   aAndroidJarLibFilesDir,
                                   aResultJarName: string): ISetOnProcessLog;
    function SetOnProcessLog(aOnProcessLog: TProc<string>): ICompileJar;
    function CompileAndCreateJar: Boolean;
  end;

function GetTJarBuilder(aOwner: TComponent): IJarBuilder;
begin
  Result := TJarBuilder.Create(aOwner);
end;

{ TJarBuilder }

constructor TJarBuilder.Create(aOwner: TComponent);
begin
  fJavaFilesDir := '';
  fAndroidJarLibFilesDir := '';
  fResultJarName := '';
  fOnProcessLog := nil;
  fResult := '';
  fOnlyJarLib := False;

  fDosCMD := TDosCommand.Create(aOwner);
end;

destructor TJarBuilder.Destroy;
begin
  fDosCMD.Free;
  inherited;
end;

function TJarBuilder.LoadFilesFromDir(const aDirectory, aExtension: string): TArray<string>;
begin
  try
    Result := TDirectory.GetFiles(aDirectory, aExtension, TSearchOption.soAllDirectories);
  except
    on Ex: Exception do
    begin
      if Assigned(fOnProcessLog) then
        fOnProcessLog(Format('Error loading files from directory "%s": %s', [aDirectory, Ex.Message]));
      Result := nil;
    end;
  end;
end;

procedure TJarBuilder.OnDosCMDTerminate(aSender: TObject);
var
  LClassFiles: TArray<string>;
  LClassFilePaths,
  LRelativePath,
  LBaseOutputDir: string;
begin
  LClassFilePaths := '';
  fResult := 'Checking for compiled class files...';

  // Step 1: Load all .class files from the output directory
  LClassFiles := LoadFilesFromDir(fJavaFilesDir + '\Output', '*.class');
  LBaseOutputDir := fJavaFilesDir + '\Output\com';

  if Assigned(LClassFiles) and (Length(LClassFiles) > 0) then
  begin
    for var LFilePath in LClassFiles do
    begin
      LRelativePath := ExtractRelativePath(LBaseOutputDir, LFilePath);
      LRelativePath := '.\' +LRelativePath;
      // Join the JavaClass files into a string for the command
      LClassFilePaths := LClassFilePaths + AnsiQuotedStr(LRelativePath, '"') + ' ';
    end;

    // Step 2: Create the JAR file with the compiled class files
    if fResultJarName.IsEmpty then
      fResultJarName := 'OutputJar';
    fDosCMD.CommandLine := Format('jar cf "%s.jar" %s', [fResultJarName,
                                                             LClassFilePaths]);
  if Assigned(fOnProcessLog) then
    fOnProcessLog(fDosCMD.CommandLine);
    fDosCMD.CurrentDir := fJavaFilesDir + '\Output';
    fDosCMD.OnNewLine := OnDosCMD_NewLine;
    fDosCMD.OnTerminated := nil;
    fResult := 'Packaging class files into JAR...';
    fDosCMD.Execute;
  end
  else if Assigned(fOnProcessLog) then
    fOnProcessLog('No class files found for packaging.');
end;

procedure TJarBuilder.OnDosCMD_NewLine(aSender: TObject; const aNewLine: string; aOutputType: TOutputType);
begin
  if Assigned(fOnProcessLog) then
    fOnProcessLog(aNewLine);
end;

function TJarBuilder.SetRequiredFiles(const aJavaFilesDir,
  aAndroidJarLibFilesDir,
  aResultJarName: string): ISetOnProcessLog;
begin
  Result := Self as ISetOnProcessLog;

  fJavaFilesDir          := aJavaFilesDir;
  fAndroidJarLibFilesDir := aAndroidJarLibFilesDir;
  fResultJarName         := aResultJarName;

  fOnlyJarLib := TFile.Exists(fAndroidJarLibFilesDir);
end;

function TJarBuilder.SetOnProcessLog(aOnProcessLog: TProc<string>): ICompileJar;
begin
  Result := Self as ICompileJar;
  fOnProcessLog := aOnProcessLog;
end;

function TJarBuilder.CompileAndCreateJar: Boolean;
var
  LJavaFiles: TArray<string>;
  LAndroidJarLibFiles: TArray<string>;
  LJavaFilePaths,
  LAndroidJarLibFilePaths: string;
  LOutputDir: string;
begin
  LJavaFilePaths := '';
  LAndroidJarLibFilePaths := '';
  Result := False;

  // Step 1: Ensure output directory exists
  LOutputDir := IncludeTrailingPathDelimiter(fJavaFilesDir) + 'Output';
  if not TDirectory.Exists(LOutputDir) then
    TDirectory.CreateDirectory(LOutputDir);


  // Step 2: Load all Required *.java files from JavaFilesDir directory
  LJavaFiles := LoadFilesFromDir(fJavaFilesDir, '*.java');
  if Length(LJavaFiles) = 0 then
  begin
    if Assigned(fOnProcessLog) then
      fOnProcessLog('No Java files found for compilation.');
    Exit;
  end;

  // Step 3: DoubleQuotting all Rrquired *.java file Paths from LJavaFiles Array
  for var LFilePath in LJavaFiles do
  begin
    // Join the Java files into a string for the command
    LJavaFilePaths := LJavaFilePaths + AnsiQuotedStr(LFilePath, '"') + ' ';

  if Assigned(fOnProcessLog) then
    fOnProcessLog(LJavaFilePaths);
  end;

  if not fOnlyJarLib then begin
    // Step 4: Load all Rrquired *.jar files from AndroidJarLibFiles directory
    LAndroidJarLibFiles := LoadFilesFromDir(fAndroidJarLibFilesDir, '*.jar');
    if Length(LAndroidJarLibFiles) = 0 then
    begin
      if Assigned(fOnProcessLog) then
        fOnProcessLog('No Jar Lib files found for compilation.');
      Exit;
    end;
    // Step 5: DoubleQuotting all Rrquired *.jar file Paths from LJavaFiles Array
    for var LFilePath in LAndroidJarLibFiles do
    begin
      // Join the Java files into a string for the command
      LAndroidJarLibFilePaths := LAndroidJarLibFilePaths + AnsiQuotedStr(LFilePath, '"') + ' ';

    if Assigned(fOnProcessLog) then
      fOnProcessLog(LAndroidJarLibFilePaths);
    end;
  end else LAndroidJarLibFilePaths := AnsiQuotedStr(fAndroidJarLibFilesDir, '"');

  // Step 6: Compile Java files to get Classes..
  fDosCMD.CommandLine := Format('javac -d %s -cp %s %s', [AnsiQuotedStr(LOutputDir, '"'),
                                                          LAndroidJarLibFilePaths,
                                                          LJavaFilePaths]);
  if Assigned(fOnProcessLog) then
    fOnProcessLog(fDosCMD.CommandLine);

  fDosCMD.CurrentDir := fJavaFilesDir;
  fDosCMD.OnNewLine := OnDosCMD_NewLine;
  fDosCMD.OnTerminated := OnDosCMDTerminate; // After Terminate process the jar create process begin..
  fResult := 'Compiling Java files...';
  fDosCMD.Execute;

  Result := True;
end;

end.
