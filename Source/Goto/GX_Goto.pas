unit GX_Goto;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  Actions,
  GX_BaseForm,
  GX_UnitPositions,
  GX_ConfigurationInfo;

type
  Tf_Goto = class(TfmBaseForm)
    cmb_LineNumber: TComboBox;
    l_LineNumber: TLabel;
    lb_UnitPositions: TListBox;
    b_Ok: TButton;
    b_Cancel: TButton;
    procedure lb_UnitPositionsClick(Sender: TObject);
    procedure lb_UnitPositionsDblClick(Sender: TObject);
    procedure lb_UnitPositionsEnter(Sender: TObject);
    procedure cmb_LineNumberKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cmb_LineNumberChange(Sender: TObject);
  private
    FUnitPositions: TUnitPositions;
    FCurrentSourceFn: string;
    procedure SetData(_Row: Integer);
    procedure GetData(out _Row: Integer);
  public
    class function Execute(var _Row: Integer): Boolean;
    constructor Create(_Owner: TComponent); override;
  end;

implementation

{$R *.dfm}

uses
  Registry,
  ToolsAPI,
  GX_OtaUtils,
  GX_Experts,
  GX_GxUtils,
  GX_IdeUtils,
  GX_GotoConfig,
  u_dzVclUtils;

const
  SEARCH_GOTO_COMMAND = 'SearchGotoCommand';

type
  TGotoExpert = class(TGX_Expert)
  private
    FIdeGotoActionEvent: TNotifyEvent;
    FOverrideSearchGoto: Boolean;
    procedure HijackIdeActions;
    procedure ResetIdeActions;
  protected
    procedure SetActive(New: Boolean); override;
    procedure Configure(_Owner: TWinControl); override;
    procedure InternalLoadSettings(_Settings: IExpertSettings); override;
    procedure InternalSaveSettings(_Settings: IExpertSettings); override;
  public
    function GetActionCaption: string; override;
    class function GetName: string; override;
    destructor Destroy; override;
    procedure Execute(Sender: TObject); override;
    function HasConfigOptions: Boolean; override;
    procedure AfterIDEInitialized; override;
  end;

{ Tf_Goto }

constructor Tf_Goto.Create(_Owner: TComponent);
var
  Items: TStrings;
  i: Integer;
  reg: TRegistry;
  cnt: Integer;
  Spacer: Integer;
  s: string;
begin
  inherited;

  Items := lb_UnitPositions.Items;
  Items.BeginUpdate;
  try
    FCurrentSourceFn := GxOtaGetCurrentSourceFile;
    FUnitPositions := TUnitPositions.Create(FCurrentSourceFn);
    for i := 0 to FUnitPositions.Count - 1 do begin
      Items.Add(FUnitPositions.Positions[i].Name);
    end;
  finally
    Items.EndUpdate;
  end;

  GxSetDefaultFont(Self);

  Spacer := lb_UnitPositions.Left;
  lb_UnitPositions.ClientHeight := (FUnitPositions.Count + 1) * lb_UnitPositions.ItemHeight;
  b_Ok.Top := lb_UnitPositions.Top + lb_UnitPositions.Height + Spacer;
  b_Cancel.Top := b_Ok.Top;
  b_Cancel.Left := lb_UnitPositions.Left + lb_UnitPositions.Width - b_Cancel.Width;
  Self.ClientHeight := b_Ok.Top + b_Ok.Height + Spacer;
  Self.ClientWidth  := lb_UnitPositions.Left + lb_UnitPositions.Width + Spacer;

  TControl_SetMinConstraints(Self);

  InitDpiScaler;

  // Unfortunately the IDE only updates the registry when it closes down so this list will be
  // outdated if the user switched from the IDE's goto dialog to the GExperts one.
  // todo: Does this history list really make any sense? I for one have never used it.
  // Remembering the active line before the goto so we can go back where we came from makes more
  // sense, but the Undo function already does that (but not everybody knows this).
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKeyReadOnly(GxOtaGetIdeBaseRegistryKey + '\History Lists\hlGotoLine') then begin
      if reg.ValueExists('Count') then begin
        cnt := reg.ReadInteger('Count');
        Items := cmb_LineNumber.Items;
        Items.BeginUpdate;
        try
          for i := 0 to cnt - 1 do begin
            s := 'Item' + IntToStr(i);
            if reg.ValueExists(s) then begin
              s := reg.ReadString(s);
              Items.Add(s);
            end;
          end;
        finally
          Items.EndUpdate;
        end;
      end;
    end;
  finally
    FreeAndNil(reg);
  end;
end;

class function Tf_Goto.Execute(var _Row: Integer): Boolean;
var
  frm: Tf_Goto;
begin
  frm := Tf_Goto.Create(nil);
  try
    frm.SetData(_Row);
    Result := (frm.ShowModal = mrOk);
    if Result then
      frm.GetData(_Row);
  finally
    FreeAndNil(frm);
  end;
end;

procedure Tf_Goto.GetData(out _Row: Integer);
var
  LText: string;
  ndx: Integer;
begin
  LText := Trim(cmb_LineNumber.Text);
  if not TryStrToInt(LText, _Row) then begin
    ndx := lb_UnitPositions.ItemIndex;
    if ndx >= 0 then begin
      _Row := FUnitPositions.Positions[ndx].LineNo;
    end;
  end;
end;

procedure Tf_Goto.SetData(_Row: Integer);
begin
  cmb_LineNumber.Text := IntToStr(_Row);
end;

procedure Tf_Goto.cmb_LineNumberChange(Sender: TObject);
var
  Line: Integer;
  LText: string;
  i: Integer;
begin
  LText := Trim(cmb_LineNumber.Text);

  // If user types a number, enable the OK button
  if TryStrToInt(LText, Line) then begin
    b_Ok.Enabled := True;
    Exit; //==>
  end;

  // not a number. Try to match the text in listbox.
  if not cmb_LineNumber.DroppedDown then begin
    for i := 0 to lb_UnitPositions.Items.Count - 1 do begin
      if Pos(LText, lb_UnitPositions.Items[i]) > 0 then begin
        lb_UnitPositions.ItemIndex := i;
        b_Ok.Enabled := True;
        Exit; //==>
      end;
    end; // for i
  end;
  b_Ok.Enabled := False;
end;

procedure Tf_Goto.cmb_LineNumberKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if not cmb_LineNumber.DroppedDown then begin
    if (Key in [VK_UP, VK_DOWN]) and (Shift = []) then begin
      SendMessage(lb_UnitPositions.Handle, WM_KEYDOWN, Key, 0);
      Key := 0;
    end;
  end;
end;

procedure TCombobox_SetText(_cmb: TWinControl; const _Text: string);
begin
  _cmb.Perform(WM_SETTEXT, 0, LPARAM(PChar(_Text)));
  _cmb.Perform(CM_TEXTCHANGED, 0, 0);
end;

procedure TCombobox_SelectAll(_cmb: TWinControl);
begin
  SendMessage(_cmb.Handle, CB_SETEDITSEL, 0, LPARAM($FFFF0000));
end;

procedure Tf_Goto.lb_UnitPositionsClick(Sender: TObject);
var
  Idx: Integer;
  Line: Integer;
begin
  Idx := lb_UnitPositions.ItemIndex;
  if Idx = -1 then
    Exit; //==>

  Line := FUnitPositions.Positions[Idx].LineNo;
  TCombobox_SetText(cmb_LineNumber, IntToStr(Line));
  TCombobox_SelectAll(cmb_LineNumber);
  b_Ok.Enabled := Line > 0;
end;

procedure Tf_Goto.lb_UnitPositionsDblClick(Sender: TObject);
begin
  lb_UnitPositionsClick(Sender);
  ModalResult := mrOk;
end;

procedure Tf_Goto.lb_UnitPositionsEnter(Sender: TObject);
var
  nValue: Integer;
begin
  inherited;
  if (lb_UnitPositions.ItemIndex > 0)
    and (not TryStrToInt(cmb_LineNumber.Text, nValue)) then
    lb_UnitPositionsClick(Sender);
end;

{ TGotoExpert }

destructor TGotoExpert.Destroy;
begin
  ResetIDEAction(SEARCH_GOTO_COMMAND, FIdeGotoActionEvent);
  inherited;
end;

procedure TGotoExpert.Execute(Sender: TObject);
var
  View: IOTAEditView;
  Line: Integer;
  CursorPos: TOTAEditPos;
begin
//    SetFormIcon(fmAsciiChart);
  if not GxOtaTryGetTopMostEditView(View) then
    Exit; //==>

  CursorPos := View.CursorPos;
  Line := CursorPos.Line;

  if not Tf_Goto.Execute(Line) then
    Exit; //==>

  CursorPos.Line := Line;
  View.CursorPos := CursorPos;
  View.Center(Line, CursorPos.Col);
  IncCallCount;
end;

function TGotoExpert.GetActionCaption: string;
begin
  Result := 'Go to';
end;

class function TGotoExpert.GetName: string;
begin
  Result := 'GotoExpert';
end;

function TGotoExpert.HasConfigOptions: Boolean;
begin
  Result := True;
end;

procedure TGotoExpert.Configure(_Owner: TWinControl);
begin
  if Tf_GotoConfig.Execute(_Owner, FOverrideSearchGoto) then begin
    ResetIdeActions;
    HijackIdeActions;
  end;
end;

procedure TGotoExpert.InternalLoadSettings(_Settings: IExpertSettings);
begin
  inherited;
  FOverrideSearchGoto := _Settings.ReadBool('OverrideSearchGoto', False);
end;

procedure TGotoExpert.InternalSaveSettings(_Settings: IExpertSettings);
begin
  inherited;
  _Settings.WriteBool('OverrideSearchGoto', FOverrideSearchGoto);
end;

procedure TGotoExpert.HijackIdeActions;
begin
  if FOverrideSearchGoto and not Assigned(FIdeGotoActionEvent) then
    HijackIDEAction(SEARCH_GOTO_COMMAND, FIdeGotoActionEvent, Execute);
end;

procedure TGotoExpert.ResetIdeActions;
begin
  if Assigned(FIdeGotoActionEvent) then
    ResetIDEAction(SEARCH_GOTO_COMMAND, FIdeGotoActionEvent);
end;

procedure TGotoExpert.SetActive(New: Boolean);
begin
  inherited;
  if New then begin
    HijackIdeActions;
  end else begin
    ResetIdeActions;
  end;
end;

procedure TGotoExpert.AfterIDEInitialized;
begin
  inherited;
  HijackIdeActions;
end;

initialization
  RegisterGX_Expert(TGotoExpert);
end.
