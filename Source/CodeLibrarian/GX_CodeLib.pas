unit GX_CodeLib;

{$I GX_CondDefine.inc}

//TODO 3 -cIssue -oAnyone: Handle invalid filenames with \/, or use Topic attribute as the display text?

interface

uses
  Windows, SysUtils,
  Forms, Controls, StdActns, Classes, ActnList, Actions, UITypes,
  Dialogs, Menus, ComCtrls, ToolWin, ExtCtrls,
  GpStructuredStorage,
  GX_Experts, GX_EnhancedEditor,
  GX_GenericUtils, GX_StringList, GX_SharedImages, GX_BaseForm,
  GX_CodeOpt;

type
  TSearchRecord = record
    Text: TGXUnicodeString;
    CaseSensitive: Boolean;
    WholeWord: Boolean;
  end;

  TGXStorageFile = class(TObject)
  private
    FStorage: IGpStructuredStorage;
    FFile: TStream;
    FFileName: TGXUnicodeString;
    function GetFileText: TGXUnicodeString;
    procedure SetFileText(const Value: TGXUnicodeString);
    procedure AssertFileIsOpen;
    procedure AssertValidFolderName(FolderName: TGXUnicodeString);
    procedure AssertValidFileName(FileName: TGXUnicodeString);
    procedure AssertExistingObjectName(const ObjectName: TGXUnicodeString);
    function GetFileInfo: IGpStructuredFileInfo;
  public
    constructor Create(const FileName: TGXUnicodeString);
    procedure CompactStorage;
    procedure CloseStorage;
    procedure OpenStorage(const FileName: WideString);
    procedure SaveStorage;

    procedure OpenFile(const FullPath: TGXUnicodeString); overload;
    procedure OpenFile(const FolderName, FileName: TGXUnicodeString); overload;
    procedure Delete(const ObjectName: TGXUnicodeString);
    procedure Move(const OldName, NewName: TGXUnicodeString);
    procedure CloseFile;
    procedure CreateFolder(const FolderName: TGXUnicodeString);
    function FolderExists(const FolderName: TGXUnicodeString): Boolean;
    function FileExists(const FileName: TGXUnicodeString): Boolean;
    function ObjectExists(const ObjectName: TGXUnicodeString): Boolean;

    procedure ListFiles(const FolderName: TGXUnicodeString; Files: TStrings);
    procedure ListFolders(const FolderName: TGXUnicodeString; Files: TStrings);

    property FileText: TGXUnicodeString read GetFileText write SetFileText;
    function AttributeAsString(const AttrName: TGXUnicodeString; const Default: TGXUnicodeString = ''): TGXUnicodeString;
    procedure SetAttribute(const AttrName: TGXUnicodeString; const Value: TGXUnicodeString); overload;
    procedure SetAttribute(const AttrName: TGXUnicodeString; const Value: Integer); overload;
    procedure SetObjectAttribute(const ObjectName, AttrName, AttrValue: TGXUnicodeString);
    function GetObjectAttribute(const ObjectName, AttrName: TGXUnicodeString): TGXUnicodeString;
  end;

  TfmCodeLib = class(TfmBaseForm)
    StatusBar: TStatusBar;
    Splitter: TSplitter;
    MainMenu: TMainMenu;
    mitFile: TMenuItem;
    mitFileNew: TMenuItem;
    mitFilePrinterSetup: TMenuItem;
    mitFilePrint: TMenuItem;
    mitFileSep3: TMenuItem;
    mitFileExit: TMenuItem;
    mitEdit: TMenuItem;
    mitEditPaste: TMenuItem;
    mitEditCopy: TMenuItem;
    mitEditCut: TMenuItem;
    mitHelp: TMenuItem;
    mitHelpHelp: TMenuItem;
    mitHelpContents: TMenuItem;
    mitHelpSep1: TMenuItem;
    mitHelpAbout: TMenuItem;
    mitFileDelete: TMenuItem;
    dlgPrinterSetup: TPrinterSetupDialog;
    pnlView: TPanel;
    pmTopics: TPopupMenu;
    mitTreeNew: TMenuItem;
    mitTreeDelete: TMenuItem;
    pmCode: TPopupMenu;
    mitEditorCut: TMenuItem;
    mitEditorCopy: TMenuItem;
    mitEditorPaste: TMenuItem;
    mitEditorSep2: TMenuItem;
    mitEditorHighlighting: TMenuItem;
    mitEditSep1: TMenuItem;
    mitEditCopyFromIde: TMenuItem;
    mitEditPasteFromIde: TMenuItem;
    mitEditorSep1: TMenuItem;
    mitEditorCopyFromDelphi: TMenuItem;
    mitEditorPasteIntoDelphi: TMenuItem;
    mitEditSep2: TMenuItem;
    mitEditFind: TMenuItem;
    mitEditFindNext: TMenuItem;
    mitFileSep1: TMenuItem;
    mitFileNewRootFolder: TMenuItem;
    mitFileNewFolder: TMenuItem;
    mitFileNewSnippet: TMenuItem;
    mitTreeNewRootFolder: TMenuItem;
    mitTreeNewFolder: TMenuItem;
    mitTreeNewSnippet: TMenuItem;
    mitOptions: TMenuItem;
    mitOptionsOptions: TMenuItem;
    mitTreeMakeRoot: TMenuItem;
    mitEditSep3: TMenuItem;
    mitEditExpandAll: TMenuItem;
    mitEditContractAll: TMenuItem;
    tvTopics: TTreeView;
    Actions: TActionList;
    actDelete: TAction;
    actNewRootFolder: TAction;
    actNewFolder: TAction;
    actNewSnippet: TAction;
    actMakeRoot: TAction;
    actPrinterSetup: TAction;
    actPrint: TAction;
    actExit: TAction;
    actEditCut: TEditCut;
    actEditCopy: TEditCopy;
    actEditPaste: TEditPaste;
    actEditCopyFromIde: TAction;
    actEditPasteToIde: TAction;
    actEditFind: TAction;
    actEditFindNext: TAction;
    actEditRename: TAction;
    actExpandAll: TAction;
    actContractAll: TAction;
    actCompactStorage: TAction;
    actEditReadOnly: TAction;
    actOptions: TAction;
    ToolBar: TToolBar;
    tbnNewFolder: TToolButton;
    tbnNewSnippet: TToolButton;
    tbnDelete: TToolButton;
    tbnCut: TToolButton;
    tbnSep1: TToolButton;
    tbnCopy: TToolButton;
    tbnPaste: TToolButton;
    tbnSep2: TToolButton;
    tbnCopyIde: TToolButton;
    tbnPasteIde: TToolButton;
    tbnSep3: TToolButton;
    tbnExpandAll: TToolButton;
    tbnContractAll: TToolButton;
    tbnSep4: TToolButton;
    tbnFind: TToolButton;
    tbnSep5: TToolButton;
    actHelpAbout: TAction;
    actHelpContents: TAction;
    actHelpHelp: TAction;
    tbnFindNext: TToolButton;
    tb_readonly: TToolButton;
    mitTreeRename: TMenuItem;
    mitFileSep2: TMenuItem;
    CompactStorage1: TMenuItem;
    N1: TMenuItem;
    mi_EditReadonly: TMenuItem;
    procedure CodeTextChange(Sender: TObject);
    procedure tvTopicsChanging(Sender: TObject; Node: TTreeNode; var AllowChange: Boolean);
    procedure tvTopicsEdited(Sender: TObject; Node: TTreeNode; var S: string);
    procedure tvTopicsChange(Sender: TObject; Node: TTreeNode);
    procedure DeleteExecute(Sender: TObject);
    procedure PrinterSetupExecute(Sender: TObject);
    procedure PrintExecute(Sender: TObject);
    procedure ExitExecute(Sender: TObject);
    procedure CutExecute(Sender: TObject);
    procedure CopyExecute(Sender: TObject);
    procedure PasteExecute(Sender: TObject);
    procedure HelpAboutExecute(Sender: TObject);
    procedure CopyFromIdeExecute(Sender: TObject);
    procedure PasteToIdeExecute(Sender: TObject);
    procedure FindExecute(Sender: TObject);
    procedure FindNextExecute(Sender: TObject);
    procedure tvTopicsDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure tvTopicsDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure ExpandAllExecute(Sender: TObject);
    procedure ContractAllExecute(Sender: TObject);
    procedure HelpExecute(Sender: TObject);
    procedure HelpContentsExecute(Sender: TObject);
    procedure StatusBarResize(Sender: TObject);
    procedure NewSnippetExecute(Sender: TObject);
    procedure NewRootFolderExecute(Sender: TObject);
    procedure NewFolderExecute(Sender: TObject);
    procedure OptionsExecute(Sender: TObject);
    procedure tvTopicsStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure tvTopicsEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure MakeRootExecute(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ActionsUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure GenericSyntaxHighlightingExecute(Sender: TObject);
    procedure tvTopicsDblClick(Sender: TObject);
    procedure actEditRenameExecute(Sender: TObject);
    procedure tvTopicsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure tvTopicsCompare(Sender: TObject; Node1, Node2: TTreeNode;
      Data: Integer; var Compare: Integer);
    procedure actCompactStorageExecute(Sender: TObject);
    function GetUniqueTopicName(ParentNode: TTreeNode; Folder: Boolean): TGXUnicodeString;
    procedure actEditReadOnlyExecute(Sender: TObject);
    procedure StatusBarDblClick(Sender: TObject);
  private
    FModified: Boolean;
    FSearch: TSearchRecord;
    FLayout: TCodeLayout;
    FStoragePath: TGXUnicodeString;
    FCodeText: TGxEnhancedEditor;
    FCurrentSyntaxMode: TGXSyntaxHighlighter;
    CodeDB: TGXStorageFile;
    function OpenStorage(const StorageFile: TGXUnicodeString): TGXStorageFile;
    procedure CloseDB(ClearFileName: Boolean = False);
    procedure InitializeTreeView;
    procedure SaveRecord;
    procedure DoSearch(First: Boolean);
    procedure SaveSettings;
    procedure LoadSettings;
    procedure SetModified(New: Boolean);
    procedure SetLayout(New: TCodeLayout);
    procedure SortNodes;
    procedure SetupSyntaxHighlightingControl;
    function IsCodeSnippet(Node: TTreeNode): Boolean;
    function IsFolder(Node: TTreeNode): Boolean;
    function GetNodePath(Node: TTreeNode): TGXUnicodeString;
    function GetNodeParentPath(Node: TTreeNode): TGXUnicodeString;
    procedure AssertValidFileName(const FileName: TGXUnicodeString);
    function TryGetSelected(out _Node: TTreeNode): Boolean;
    function SelectedNodeFullName: TGXUnicodeString;
    function SelectedCaption: TGXUnicodeString;
    procedure AssertNodeSelected(out _SelectedNode: TTreeNode);
    function FolderSelected: Boolean;
    procedure AddFolder(ParentNode: TTreeNode);
    procedure AddCode;
    property Modified: Boolean read FModified write SetModified;
    property StoragePath: TGXUnicodeString read FStoragePath write FStoragePath;
    procedure SetNodeAttribute(Node: TTreeNode; const AttrName, AttrValue: TGXUnicodeString);
    procedure InitializeSyntaxLanguages;
    function GetIdentifierForCurrentSyntaxMode: string;
    procedure SetCurrentSyntaxModeFromIdentifier(const LangIdent: string);
  protected
{$IFDEF GX_IDE_IS_HIDPI_AWARE}
    procedure ApplyDpi(_NewDpi: Integer; _NewBounds: PRect); override;
{$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Layout: TCodeLayout read FLayout write SetLayout;
  end;

  TCodeLibrarianExpert = class(TGX_Expert)
  protected
    FCodeLibForm: TfmCodeLib;
    procedure SetActive(New: Boolean); override;
    procedure CreateCodeLibForm;
  public
    destructor Destroy; override;
    function GetActionCaption: string; override;
    class function GetName: string; override;
    procedure Execute(Sender: TObject); override;
    function HasConfigOptions: Boolean; override;
  end;

procedure ShowCodeLib; {$IFNDEF GX_BCB} export; {$ENDIF GX_BCB}

implementation

{$R *.dfm}

// The built-in IDE parser/scanner has problems
// with a few conditional defines we use.
// Make it happy with code that *it* sees,
// but is never compiled by the real compiler.
{$UNDEF IdeParserPacifier_NEVERCOMPILED}

uses
  Clipbrd,
  u_dzVclUtils, u_dzStringUtils,
  {$IFOPT D+} GX_DbugIntf, {$ENDIF}
  GX_CodeSrch, GX_GxUtils,
  GX_OtaUtils, GX_IdeUtils,
  GX_GExperts, GX_ConfigurationInfo, GX_MessageBox;

const
  DefaultFileName = 'CodeLibrarian.fs';
  CodeLibPathSep = '\';
  AttrTopic = 'Topic';
  AttrLanguage = 'Language';
  SyntaxCategory = 'Syntax';
  STATUS_PANEL_PATH = 0;
  STATUS_PANEL_STATUS = 1;
  STATUS_PANEL_LANGUAGE = 2;

resourcestring
  SCouldNotCreateStorage = 'Could not create Code Librarian storage file.';

type
  TReadOnlyCodeLibFileMessage = class(TGxMsgBoxAdaptor)
  protected
    function GetMessage: string; override;
  end;

function MakeFileName(const FolderName, FileName: TGXUnicodeString): TGXUnicodeString;
begin
  Result := FolderName;
  if Result = '' then
    Result := CodeLibPathSep
  else
    Result := AddSlash(Result);
  if FileName <> '' then
  begin
    if FileName[1] = CodeLibPathSep then
      Result := Result + Copy(FileName, 2)
    else
      Result := Result + FileName;
  end;
end;

function TfmCodeLib.OpenStorage(const StorageFile: TGXUnicodeString): TGXStorageFile;
begin
  Result := TGXStorageFile.Create(StorageFile);
  {$IFOPT D+}SendDebug('Created new CodeLib storage file: ' + StorageFile);{$ENDIF}
end;

procedure TfmCodeLib.InitializeTreeView;

  procedure LoadTreeView(Node: TTreeNode);
  var
    RNode: TTreeNode;
    Folders: TStringList;
    Files: TStringList;
    i: Integer;
    RootPath: TGXUnicodeString;
  begin
    Folders := TStringList.Create;
    Files := TStringList.Create;
    try
      RootPath := GetNodePath(Node);
      CodeDB.ListFolders(RootPath, Folders);
      for i := 0 to Folders.Count - 1 do
      begin
        RNode := tvTopics.Items.AddChild(Node, CodeDB.GetObjectAttribute(MakeFileName(RootPath, Folders[i]), AttrTopic));
        RNode.ImageIndex := ImageIndexClosedFolder;
        RNode.SelectedIndex := ImageIndexOpenFolder;
        LoadTreeView(RNode);
      end;
      CodeDB.ListFiles(RootPath, Files);
      for i := 0 to Files.Count - 1 do
      begin
        RNode := tvTopics.Items.AddChild(Node, CodeDB.GetObjectAttribute(MakeFileName(RootPath, Files[i]), AttrTopic));
        RNode.ImageIndex := ImageIndexDocument;
        RNode.SelectedIndex := ImageIndexDocument;
      end;
    finally
      FreeAndNil(Files);
      FreeAndNil(Folders);
    end;
  end;

begin
  tvTopics.SortType := stNone;
  tvTopics.Items.BeginUpdate;
  try
    tvTopics.Items.Clear;
    LoadTreeView(nil);
    tvTopics.Selected := nil;
  finally
    tvTopics.SortType := stText;
    tvTopics.Items.EndUpdate;
  end;
  {$IFOPT D+}SendDebug('Finished creating tree view nodes');{$ENDIF}
end;

procedure TfmCodeLib.SetLayout(New: TCodeLayout);
begin
  if FLayout <> New then
  begin
    FLayout := New;
    case FLayout of
      clSide:
        begin
          tvTopics.Align := alLeft;
          tvTopics.Width := Self.Width div 2;
          Splitter.Align := alLeft;
          if Splitter.Left < tvTopics.Left then
            Splitter.Left := Self.Width;
          Splitter.Cursor := crHSplit;
          FCodeText.Align := AlClient;
        end;
      clTop:
        begin
          tvTopics.Align := alTop;
          tvTopics.Height := Self.Height div 2;
          Splitter.Align := alTop;
          if Splitter.Top < tvTopics.Top then
            Splitter.Top := Self.Height;
          FCodeText.Align := AlClient;
          Splitter.Cursor := crVSplit;
        end;
    end;
  end;
end;

procedure TfmCodeLib.AddFolder(ParentNode: TTreeNode);
var
  NewNode: TTreeNode;
  NewFolder: TGXUnicodeString;
  NewTopic: TGXUnicodeString;
begin
  if Assigned(ParentNode) and IsCodeSnippet(ParentNode) then
    ParentNode := ParentNode.Parent;

  NewTopic := GetUniqueTopicName(ParentNode, True);
  NewFolder := AddSlash(GetNodePath(ParentNode)) + NewTopic;
  CodeDB.AssertValidFolderName(NewFolder);
  CodeDB.CreateFolder(NewFolder);
  Assert(CodeDB.FolderExists(NewFolder));
  NewNode := tvTopics.Items.AddChild(ParentNode, NewTopic);
  SetNodeAttribute(NewNode, AttrTopic, NewTopic);
  NewNode.ImageIndex := ImageIndexClosedFolder;
  NewNode.SelectedIndex := ImageIndexOpenFolder;
  SortNodes;
  tvTopics.Selected := NewNode;
  NewNode.EditText;
end;

procedure TfmCodeLib.SetModified(New: Boolean);
begin
  FModified := New;
  if FModified then
    StatusBar.Panels[STATUS_PANEL_STATUS].Text := 'Modified'
  else if actEditReadOnly.Checked then
    StatusBar.Panels[STATUS_PANEL_STATUS].Text := 'Readonly'
  else
    StatusBar.Panels[STATUS_PANEL_STATUS].Text := 'Editable';
end;

procedure TfmCodeLib.AddCode;
var
  NewNode: TTreeNode;
  NewFileName: TGXUnicodeString;
  TopicName: TGXUnicodeString;
  LangType: string;
  SelectedNode: TTreeNode;
begin
  if not TryGetSelected(SelectedNode) then
    Exit; //==>

  if IsCodeSnippet(SelectedNode) then
    SelectedNode := SelectedNode.Parent;

  TopicName := GetUniqueTopicName(SelectedNode, False);
  NewFileName := AddSlash(GetNodePath(SelectedNode)) + TopicName;
  CodeDB.OpenFile(NewFileName);
  Assert(CodeDB.FileExists(NewFileName));
  CodeDB.SetAttribute(AttrTopic, TopicName);

  LangType := GetIdentifierForCurrentSyntaxMode;
  CodeDB.SetAttribute(AttrLanguage, LangType);
  CodeDB.SaveStorage;

  NewNode := tvTopics.Items.AddChild(SelectedNode, TopicName);
  NewNode.ImageIndex := ImageIndexDocument;
  NewNode.SelectedIndex := ImageIndexDocument;

  SortNodes;
  tvTopics.Selected := NewNode;
  NewNode.EditText;
  actEditReadOnly.Checked := False;
  FCodeText.ReadOnly := False;
end;

procedure TfmCodeLib.CodeTextChange(Sender: TObject);
begin
  Modified := FCodeText.Modified;
end;

procedure TfmCodeLib.tvTopicsChanging(Sender: TObject; Node: TTreeNode;
  var AllowChange: Boolean);
begin
  if (tvTopics.Selected <> nil) and Modified then
    SaveRecord;
  // Do not alter value of AllowChange.
end;

procedure TfmCodeLib.SaveRecord;
var
  LangType: TGXUnicodeString;
  SelectedNode: TTreeNode;
begin
  // This is called from the destructor where
  // we may be in a forced clean-up state due
  // to an exception in the constructor.
  if ExceptObject <> nil then
    Exit; //==>

  Modified := False;
  if not TryGetSelected(SelectedNode) then
    Exit; //==>

  SetNodeAttribute(SelectedNode, AttrTopic, SelectedCaption);
  if FolderSelected then
  begin
    Assert(CodeDB.FolderExists(GetNodePath(SelectedNode)));
  end
  else
  begin
    CodeDB.FileText :=  FCodeText.AsUnicodeString;
    LangType := GetIdentifierForCurrentSyntaxMode;
    CodeDB.SetAttribute(AttrLanguage, LangType);

    CodeDB.SaveStorage;
  end;
end;

procedure TfmCodeLib.tvTopicsEdited(Sender: TObject; Node: TTreeNode; var S: string);
var
  NewFileName: TGXUnicodeString;
begin
  Modified := True;
  AssertValidFileName(S);
  NewFileName := AddSlash(GetNodeParentPath(Node)) + S;
  if CodeDB.FileExists(NewFileName) or CodeDB.FolderExists(NewFileName) then
    raise Exception.CreateFmt('An item named %s already exists.', [S]);
  SetNodeAttribute(Node, AttrTopic, S);
  CodeDB.Move(GetNodePath(Node), NewFileName);
  SortNodes;
end;

procedure TfmCodeLib.tvTopicsChange(Sender: TObject; Node: TTreeNode);
var
  LangType: TGXUnicodeString;
begin
  try
    if (Node <> nil) and (IsCodeSnippet(Node)) then
    begin
      CodeDB.OpenFile(GetNodePath(Node));
      FCodeText.BeginUpdate;
      try
        LangType := CodeDB.AttributeAsString(AttrLanguage, 'P');
        SetCurrentSyntaxModeFromIdentifier(LangType);
        FCodeText.AsUnicodeString := CodeDB.FileText;
        FCodeText.Modified := False;
      finally
        FCodeText.EndUpdate;
      end;
      FCodeText.ReadOnly := actEditReadOnly.Checked;
    end
    else
      FCodeText.Clear;

    Modified := False;
    if Node <> nil then
      StatusBar.Panels[STATUS_PANEL_PATH].Text := GetNodePath(Node);
  except
    on E: Exception do
      GxLogAndShowException(E);
  end;
end;

procedure TfmCodeLib.DeleteExecute(Sender: TObject);
resourcestring
  SSnippet = 'snippet';
  SFolder = 'folder';
  SConfirmDelete = 'Delete %s "%s"?';
var
  NodeType: TGXUnicodeString;
  SelectedNode: TTreeNode;
begin
  if not TryGetSelected(SelectedNode) then
    Exit; //==>

  if FolderSelected then
    NodeType := SFolder
  else
    NodeType := SSnippet;
  if MessageDlg(Format(SConfirmDelete, [NodeType, SelectedNode.Text]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    CodeDB.Delete(SelectedNodeFullName);
    SelectedNode.Delete;
  end;
end;

procedure TfmCodeLib.PrinterSetupExecute(Sender: TObject);
begin
  dlgPrinterSetup.Execute;
end;

procedure TfmCodeLib.PrintExecute(Sender: TObject);
resourcestring
  RS_PRINTTITLE = 'GExperts';
var
  Node: TTreeNode;
begin
  if TryGetSelected(Node) then
    FCodeText.Print(Node.Text)
  else
    FCodeText.Print(RS_PRINTTITLE);
end;

procedure TfmCodeLib.ExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TfmCodeLib.CutExecute(Sender: TObject);
begin
  FCodeText.CutToClipboard;
end;

procedure TfmCodeLib.CopyExecute(Sender: TObject);
begin
  FCodeText.CopyToClipboard;
end;

procedure TfmCodeLib.PasteExecute(Sender: TObject);
begin
  if not FCodeText.ReadOnly then
    FCodeText.PasteFromClipBoard
end;

procedure TfmCodeLib.HelpAboutExecute(Sender: TObject);
begin
  ShowGXAboutForm;
end;

resourcestring
  SNotForFormFiles = 'Copy/Paste is not allowed in form files.';

procedure TfmCodeLib.CopyFromIdeExecute(Sender: TObject);
var
  FileName: TGXUnicodeString;
begin
  FileName := GxOtaGetCurrentSourceFile;
  if IsForm(FileName) then
    raise Exception.Create(SNotForFormFiles);

  FCodeText.SelText := GxOtaGetCurrentSelection;
  FCodeText.ReadOnly := False;
  actEditReadOnly.Checked := False;
end;

procedure TfmCodeLib.PasteToIdeExecute(Sender: TObject);
var
  FileName: TGXUnicodeString;
begin
  FileName := GxOtaGetCurrentSourceFile;
  if IsForm(FileName) then
    raise Exception.Create(SNotForFormFiles);

  GxOtaInsertTextIntoEditor(FCodeText.Text);
  Hide;
end;

procedure TfmCodeLib.FindExecute(Sender: TObject);
var
  frm: TfmCodeSearch;
begin
  frm := TfmCodeSearch.Create(nil);
  try
    try
      if frm.ShowModal = mrOk then begin
        FSearch.Text := frm.edSearch.Text;
        FSearch.CaseSensitive := frm.cbCaseSensitive.Checked;
        FSearch.WholeWord := frm.cbWholeWord.Checked;
        DoSearch(True);
      end;
    finally
      frm.Free;
    end;
  except
    on E: Exception do
      GxLogAndShowException(E);
  end;
end;

procedure TfmCodeLib.DoSearch(First: Boolean);

  function DoMatch(const Text: TGXUnicodeString): Integer;
  var
    MatchPos: Integer;
  begin
    Result := -1;

    if FSearch.CaseSensitive then
      MatchPos := AnsiPos(FSearch.Text, Text)
    else
      MatchPos := AnsiCaseInsensitivePos(FSearch.Text, Text);

    if (MatchPos > 0) and FSearch.WholeWord then
    begin
      // If the previous character is alphabetic, there isn't a match
      if MatchPos > 1 then
        if IsCharAlphaW(Text[MatchPos - 1]) then
          Exit;
      // If the next character is alphabetic, we didn't find a word match
      if MatchPos + Length(FSearch.Text) <= Length(Text) then
        if IsCharAlphaW(Text[MatchPos + Length(FSearch.Text)]) then
          Exit;
    end;
    Result := MatchPos;
  end;

var
  Node: TTreeNode;
  Match: Integer;
  InTopic: Boolean;
  FirstLoop: Boolean;
  NodePath: TGXUnicodeString;
  IsSnippet: Boolean;
begin
  try
    Node := nil;
    if not First then
    begin
      //if ActiveControl = FCodeText then
        Node := tvTopics.Selected
      //else
      //  Node := tvTopics.Selected.GetNext;
    end;
    if First or (Node = nil) then
      Node := tvTopics.Items.GetFirstNode;
    Match := 0;
    InTopic := False;
    FirstLoop := True;
    while Node <> nil do
    begin
      NodePath := GetNodePath(Node);
      IsSnippet := IsCodeSnippet(Node);
      if IsSnippet then
        CodeDB.OpenFile(NodePath)
      else
        CodeDB.CloseFile;
      //{$IFOPT D+}SendDebug('Starting search from '+Node.Text+ ' for '+IntToStr(Integer(Node.Data)));{$ENDIF}
      begin
        //{$IFOPT D+}SendDebug('Found the key: '+IntToStr(Integer(Node.Data)));{$ENDIF}
        if FirstLoop and IsSnippet and (FCodeText.Focused) and (Length(FCodeText.SelText) > 0) then
        begin
          InTopic := False;
          Match := DoMatch(Copy(CodeDB.FileText, FCodeText.SelStart + Length(FCodeText.SelText) + 1));
          //{$IFOPT D+}SendDebug('InterText search found '+FSearch.Text+' at '+IntToStr(Match)+' in '+Copy(CodeDB.FieldByName('Code').AsString, GetByteSelStart + FCodeText.SelLength, 999999));{$ENDIF}
          if Match > 0 then
          begin
            //{$IFOPT D+}SendDebug('Found a match at position '+IntToStr(Match)+'("'+Copy(Copy(CodeDB.FieldByName('Code').AsString, GetByteSelStart + FCodeText.SelLength, 999999), 1, 15)+'")'+' SelStart = '+IntToStr(FCodeText.SelStart)+' SelLength = '+IntToStr(FCodeText.SelLength));{$ENDIF}
            //FCodeText.Perform(EM_LINEFROMCHAR, FCodeText.SelStart, 0);
            Match := Match + FCodeText.SelStart + Length(FCodeText.SelText);
            //{$IFOPT D+}SendDebug('Matched Text: "'+Copy(CodeDB.FieldByName('Code').AsString, Match, 12)+'"');{$ENDIF}
          end;
        end
        else // Search the complete topic and code text
        begin
          if not FirstLoop then
          begin
            InTopic := True;
            Match := DoMatch(Node.Text);
          end;
          //{$IFOPT D+}SendDebug('Topic match on '+CodeDB.FieldByName(AttrTopic).AsString+' returned '+IntToStr(Match));{$ENDIF}
          if (Match = 0) and IsSnippet then
          begin
            Match := DoMatch(CodeDB.FileText);
            InTopic := False;
            //{$IFOPT D+}SendDebug('Code match on '+CodeDB.FieldByName('Code').AsString+' returned '+IntToStr(Match));{$ENDIF}
          end;
        end;
        if Match > 0 then Break;
      end;
      Node := Node.GetNext;
      FirstLoop := False;
    end;
    if Node = nil then
      SysUtils.Beep;
    if Match > 0 then
    begin
      //{$IFOPT D+}SendDebug('Found a match!  InTopic: '+BooleanText(InTopic));{$ENDIF}
      //{$IFOPT D+}SendDebug('Match Text: '+Copy(FCodeText.Lines.Text, Match, 10));{$ENDIF}
      tvTopics.Selected := Node;
      if InTopic then
        tvTopics.SetFocus
      else
      begin
        TWinControl_SetFocus(FCodeText);
        Dec(Match);
        FCodeText.SetSelection(Match, Length(FSearch.Text));
        //{$IFOPT D+}SendDebug('Focused Text: '+Copy(FCodeText.Lines.Text, Match - 1, 10));{$ENDIF}
      end;
    end;
  except
    on E: Exception do
      GxLogAndShowException(E);
  end;
end;

procedure TfmCodeLib.FindNextExecute(Sender: TObject);
begin
  if FSearch.Text <> '' then
    DoSearch(False)
  else
    actEditFind.Execute;
end;

procedure TfmCodeLib.tvTopicsDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  DestNode: TTreeNode;
  SelectedNode: TTreeNode;
begin
  try
    if not TryGetSelected(SelectedNode) then
      Exit; //==>

    DestNode := tvTopics.GetNodeAt(X, Y);
    if (DestNode = nil) or (DestNode = SelectedNode) then
      Exit; //==>

    if IsCodeSnippet(DestNode) or DestNode.HasAsParent(SelectedNode) then
      Exit; //==>

    CodeDB.Move(SelectedNodeFullName, AddSlash(GetNodePath(DestNode)) + SelectedCaption);
    CodeDB.SaveStorage;
    SelectedNode.MoveTo(DestNode, naAddChild);
    DestNode.AlphaSort;
  except
    on E: Exception do
      GxLogAndShowException(E);
  end;
end;

procedure TfmCodeLib.tvTopicsDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept := (Source = Sender);
end;

procedure TfmCodeLib.ExpandAllExecute(Sender: TObject);
var
  Node: TTreeNode;
begin
  Node := tvTopics.Items.GetFirstNode;
  while Node <> nil do
  begin
    Node.Expand(True);
    Node := Node.GetNextSibling;
  end;
end;

procedure TfmCodeLib.ContractAllExecute(Sender: TObject);
var
  Node: TTreeNode;
  SelectedNode: TTreeNode;
begin
  // OnChanging doesn't fire under Delphi 5 when calling Collapse below
  if TryGetSelected(SelectedNode) and Modified then
    SaveRecord;

  Node := tvTopics.Items.GetFirstNode;
  while Node <> nil do
  begin
    Node.Collapse(True);
    Node := Node.GetNextSibling;
  end;

  // OnChange doesn't fire under Delphi 5 when calling Collapse above
  tvTopicsChange(tvTopics, SelectedNode);
end;

procedure TfmCodeLib.SaveSettings;
var
  Settings: IExpertSettings;
begin
  Settings := TCodeLibrarianExpert.GetSettings;
  // Do not localize any of the following lines.
  Settings.WriteString('StoragePath', StoragePath);
  Settings.SaveFont('Editor', FCodeText.Font);
  Settings.SaveFont('TreeView', tvTopics.Font);

  Settings.SaveForm('Window', Self);
  Settings := Settings.Subkey('Window');
  Settings.WriteInteger('Layout', Ord(Layout));
  if Layout = clSide then
    Settings.WriteInteger('Splitter', tvTopics.Width)
  else
    Settings.WriteInteger('Splitter', tvTopics.Height);
end;

procedure TfmCodeLib.LoadSettings;
var
  Settings: IExpertSettings;
begin
  Settings := TCodeLibrarianExpert.GetSettings;
  // Do not localize any of the following lines.
  StoragePath := Settings.ReadString('StoragePath', StoragePath);
  Settings.LoadFont('Editor', FCodeText.Font);
  Settings.LoadFont('TreeView', tvTopics.Font);

  Settings.LoadForm('Window', Self);
  Settings := Settings.Subkey('Window');
  Layout := TCodeLayout(Settings.ReadInteger('Layout', 0));
  if Layout = clSide then
    tvTopics.Width := Settings.ReadInteger('Splitter', tvTopics.Width)
  else
    tvTopics.Height := Settings.ReadInteger('Splitter', tvTopics.Height);
end;

procedure TfmCodeLib.HelpExecute(Sender: TObject);
begin
{$IFNDEF STANDALONE}
  GxContextHelp(Self, 17);
{$ENDIF STANDALONE}
end;

procedure TfmCodeLib.HelpContentsExecute(Sender: TObject);
begin
{$IFNDEF STANDALONE}
  GxContextHelpContents(Self);
{$ENDIF STANDALONE}
end;

procedure TfmCodeLib.StatusBarDblClick(Sender: TObject);
begin
  inherited;
  if TStatusBar_GetClickedPanel(StatusBar) = STATUS_PANEL_STATUS then
    actEditReadOnly.Execute;
end;

procedure TfmCodeLib.StatusBarResize(Sender: TObject);
begin
  TStatusBar_Resize(StatusBar, STATUS_PANEL_PATH);
end;

procedure TfmCodeLib.NewRootFolderExecute(Sender: TObject);
begin
  AddFolder(nil);
end;

procedure TfmCodeLib.NewSnippetExecute(Sender: TObject);
begin
  AddCode;
end;

procedure TfmCodeLib.NewFolderExecute(Sender: TObject);
begin
  AddFolder(tvTopics.Selected)
end;

procedure TfmCodeLib.OptionsExecute(Sender: TObject);
var
  lStoragePath: string;
  lLayout: TCodeLayout;
begin
  lStoragePath := StoragePath;
  lLayout := Layout;
  if TfmCodeOptions.Execute(Self, lStoragePath, lLayout, tvTopics.Font, FCodeText.Font) then begin
    if StoragePath <> lStoragePath then begin
      if CodeDB <> nil then
        CloseDB(True);
      FreeAndNil(CodeDB);
      tvTopics.Items.Clear;
      FCodeText.Clear;
      StoragePath := AddSlash(lStoragePath);
      CodeDB := OpenStorage(StoragePath + DefaultFileName);
      if CodeDB = nil then begin
        MessageDlg(SCouldNotCreateStorage, mtError, [mbOK], 0);
        Exit;
      end;
      InitializeTreeView;
    end;
    Layout := lLayout;
  end;
end;

procedure TfmCodeLib.tvTopicsStartDrag(Sender: TObject; var DragObject: TDragObject);
begin
  AutoScroll := True;
end;

procedure TfmCodeLib.tvTopicsEndDrag(Sender, Target: TObject; X, Y: Integer);
begin
  AutoScroll := False;
end;

procedure TfmCodeLib.MakeRootExecute(Sender: TObject);
var
  SelectedNode: TTreeNode;
begin
  if not TryGetSelected(SelectedNode) then
    Exit; //==>

  if (SelectedNode.Level > 0) and (not IsCodeSnippet(SelectedNode)) then
  begin
    CodeDB.Move(SelectedNodeFullName, CodeLibPathSep + SelectedCaption);
    SelectedNode.MoveTo(nil, naAdd);
    Modified := True;
    SortNodes;
  end;
end;

procedure TfmCodeLib.FormHide(Sender: TObject);
begin
  if FModified then
    SaveRecord;
  CloseDB;
end;

procedure TfmCodeLib.FormShow(Sender: TObject);
var
  Node: TTreeNode;
begin
  inherited;
  CodeDB.OpenStorage(StoragePath + DefaultFileName);
  if TryGetSelected(Node) and (IsCodeSnippet(Node)) then
    CodeDB.OpenFile(GetNodePath(Node));
end;

procedure TfmCodeLib.SortNodes;
begin
  tvTopics.AlphaSort;
end;

procedure TfmCodeLib.ActionsUpdate(Action: TBasicAction; var Handled: Boolean);
var
  HaveEditorSelection: Boolean;
  lHaveSelectedNode: Boolean;
  SnippetIsSelected: Boolean;
  i: Integer;
  SelectedNode: TTreeNode;
begin
  HaveEditorSelection := Length(FCodeText.SelText) > 0;
  actEditCut.Enabled := HaveEditorSelection;
  actEditCopy.Enabled := HaveEditorSelection;
  actEditPaste.Enabled := (Clipboard.HasFormat(CF_TEXT) and (not FCodeText.ReadOnly));

  lHaveSelectedNode  := TryGetSelected(SelectedNode);
  SnippetIsSelected := lHaveSelectedNode and IsCodeSnippet(SelectedNode);

  actEditPasteToIde.Enabled := SnippetIsSelected and not IsStandalone;
  actEditCopyFromIde.Enabled := SnippetIsSelected and not IsStandalone;
  actDelete.Enabled := lHaveSelectedNode;
  actEditRename.Enabled := lHaveSelectedNode;
  actEditReadOnly.Enabled := SnippetIsSelected;
  if actEditReadOnly.Checked then
    actEditReadOnly.ImageIndex := 90
  else
    actEditReadOnly.ImageIndex := 91;

  if not lHaveSelectedNode then
  begin
    actMakeRoot.Enabled := True;
    actNewSnippet.Enabled := False;
  end
  else
  begin
    actMakeRoot.Enabled := True;
    actNewSnippet.Enabled := True;
    actMakeRoot.Enabled := True;
  end;

  for i := 0 to Actions.ActionCount - 1 do begin
    if SameText(Actions[i].Category, SyntaxCategory) then
      (Actions[i] as TCustomAction).Checked := Actions[i].Tag = Ord(FCurrentSyntaxMode);
  end;
  FCodeText.Enabled := SnippetIsSelected;
  FCodeText.ReadOnly := not SnippetIsSelected or actEditReadOnly.Checked;
  StatusBar.Panels[2].Text := GXSyntaxInfo[FCurrentSyntaxMode].Name;

  Handled := True;
end;

procedure TfmCodeLib.actEditReadOnlyExecute(Sender: TObject);
var
  b: Boolean;
begin
  b := not actEditReadOnly.Checked;
  FCodeText.ReadOnly := b;
  actEditReadOnly.Checked := b;

  Modified := FCodeText.Modified;

  if not b and FCodeText.CanFocus then
    TWinControl_SetFocus(FCodeText)
  else
    TWinControl_SetFocus(tvTopics);
end;

procedure TfmCodeLib.GenericSyntaxHighlightingExecute(Sender: TObject);
begin
  Modified := True;
  if (Sender is TCustomAction) and (TCustomAction(Sender).Category = SyntaxCategory) then
    SetCurrentSyntaxModeFromIdentifier(TCustomAction(Sender).Hint);
end;

procedure TfmCodeLib.SetupSyntaxHighlightingControl;
begin
  FCurrentSyntaxMode := gxpPas;
  FCodeText := TGXEnhancedEditor.Create(Self);
  FCodeText.Highlighter := FCurrentSyntaxMode;
  FCodeText.Align := alClient;
  FCodeText.PopupMenu := pmCode;
  FCodeText.OnChange := CodeTextChange;
  FCodeText.Parent := pnlView;
  FCodeText.ReadOnly := True;
  FCodeText.WantTabs := True;
  FCodeText.TabWidth := GxOtaGetTabWidth;
end;

constructor TfmCodeLib.Create(AOwner: TComponent);
begin
  inherited;

  TControl_SetMinConstraints(Self);
  SetNonModalFormPopupMode(Self);
  SetToolbarGradient(ToolBar);
  SetupSyntaxHighlightingControl;

  InitDpiScaler;

  TCursor_TempHourglass;

  CodeDB := nil;
  {$IFOPT D+}SendDebug('Setting CodeLib storage path');{$ENDIF}
  StoragePath := AddSlash(ConfigInfo.ConfigPath);
  {$IFOPT D+}SendDebug('Storage path: ' + StoragePath);{$ENDIF}
  FLayout := clSide;

  FModified := False;
  CenterForm(Self);
  {$IFOPT D+}SendDebug('Loading CodeLib settings');{$ENDIF}
  LoadSettings;
  {$IFOPT D+}SendDebug('Opening CodeLib storage');{$ENDIF}
  CodeDB := OpenStorage(StoragePath + DefaultFileName); // do not localize
  if CodeDB = nil then
  begin
    MessageDlg(SCouldNotCreateStorage, mtError, [mbOK], 0);
    Exit;
  end;
  {$IFOPT D+}SendDebug('Opened storage file');{$ENDIF}
  InitializeTreeView;
  InitializeSyntaxLanguages;
  FModified := False;
end;

destructor TfmCodeLib.Destroy;
begin
  if FModified then
    SaveRecord;

  {$IFOPT D+}SendDebug('Saving code librarian settings');{$ENDIF}
  SaveSettings;

  {$IFOPT D+}SendDebug('Freeing CodeDB');{$ENDIF}
  CloseDB(True);
  FreeAndNil(CodeDB);

  inherited;
end;

{$IFDEF GX_IDE_IS_HIDPI_AWARE}
procedure TfmCodeLib.ApplyDpi(_NewDpi: Integer; _NewBounds: PRect);
var
  il: TImageList;
begin
  inherited;
  il := GExpertsInst.GetScaledSharedDisabledImages(_NewDpi);
  ToolBar.DisabledImages := il;

  il := GExpertsInst.GetScaledSharedImages(_NewDpi);
  ToolBar.Images := il;
  Actions.Images := il;
  MainMenu.Images := il;
end;
{$ENDIF}

procedure TfmCodeLib.tvTopicsDblClick(Sender: TObject);
var
  Node: TTreeNode;
begin
  if TryGetSelected(Node) then begin
    if IsCodeSnippet(Node) then
      actEditPasteToIde.Execute;
  end;
end;

procedure TfmCodeLib.actEditRenameExecute(Sender: TObject);
var
  Node: TTreeNode;
begin
  if TryGetSelected(Node) then
    Node.EditText;
end;

procedure TfmCodeLib.tvTopicsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Node: TTreeNode;
begin
  // RightClickSelect in Delphi 5/6 is totally useless, so this is a workaround
  if Button = mbRight then
  begin
    Node := tvTopics.GetNodeAt(X, Y);
    if Node <> nil then
      tvTopics.Selected := Node;
  end;
end;

procedure TfmCodeLib.CloseDB(ClearFileName: Boolean);
begin
  if CodeDB <> nil then
    CodeDB.CloseStorage;
end;

procedure TfmCodeLib.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then
  begin
    Key := #0;
    actExit.Execute;
  end;
end;

procedure TfmCodeLib.tvTopicsCompare(Sender: TObject; Node1, Node2: TTreeNode; Data: Integer; var Compare: Integer);
begin
  Compare := lstrcmp(PChar(Node1.Text), PChar(Node2.Text));
  if IsCodeSnippet(Node1) and (not IsCodeSnippet(Node2)) then
    Compare := 1
  else if IsCodeSnippet(Node2) and (not IsCodeSnippet(Node1)) then
    Compare := -1;
end;

function TfmCodeLib.GetNodeParentPath(Node: TTreeNode): TGXUnicodeString;
begin
  Assert(Assigned(Node));
  Result := CodeLibPathSep;
  if Assigned(Node.Parent) then
    Result := GetNodePath(Node.Parent);
end;

procedure TfmCodeLib.actCompactStorageExecute(Sender: TObject);
begin
  CodeDB.CompactStorage;
  InitializeTreeView;
end;

function TfmCodeLib.IsCodeSnippet(Node: TTreeNode): Boolean;
begin
  Assert(Assigned(Node));
  Result := Node.ImageIndex = ImageIndexDocument;
end;

procedure TfmCodeLib.AssertValidFileName(const FileName: TGXUnicodeString);
resourcestring
  SlashError = 'The slash characters are not allowed in topic names';
  EmptyError = 'Blank names are not allowed';
begin
  if (Pos('/', FileName) > 0) or (Pos('\', FileName) > 0) then
    raise Exception.Create(SlashError);
  if FileName = '' then
    raise Exception.Create(EmptyError);
end;

function TfmCodeLib.GetNodePath(Node: TTreeNode): TGXUnicodeString;

  function GetPath(const Prefix: TGXUnicodeString; Node: TTreeNode): TGXUnicodeString;
  begin
    if not Assigned(Node) then
      Result := Prefix
    else
      Result := MakeFileName(GetPath(Prefix, Node.Parent), Node.Text);
  end;

begin
  Result := CodeLibPathSep;
  if not Assigned(Node) then
    Exit;
  Result := GetPath(Result, Node);
end;

function TfmCodeLib.TryGetSelected(out _Node: TTreeNode): Boolean;
begin
  _Node := tvTopics.Selected;
  Result := Assigned(_Node);
end;

function TfmCodeLib.SelectedNodeFullName: TGXUnicodeString;
var
  Node: TTreeNode;
begin
  AssertNodeSelected(Node);
  Result := GetNodePath(Node);
end;

function TfmCodeLib.SelectedCaption: TGXUnicodeString;
var
  SelectedNode: TTreeNode;
begin
  AssertNodeSelected(SelectedNode);
  Result := SelectedNode.Text;
end;

procedure TfmCodeLib.AssertNodeSelected(out _SelectedNode: TTreeNode);
begin
  if not TryGetSelected(_SelectedNode) then
    raise Exception.Create('No node selected');
end;

function TfmCodeLib.FolderSelected: Boolean;
var
  SelectedNode: TTreeNode;
begin
  AssertNodeSelected(SelectedNode);
  Result := IsFolder(SelectedNode);
end;

function TfmCodeLib.IsFolder(Node: TTreeNode): Boolean;
begin
  Assert(Assigned(Node));
  Result := Node.ImageIndex = ImageIndexClosedFolder;
end;

procedure TfmCodeLib.SetNodeAttribute(Node: TTreeNode; const AttrName, AttrValue: TGXUnicodeString);
var
  ObjectName: TGXUnicodeString;
begin
  Assert(Assigned(Node));
  ObjectName := GetNodePath(Node);
  CodeDB.AssertExistingObjectName(ObjectName);
  CodeDB.SetObjectAttribute(ObjectName, AttrName, AttrValue);
end;

{ TReadOnlyCodeLibDBMessage }

function TReadOnlyCodeLibFileMessage.GetMessage: string;
resourcestring
  ReadOnlyCodeLibDBMsg = 'Your code librarian storage file is read only. ' +
    'Any changes you make will not be saved.';
begin
  Result := ReadOnlyCodeLibDBMsg;
end;

{ TCodeLibrarianExpert }

destructor TCodeLibrarianExpert.Destroy;
begin
  FreeAndNil(FCodeLibForm);
  inherited;
end;

procedure TCodeLibrarianExpert.SetActive(New: Boolean);
begin
  if New <> Active then
  begin
    inherited SetActive(New);
    if New then //FI:W505
    else
    begin
      if Assigned(FCodeLibForm) then
      begin
        if FCodeLibForm.Visible then
          FCodeLibForm.Close;

        FreeAndNil(FCodeLibForm);
      end;
    end;
  end;
end;

function TCodeLibrarianExpert.GetActionCaption: string;
resourcestring
  SMenuCaption = 'Code &Librarian';
begin
  Result := SMenuCaption;
end;

class function TCodeLibrarianExpert.GetName: string;
begin
  Result := 'CodeLibrarian';
end;

procedure TCodeLibrarianExpert.Execute(Sender: TObject);
resourcestring
  SSetConfigPath = 'You must set the configuration path in the GExperts Options dialog for the Code Librarian to work.';
begin
  {$IFOPT D+}SendDebug('Activating CodeLib expert');{$ENDIF}
  if ConfigInfo.ConfigPath = '' then
  begin
    MessageDlg(SSetConfigPath, mtInformation, [mbOK], 0);
    Exit;
  end;
  CreateCodeLibForm;
  if FCodeLibForm.WindowState = wsMinimized then
    FCodeLibForm.WindowState := wsNormal;
  {$IFOPT D+}SendDebug('Showing CodeLib form');{$ENDIF}
  FCodeLibForm.Show;
  IncCallCount;
end;

function TCodeLibrarianExpert.HasConfigOptions: Boolean;
begin
  Result := False;
end;

procedure TCodeLibrarianExpert.CreateCodeLibForm;
begin
  {$IFOPT D+}SendDebug('Creating CodeLib form');{$ENDIF}
  if FCodeLibForm = nil then
  begin
    FCodeLibForm := TfmCodeLib.Create(nil);
    SetFormIcon(FCodeLibForm);
  end;
end;

procedure ShowCodeLib;
var
  CodeLibStandAlone: TCodeLibrarianExpert;
begin
  {$IFOPT D+} SendDebug('Showing CodeLib expert'); {$ENDIF}
  CodeLibStandAlone := nil;
  InitSharedResources;
  try
    {$IFOPT D+} SendDebug('Created CodeLib window'); {$ENDIF}
    CodeLibStandAlone := TCodeLibrarianExpert.Create;
    CodeLibStandAlone.LoadSettings;
    CodeLibStandAlone.CreateCodeLibForm;
    CodeLibStandAlone.FCodeLibForm.ShowModal;
    CodeLibStandAlone.SaveSettings;
  finally
    FreeAndNil(CodeLibStandAlone);
    FreeSharedResources;
  end;
end;

{ TGXStorageFile }

procedure TGXStorageFile.AssertFileIsOpen;
begin
  if not Assigned(FFile) then
    raise Exception.Create('No file is currently open');
  if FFileName = '' then
    raise Exception.Create('The file name is blank');
end;

procedure TGXStorageFile.AssertValidFileName(FileName: TGXUnicodeString);
begin
  if FileName = '' then
    raise Exception.Create('The file name can not be blank');
  if FileName[1] = CodeLibPathSep then
    raise Exception.Create('The file name can not start with a slash: ' + FileName);
end;

procedure TGXStorageFile.AssertValidFolderName(FolderName: TGXUnicodeString);
begin
  if FolderName = '' then
    raise Exception.Create('FolderName can not be blank');
  if FolderName[1] <> CodeLibPathSep then
    raise Exception.Create('FolderName must start with a slash');
end;

function TGXStorageFile.AttributeAsString(const AttrName, Default: TGXUnicodeString): TGXUnicodeString;
var
  FileInfo: IGpStructuredFileInfo;
begin
  Result := Default;
  FileInfo := GetFileInfo;
  Result := FileInfo.GetAttribute(AttrName);
end;

procedure TGXStorageFile.CloseFile;
begin
  FreeAndNil(FFile);
end;

procedure TGXStorageFile.CloseStorage;
begin
  CloseFile;
  FStorage := nil;
end;

constructor TGXStorageFile.Create(const FileName: TGXUnicodeString);
begin
  inherited Create;
  OpenStorage(FileName);
end;

procedure TGXStorageFile.CreateFolder(const FolderName: TGXUnicodeString);
begin
  FStorage.CreateFolder(FolderName);
end;

procedure TGXStorageFile.Delete(const ObjectName: TGXUnicodeString);
begin
  Assert(Length(ObjectName) > 0);
  CloseFile;
  FStorage.Delete(ObjectName);
end;

function TGXStorageFile.FileExists(const FileName: TGXUnicodeString): Boolean;
begin
  Result := FStorage.FileExists(FileName);
end;

function TGXStorageFile.FolderExists(const FolderName: TGXUnicodeString): Boolean;
begin
  Result := FStorage.FolderExists(FolderName);
end;

function TGXStorageFile.GetFileInfo: IGpStructuredFileInfo;
begin
  AssertFileIsOpen;
  Result := FStorage.GetFileInfo(FFileName);
  if not Assigned(Result) then
    raise Exception.CreateFmt('The file %s does not exist to get the file info', [FFileName]);
end;

function TGXStorageFile.GetFileText: TGXUnicodeString;
var
  StringStream: TStringStream;
begin
  AssertFileIsOpen;
  StringStream := TStringStream.Create('');
  try
    StringStream.CopyFrom(FFile, 0);
    Result := StringStream.DataString;
  finally
    FreeAndNil(StringStream);
  end;
end;

procedure TGXStorageFile.ListFiles(const FolderName: TGXUnicodeString; Files: TStrings);
begin
  AssertValidFolderName(FolderName);
  FStorage.FileNames(FolderName, Files);
end;

procedure TGXStorageFile.ListFolders(const FolderName: TGXUnicodeString; Files: TStrings);
begin
  AssertValidFolderName(FolderName);
  FStorage.FolderNames(FolderName, Files);
end;

procedure TGXStorageFile.Move(const OldName, NewName: TGXUnicodeString);
begin
  if OldName = NewName then
    Exit;
  FStorage.Move(OldName, NewName);
  if SameFileName(FFileName, OldName) then
    OpenFile(NewName);
end;

procedure TGXStorageFile.OpenFile(const FolderName, FileName: TGXUnicodeString);
begin
  AssertValidFolderName(FolderName);
  AssertValidFileName(FileName);
  OpenFile(MakeFileName(FolderName, FileName));
end;

procedure TGXStorageFile.OpenStorage(const FileName: WideString);
begin
  if not Assigned(FStorage) then begin
    FStorage := CreateStructuredStorage;
    if SysUtils.FileExists(FileName) then
      FStorage.Initialize(FileName, fmOpenReadWrite)
    else
      FStorage.Initialize(FileName, fmCreate or fmOpenReadWrite);
  end;
end;

procedure TGXStorageFile.OpenFile(const FullPath: TGXUnicodeString);
begin
  FreeAndNil(FFile);
  Assert(Assigned(FStorage));
  AssertValidFolderName(FullPath);
  Assert(Length(FullPath) > 0);
  FFile := FStorage.OpenFile(FullPath, fmCreate or fmOpenReadWrite);
  FFileName := FullPath;
end;

procedure TGXStorageFile.CompactStorage;
begin
  FreeAndNil(FFile);
  FStorage.Compact;
end;

procedure TGXStorageFile.SaveStorage;
begin
  //FStorage.Save;
  { TODO -oAnyone -ccheck : Is this commented out on purpose? Or did somebody forget to reenable this code? }
end;

procedure TGXStorageFile.SetAttribute(const AttrName: TGXUnicodeString; const Value: Integer);
begin
  SetAttribute(AttrName, IntToStr(Value));
end;

procedure TGXStorageFile.SetAttribute(const AttrName: TGXUnicodeString; const Value: TGXUnicodeString);
var
  FileInfo: IGpStructuredFileInfo;
begin
  AssertFileIsOpen;
  FileInfo := GetFileInfo;
  FileInfo.Attribute[AttrName] := Value;
end;

procedure TGXStorageFile.SetFileText(const Value: TGXUnicodeString);
var
  StringStream: TStringStream;
begin
  AssertFileIsOpen;
  StringStream := TStringStream.Create(Value);
  try
    FFile.Size := StringStream.Size;
    FFile.Position := 0;
    FFile.CopyFrom(StringStream, 0);
  finally
    FreeAndNil(StringStream);
  end;
end;

procedure TGXStorageFile.SetObjectAttribute(const ObjectName, AttrName, AttrValue: TGXUnicodeString);
var
  FileInfo: IGpStructuredFileInfo;
begin
  FileInfo := FStorage.FileInfo[ObjectName];
  Assert(Assigned(FileInfo));
  FileInfo.Attribute[AttrName] := AttrValue;
end;

function TGXStorageFile.GetObjectAttribute(const ObjectName, AttrName: TGXUnicodeString): TGXUnicodeString;
var
  FileInfo: IGpStructuredFileInfo;
begin
  AssertExistingObjectName(ObjectName);
  FileInfo := FStorage.FileInfo[ObjectName];
  Assert(Assigned(FileInfo));
  Result := FileInfo.Attribute[AttrName];
end;

procedure TGXStorageFile.AssertExistingObjectName(const ObjectName: TGXUnicodeString);
begin
  Assert(ObjectExists(ObjectName), ObjectName + ' does not exist');
end;

function TfmCodeLib.GetUniqueTopicName(ParentNode: TTreeNode; Folder: Boolean): TGXUnicodeString;
resourcestring
  FolderPrefix = 'Folder ';
  SnippetPrefix = 'Snippet ';
var
  i: Integer;
  TopicName: TGXUnicodeString;
  ParentPath: TGXUnicodeString;
  TestName: TGXUnicodeString;
begin
  if Folder then
    TopicName := FolderPrefix
  else
    TopicName := SnippetPrefix;
  ParentPath := AddSlash(GetNodePath(ParentNode));
  for i := 1 to 101 do
  begin
    TestName := TopicName + IntToStr(i);
    CodeDB.AssertValidFolderName(ParentPath + TestName);
    if not CodeDB.ObjectExists(ParentPath + TestName) then
    begin
      Result := TestName;
      Exit;
    end;
  end;
  raise Exception.Create('Unable to find a unique folder name under ' + ParentPath);
end;

function TGXStorageFile.ObjectExists(const ObjectName: TGXUnicodeString): Boolean;
begin
  Result := FileExists(ObjectName) or FolderExists(ObjectName);
end;

procedure TfmCodeLib.InitializeSyntaxLanguages;
var
  i: TGXSyntaxHighlighter;
  Data: TGXSyntaxData;
  MenuItem: TMenuItem;
  Action: TAction;
begin
  mitEditorHighlighting.Clear;
  FCurrentSyntaxMode := gxpPAS;
  for i := Low(GXSyntaxInfo) to High(GXSyntaxInfo) do
  begin
    Data := GXSyntaxInfo[i];
    if Data.Visible then
    begin
      Action := TAction.Create(Self);
      Action.ActionList := Actions;
      Action.Caption := Data.Name;
      Action.OnExecute := GenericSyntaxHighlightingExecute;
      Action.Category := SyntaxCategory;
      Action.Hint := Data.Identifier; // Hint is the language identifier
      Action.Tag := Ord(i);
      MenuItem := TMenuItem.Create(Self);
      MenuItem.Action := Action;
      mitEditorHighlighting.Add(MenuItem);
    end;
  end;
end;

function TfmCodeLib.GetIdentifierForCurrentSyntaxMode: string;
begin
  Result := GXSyntaxInfo[FCurrentSyntaxMode].Identifier
end;

procedure TfmCodeLib.SetCurrentSyntaxModeFromIdentifier(const LangIdent: string);
var
  Syntax: TGXSyntaxHighlighter;
begin
  for Syntax := Low(GXSyntaxInfo) to High(GXSyntaxInfo) do
  begin
    if SameText(GXSyntaxInfo[Syntax].Identifier, LangIdent) then
    begin
      FCurrentSyntaxMode := Syntax;
      FCodeText.Highlighter := Syntax;
      Exit;
    end;
  end;
  // Fallback for unknown
  FCurrentSyntaxMode := gxpNone;
  FCodeText.Highlighter := gxpNone;
end;

initialization
  RegisterGX_Expert(TCodeLibrarianExpert);

end.

