unit UFMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ComCtrls, ExtCtrls;

type
  TFMain = class(TForm)
    Image1: TImage;
    PageControl1: TPageControl;
    TSWrite: TTabSheet;
    Memo1: TMemo;
    ListBox1: TListBox;
    BSelectFiles: TButton;
    BWrite: TButton;
    Label1: TLabel;
    TSRead: TTabSheet;
    ListBox2: TListBox;
    BReadMsg: TButton;
    BGetFile: TButton;
    BUpdate: TButton;
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
    procedure Image1Click(Sender: TObject);
    procedure BWriteClick(Sender: TObject);
    procedure BSelectFilesClick(Sender: TObject);
    procedure BReadMsgClick(Sender: TObject);
    procedure BGetFileClick(Sender: TObject);
    procedure BUpdateClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FMain: TFMain;

implementation

{$R *.dfm}

uses
  UDMMain, UJPGFunctions, UFMessage, JPEG;

var
  FileName: string;
  { OffBits: int64;
    Count: byte; }

procedure TFMain.BGetFileClick(Sender: TObject);
begin
  if ListBox2.ItemIndex <> -1 then
  begin
    UJPGFunctions.LoadFile(FileName, ExtractFileDir(Application.ExeName) + '\', ListBox2.ItemIndex + 1);
    ShowMessage('Готово');
  end
  else
    ShowMessage('Выберите файл');
end;

procedure TFMain.BReadMsgClick(Sender: TObject);
begin
  UFMessage.FMessage.Memo1.Lines.Clear;
  UFMessage.FMessage.Memo1.Text := UJPGFunctions.GetMsg(FileName, ListBox2.ItemIndex + 1);
  UFMessage.FMessage.ShowModal;
end;

procedure TFMain.BSelectFilesClick(Sender: TObject);
var
  i: word;
begin
  if UDMMain.DMMain.OD1.Execute then
  begin
    ListBox1.Items.Clear;
    for i := 0 to UDMMain.DMMain.OD1.Files.Count - 1 do
      ListBox1.Items.Add(UDMMain.DMMain.OD1.Files[i]);
  end;
end;

procedure TFMain.BUpdateClick(Sender: TObject);
var
  i: byte;
begin
  ListBox2.Items.Clear;
  for i := 1 to UJPGFunctions.GetMsgCount(FileName) do
  begin
    case UJPGFunctions.GetMsgType(FileName, i) of
    0: ListBox2.Items.Add(inttostr(i) + ' - текстовое сообщение');
    1: ListBox2.Items.Add(inttostr(i) + ' -  ' + UJPGFunctions.GetFileName(FileName, i));
    end; { case }
  end;
end;

procedure TFMain.BWriteClick(Sender: TObject);
var
  i: word;
begin
  if FileName = '' then
    Image1Click(Sender);
  if Memo1.Text <> '' then
    UJPGFunctions.WriteMsg(FileName, Memo1.Text);
  Memo1.Lines.Clear;
  if ListBox1.Items.Count > 0 then
    for i := 0 to ListBox1.Items.Count - 1 do
      UJPGFunctions.WriteFile(FileName, ListBox1.Items[i]);
  ListBox1.Items.Clear;
end;

procedure TFMain.FormActivate(Sender: TObject);
begin
  Image1.Canvas.Rectangle(0, 0, Image1.Width, Image1.Height);
end;

procedure TFMain.FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
begin
  Resize := false;
end;

procedure TFMain.Image1Click(Sender: TObject);
var
  i: byte;
begin
  if UDMMain.DMMain.OPD1.Execute then
  begin
    FileName := UDMMain.DMMain.OPD1.FileName;
    Image1.Picture.LoadFromFile(FileName);
    ListBox2.Items.Clear;
    for i := 1 to UJPGFunctions.GetMsgCount(FileName) do
    begin
      case UJPGFunctions.GetMsgType(FileName, i) of
      0: ListBox2.Items.Add(inttostr(i) + ' - текстовое сообщение');
      1: ListBox2.Items.Add(inttostr(i) + ' -  ' + UJPGFunctions.GetFileName(FileName, i));
      end; { case }
    end;
  end
  else
    FileName := '';
end;

end.
