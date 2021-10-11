program DF;

uses
  Forms,
  U_M in 'U_M.pas' {Farticl};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFarticl, Farticl);
  Application.Run;
end.
