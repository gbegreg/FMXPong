program FMXPong;

uses
  System.StartUpCopy,
  FMX.Forms,
  principale in 'principale.pas' {fPrincipale};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfPrincipale, fPrincipale);
  Application.Run;
end.
