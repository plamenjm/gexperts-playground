unit GX_Experts;

{$I GX_CondDefine.inc}

interface

uses
  Classes, Graphics, Forms, ActnList, Menus,
  GX_ConfigurationInfo, GX_BaseExpert;

type
  TGX_Expert = class(TGX_BaseExpert)
  private
    procedure ActionOnUpdate(Sender: TObject);
  protected
    function GetExpertIndex: Integer;
    procedure SetFormIcon(Form: TForm);
    procedure SetActive(New: Boolean); override;
    procedure UpdateAction(Action: TCustomAction); virtual;
    // Defaults to False
    function HasSubmenuItems: Boolean; virtual;
    // you usually don't need to override this
    procedure LoadActiveAndShortCut(Settings: TGExpertsSettings); override;
    // you usually don't need to override this
    procedure SaveActiveAndShortCut(Settings: TGExpertsSettings); override;
  public
    ///<summary>
    /// @returns the category of this expert. It is used to create submenus in the GExperts menu.
    ///          Defaults to an empty string, meaning the expert is listed directly in
    ///          the GExperts menu. </summary>
    class function GetCategory: string; virtual;
    constructor Create; virtual;
    destructor Destroy; override;
    // Information functions that need to be overriden
    // by each expert to provide required registration
    // information.

    // Determine if the expert action is enabled
    function GetActionEnabled: Boolean; virtual;
    // Name to be displayed for the expert in the GExperts
    // *configuration* dialog; this is a different entry than
    // the action caption (GetActionCaption) but by default
    // it calls GetActionCaption and removes any Hotkey characters and '...'
    // This is probably OK for most experts.
    function GetDisplayName: string; override;
    // Defaults to True
    function HasMenuItem: Boolean; virtual;
    // Defaults to False
    function HasDesignerMenuItem: Boolean; virtual;
    procedure DoCreateSubMenuItems(MenuItem: TMenuItem);
    procedure CreateSubMenuItems(MenuItem: TMenuItem); virtual;
//    procedure Execute(Sender: TObject); virtual; // declared in TGX_BaseExpert
    // Do any delayed setup after the IDE is done initializing
    procedure AfterIDEInitialized; virtual;
    // Update the action state
    procedure DoUpdateAction;
    // Calls HasMenuItem
    function CanHaveShortCut: boolean; override;
    // Index of expert; used to determine a "historic"
    // menu item order in the GExperts menu item.
    property ExpertIndex: Integer read GetExpertIndex;
  end;

  TGX_ExpertClass = class of TGX_Expert;

var
  GX_ExpertList: TList = nil;
  ExpertIndexLookup: TStringList = nil;

procedure RegisterGX_Expert(AClass: TGX_ExpertClass);
function GetGX_ExpertClassByIndex(const Index: Integer): TGX_ExpertClass;

implementation

uses
  {$IFOPT D+} GX_DbugIntf, {$ENDIF}
  SysUtils, Dialogs,
  GX_MenuActions,
  GX_OtaUtils, GX_GenericUtils;

{ TGX_Expert }

procedure TGX_Expert.ActionOnUpdate(Sender: TObject);
begin
  DoUpdateAction;
end;

// Note: Don't call LoadSettings in Create.  This is done for you
// when the expert is created.  See TGExperts.InstallAddIn.
constructor TGX_Expert.Create;
begin
  inherited Create;

  // Don't set Active to True.
  // Instead override IsDefaultActive and let LoadSettings do it
end;

procedure TGX_Expert.CreateSubMenuItems(MenuItem: TMenuItem);
begin
  // Override to create any submenu items in the main menu
end;

destructor TGX_Expert.Destroy;
begin
  // Set active to False, this makes it possible to handle all creation and
  // destruction inside SetActive
  Active := False;

  inherited Destroy;
end;

class function TGX_Expert.GetCategory: string;
begin
  Result := '';
end;

function TGX_Expert.GetExpertIndex: Integer;
var
  Index: Integer;
begin
  Result := MaxInt - 10000;
  if not ExpertIndexLookup.Find(ClassName, Index) then
    {$IFOPT D+} SendDebugWarning(ClassName + ': not found in ExpertIndexLookup') {$ENDIF D+}
  else
    Result := GXNativeInt(ExpertIndexLookup.Objects[Index]);
end;

function TGX_Expert.HasMenuItem: Boolean;
begin
  Result := True;
end;

function TGX_Expert.HasSubmenuItems: Boolean;
begin
  Result := False;
end;

const
  ShortCutIdent = 'ExpertShortcuts'; // Do not localize.
  EnabledIdent = 'EnabledExperts'; // Do not localize.

procedure TGX_Expert.LoadActiveAndShortCut(Settings: TGExpertsSettings); 
begin
  // Do not put these two Settings.xxx lines in InternalLoadSettings,
  // since a descendant might forget to call 'inherited'
  ShortCut := Settings.ReadInteger(ShortCutIdent, GetName, ShortCut);
  Active := Settings.ReadBool(EnabledIdent, GetName, IsDefaultActive);
end;

procedure TGX_Expert.SaveActiveAndShortCut(Settings: TGExpertsSettings);
begin
  // Do not put these two Settings.xxx lines in InternalSaveSettings,
  // since a descendant might forget to call 'inherited'
  Settings.WriteBool(EnabledIdent, GetName, Active);
  Settings.WriteInteger(ShortCutIdent, GetName, ShortCut);
end;

procedure TGX_Expert.SetActive(New: Boolean);
begin
  if New = FActive then
    Exit;

  if HasMenuItem or HasDesignerMenuItem then
  begin
    if New and not IsStandAlone then
      FActionInt := GXMenuActionManager.RequestMenuExpertAction(Self)
    else
      FActionInt := nil;
  end;

  if Assigned(FActionInt) then
    FActionInt.OnUpdate := ActionOnUpdate;

  inherited;
end;

{ Globals }

function GetGX_ExpertClass(const ClassName: string): TGX_ExpertClass;
var
  i: Integer;
begin
  Assert(GX_ExpertList <> nil, 'Uses clauses are out of order.  GX_ExpertList is nil!');

  for i := 0 to GX_ExpertList.Count - 1 do
  begin
    Result := GX_ExpertList[i];
    if Result.ClassNameIs(ClassName) then Exit;
  end;
  Result := nil;
end;

function GetGX_ExpertClassByIndex(const Index: Integer): TGX_ExpertClass;
begin
  Result := nil;
  if (Index >= 0) and (Index <= GX_ExpertList.Count - 1) then
    Result := GX_ExpertList[Index];
end;

procedure RegisterGX_Expert(AClass: TGX_ExpertClass);
var
  ExpertClassName: string;
begin
  ExpertClassName := AClass.ClassName;
  {$IFOPT D+} SendDebug('Registering expert: ' +  ExpertClassName); {$ENDIF D+}
  if GetGX_ExpertClass(ExpertClassName) <> nil then
  begin
    Assert(False, 'Duplicate call to RegisterGX_Expert for ' + ExpertClassName);
    Exit;
  end;
  GX_ExpertList.Add(AClass);
end;

procedure InitExpertIndexLookup;
// Current order (2024-10-02, probably based on units initialization order):
// Expert Manager...
// Set Tab Order...
// Project Option Sets
// Open File
// PE Information
// Uses Clause Manager
// Keyboard Macro Library
// Keyboard Shortcuts
// IDE Menu Shortcuts
// Hide/Show Non-Visual
// Instant Grep
// Go to
// Form Hotkeys
// Focus Code Editor
// Find Component Reference
// Favorite Files
// Editor Experts
// Components to Code
// Component Grid...
// Clipboard History
// Clean Directories...
// Class Browser
// Editor Bookmarks
// ASCII Chart
// Add Dock Window
// Project Dependencies
// Grep
// Code Librarian
const
  OldExpertOrder: array [0..13] of string = (
//  'TProcedureExpert',         - old^2, class not found
  'TExpertManagerExpert',
//  'TGrepDlgExpert',           - old^2, class not found
  'TGrepExpert',
//  'TMsgExpExpert',            - old^2, class not found
//  'TBackupExpert',            - old^2, class not found
  'TTabExpert',
//  'TCleanExpert',             - old^2, class not found
//  'TClipExpert',              - old^2, class not found
//  'TFilesExpert',             - old^2, class not found
//  'TClassExpert',             - old^2, class not found
  'TSourceExportExpert',
//  'TCodeLibExpert',           - old^2, class not found
//  'TASCIIExpert',             - old^2, class not found
//  'TPEExpert',                - old^2, class not found
  'TReplaceCompExpert',
//  'TGridExpert',              - old^2, class not found
//  'TShortCutExpert',          - old^2, class not found
//  'TDependExpert',            - old^2, class not found
//  'TLayoutExpert',            - old^2, class not found
  'TToDoExpert',
  'TCodeProofreaderExpert',
  'TProjOptionSetsExpert',
//  'TCompsToCodeExpert',       - old^2, class not found
//  'TCompRenameExpert',        - old^2, class not found
  'TCopyComponentNamesExpert',
//  'TGxMenusForEditorExperts', - old^2, class not found
//  'TMacroLibExpert',          - old^2, class not found
  'TOpenFileExpert',
//  'TFindCompRefWizard'        - old^2, class not found
  'TKeyboardShortcutsExpert',
  'TIDEMenuShortCutsExpert',
  'TFocusCodeEditorExpert',
  'TProjectDependenciesExpert');
var
  i: Integer;
begin
  Assert(not Assigned(ExpertIndexLookup));
  ExpertIndexLookup := TStringList.Create;
  for i := Low(OldExpertOrder) to High(OldExpertOrder) do
    ExpertIndexLookup.AddObject(OldExpertOrder[i], TObject(i));
  ExpertIndexLookup.Sorted := True;
end;

procedure TGX_Expert.SetFormIcon(Form: TForm);
var
  bmp: TBitmap;
begin
  Assert(Assigned(Form));
  bmp := GetBitmap;
  if Assigned(bmp) then
    ConvertBitmapToIcon(bmp, Form.Icon);
end;

function TGX_Expert.HasDesignerMenuItem: Boolean;
begin
  Result := False;
end;

function TGX_Expert.GetActionEnabled: Boolean;
begin
  Result := FActionInt.GetEnabled;
end;

procedure TGX_Expert.DoCreateSubMenuItems(MenuItem: TMenuItem);
begin
  if HasSubMenuItems then
    if Assigned(MenuItem) then
      CreateSubMenuItems(MenuItem);
end;

procedure TGX_Expert.DoUpdateAction;
begin
  UpdateAction(FActionInt.GetAction);
end;

function TGX_Expert.GetDisplayName: string;
begin
  Result := StringReplace(GetActionCaption, '...', '', [rfReplaceAll]);
  Result := StripHotkey(Result);
end;

function TGX_Expert.CanHaveShortCut: boolean;
begin
  Result := HasMenuItem;
end;

{$IFDEF GX_BCB}
class function TGX_Expert.GetName: string;
begin
  Result := ClassName;
end;
{$ENDIF}

procedure TGX_Expert.UpdateAction(Action: TCustomAction);
begin
  // Update Enabled, Visible, Caption, etc.
end;

procedure TGX_Expert.AfterIDEInitialized;
begin
  // Do any delayed setup here that needs some later-created IDE items
end;

initialization
  GX_ExpertList := TList.Create;
  InitExpertIndexLookup;

finalization
  FreeAndNil(GX_ExpertList);
  FreeAndNil(ExpertIndexLookup);

end.

