program JarBuilder;

uses
  Vcl.Forms,
  API.JarBuilder in 'API\API.JarBuilder.pas',
  Main.View in 'Main.View.pas' {MainView};

{$R *.res}

var
  MainView: TMainView;
begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainView, MainView);
  Application.Run;
end.
