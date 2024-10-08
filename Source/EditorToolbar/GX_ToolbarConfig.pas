unit GX_ToolbarConfig;

{$I GX_CondDefine.inc}

interface

uses
  Classes, Windows, Controls, Forms,
  StdCtrls, ExtCtrls, ComCtrls, ActnList, Buttons, Actions,
  GX_BaseForm;

type
  TfmToolbarConfig = class(TfmBaseForm)
    Actions: TActionList;
    actAddButton: TAction;
    actRemoveButton: TAction;
    actAddSeparator: TAction;
    actMoveDown: TAction;
    actMoveUp: TAction;
    pnlButtons: TPanel;
    pnlContent: TPanel;
    pnlButtonsRight: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    pnlCategories: TPanel;
    pnlAvailButtons: TPanel;
    pnlToolbarButtons: TPanel;
    pnlToolButtons: TPanel;
    btnDown: TBitBtn;
    btnUp: TBitBtn;
    btnRemove: TBitBtn;
    btnAdd: TBitBtn;
    pnlCatHeader: TPanel;
    pnlAvailButtonHeader: TPanel;
    pnlToolbarHeader: TPanel;
    lbCategories: TListBox;
    lbAvailable: TListBox;
    lbToolbar: TListBox;
    pnlSep: TPanel;
    btnAddSeparator: TBitBtn;
    procedure btnHelpClick(Sender: TObject);
    procedure actAddButtonExecute(Sender: TObject);
    procedure actRemoveButtonExecute(Sender: TObject);
    procedure actAddSeparatorExecute(Sender: TObject);
    procedure ActionsUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure lbCategoriesClick(Sender: TObject);
    procedure actMoveUpExecute(Sender: TObject);
    procedure actMoveDownExecute(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure ListboxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lbAvailableDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure lbAvailableDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure lbToolbarDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure lbToolbarDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure lbToolbarStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure lbToolbarKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FToolbarActionNames: TStrings;
    FSavedToolbarItemIndex: Integer;
    FTextOffset: Integer;
    procedure SetupActionListBoxes;
    procedure SetData(_Actions: TStrings);
    procedure GetData(_Actions: TStrings);
  public
    ///<sumamry>
    /// @param Actions is The list of actions names which are already present on the toolbar. </summary>
    class function Execute(_Owner: TWinControl; _Actions: TStrings): Boolean;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ShowModal: Integer; override;
  end;

implementation

{$R *.dfm}

uses
  SysUtils, Graphics, Menus, Messages, StrUtils,
  u_dzStringUtils, u_dzVclUtils,
  GX_ActionBroker, GX_GenericUtils, GX_GxUtils, GX_Toolbar;

procedure AddActionToListbox(Action: TContainedAction; Listbox: TCustomListbox; Select: Boolean);
var
  NewIndex: Integer;
begin
  if Action = nil then
    NewIndex := Listbox.Items.AddObject('[Separator]', nil)
  else if (Action is TCustomAction) and (TCustomAction(Action).Caption <> '') then
    NewIndex := Listbox.Items.AddObject(StripHotkey(TCustomAction(Action).Caption), Action)
  else
    NewIndex := Listbox.Items.AddObject(Action.Name, Action);
  if Select then
    Listbox.ItemIndex := NewIndex;
end;

class function TfmToolbarConfig.Execute(_Owner: TWinControl; _Actions: TStrings): Boolean;
var
  frm: TfmToolbarConfig;
begin
  frm := TfmToolbarConfig.Create(_Owner);
  try
    TForm_CenterOn(frm, _Owner);
    frm.SetData(_Actions);
    Result := (mrOk = frm.ShowModal);
    if Result then
      frm.GetData(_Actions);
  finally
    FreeAndNil(frm);
  end;
end;

procedure TfmToolbarConfig.SetupActionListBoxes;
var
  i: Integer;
  Action: TContainedAction;
  NoneIndex: Integer;
begin
  GxActionBroker.GetCategories(lbCategories.Items);
  Assert(lbCategories.Items.Count > 0);
  lbCategories.Sorted := True;
  NoneIndex := lbCategories.Items.IndexOf(SNoButtonCategory);
  lbCategories.Sorted := False;
  if NoneIndex >= 0 then
  begin
    lbCategories.Items.Delete(NoneIndex);
    lbCategories.Items.Add(SNoButtonCategory);
  end;
  lbCategories.Items.Add(SAllButtonsCategory);
  lbCategories.ItemIndex := 0;
  lbCategoriesClick(lbCategories);
  ActiveControl := lbCategories;
  ListboxHorizontalScrollbar(lbCategories);

  Assert(Assigned(FToolbarActionNames));
  for i := 0 to FToolbarActionNames.Count - 1 do
  begin
    Action := GxActionBroker.FindAction(FToolbarActionNames[i]);
    if Assigned(Action) then
      AddActionToListbox(Action, lbToolbar, False)
    else
      AddActionToListbox(nil, lbToolbar, False);
  end;
end;

procedure TfmToolbarConfig.SetData(_Actions: TStrings);
begin
  Assert(Assigned(FToolbarActionNames));
  FToolbarActionNames.Assign(_Actions);
end;

constructor TfmToolbarConfig.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FToolbarActionNames := TStringList.Create;

  InitDpiScaler;
end;

destructor TfmToolbarConfig.Destroy;
begin
  FreeAndNil(FToolbarActionNames);

  inherited Destroy;
end;

procedure TfmToolbarConfig.btnHelpClick(Sender: TObject);
begin
  GxContextHelp(Self, 32);
end;

procedure TfmToolbarConfig.actAddButtonExecute(Sender: TObject);
var
  i: Integer;
begin
  if lbToolbar.MultiSelect then
  begin
  for i := 0 to lbAvailable.Items.Count-1 do
    if lbAvailable.Selected[i] then
      AddActionToListbox(TContainedAction(lbAvailable.Items.Objects[i]), lbToolbar, True);
  end
  else
  begin
    if lbAvailable.ItemIndex <> -1 then
      AddActionToListbox(TContainedAction(lbAvailable.Items.Objects[lbAvailable.ItemIndex]), lbToolbar, True);
  end;
end;

procedure TfmToolbarConfig.actRemoveButtonExecute(Sender: TObject);
var
  i: Integer;
  SelIndex: Integer;
begin
  SelIndex := lbToolbar.ItemIndex;
  if lbToolbar.MultiSelect then
  begin
    for i := lbToolbar.Items.Count-1 to 0 do
      if lbToolbar.Selected[i] then
        lbToolbar.Items.Delete(i);
  end
  else
  begin
    if lbToolbar.ItemIndex <> -1 then
      lbToolbar.Items.Delete(lbToolbar.ItemIndex);
  end;
  if SelIndex <= lbToolbar.Items.Count - 1 then
    lbToolbar.ItemIndex := SelIndex
  else
    lbToolbar.ItemIndex := lbToolbar.Items.Count - 1;
end;

procedure TfmToolbarConfig.actAddSeparatorExecute(Sender: TObject);
begin
  AddActionToListbox(nil, lbToolbar, True);
end;

procedure TfmToolbarConfig.ActionsUpdate(Action: TBasicAction; var Handled: Boolean);
begin
  if lbToolbar.MultiSelect then
    actRemoveButton.Enabled := lbAvailable.SelCount > 0
  else
    actAddButton.Enabled := lbAvailable.ItemIndex <> -1;
  if lbToolbar.MultiSelect then
    actRemoveButton.Enabled := lbToolbar.SelCount > 0
  else
    actRemoveButton.Enabled := lbToolbar.ItemIndex <> -1;
  actMoveUp.Enabled := actRemoveButton.Enabled and (lbToolbar.ItemIndex <> 0);
  actMoveDown.Enabled := actRemoveButton.Enabled and (lbToolbar.ItemIndex <> lbToolbar.Items.Count - 1);
end;

procedure TfmToolbarConfig.lbCategoriesClick(Sender: TObject);
var
  i: Integer;
  Category: string;
  TheAction: TContainedAction;
  ActionName: string;
  ActionCategory: string;
begin
  lbAvailable.Items.BeginUpdate;
  try
    lbAvailable.Clear;
    if lbCategories.ItemIndex = -1 then
      Exit;
    Category := lbCategories.Items[lbCategories.ItemIndex];
    for i := 0 to GxActionBroker.GetActionCount - 1 do begin
      TheAction := GxActionBroker.GetActions(i);
      ActionName := TheAction.Name;
      if ActionName = '' then begin
        // Some actions (mainly 3d party actions) don't have a name.
        // We can't handle these, so we skip them
        Continue; //==^
      end;
      if not (TheAction is TCustomAction) then begin
        // TContainedAction does not have ImageIndex (at least in older Delphi versions)
        Continue; //==^
      end;
      if TCustomAction(TheAction).ImageIndex = -1 then begin
        // Also skip actions that don't have an icon associated with them because they
        // obviously are not meant to be shown on a tool bar.
        Continue; //==^
      end;
{$ifdef GExpertsBPL}
      if StartsStr('FileClose', ActionName) or StrContains('GExpertsBPL_MoreAction', ActionName, False) then begin
{$else GExpertsBPL}
      if StartsStr('FileClose', ActionName) or StrContains('GExpertsMoreAction', ActionName, False) then begin
{$endif GExpertsBPL}
        // Close All causes AVs, so we don't allow it.  More/Editor Experts are not useful.
        Continue; //==^
      end;
      ActionCategory := TheAction.Category;
      if Category = SAllButtonsCategory then
        AddActionToListbox(TheAction, lbAvailable, False)
      else if SameText(Category, ActionCategory) then
        AddActionToListbox(TheAction, lbAvailable, False)
      else if (Category = SNoButtonCategory) and (Trim(ActionCategory) = '') then
        AddActionToListbox(TheAction, lbAvailable, False);
    end;
    lbAvailable.Sorted := True;
  finally
    lbAvailable.Items.EndUpdate;
  end;
end;

procedure TfmToolbarConfig.GetData(_Actions: TStrings);
begin
  _Actions.Assign(FToolbarActionNames);
end;

function TfmToolbarConfig.ShowModal: Integer;
begin
  SetupActionListBoxes;
  Result := inherited ShowModal;
end;

procedure TfmToolbarConfig.actMoveUpExecute(Sender: TObject);
var
  Index: Integer;
begin
  Index := lbToolbar.ItemIndex;
  if Index = 0 then
    Exit;
  lbToolbar.Items.Exchange(Index, Index - 1);
end;

procedure TfmToolbarConfig.actMoveDownExecute(Sender: TObject);
var
  Index: Integer;
begin
  Index := lbToolbar.ItemIndex;
  if Index = lbToolbar.Items.Count - 1 then
    Exit;
  lbToolbar.Items.Exchange(Index, Index + 1);
end;

procedure TfmToolbarConfig.btnOKClick(Sender: TObject);
var
  i: Integer;
  Action: TContainedAction;
begin
  FToolbarActionNames.Clear;
  for i := 0 to lbToolbar.Items.Count - 1 do begin
    Action := TContainedAction(lbToolbar.Items.Objects[i]);
    if Action = nil then
      FToolbarActionNames.Add(SeparatorMenuItemString)
    else if Action.Name <> '' then
      FToolbarActionNames.Add(Action.Name);
  end;
end;

procedure TfmToolbarConfig.ListboxDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  Listbox: TListbox;
  LbCanvas: TCanvas;

  procedure DrawToolbarButton;
  var
    BtnRect: TRect;
    OldColor: TColor;
    Action: TCustomAction;
    Obj: TObject;
  begin
    Action := nil;
    Obj := Listbox.Items.Objects[Index];
    if Assigned(Obj) and (Obj is TCustomAction) then
      Action := TCustomAction(Obj);

    if odSelected in State then
      LbCanvas.Brush.Color := clHighlight
    else
      LbCanvas.Brush.Color := clWindow;

    LbCanvas.FillRect(Rect);

    // Paint fake button
    if Assigned(Action) and (Action.ImageIndex <> -1) then
    begin
      OldColor := LbCanvas.Brush.Color;
      LbCanvas.Brush.Color := clBtnface;
      try
        BtnRect := Classes.Rect(Rect.Left, Rect.Top + 1,
                                Rect.Left + 20, Rect.Top + 20);
        LbCanvas.FillRect(BtnRect);
        Action.ActionList.Images.Draw(LbCanvas,
                                      Rect.Left + 2,
                                      Rect.Top + 2,
                                      Action.ImageIndex);
        Frame3D(LbCanvas, BtnRect, clBtnHighlight, clBtnShadow, 1);
      finally
        LbCanvas.Brush.Color := OldColor;
      end;
    end;
  end;

begin
  Assert(Control is TListBox);
  Listbox := TListBox(Control);
  LbCanvas := Listbox.Canvas;
  if FTextOffset = 0 then
    FTextOffset := (Listbox.ItemHeight - LbCanvas.TextHeight(SAllAlphaNumericChars)) div 2;

  DrawToolbarButton;

  LbCanvas.Brush.Style := bsClear;

  if not lbAvailable.Enabled then
    LbCanvas.Font.Color := clGrayText;
  LbCanvas.TextOut(Rect.Left + 22, Rect.Top + FTextOffSet, Listbox.Items[Index]);
end;

procedure TfmToolbarConfig.lbAvailableDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := (Source = lbToolbar);
end;

procedure TfmToolbarConfig.lbAvailableDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  actRemoveButton.Execute;
end;

procedure TfmToolbarConfig.lbToolbarDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  Idx: Integer;
begin
  Accept := ((Source = lbAvailable) or (Source = Sender));
  // Autoscroll the listbox to make dragging easier
  if Y < 15 then
    lbToolbar.Perform(WM_VSCROLL, SB_LINEUP, 0)
  else
    if Y > lbToolbar.Height - 15 then
      lbToolbar.Perform(WM_VSCROLL, SB_LINEDOWN, 0);
  Idx := lbToolbar.ItemAtPos(Point(X, Y), False);
  if (Idx > -1) and (Idx < lbToolbar.Items.Count) then
    lbToolbar.ItemIndex := Idx;
end;

procedure TfmToolbarConfig.lbToolbarDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  Idx: Integer;
begin
  Idx := lbToolbar.ItemAtPos(Point(X, Y), False);
  if Idx = lbToolbar.Items.Count then
    Dec(Idx);
  if Sender <> Source then
  begin
    if (Idx < 0) or (Idx = lbToolbar.Items.Count - 1) then
      actAddButton.Execute
    else
    begin
      lbToolbar.Items.InsertObject(Idx, lbAvailable.Items[lbAvailable.ItemIndex],
        lbAvailable.Items.Objects[lbAvailable.ItemIndex]);
      lbToolbar.ItemIndex := Idx;
    end;
  end
  else
  begin
    if (FSavedToolbarItemIndex < 0) or (Idx < 0) then
      Exit;
    lbToolbar.Items.Move(FSavedToolbarItemIndex, Idx);
    lbToolbar.ItemIndex := Idx;
  end;
end;

procedure TfmToolbarConfig.lbToolbarStartDrag(Sender: TObject; var DragObject: TDragObject);
begin
  FSavedToolbarItemIndex := lbToolbar.ItemIndex;
end;

procedure TfmToolbarConfig.lbToolbarKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
    actRemoveButton.Execute;
end;

end.
