unit UDMMain;

interface

uses
  SysUtils, Classes, Dialogs, ExtDlgs, Menus;

type
  TDMMain = class(TDataModule)
    OPD1: TOpenPictureDialog;
    OD1: TOpenDialog;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    procedure N4Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DMMain: TDMMain;

implementation

{$R *.dfm}
uses
  Forms, UFMain, UFAbout;

procedure TDMMain.N2Click(Sender: TObject);
begin
  UFMain.FMain.Image1Click(Sender);
end;

procedure TDMMain.N4Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TDMMain.N6Click(Sender: TObject);
begin
  UFAbout.FAbout.ShowModal;
end;

end.
