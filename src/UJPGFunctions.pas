unit UJPGFunctions;

interface

function GetMsgCount(FileName: string): byte;
function GetMsgType(FileName: string; MsgNum: byte): byte;
procedure WriteMsg(FileName: string; Msg: string);
procedure WriteFile(FileName: string; File2Name: string);
function GetMsg(FileName: string; MsgNum: byte): string;
function GetFileName(FileName: string; MsgNum: byte): string;
procedure LoadFile(FileName: string; FOut: string; MsgNum: byte);

implementation

uses
  Classes, SysUtils;

///
///  Функция возвращает количество скрытых сообщений.
///
function GetMsgCount(FileName: string): byte;
var
f: TFileStream;
i: byte;
tmp: byte;
str: string;
OffBits: int64;
count: byte;
begin
  str:=''; count:=0;
  try
    f:=TFileStream.Create(FileName,fmOpenRead);
    f.Seek(f.Size-sizeof(OffBits)-1,soBeginning);
    f.ReadBuffer(OffBits,sizeof(OffBits));
    f.Seek(OffBits,soBeginning);

    for i:=1 to length('StartSecretSection') do
    begin
      f.Read(tmp,1);
      str:=str+char(tmp);
    end;
    if str='StartSecretSection' then
    begin
      f.Seek(f.Size-1,soBeginning);
      f.Read(count,1);
    end
    else
      count:=0;
  finally
    f.Free;
    Result:=count;
  end;
end;

///
///  Функция возвращает тип сообщения.
///  0 - Текстовая вставка
///  1 - Файл.
///
function GetMsgType(FileName: string; MsgNum: byte): byte;
var
f: TFileStream;
OffBits, MsgSize: int64;
count: byte;
i,tmp: byte;
str: string;
MsgType: byte;
begin
  str:=''; MsgType:=255;
  try
    f:=TFileStream.Create(FileName,fmOpenRead);
    f.Seek(f.Size-sizeof(OffBits)-1,soBeginning);
    f.ReadBuffer(OffBits,sizeof(OffBits));
    f.Read(count,1);
    f.Seek(OffBits,soBeginning);
    f.Seek(18,soCurrent);

    for i:=1 to MsgNum-1 do
    begin
      f.Seek(3,soCurrent);
      f.ReadBuffer(MsgSize,sizeof(MsgSize));
      f.Seek(MsgSize,soCurrent);
    end;

    for i:=1 to 3 do
    begin
      f.Read(tmp,1);
      str:=str+char(tmp);
    end;

    if str='Msg' then
      MsgType:=0;
    if str='Fil' then
      MsgType:=1;

  finally
    f.Free;
    result:=MsgType;
  end;
end;

///
///  Записываем текстовое сообщение.
///
procedure WriteMsg(FileName: string; Msg: string);
var
f: TFileStream;
count: byte;
OffBits, MsgSize, Size: int64;
str: string;
i: byte;
j: int64;
begin
   MsgSize:=length(Msg);
  if GetMsgCount(FileName)=0 then
    try
      f:=TFileStream.Create(FileName,fmOpenReadWrite);
      f.Seek(f.Size,soBeginning);
      OffBits:=f.Size; count:=0;
      str:='StartSecretSection';
      for i:=1 to length(str) do
        f.Write(str[i],1);

      str:='Msg';
      for i:=1 to length(str) do
        f.Write(str[i],1);
      f.WriteBuffer(MsgSize,sizeof(MsgSize));

      j:=0;
      while j<MsgSize do
      begin
        j:=j+1;
        f.Write(Msg[j],1);
      end;

      f.WriteBuffer(OffBits,sizeof(OffBits));
      count:=1;
      f.Write(count,1);
    finally
      f.Free;
    end
  else
    try
      f:=TFileStream.Create(FileName,fmOpenReadWrite);
      f.Seek(f.Size-sizeof(OffBits)-1,soBeginning);
      f.ReadBuffer(OffBits,sizeof(OffBits));
      f.Read(count,1);
      f.Seek(OffBits,soBeginning);
      f.Seek(18,soCurrent);// Пропускаем слова StartSecretSection
      for i:=1 to count do
      begin
        f.Seek(3,soCurrent);
        f.ReadBuffer(Size,sizeof(Size));
        f.Seek(Size,soCurrent);
      end;

      str:='Msg';
      for i:=1 to length(str) do
        f.Write(str[i],1);

      f.WriteBuffer(MsgSize,sizeof(MsgSize));

      j:=0;
      while j<MsgSize do
      begin
        j:=j+1;
        f.Write(Msg[j],1);
      end;
      
      f.WriteBuffer(OffBits,sizeof(OffBits));
      count:=count+1;
      f.Write(count,1);
    finally
      f.Free;
    end;
end;

///
///  Записываем в картинку файл.
///
procedure WriteFile(FileName: string; File2Name: string);
var
f1,f2: TFileStream;
OffBits: int64;
count: byte;
i: word;
str: string;
FileSize: int64;
FileNameSize: int64;
Size: int64;
begin

  if GetMsgCount(FileName)=0 then
    try
      f1:=TFileStream.Create(FileName,fmOpenReadWrite);
      f1.Seek(f1.Size,soBeginning);
      OffBits:=f1.Size; count:=0;
      str:='StartSecretSection';
      for i:=1 to length(str) do
        f1.Write(str[i],1);

      str:='Fil';
      for i:=1 to length(str) do
        f1.Write(str[i],1);


      f2:=TFileStream.Create(File2Name,fmOpenRead);
      File2Name:=ExtractFileName(File2Name);
      FileNameSize:=length(File2Name);
      FileSize:=f2.Size+sizeof(FileNameSize)+FileNameSize;
      f1.WriteBuffer(FileSize,sizeof(FileSize));
      f1.WriteBuffer(FileNameSize,sizeof(FileNameSize));
      for i:=1 to FileNameSize do
        f1.Write(File2Name[i],1);

      f1.CopyFrom(f2,f2.Size);

      f1.WriteBuffer(OffBits,sizeof(OffBits));
      count:=1;
      f1.Write(count,1);
    finally
      f1.Free;
      f2.Free;
    end
  else
  begin
     try
      f1:=TFileStream.Create(FileName,fmOpenReadWrite);
      f1.Seek(f1.Size-sizeof(OffBits)-1,soBeginning);
      f1.ReadBuffer(OffBits,sizeof(OffBits));
      f1.Read(count,1);
      f1.Seek(OffBits,soBeginning);
      f1.Seek(18,soCurrent);// Пропускаем слова StartSecretSection
      for i:=1 to count do
      begin
        f1.Seek(3,soCurrent);
        f1.ReadBuffer(Size,sizeof(Size));
        f1.Seek(Size,soCurrent);
      end;

      str:='Fil';
      for i:=1 to length(str) do
        f1.Write(str[i],1);

      f2:=TFileStream.Create(File2Name,fmOpenRead);
      File2Name:=ExtractFileName(File2Name);
      FileNameSize:=length(File2Name);
      FileSize:=f2.Size+sizeof(FileNameSize)+FileNameSize;
      f1.WriteBuffer(FileSize,sizeof(FileSize));
      f1.WriteBuffer(FileNameSize,sizeof(FileNameSize));
      for i:=1 to FileNameSize do
        f1.Write(File2Name[i],1);

      f1.CopyFrom(f2,f2.Size);

      f1.WriteBuffer(OffBits,sizeof(OffBits));
      count:=count+1;
      f1.Write(count,1);
    finally
      f1.Free;
      f2.Free;
    end
  end;

end;

///
///  Считываем сообщение.
///
function GetMsg(FileName: string; MsgNum: byte): string;
var
str: string;
f: TFileStream;
OffBits, MsgSize, MsgCount: int64;
count: byte;
i: byte;
tmp: byte;
begin
  str:='';
  try
    f:=TFileStream.Create(FileName,fmOpenRead);
    f.Seek(f.Size-sizeof(OffBits)-1,soBeginning);
    f.ReadBuffer(OffBits,sizeof(OffBits));
    f.Read(count,1);
    f.Seek(OffBits,soBeginning);
    f.Seek(18,soCurrent);

    for i:=1 to MsgNum-1 do
    begin
      f.Seek(3,soCurrent);
      f.ReadBuffer(MsgSize,sizeof(MsgSize));
      f.Seek(MsgSize,soCurrent);
    end;

    for i:=1 to 3 do
    begin
      f.Read(tmp,1);
      str:=str+char(tmp);
    end;

    if str<>'Msg' then
      str:='Под индексом '+inttostr(MsgNum)+' хранится не сообщение'
    else
    begin
      f.ReadBuffer(MsgSize,sizeof(MsgSize));
      str:='';
      MsgCount:=0;
      while MsgCount<MsgSize do
      begin
        MsgCount:=MsgCount+1;
        f.Read(tmp,1);
        str:=str+char(tmp);
      end;
    end;

  finally
    f.Free;
    result:=str;
  end;
end;

///
///  Получеам имя файла.
///
function GetFileName(FileName: string; MsgNum: byte): string;
var
str: string;
f: TFileStream;
OffBits, MsgSize, MsgCount, FileNameSize: int64;
count: byte;
i: byte;
tmp: byte;
begin
  str:='';
  try
    f:=TFileStream.Create(FileName,fmOpenRead);
    f.Seek(f.Size-sizeof(OffBits)-1,soBeginning);
    f.ReadBuffer(OffBits,sizeof(OffBits));
    f.Read(count,1);
    f.Seek(OffBits,soBeginning);
    f.Seek(18,soCurrent);

    for i:=1 to MsgNum-1 do
    begin
      f.Seek(3,soCurrent);
      f.ReadBuffer(MsgSize,sizeof(MsgSize));
      f.Seek(MsgSize,soCurrent);
    end;

    for i:=1 to 3 do
    begin
      f.Read(tmp,1);
      str:=str+char(tmp);
    end;

    if str='Fil' then
    begin
      f.ReadBuffer(MsgSize,sizeof(MsgSize));
      f.ReadBuffer(FileNameSize,sizeof(FileNameSize));
      str:='';
      MsgCount:=0;
      while MsgCount<FileNameSize do
      begin
        MsgCount:=MsgCount+1;
        f.Read(tmp,1);
        str:=str+char(tmp);
      end;
    end;

  finally
    f.Free;
    result:=str;
  end;
end;

///
///  Выгружаем файл.
///
procedure LoadFile(FileName: string; FOut: string; MsgNum: byte);
var
str: string;
f,f2: TFileStream;
OffBits, MsgSize, MsgCount, FileNameSize, j: int64;
count: byte;
i: byte;
tmp: byte;
begin
  str:='';
  try
    f:=TFileStream.Create(FileName,fmOpenRead);
    f.Seek(f.Size-sizeof(OffBits)-1,soBeginning);
    f.ReadBuffer(OffBits,sizeof(OffBits));
    f.Read(count,1);
    f.Seek(OffBits,soBeginning);
    f.Seek(18,soCurrent);

    for i:=1 to MsgNum-1 do
    begin
      f.Seek(3,soCurrent);
      f.ReadBuffer(MsgSize,sizeof(MsgSize));
      f.Seek(MsgSize,soCurrent);
    end;

    for i:=1 to 3 do
    begin
      f.Read(tmp,1);
      str:=str+char(tmp);
    end;

    if str='Fil' then
    begin
      f.ReadBuffer(MsgSize,sizeof(MsgSize));
      f.ReadBuffer(FileNameSize,sizeof(FileNameSize));
      str:='';
      MsgCount:=0;
      while MsgCount<FileNameSize do
      begin
        MsgCount:=MsgCount+1;
        f.Read(tmp,1);
        str:=str+char(tmp);
      end;
      FOut:=FOut+str;
      MsgSize:=MsgSize-sizeof(FileNameSize)-FileNameSize;

      try
        f2:=TFileStream.Create(FOut,fmCreate);
        MsgCount:=0;
        f2.CopyFrom(f,MsgSize);
      finally
        f2.Free;
      end;
    end;
  finally
    f.Free;
  end;
end;

end.
