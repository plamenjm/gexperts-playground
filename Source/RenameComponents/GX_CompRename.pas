unit GX_CompRename;

(* Things left to consider:
 *  - Search a new component's ancestors to get an alternate rename rule
 *  - Remove timer hack somehow?
 *  - Allow explicit %d rename rules to apply before the rename dialog shows
 *)

{$I GX_CondDefine.inc}

interface

uses
  Classes, Controls, Forms, StdCtrls, ExtCtrls, ToolsAPI, ComCtrls, Buttons,
  GX_Experts, GX_ConfigurationInfo, GX_EditorChangeServices, Contnrs, Messages,
  Types, GX_BaseForm, u_dzSpeedBitBtn;

type
  TIsValidComponentName = function (const OldName, NewName: WideString; var Reason: WideString): Boolean of object;

  // Simple rename dialog that shows the old and new component name
  TfmCompRename = class(TfmBaseForm)
    lblOldName: TLabel;
    edtOldName: TEdit;
    lblNewName: TLabel;
    edtNewName: TEdit;
    p_Buttons: TPanel;
    btnCancel: TButton;
    btnOK: TButton;
    lblReason: TLabel;
    btnSettings: TButton;
    pc_Additional: TPageControl;
    ts_Align: TTabSheet;
    grp_Margins: TGroupBox;
    ed_MarginTop: TEdit;
    l_MarginTop: TLabel;
    ed_MarginLeft: TEdit;
    l_MarginLeft: TLabel;
    l_MarginRight: TLabel;
    ed_MarginRight: TEdit;
    ed_MarginBottom: TEdit;
    l_MarginBottom: TLabel;
    chk_WithMargins: TCheckBox;
    ts_Anchors: TTabSheet;
    b_AnchorLeft: TBitBtn;
    b_AnchorRight: TBitBtn;
    b_AnchorTop: TBitBtn;
    b_AnchorBottom: TBitBtn;
    b_AlignTop: TBitBtn;
    b_AlignLeft: TBitBtn;
    b_AlignRight: TBitBtn;
    b_AlignClient: TBitBtn;
    b_AlignBottom: TBitBtn;
    b_AlignNone: TBitBtn;
    b_AlignCustom: TBitBtn;
    b_Margins0: TButton;
    b_Margins3: TButton;
    b_Margins6: TButton;
    b_Margins8: TButton;
    procedure edtNewNameChange(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
    procedure pc_AdditionalChange(Sender: TObject);
    procedure b_AlignTopClick(Sender: TObject);
    procedure b_AlignLeftClick(Sender: TObject);
    procedure b_AlignClientClick(Sender: TObject);
    procedure b_AlignRightClick(Sender: TObject);
    procedure b_AlignBottomClick(Sender: TObject);
    procedure b_AlignNoneClick(Sender: TObject);
    procedure b_AlignCustomClick(Sender: TObject);
    procedure b_Margins0Click(Sender: TObject);
    procedure b_Margins3Click(Sender: TObject);
    procedure b_Margins6Click(Sender: TObject);
    procedure b_Margins8Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FIsValidComponentName: TIsValidComponentName;
    FProperties: TObjectList;
    FAnchorButtons: array[TAnchorKind] of TdzSpeedBitBtn;
    FAlignButtons: array[TAlign] of TdzSpeedBitBtn;
    FComponentClassName: WideString;
    procedure InitializeForm;
    function GetNewName: WideString;
    function GetOldName: WideString;
    procedure SetNewName(const Value: WideString);
    procedure SetOldName(const Value: WideString);
    procedure AddComponentProperty(PropertyName: WideString; const Value: WideString);
    function GetComponentProperty(Index: Integer): WideString;
    procedure SetComponent(const _Component: IOTAComponent);
    procedure SetAlign(const _Component: IOTAComponent);
    procedure GetAlign(const _Component: IOTAComponent);
    procedure SetAnchors(const _Component: IOTAComponent);
    procedure GetAnchors(const _Component: IOTAComponent);
    procedure HandleAlignButtons(_Align: TAlign);
    procedure SetMargins(_Value: integer);
    procedure DialogKey(var Msg: TWMKey); message CM_DIALOGKEY;
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;
    property OldName: WideString read GetOldName write SetOldName;
    property NewName: WideString read GetNewName write SetNewName;
    function Execute: TModalResult;
    procedure SetRuleSelection(SelStart, SelEnd: Integer);
    property OnIsValidComponentName: TIsValidComponentName read FIsValidComponentName write FIsValidComponentName;
  end;

implementation

{$R *.dfm}

uses
  SysUtils, Windows, Menus, StrUtils, IniFiles, Graphics, TypInfo,
  u_dzClassUtils, u_dzVclUtils, u_dzStringUtils,
  {$IFOPT D+}GX_DbugIntf, {$ENDIF}
  GX_CompRenameConfig, GX_OtaUtils, GX_GenericUtils, GX_IdeUtils;

type
  TRenameComponentsExpert = class;

  TCompRenameNotifier = class(TInterfacedObject, IGxEditorNotification)
  private
    FChangeServiceNotifierIndex: Integer;
    FClient: TRenameComponentsExpert;
  protected
    // IGxEditorNotification
    procedure NewModuleOpened(const Module: IOTAModule);
    procedure SourceEditorModified(const SourceEditor: IOTASourceEditor);
    procedure FormEditorModified(const FormEditor: IOTAFormEditor);
    procedure ComponentRenamed(const FormEditor: IOTAFormEditor;
      Component: IOTAComponent; const OldName, NewName: string);
    function EditorKeyPressed(const SourceEditor: IOTASourceEditor; CharCode: Word; KeyData: Integer): Boolean;
    function GetIndex: Integer;
  protected
    procedure Attach;
  public
    constructor Create(const Client: TRenameComponentsExpert);
    destructor Destroy; override;

    procedure Detach;
  end;

  TRenameComponentsExpert = class(TGX_Expert)
  private
    FCompRenameNotifier: TCompRenameNotifier;
    FRenameRuleListVcl: TStringList;
    FRenameRuleListFmx: TStringList;
    FShowDialog: Boolean;
    FAutoAddClasses: Boolean;
    FComponentNames: TStringList;
    FFormNames: TStringList;
    FTimer: TTimer;
    FFormEditor: IOTAFormEditor;
    FFormWidth: Integer;
    FFormHeight: Integer;
    function DoRename(const Component: IOTAComponent; UseRules: Boolean): TModalResult;
    procedure HandleOnExport(_Sender: TObject; _RulesListVcl, _RulesListFmx: TStringList);
    procedure HandleOnImport(_Sender: TObject; const _fn: string;
      _RulesListVcl, _RulesListFmx: TStringList);
    function GetActiveRenameRuleList: TStringList;
    class function TryLoadRules(_Settings: IExpertSettings; const _Section: string;
      _TryRoot: Boolean; _RulesList: TStringList): Boolean;
    class procedure SaveRules(_Settings: IExpertSettings; const _Section: string;
      _RulesList: TStringList);
  protected
    procedure AddNewClass(const AClassName: WideString);
    procedure DoOnTimer(Sender: TObject);
    function GetClassRenameRule(const AClassName: WideString): WideString;
    procedure InternalLoadSettings(_Settings: IExpertSettings); override;
    procedure InternalSaveSettings(_Settings: IExpertSettings); override;
    procedure ComponentRenamed(const FormEditor: IOTAFormEditor;
      Component: IOTAComponent; const OldName, NewName: WideString);
    procedure FormEditorModified(const FormEditor: IOTAFormEditor);
    function IsValidComponentName(const OldName, NewName: WideString; var Reason: WideString): Boolean;
    procedure AddNotifier;
    procedure RemoveNotifier;
    function IsDefaultComponentName(Component: IOTAComponent; const NewName: WideString): Boolean;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Execute(Sender: TObject); override;
    procedure Configure(_Owner: TWinControl); overload; override;
    procedure Configure(_Owner: TWinControl; const _Selected: string); reintroduce; overload;
    function GetActionCaption: string; override;
    function GetDefaultShortCut: TShortCut; override;
    class function GetName: string; override;
    function HasConfigOptions: Boolean; override;
    procedure SetActive(New: Boolean); override;
    function IsDefaultActive: Boolean; override;
    function HasDesignerMenuItem: Boolean; override;
  end;

resourcestring
  SPropertyNotFound = 'Property not found';

var
  PrivateCompRenameExpert: TRenameComponentsExpert;

{ TfmCompRename }

function TfmCompRename.Execute: TModalResult;
begin
  ActiveControl := edtNewName;
//  lblReason.Top := btnOK.Top + Round((btnOK.Height / 2) - (lblReason.Height / 2));
  Result := ShowModal;
end;

procedure TfmCompRename.FormShow(Sender: TObject);
begin
  inherited;
  // Adjust some button positons and size after scaling
  // DisableAlign;
  b_AlignRight.Left   := b_AlignTop.Left + b_AlignTop.Width - b_AlignRight.Width;
  b_AlignClient.Left  := b_AlignLeft.Left + b_AlignLeft.Width + 1;
  b_AlignClient.Width := b_AlignRight.Left - b_AlignClient.Left - 2;
  // EnableAlign;
end;

function TfmCompRename.GetNewName: WideString;
begin
  Result := Trim(edtNewName.Text);
end;

function TfmCompRename.GetOldName: WideString;
begin
  Result := Trim(edtOldName.Text);
end;

procedure TfmCompRename.pc_AdditionalChange(Sender: TObject);
begin
  inherited;
  if pc_Additional.ActivePage = ts_Align then
    TWinControl_SetFocus(b_AlignClient)
  else if pc_Additional.ActivePage = ts_Anchors then
    TWinControl_SetFocus(b_AnchorTop);
end;

procedure TfmCompRename.GetAlign(const _Component: IOTAComponent);
var
  BoolValue: LongBool;
  CompMargins: TObject;
  al: TAlign;
  IntValue: Integer;
begin
  if not GxOtaActiveDesignerIsVCL then begin
    // for whatever reason this currently does not work for FMX
    Exit; //==>
  end;

  if not ts_Align.TabVisible then
    Exit; //==>

  al := Low(TAlign);
  while al < High(TAlign) do begin
    if FAlignButtons[al].Down then
      Break;
    Inc(al);
  end;
  IntValue := Ord(al);
  _Component.SetPropByName('Align', IntValue);

  if not grp_Margins.Visible then
    Exit; //==>

  if chk_WithMargins.Visible then begin
    BoolValue := chk_WithMargins.Checked;
    _Component.SetPropByName('AlignWithMargins', BoolValue);
  end;
  if _Component.GetPropTypeByName('Margins') = tkClass then begin
    CompMargins := GetObjectProp((_Component as INTAComponent).GetComponent, 'Margins');
    if TryStrToInt(ed_MarginTop.Text, IntValue) then
      SetOrdProp(CompMargins, 'Top', IntValue);
    if TryStrToInt(ed_MarginLeft.Text, IntValue) then
      SetOrdProp(CompMargins, 'Left', IntValue);
    if TryStrToInt(ed_MarginRight.Text, IntValue) then
      SetOrdProp(CompMargins, 'Right', IntValue);
    if TryStrToInt(ed_MarginBottom.Text, IntValue) then
      SetOrdProp(CompMargins, 'Bottom', IntValue);
  end;
end;

procedure TfmCompRename.SetAlign(const _Component: IOTAComponent);
var
  BoolValue: LongBool;
  CompMargins: TObject;
  IntValue: Integer;
  AlignValue: TAlign;
  al: TAlign;
begin
  if not GxOtaActiveDesignerIsVCL then begin
    ts_Align.TabVisible := False;
    // for whatever reason this currently does not work for FMX
    Exit; //==>
  end;

  // GetPropValueByName expects 4 byte values for enums
  if not _Component.GetPropValueByName('Align', IntValue) then begin
    ts_Align.TabVisible := False;
    Exit; //==>
  end;

  if (IntValue < Ord(Low(TAlign))) or (Ord(High(TAlign)) < IntValue) then begin
    ts_Align.TabVisible := False;
    Exit; //==>
  end;
  AlignValue := TAlign(IntValue);

  for al := Low(TAlign) to High(TAlign) do
    FAlignButtons[al].Down := (al = AlignValue);

  if _Component.GetPropTypeByName('Margins') <> tkClass then begin
    grp_Margins.Visible := False;
    chk_WithMargins.Visible := False;
    Exit; //==>
  end;

  // GetPropValueByName expects 4 byte values for booleans too
  if not _Component.GetPropValueByName('AlignWithMargins', BoolValue) then begin
    chk_WithMargins.Visible := False;
  end;
  chk_WithMargins.Checked := BoolValue;
  CompMargins := GetObjectProp((_Component as INTAComponent).GetComponent, 'Margins');
  IntValue := GetOrdProp(CompMargins, 'Top');
  ed_MarginTop.Text := IntToStr(IntValue);
  IntValue := GetOrdProp(CompMargins, 'Left');
  ed_MarginLeft.Text := IntToStr(IntValue);
  IntValue := GetOrdProp(CompMargins, 'Right');
  ed_MarginRight.Text := IntToStr(IntValue);
  IntValue := GetOrdProp(CompMargins, 'Bottom');
  ed_MarginBottom.Text := IntToStr(IntValue);
end;

procedure TfmCompRename.GetAnchors(const _Component: IOTAComponent);
var
  AnchorValue: TAnchors;
  IntValue: Integer;
  ak: TAnchorKind;
begin
  if ts_Anchors.TabVisible then begin
    AnchorValue := [];
    for ak  := Low(TAnchorKind) to High(TAnchorKind) do begin
      if FAnchorButtons[ak].Down then
        Include(AnchorValue, ak);
    end;
    IntValue := 0;
    Move(AnchorValue, IntValue, SizeOf(AnchorValue));
    _Component.SetPropByName('Anchors', AnchorValue);
  end;
end;

procedure TfmCompRename.SetAnchors(const _Component: IOTAComponent);
var
  AnchorValue: TAnchors;
  IntValue: Integer;
  ak: TAnchorKind;
begin
  if not _Component.GetPropValueByName('Anchors', IntValue) then begin
    ts_Anchors.TabVisible := False;
  end else begin
    Move(IntValue, AnchorValue, SizeOf(AnchorValue));
    for ak := Low(TAnchorKind) to High(TAnchorKind) do
      FAnchorButtons[ak].Down := (ak in AnchorValue);
  end;
end;

procedure TfmCompRename.SetComponent(const _Component: IOTAComponent);
begin
  FComponentClassName := _Component.GetComponentType;
  SetAlign(_Component);
  SetAnchors(_Component);
end;

procedure TfmCompRename.SetNewName(const Value: WideString);
begin
  edtNewName.Text := Value;
  edtNewName.Modified := False;
end;

procedure TfmCompRename.SetOldName(const Value: WideString);
begin
  edtOldName.Text := Value;
end;

procedure TfmCompRename.edtNewNameChange(Sender: TObject);
var
  LOldName: WideString;
  LNewName: WideString;
  Reason: WideString;
begin
  if Assigned(FIsValidComponentName) then
  begin
    LOldName := edtOldName.Text;
    LNewName := edtNewName.Text;
    btnOK.Enabled := FIsValidComponentName(LOldName, LNewName, Reason);
    if btnOK.Enabled then
      lblReason.Visible := False
    else
    begin
      lblReason.Caption := Reason;
      lblReason.Visible := True;
    end;
  end
  else
    btnOK.Enabled := IsValidIdent(edtNewName.Text);
end;

procedure TfmCompRename.SetRuleSelection(SelStart, SelEnd: Integer);
begin
  edtNewName.SelStart := SelStart;
  if SelEnd > SelStart then
    edtNewName.SelLength := SelEnd - SelStart;
end;

procedure TfmCompRename.AddComponentProperty(PropertyName: WideString; const Value: WideString);
var
  Lbl: TLabel;
  Edit: TEdit;
  diff: Integer;
begin
  PropertyName := Trim(PropertyName);
  if PropertyName = '' then
    Exit; //==>

  Lbl := TLabel.Create(Self);
  Lbl.Name := 'lblProperty_' + PropertyName;
  Lbl.Parent := Self;
  Lbl.Top := (FProperties.Count + 1) * (lblNewName.Top - lblOldName.Top) + lblNewName.Top;
  Lbl.Left := lblNewName.Left;
  Lbl.Caption := PropertyName;

  Edit := TEdit.Create(Self);
  Edit.Name := 'edtProperty_' + PropertyName;
  Edit.Parent := Self;
  Edit.Top := (FProperties.Count + 1) * (edtNewName.Top - edtOldName.Top) + edtNewName.Top;
  Edit.Left := edtNewName.Left;
  Edit.Width := edtNewName.Width;
  Edit.Text := Value;
  Edit.TabOrder := FProperties.Count + 1 + edtNewName.TabOrder;
  FProperties.Add(Edit);

  if Edit.Text = SPropertyNotFound then begin
    Edit.ReadOnly := True;
    Edit.Color := clBtnFace;
    Edit.TabStop := False;
    Lbl.Font.Color := clGrayText;
  end;

  diff := edtNewName.Top - edtOldName.Top;
  Height := Height + diff;
end;

function TfmCompRename.GetComponentProperty(Index: Integer): WideString;
begin
  if (Index >=0) and (Index < FProperties.Count) then
    Result := (FProperties[Index] as TEdit).Text
  else
    raise Exception.Create('Invalid property index in TfmCompRename.GetComponentProperty');
end;

constructor TfmCompRename.Create(Owner: TComponent);
begin
  inherited;
  TControl_SetMinConstraints(Self);

  FProperties := TObjectList.Create(False);

  FAlignButtons[alTop] := TdzSpeedBitBtn.Create(b_AlignTop);
  FAlignButtons[alLeft] := TdzSpeedBitBtn.Create(b_AlignLeft);
  FAlignButtons[alClient] := TdzSpeedBitBtn.Create(b_AlignClient);
  FAlignButtons[alRight] := TdzSpeedBitBtn.Create(b_AlignRight);
  FAlignButtons[alBottom] := TdzSpeedBitBtn.Create(b_AlignBottom);
  FAlignButtons[alNone] := TdzSpeedBitBtn.Create(b_AlignNone);
  FAlignButtons[alCustom] := TdzSpeedBitBtn.Create(b_AlignCustom);

  FAnchorButtons[akTop] := TdzSpeedBitBtn.Create(b_AnchorTop);
  FAnchorButtons[akLeft] := TdzSpeedBitBtn.Create(b_AnchorLeft);
  FAnchorButtons[akRight] := TdzSpeedBitBtn.Create(b_AnchorRight);
  FAnchorButtons[akBottom] := TdzSpeedBitBtn.Create(b_AnchorBottom);
  p_Buttons.BevelOuter := bvNone;

  InitializeForm;
end;

destructor TfmCompRename.Destroy;
begin
  FreeAndNil(FProperties);
  inherited;
end;

procedure TfmCompRename.DialogKey(var Msg: TWMKey);
begin
  // make the selection of alignment and anchors via arrow keys more intuitive
  case Msg.CharCode of
    VK_DOWN: begin
        if ActiveControl = b_AlignTop then
          b_AlignClient.SetFocus
        else if (ActiveControl = b_AlignClient) or (ActiveControl = b_AlignLeft) or (ActiveControl = b_AlignRight) then
          b_AlignBottom.SetFocus
        else if (ActiveControl = b_AnchorTop) or (ActiveControl = b_AnchorLeft) or (ActiveControl = b_AnchorRight) then
          b_AnchorBottom.SetFocus
        else
          inherited;
      end;
    VK_UP: begin
        if ActiveControl = b_AlignBottom then
          b_AlignClient.SetFocus
        else if (ActiveControl = b_AlignClient) or (ActiveControl = b_AlignLeft) or (ActiveControl = b_AlignRight) then
          b_AlignTop.SetFocus
        else if (ActiveControl = b_AlignNone) or (ActiveControl = b_AlignCustom)then
          b_AlignBottom.SetFocus
        else if (ActiveControl = b_AnchorBottom) or (ActiveControl = b_AnchorLeft) or (ActiveControl = b_AnchorRight) then
          b_AnchorTop.SetFocus
        else
          inherited;
      end;
    VK_RIGHT: begin
        if ActiveControl = b_AlignLeft then
          b_AlignClient.SetFocus
        else if ActiveControl = b_AlignClient then
          b_AlignRight.SetFocus
        else if (ActiveControl = b_AnchorTop) or (ActiveControl = b_AnchorBottom) or (ActiveControl = b_AnchorLeft) then
          b_AnchorRight.SetFocus
        else
          inherited;
      end;
    VK_LEFT: begin
        if ActiveControl = b_AlignRight then
          b_AlignClient.SetFocus
        else if ActiveControl = b_AlignClient then
          b_AlignLeft.SetFocus
        else if (ActiveControl = b_AnchorTop) or (ActiveControl = b_AnchorBottom) or (ActiveControl = b_AnchorRight) then
          b_AnchorLeft.SetFocus
        else
          inherited;
      end;
  else
    inherited;
  end;
end;

{ TCompRenameNotifier }

procedure TCompRenameNotifier.Attach;
begin
  Assert(FChangeServiceNotifierIndex = -1);
  FChangeServiceNotifierIndex := GxEditorChangeServices.AddNotifier(Self);
end;

procedure TCompRenameNotifier.ComponentRenamed(const FormEditor: IOTAFormEditor;
  Component: IOTAComponent; const OldName, NewName: string);
begin
  if Assigned(FClient) then
    FClient.ComponentRenamed(FormEditor, Component, OldName, NewName);
end;

constructor TCompRenameNotifier.Create(const Client: TRenameComponentsExpert);
begin
  inherited Create;

  if Assigned(Client) then
  begin
    FClient := Client;
    FChangeServiceNotifierIndex := -1;
    Attach;
  end;
end;

destructor TCompRenameNotifier.Destroy;
begin
  Detach;
  FClient := nil;
  inherited Destroy;
end;

procedure TCompRenameNotifier.Detach;
begin
  GxEditorChangeServices.RemoveNotifierIfNecessary(FChangeServiceNotifierIndex);
end;

function TCompRenameNotifier.EditorKeyPressed(
  const SourceEditor: IOTASourceEditor; CharCode: Word; KeyData: Integer): Boolean;
begin
  Result := False;
  // Nothing
end;

procedure TCompRenameNotifier.FormEditorModified(const FormEditor: IOTAFormEditor);
begin
  if Assigned(FClient) then
    FClient.FormEditorModified(FormEditor);
end;

function TCompRenameNotifier.GetIndex: Integer;
begin
  Result := FChangeServiceNotifierIndex;
end;

procedure TCompRenameNotifier.NewModuleOpened(const Module: IOTAModule);
begin
  // Nothing
end;

procedure TCompRenameNotifier.SourceEditorModified(const SourceEditor: IOTASourceEditor);
begin
  // Nothing
end;

{ TRenameComponentsExpert }

function  TRenameComponentsExpert.GetActiveRenameRuleList: TStringList;
begin
  if GxOtaActiveDesignerIsFMX then begin
    Result := FRenameRuleListFmx;
  end else begin
    // I can't be bothered to distinguish between VCL, CLX and dotNET, since only VCL has survived
    Result := FRenameRuleListVcl;
  end;
end;


procedure TRenameComponentsExpert.AddNewClass(const AClassName: WideString);
var
  RuleList: TStringList;
begin
  RuleList := GetActiveRenameRuleList;
  Assert(Assigned(RuleList));

  // Classname already in list?
  if RuleList.IndexOfName(AClassName) < 0 then
  begin
    // No -> add "TClass=Class" as new entry
    RuleList.Add(AClassName+'='+Copy(AClassName, 2));
    SaveSettings;
  end;
end;

procedure TRenameComponentsExpert.Execute(Sender: TObject);
var
  SelCount: Integer;
  CurrentComponent: IOTAComponent;
  i: Integer;
begin
  if not GxOtaFormEditorHasSelectedComponent then
    Configure(nil)
  else
  begin
    if not GxOtaTryGetCurrentFormEditor(FFormEditor) then
      Exit;
    try
      SelCount := FFormEditor.GetSelCount;
      for i := 0 to SelCount - 1 do begin
        CurrentComponent := FFormEditor.GetSelComponent(i);
        if DoRename(CurrentComponent, False) = mrCancel then
          Break;
      end;
    finally
      FFormEditor := nil;
    end;
  end;

  IncCallCount;
end;

procedure TRenameComponentsExpert.Configure(_Owner: TWinControl);
begin
  Configure(_Owner, '');
end;

procedure TRenameComponentsExpert.Configure(_Owner: TWinControl; const _Selected: string);
begin
//    SetFormIcon(Dialog);
  FRenameRuleListVcl.Sort;
  FRenameRuleListFmx.Sort;
  if TfmCompRenameConfig.Execute(_Owner, HandleOnImport, HandleOnExport,
    FRenameRuleListVcl, FRenameRuleListFmx, FShowDialog, FAutoAddClasses,
    FFormWidth, FFormHeight, _Selected) then
    SaveSettings;
end;

procedure TRenameComponentsExpert.HandleOnImport(_Sender: TObject; const _fn: string;
  _RulesListVcl, _RulesListFmx: TStringList);
var
  GXSettings: TGExpertsSettings;
  Settings: IExpertSettings;
  ini: TMemIniFile;
begin
  {$IFOPT D+} SendDebugFmt('RenameComponents importing from file %s', [_fn]); {$ENDIF}
  if not FileExists(_fn) then begin
    {$IFOPT D+} SendDebug('File does not exist'); {$ENDIF}
    Exit; //==>
    end;


  GXSettings := nil;
  ini := TMemInifile.Create(_fn);
  try
    GXSettings := TGExpertsSettings.Create(ini, True);
    Ini := nil;
    Settings :=TExpertSettingsEx.Create(GXSettings, ConfigurationKey);
    GXSettings := nil;
    if not TryLoadRules(Settings, 'vcl', False, _RulesListVcl) then
      TryLoadRules(Settings, 'Items', False, _RulesListVcl);
    TryLoadRules(Settings, 'fmx', False, _RulesListFmx);
{$IFOPT D+}SendDebugFmt('RenameComponents imported %d vcl and %d fmx rules', [_RulesListVcl.Count, _RulesListFmx.Count]); {$ENDIF}
  finally
    FreeAndNil(GXSettings);
    FreeAndNil(ini);
  end;
end;

procedure TRenameComponentsExpert.HandleOnExport(_Sender: TObject; _RulesListVcl, _RulesListFmx: TStringList);
var
  GXSettings: TGExpertsSettings;
  Settings: IExpertSettings;
  ini: TMemIniFile;
  fn: string;
begin
  fn := 'GExperts_' + Self.GetName + '.ini';
  if not ShowSaveDialog('Select file to export to', 'ini', fn, 'INI files (*.ini)|*.ini') then
    Exit; //==>

  GXSettings := nil;
  ini := TMemIniFile.Create(fn);
  try
    GXSettings := TGExpertsSettings.Create(ini, False);
    Settings := TExpertSettingsEx.Create(GXSettings, ConfigurationKey);
    GXSettings := nil;
    SaveRules(Settings, 'vcl', _RulesListVcl);
    SaveRules(Settings, 'fmx', _RulesListFmx);
    ini.UpdateFile;
  finally
    FreeAndNil(GXSettings);
    FreeAndNil(ini);
  end;
end;

procedure TRenameComponentsExpert.ComponentRenamed(const FormEditor: IOTAFormEditor;
    Component: IOTAComponent; const OldName, NewName: WideString);
var
  RenameRuleList: TStringList;
begin
  // Bug: Delphi 8 can not set string properties on components
  if RunningDelphi8 then
    Exit;

  RenameRuleList := GetActiveRenameRuleList;
  if (not Assigned(RenameRuleList)) or (RenameRuleList.Count < 1) then
    Exit;
  if Active and Assigned(FormEditor) and (OldName = '') and (NewName > '') then
  begin
    // If the form being edited isn't the active designer, assume some
    // automated tool is doing the editing, and GExperts ignores the change
    if FormEditor.FileName <> GxOtaGetCurrentSourceFile then
      Exit;
    // Don't change the names of components that are not a default component
    // name based on the class.  This prevents renaming pasted components.
    if Assigned(Component) and IsDefaultComponentName(Component, NewName) then
    begin
      FComponentNames.Add(NewName);
      FFormNames.Add(FormEditor.FileName);
      FTimer.Enabled := True;
    end;
  end;
end;

constructor TRenameComponentsExpert.Create;
begin
  inherited Create;
  PrivateCompRenameExpert := Self;
  FComponentNames := TStringList.Create;
  FFormNames := TStringList.Create;
  FRenameRuleListVcl := TStringList.Create;
  FRenameRuleListFmx := TStringList.Create;
  FTimer := TTimer.Create(nil);
  FTimer.Enabled := False;
  FTimer.Interval := 100;
  FTimer.OnTimer := DoOnTimer;
  AddNotifier;
end;

destructor TRenameComponentsExpert.Destroy;
begin
  PrivateCompRenameExpert := nil;
  RemoveNotifier;
  FreeAndNil(FTimer);

  TStrings_FreeWithObjects(FRenameRuleListVcl);
  TStrings_FreeWithObjects(FRenameRuleListFmx);

  FreeAndNil(FComponentNames);
  FreeAndNil(FFormNames);
  inherited;
end;

function TRenameComponentsExpert.DoRename(const Component: IOTAComponent; UseRules: Boolean): TModalResult;
var
  i: Integer;
  Pipe1Pos: Integer;
  Pipe2Pos: Integer;
  PlaceHolderPos: Integer;
  ClassName: WideString;
  RenameRule: WideString;
  CompName: WideString;
  PropName: WideString;
  PropValue: String;
  UsePropValue: Boolean;
  SearchName: WideString;
  Reason: WideString;
  frm: TfmCompRename;
  ShowDialog: Boolean;
  OtherProps: TStringList;
  Index: Integer;
  RenameRuleList: TStringList;
begin
  Assert(Assigned(Component));
  Assert(Assigned(FFormEditor));
  Result := mrOk;

  // Get the component class name
  ClassName := Component.GetComponentType;

  // Get the desired rename rule for this class
  RenameRule := GetClassRenameRule(ClassName);
  if RenameRule = '' then
  begin
    if FAutoAddClasses then
    begin
      AddNewClass(ClassName);
      RenameRule := GetClassRenameRule(ClassName);
    end;
  end;

  Pipe2Pos := -1;
  Pipe1Pos := Pos(WideString('|'), RenameRule);
  if Pipe1Pos > 0 then begin
    System.Delete(RenameRule, Pipe1Pos, 1);
    Pipe2Pos := LastCharPos(RenameRule, '|');
    if (Pipe2Pos >= Pipe1Pos) then
      System.Delete(RenameRule, Pipe2Pos, 1);
  end;

  PlaceHolderPos := Pos(WideString('%d'), RenameRule);
  if PlaceHolderPos > 0 then
    System.Delete(RenameRule, PlaceHolderPos, 2);

  CompName := GxOtaGetComponentName(Component);
  if CompName = '' then
    Exit;

  ShowDialog := FShowDialog;
  if not UseRules and (Length(RenameRule) > 0) then
  begin
    ShowDialog := True;
    UseRules := IsDefaultComponentName(Component, CompName);
  end;

  RenameRuleList := GetActiveRenameRuleList;
  if not UseRules or (Length(RenameRule) > 0) then
  begin
    if ShowDialog or not UseRules then
    begin
      frm := TfmCompRename.Create(nil);
      try
        frm.OnIsValidComponentName := IsValidComponentName;
        frm.OldName := CompName;

        frm.SetComponent(Component);
        frm.InitDpiScaler;

        Index := RenameRuleList.IndexOfName(Component.GetComponentType);
        if Index <> -1 then
        begin
          OtherProps := RenameRuleList.Objects[Index] as TStringList;
          if Assigned(OtherProps) then
          begin
            for i := 0 to OtherProps.Count - 1 do
            begin
              UsePropValue := False;
              PropName := OtherProps.Names[i];
              if PropName = '' then
                PropName := OtherProps[i];
              // Consolidate with code below
              if GxOtaPropertyExists(Component, PropName) then
              begin
                if UseRules then
                begin
                  PropValue := OtherProps.Values[PropName];
                  if PropValue <> '' then
                  begin
                    PropValue := AnsiDequotedStr(PropValue, #39);
                    if (PropValue= #39#39) then
                      PropValue := '';
                    UsePropValue := True;
                  end;
                end;
                if UsePropValue then
                  frm.AddComponentProperty(PropName, PropValue)
                else
                  frm.AddComponentProperty(PropName,
                    GxOtaGetComponentPropertyAsString(Component, PropName, True));
              end
              else
                frm.AddComponentProperty(PropName, SPropertyNotFound);
            end;
          end
        end
        else
          OtherProps := nil;

        if UseRules then
        begin
          frm.NewName := RenameRule;
          if Pipe1Pos > 0 then
            frm.SetRuleSelection(Pipe1Pos - 1, Pipe2Pos - 1)
          else
            frm.SetRuleSelection(Length(RenameRule), Length(RenameRule));
        end
        else
        begin
          frm.NewName := CompName;
          frm.SetRuleSelection(0, Length(CompName));
        end;

        Result := frm.Execute;
        if Result = mrOk then
        begin
          CompName := frm.NewName;
          GxOtaSetComponentName(Component, CompName);

          frm.GetAlign(Component);
          frm.GetAnchors(Component);

          if Assigned(OtherProps) then
          begin
            for i := 0 to OtherProps.Count - 1 do
            begin
              PropName := OtherProps.Names[i];
              if PropName = '' then
                PropName := OtherProps[i];
              if GxOtaPropertyExists(Component, PropName) then
                GxOtaSetComponentPropertyAsString(Component, PropName,
                  frm.GetComponentProperty(i));
            end;
          end;
        end;
      finally
        FreeAndNil(frm);
      end;
    end
    else
    begin
      // Try to find a new name without user interaction
      CompName := '';

      if PlaceHolderPos > 0 then
        Insert('%d', RenameRule, PlaceHolderPos)
      else
        RenameRule := RenameRule + '%d';

      for i := 1 to 100 do
      begin
        SearchName := Format(RenameRule, [i]);
        if GxOtaComponentsAreEqual(Component, FFormEditor.FindComponent(SearchName)) then
          Exit; // The component already matches the rename rule's result

        if IsValidComponentName(CompName, SearchName, Reason) then
        begin
          CompName := SearchName;
          Break;
        end;
      end;
      if Length(CompName) > 0 then
        GxOtaSetComponentName(Component, CompName);

      if UseRules then
      begin
        Index := RenameRuleList.IndexOfName(Component.GetComponentType);
        if Index <> -1 then
        begin
          OtherProps := RenameRuleList.Objects[Index] as TStringList;
          if Assigned(OtherProps) then
          begin
            for i := 0 to OtherProps.Count - 1 do
            begin
              PropName := OtherProps.Names[i];
              if (PropName <> '') and GxOtaPropertyExists(Component, PropName) then
              begin
                PropValue := OtherProps.Values[PropName];
                if PropValue <> '' then
                begin
                  PropValue := AnsiDequotedStr(PropValue, #39);
                  if (PropValue= #39#39) then
                    PropValue := '';
                  GxOtaSetComponentPropertyAsString(Component, PropName, PropValue);
                end;
              end;
            end;
          end
        end;
      end;
    end;
  end
end;

procedure TRenameComponentsExpert.DoOnTimer(Sender: TObject);
var
  i: Integer;
  FormName: WideString;
  SearchName: WideString;
  Component: IOTAComponent;
begin
  FTimer.Enabled := False;
  try
    if (GxOtaGetCurrentFormEditor = nil) then
      Exit;
    Assert(FFormNames.Count = FComponentNames.Count);
    for i := 0 to FComponentNames.Count - 1 do
    begin
      // Try to locate the component with given name
      FormName := FFormNames[i];
      SearchName := FComponentNames[i];
      if (FormName = '') or (SearchName = '') then
        Break;
      FFormEditor := GxOtaGetFormEditorForFileName(FormName);
      if not Assigned(FFormEditor) then
        Break;

      Component := FFormEditor.FindComponent(SearchName);
      if Assigned(Component) then
      begin
        if GxOtaIsInheritedComponent(Component) then
          Break;
        if DoRename(Component, True) = mrCancel then
          Break;
      end;
    end;
  finally
    FFormEditor := nil;
    Component := nil;
    FComponentNames.Clear;
    FFormNames.Clear;
  end;
end;

procedure TRenameComponentsExpert.FormEditorModified(const FormEditor: IOTAFormEditor);
begin
  // Nothing
end;

function TRenameComponentsExpert.GetActionCaption: string;
resourcestring
  SMenuCaption = 'Rename Components...';
begin
  Result := SMenuCaption;
end;

function TRenameComponentsExpert.GetClassRenameRule(const AClassName: WideString): WideString;
var
  RuleList: TStringList;
begin
  RuleList := GetActiveRenameRuleList;
  Assert(Assigned(RuleList));
  Result := RuleList.Values[AClassName];
end;

function TRenameComponentsExpert.GetDefaultShortCut: TShortCut;
begin
  Result := Menus.ShortCut(VK_F2, [ssShift]);
end;

class function TRenameComponentsExpert.GetName: string;
begin
  Result := COMP_RENAME_NAME;
end;

function TRenameComponentsExpert.HasConfigOptions: Boolean;
begin
  Result := True;
end;

function TRenameComponentsExpert.HasDesignerMenuItem: Boolean;
begin
  Result := True;
end;

class function TRenameComponentsExpert.TryLoadRules(_Settings: IExpertSettings; const _Section: string;
  _TryRoot: Boolean; _RulesList: TStringList): Boolean;

  procedure ReadOtherProps(_Settings: IExpertSettings; const _Section: string; _TryRoot: Boolean;
    _RulesList: TStringList);
  var
    OtherProps: TStringList;
    i: Integer;
  begin
    OtherProps := nil;
    try
      for i := 0 to _RulesList.Count - 1 do begin
        if not Assigned(OtherProps) then
          OtherProps := TStringList.Create;
        _Settings.ReadStrings(_Section + _RulesList.Names[i], OtherProps);
        if _TryRoot and (OtherProps.Count = 0) then begin
          _Settings.ReadStrings(_RulesList.Names[i], OtherProps);
        end;
        if OtherProps.Count > 0 then begin
          _RulesList.Objects[i] := OtherProps;
          OtherProps := nil;
        end;
      end;
    finally
      FreeAndNil(OtherProps);
    end;
  end;

begin
  TStrings_FreeAllObjects(_RulesList).Clear;
  Result := _Settings.SectionExists(_Section);
  if Result then begin
    _Settings.ReadStrings(_Section, _RulesList);
    _RulesList.Sort;
    ReadOtherProps(_Settings, AddSlash(_Section), _TryRoot, _RulesList);
  end;
end;

procedure TRenameComponentsExpert.InternalLoadSettings(_Settings: IExpertSettings);
begin
  inherited InternalLoadSettings(_Settings);
  FShowDialog := _Settings.ReadBool('ShowDialog', False);
  FAutoAddClasses := _Settings.ReadBool('AutoAdd', True);

  FFormWidth := _Settings.ReadInteger('Width', 0);
  FFormHeight := _Settings.ReadInteger('Height', 0);

  // new configuration under .\vcl
  if not TryLoadRules(_Settings, 'vcl', True, FRenameRuleListVcl) then begin
    // older configuration under .\Items
    TryLoadRules(_Settings, 'Items', True, FRenameRuleListVcl);
  end;

  TryLoadRules(_Settings, 'fmx', False, FRenameRuleListFmx);
end;

class procedure TRenameComponentsExpert.SaveRules(_Settings: IExpertSettings; const _Section: string; _RulesList: TStringList);
var
  i: Integer;
  SubSection: string;
  OtherProps: TStringList;
begin
  _Settings.WriteStrings(_Section, _RulesList);

  for i := 0 to _RulesList.Count - 1 do begin
    SubSection := AddSlash(_Section) + _RulesList.Names[i];
    OtherProps := _RulesList.Objects[i] as TStringList;
    if Assigned(OtherProps) then
      _Settings.WriteStrings(SubSection, OtherProps)
    else begin
      if _Settings.SectionExists(SubSection) then
        _Settings.EraseSection(SubSection);
    end;
  end;
end;

procedure TRenameComponentsExpert.InternalSaveSettings(_Settings: IExpertSettings);
var
  i: Integer;
  cnt: integer;
  Sections: TStringList;
  s: string;
begin
  inherited InternalSaveSettings(_Settings);
  Assert(Assigned(FRenameRuleListVcl));
  Assert(Assigned(FRenameRuleListFmx));

  // clean up older sub sections which were directly in the section.
  Sections := TStringList.Create;
  try
    _Settings.ReadSections(Sections);
    for i := 0 to Sections.Count - 1 do begin
     s := sections[i];
      if not SameText(s, 'vcl') and not SameText(s, 'fmx') then
        _Settings.EraseSection(s);
    end;
  finally
    FreeAndNil(Sections);
  end;

  if _Settings.ValueExists('Count') then begin
    // clean up old entries that were directly in the section, we now write
    // to a subsection
    cnt := _Settings.ReadInteger('Count', 0);
    for i := 0 to cnt - 1 do begin
      _Settings.DeleteKey(Format('Item%d', [i]));
    end;
    _Settings.DeleteKey('Count');
  end;

  _Settings.WriteInteger('Width', FFormWidth);
  _Settings.WriteInteger('Height', FFormHeight);

  _Settings.WriteBool('ShowDialog', FShowDialog);
  _Settings.WriteBool('AutoAdd', FAutoAddClasses);

  SaveRules(_Settings, 'vcl', FRenameRuleListVcl);
  SaveRules(_Settings, 'fmx', FRenameRuleListFmx);
end;

function TRenameComponentsExpert.IsValidComponentName(const OldName, NewName: WideString; var Reason: WideString): Boolean;
resourcestring
  InalidIdent = 'Invalid identifier';
  DuplicateName = 'Duplicate name';
var
  FoundComponent: IOTAComponent;
  FoundName: WideString;
begin
  Reason := '';
  FoundName := '';
  Result := IsValidIdent(NewName);
  if not Result then
    Reason := InalidIdent;
  if Result and Assigned(FFormEditor) then
  begin
    FoundComponent := FFormEditor.FindComponent(NewName);
    if Assigned(FoundComponent) then
      FoundName := GxOtaGetComponentName(FoundComponent);
    Result := (not Assigned(FoundComponent)) or (FoundName = OldName);
    if not Result then
      Reason := DuplicateName;
  end;
end;

procedure TRenameComponentsExpert.SetActive(New: Boolean);
begin
  if New <> Active then
  begin
    inherited SetActive(New);
    if New then
      AddNotifier
    else
      RemoveNotifier;
  end;
end;

procedure TRenameComponentsExpert.AddNotifier;
begin
  if not Assigned(FCompRenameNotifier) then
    FCompRenameNotifier := TCompRenameNotifier.Create(Self);
end;

procedure TRenameComponentsExpert.RemoveNotifier;
begin
  if Assigned(FCompRenameNotifier) then
  begin
    FCompRenameNotifier.Detach;
    FCompRenameNotifier := nil;
  end;
end;

function TRenameComponentsExpert.IsDefaultComponentName(Component: IOTAComponent; const NewName: WideString): Boolean;
var
  Prefix: WideString;
  Suffix: WideString;
begin
  Assert(Assigned(Component));
  Result := False;
  Prefix := Component.GetComponentType;
  if (Length(Prefix) > 1) and (Prefix[1] = 'T') then
    Prefix := Copy(Prefix, 2);
  if not StartsText(Prefix, NewName) then
    Exit;
  Suffix := Copy(NewName, Length(Prefix) + 1);
  if StrToIntDef(Suffix, -999) <> -999 then
    Result := True;
end;

function TRenameComponentsExpert.IsDefaultActive: Boolean;
begin
  // IDE Bug: This expert does not work under Delphi 8
  Result := not RunningDelphi8;
end;

procedure TfmCompRename.InitializeForm;
begin
  SetModalFormPopupMode(Self);
  lblReason.Font.Color := clRed;
end;

procedure TfmCompRename.btnSettingsClick(Sender: TObject);
begin
  Assert(Assigned(PrivateCompRenameExpert));
  PrivateCompRenameExpert.Configure(Self, FComponentClassName);
end;

procedure TfmCompRename.HandleAlignButtons(_Align: TAlign);
var
  al: TAlign;
begin
  if FAlignButtons[_Align].Down then begin
    for al := Low(FAlignButtons) to High(FAlignButtons) do
      if al <> _Align then
        FAlignButtons[al].Down := False;
  end else
    FAlignButtons[_Align].Down := True;
end;

procedure TfmCompRename.b_AlignBottomClick(Sender: TObject);
begin
  HandleAlignButtons(alBottom);
end;

procedure TfmCompRename.b_AlignClientClick(Sender: TObject);
begin
  HandleAlignButtons(alClient);
end;

procedure TfmCompRename.b_AlignCustomClick(Sender: TObject);
begin
  HandleAlignButtons(alCustom);
end;

procedure TfmCompRename.b_AlignLeftClick(Sender: TObject);
begin
  HandleAlignButtons(alLeft);
end;

procedure TfmCompRename.b_AlignNoneClick(Sender: TObject);
begin
  HandleAlignButtons(alNone);
end;

procedure TfmCompRename.b_AlignRightClick(Sender: TObject);
begin
  HandleAlignButtons(alRight);
end;

procedure TfmCompRename.b_AlignTopClick(Sender: TObject);
begin
  HandleAlignButtons(alTop);
end;

procedure TfmCompRename.SetMargins(_Value: integer);
var
  s: string;
begin
  s := IntToStr(_Value);
  ed_MarginTop.Text := s;
  ed_MarginLeft.Text := s;
  ed_MarginRight.Text := s;
  ed_MarginBottom.Text := s;
end;

procedure TfmCompRename.b_Margins0Click(Sender: TObject);
begin
  SetMargins(0);
end;

procedure TfmCompRename.b_Margins3Click(Sender: TObject);
begin
  SetMargins(3);
end;

procedure TfmCompRename.b_Margins6Click(Sender: TObject);
begin
  SetMargins(6);
end;

procedure TfmCompRename.b_Margins8Click(Sender: TObject);
begin
  SetMargins(8);
end;

initialization
  RegisterGX_Expert(TRenameComponentsExpert);

end.

