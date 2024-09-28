unit GX_DummyWizard;

{$I GX_CondDefine.inc}

interface

uses
  ToolsAPI;

type
  ///<summary>
  /// This dummy wizard is registerd with the IDE if another instance of GExperts has already
  /// been installed. (See GX_LibrarySource.InitWizard) </summary>
  TDummyWizard = class(TNotifierObject, IOTAWizard)
  protected
    // IOTAWizard
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;
    procedure Execute;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  GX_About;

{ TDummyWizard }

function TDummyWizard.GetIDString: string;
begin
{$ifdef GExpertsBPL}
  Result := 'GExpertsBPL.DummyWizard'; // Do not localize.
{$else GExpertsBPL}
  Result := 'GExperts.DummyWizard'; // Do not localize.
{$endif GExpertsBPL}
end;

function TDummyWizard.GetName: string;
begin
  Result := GetIDString;
end;

function TDummyWizard.GetState: TWizardState;
begin
  Result := [];
end;

constructor TDummyWizard.Create;
begin
  inherited Create;
  gblAboutFormClass.AddToAboutDialog;
end;

destructor TDummyWizard.Destroy;
begin
  gblAboutFormClass.RemoveFromAboutDialog;
  inherited;
end;

procedure TDummyWizard.Execute;
begin
  // do nothing
end;

end.
