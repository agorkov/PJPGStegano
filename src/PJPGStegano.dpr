program PJPGStegano;

uses
  Forms,
  UFMain in 'UFMain.pas',
  UFMessage in 'UFMessage.pas',
  UDMMain in 'UDMMain.pas',
  UFAbout in 'UFAbout.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Стеганография';
  Application.CreateForm(TFMain, FMain);
  Application.CreateForm(TFMessage, FMessage);
  Application.CreateForm(TDMMain, DMMain);
  Application.CreateForm(TFAbout, FAbout);
  Application.Run;
end.
