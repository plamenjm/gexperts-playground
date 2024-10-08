unit GX_EditorExpert;

interface

uses
  Classes, Graphics, Forms,
  GX_ConfigurationInfo, GX_BaseExpert;

type
  TEditorExpert = class(TGX_BaseExpert)
  protected
    // you usually don't need to override this
    procedure LoadActiveAndShortCut(Settings: TGExpertsSettings); override;
    // you usually don't need to override this
    procedure SaveActiveAndShortCut(Settings: TGExpertsSettings); override;
    procedure ActionOnUpdate(Sender: TObject);
    procedure SetFormIcon(Form: TForm);
  public
    constructor Create; virtual;
    destructor Destroy; override;
    // returns true
    function CanHaveShortCut: boolean; override;
    procedure DoExecute(Sender: TObject);
    // you usually don't need to override this
    class function GetOptionsBaseRegistryKey: string; override;
  end;

  TEditorExpertClass = class of TEditorExpert;

function EditorExpertClassList: TList;

procedure RegisterEditorExpert(AClass: TEditorExpertClass);
function GetEditorExpertClassByIndex(const Index: Integer): TEditorExpertClass;

implementation

uses
  {$IFOPT D+} GX_DbugIntf, {$ENDIF}
  SysUtils, Dialogs, ActnList, ToolsAPI,
  GX_ActionBroker, GX_OtaUtils, GX_GenericUtils, GX_Actions;

{ Global utility functions }

function GetExpertClass(const ClassName: string): TEditorExpertClass;
var
  I: Integer;
begin
  Assert(Length(ClassName) > 0);

  for I := 0 to EditorExpertClassList.Count - 1 do
  begin
    Result := EditorExpertClassList[I];
    if Result.ClassNameIs(ClassName) then
      Exit;
  end;
  Result := nil;
end;

procedure RegisterEditorExpert(AClass: TEditorExpertClass);
var
  ClassName: string;
begin
  Assert(Assigned(AClass));
  ClassName := AClass.ClassName;
  if GetExpertClass(ClassName) <> nil then
  begin
    {raise EFilerError.CreateFmt(SDuplicateClass, [ClassName]);}
    Exit;
  end;
  EditorExpertClassList.Add(AClass);
end;

function GetEditorExpertClassByIndex(const Index: Integer): TEditorExpertClass;
begin
  Assert((Index >= 0) and (Index <= EditorExpertClassList.Count - 1));

  Result := EditorExpertClassList[Index];
end;

{ TEditorExpert }

constructor TEditorExpert.Create;
//const
//  EditorExpertPrefix = 'EditorExpert'; // Do not localize.
begin
  inherited Create;

  Assert(IsValidIdent(GetName),
    Format('%s needs to specify a valid name; currently it is "%s"', [Self.ClassName, GetName]));

  FActionInt := GxActionBroker.RequestAction(GetActionName, GetBitmap);
  FActionInt.OnExecute := Self.DoExecute;
  FActionInt.Caption := GetActionCaption;
  FActionInt.OnUpdate := ActionOnUpdate;

  ShortCut := GetDefaultShortCut;
end;

destructor TEditorExpert.Destroy;
begin
  inherited Destroy;
end;

class function TEditorExpert.GetOptionsBaseRegistryKey: string;
begin
  Result := AddSlash(ConfigInfo.GExpertsIdeRootRegistryKey) + 'EditorExperts'; // Do not localize.
end;

procedure TEditorExpert.LoadActiveAndShortCut(Settings: TGExpertsSettings);
begin
  inherited;
  ShortCut := Settings.ReadInteger(ConfigurationKey, 'ShortCut', ShortCut);
  Active := Settings.ReadBool(ConfigurationKey, 'Active', IsDefaultActive);
end;

procedure TEditorExpert.SaveActiveAndShortCut(Settings: TGExpertsSettings);
begin
  inherited;
  Settings.WriteInteger(ConfigurationKey, 'ShortCut', ShortCut);
  Settings.WriteBool(ConfigurationKey, 'Active', Active);
end;

procedure TEditorExpert.SetFormIcon(Form: TForm);
var
  bmp: TBitmap;
begin
  Assert(Assigned(Form));
  bmp := GetBitmap;
  if Assigned(bmp) then
    ConvertBitmapToIcon(bmp, Form.Icon);
end;

function TEditorExpert.CanHaveShortCut: boolean;
begin
  Result := True;
end;

var
  PrivateEditorExpertClassList: TList;

function EditorExpertClassList: TList;
begin
  Result := PrivateEditorExpertClassList;
end;

procedure TEditorExpert.ActionOnUpdate(Sender: TObject);
var
  SendingAction: TCustomAction;
  Editor: IOTASourceEditor;
begin
  // All editor experts require a current edit view
  SendingAction := Sender as TCustomAction;
  Assert(Assigned(SendingAction));

  SendingAction.Enabled := GxOtaTryGetCurrentEditorAsSourceEditor(Editor);
end;

procedure TEditorExpert.DoExecute(Sender: TObject);
var
  Editor: IOTASourceEditor;
begin
  if not GxOtaTryGetCurrentEditorAsSourceEditor(Editor) then begin
    // since apparently ActionOnUpdate isn't reliably called,
    // we prevent editor actions from being executed here,
    // if the current editor is not a source editor (but e.g. a form editor)
    Exit; //==>
  end;

  try
    Execute(Sender);
  except
    // Trap exceptions because the editor will continue to insert the pressed
    // shortcut character into the editor (in D6 at least)
    on E: Exception do
      ShowError(E.Message);
  end;
end;

initialization
  PrivateEditorExpertClassList := TList.Create;

finalization
  FreeAndNil(PrivateEditorExpertClassList);

end.

