unit uFormRemotoServer;

{
 Projeto Aegys.

  Criado por Gilberto Rocha da Silva em 05/04/2017 baseado no projeto Allakore, tem por objetivo promover acesso remoto e outros
 de forma gratuita a todos que necessitarem, hoje mantido por uma bela comunidade listando aqui nossos colaboradores de grande estima.

  Gilberto Rocha da Silva(XyberX) (Creator of Aegys Project/Main Desenveloper/Admin).
  Wendel Rodrigues Fassarella(wendelfassarella) (Creator of Aegys FMX/CORE Desenveloper).
  Rai Duarte Jales(Ra� Duarte) (Aegys Server Desenveloper).
  Roniery Santos Cardoso (Aegys Desenveloper).
  Alexandre Carlos Silva Abade (Aegys Desenveloper).
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs, Vcl.ExtCtrls, uDMServer;

type
  TFormRemotoServer = class(TService)
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceAfterInstall(Sender: TService);
    procedure ServiceBeforeInstall(Sender: TService);
    procedure ServiceBeforeUninstall(Sender: TService);
    procedure ServiceCreate(Sender: TObject);
  private
    procedure GetServiceName;
    procedure GetServiceDisplayName;
  public
    function GetServiceController: TServiceController; override;
  end;

var
  FormRemotoServer: TFormRemotoServer;

implementation

{$R *.dfm}

// instalar : MyService.Exe /install /name "test1" /display "test instance1"
// desinstalar : MyService.Exe /uninstall /name "test1"

uses uCtrl_ThreadsService, System.Win.Registry;

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  FormRemotoServer.Controller(CtrlCode);
end;

function TFormRemotoServer.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TFormRemotoServer.GetServiceDisplayName;
var
  xServiceDisplayName: string;
begin
  if not FindCmdLineSwitch('display', xServiceDisplayName) then
    raise Exception.Create('Please specify the service displayname with /display switch');
  DisplayName := xServiceDisplayName;
end;

procedure TFormRemotoServer.GetServiceName;
var
  xServiceName: string;
begin
  if not FindCmdLineSwitch('name', xServiceName) then
    raise Exception.Create('Please specify the service name with /name switch');
  Name := xServiceName;
end;

procedure TFormRemotoServer.ServiceAfterInstall(Sender: TService);
var
  Reg: TRegistry;
  xImagePath: string;
begin
  Reg := TRegistry.Create(KEY_READ OR KEY_WRITE);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('SYSTEM\CurrentControlSet\Services\' + Name, False) then
    begin
      // set service description
      Reg.WriteString('Description', 'Multi instance test for service ' + Name);
      // add name parameter to ImagePath value
      xImagePath := ParamStr(0) + ' /name ' + Name;
      Reg.WriteString('ImagePath', xImagePath);
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

procedure TFormRemotoServer.ServiceBeforeInstall(Sender: TService);
begin
  GetServiceName;
  GetServiceDisplayName;
end;

procedure TFormRemotoServer.ServiceBeforeUninstall(Sender: TService);
begin
  GetServiceName;
end;

procedure TFormRemotoServer.ServiceCreate(Sender: TObject);
begin
  if not Application.Installing then
    GetServiceName;
end;

procedure TFormRemotoServer.ServiceStart(Sender: TService; var Started: Boolean);
begin
  if not Assigned(DMServer) then
    DMServer := TDMServer.Create(Self);
end;

procedure TFormRemotoServer.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  if Assigned(DMServer) then
    FreeAndNil(DMServer);
end;

end.
