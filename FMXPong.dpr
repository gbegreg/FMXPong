program FMXPong;

uses
  System.StartUpCopy,
  FMX.Forms,
  principale in 'principale.pas' {fPrincipale};

{$R *.res}

begin
  // en cas de mauvais rendu sous Windows, décommentez le ligne suivante
  // fmx.types.GlobalUseDXSoftware := True;
  Application.Initialize;
  Application.FormFactor.Orientations := [TFormOrientation.Portrait];
  Application.CreateForm(TfPrincipale, fPrincipale);
  Application.Run;
end.
