{Search history author: (ERT) Ferenc Kiffer, Hungary <kifferferenc@yahoo.com>}

unit GX_GrepExpert;

interface

uses
  Windows,
  Classes, Graphics, IniFiles, Controls,
  GX_Experts, GX_ConfigurationInfo, GX_GrepBackend;

type
  TGrepExpert = class(TGX_Expert)
  private
    FHistoryIniVersion: Integer; //0: old, 1: renamed new, 2: multiINI/indexed new
    FGrepMiddle: Boolean;
    FGrepExpandAll: Boolean;
    FGrepExpandIf: Boolean;
    FGrepExpandIfFiles: Integer;
    FGrepExpandIfMatches: Integer;
    FGrepExpandFew: Boolean;
    FGrepExpandFewLines: Integer;
    FSearchList: TStrings;
    FReplaceList: TStrings;
    FMaskList: TStrings;
    FDirList: TStrings;
    FExcludedDirsList: TStrings;
    FGrepCaseSensitive: Boolean;
    FGrepCode: Boolean;
    FGrepStrings: Boolean;
    FGrepComments: Boolean;
    FGrepInterface: Boolean;
    FGrepImplementation: Boolean;
    FGrepInitialization: Boolean;
    FGrepFinalization: Boolean;
    FGrepForms: Boolean;
    FGrepFormsSpecialChars: Boolean;
    FGrepFormsMultiline: Boolean;
    FGrepSQLFiles: Boolean;
    FGrepAction: TGrepAction;
    FGrepSub: Boolean;
    FGrepWholeWord: Boolean;
    FGrepRegEx: Boolean;
    FGrepSaveOption: TGrepSaveOption;
    FGrepUseCurrentIdent: Boolean;
    FNumContextLines: Integer;
    FListFont: TFont;
    FListUseDefaultColors: Boolean;
    FListMatchTextColor: TColor;
    FListMatchBrushColor: TColor;
    FContextFont: TFont;
    FContextMatchColor: TColor;
    FAutoHide: Boolean;
    FContextMatchLineColor: TColor;
    FGrepSaveHistoryListItems: Integer;
    FHistoryList: TGrepHistoryList;
    FGrepOnlySaveParamsAction: Integer;
    FGrepFileListDeleteAfterDays: Boolean;
    FGrepHistoryListDefaultPage: Integer;
    FGrepDeleteAfterDays: Integer;
    FGrepSaveOptionDefaultValue: Integer;
    FGrepOpenSaveOptionDefaultValue: Integer;
    FGrepEmptyMoveToOnlySaveParams: Boolean;
    FGrepAdvancedOptions: Boolean;
    FGrepQuickRefresh: Boolean;
    FGrepHistoryPagesTabMultiline: Boolean;
    FGrepHistoryPagesTabWidth: Integer;
    FGrepMouseWheelPrevNextMatch: Boolean;
    FGrepUseMapFile: Boolean;
    FGrepMinDepth: Integer;
    FGrepMaxDepth: Integer;
    FExcludedDirsIsRegEx: Boolean;
    FExternalEditor: string;
    FExternalEditorParams: string;
    function  GetGrepSaveHistoryListItems(AIndex: Integer): Boolean;
    procedure SetSearchList(New: TStrings);
    procedure SetReplaceList(New: TStrings);
    procedure SetMaskList(New: TStrings);
    procedure SetDirList(New: TStrings);
    procedure SetExcludedDirsList(const Value: TStrings);
    procedure LoadHistoryList(AGrepSettings : TGrepSettings);
    function  FillGrepSettings: TGrepSettings;
    function  GetSaveOption: TGrepSaveOption;
    function  GetOpenSaveOption: TGrepSaveOption;
  protected
    function  CreateSettings: TCustomIniFile;
    procedure SetActive(New: Boolean); override;
    procedure InternalLoadSettings(_Settings: IExpertSettings); override;
    procedure InternalSaveSettings(_Settings: IExpertSettings); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure ShowModal;
    procedure ShowStandAlone(const _Directory: string);
    function GetDefaultShortCut: TShortCut; override;
    function GetActionCaption: string; override;
    function CanHaveShortCut: boolean; override;
    class function ConfigurationKey: string; override;
    class function GetName: string; override;
    function GetHelpString: string; override;
    ///<summary>
    /// @returns false, because we now group the Grep menu items in a submenu </summary>
    function HasMenuItem: Boolean; override;

    function  GrepConfigPath: String;
    function  GrepHistorySettingsFileName: String;

    procedure Execute(Sender: TObject); override;
    procedure Configure(_Owner: TWinControl); override;
    procedure HistoryListSaveSettings(AItemIndex: Integer = -1); //if -1 then all
    procedure HistoryListSaveSearchListSettings;
    procedure HistoryListDeleteFromSettings(ADelMode: TGrepDeleteMode; AItemIndex: Integer = -1); //if -1 then all

    property GrepMiddle: Boolean read FGrepMiddle write FGrepMiddle;
    property GrepExpandAll: Boolean read FGrepExpandAll write FGrepExpandAll;
    property GrepExpandIf: Boolean read FGrepExpandIf write FGrepExpandIf;
    property GrepExpandIfFiles: Integer read FGrepExpandIfFiles write FGrepExpandIfFiles;
    property GrepExpandIfMatches: Integer read FGrepExpandIfMatches write FGrepExpandIfMatches;
    property GrepExpandFew: Boolean read FGrepExpandFew write FGrepExpandFew;
    property GrepExpandFewLines: Integer read FGrepExpandFewLines write FGrepExpandFewLines;
    property GrepCaseSensitive: Boolean read FGrepCaseSensitive write FGrepCaseSensitive;
    property GrepCode: Boolean read FGrepCode write FGrepCode;
    property GrepStrings: Boolean read FGrepStrings write FGrepStrings;
    property GrepComments: Boolean read FGrepComments write FGrepComments;
    property GrepInterface: Boolean read FGrepInterface write FGrepInterface;
    property GrepImplementation: Boolean read FGrepImplementation write FGrepImplementation;
    property GrepInitialization: Boolean read FGrepInitialization write FGrepInitialization;
    property GrepFinalization: Boolean read FGrepFinalization write FGrepFinalization;
    property GrepForms: Boolean read FGrepForms write FGrepForms;
    property GrepFormsMultiline: Boolean read FGrepFormsMultiline write FGrepFormsMultiline;
    property GrepFormsSpecialChars: Boolean read FGrepFormsSpecialChars write FGrepFormsSpecialChars;
    property GrepSQLFiles: Boolean read FGrepSQLFiles write FGrepSQLFiles;
    property GrepAction: TGrepAction read FGrepAction write FGrepAction;
    property GrepSub: Boolean read FGrepSub write FGrepSub;
    property GrepWholeWord: Boolean read FGrepWholeWord write FGrepWholeWord;
    property GrepRegEx: Boolean read FGrepRegEx write FGrepRegEx;
    property GrepSaveOption: TGrepSaveOption read FGrepSaveOption write FGrepSaveOption;
    property GrepUseCurrentIdent: Boolean read FGrepUseCurrentIdent write FGrepUseCurrentIdent;
    property GrepUseMapFile: Boolean read FGrepUseMapFile write FGrepUseMapFile;
    property GrepMinDepth: Integer read FGrepMinDepth write FGrepMinDepth;
    property GrepMaxDepth: Integer read FGrepMaxDepth write FGrepMaxDepth;
    property NumContextLines: Integer read FNumContextLines write FNumContextLines;

    property GrepAdvancedOptions: Boolean read FGrepAdvancedOptions write FGrepAdvancedOptions;
    property GrepSaveOptionDefaultValue: Integer read FGrepSaveOptionDefaultValue write FGrepSaveOptionDefaultValue;
    property GrepOpenSaveOptionDefaultValue: Integer read FGrepOpenSaveOptionDefaultValue write FGrepOpenSaveOptionDefaultValue;
    property GrepFileListDeleteAfterDays: Boolean read FGrepFileListDeleteAfterDays write FGrepFileListDeleteAfterDays;
    property GrepDeleteAfterDays: Integer read FGrepDeleteAfterDays write FGrepDeleteAfterDays;
    property GrepEmptyMoveToOnlySaveParams: Boolean read FGrepEmptyMoveToOnlySaveParams write FGrepEmptyMoveToOnlySaveParams;
    property GrepOnlySaveParamsAction: Integer read FGrepOnlySaveParamsAction write FGrepOnlySaveParamsAction;
    property GrepHistoryListDefaultPage: Integer read FGrepHistoryListDefaultPage write FGrepHistoryListDefaultPage;
    property GrepQuickRefresh: Boolean read FGrepQuickRefresh write FGrepQuickRefresh;
    property GrepHistoryPagesTabMultiline: Boolean read FGrepHistoryPagesTabMultiline write FGrepHistoryPagesTabMultiline;
    property GrepHistoryPagesTabWidth: Integer read FGrepHistoryPagesTabWidth write FGrepHistoryPagesTabWidth;
    property GrepMouseWheelPrevNextMatch: Boolean read FGrepMouseWheelPrevNextMatch write FGrepMouseWheelPrevNextMatch;

    property ExternalEditor: string read FExternalEditor write FExternalEditor;
    property ExternalEditorParams: string read FExternalEditorParams write FExternalEditorParams;

    property SaveOption: TGrepSaveOption read GetSaveOption;
    property OpenSaveOption: TGrepSaveOption read GetOpenSaveOption;

    property ListFont: TFont read FListFont write FListFont;
    property ListUseDefaultColors: Boolean read FListUseDefaultColors write FListUseDefaultColors;
    property ListMatchTextColor: TColor read FListMatchTextColor write FListMatchTextColor;
    property ListMatchBrushColor: TColor read FListMatchBrushColor write FListMatchBrushColor;
    property ContextFont: TFont read FContextFont write FContextFont;
    property ContextMatchColor: TColor read FContextMatchColor write FContextMatchColor;
    property ContextMatchLineColor: TColor read FContextMatchLineColor write FContextMatchLineColor;
    property AutoHide: Boolean read FAutoHide write FAutoHide;

    property GrepSaveHistoryListItems: Boolean index 3 read GetGrepSaveHistoryListItems;
    property GrepSaveHistoryListItemsToIni: Boolean index 1 read GetGrepSaveHistoryListItems;
    property GrepSaveHistoryListItemsToReg: Boolean index 2 read GetGrepSaveHistoryListItems;

    property SearchList: TStrings read FSearchList write SetSearchList;
    property ReplaceList: TStrings read FReplaceList write SetReplaceList;
    property MaskList: TStrings read FMaskList write SetMaskList;
    property DirList: TStrings read FDirList write SetDirList;
    property ExcludedDirsList: TStrings read FExcludedDirsList write SetExcludedDirsList;
    property ExcludedDirsIsRegEx: Boolean read FExcludedDirsIsRegEx write FExcludedDirsIsRegEx;

    property HistoryIniVersion: Integer read FHistoryIniVersion;
    property HistoryList: TGrepHistoryList read FHistoryList;
  end;

var
  gblGrepExpert: TGrepExpert = nil;

procedure ShowGrep; {$IFNDEF GX_BCB} export; {$ENDIF GX_BCB}
///<summary>
/// These parameters are necessary to have this entry point called using rundll32.exe
/// https://support.microsoft.com/en-us/help/164787/info-windows-rundll-and-rundll32-interface
/// We only need the directory name. </summary>
procedure ShowGrepEx(_HWnd: HWND; _HInst: HINST; _CmdLine: PAnsiChar; nCmdShow: Integer); stdcall; {$IFNDEF GX_BCB} export; {$ENDIF GX_BCB}

implementation

uses
  SysUtils, Menus, ComCtrls,
  u_dzVclUtils,
  {$IFOPT D+} GX_DbugIntf, {$ENDIF D+}
  GX_OtaUtils, GX_GenericUtils,
  GX_GrepResults, GX_GrepResultsOptions,
  GX_IdeDock, GX_GExperts, GX_ActionBroker, GX_GrepOptions, GX_GrepMenuEntry;

{ TGrepExpert }

constructor TGrepExpert.Create;
begin
  inherited Create;

{$IFNDEF GX_STANDALONE}
  // since we no longer have a menu entry in the GExperts menu
  // we need to create an action here
  FActionInt := GxActionBroker.RequestAction(GetActionName, GetBitmap);
  FActionInt.OnExecute := Self.Execute;
  FActionInt.Caption := GetActionCaption;
{$ENDIF ~GX_STANDALONE}

  FSearchList := TStringList.Create;
  FReplaceList := TStringList.Create;
  FMaskList := TStringList.Create;
  FDirList := TStringList.Create;
  FExcludedDirsList := TStringList.Create;

  FListFont := TFont.Create;
  FListUseDefaultColors := True;
  FListMatchTextColor := clHighlightText;
  FListMatchBrushColor := clHighlight;
  FContextFont := TFont.Create;
  FContextMatchColor := clHighlight;
  FContextMatchLineColor := clHighlight;

  FNumContextLines := 2;
  FAutoHide := False;

  FHistoryList := TGrepHistoryList.Create;

  FGrepMinDepth := 0;
  FGrepMaxDepth := -1;

  FGrepAdvancedOptions := False;

  FGrepExpandAll := False;
  FGrepExpandIf := False;
  FGrepExpandIfFiles := 25;
  FGrepExpandIfMatches := 150;
  FGrepExpandFew := False;
  FGrepExpandFewLines := 20;
  FGrepUseCurrentIdent := False;
  FGrepSaveHistoryListItems := 0;
  FGrepHistoryPagesTabMultiline := True;

  FGrepSaveOption := gsoOnlySaveSettings;
  FGrepSaveOptionDefaultValue := Integer(gsoOnlySaveSettings);
  FGrepOpenSaveOptionDefaultValue := Integer(gsoNoSave);
  FGrepFileListDeleteAfterDays := True;
  FGrepDeleteAfterDays := 30;
  FGrepEmptyMoveToOnlySaveParams := False;
  FGrepOnlySaveParamsAction := 0;
  FGrepHistoryListDefaultPage := 0;
  FGrepQuickRefresh := False;

  FHistoryIniVersion := 0;

  fmGrepResults := TfmGrepResults.Create(nil);
  SetFormIcon(fmGrepResults);
  if not IsStandAlone then
    IdeDockManager.RegisterDockableForm(TfmGrepResults, fmGrepResults, 'fmGrepResults');
  gblGrepExpert := Self;
end;

destructor TGrepExpert.Destroy;
begin
  IdeDockManager.UnRegisterDockableForm(fmGrepResults, 'fmGrepResults');

  HistoryListSaveSettings;
  SaveSettings;

  FreeAndNil(FHistoryList);

  FreeAndNil(fmGrepResults);
  FreeAndNil(FSearchList);
  FreeAndNil(FReplaceList);
  FreeAndNil(FMaskList);
  FreeAndNil(FDirList);
  FreeAndNil(FExcludedDirsList);
  FreeAndNil(FListFont);
  FreeAndNil(FContextFont);

  inherited Destroy;
end;

function TGrepExpert.GetActionCaption: string;
resourcestring
  SMenuCaption = 'Grep &Results';
begin
  Result := SMenuCaption;
end;

function TGrepExpert.GetDefaultShortCut: TShortCut;
begin
  Result := Menus.ShortCut(Word('R'), [ssCtrl, ssAlt]);
end;

class function TGrepExpert.GetName: string;
begin
  Result := GrepResultsName;
end;

procedure TGrepExpert.Execute(Sender: TObject);
begin
  SetFormIcon(fmGrepResults);
  IdeDockManager.ShowForm(fmGrepResults);
  EnsureFormVisible(fmGrepResults);

  IncCallCount;
end;

procedure TGrepExpert.ShowModal;
begin
  fmGrepResults.ShowModal;
end;

procedure TGrepExpert.ShowStandAlone(const _Directory: string);
begin
  AddMRUString(_Directory, FDirList, True);
  fmGrepResults.Execute(gssNormal);
  fmGrepResults.Hide;
  fmGrepResults.ShowModal;
end;

procedure TGrepExpert.Configure(_Owner: TWinControl);
var
  frm: TfmGrepResultsOptions;
begin
  frm := TfmGrepResultsOptions.Create(_Owner);
  try
    Tform_CenterOn(frm, _Owner);
    frm.chkAdvanced.Checked := GrepAdvancedOptions;
    frm.chkAdvancedClick(nil);

    frm.chkGrepMiddle.Checked := GrepMiddle;
    frm.chkGrepExpandAll.Checked := GrepExpandAll;
    frm.chkGrepExpandIf.Checked := GrepExpandIf;
    frm.eExpandIfFiles.Text := IntToStr(GrepExpandIfFiles);
    frm.eExpandIfMatches.Text := IntToStr(GrepExpandIfMatches);
    frm.chkGrepExpandFew.Checked := GrepExpandFew;
    frm.eExpandFewLines.Text := IntToStr(GrepExpandFewLines);

    frm.chkDefaultListColors.Checked := ListUseDefaultColors;
    frm.pnlListFont.Font.Assign(ListFont);
    frm.pnlListMatchTextColor.Font.Assign(ListFont);
    frm.pnlListMatchTextColor.Font.Color := ListMatchTextColor;
    frm.pnlListMatchTextColor.Color := ListMatchBrushColor;
    frm.pnlListMatchBackgroundColor.Font.Assign(ListFont);
    frm.pnlListMatchBackgroundColor.Font.Color := ListMatchTextColor;
    frm.pnlListMatchBackgroundColor.Color := ListMatchBrushColor;

    frm.pnlContextFont.Font.Assign(ContextFont);
    frm.pnlContextMacthLineFontColor.Font.Assign(ContextFont);
    frm.pnlContextMacthLineFontColor.Font.Color := ContextMatchLineColor;
    frm.pnlContextMatchFontColor.Font.Assign(ContextFont);
    frm.pnlContextMatchFontColor.Font.Color := ContextMatchColor;

    frm.udContextLines.Position := NumContextLines;
    frm.chkGrepSaveHistoryListItems.Checked := GrepSaveHistoryListItems;
    frm.rbSaveToIniFile.Checked := GrepSaveHistoryListItemsToIni;
    frm.rbSaveToRegistry.Checked := GrepSaveHistoryListItemsToReg;

    frm.chkGrepAutoHide.Checked := AutoHide;

    frm.chkFileListDeleteAfterDays.Checked := GrepFileListDeleteAfterDays;
    frm.eDeleteAfterDays.Text := IntToStr(GrepDeleteAfterDays);
    frm.chkEmptyMoveToParams.Checked := GrepEmptyMoveToOnlySaveParams;
    frm.cbxSearchSaveOptionDefaultValue.ItemIndex := GrepSaveOptionDefaultValue;
    frm.cbxOpenSaveOptionDefaultValue.ItemIndex := GrepOpenSaveOptionDefaultValue;
    frm.cbxOnlySaveParamsAction.ItemIndex := GrepOnlySaveParamsAction;
    frm.cbxHistoryListDefaultPage.ItemIndex := GrepHistoryListDefaultPage;
    frm.chkQuickRefreshMode.Checked := GrepQuickRefresh;

    frm.chkHistoryPagesTabMultiLine.Checked := GrepHistoryPagesTabMultiline;
    frm.eHistoryPagesTabWidth.Text := IntToStr(GrepHistoryPagesTabWidth);
    frm.chkMouseWheelMoveItemIndex.Checked := GrepMouseWheelPrevNextMatch;

    if frm.ShowModal = mrOk then
    begin
      GrepAdvancedOptions := frm.chkAdvanced.Checked;

      GrepMiddle := frm.chkGrepMiddle.Checked;
      GrepExpandAll := frm.chkGrepExpandAll.Checked;
      GrepExpandIf := GrepAdvancedOptions and frm.chkGrepExpandIf.Checked;
      GrepExpandIfFiles := StrToIntDef(frm.eExpandIfFiles.Text, 25);
      GrepExpandIfMatches := StrToIntDef(frm.eExpandIfMatches.Text, 150);
      GrepExpandFew := GrepAdvancedOptions and frm.chkGrepExpandFew.Checked;
      GrepExpandFewLines := StrToIntDef(frm.eExpandFewLines.Text, 20);

      ListUseDefaultColors := frm.chkDefaultListColors.Checked;
      FListFont.Assign(frm.pnlListFont.Font);
      FContextFont.Assign(frm.pnlContextFont.Font);
      ListMatchTextColor := frm.pnlListMatchTextColor.Font.Color;
      ListMatchBrushColor := frm.pnlListMatchBackgroundColor.Color;
      ContextMatchLineColor := frm.pnlContextMacthLineFontColor.Font.Color;
      ContextMatchColor := frm.pnlContextMatchFontColor.Font.Color;

      NumContextLines := frm.udContextLines.Position;
      if GrepAdvancedOptions then
      begin
        if not frm.chkGrepSaveHistoryListItems.Checked then
          FGrepSaveHistoryListItems := 0
        else if frm.rbSaveToIniFile.Checked then
          FGrepSaveHistoryListItems := 1
        else if frm.rbSaveToRegistry.Checked then
          FGrepSaveHistoryListItems := 2;
      end
      else
      begin
        if not frm.chkGrepSaveHistoryListItems.Checked then
          FGrepSaveHistoryListItems := 0
        else
          FGrepSaveHistoryListItems := 1;
      end;

      GrepFileListDeleteAfterDays := frm.chkFileListDeleteAfterDays.Checked;
      GrepDeleteAfterDays := StrToIntDef(frm.eDeleteAfterDays.Text, 30);
      GrepSaveOptionDefaultValue := frm.cbxSearchSaveOptionDefaultValue.ItemIndex;
      GrepOpenSaveOptionDefaultValue := frm.cbxOpenSaveOptionDefaultValue.ItemIndex;
      GrepEmptyMoveToOnlySaveParams := GrepAdvancedOptions and frm.chkEmptyMoveToParams.Checked;
      GrepOnlySaveParamsAction := frm.cbxOnlySaveParamsAction.ItemIndex;
      GrepHistoryListDefaultPage := frm.cbxHistoryListDefaultPage.ItemIndex;
      GrepQuickRefresh := frm.chkQuickRefreshMode.Checked;

      if GrepAdvancedOptions then
      begin
        GrepHistoryPagesTabMultiline := frm.chkHistoryPagesTabMultiLine.Checked;
        GrepHistoryPagesTabWidth := StrToIntDef(frm.eHistoryPagesTabWidth.Text, GrepHistoryPagesTabWidth);
      end;

      GrepMouseWheelPrevNextMatch := GrepAdvancedOptions and frm.chkMouseWheelMoveItemIndex.Checked;

      AutoHide := frm.chkGrepAutoHide.Checked;
      SaveSettings;
    end;
  finally
    FreeAndNil(frm);
  end;
end;

procedure TGrepExpert.InternalSaveSettings(_Settings: IExpertSettings);
begin
  inherited InternalSaveSettings(_Settings);
  // do not localize any of the following lines
  _Settings.WriteInteger( 'HistoryIniVersion', FHistoryIniVersion);

  _Settings.WriteBool('CaseSensitive', GrepCaseSensitive);
  _Settings.WriteBool('Code', GrepCode);
  _Settings.WriteBool('Strings', GrepStrings);
  _Settings.WriteBool('NoComments', not GrepComments);
  _Settings.WriteBool('Interface', GrepInterface);
  _Settings.WriteBool('Implementation', GrepImplementation);
  _Settings.WriteBool('Initialization', GrepInitialization);
  _Settings.WriteBool('Finalization', GrepFinalization);
  _Settings.WriteBool('Forms', GrepForms);
  _Settings.WriteBool('FormsSpecialChars', GrepFormsSpecialChars);
  _Settings.WriteBool('FormsMultiline', GrepFormsMultiline);
  _Settings.WriteBool('SQLFiles', GrepSQLFiles);
  _Settings.WriteInteger('Search', Ord(GrepAction));
  _Settings.WriteBool('SubDirectories', GrepSub);
  _Settings.WriteBool('ExpandAll', GrepExpandAll);
  _Settings.WriteBool('ExpandIf', GrepExpandIf);
  _Settings.WriteInteger('ExpandIfFiles', GrepExpandIfFiles);
  _Settings.WriteInteger('ExpandIfMatches', GrepExpandIfMatches);
  _Settings.WriteBool('ExpandFew', GrepExpandFew);
  _Settings.WriteInteger('ExpandFewLines', GrepExpandFewLines);
  _Settings.WriteBool('Whole Word', GrepWholeWord);
  _Settings.WriteBool('Middle', GrepMiddle);
  _Settings.WriteBool('AutoHide', AutoHide);
  _Settings.WriteBool('RegEx', GrepRegEx);
  _Settings.WriteInteger('SaveOption', Integer(GrepSaveOption));
  _Settings.WriteBool('UseCurrentIdent', GrepUseCurrentIdent);
  _Settings.WriteBool('UseMapFile', GrepUseMapFile);
  _Settings.WriteBool('ExcludedDirsIsRegEx', ExcludedDirsIsRegEx);
  _Settings.WriteInteger('MinDepth', GrepMinDepth);
  _Settings.WriteInteger('MaxDepth', GrepMaxDepth);

  _Settings.WriteBool('AdvancedOptions', GrepAdvancedOptions);
  _Settings.WriteInteger('SaveOptionDeafult', GrepSaveOptionDefaultValue);
  _Settings.WriteInteger('SaveOptionDeafult4Open', GrepOpenSaveOptionDefaultValue);
  _Settings.WriteBool('FileListDeleteAfterDays', GrepFileListDeleteAfterDays);
  _Settings.WriteInteger('DeleteAfterDays', GrepDeleteAfterDays);
  _Settings.WriteBool('EmptyResultsMoveToOnlySaveParams', GrepEmptyMoveToOnlySaveParams);
  _Settings.WriteInteger('OnlySaveParamsAction', GrepOnlySaveParamsAction);
  _Settings.WriteInteger('HistoryListDefaultPage', GrepHistoryListDefaultPage);
  _Settings.WriteBool('QuickRefresh', GrepQuickRefresh);

  _Settings.WriteBool('ListUseDefaultColors', ListUseDefaultColors);
  _Settings.SaveFont('ListFont', ListFont, [ffColor]);
  _Settings.WriteInteger('ListMatchTextColor', ListMatchTextColor);
  _Settings.WriteInteger('ListMatchBrushColor', ListMatchBrushColor);
  _Settings.SaveFont('ContextFont', ContextFont, [ffColor]);
  _Settings.WriteInteger('ContextMatchColor', ContextMatchColor);
  _Settings.WriteInteger('ContextMatchLineColor', ContextMatchLineColor);

  _Settings.WriteInteger('NumContextLines', NumContextLines);
  _Settings.WriteInteger('SaveHistoryListItems', FGrepSaveHistoryListItems);
  _settings.DeleteKey('ContextSaveFixedHeight');

  _Settings.WriteBool('HistoryPagesTabMultilin', GrepHistoryPagesTabMultiline);
  _Settings.WriteInteger('HistoryPagesTabWidth', GrepHistoryPagesTabWidth);
  _Settings.WriteBool('MouseWheelPrevNextMatch', GrepMouseWheelPrevNextMatch);

  _Settings.WriteString('ExternalEditor', FExternalEditor);
  _Settings.WriteString('ExternalEditorParams', FExternalEditorParams);

  _Settings.WriteStrings('DirectoryList', DirList, 'GrepDir');
  _Settings.WriteStrings('SearchList', SearchList, 'GrepSearch');
  _Settings.WriteStrings('ReplaceList', ReplaceList, 'GrepReplace');
  _Settings.WriteStrings('MaskList', MaskList, 'GrepMask');
  _Settings.WriteStrings('ExcludedDirsList', ExcludedDirsList, 'GrepExcludedDirs');
end;

function TGrepExpert.FillGrepSettings: TGrepSettings;
begin
  Result.CaseSensitive := GrepCaseSensitive;
  Result.WholeWord := GrepWholeWord;
  Result.RegEx := GrepRegEx;
  Result.Pattern := '';
  Result.IncludeForms := GrepForms;
  Result.HandleFormMultiline := GrepFormsMultiline;
  Result.HandleFormSpecialChars := GrepFormsSpecialChars;
  Result.IncludeSQLs := GrepSQLFiles;
  Result.SaveOption := GrepSaveOption;
  Result.Mask := '';
  Result.Directories := '';
  Result.ExcludedDirs := '';
  Result.IncludeSubdirs := GrepSub;
  Result.ExcludedDirsIsRegEx := ExcludedDirsIsRegEx;
  Result.MinDepth := GrepMinDepth;
  Result.MaxDepth := GrepMaxDepth;

  Result.IncludeCode := GrepCode;
  Result.IncludeStrings := GrepStrings;
  Result.IncludeComments := GrepComments;

  Result.SectionInterface := GrepInterface;
  Result.SectionImplementation := GrepImplementation;
  Result.SectionInitialization := GrepInitialization;
  Result.SectionFinalization := GrepFinalization;

  Result.GrepAction := GrepAction;
  if GrepAction = gaDirGrep then begin
    if MaskList.Count > 0 then
      Result.Mask := MaskList[0];
    if DirList.Count > 0 then
      Result.Directories := DirList[0];
    if ExcludedDirsList.Count > 0 then
      Result.ExcludedDirs := ExcludedDirsList[0];
  end;
end;

function TGrepExpert.GrepConfigPath: String;
begin
  Result := AddSlash(ConfigInfo.ConfigPath);
  if FHistoryIniVersion >= 2 then
    Result := AddSlash(Result + ConfigurationKey + '.' + TGrepHistoryList.KeyName);
end;

function TGrepExpert.GrepHistorySettingsFileName: String;
begin
  if FHistoryIniVersion = 0 then
    Result := 'GrepFound.ini'
  else
    Result := TGrepHistoryList.SettingsFileName;
end;

function TGrepExpert.CreateSettings: TCustomIniFile;
begin
  Result := nil;
  case FGrepSaveHistoryListItems of
    1: begin
      ForceDirectories(GrepConfigPath);
      Result := TGrepIniFile.Create(GrepConfigPath + GrepHistorySettingsFileName);
    end;
    2: Result := TGExpertsSettings.Create;
  end;
end;

procedure TGrepExpert.LoadHistoryList(AGrepSettings : TGrepSettings);
var
  Settings: TCustomIniFile;
  BaseKey: String;
  AIniMode: TIniFileMode;
begin
  if not GrepSaveHistoryListItems then
    Exit;

  BaseKey := '';
  if GrepSaveHistoryListItemsToReg then
    BaseKey := ConfigurationKey + PathDelim;

  AIniMode := ifmMulti;
  if FHistoryIniVersion < 2 then
    AIniMode := ifmSingle;

  Settings := CreateSettings;
  try
    HistoryList.LoadFromSettings(AGrepSettings, Settings, HistoryIniVersion, AIniMode, BaseKey, SaveOption);
  finally
    FreeAndNil(Settings);
  end;
end;

procedure TGrepExpert.HistoryListSaveSettings(AItemIndex: Integer);
var
  Settings: TCustomIniFile;
  BaseKey: String;
begin
  if not GrepSaveHistoryListItems then
    Exit;

  BaseKey := '';
  if GrepSaveHistoryListItemsToReg then
    BaseKey := ConfigurationKey + PathDelim;

  Settings := CreateSettings;
  try
    HistoryList.SaveToSettings(Settings, HistoryIniVersion, BaseKey, AItemIndex,
      GrepEmptyMoveToOnlySaveParams, GrepFileListDeleteAfterDays, GrepDeleteAfterDays);
  finally
    FreeAndNil(Settings);
  end;
end;

procedure TGrepExpert.HistoryListSaveSearchListSettings;
var
  Settings: TCustomIniFile;
  BaseKey: String;
begin
  if not GrepSaveHistoryListItems then
    Exit;

  BaseKey := '';
  if GrepSaveHistoryListItemsToReg then
    BaseKey := ConfigurationKey + PathDelim;

  Settings := CreateSettings;
  try
    HistoryList.SaveSearchListToSettings(Settings, BaseKey);
  finally
    FreeAndNil(Settings);
  end;
end;

function TGrepExpert.HasMenuItem: Boolean;
begin
  Result := False;
end;

procedure TGrepExpert.HistoryListDeleteFromSettings(ADelMode: TGrepDeleteMode; AItemIndex: Integer);
var
  Settings: TCustomIniFile;
  BaseKey: String;
begin
  if not GrepSaveHistoryListItems then
    Exit;

  BaseKey := '';
  if GrepSaveHistoryListItemsToReg then
    BaseKey := ConfigurationKey + PathDelim;

  //if you delete one file must be at least
  if GrepSaveHistoryListItemsToIni and ((ADelMode <> delOneItem) or (HistoryIniVersion >= 2)) and
    (HistoryList.ListMode <> hlmSearch)
  then
    HistoryList.DeleteINIFiles(GrepConfigPath + GrepHistorySettingsFileName, ADelMode, HistoryIniVersion, AItemIndex)
  else //only deleting keys
  begin
    Settings := CreateSettings;
    try
      HistoryList.RemoveFromSettings(Settings, BaseKey, ADelMode, AItemIndex);
    finally
      FreeAndNil(Settings);
    end;
  end;
end;

procedure TGrepExpert.InternalLoadSettings(_Settings: IExpertSettings);

  ///<summary>
  /// Build a guess for the SubSystem path from the passed in VCL path.
  /// @returns true, if the SubSystem path exists </summary>
  function TryGuessPath(const _VclPath, _SubSystem: string; out _SubSystemPath: string): Boolean;
  const
    cVCL = 'vcl';
  var
    SubPos: Integer;
  begin
    Result := False;
    SubPos := AnsiCaseInsensitivePos(cVCL, _VclPath);
    if SubPos > 0 then begin
      _SubSystemPath := _VclPath;
      Delete(_SubSystemPath, SubPos, Length(cVCL));
      Insert(_SubSystem, _SubSystemPath, SubPos);
      Result := DirectoryExists(_SubSystemPath);
    end;
  end;

var
  TempPath: string;
  GrepActionInt: Integer;
begin
  inherited InternalLoadSettings(_Settings);
  // Do not localize any of the following lines
  FHistoryIniVersion := _Settings.ReadInteger('HistoryIniVersion', 0);

  FGrepCaseSensitive := _Settings.ReadBool('CaseSensitive', False);
  FGrepCode := _Settings.ReadBool('Code', True);
  FGrepStrings := _Settings.ReadBool('Strings', True);
  FGrepComments := not _Settings.ReadBool('NoComments', False);
  FGrepInterface := _Settings.ReadBool('Interface', True);
  FGrepImplementation := _Settings.ReadBool('Implementation', True);
  FGrepInitialization := _Settings.ReadBool('Initialization', True);
  FGrepFinalization := _Settings.ReadBool('Finalization', True);

  FGrepForms := _Settings.ReadBool('Forms', False);
  FGrepFormsSpecialChars := _Settings.ReadBool('FormsSpecialChars', False);
  FGrepFormsMultiline := _Settings.ReadBool('FormsMultiline', False);

  FGrepSQLFiles := _Settings.ReadBool('SQLFiles', False);

  GrepActionInt := _Settings.ReadInteger('Search', Ord(gaProjGrep));
  if (GrepActionInt < 0) or (GrepActionInt > Ord(High(TGrepAction))) then
    GrepAction := gaProjGrep
  else
    GrepAction := TGrepAction(GrepActionInt);

  FGrepSub := _Settings.ReadBool('SubDirectories', True);
  FGrepExpandAll := _Settings.ReadBool('ExpandAll', False);
  FGrepExpandIf := _Settings.ReadBool('ExpandIf', False);
  FGrepExpandIfFiles := _Settings.ReadInteger('ExpandIfFiles', FGrepExpandIfFiles);
  FGrepExpandIfMatches := _Settings.ReadInteger('ExpandIfMatches', FGrepExpandIfMatches);
  FGrepExpandFew := _Settings.ReadBool('ExpandFew', False);
  FGrepExpandFewLines := _Settings.ReadInteger('ExpandFewLines', FGrepExpandFewLines);
  FGrepWholeWord := _Settings.ReadBool('Whole Word', True);
  FGrepMiddle := _Settings.ReadBool('Middle', True);
  FAutoHide := _Settings.ReadBool('AutoHide', False);
  FGrepRegEx := _Settings.ReadBool('RegEx', False);
  FGrepSaveOption := TGrepSaveOption(_Settings.ReadInteger('SaveOption', Integer(GrepSaveOption)));
  FGrepUseCurrentIdent := _Settings.ReadBool('UseCurrentIdent', False);
  FGrepUseMapFile := _Settings.ReadBool('UseMapFile', False);
  FExcludedDirsIsRegEx := _Settings.ReadBool('ExcludedDirsIsRegEx', False);
  FGrepMinDepth := _Settings.ReadInteger('MinDepth', 0);
  FGrepMaxDepth := _Settings.ReadInteger('MaxDepth', -1);

  FGrepAdvancedOptions := _Settings.ReadBool('AdvancedOptions', GrepAdvancedOptions);
  FGrepSaveOptionDefaultValue := _Settings.ReadInteger('SaveOptionDeafult', GrepSaveOptionDefaultValue);
  FGrepOpenSaveOptionDefaultValue := _Settings.ReadInteger('SaveOptionDeafult4Open', GrepOpenSaveOptionDefaultValue);
  FGrepFileListDeleteAfterDays := _Settings.ReadBool('FileListDeleteAfterDays', GrepFileListDeleteAfterDays);
  FGrepDeleteAfterDays := _Settings.ReadInteger('DeleteAfterDays', GrepDeleteAfterDays);
  FGrepEmptyMoveToOnlySaveParams := _Settings.ReadBool('EmptyResultsMoveToOnlySaveParams', GrepEmptyMoveToOnlySaveParams);
  FGrepOnlySaveParamsAction := _Settings.ReadInteger('OnlySaveParamsAction', GrepOnlySaveParamsAction);
  FGrepHistoryListDefaultPage := _Settings.ReadInteger('HistoryListDefaultPage', GrepHistoryListDefaultPage);
  FGrepQuickRefresh := _Settings.ReadBool('QuickRefresh', GrepQuickRefresh);

  FListUseDefaultColors := _Settings.ReadBool('ListUseDefaultColors', False);
  _Settings.LoadFont('ListFont', ListFont, [ffColor]);
  FListMatchTextColor :=  _Settings.ReadInteger('ListMatchTextColor', FListMatchTextColor);
  FListMatchBrushColor :=  _Settings.ReadInteger('ListMatchBrushColor', FListMatchBrushColor);
  _Settings.LoadFont('ContextFont', ContextFont, [ffColor]);
  FContextMatchColor :=  _Settings.ReadInteger('ContextMatchColor', FContextMatchColor);
  if _Settings.ValueExists('ContextMatchLineColor') then
    FContextMatchLineColor := _Settings.ReadInteger('ContextMatchLineColor', FContextMatchLineColor)
  else
    FContextMatchLineColor := FContextMatchColor;

  FNumContextLines :=  _Settings.ReadInteger('NumContextLines', FNumContextLines);

  FGrepHistoryPagesTabMultiline := _Settings.ReadBool('HistoryPagesTabMultilin', GrepHistoryPagesTabMultiline);
  FGrepHistoryPagesTabWidth := _Settings.ReadInteger('HistoryPagesTabWidth', GrepHistoryPagesTabWidth);
  FGrepMouseWheelPrevNextMatch := _Settings.ReadBool('MouseWheelPrevNextMatch', GrepMouseWheelPrevNextMatch);

  FExternalEditor := _Settings.ReadString('ExternalEditor', FExternalEditor);
  FExternalEditorParams := _Settings.ReadString('ExternalEditorParams', FExternalEditorParams);

  _Settings.ReadStrings('DirectoryList', DirList, 'GrepDir');
  _Settings.ReadStrings('SearchList', SearchList, 'GrepSearch');
  _Settings.ReadStrings('ReplaceList', ReplaceList, 'GrepReplace');
  _Settings.ReadStrings('MaskList', MaskList, 'GrepMask');
  _Settings.ReadStrings('ExcludedDirsList', ExcludedDirsList, 'GrepExcludedDirs');

  if FHistoryIniVersion = 0 then
    FGrepSaveHistoryListItems := _Settings.ReadInteger('SaveResultListItems', 0)
  else
    FGrepSaveHistoryListItems := _Settings.ReadInteger('SaveHistoryListItems', 0);

  EnsureStringInList(MaskList,'*.pas;*.dpr;*.inc');
  EnsureStringInList(MaskList,'*.txt;*.html;*.htm;.rc;*.xml;*.todo;*.me');
  if IsStandAlone or GxOtaHaveCPPSupport then
    EnsureStringInList(MaskList,'*.cpp;*.hpp;*.h;*.pas;*.dpr');
  if IsStandAlone or GxOtaHaveCSharpSupport then
    EnsureStringInList(MaskList,'*.cs');

  TempPath := RemoveSlash(ConfigInfo.VCLPath);
  if NotEmpty(TempPath) then begin
    if DirectoryExists(TempPath) then
      EnsureStringInList(DirList, TempPath);
    if TryGuessPath(ConfigInfo.VCLPath, 'rtl', TempPath) then
      EnsureStringInList(DirList, RemoveSlash(TempPath));
    if TryGuessPath(ConfigInfo.VCLPath, 'clx', TempPath) then
      EnsureStringInList(DirList, RemoveSlash(TempPath));
    if TryGuessPath(ConfigInfo.VCLPath, 'fmx', TempPath) then
      EnsureStringInList(DirList, RemoveSlash(TempPath));
  end;

  fmGrepResults.InitGrepSettings(FillGrepSettings);

  LoadHistoryList(fmGrepResults.GrepSettings);

  fmGrepResults.UpdateFromSettings;

  if FHistoryIniVersion = 0 then
  begin
    HistoryListDeleteFromSettings(delAll);

    FHistoryIniVersion := 2;

    _Settings.EraseSection(ConfigurationKey);

    InternalSaveSettings(_Settings);
    fmGrepResults.InternalSaveSettings(_Settings);

    HistoryListSaveSettings;
  end
  else if FHistoryIniVersion = 1 then
  begin
    HistoryListDeleteFromSettings(delAll);
    FHistoryIniVersion := 2;
    InternalSaveSettings(_Settings);
    HistoryListSaveSettings;
  end;
end;

function TGrepExpert.GetGrepSaveHistoryListItems(AIndex: Integer): Boolean;
begin
  if AIndex = 3 then
    Result := FGrepSaveHistoryListItems in [1..2]
  else
    Result := FGrepSaveHistoryListItems = AIndex;
end;

function TGrepExpert.GetHelpString: string;
resourcestring
  SHelpString =
  '  The Grep Results window is where the results of a Grep Search are shown.'#13#10 +
  '  It also provides an interface for multi-file search and replace on matches.';
begin
  Result := SHelpString;
end;

procedure TGrepExpert.SetSearchList(New: TStrings);
begin
  FSearchList.Assign(New);
end;

procedure TGrepExpert.SetReplaceList(New: TStrings);
begin
  FReplaceList.Assign(New);
end;

procedure TGrepExpert.SetMaskList(New: TStrings);
begin
  FMaskList.Assign(New);
end;

procedure TGrepExpert.SetDirList(New: TStrings);
begin
  FDirList.Assign(New);
end;

procedure TGrepExpert.SetExcludedDirsList(const Value: TStrings);
begin
  FExcludedDirsList.Assign(Value);
end;

procedure TGrepExpert.SetActive(New: Boolean);
begin
  if New <> Active then
  begin
    inherited SetActive(New);
    if New then
    begin
      if fmGrepResults = nil then
        fmGrepResults := TfmGrepResults.Create(nil);
    end
    else
      FreeAndNil(fmGrepResults);
  end;
end;

function TGrepExpert.CanHaveShortCut: boolean;
begin
  Result := True;
end;

class function TGrepExpert.ConfigurationKey: string;
begin
  Result := 'Grep';
end;

procedure ShowGrep;
begin
  {$IFOPT D+} SendDebug('Showing grep expert'); {$ENDIF}
  InitSharedResources;
  try
    gblGrepExpert := TGrepExpert.Create;
    try
      {$IFOPT D+} SendDebug('Created grep window'); {$ENDIF}
      gblGrepExpert.LoadSettings;
      gblGrepExpert.ShowModal;
      gblGrepExpert.HistoryListSaveSettings;
      gblGrepExpert.SaveSettings;
    finally
      FreeAndNil(gblGrepExpert);
    end;
  finally
    FreeSharedResources;
  end;
end;

procedure doShowGrepEx(const _Directory: string);
begin
{$IFOPT D+}SendDebug('Showing grep expert for directory ' + _Directory);{$ENDIF}
  InitSharedResources;
  try
    // gblGrepExpert is already set in the constructor, so assigning it here is not really necessary
    gblGrepExpert := TGrepExpert.Create;
    try
      {$IFOPT D+} SendDebug('Created grep window'); {$ENDIF}
      gblGrepExpert.LoadSettings;
      gblGrepExpert.ShowStandAlone(_Directory);
      gblGrepExpert.HistoryListSaveSettings;
      gblGrepExpert.SaveSettings;
    finally
      // the destructor sets the global variable to nil, so FreeAndNil is not really necesary here
      FreeAndNil(gblGrepExpert);
    end;
  finally
    FreeSharedResources;
  end;
end;

procedure ShowGrepEx(_HWnd: HWND; _HInst: HINST; _CmdLine: PAnsiChar; nCmdShow: Integer);
var
  Dir: string;
begin
  Dir := String(_CmdLine);
  doShowGrepEx(Dir);
end;

function TGrepExpert.GetSaveOption: TGrepSaveOption;
begin
  if FGrepSaveOptionDefaultValue <= Integer(High(TGrepSaveOption)) then
    Result := TGrepSaveOption(FGrepSaveOptionDefaultValue)
  else
    Result := FGrepSaveOption;
end;

function TGrepExpert.GetOpenSaveOption: TGrepSaveOption;
begin
  if FGrepOpenSaveOptionDefaultValue <= Integer(High(TGrepSaveOption)) then
    Result := TGrepSaveOption(FGrepOpenSaveOptionDefaultValue)
  else
    Result := SaveOption;
end;

initialization
  RegisterGX_Expert(TGrepExpert);
end.
