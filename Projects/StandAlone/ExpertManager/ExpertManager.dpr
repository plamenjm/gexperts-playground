program ExpertManager;

uses
  Windows,
  SysUtils,
  GX_VerDepConst in '..\..\..\Source\Framework\GX_VerDepConst.pas',
  GExpertsDllSelection in 'GExpertsDllSelection.pas' {frGEXpertsDllSelection};

{$R *_icon.res}

begin
  TfrGEXpertsDllSelection.Execute;
end.
