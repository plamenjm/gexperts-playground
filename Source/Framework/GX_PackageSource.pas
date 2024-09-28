unit GX_PackageSource;

interface

{$I GX_CondDefine.inc}

procedure Register;
//procedure IDERegister;

implementation

uses
  ToolsAPI, DesignIntf, SysUtils, Forms,
  //{$IFOPT D+} GX_DbugIntf, {$ENDIF}
  GX_GenericUtils, GX_About, GX_GExperts, GX_LibrarySource;

var
  FinalizeWizard: TWizardTerminateProc;
  InitWizardRes: Boolean;

procedure Initialize;
begin
  InitWizardRes := False;
  try
    InitWizardRes := InitWizard(BorlandIDEServices, nil, FinalizeWizard);
  except
    on ex: Exception do SendDebugMsg(ex, 'GX_PackageSource');
  end;
end;

procedure Finalize;
begin
  //if InitWizardRes then
    FinalizeWizard;

  const GExpertsDllMarker2 = Application.FindComponent(cGExpertsDllMarker2);
  if Assigned(GExpertsDllMarker2) then GExpertsDllMarker2.Free;

  FreeAndNil(GExpertsDllMarker);
end;

// Under Delphi 8+ we need to delay register with the IDE so the OTA is ready
//procedure IDERegister;
//begin
//  SendDebugMsg([sdUnit], 'GX_PackageSource.IDERegister');
//  TGExperts.DelayedRegister;
//end;

procedure Register;
begin
  SendDebugMsg([sdUnit], 'GX_PackageSource.Register');
  ForceDemandLoadState(dlDisable);
  //RegisterPackageWizard(TGExperts.Create as IOTAWizard);
  Initialize; // package Register is after units initialization
end;

initialization

finalization
  SendDebugMsg([sdUnit, sdEnd], 'GX_PackageSource');
  Finalize;

end.
