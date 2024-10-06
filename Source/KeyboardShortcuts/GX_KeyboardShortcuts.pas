unit GX_KeyboardShortcuts;

{$I GX_CondDefine.inc}

interface

uses
  Windows,
  SysUtils,
  Classes,
  Grids,
  Types,
  Controls,
  Forms,
  Dialogs,
  Graphics,
  GX_Experts, GX_ConfigurationInfo,
  GX_BaseForm;

type
  TfmGxKeyboardShortcuts = class(TfmBaseForm)
    Grid: TStringGrid;
    procedure GridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure GridMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure GridMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure GridMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    FColsIdx: array of Integer;
    FSortCols: TStringList;
    FSkipMouseUpAfterColumnMoved: Boolean;
    function ConfigurationKey: string;
    function SortCompareEntries(_Idx1, _Idx2: Integer): Integer;
    procedure SortSwapEntries(_Idx1, _Idx2: Integer);
    function ScrollGrid(Grid: TDrawGrid; Direction: Integer; Shift: TShiftState): Boolean;
    procedure GridOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure GridOnFixedCellClick(Sender: TObject; ACol, ARow: Longint);
    procedure GridOnColumnMoved(Sender: TObject; FromIndex, ToIndex: Longint);
    procedure GridOnDblClick(Sender: TObject);
    procedure GridOnClick(Sender: TObject);
    procedure GridSort;
    procedure GridFill;
    procedure GridOnContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure PopupOnClick(Sender: TObject);
    procedure PopupExecute(IsInit: Boolean; Sender: TObject);
    procedure LoadSettings(Settings: IExpertSettings; var ColWidths: Boolean);
    procedure SaveSettings(Settings: IExpertSettings);
    procedure MenuOnClick(Sender: TObject);
    procedure MenuOnAdvancedDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; State: TOwnerDrawState);
    procedure FormOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  protected
{$IFDEF GX_IDE_IS_HIDPI_AWARE}
    FOldDPI: Integer;
    procedure ApplyDpi(_NewDpi: Integer; _NewBounds: PRect); override;
{$ENDIF}
  public
    class procedure Execute(_bmp: TBitmap);
    constructor Create(_Owner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

uses
{$IFOPT D+}GX_DbugIntf,
{$ENDIF}
  Menus,
  StrUtils,
  Math,
  Actions,
  ActnList,
  u_dzVclUtils,
  u_dzQuicksort, u_dzOsUtils,
  GX_ActionBroker,
  GX_GenericUtils, GX_OtaUtils,
  GX_GetIdeVersion,
  GX_StringGridDrawFix;

const
  cIDEMenuFileOpenRecentItem = 'FileOpenRecentItem';
  cIDEActionShortcutSecondary = 'Shift-Ctrl-Enter';
  cIDEActionShortcutSecondaryFix = 'Ctrl+Shift+Enter'; // just like that, hardcoded

const
  colModifier   = 0; colObjItemIndex = 0; colTitleModifier = 'Modifier';
  colSCutKey    = 1; colObjSCutIndex = 1; colTitleSCutKey  = 'Key';
  colCategory   = 2; colObjDuplicate = 2; colTitleCategory = 'Category, Menu';
  colCaption    = 3;                      colTitleCaption  = 'Caption';
  colCompName   = 4; colObjComponent = 4; colTitleCompName = 'Name Action/Menu';
  colsCount     = 5;
  colsTitle: array[0..colsCount - 1] of string =
    (colTitleModifier, colTitleSCutKey, colTitleCategory, colTitleCaption, colTitleCompName);
  cRowTitle     = 0;
  cRowsFixed    = 1;
  cursorFixed   = crHandPoint;
  cObjNil       = nil;
  cObjDuplicate = TObject(1);
  cObjSortAsc   = TObject(1);
  cObjSortDesc  = TObject(-1);

const
  cpmATest1      =  0; //?!?
  cpmATest2      =  1; //?!?
  cpmFActions    =  3;
  cpmFMenu       =  4;
  cpmFNoName     =  5;
  cpmFSecondary  =  6;
  cpmSTaskBar    =  8;
  cpmSOnTop      =  9;
  cpmLast        = 10;
  cpmCaption     =  0;
  cpmDefault     =  1;
  cpmSetting     =  2;
  cpmArray: array[0..cpmLast] of array[0..2] of string  = (
    ('Test1'            , ''    , ''),
    ('Test2'            , ''    , ''),
    ('-'                , ''    , ''),
    ('Show Actions'     , 'True', 'Filter.ShowActions'),
    ('Show Menu'        , 'True', 'Filter.ShowMenu'),
    ('Show without Name', 'True', 'Filter.ShowWithoutName'),
    ('Show Secondary'   , 'True', 'Filter.ShowSecondary'),
    ('-'                , ''    , ''),
    ('ShowInTaskBar'    , 'True', 'Form.ShowInTaskBar'),
    ('StayOnTop'        , ''    , 'Form.StayOnTop'),
    ('-'                , ''    , ''));

resourcestring
  SExpertCaption = 'Keyboard Shortc&uts'; //'IDE Shortc&uts'; //'Keyboard Shortcuts';
  SExpertDescription =
    //'List all keyboard shortcuts of registered actions in the IDE';
    'List all IDE Shortcuts - Actions, Menu, Keymappings';

var
  UfmGxKeyboardShortcuts: TfmGxKeyboardShortcuts = nil;

type
  TMenuItem_Protected = class(TMenuItem);



type
  TSCutRec = record
  private
    ShortCut: TShortCut;
    ShortcutText: string;
    Key: string;
    Modifier: string;
    Text: string;
    procedure SetShortCut(AShortCut: TShortCut);
    procedure Init;
  end;

  TSCRec = record
  private
    Shortcuts: array of TSCutRec;
    Action: TContainedAction;
    Menu: TMenuItem;
    MenuFrm: TMenuItem;
    function TextAlt(const Text, Alt: string): string;
    function Category: string;
    function Caption: string;
    function Name(Index: Integer = 0): string;
    procedure InitShortcuts(Count: Integer = -1);
    procedure Init;
    class var Items: array of TSCRec;
    class procedure ItemsInit(Count: Integer = -1); static;
    class procedure ItemsFill(MenuIde, MenuFrm: TMenuItem; OnClick: TNotifyEvent; OnDraw: TAdvancedMenuDrawItemEvent = nil); static;
    class procedure ItemsFillAction(Action: TContainedAction; Index: Integer); static;
    class procedure ItemsFillMenu(MenuIde, MenuFrm: TMenuItem; Actions: TList; OnClick: TNotifyEvent; OnDraw: TAdvancedMenuDrawItemEvent = nil); static;
    class procedure ItemsFillMenuItem(MenuIde, MenuFrm: TMenuItem; Index: Integer); static;
  end;



type
  TKeyboardShortcutsExpert = class(TGX_Expert)
  private
  protected
  public
    class function GetName: string; override;
    function CanHaveShortCut: Boolean; override;
    constructor Create; override;
    destructor Destroy; override;
    function GetActionCaption: string; override;
    function GetHelpString: string; override;
    function HasConfigOptions: Boolean; override;
    procedure Execute(Sender: TObject); override;
  end;



function TGrid_IsCell(Grid: TDrawGrid; Col: Integer; Row: Integer = 0): Boolean;
begin
  Result := (Col >= 0) and (col < Grid.ColCount) and (Row >= 0) and (Row < Grid.RowCount);
end;

function TGrid_IsFixed(Grid: TDrawGrid; Col: Integer; Row: Integer = 0): Boolean;
begin
  Result := TGrid_IsCell(Grid, Col, Row) and ( (Col < Grid.FixedCols) or (Row < Grid.FixedRows) );
end;

function TGrid_MouseToCell(Grid: TDrawGrid; var Col: Integer; var Row: Integer): Boolean; overload;
var
  mouse: TPoint;
begin
  GetCursorPos(mouse);
  mouse := Grid.ScreenToClient(mouse);
  Grid.MouseToCell(mouse.X, mouse.Y, Col, Row);
  Result := TGrid_IsCell(Grid, Col, Row);
end;

function TGrid_MouseToFixed(Grid: TDrawGrid; var Col: Integer; var Row: Integer; Fixed: Boolean = True): Boolean; overload;
begin
  Result := TGrid_MouseToCell(Grid, Col, Row) and (Fixed = TGrid_IsFixed(Grid, Col, Row));
end;

function TGrid_MouseToCell(Grid: TDrawGrid; X, Y: Integer; var Col: Integer; var Row: Integer; Fixed: Boolean = True): Boolean; overload;
begin
  Grid.MouseToCell(X, Y, Col, Row);
  Result := TGrid_IsCell(Grid, Col, Row);
end;

function TGrid_MouseToFixed(Grid: TDrawGrid; X, Y: Integer; var Col: Integer; var Row: Integer; Fixed: Boolean = True): Boolean; overload;
begin
  Result := TGrid_MouseToCell(Grid, X, Y, Col, Row) and (Fixed = TGrid_IsFixed(Grid, Col, Row));
end;



{ TSCutRec }

procedure TSCutRec.SetShortCut(AShortCut: TShortCut);
var
  LKey: Word;
  LShift: TShiftState;
  //keyStr, shiftStr: string;
begin
  ShortCut := AShortCut;
  Menus.ShortCutToKey(ShortCut, LKey, LShift);
  Key := Menus.ShortCutToText(Menus.ShortCut(LKey, []));

  if ShortCut = 0 then begin
    Text := ShortcutText;
    Modifier := ShortcutText;
  end
  else begin
    Text := Menus.ShortCutToText(ShortCut);
    //Text := StringReplace(Text, '+', ' + ', [rfReplaceAll]);

    //keyStr := Menus.ShortCutToText(Menus.ShortCut(Key, []));
    //shiftStr := LeftStr(Text, Length(Text) - Length(keyStr) - 1);
    //Text := shiftStr + IfThen(shiftStr = '', '', ' + ') + keyStr;

    Modifier := LeftStr(Text, Length(Text) - Length(Key) - 1); //- 3
  end;
end;

procedure TSCutRec.Init;
begin
  ShortCut := 0;
  ShortcutText := '';
  Key := '';
  Modifier := '';
  Text := '';
end;



{ TSCRec }

function TSCRec.TextAlt(const Text, Alt: string): string;
begin
  if Alt = '' then Exit(Result);
  Result := Text + IfThen(Text = '', '', ' (') + Alt + IfThen(Text = '', '', ')');
end;

function TSCRec.Category: string;
var
  mText, text: string;
  mItem: TMenuItem;
begin
  Result := '';
  if Assigned(Action) then begin
    text := Action.Category;
    Result := TextAlt(Result, text + IfThen(text = '', '', ' /'));
  end;
  if Assigned(Menu) then begin
    mText := '';
    mItem := Menu.Parent;
    while Assigned(mItem) and Assigned(mItem.Parent) do begin
      text := Menus.StripHotkey(mItem.Caption); //StringReplace(mItem.Caption, Menus.cHotkeyPrefix, '', [rfReplaceAll]);
      mText := text + IfThen(mText = '', '', ' | ') + mText;
      mItem := mItem.Parent;
    end;
    Result := TextAlt(Result, mText + IfThen((mText = '') or Assigned(Action), '', ' |'));

    //if (Menu.Action is TContainedAction) and (Action <> Menu.Action) then
    //  Result := TextAlt(Result, TContainedAction(Menu.Action).Category);
  end;
end;

function TSCRec.Caption: string;
var act, mnu: string;
begin
  Result := '';
  act := '';
  if Assigned(Action) then begin
    act := Menus.StripHotkey(Action.Caption);
    Result := TextAlt(Result, act);
  end;
  if Assigned(Menu) then begin
    mnu := Menus.StripHotkey(Menu.Caption);
    if act = mnu then mnu := '';
    Result := TextAlt(Result, mnu);
    //if (Menu.Action is TContainedAction) and (Action <> Menu.Action) then
    //  Result := TextAlt(Result, Menus.StripHotkey(TContainedAction(Menu.Action).Caption));
  end;
end;

function TSCRec.Name(Index: Integer = 0): string;
begin
  Result := '';
  if Assigned(Action) then
    Result := TextAlt(Result, Action.Name);
  if Assigned(Menu) then begin
    Result := TextAlt(Result, Menu.Name);
    if Assigned(Menu.Action) and (Action <> Menu.Action) then
      Result := TextAlt(Result, Menu.Action.Name);
  end;
  if Assigned(Action) and (Index > 0) then
    Result := Result + ' [' + IntToStr(Index) + ']';
end;

procedure TSCRec.InitShortcuts(Count: Integer = -1);
var cnt, idx: Integer;
begin
  cnt := 0;
  if Count >= 0 then begin
    for idx := Count to High(Shortcuts) do Shortcuts[idx].Init;
    cnt := Length(Shortcuts);
  end;
  SetLength(Shortcuts, Count);
  for idx := cnt to High(Shortcuts) do Shortcuts[idx].Init;
end;

procedure TSCRec.Init;
begin
  SetLength(Shortcuts, 0);
  Action := nil;
  Menu := nil;
  MenuFrm := nil;
end;

class procedure TSCRec.ItemsInit(Count: Integer = -1);
var cnt, idx: Integer;
begin
  cnt := 0;
  if Count >= 0 then begin
    for idx := Count to High(Items) do Items[idx].Init;
    cnt := Length(Items);
  end;
  SetLength(Items, Count);
  for idx := cnt to High(Items) do Items[idx].Init;
end;

class procedure TSCRec.ItemsFill(MenuIde, MenuFrm: TMenuItem; OnClick: TNotifyEvent; OnDraw: TAdvancedMenuDrawItemEvent = nil);
var
  actionList: TContainedActionList;
  actions: TList;
  idx: Integer;
begin
  TSCRec.ItemsInit(0);

  actionList := GxActionBroker.GetActions(0).ActionList;

  actions := TList.Create;
  try
    for idx := 0 to actionList.ActionCount - 1 do
      actions.Add(actionList.Actions[idx]);

    TSCRec.ItemsInit(Actions.Count);
    for idx := 0 to Actions.Count - 1 do
      TSCRec.ItemsFillAction(TContainedAction(Actions[idx]), idx);

    TSCRec.ItemsFillMenu(MenuIde, MenuFrm, actions, OnClick, OnDraw);
  finally
    actions.Free;
  end;
end;

class procedure TSCRec.ItemsFillAction(Action: TContainedAction; Index: Integer);
var
  LShortCut: TShortCut;
  sdx: Integer;
  str: string;
begin
  TSCRec.Items[Index].InitShortcuts(Action.SecondaryShortCuts.Count + 1);
  for sdx := 0 to Action.SecondaryShortCuts.Count do begin // Count + 1
    if sdx = 0 then
      LShortCut := Action.ShortCut
    else begin
      LShortCut := Action.SecondaryShortCuts.ShortCuts[sdx - 1];
      {$IFOPT D+} if LShortCut <> 0 then SendDebugFmt('SecondaryShortCuts[%d] of %s[%d] = %d', [sdx - 1, Action.Name, Index, LShortCut]); {$ENDIF}
      if LShortCut = 0 then begin // try Action.SecondaryShortCuts.Strings
        str := Action.SecondaryShortCuts.Strings[sdx - 1];
        {$IFOPT D+} SendDebugFmt('SecondaryShortCuts[%d] of %s[%d] = "%s"', [sdx - 1, Action.Name, Index, str]); {$ENDIF}
        if str = cIDEActionShortcutSecondary then str := cIDEActionShortcutSecondaryFix;
        LShortCut := Menus.TextToShortCut(str);
        TSCRec.Items[Index].Shortcuts[sdx].ShortcutText := str;
      end;
    end;
    TSCRec.Items[Index].Shortcuts[sdx].SetShortCut(LShortCut);
  end;

  TSCRec.Items[Index].Action := Action;
end;

class procedure TSCRec.ItemsFillMenu(MenuIde, MenuFrm: TMenuItem; Actions: TList; OnClick: TNotifyEvent; OnDraw: TAdvancedMenuDrawItemEvent = nil);
var
  idx, mdx: Integer;
  mMenu: TMenu;
  item: TMenuItem;
begin
  MenuFrm.Caption := MenuIde.Caption;
  MenuFrm.ShortCut := MenuIde.ShortCut;
  MenuFrm.AutoHotkeys := MenuIde.AutoHotkeys;
  MenuFrm.AutoLineReduction := MenuIde.AutoLineReduction;
  MenuFrm.ImageIndex := MenuIde.ImageIndex;
  MenuFrm.ImageName := MenuIde.ImageName;
  MenuFrm.OnClick := OnClick; //MenuIde.OnClick;
  MenuFrm.OnAdvancedDrawItem := OnDraw; //MenuIde.OnAdvancedDrawItem;

  if Assigned(MenuIde.Parent) and (MenuIde.Caption <> Menus.cLineCaption) then begin
    idx := Actions.IndexOf(MenuIde.Action);
    if idx < 0 then begin
      idx := Length(TSCRec.Items);
      TSCRec.ItemsInit(idx + 1);
    end;
    ItemsFillMenuItem(MenuIde, MenuFrm, idx);
  end;

  mMenu := MenuFrm.GetParentMenu;
  for mdx := 0 to MenuIde.Count - 1 do begin
    if (MenuIde.Name = cIDEMenuFileOpenRecentItem) and (MenuIde.Items[mdx].Name = '') then Continue;
    item := TMenuItem.Create(mMenu);
    MenuFrm.Add(item);
    TSCRec.ItemsFillMenu(MenuIde.Items[mdx], item, Actions, OnClick, OnDraw);
  end;
end;

class procedure TSCRec.ItemsFillMenuItem(MenuIde, MenuFrm: TMenuItem; Index: Integer);
var
  keyStr: string;
  sdx: Integer;
begin
  TSCRec.Items[Index].Menu := MenuIde;
  TSCRec.Items[Index].MenuFrm := MenuFrm;

  if Assigned(MenuIde.Parent) and not Assigned(MenuIde.Parent.Parent) then begin
    keyStr := Menus.GetHotKey(MenuIde.Caption).ToUpper;
    if keyStr <> '' then begin
      sdx := Length(TSCRec.Items[Index].Shortcuts);
      TSCRec.Items[Index].InitShortcuts(sdx + 1);
      TSCRec.Items[Index].Shortcuts[sdx].SetShortCut(Menus.ShortCut(Word(keyStr[1]), [ssAlt]));
    end;
  end;

  if Length(TSCRec.Items[Index].Shortcuts) = 0 then TSCRec.Items[Index].InitShortcuts(1);
end;



{ TKeyboardShortcutsExpert }

class function TKeyboardShortcutsExpert.GetName: string;
begin
  Result := RightStr(ClassName, Length(ClassName) - 1); // new name? old settings should be deleted?
end;

procedure TKeyboardShortcutsExpert.Execute(Sender: TObject);
begin
  TfmGxKeyboardShortcuts.Execute(GetBitmap);
end;

function TKeyboardShortcutsExpert.CanHaveShortCut: Boolean;
begin
  Result := False;
end;

constructor TKeyboardShortcutsExpert.Create;
begin
  inherited Create;
end;

destructor TKeyboardShortcutsExpert.Destroy;
begin
  FreeAndNil(UfmGxKeyboardShortcuts);
  inherited Destroy;
end;

function TKeyboardShortcutsExpert.GetActionCaption: string;
begin
  Result := SExpertCaption;
end;

function TKeyboardShortcutsExpert.GetHelpString: string;
begin
  Result := SExpertDescription;
end;

function TKeyboardShortcutsExpert.HasConfigOptions: Boolean;
begin
  Result := False;
end;



{ TfmGxKeyboardShortcuts }

class procedure TfmGxKeyboardShortcuts.Execute(_bmp: TBitmap);
var
  frm: TfmGxKeyboardShortcuts;
  isNew: Boolean;
begin
  isNew := not Assigned(UfmGxKeyboardShortcuts);
  if not isNew then
    frm := UfmGxKeyboardShortcuts
  else begin
    frm := TfmGxKeyboardShortcuts.Create(nil);
    ConvertBitmapToIcon(_bmp, frm.Icon);
  end;

  if frm.WindowState = wsMinimized then
    frm.WindowState := wsNormal;
  frm.Show;
end;

procedure TfmGxKeyboardShortcuts.FormClose(Sender: TObject; var Action: TCloseAction);
var
  Settings: IExpertSettings;
begin
  Action := caFree;
  // Do not localize any of the following lines.
  Settings := ConfigInfo.GetExpertSettings(ConfigurationKey);
  SaveSettings(Settings);
  Settings.SaveForm('Window', Self);
end;

function TfmGxKeyboardShortcuts.ScrollGrid(Grid: TDrawGrid; Direction: Integer; Shift: TShiftState): Boolean;
var
  scroll: Integer;
  topRow: Integer;
begin
  Result := True;
  scroll := 1;
  if not (ssShift in Shift) then scroll := scroll * 3;
  if ssCtrl in Shift then scroll := scroll * 3;
  topRow := Grid.TopRow + scroll * Direction;
  topRow := Max(topRow, cRowsFixed);
  topRow := Min(topRow, Grid.RowCount - Grid.VisibleRowCount);
  Grid.TopRow := topRow;
  //Grid.Row := Grid.TopRow + IfThen(Direction < 0, 0, Grid.VisibleRowCount - 1);
end;

function TfmGxKeyboardShortcuts.ConfigurationKey: string;
begin
  Result := TKeyboardShortcutsExpert.ConfigurationKey;
end;

constructor TfmGxKeyboardShortcuts.Create(_Owner: TComponent);
var
  idx: Integer;
  Settings: IExpertSettings;
  menuIde: TMenu;
  colWidths: Boolean;
  popup: TMenuItem;
begin
  inherited;
  menuIde := GxOtaGetIdeMainMenu;
  Menu := TMainMenu.Create(Self);
  Menu.AutoHotkeys := menuIde.AutoHotkeys;
  Menu.AutoLineReduction := menuIde.AutoLineReduction;
  Menu.BiDiMode := menuIde.BiDiMode;
  Menu.Images := menuIde.Images;
  Menu.OwnerDraw := True; //menuIde.OwnerDraw;
  TSCRec.ItemsFill(menuIde.Items, Menu.Items, MenuOnClick, MenuOnAdvancedDrawItem);

  UfmGxKeyboardShortcuts := Self;

  Grid.PopupMenu := TPopupMenu.Create(Self);
  for idx := 0 to cpmLast do begin
    popup := TMenuItem.Create(Self);
    Grid.PopupMenu.Items.Add(popup);
    popup.Caption := cpmArray[idx, cpmCaption];
    popup.Checked := cpmArray[idx, cpmDefault] = 'True';
    popup.Tag := idx;
    popup.OnClick := PopupOnClick;
  end;

  Grid.ColCount := colsCount;
  SetLength(FColsIdx, colsCount);
  for idx := Low(FColsIdx) to High(FColsIdx) do FColsIdx[idx] := idx;
  FSortCols := TStringList.Create;

  TControl_SetMinConstraints(Self);
  Settings := ConfigInfo.GetExpertSettings(ConfigurationKey);
  Settings.LoadForm('Window', Self);
  LoadSettings(Settings, colWidths);

  PopupExecute(True, Grid.PopupMenu.Items[cpmSTaskBar]);
  PopupExecute(True, Grid.PopupMenu.Items[cpmSOnTop]);

  Caption := Menus.StripHotkey(SExpertCaption);
  DefaultMonitor := dmDesktop;
  Position := poDesigned;
  BorderIcons := BorderIcons + [biMinimize];
  //BorderStyle := bsSizeToolWin;
  KeyPreview := True;
  OnKeyDown := FormOnKeyDown;

  Grid.OnMouseMove := GridOnMouseMove;
  //Grid.OnFixedCellClick := GridOnFixedCellClick; // not available with goColMoving in TStringGrid.Options
  Grid.OnClick := GridOnClick;
  Grid.OnDblClick := GridOnDblClick;
  Grid.OnColumnMoved := GridOnColumnMoved;
  Grid.OnContextPopup := GridOnContextPopup;

  Grid.BeginUpdate;
  try
    Grid.Options := Grid.Options - [goRowSelect] +
      [goDrawFocusSelected, goColMoving, goTabs, goThumbTracking, goFixedColClick, goFixedRowClick, goFixedHotTrack];
    Grid.FixedRows := cRowsFixed;
    GridFill;
    TStringGrid_AdjustRowHeight(Grid);
    if not colWidths then begin
      Grid.ColWidths[colModifier] := 75;
      TGrid_Resize(Grid, [roUseGridWidth, roUseAllRows, roReduceMinWidth], [colModifier, colSCutKey]);
    end;
  finally
    Grid.EndUpdate;
  end;

  InitDpiScaler;
end;

destructor TfmGxKeyboardShortcuts.Destroy;
begin
  UfmGxKeyboardShortcuts := nil;
  TSCRec.ItemsInit(0);
  FSortCols.Free;
  SetLength(FColsIdx, 0);
  inherited;
end;

{$IFDEF GX_IDE_IS_HIDPI_AWARE}
procedure TfmGxKeyboardShortcuts.ApplyDpi(_NewDpi: Integer; _NewBounds: PRect);
begin
  if FOldDPI = 0 then
    FOldDPI := TForm_CurrentPPI(Self);
  if Assigned(FScaler) then
    FScaler.ApplyDpi(_NewDpi, _NewBounds);
  TStringGrid_AdjustRowHeight(Grid);
end;
{$ENDIF}

function TfmGxKeyboardShortcuts.SortCompareEntries(_Idx1, _Idx2: Integer): Integer;
var
  sortIdx, col, i1, i2: Integer;
  sortDir: TObject;
  colName, s1, s2: string;
begin
  Result := 0;

  for sortIdx := 0 to FSortCols.Count - 1 do begin
    sortDir := FSortCols.Objects[sortIdx];
    if cObjNil = sortDir then Continue;

    colName := FSortCols[sortIdx];
    if not TryStrToInt(colName, col) or not TGrid_IsCell(Grid, col) then Continue;
    s1 := Grid.Cells[col, _Idx1];
    s2 := Grid.Cells[col, _Idx2];

    Result := CompareText(s1, s2);
    if cObjSortDesc = sortDir then Result := -Result;

    if Result <> 0 then begin // empty after not empty
      if s1 = '' then Result := 1;
      if s2 = '' then Result := -1;
    end;

    if Result <> 0 then Break;
  end;

  if Result = 0 then begin // by order of TSCRec.Items
    i1 := NativeInt(Grid.Objects[FColsIdx[colObjItemIndex], _Idx1]);
    i2 := NativeInt(Grid.Objects[FColsIdx[colObjItemIndex], _Idx2]);
    Result := CompareValue(i1, i2);
  end;
  if Result = 0 then begin
    i1 := NativeInt(Grid.Objects[FColsIdx[colObjSCutIndex], _Idx1]);
    i2 := NativeInt(Grid.Objects[FColsIdx[colObjSCutIndex], _Idx2]);
    Result := CompareValue(i1, i2);
  end;

  if Result = 0 then // by current order
    Result := CompareValue(_Idx1, _Idx2);
end;

procedure TfmGxKeyboardShortcuts.SortSwapEntries(_Idx1, _Idx2: Integer);
var
  col: Integer;
  str: string;
  obj: TObject;
begin
  for col := 0 to colsCount - 1 do begin
    str := Grid.Cells[col, _Idx1];
    Grid.Cells[col, _Idx1] := Grid.Cells[col, _Idx2];
    Grid.Cells[col, _Idx2] := str;
    obj := Grid.Objects[col, _Idx1];
    Grid.Objects[col, _Idx1] := Grid.Objects[col, _Idx2];
    Grid.Objects[col, _Idx2] := obj;
  end;
end;

procedure TfmGxKeyboardShortcuts.GridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  if ARow < cRowsFixed then begin
    //Grid.Canvas.Brush.Color := clMenu;
    //Grid.Canvas.Font.Style := Grid.Canvas.Font.Style + [fsBold];
    Exit; // we have goFixedHotTrack in TStringGrid.Options
  end;

  if (ACol in [FColsIdx[colModifier], FColsIdx[colSCutKey]]) and
     (cObjDuplicate = Grid.Objects[FColsIdx[colObjDuplicate], ARow]) then begin
    Grid.Canvas.Brush.Color := clYellow;
    Grid.Canvas.Font.Color := clBlack;
  end;
  if (ACol in [FColsIdx[colCompName]]) and
     (cObjDuplicate = Grid.Objects[FColsIdx[colObjComponent], ARow]) then begin
    Grid.Canvas.Brush.Color := clYellow;
    Grid.Canvas.Font.Color := clBlack;
  end;

  TStringGrid_DrawCellFixed(Grid, Grid.Cells[ACol, ARow], Rect, State, True); //sg.Focused);
end;

procedure TfmGxKeyboardShortcuts.GridMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var col, row: Integer;
begin
  //{$IFOPT D+} SendDebug(ClassName + '.GridMouseUp'); {$ENDIF}
  if FSkipMouseUpAfterColumnMoved then begin
    FSkipMouseUpAfterColumnMoved := False;
    Exit;
  end;
  if (Button <> mbLeft) or not TGrid_MouseToFixed(Grid, X, Y, col, row) then Exit;
  GridOnMouseMove(Sender, Shift, X, Y);
  if Grid.Cursor <> cursorFixed then Exit;
  GridOnFixedCellClick(nil, col, row);
end;

procedure TfmGxKeyboardShortcuts.GridMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Handled := ScrollGrid(Grid, +1, Shift);
end;

procedure TfmGxKeyboardShortcuts.GridMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Handled := ScrollGrid(Grid, -1, Shift);
end;

procedure TfmGxKeyboardShortcuts.GridOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  col, row: Integer;
  cell: TRect;
  cur: TCursor;
begin
  cur := crDefault;
  if TGrid_MouseToFixed(Grid, X, Y, col, row) then begin
    cell := Grid.CellRect(col, row);
    if (X - cell.Left > 10) and (cell.Right - X > 10) then
      cur := cursorFixed;
  end;
  Grid.Cursor := cur;
end;

procedure TfmGxKeyboardShortcuts.GridOnFixedCellClick(Sender: TObject; ACol, ARow: Longint);
// OnFixedCellClick is not available with goColMoving in TStringGrid.Options
var
  colName: string;
  sortIdx: Integer;
  Shift: TShiftState;
begin
  //{$IFOPT D+} SendDebug(ClassName + '.GridOnFixedCellClick SortCols: ' + FSortCols.Text); {$ENDIF}
  //{$IFOPT D+} SendDebugFmt('%s.GridOnFixedCellClick ColsIdx: %d %d %d %d %d', [ClassName, FColsIdx[0], FColsIdx[1], FColsIdx[2], FColsIdx[3], FColsIdx[4]]); {$ENDIF}
  Shift := GetModifierKeyState;
  colName := IntToStr(ACol);
  sortIdx := FSortCols.IndexOf(colName);

  if (sortIdx < 0) and (Shift = [ssShift]) then
    FSortCols.AddObject(colName, cObjSortAsc)
  else if (sortIdx < 0) and (Shift = []) then
    FSortCols.InsertObject(0, colName, cObjSortAsc)
  else if (sortIdx > 0) and (Shift = []) then begin
    FSortCols.Delete(sortIdx);
    FSortCols.InsertObject(0, colName, cObjSortAsc);
  end
  else if (sortIdx >= 0) and (Shift = [ssShift]) then
    if sortIdx < FSortCols.Count - 1 then
      FSortCols.Exchange(sortIdx, sortIdx + 1)
    else
      FSortCols.Delete(sortIdx)
  else if (sortIdx > 0) and (Shift = [ssCtrl]) then
    FSortCols.Exchange(sortIdx, sortIdx - 1)
  else if ( (sortIdx = 0) and (Shift <> [ssShift]) ) or
          ( (sortIdx > 0) and (Shift <> [ssShift]) and (Shift <> [ssCtrl]) ) then
    if cObjSortAsc = FSortCols.Objects[sortIdx] then FSortCols.Objects[sortIdx] := cObjSortDesc
    else if cObjSortDesc = FSortCols.Objects[sortIdx] then FSortCols.Objects[sortIdx] := cObjNil
    else FSortCols.Objects[sortIdx] := cObjSortAsc
  else
    Exit;

  while (FSortCols.Count > 0) and (cObjNil = FSortCols.Objects[FSortCols.Count - 1]) do
    FSortCols.Delete(FSortCols.Count - 1);

  GridSort;
end;

procedure TfmGxKeyboardShortcuts.GridOnColumnMoved(Sender: TObject; FromIndex, ToIndex: Longint);
var idxFr, idxTo: Integer;
begin
  //{$IFOPT D+} SendDebug(ClassName + '.GridOnColumnMoved'); {$ENDIF}
  FSkipMouseUpAfterColumnMoved := True;
  FColsIdx[FromIndex] := ToIndex;
  FColsIdx[ToIndex] := FromIndex;
  idxFr := FSortCols.IndexOf(IntToStr(FromIndex));
  idxTo := FSortCols.IndexOf(IntToStr(ToIndex));
  if idxFr >= 0 then FSortCols[idxFr] := IntToStr(ToIndex);
  if idxTo >= 0 then FSortCols[idxTo] := IntToStr(FromIndex);
  //GridSort; // test
end;

procedure TfmGxKeyboardShortcuts.GridOnDblClick(Sender: TObject);
var
  col, row: Integer;
//  input: TInput;
begin
  if not TGrid_MouseToFixed(Grid, col, row, False) then Exit;

  {$IFOPT D+} SendDebug(ClassName + '.GridOnDblClick: ' + Grid.Cells[col, row]); {$ENDIF} //?!?
//  var sdx := NativeInt(Grid.Objects[FColsIdx[colObjSCutIndex], row]);
//  TSCRec.Items[idx].Shortcuts[sdx]

//? something is wrong here
//  var idx := NativeInt(Grid.Objects[FColsIdx[colObjItemIndex], row]);
//  if Assigned(TSCRec.Items[idx].Menu) then
//    Menu.Items[0].Click; //? open, expand, dropdown
//
//  input.Itype := INPUT_KEYBOARD;
//  input.ki.time := 0;
//  input.ki.dwExtraInfo := 0;
//  input.ki.wScan := 0;
//
//  input.ki.wVk := VK_F10;
//  //input.ki.wScan := $c4;
//  input.ki.dwFlags := 0;
//  SendInput(1, input, SizeOf(input));
//
//  input.ki.wVk := VK_F10;
//  //input.ki.wScan := $c4;
//  input.ki.dwFlags := KEYEVENTF_KEYUP;
//  SendInput(1, input, SizeOf(input));
//
//  input.ki.wVk := VK_MENU;
//  //input.ki.wScan := $b8;
//  input.ki.dwFlags := 0;
//  SendInput(1, input, SizeOf(input));
//
//  input.ki.wVk := Word('F');
//  //input.ki.wScan := $a1;
//  input.ki.dwFlags := 0;
//  SendInput(1, input, SizeOf(input));
//
//  input.ki.wVk := Word('F');
//  //input.ki.wScan := $a1;
//  input.ki.dwFlags := KEYEVENTF_KEYUP;
//  SendInput(1, input, SizeOf(input));
//
//  input.ki.wVk := VK_MENU;
//  //input.ki.wScan := $b8;
//  input.ki.dwFlags := KEYEVENTF_KEYUP;
//  SendInput(1, input, SizeOf(input));
//
//  keybd_event(VK_F10, $c4, 0, 0);
//  keybd_event(VK_F10, $c4, KEYEVENTF_KEYUP, 0);
//  keybd_event(VK_MENU, $b8, 0, 0);
//  keybd_event(Word('F'), $a1, 0, 0);
//  keybd_event(Word('F'), $a1, KEYEVENTF_KEYUP,0);
//  keybd_event(VK_MENU, $b8, KEYEVENTF_KEYUP, 0);
end;

procedure TfmGxKeyboardShortcuts.GridOnClick(Sender: TObject);
begin
  {$IFOPT D+} SendDebug(ClassName + '.GridOnClick'); {$ENDIF} //?!?
end;

procedure TfmGxKeyboardShortcuts.GridSort;
var
  col, sortIdx: Integer;
  colName, sortSuff: string;
begin
  Grid.BeginUpdate;
  try
    for col := 0 to colsCount - 1 do begin
      colName := IntToStr(col);
      sortIdx := FSortCols.IndexOf(colName);
      sortSuff := '';
      if sortIdx >= 0 then begin
        sortSuff := '  ' + IntToStr(sortIdx + 1);
        if cObjSortAsc = FSortCols.Objects[sortIdx] then sortSuff := sortSuff + '^'        // arrow variants: ↑ ▲ ⬆ △ ^
        else if cObjSortDesc = FSortCols.Objects[sortIdx] then sortSuff := sortSuff + '∨'; // arrow variants: ↓ ▼ ⬇ ▽ v ∨
      end;
      Grid.Cells[col, cRowTitle] := colsTitle[FColsIdx[col]] + sortSuff;
    end;

    QuickSort(cRowsFixed, Grid.RowCount - 1, SortCompareEntries, SortSwapEntries);
  finally
    Grid.EndUpdate;
  end;
end;

procedure TfmGxKeyboardShortcuts.GridFill;
var
  row, idx, sdx: Integer;
  sortCols: TStringList;
begin
  Grid.BeginUpdate;
  try
    row := cRowsFixed - 1;
    TGrid_SetNonfixedRowCount(Grid, High(TSCRec.Items) + 1);
    for idx := Low(TSCRec.Items) to High(TSCRec.Items) do
      for sdx := Low(TSCRec.Items[idx].Shortcuts) to High(TSCRec.Items[idx].Shortcuts) do begin
        if (sdx > 0) and not Grid.PopupMenu.Items[cpmFSecondary].Checked then Continue;
        if Assigned(TSCRec.Items[idx].Action) and Grid.PopupMenu.Items[cpmFActions].Checked then
        else if Assigned(TSCRec.Items[idx].Menu) and Grid.PopupMenu.Items[cpmFMenu].Checked then
        else Continue;
        if (TSCRec.Items[idx].Name(0) = '') and not Grid.PopupMenu.Items[cpmFNoName].Checked then Continue;

        Inc(row);
        if row > High(TSCRec.Items) + 1 then TGrid_SetNonfixedRowCount(Grid, row);
        Grid.Objects[FColsIdx[colObjItemIndex], row] := TObject(idx);
        Grid.Objects[FColsIdx[colObjSCutIndex], row] := TObject(sdx);
        if sdx > 0 then begin // secondary shortcuts
          Grid.Objects[FColsIdx[colObjComponent], row - 1] := cObjDuplicate;
          Grid.Objects[FColsIdx[colObjComponent], row    ] := cObjDuplicate;
        end;
        Grid.Cells[FColsIdx[colModifier], row] := TSCRec.Items[idx].Shortcuts[sdx].Modifier;
        Grid.Cells[FColsIdx[colSCutKey ], row] := TSCRec.Items[idx].Shortcuts[sdx].Key;
        Grid.Cells[FColsIdx[colCategory], row] := TSCRec.Items[idx].Category;
        Grid.Cells[FColsIdx[colCaption ], row] := TSCRec.Items[idx].Caption;
        Grid.Cells[FColsIdx[colCompName], row] := TSCRec.Items[idx].Name(sdx); // secondary shortcuts
      end;
    if row = 0 then begin
      row := 1;
      for idx := 0 to colsCount - 1 do Grid.Cells[idx, row] := '';
    end;
    if row < Grid.RowCount - 1 then TGrid_SetNonfixedRowCount(Grid, row);

    sortCols := FSortCols;
    FSortCols := TStringList.Create;
    try // duplicate shortcuts
      FSortCols.AddObject('0', cObjSortAsc);
      FSortCols.AddObject('1', cObjSortAsc);
      GridSort;
      for row := cRowsFixed + 1 to Grid.RowCount - 1 do begin
        if Grid.Cells[FColsIdx[colModifier], row] + Grid.Cells[FColsIdx[colSCutKey ], row] = '' then Continue;
        if Grid.Cells[FColsIdx[colModifier], row - 1] <> Grid.Cells[FColsIdx[colModifier], row] then Continue;
        if Grid.Cells[FColsIdx[colSCutKey ], row - 1] <> Grid.Cells[FColsIdx[colSCutKey ], row] then Continue;
        Grid.Objects[FColsIdx[colObjDuplicate], row - 1] := cObjDuplicate;
        Grid.Objects[FColsIdx[colObjDuplicate], row    ] := cObjDuplicate;
      end;
    finally
      FSortCols.Free;
      FSortCols := sortCols;
    end;
    GridSort;
  finally
    Grid.EndUpdate;
  end;
end;

procedure TfmGxKeyboardShortcuts.GridOnContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
var
  col, row: Integer;
  isCell, isFixed: Boolean;
begin
  isCell := TGrid_MouseToCell(Grid, MousePos.X, MousePos.Y, col, row);
  isFixed := isCell and TGrid_IsFixed(Grid, col, row);
  Grid.PopupMenu.Items[cpmATest1].Enabled := isCell and isFixed; //?!?
  Grid.PopupMenu.Items[cpmATest2].Enabled := isCell and not isFixed; //?!?
end;

procedure TfmGxKeyboardShortcuts.PopupOnClick(Sender: TObject);
begin
  PopupExecute(False, Sender);
end;

procedure TfmGxKeyboardShortcuts.PopupExecute(IsInit: Boolean; Sender: TObject);
var mItem: TMenuItem absolute Sender;
begin
  if cpmArray[mItem.Tag, cpmSetting] <> '' then begin
    if not IsInit then mItem.Checked := not mItem.Checked;

    if mItem.Tag in [cpmFActions, cpmFMenu, cpmFNoName, cpmFSecondary] then
      GridFill
    else if mItem.Tag = cpmSTaskBar then
      ShowInTaskBar := Grid.PopupMenu.Items[cpmSTaskBar].Checked
    else if mItem.Tag = cpmSOnTop then
      if Grid.PopupMenu.Items[cpmSOnTop].Checked then
        FormStyle := fsStayOnTop
      else
        FormStyle := fsNormal
  end
  else begin
    if mItem.Tag = cpmATest1 then ShowMessage(mItem.Caption) //?!?
    else if mItem.Tag = cpmATest2 then ShowMessage(mItem.Caption); //?!?
  end;
end;

procedure TfmGxKeyboardShortcuts.LoadSettings(Settings: IExpertSettings; var ColWidths: Boolean);
var
  idx, col, sortIdx, sortDir: Integer;
  colName: string;
begin
  if not Assigned(Settings) then Settings := TKeyboardShortcutsExpert.GetSettings;

  FSortCols.Text := Settings.ReadString(Format('Grid.SortColumns', [col]), FSortCols.Text);
  ColWidths := False;
  for col := 0 to colsCount - 1 do begin
    ColWidths := ColWidths or Settings.ValueExists(Format('Grid.Columns[%d].Width', [col]));
    Grid.ColWidths[col] := Settings.ReadInteger(Format('Grid.Columns[%d].Width', [col]), Grid.ColWidths[col]);
    FColsIdx[col] := Settings.ReadInteger(Format('Grid.Columns[%d].Index', [col]), FColsIdx[col]);

    colName := IntToStr(col);
    sortIdx := FSortCols.IndexOf(colName);
    if sortIdx < 0 then Continue;
    sortDir := NativeInt(FSortCols.Objects[sortIdx]);
    sortDir := Settings.ReadInteger(Format('Grid.Columns[%d].Sort', [col]), sortDir);
    if (TObject(sortDir) = cObjNil) or (TObject(sortDir) = cObjSortAsc) or (TObject(sortDir) = cObjSortDesc) then
      FSortCols.Objects[sortIdx] := TObject(sortDir);
  end;

  for idx := 0 to cpmLast do begin
    if cpmArray[idx, cpmSetting] = '' then Continue;
    Grid.PopupMenu.Items[idx].Checked := Settings.ReadBool(cpmArray[idx, cpmSetting], Grid.PopupMenu.Items[idx].Checked);
  end;
end;

procedure TfmGxKeyboardShortcuts.SaveSettings(Settings: IExpertSettings);
var
  idx, col, sortIdx, sortDir: Integer;
  colName: string;
  mItem: TMenuItem;
begin
  if not Assigned(Settings) then Settings := TKeyboardShortcutsExpert.GetSettings;

  Settings.WriteString(Format('Grid.SortColumns', [col]), FSortCols.Text);
  for col := 0 to colsCount - 1 do begin
    Settings.WriteInteger(Format('Grid.Columns[%d].Width', [col]), Grid.ColWidths[col]);
    Settings.WriteInteger(Format('Grid.Columns[%d].Index', [col]), FColsIdx[col]);

    colName := IntToStr(col);
    sortIdx := FSortCols.IndexOf(colName);
    if sortIdx < 0 then Continue;
    sortDir := NativeInt(FSortCols.Objects[sortIdx]);
    Settings.WriteInteger(Format('Grid.Columns[%d].Sort', [col]), sortDir);
  end;

  for idx := 0 to cpmLast do begin
    if cpmArray[idx, cpmSetting] = '' then Continue;
    Settings.WriteBool(cpmArray[idx, cpmSetting], Grid.PopupMenu.Items[idx].Checked);
  end;
end;

procedure TfmGxKeyboardShortcuts.MenuOnClick(Sender: TObject);
var
  mItem: TMenuItem absolute Sender;
  Shift: TShiftState;
  row, idx: Integer;
begin
  Shift := GetModifierKeyState;
  if (mItem.Count > 0) and (Shift = []) then Exit;

  for row := cRowsFixed + 1 to Grid.RowCount - 1 do begin
    idx := NativeInt(Grid.Objects[FColsIdx[colObjItemIndex], row]);
    if TSCRec.Items[idx].MenuFrm <> Sender then Continue;
    Grid.Row := row;
    Break;
  end;
end;

procedure TfmGxKeyboardShortcuts.MenuOnAdvancedDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; State: TOwnerDrawState);
var
  mItem: TMenuItem absolute Sender;
  event: TAdvancedMenuDrawItemEvent;
  mRect: TRect;
  mTop: Boolean;
begin
  event := mItem.OnAdvancedDrawItem;
  try
    mItem.OnAdvancedDrawItem := nil;
    mRect := Rect(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom - 3);
    mTop := mItem.GetParentComponent is TMainMenu;
    TMenuItem_Protected(mItem).AdvancedDrawItem(ACanvas, mRect, State, mTop);
    ACanvas.Brush.Color := clMenuBar;
    ACanvas.FillRect(Rect(ARect.Left, ARect.Top - 2, ARect.Right, ARect.Top - 1));
    ACanvas.FillRect(Rect(ARect.Left, ARect.Bottom - 2, ARect.Right, ARect.Bottom - 1));
  finally
    mItem.OnAdvancedDrawItem := event;
  end;
end;

procedure TfmGxKeyboardShortcuts.FormOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) and (Shift = []) then begin
    Key := 0;
    Close;
  end;
end;




initialization
  RegisterGX_Expert(TKeyboardShortcutsExpert);

end.
