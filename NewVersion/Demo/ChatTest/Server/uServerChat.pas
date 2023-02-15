unit uServerChat;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics,   Vcl.Controls,    Vcl.Forms,       Vcl.Dialogs,     Vcl.StdCtrls,
  uAegysBase,     IdContext;

type
  TForm3 = class(TForm)
    Label2: TLabel;
    ePort: TEdit;
    bConnect: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure bConnectClick(Sender: TObject);
  private
    { Private declarations }
   vAegysService : TAegysService;
   Procedure Connect;
  public
    { Public declarations }
   Function  GeneratePassword(LastPassword   : String) : String;
   Procedure GetNewID        (ContextList    : TSessionList;
                              Value          : String;
                              Var ClientID,
                              ClientPassword : String;
                              Var Accept    : Boolean);
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

Function GenerateIDUnique(mac, hd : String) : String;
 Function LetToNum(Str : String) : String;
 Const
  Cad1: String = 'ABCDEF';
  Cad2: String = '123456';
 var
  x, y: integer;
 Begin
  Result := '';
  For y := 1 To Length(Str) Do
   Begin
    x := Pos(Str[y], Cad1);
    If x > 0 Then
     Result := Result + Copy(Cad2,x,1)
    Else
     Result := Result + Copy(str,y,1);
   End;
 End;
 Function RemoveChrInvalidos(Str : String) : String;
 Var
  x   : Integer;
  ret : String;
 Begin
  ret := '';
  For x := 1 To Length(Str) Do
   Begin
    If (Str[x] <> '-') And
       (Str[x] <> '.') And
       (Str[x] <> ',') And
       (Str[x] <> '/') Then
     ret := ret + Str[x];
   End;
  RemoveChrInvalidos := Trim(TrimRight(ret));
 End;
Var
 AMac,
 AHD, S,
 sID1,
 sID2,
 sID3 : String;
Begin
 AMac := RemoveChrInvalidos(mac);
 AHD  := RemoveChrInvalidos(hd);
 S    := LetToNum(AMac + AHD); // Trocando as letras pelos numeros;
 sID1 := Copy(s,StrToIntDef(Copy(s,1,1),1),2);
 sID2 := Copy(s,StrToIntDef(Copy(s,10,1),2),3);
 sID3 := Copy(s,StrToIntDef(Copy(s,length(s)-3,1),3),3);
 Result := sID1 + '-'+ sID2  +'-'+ sID3;
End;

Function TForm3.GeneratePassword(LastPassword : String) : String;
Begin
 Randomize;
 If (LastPassword <> '') Then
  Result := LastPassword
 Else
  Result := IntToStr(Random(9)) + IntToStr(Random(9)) + IntToStr(Random(9)) + IntToStr(Random(9));
End;

Procedure TForm3.GetNewID(ContextList      : TSessionList;
                          Value            : String;
                          Var ClientID,
                          ClientPassword   : String;
                          Var Accept       : Boolean);
Var
 I             : Integer;
 strMAC,
 strHD, ID,
 vLastPassword : String;
 Exists        : Boolean;
 Procedure ParseSerial(aValue        : String;
                       Var aMAC,
                       aHD,
                       aLastPassword : String);
 Begin
  aLastPassword := '';
  strMAC := Copy(aValue, 1, Pos('|', aValue) -1);
  Delete(aValue, 1, Pos('|', aValue));
  If Pos('|', aValue) > 0 Then
   Begin
    aHD  := Copy(aValue, 1, Pos('|', aValue) -1);
    Delete(aValue, 1, Pos('|', aValue));
    aLastPassword := aValue;
   End
  Else
   aHD   := aValue;
 End;
Begin
 Randomize;
 ParseSerial(Value, strMAC, strHD, vLastPassword);
 ID := GenerateIDUnique(strMAC, strHD);
 Exists := False;
 Try
  For I := ContextList.Count - 1 DownTo 0 do
   Begin
    Exists := (ContextList.Items[i].SessionID = ID);
    If Exists Then
     Break;
   End;
 Finally
  ClientID       := ID;
  ClientPassword := GeneratePassword(vLastPassword);
 End;
End;

procedure TForm3.bConnectClick(Sender: TObject);
begin
 Connect;
end;

Procedure TForm3.Connect;
Begin
 vAegysService.ServicePort := StrToInt(ePort.Text);
 Try
  vAegysService.Active     := Not vAegysService.Active;
 Except

 End;
 If vAegysService.Active Then
  bConnect.Caption := 'Disconnect'
 Else
  bConnect.Caption := 'Connect';
End;

procedure TForm3.FormCreate(Sender: TObject);
begin
 vAegysService := TAegysService.Create(Self);
 vAegysService.OnGetClientDetails := GetNewID;
end;

procedure TForm3.FormDestroy(Sender: TObject);
begin
 FreeAndNil(vAegysService);
 Release;
end;

end.
