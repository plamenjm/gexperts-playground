unit GX_ClipboardHistory;

{$I GX_CondDefine.inc}

interface

uses
  Windows, SysUtils, Classes, Types, Controls, Forms, StdCtrls, ExtCtrls, Menus,
  ComCtrls, ActnList, Actions, ToolWin, Graphics, GX_SharedImages,
  GX_Experts, GX_ConfigurationInfo, GX_IdeDock;

type
  TClipInfo = class(TObject)
  private
    FClipTimeStamp: string;
    FClipString: string;
  public
    property ClipTimeStamp: string read FClipTimeStamp write FClipTimeStamp;
    property ClipString: string read FClipString write FClipString;
  end;

  TfmClipboardHistory = class(TfmIdeDockForm)
    Splitter: TSplitter;
    mmoClipText: TMemo;
    MainMenu: TMainMenu;
    mitFile: TMenuItem;
    mitFileExit: TMenuItem;
    mitEdit: TMenuItem;
    mitEditCopy: TMenuItem;
    mitHelp: TMenuItem;
    mitHelpContents: TMenuItem;
    mitHelpAbout: TMenuItem;
    mitHelpHelp: TMenuItem;
    mitHelpSep1: TMenuItem;
    mitEditClear: TMenuItem;
    lvClip: TListView;
    ToolBar: TToolBar;
    tbnClear: TToolButton;
    tbnCopy: TToolButton;
    tbnHelp: TToolButton;
    tbnSep2: TToolButton;
    Actions: TActionList;
    actFileExit: TAction;
    actEditCopy: TAction;
    actEditClear: TAction;
    actHelpHelp: TAction;
    actHelpContents: TAction;
    actHelpAbout: TAction;
    actEditPasteToIde: TAction;
    tbnPaste: TToolButton;
    mitEditPasteToIde: TMenuItem;
    mitView: TMenuItem;
    actViewToolBar: TAction;
    mitViewToolBar: TMenuItem;
    tbnSep3: TToolButton;
    btnOptions: TToolButton;
    actViewOptions: TAction;
    mitViewOptions: TMenuItem;
    actFileRehookClipboard: TAction;
    mitFileRehookClipboard: TMenuItem;
    tbnDelete: TToolButton;
    actDelete: TAction;
    mitEditDelete: TMenuItem;
    tbnSep1: TToolButton;
    mitEditSep1: TMenuItem;
    pmListMenu: TPopupMenu;
    mitListCopy: TMenuItem;
    mitListPasteIntoIDE: TMenuItem;
    mitListDelete: TMenuItem;
    mitListSep2: TMenuItem;
    actEditPasteAsPascalString: TAction;
    mitEditPasteAsPascalString: TMenuItem;
    mitListPasteAsPascalString: TMenuItem;
    tbnPasteAsPascal: TToolButton;
    pnlPasteAsOptions: TPanel;
    actViewPasteAsOptions: TAction;
    tbnViewPasteAs: TToolButton;
    tbnSep4: TToolButton;
    ShowPasteAsoptions1: TMenuItem;
    lblMaxEntries: TLabel;
    cbPasteAsType: TComboBox;
    chkCreateQuotedStrings: TCheckBox;
    chkAddExtraSpaceAtTheEnd: TCheckBox;
    actEditCopyFromPascalString: TAction;
    actEditReplaceAsPascalString: TAction;
    mitEditCopyfromPascalstring: TMenuItem;
    mitEditReplaceasPascalstring: TMenuItem;
    mitListSep1: TMenuItem;
    mitListCopyfromPascalstring: TMenuItem;
    mitReplaceasPascalstring: TMenuItem;
    actHamburgerMenu: TAction;
    tbnHamburgerMenu: TToolButton;
    pmHamburgerMenu: TPopupMenu;
    mi_HambugerFile: TMenuItem;
    mi_HambugerEdit: TMenuItem;
    mi_HambugerView: TMenuItem;
    mi_HambuergerHelp: TMenuItem;
    mi_HambugerFileRehookClipboard: TMenuItem;
    mi_HambugerEditClear: TMenuItem;
    mi_HambugerEditDelete: TMenuItem;
    N1: TMenuItem;
    mi_HambugerEditCopy: TMenuItem;
    mi_HambugerEditCopyFromPascalString: TMenuItem;
    mi_HambugerEditPasteIntoIde: TMenuItem;
    N2: TMenuItem;
    mi_HambugerEditPasteAsPascalString: TMenuItem;
    mi_HambugerEditReplaceAsPascalString: TMenuItem;
    mi_HamburgerViewShowToolbar: TMenuItem;
    mi_HamburgerViewShowPasteAsOptions: TMenuItem;
    mi_HamburberViewOptions: TMenuItem;
    mi_HambuergerHelpHelp: TMenuItem;
    mi_HamburgerHelpContents: TMenuItem;
    N3: TMenuItem;
    miListViewView: TMenuItem;
    miListViewShowToolbar: TMenuItem;
    miListViewShowPasteAsOptions: TMenuItem;
    miListViewOptions: TMenuItem;
    procedure FormResize(Sender: TObject);
    procedure SplitterMoved(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lvClipDblClick(Sender: TObject);
    procedure lvClipChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure actEditCopyExecute(Sender: TObject);
    procedure actEditClearExecute(Sender: TObject);
    procedure actFileExitExecute(Sender: TObject);
    procedure actHelpHelpExecute(Sender: TObject);
    procedure actHelpContentsExecute(Sender: TObject);
    procedure actHelpAboutExecute(Sender: TObject);
    procedure lvClipKeyPress(Sender: TObject; var Key: Char);
    procedure actEditPasteToIdeExecute(Sender: TObject);
    procedure ActionsUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure actViewToolBarExecute(Sender: TObject);
    procedure actViewPasteAsOptionsExecute(Sender: TObject);
    procedure actViewOptionsExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure actFileRehookClipboardExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actEditPasteAsPascalStringExecute(Sender: TObject);
    procedure lvClipResize(Sender: TObject);
    procedure actHamburgerMenuExecute(Sender: TObject);
  private
    FHelperWindow: TWinControl;
    IgnoreClip: Boolean;
    FDataList: TList;
    FLoading: Boolean;
    SplitterRatio: Double;
    procedure InitializeForm;
    procedure ClearDataList;
    procedure LoadClips;
    procedure SaveClips;
    procedure HookClipboard;
    function ClipInfoForItem(Item: TListItem): TClipInfo;
    function ClipInfoFromPointer(Ptr: Pointer): TClipInfo;
    function HaveSelectedItem: Boolean;
    procedure RemoveDataListItem(Index: Integer);
    function GetSelectedItemsText: string;
    procedure WmDrawClipBoard;
    procedure AddClipItem(const AClipText: string);
    procedure ArrangeToolbarAndPanel;
  protected
{$IFDEF GX_IDE_IS_HIDPI_AWARE}
    procedure ApplyDpi(_NewDpi: Integer; _NewBounds: PRect); override;
    procedure ArrangeControls;  override;
{$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    procedure SaveSettings;
    procedure LoadSettings;
  end;

  TClipboardHistoryExpert = class(TGX_Expert)
  private
    FMaxClip: Integer;
    FAutoStart: Boolean;
    FAutoClose: Boolean;
    FStoragePath: string;
    FPreviewFont: TFont;
    function GetStorageFile: string;
  protected
    procedure SetActive(New: Boolean); override;
    procedure InternalLoadSettings(_Settings: IExpertSettings); override;
    procedure InternalSaveSettings(_Settings: IExpertSettings); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    function GetActionCaption: string; override;
    class function GetName: string; override;
    procedure Execute(Sender: TObject); override;
    procedure Configure(_Owner: TWinControl); override;
    property MaxClip: Integer read FMaxClip write FMaxClip;
    property StorageFile: string read GetStorageFile;
  end;

var
  fmClipboardHistory: TfmClipboardHistory = nil;
  ClipExpert: TClipboardHistoryExpert = nil;

implementation

{$R *.dfm}

uses
  {$IFOPT D+} GX_DbugIntf, {$ENDIF}
  Messages, Clipbrd, Dialogs, Math, StrUtils, OmniXML,
  GX_GxUtils, GX_GenericUtils, GX_OtaUtils, u_dzVclUtils,
  GX_GExperts, GX_ClipboardOptions, GX_XmlUtils,
  GX_PasteAs;

const
  ClipStorageFileName = 'ClipboardHistory.xml';

type
  THelperWinControl = class(TWinControl)
  private
    FPrevWindow: HWnd;
    procedure WMChangeCBChain(var Msg: TMessage); message WM_CHANGECBCHAIN;
    procedure WMDrawClipBoard(var Msg: TMessage); message WM_DRAWCLIPBOARD;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TClipData = record
    FirstLine: String;
    Count: Integer;
  end;

function FirstLineOfText(const AClipString: string): TClipData;
var
  sl: TStringList;
  i: Integer;
begin
  Result.FirstLine := '';
  sl := TStringList.Create;
  try
    sl.Text := AClipString;
    Result.Count := sl.Count;
    i := 0;
    while (Result.FirstLine = '') and (i < sl.Count) do begin
      Result.FirstLine := sl[i];
      Inc(i);
    end;
  finally
    sl.Free;
  end;
end;


{ THelperWinControl }

constructor THelperWinControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Name := 'ClipboardChainHelperWindow';
  // The clipboard chaining only works properly if this window is
  // not parented by the the clip form.  The desktop window may not
  // be the best window to hook but it works.
  ParentWindow := GetDesktopWindow;
  Visible := False;
  {$IFOPT D+} SendDebug('In THelperWinControl Create'); {$ENDIF}
  FPrevWindow := SetClipBoardViewer(Self.Handle);
  {$IFOPT D+} SendDebug('FPrevWindow = ' + IntToStr(FPrevWindow)); {$ENDIF}
end;

destructor THelperWinControl.Destroy;
begin
  //{$IFOPT D+} SendDebug('In THelperWinControl Destroy'); {$ENDIF}
  try
    ChangeClipBoardChain(Self.Handle, FPrevWindow);
  except
    on E: Exception do
    begin
      {$IFOPT D+} SendDebugError('Clip Chain Destroy: ' + E.Message); {$ENDIF}
    end;
  end;
  inherited Destroy;
end;

procedure THelperWinControl.WMChangeCBChain(var Msg: TMessage);
begin
  {$IFOPT D+} SendDebug('In THelperWinControl WMChangeCBChain'); {$ENDIF}
  if Msg.WParam = WPARAM(FPrevWindow) then
    FPrevWindow := Msg.lParam
  else if (FPrevWindow <> 0) then
    SendMessage(FPrevWindow, WM_CHANGECBCHAIN, Msg.WParam, Msg.LParam);
  //Msg.Result := 0; //??
end;

procedure THelperWinControl.WMDrawClipBoard(var Msg: TMessage);
begin
  try
    {$IFOPT D+} SendDebug('In THelperWinControl WMDrawClipBoard'); {$ENDIF}
    if not Assigned(fmClipboardHistory) then
      Exit;
    fmClipboardHistory.WmDrawClipBoard;
  finally
    if FPrevWindow <> 0 then
      SendMessage(FPrevWindow, WM_DRAWCLIPBOARD, Msg.WParam, Msg.LParam);
  end;
end;

{ TfmClipboardHistory }

procedure TfmClipboardHistory.InitializeForm;
begin
  inherited;
  TPasteAsHandler.GetTypeText(cbPasteAsType.Items);
  cbPasteAsType.DropDownCount := Integer(High(TPasteAsType)) + 1;
  cbPasteAsType.ItemIndex := Integer(PasteAsHandler.PasteAsType);
  chkCreateQuotedStrings.Checked := PasteAsHandler.CreateQuotedString;
  chkAddExtraSpaceAtTheEnd.Checked := PasteAsHandler.AddExtraSpaceAtTheEnd;
end;

procedure TfmClipboardHistory.FormResize(Sender: TObject);
begin
  mmoClipText.Height := Trunc(SplitterRatio * (mmoClipText.Height + lvClip.Height));
end;

procedure TfmClipboardHistory.SplitterMoved(Sender: TObject);
begin
  SplitterRatio := mmoClipText.Height / (lvClip.Height + mmoClipText.Height);
  FormResize(Self);
end;

procedure TfmClipboardHistory.ClearDataList;
var
  i: Integer;
begin
  if Assigned(FDataList) then
  begin
    for i := 0 to FDataList.Count - 1 do
      ClipInfoFromPointer(FDataList.Items[i]).Free;
    FDataList.Clear;
  end;
  lvClip.Items.Clear;
end;

procedure TfmClipboardHistory.Clear;
begin
  ClearDataList;
  mmoClipText.Lines.Clear;
end;

procedure TfmClipboardHistory.SaveSettings;
var
  Settings: IExpertSettings;
begin
  Settings := TClipboardHistoryExpert.GetSettings;
  // Do not localize.
  Settings.SaveForm('Window', Self);
  Settings := Settings.Subkey('Window');
  Settings.WriteInteger('SplitterRatio', Round(SplitterRatio * 100));
  Settings.WriteBool('ViewToolBar', ToolBar.Visible);
  Settings.WriteBool('PasteAsOptions', pnlPasteAsOptions.Visible);
end;

procedure TfmClipboardHistory.LoadSettings;
var
  Settings: IExpertSettings;
begin
  Settings := TClipboardHistoryExpert.GetSettings;
  // Do not localize.
  Settings.LoadForm('Window', Self);
  Settings := Settings.Subkey('Window');
  SplitterRatio := Settings.ReadInteger('SplitterRatio', 50) / 100;
  mmoClipText.Height := Trunc(SplitterRatio * (mmoClipText.Height + lvClip.Height));
  ToolBar.Visible := Settings.ReadBool('ViewToolBar', True);
  pnlPasteAsOptions.Visible := Settings.ReadBool('PasteAsOptions', True);
  EnsureFormVisible(Self);
end;

procedure TfmClipboardHistory.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TfmClipboardHistory.lvClipDblClick(Sender: TObject);
begin
  actEditCopy.Execute;
end;

procedure TfmClipboardHistory.LoadClips;
var
  Doc: IXmlDocument;
  Nodes: IXMLNodeList;
  i: Integer;
  TimeStr: string;
  ClipStr: string;
  Info: TClipInfo;
  ClipItem: TListItem;
  TimeNode: IXMLNode;
  ClipData: TClipData;
begin
  ClearDataList;
  Doc := CreateXMLDoc;
  if FileExists(ClipExpert.StorageFile) then begin
    Doc.Load(ClipExpert.StorageFile);
    if not Assigned(Doc.DocumentElement) then
      Exit;
    Nodes := Doc.DocumentElement.selectNodes('ClipItem');
    lvClip.Items.BeginUpdate;
    try
      FLoading := True;
      for i := 0 to Nodes.Length - 1 do
      begin
        if i >= ClipExpert.MaxClip then
          Break;
        TimeNode := Nodes.Item[i].Attributes.GetNamedItem('DateTime');
        if Assigned(TimeNode) then
          TimeStr := TimeNode.NodeValue
        else
          TimeStr := TimeToStr(Time);
        ClipStr := GX_XmlUtils.GetCDataSectionTextOrNodeText(Nodes.Item[i]);

        Info := TClipInfo.Create;
        FDataList.Add(Info);
        Info.ClipString := ClipStr;
        Info.ClipTimeStamp := TimeStr;

        ClipItem := lvClip.Items.Add;
        ClipItem.Caption := Info.ClipTimeStamp;
        ClipData := FirstLineOfText(ClipStr);
        ClipItem.SubItems.Add(IntToStr(ClipData.Count));
        ClipItem.SubItems.Add(Trim(ClipData.FirstLine));
        ClipItem.Data := Info;
      end;
    finally
      TListView_Resize(lvClip);
      lvClip.Items.EndUpdate;
      FLoading := False;
    end;
    if lvClip.Items.Count > 0 then
    begin
      lvClip.Selected := lvClip.Items[0];
      lvClip.ItemFocused := lvClip.Selected;
    end;
  end;
end;

procedure TfmClipboardHistory.SaveClips;
var
  Doc: IXmlDocument;
  Root: IXMLElement;
  i: Integer;
  ClipItem: IXMLElement;
  ClipText: IXMLCDATASection;
begin
  // We are calling SaveClips from the destructor where
  // we may be in a forced clean-up due to an exception.
  if ExceptObject <> nil then
    Exit;

  Doc := CreateXMLDoc;
  AddXMLHeader(Doc);
  Root := Doc.CreateElement('Clips');
  Doc.AppendChild(Root);
  for i := 0 to FDataList.Count - 1 do
  begin
    ClipItem := Doc.CreateElement('ClipItem');
    ClipItem.SetAttribute('DateTime', ClipInfoFromPointer(FDataList[i]).ClipTimeStamp);
    ClipText := Doc.CreateCDATASection(EscapeCDataText(ClipInfoFromPointer(FDataList[i]).ClipString));
    ClipItem.AppendChild(ClipText);
    Root.AppendChild(ClipItem);
  end;
  if PrepareDirectoryForWriting(ExtractFileDir(ClipExpert.StorageFile)) then
    Doc.Save(ClipExpert.StorageFile, ofFlat);
end;

procedure TfmClipboardHistory.lvClipChange(Sender: TObject; Item: TListItem; Change: TItemChange);
begin
  if FLoading or (csDestroying in ComponentState) then
    Exit;
  if lvClip.Selected = nil then begin
    mmoClipText.Clear;
  end else
    try
      mmoClipText.Lines.Text := GetSelectedItemsText;
    except
      on EInvalidOperation do begin
        // sometimes setting the memo text fails
        // according to the Win32API documentation this can only happen if there is
        // insufficient space available to set the text in the edit control.
        // On the otherhand, this has happened with large but not huge texts (<5000 characters)
        // so I doubt that this is the real problem here. In my case the error happened
        // during debugging, so maybe that's a factor in it too.
        // If this exception is not handled it will crash the IDE.
        // For now we will simply ignore it since it happens so rarely.
      end;
    end;
end;

constructor TfmClipboardHistory.Create(AOwner: TComponent);
resourcestring
  SLoadingFailed = 'Loading of stored clipboard clips failed.' + sLineBreak;
begin
  inherited;

  TControl_SetMinConstraints(Self);

  if IsStandAlone then begin
    actHamburgerMenu.Visible := False;
    Menu := MainMenu;
  end;

  SetToolbarGradient(ToolBar);
  {$IFOPT D+} SendDebug('Creating clipboard history data list'); {$ENDIF}
  FDataList := TList.Create;
  SplitterRatio := 0.50;
  LoadSettings;

  IgnoreClip := False;

  // With large fonts, the TMenuToolBar ends up below the ToolBar, this fixes it
  ArrangeToolbarAndPanel;

  InitDpiScaler;

  InitializeForm;

  CenterForm(Self);

  HookClipboard;

  // Now load any saved clips from our XML storage.
  // Since we do not depend on these snippets, continue
  // even in the presence of an exception.
  try
    LoadClips;
  except
    on E: Exception do
    begin
      GxLogAndShowException(E, SLoadingFailed);
      // Swallow exceptions
    end;
  end;
end;

destructor TfmClipboardHistory.Destroy;
begin
  SaveClips;

  // Now free everything.
  ClearDataList;
  FreeAndNil(FDataList);
  FreeAndNil(FHelperWindow);
  SaveSettings;

  inherited Destroy;
  fmClipboardHistory := nil;
end;

{$IFDEF GX_IDE_IS_HIDPI_AWARE}
procedure TfmClipboardHistory.ApplyDpi(_NewDpi: Integer; _NewBounds: PRect);
var
  il: TImageList;
begin
  inherited;
  ToolBar.DisabledImages := GExpertsInst.GetScaledSharedDisabledImages(_NewDpi);
  il := GExpertsInst.GetScaledSharedImages(_NewDpi);
  ToolBar.Images := il;
  Actions.Images := il;
  MainMenu.Images := il;
end;

procedure TfmClipboardHistory.ArrangeControls;
begin
  ArrangeToolbarAndPanel;
end;
{$ENDIF}

procedure TfmClipboardHistory.ArrangeToolbarAndPanel;
begin
  ToolBar.Align := alNone;
  ToolBar.Top := 200;
  ToolBar.Align := alTop;

  pnlPasteAsOptions.Top := ToolBar.Top + ToolBar.Height;
end;


procedure TfmClipboardHistory.AddClipItem(const AClipText: string);
var
  Info: TClipInfo;
  ClipItem: TListItem;
  ClipData: TClipData;
begin
  Info := TClipInfo.Create;
  FDataList.Insert(0, Info);
  Info.ClipString := AClipText;
  Info.ClipTimeStamp := TimeToStr(Time);

  ClipItem := lvClip.Items.Insert(0);
  ClipItem.Caption := Info.ClipTimeStamp;
  ClipData := FirstLineOfText(Info.ClipString);
  ClipItem.SubItems.Add(IntToStr(ClipData.Count));
  ClipItem.SubItems.Add(Trim(ClipData.FirstLine));
  ClipItem.Data := Info;
end;

procedure TfmClipboardHistory.actEditCopyExecute(Sender: TObject);
var
  idx: Integer;
  Buffer: string;
  AsPascalString: Boolean;

  function GetCopyText(AText: String): String;
  var
    AList: TStringList;
    ALine: String;
    APasteAsHandler: TPasteAsHandler;
  begin
    Result := AText;
    if AsPascalString then
    begin
      AList := TStringList.Create;
      try
        AList.Text := AText;

        if AList.Count = 1 then
        begin
          ALine := AList[0];
          ALine := AnsiReplaceText(ALine, '#$D#$A', #$D#$A);
          ALine := AnsiReplaceText(ALine, '#13#10', #13#10);
          AList.Text := ALine;
        end;

        if actViewPasteAsOptions.Checked then
        begin
          APasteAsHandler := TPasteAsHandler.Create;
          try
            APasteAsHandler.PasteAsType := TPasteAsType(cbPasteAsType.ItemIndex);
            APasteAsHandler.CreateQuotedString := chkCreateQuotedStrings.Checked;
            APasteAsHandler.AddExtraSpaceAtTheEnd := chkAddExtraSpaceAtTheEnd.Checked;

            APasteAsHandler.ExtractRawStrings(AList, False);
            Result := AList.Text;
          finally
            APasteAsHandler.Free;
          end;
        end
        else begin
          PasteAsHandler.ExtractRawStrings(AList, False);
          Result := AList.Text;
        end;
      finally
        AList.Free;
      end;
    end;
  end;

begin
  try
    AsPascalString := Sender = actEditCopyFromPascalString;

    if mmoClipText.SelLength = 0 then
    begin
      if lvClip.SelCount = 1 then
      begin
        IgnoreClip := True;
        try
          idx := lvClip.Selected.Index;
          Buffer := GetCopyText(mmoClipText.Text);
          Clipboard.AsText := Buffer;

          lvClip.Items.Delete(idx);
          ClipInfoFromPointer(FDataList[idx]).Free;
          FDataList.Delete(idx);

          AddClipItem(Buffer);

          lvClip.Selected := lvClip.Items[0];
          lvClip.ItemFocused := lvClip.Selected;

          TListView_Resize(lvClip);
        finally
          IgnoreClip := False;
        end;
      end
      else
        Clipboard.AsText := GetCopyText(GetSelectedItemsText);
    end
    else
//      mmoClipText.CopyToClipBoard;
      Clipboard.AsText := GetCopyText(mmoClipText.Text);

    if ClipExpert.FAutoClose then
      Self.Close;
  finally
    Application.ProcessMessages;
  end;
end;

procedure TfmClipboardHistory.actEditClearExecute(Sender: TObject);
resourcestring
  SConfirmClearClipHistory = 'Clear the clipboard history?';
begin
  if MessageDlg(SConfirmClearClipHistory, mtConfirmation, [mbOK, mbCancel], 0) = mrOk then
    Self.Clear;
end;

procedure TfmClipboardHistory.actFileExitExecute(Sender: TObject);
begin
  Self.Hide;
end;

procedure TfmClipboardHistory.actHelpHelpExecute(Sender: TObject);
begin
  GxContextHelp(Self, 13);
end;

procedure TfmClipboardHistory.actHelpContentsExecute(Sender: TObject);
begin
  GxContextHelpContents(Self);
end;

procedure TfmClipboardHistory.actHamburgerMenuExecute(Sender: TObject);
var
  Pnt: TPoint;
begin
  inherited;
  Pnt := tbnHamburgerMenu.ClientToScreen(Point(0, tbnHamburgerMenu.Height));
  pmHamburgerMenu.Popup(Pnt.X, Pnt.Y);
end;

procedure TfmClipboardHistory.actHelpAboutExecute(Sender: TObject);
begin
  ShowGXAboutForm;
end;

procedure TfmClipboardHistory.lvClipKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;

  if Key = #13 then
    actEditCopy.Execute;
end;

procedure TfmClipboardHistory.lvClipResize(Sender: TObject);
begin
  TListView_Resize(lvClip);
end;

procedure TfmClipboardHistory.actEditPasteToIdeExecute(Sender: TObject);
begin
  if mmoClipText.SelLength = 0 then
    GxOtaInsertTextIntoEditor(mmoClipText.Text)
  else
    GxOtaInsertTextIntoEditor(mmoClipText.SelText);
end;

procedure TfmClipboardHistory.ActionsUpdate(Action: TBasicAction; var Handled: Boolean);
begin
  actEditCopy.Enabled := (mmoClipText.SelLength > 0) or HaveSelectedItem;
  actEditPasteToIde.Enabled := actEditCopy.Enabled;
  actEditPasteAsPascalString.Enabled := actEditCopy.Enabled;
  actDelete.Enabled := HaveSelectedItem;
  actViewToolBar.Checked := ToolBar.Visible;
  actViewPasteAsOptions.Checked := pnlPasteAsOptions.Visible;
end;

procedure TfmClipboardHistory.actViewPasteAsOptionsExecute(Sender: TObject);
begin
  pnlPasteAsOptions.Visible := not pnlPasteAsOptions.Visible;
  ArrangeToolbarAndPanel;
end;

procedure TfmClipboardHistory.actViewToolBarExecute(Sender: TObject);
begin
  ToolBar.Visible := not ToolBar.Visible;
  ArrangeToolbarAndPanel;
end;

procedure TfmClipboardHistory.actViewOptionsExecute(Sender: TObject);
begin
  ClipExpert.Configure(Self);
end;

procedure TfmClipboardHistory.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0;
    Close;
  end;
end;

procedure TfmClipboardHistory.HookClipboard;
begin
  FreeAndNil(FHelperWindow);
  {$IFOPT D+} SendDebug('Creating clipboard history THelperWinControl'); {$ENDIF}
  // The helper window is parented by the Desktop Window and
  // it chains the clipboard for us.
  FHelperWindow := THelperWinControl.Create(nil);
  {$IFOPT D+} SendDebug('Clipboard history helper window created'); {$ENDIF}
end;

procedure TfmClipboardHistory.actFileRehookClipboardExecute(Sender: TObject);
begin
  IgnoreClip := True;
  try
    HookClipboard;
  finally
    IgnoreClip := False;
  end;
end;

function TfmClipboardHistory.ClipInfoForItem(Item: TListItem): TClipInfo;
begin
  Assert(Assigned(Item));
  Assert(Assigned(Item.Data));
  Result := ClipInfoFromPointer(Item.Data);
end;

function TfmClipboardHistory.ClipInfoFromPointer(Ptr: Pointer): TClipInfo;
begin
  Assert(Assigned(Ptr));
  Result := TObject(Ptr) as TClipInfo;
end;

function TfmClipboardHistory.HaveSelectedItem: Boolean;
begin
  Result := Assigned(lvClip.Selected);
end;

procedure TfmClipboardHistory.RemoveDataListItem(Index: Integer);
var
  ClipInfo: TClipInfo;
begin
  Assert(Assigned(FDataList));
  Assert(Index < FDataList.Count);
  ClipInfo := ClipInfoFromPointer(FDataList.Items[Index]);
  FreeAndNil(ClipInfo);
  FDataList.Delete(Index);
end;

procedure TfmClipboardHistory.actDeleteExecute(Sender: TObject);
var
  i: Integer;
begin
  if not HaveSelectedItem then
    Exit;
  for i := lvClip.Items.Count - 1 downto 0 do
  begin
    if lvClip.Items[i].Selected then
    begin
      lvClip.Items.Delete(i);
      RemoveDataListItem(i);
    end;
  end;
  mmoClipText.Clear;
end;

function TfmClipboardHistory.GetSelectedItemsText: string;
var
  i: Integer;
  ClipItem: TListItem;
begin
  Result := '';
  for i := lvClip.Items.Count - 1 downto 0 do
  begin
    ClipItem := lvClip.Items[i];
    if ClipItem.Selected then
    begin
      if NotEmpty(Result) and (not HasTrailingEOL(Result)) then
        Result := Result + sLineBreak;
      Result := Result + ClipInfoForItem(ClipItem).ClipString;
    end;
  end;
end;

procedure TfmClipboardHistory.actEditPasteAsPascalStringExecute(Sender: TObject);
var
  AFromList: TStringList;
  APasteAsHandler: TPasteAsHandler;
  IsReplace: Boolean;
begin
  IsReplace := Sender = actEditReplaceAsPascalString;

  AFromList := TStringList.Create;
  try
    if mmoClipText.SelLength = 0 then
      AFromList.Text := mmoClipText.Text
    else
      AFromList.Text := mmoClipText.SelText;

    if actViewPasteAsOptions.Checked then
    begin
      APasteAsHandler := TPasteAsHandler.Create;
      try
        APasteAsHandler.PasteAsType := TPasteAsType(cbPasteAsType.ItemIndex);
        APasteAsHandler.CreateQuotedString := chkCreateQuotedStrings.Checked;
        APasteAsHandler.AddExtraSpaceAtTheEnd := chkAddExtraSpaceAtTheEnd.Checked;

        if IsReplace then
          APasteAsHandler.ExtractRawStrings(AFromList, True);

        APasteAsHandler.ConvertToCode(AFromList, False)
      finally
        APasteAsHandler.Free;
      end;
    end
    else
    begin
      if IsReplace then
        PasteAsHandler.ExtractRawStrings(AFromList, True);

      PasteAsHandler.ConvertToCode(AFromList, False);
    end;
  finally
    AFromList.Free;
  end;
end;

procedure TfmClipboardHistory.WmDrawClipBoard;
var
  ItemCount: Integer;
  ClipText: string;
  Handle: THandle;
  DataSize: Cardinal;
begin
  if IgnoreClip then
    Exit;
  try
    if Clipboard.HasFormat(CF_TEXT) then
    begin
      Clipboard.Open;
      try
        Handle := Clipboard.GetAsHandle(CF_TEXT);
        DataSize := GlobalSize(Handle);  // This function might over-estimate by a few bytes
      finally
        Clipboard.Close;
      end;
      // Don't try to save clipboard items over 512 KB for speed reasons
      if DataSize > ((1024 * 512) + 32) then
        Exit;

      ClipText := Clipboard.AsText;
      if (FDataList.Count = 0) or
         (TClipInfo(FDataList[0]).ClipString <> clipText) then begin
        {$IFOPT D+} SendDebug('New clipboard text detected'); {$ENDIF}
        mmoClipText.Text := ClipText;

        AddClipItem(ClipText);

        ItemCount := lvClip.Items.Count;
        if ItemCount > ClipExpert.MaxClip then
        begin
          Dec(ItemCount);
          lvClip.Items.Delete(ItemCount);
          TClipInfo(FDataList[ItemCount]).Free;
          FDataList.Delete(ItemCount);
        end;
        lvClip.Selected := nil;
        lvClip.Selected := lvClip.Items[0]; //FI:W508 - assigning to TListView.Selected has side effects
        lvClip.ItemFocused := lvClip.Selected;

        TListView_Resize(lvClip);
      end;
    end;
  except
    on E: Exception do
    begin
      {$IFOPT D+} SendDebugError(e.Message); {$ENDIF}
    end;
  end;
end;

{ TClipboardHistoryExpert }

constructor TClipboardHistoryExpert.Create;
begin
  inherited Create;
  FStoragePath := ConfigInfo.ConfigPath;

  FMaxClip := CLIPBOARD_VIEWER_ENTRIES_MIN;
  FPreviewFont := TFont.Create;

  FreeAndNil(ClipExpert);
  ClipExpert := Self;
end;

destructor TClipboardHistoryExpert.Destroy;
begin
  FreeAndNil(fmClipboardHistory);
  ClipExpert := nil;

  FreeAndnil(FPreviewFont);

  inherited Destroy;
end;

function TClipboardHistoryExpert.GetActionCaption: string;
resourcestring
  SMenuCaption = 'Clipboard &History';
begin
  Result := SMenuCaption;
end;

class function TClipboardHistoryExpert.GetName: string;
begin
  Result := 'ClipboardHistory';
end;

procedure TClipboardHistoryExpert.Execute(Sender: TObject);
begin
  // If the form doesn't exist, create it.
  if fmClipboardHistory = nil then
  begin
    fmClipboardHistory := TfmClipboardHistory.Create(nil);
    SetFormIcon(fmClipboardHistory);
    fmClipboardHistory.mmoClipText.Font := FPreviewFont;
  end;
  IdeDockManager.ShowForm(fmClipboardHistory);
  fmClipboardHistory.lvClip.SetFocus;
  IncCallCount;
end;

procedure TClipboardHistoryExpert.InternalLoadSettings(_Settings: IExpertSettings);
begin
  inherited InternalLoadSettings(_Settings);
  // Do not localize.
  FMaxClip := _Settings.ReadInteger('Maximum', CLIPBOARD_VIEWER_ENTRIES_MIN);
  FMaxClip := Max(Min(FMaxClip, CLIPBOARD_VIEWER_ENTRIES_MAX), CLIPBOARD_VIEWER_ENTRIES_MIN);
  FAutoStart := _Settings.ReadBool('AutoStart', False);
  FAutoClose := _Settings.ReadBool('AutoClose', False);
  _Settings.LoadFont('PreviewFont', FPreviewFont);

  // This procedure is only called once, so it is safe to
  // register the form for docking here.
  if Active then begin
    IdeDockManager.RegisterDockableForm(TfmClipboardHistory, fmClipboardHistory, 'fmClipboardHistory');

    if FAutoStart and (fmClipboardHistory = nil) then begin
      fmClipboardHistory := TfmClipboardHistory.Create(nil);
      fmClipboardHistory.mmoClipText.Font := FPreviewFont;
    end;
  end;
end;

procedure TClipboardHistoryExpert.InternalSaveSettings(_Settings: IExpertSettings);
begin
  inherited InternalSaveSettings(_Settings);
  // Do not localize.
  _Settings.WriteInteger('Maximum', FMaxClip);
  _Settings.WriteBool('AutoStart', FAutoStart);
  _Settings.WriteBool('AutoClose', FAutoClose);
  _Settings.SaveFont('PreviewFont', FPreviewFont);
end;

procedure TClipboardHistoryExpert.Configure(_Owner: TWinControl);
begin
  if TfmClipboardOptions.Execute(_Owner, FMaxClip, FAutoStart, FAutoClose, FPreviewFont) then begin
    SaveSettings;
    if Assigned(fmClipboardHistory) then
      fmClipboardHistory.mmoClipText.Font := FPreviewFont;
  end;
end;

function TClipboardHistoryExpert.GetStorageFile: string;
begin
  Result := FStoragePath + ClipStorageFileName;
end;

procedure TClipboardHistoryExpert.SetActive(New: Boolean);
begin
  if New <> Active then
  begin
    inherited SetActive(New);
    if New then //FI:W505
      // Nothing to initialize here
    else
      FreeAndNil(fmClipboardHistory);
  end;
end;

initialization
  RegisterGX_Expert(TClipboardHistoryExpert);
end.

