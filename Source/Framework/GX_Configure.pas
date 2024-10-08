unit GX_Configure;

{$I GX_CondDefine.inc}

interface

uses
  Windows, Classes, Graphics, Controls, Forms, Dialogs, Menus,
  StdCtrls, ComCtrls, ExtCtrls, GX_BaseForm,
  GX_ConfigureExperts;

type
  TfmConfiguration = class(TfmBaseForm)
    pnlMain: TPanel;
    pnlButtons: TPanel;
    pcConfig: TPageControl;
    tshExperts: TTabSheet;
    tshGeneral: TTabSheet;
    tshIDE: TTabSheet;
    tshEditorExperts: TTabSheet;
    gbxIDEMenu: TGroupBox;
    dlgUIFont: TFontDialog;
    gbxTabDockHost: TGroupBox;
    chkMultiLineTabDockHost: TCheckBox;
    chkDefaultMultiLineTabDockHost: TCheckBox;
    gbxCompPalette: TGroupBox;
    chkCPMultiLine: TCheckBox;
    chkCPAsButtons: TCheckBox;
    chkCPTabsInPopup: TCheckBox;
    chkCPFlat: TCheckBox;
    chkCPTabsInPopupAlphaSort: TCheckBox;
    chkCPScrollOpposite: TCheckBox;
    chkCPRaggedRight: TCheckBox;
    chkAlphabetizeMenu: TCheckBox;
    chkHideWindowMenu: TCheckBox;
    chkMoveComponentMenu: TCheckBox;
    chkPlaceGxMainMenuInToolsMenu: TCheckBox;
    tshDebug: TTabSheet;
    chkEditorKeyTracing: TCheckBox;
    btnEnumerateModules: TButton;
    btnEumerateActions: TButton;
    btnGetFonts: TButton;
    btnAppBuilder: TButton;
    gbxIDEForms: TGroupBox;
    chkEnhanceDialogs: TCheckBox;
    gbxFonts: TGroupBox;
    btnOIFont: TButton;
    btnCPFont: TButton;
    chkOIFontEnabled: TCheckBox;
    chkCPFontEnabled: TCheckBox;
    gbxFileSaving: TGroupBox;
    lblEvery: TLabel;
    lblMinutes: TLabel;
    chkAutoSave: TCheckBox;
    edtMinutes: TEdit;
    udMinutes: TUpDown;
    btnEditView: TButton;
    pnlButtonsRight: TPanel;
    btnHelp: TButton;
    btnCancel: TButton;
    btnOK: TButton;
    dlgFont: TFontDialog;
    pnlGeneral: TPanel;
    gbxLocations: TGroupBox;
    lblVCL: TLabel;
    lblConfig: TLabel;
    lblHelp: TLabel;
    sbVCLDir: TButton;
    sbConfigDir: TButton;
    sbHelpFile: TButton;
    edVCLPath: TEdit;
    edConfigPath: TEdit;
    edHelpFile: TEdit;
    gbxCustomFont: TGroupBox;
    chkUseCustomFont: TCheckBox;
    btnCustomFont: TButton;
    pnlGeneralSpacer: TPanel;
    chkEnhanceSearchPaths: TCheckBox;
    chkEnhanceToolProperties: TCheckBox;
    chkAllowResize: TCheckBox;
    chkRememberPosition: TCheckBox;
    tshSuppressedMessages: TTabSheet;
    gbSuppressedMessages: TGroupBox;
    lbSuppressedMesages: TListBox;
    btnDeleteSuppressedMessage: TButton;
    btnClearSuppressedMessages: TButton;
    chkEnhanceInstallPackages: TCheckBox;
    btnImport: TButton;
    btnExport: TButton;
    gbxObjectInspector: TGroupBox;
    chkOIFontNames: TCheckBox;
    chkOIHideHotCmds: TCheckBox;
    chkOIHideDescPane: TCheckBox;
    chkEnhanceBuildEventsDialog: TCheckBox;
    chkEnhanceApplicationSettingsDialog: TCheckBox;
    btnUsage: TButton;
    chkAutoCloseMessage: TCheckBox;
    tshOldIdes: TTabSheet;
    chkForceStartupDesktop: TCheckBox;
    cbxDesktop: TComboBox;
    chkEnhanceDockForms: TCheckBox;
    lblCachingPath: TLabel;
    edCachingPath: TEdit;
    bCachingPath: TButton;
    chk_FontForNewForms: TCheckBox;
    b_CustomFontForNewForms: TButton;
    l_ForceDestkopAV: TLabel;
    chkAutoCloseIgnoreHints: TCheckBox;
    chkAutoCloseIgnoreWarnings: TCheckBox;
    procedure btnEnumerateModulesClick(Sender: TObject);
    procedure chkEditorKeyTracingClick(Sender: TObject);
    procedure sbVCLDirClick(Sender: TObject);
    procedure sbConfigDirClick(Sender: TObject);
    procedure bCachingPathClick(Sender: TObject);
    procedure sbHelpFileClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure chkFontEnabledClick(Sender: TObject);
    procedure btnFontClick(Sender: TObject);
    procedure chkAutoSaveClick(Sender: TObject);
    procedure chkCPAsButtonsClick(Sender: TObject);
    procedure chkCPTabsInPopupClick(Sender: TObject);
    procedure chkCPMultiLineClick(Sender: TObject);
    procedure chkMultiLineTabDockHostClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnEumerateActionsClick(Sender: TObject);
    procedure btnGetFontsClick(Sender: TObject);
    procedure btnAppBuilderClick(Sender: TObject);
    procedure btnEditViewClick(Sender: TObject);
    procedure btnCustomFontClick(Sender: TObject);
    procedure chkEnhanceDialogsClick(Sender: TObject);
    procedure btnDeleteSuppressedMessageClick(Sender: TObject);
    procedure btnClearSuppressedMessagesClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure btnUsageClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure b_CustomFontForNewFormsClick(Sender: TObject);
    procedure chkUseCustomFontClick(Sender: TObject);
  private
    FOIFont: TFont;
    FCPFont: TFont;
    FConfigEditorExpertsFrame: TfrConfigureExperts;
    FConfigExpertsFrame: TfrConfigureExperts;
    procedure HideUnsupportedIdeItems;

    procedure LoadGeneral;
    procedure SaveGeneral;

    procedure LoadIdeEnhancements;
    procedure SaveIdeEnhancements;

    procedure LoadSuppressedMessages;

    procedure edVCLPathOnDropFiles(_Sender: TObject; _Files: TStrings);
    procedure edConfigPathDropFiles(_Sender: TObject; _Files: TStrings);
    procedure edHelpFileDropFiles(_Sender: TObject; _Files: TStrings);
    procedure UpdateIdeDialogCheckboxes;
    procedure SaveAllSettings;
    procedure edCachingPathDropFiles(_Sender: TObject; _Files: TStrings);
{$IFDEF GX_IDE_IS_HIDPI_AWARE}
    procedure ArrangeGeneralTab;
  protected
    procedure ArrangeControls; override;
{$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

uses
  {$IFOPT D+} GX_DbugIntf, {$ENDIF}
  SysUtils, UITypes,
{$ifNdef GExpertsBPL_NoSizeGrip}
{$IFDEF GX_DELPHI2007_UP}
  GX_SizeGripHWND,
{$ENDIF}
{$endif GExpertsBPL_NoSizeGrip}
  GX_GxUtils, GX_IdeEnhance,
  GX_ConfigurationInfo, GX_EditorExpertManager, GX_MessageBox,
  GX_GExperts, GX_MenuActions, GX_GenericUtils, GX_IdeUtils,
  GX_OtaUtils, u_dzVclUtils, GX_KbdShortCutBroker,
{$ifNdef GExpertsBPL_NoStatistics}
  GX_UsageStatistics,
{$endif GExpertsBPL_NoStatistics}
  GX_BaseExpert;

procedure SetupGroupBox(Box: TGroupBox; Enable: Boolean);
var
  i: Integer;
begin
  for i := 0 to Box.ControlCount - 1 do
    Box.Controls[i].Enabled := Enable;
end;

// **************************************************************

constructor TfmConfiguration.Create(AOwner: TComponent);
var
  MinWidth: Integer;
  MinHeight: Integer;
  GExperts: TGExperts;
  i: Integer;
  UsageCount: Integer;
  Expert: TGX_BaseExpert;
{$IFDEF GX_STARTUP_LAYOUT_FIX_ENABLED}
  Desktops: TStrings;
{$ENDIF}

  procedure AdjustMinSize(_ctrl: TControl);
  begin
    if _ctrl.Constraints.MinWidth > MinWidth then
      MinWidth := _ctrl.Constraints.MinWidth;
    if _ctrl.Constraints.MinHeight > MinHeight then
      MinHeight := _ctrl.Constraints.MinHeight;
  end;

begin
  inherited Create(AOwner);

{$IFDEF GX_IDE_IS_HIDPI_AWARE}
  ArrangeGeneralTab;
{$ENDIF}

  MinWidth := pcConfig.ClientWidth;
  MinHeight := pcConfig.ClientHeight;

  FOIFont := TFont.Create;
  FCPFont := TFont.Create;

  TWinControl_ActivateDropFiles(edVCLPath, edVCLPathOnDropFiles);
  TEdit_ActivateAutoComplete(edVCLPath, [acsFileSystem], [actSuggest]);
  TWinControl_ActivateDropFiles(edConfigPath, edConfigPathDropFiles);
  TWinControl_ActivateDropFiles(edCachingPath, edCachingPathDropFiles);
  TEdit_ActivateAutoComplete(edConfigPath, [acsFileSystem], [actSuggest]);
  TWinControl_ActivateDropFiles(edHelpFile, edHelpFileDropFiles);
  TEdit_ActivateAutoComplete(edHelpFile, [acsFileSystem], [actSuggest]);

{$IFDEF GX_VER150_up}
  pnlMain.ParentBackground := False; // reduce flickering
{$ENDIF GX_VER150_up}
  pnlMain.DoubleBuffered := True;

  pcConfig.ActivePage := tshExperts;

  FConfigEditorExpertsFrame := TfrConfigureExperts.Create(Self);
  FConfigEditorExpertsFrame.Name := 'frmConfigureEditorExperts';
  FConfigEditorExpertsFrame.Parent := tshEditorExperts;
  FConfigEditorExpertsFrame.Align := alClient;
  AdjustMinSize(FConfigEditorExpertsFrame);
  { TODO : Sort expert and editor expert lists by caption }
  FConfigEditorExpertsFrame.Init(GExpertsInst.EditorExpertManager.GetExpertList);

  FConfigExpertsFrame := TfrConfigureExperts.Create(Self);
  FConfigExpertsFrame.Name := 'frmConfigureExperts';
  FConfigExpertsFrame.Parent := tshExperts;
  FConfigExpertsFrame.Align := alClient;
  AdjustMinSize(FConfigExpertsFrame);
  FConfigExpertsFrame.Init(GExpertsInst.GetExpertList);

{$IFDEF GX_STARTUP_LAYOUT_FIX_ENABLED}
  if TryGetIdeDesktops(Desktops) then
    cbxDesktop.Items.Assign(Desktops);
{$ENDIF}

  ActiveControl := FConfigExpertsFrame.edtFilter;

  MinWidth := MinWidth + (Width - pcConfig.ClientWidth);
  MinHeight := MinHeight+ (Height - pcConfig.ClientHeight);

  Width := MinWidth;
  Height := MinHeight;
  TControl_SetMinConstraints(Self);

  LoadGeneral;

  LoadIdeEnhancements;

  chkPlaceGxMainMenuInToolsMenu.Checked := ConfigInfo.PlaceGxMainMenuInToolsMenu;
  chkAlphabetizeMenu.Checked := ConfigInfo.AlphabetizeMenu;
  chkHideWindowMenu.Checked := ConfigInfo.HideWindowMenu;
  chkMoveComponentMenu.Checked := ConfigInfo.MoveComponentMenu;

  // debug option:
  chkEditorKeyTracing.Checked := GxOtaGetEditorKeyTracingEnabled;

  HideUnsupportedIdeItems;

  LoadSuppressedMessages;

  tshDebug.TabVisible := False;

  GExperts := GExpertsInst(True);
  UsageCount := 0;
  for i := 0 to GExperts.ExpertCount - 1 do begin
    Expert := GExperts.ExpertList[i];
    if Expert.HasCallCount then
      Inc(UsageCount, Expert.CallCount);
  end;
  for i := 0 to GExperts.EditorExpertManager.EditorExpertCount - 1 do begin
    Expert := GExperts.EditorExpertManager.EditorExpertList[i];
    if Expert.HasCallCount then
      Inc(UsageCount, Expert.CallCount);
  end;
  btnUsage.Caption := Format('Usage (%d) ...', [UsageCount]);

  InitDpiScaler;
end;

destructor TfmConfiguration.Destroy;
begin
  FreeAndNil(FOIFont);
  FreeAndNil(FCPFont);

  inherited Destroy;
end;

{$IFDEF GX_IDE_IS_HIDPI_AWARE}
procedure TfmConfiguration.ArrangeGeneralTab;
var
  t: Integer;
begin
  t := TEdit_AlignBelowLabel(edVCLPath, lblVCL);
  TButton_AlignVerticallyTo(sbVCLDir, edVCLPath);
  lblConfig.Top := t + 8;
  t := TEdit_AlignBelowLabel(edConfigPath, lblConfig);
  TButton_AlignVerticallyTo(sbConfigDir, edConfigPath);
  lblCachingPath.Top := t + 8;
  t := TEdit_AlignBelowLabel(edCachingPath, lblCachingPath);
  TButton_AlignVerticallyTo(bCachingPath, edCachingPath);
  lblHelp.Top := t + 8;
  t := TEdit_AlignBelowLabel(edHelpFile, lblHelp);
  TButton_AlignVerticallyTo(sbHelpFile, edHelpFile);
  gbxLocations.ClientHeight := t + edHelpFile.Height + 8;
  gbxCustomFont.Top := gbxLocations.Top + gbxLocations.Height + 8;
  TButton_AlignVerticallyTo(btnCustomFont, chkUseCustomFont);
  btnCustomFont.Left := chkUseCustomFont.Left + chkUseCustomFont.Width + 8;
end;

procedure TfmConfiguration.ArrangeControls;
var
  WorkAreaHeight: Integer;
begin
  inherited;
  WorkAreaHeight := Monitor.WorkareaRect.Height;
  if Constraints.MinHeight > WorkAreaHeight then
    Constraints.MinHeight := WorkAreaHeight;
  if Height > WorkAreaHeight then
    Height := WorkAreaHeight;
  ArrangeGeneralTab;
  FConfigExpertsFrame.ArrangeControls;
  FConfigEditorExpertsFrame.ArrangeControls;
end;

{$ENDIF}

procedure TfmConfiguration.edVCLPathOnDropFiles(_Sender: TObject; _Files: TStrings);
begin
  edVCLPath.Text := _Files[0];
end;

procedure TfmConfiguration.edConfigPathDropFiles(_Sender: TObject; _Files: TStrings);
begin
  edConfigPath.Text := _Files[0];
end;

procedure TfmConfiguration.edCachingPathDropFiles(_Sender: TObject; _Files: TStrings);
begin
  edCachingPath.Text := _Files[0];
end;

procedure TfmConfiguration.edHelpFileDropFiles(_Sender: TObject; _Files: TStrings);
begin
  edHelpFile.Text := _Files[0];
end;

procedure TfmConfiguration.LoadGeneral;
begin
  edVCLPath.Text := ConfigInfo.VclPath;
  edConfigPath.Text := ConfigInfo.ConfigPath;
  edCachingPath.Text := ConfigInfo.CachingPath;
  edHelpFile.Text := ConfigInfo.HelpFile;
  chkUseCustomFont.Checked := ConfigInfo.EnableCustomFont;
  dlgUIFont.Font.Assign(ConfigInfo.CustomFont);
end;

procedure TfmConfiguration.SaveGeneral;
begin
  ConfigInfo.VclPath := edVCLPath.Text;
  ConfigInfo.ConfigPath := edConfigPath.Text;
  ConfigInfo.CachingPath := edCachingPath.Text;
  ConfigInfo.HelpFile := edHelpFile.Text;
  ConfigInfo.EnableCustomFont := chkUseCustomFont.Checked;
  ConfigInfo.CustomFont.Assign(dlgUIFont.Font);
  ConfigInfo.UpdateScreenForms;
end;

procedure TfmConfiguration.sbVCLDirClick(Sender: TObject);
resourcestring
  SSelVclDir = 'Select VCL Directory';
var
  TempString: string;
begin
  TempString := edVCLPath.Text;
  if GetDirectory(SSelVclDir, TempString, self) then
    edVCLPath.Text := TempString;
end;

procedure TfmConfiguration.bCachingPathClick(Sender: TObject);
resourcestring
  SSelCachingDir = 'Select Caching Directory';
var
  TempString: string;
begin
  TempString := edCachingPath.Text;
  if GetDirectory(SSelCachingDir, TempString, Self) then
    edCachingPath.Text := TempString;
end;

procedure TfmConfiguration.sbConfigDirClick(Sender: TObject);
resourcestring
  SSelConfigDir = 'Select Configuration Directory';
var
  TempString: string;
begin
  TempString := edConfigPath.Text;
  if GetDirectory(SSelConfigDir, TempString, Self) then
    edConfigPath.Text := TempString;
end;

procedure TfmConfiguration.sbHelpFileClick(Sender: TObject);
var
  fn: string;
begin
  fn := edHelpFile.Text;
  if ShowOpenDialog('Select Help File', 'chm', fn, 'Help Files (*.chm)|*.chm') then
    edHelpFile.Text := fn;
end;

procedure TfmConfiguration.SaveAllSettings;
begin
  GxKeyboardShortCutBroker.BeginUpdate;
  try
    SaveGeneral;
    FConfigExpertsFrame.SaveExperts;
    FConfigEditorExpertsFrame.SaveExperts;
    SaveIdeEnhancements;
    ConfigInfo.SaveSettings;
    GXMenuActionManager.ArrangeMenuItems;
  finally
    GxKeyboardShortCutBroker.EndUpdate;
  end;
end;

procedure TfmConfiguration.btnOKClick(Sender: TObject);
begin
  SaveAllSettings;

  ModalResult := mrOk;
end;

procedure TfmConfiguration.btnUsageClick(Sender: TObject);
begin
{$ifNdef GExpertsBPL_NoStatistics}
  TfmUsageStatistics.Execute(Self);
{$endif GExpertsBPL_NoStatistics}
end;

procedure TfmConfiguration.b_CustomFontForNewFormsClick(Sender: TObject);
begin
  dlgUIFont.Font.Height := DefFontData.Height;
{$IFDEF GX_DELPHI2005_UP}
  dlgUIFont.Font.Orientation := DefFontData.Orientation;
{$ENDIF}
  dlgUIFont.Font.Pitch := DefFontData.Pitch;
  dlgUIFont.Font.Style := DefFontData.Style;
  dlgUIFont.Font.Charset := DefFontData.Charset;
  dlgUIFont.Font.Name := TFontName(DefFontData.Name);
  if dlgUIFont.Execute then begin
    chk_FontForNewForms.Checked := True;
    DefFontData.Height := dlgUIFont.Font.Height;
{$IFDEF GX_DELPHI2005_UP}
    DefFontData.Orientation := dlgUIFont.Font.Orientation;
{$ENDIF}
    DefFontData.Pitch := dlgUIFont.Font.Pitch;
    DefFontData.Style := dlgUIFont.Font.Style;
    DefFontData.Charset := dlgUIFont.Font.Charset;
    DefFontData.Name := TFontDataName(dlgUIFont.Font.Name);
  end;
end;

procedure TfmConfiguration.btnHelpClick(Sender: TObject);
var
  ActivePage: TTabSheet;
begin
  ActivePage := pcConfig.ActivePage;
  if ActivePage = tshEditorExperts then
    GxContextHelp(Self, 29)
  else if ActivePage = tshIDE then
    GxContextHelp(Self, 30)
  else
    GxContextHelp(Self, 12);
end;

procedure TfmConfiguration.btnClearSuppressedMessagesClick(Sender: TObject);
var
  Settings: TGExpertsSettings;
begin
  Settings := TGExpertsSettings.Create;
  try
    Settings.EraseSection(TGxMsgBoxAdaptor.ConfigurationKey);
  finally
    Settings.Free;
  end;
  LoadSuppressedMessages;
end;

procedure TfmConfiguration.chkEditorKeyTracingClick(Sender: TObject);
begin
  GxOtaSetEditorKeyTracingEnabled(chkEditorKeyTracing.Checked);
end;

procedure TfmConfiguration.LoadIdeEnhancements;
begin
  Assert(IdeEnhancements <> nil);

  // Multi-line component palette
  chkCPMultiLine.Checked := IdeEnhancements.CPMultiLine;
  chkCPAsButtons.Checked := IdeEnhancements.CPAsButtons;
  chkCPScrollOpposite.Checked := IdeEnhancements.CPScrollOpposite;
  chkCPRaggedRight.Checked := IdeEnhancements.CPRaggedRight;
  chkCPFlat.Checked := IdeEnhancements.CPFlatButtons;
  chkCPTabsInPopup.Checked := IdeEnhancements.CPTabsInPopup;
  chkCPTabsInPopupAlphaSort.Checked := IdeEnhancements.CPTabsInPopupAlphaSort;

  // Tab-docked hosts
  chkMultiLineTabDockHost.Checked := IdeEnhancements.MultiLineTabDockHost;
  chkDefaultMultiLineTabDockHost.Checked := IdeEnhancements.DefaultMultiLineTabDockHost;

  chkEnhanceDialogs.Checked := IdeEnhancements.EnhanceIDEForms;
  chkAllowResize.Checked := IdeEnhancements.IdeFormsAllowResize;
  chkRememberPosition.Checked := IdeEnhancements.IdeFormsRememberPosition;
  chkEnhanceSearchPaths.Checked := IdeEnhancements.EnhanceSearchPath;
  chkEnhanceToolProperties.Checked := IdeEnhancements.EnhanceToolProperties;
  chkEnhanceInstallPackages.Checked := IdeEnhancements.EnhanceInstallPackages;
  chkEnhanceDockForms.Checked := IdeEnhancements.EnhanceDockForms;
{$IFDEF GX_VER170_up} // Delphi 9/2005 (BDS 2)
  chkAutoCloseMessage.Checked := IdeEnhancements.AutoCloseMessageWindow;
{$ENDIF GX_VER170_up} // Delphi 9/2005 (BDS 2)

{$IFDEF GX_STARTUP_LAYOUT_FIX_ENABLED}
  chkForceStartupDesktop.Checked := ConfigInfo.GetForceDesktopOnStartup;
  cbxDesktop.Text := ConfigInfo.GetForcedStartupDesktop;
{$ENDIF}

  chkEnhanceBuildEventsDialog.Checked := IdeEnhancements.EnhanceBuildEventsDialog;
  chkEnhanceApplicationSettingsDialog.Checked := IdeEnhancements.EnhanceApplicationSettingsDialog;
  UpdateIdeDialogCheckboxes;
{$ifdef GExpertsBPL_NoStatistics}
  btnUsage.Enabled := False;
{$endif GExpertsBPL_NoStatistics}
{$ifdef GExpertsBPL_NoMultiline}
  chkMultiLineTabDockHost.Enabled := False;
{$endif GExpertsBPL_NoMultiline}

  chkCPFontEnabled.Checked := IdeEnhancements.CPFontEnabled;
  FCPFont.Assign(IdeEnhancements.CPFont);

  // File saving
  chkAutoSave.Checked := IdeEnhancements.AutoSave;
  udMinutes.Position := IdeEnhancements.AutoSaveInterval;

  // Object Inspector
  chkOIFontEnabled.Checked := IdeEnhancements.OIFontEnabled;
  FOIFont.Assign(IdeEnhancements.OIFont);
  chkOIFontNames.Checked := IdeEnhancements.OICustomFontNames;
  chkOIHideHotCmds.Checked := IdeEnhancements.OIHideHotCmds;
  chkOIHideDescPane.Checked := IdeEnhancements.OIHideDescPane;
  chkFontEnabledClick(Self);

  chkAutoSaveClick(chkAutoSave);
  chkCPAsButtonsClick(chkCPAsButtons);
  chkCPTabsInPopupClick(chkCPTabsInPopup);
  chkCPMultiLineClick(chkCPMultiLine);
  chkMultiLineTabDockHostClick(chkMultiLineTabDockHost);
  chkCPMultiLineClick(chkCPMultiLine);
end;

procedure TfmConfiguration.LoadSuppressedMessages;
var
  Section: string;
  Settings: TGExpertsSettings;
  sl: TStringList;
  i: Integer;
begin
  sl := TStringList.Create;
  try
    Settings := TGExpertsSettings.Create;
    try
      Section := TGxMsgBoxAdaptor.ConfigurationKey;
      Settings.ReadSection(Section, sl);
      for i := sl.Count - 1 downto 0 do begin
        if not Settings.ReadBool(Section, sl[i], False) then
          sl.Delete(i);
      end;
      lbSuppressedMesages.Items.Assign(sl);
    finally
      Settings.Free;
    end;
  finally
    sl.Free;
  end;
end;

procedure TfmConfiguration.SaveIdeEnhancements;
begin
  Assert(IdeEnhancements <> nil);

  // Multi-line tab dock host
  IdeEnhancements.MultiLineTabDockHost := chkMultiLineTabDockHost.Checked;
  IdeEnhancements.DefaultMultiLineTabDockHost := chkDefaultMultiLineTabDockHost.Checked;
  // Component palette
  IdeEnhancements.CPMultiLine := chkCPMultiLine.Checked;
  IdeEnhancements.CPScrollOpposite := chkCPScrollOpposite.Checked;
  IdeEnhancements.CPRaggedRight := chkCPRaggedRight.Checked;
  IdeEnhancements.CPAsButtons := chkCPAsButtons.Checked;
  IdeEnhancements.CPFlatButtons := chkCPFlat.Checked;
  IdeEnhancements.CPTabsInPopup := chkCPTabsInPopup.Checked;
  IdeEnhancements.CPTabsInPopupAlphaSort := chkCPTabsInPopupAlphaSort.Checked;

  IdeEnhancements.CPFontEnabled := chkCPFontEnabled.Checked;
  IdeEnhancements.OIFont.Assign(FOIFont);
  IdeEnhancements.CPFont.Assign(FCPFont);

  IdeEnhancements.EnhanceIDEForms := chkEnhanceDialogs.Checked;
  IdeEnhancements.IdeFormsAllowResize := chkAllowResize.Checked;
  IdeEnhancements.IdeFormsRememberPosition := chkRememberPosition.Checked;
  IdeEnhancements.EnhanceSearchPath := chkEnhanceSearchPaths.Checked;
  IdeEnhancements.EnhanceInstallPackages := chkEnhanceInstallPackages.Checked;
  IdeEnhancements.EnhanceToolProperties := chkEnhanceToolProperties.Checked;
  IdeEnhancements.EnhanceDockForms := chkEnhanceDockForms.Checked;
{$IFDEF GX_VER170_up} // Delphi 9/2005 (BDS 2)
  IdeEnhancements.AutoCloseIgnoreHints := chkAutoCloseIgnoreHints.Checked;
  IdeEnhancements.AutoCloseIgnoreWarnings := chkAutoCloseIgnoreWarnings.Checked;
  IdeEnhancements.AutoCloseMessageWindow := chkAutoCloseMessage.Checked;
{$ENDIF GX_VER170_up} // Delphi 9/2005 (BDS 2)

{$IFDEF GX_STARTUP_LAYOUT_FIX_ENABLED}
  ConfigInfo.SetForceDesktopOnStartup(chkForceStartupDesktop.Checked);
  ConfigInfo.SetForcedStartupDesktop(cbxDesktop.Text);
{$ENDIF}

  IdeEnhancements.EnhanceBuildEventsDialog := chkEnhanceBuildEventsDialog.Checked;
  IdeEnhancements.EnhanceApplicationSettingsDialog:= chkEnhanceApplicationSettingsDialog.Checked;

  // Menus
  ConfigInfo.PlaceGxMainMenuInToolsMenu := chkPlaceGxMainMenuInToolsMenu.Checked;
  GXMenuActionManager.Alphabetical := chkAlphabetizeMenu.Checked;
  GXMenuActionManager.HideWindowMenu := chkHideWindowMenu.Checked;
  GXMenuActionManager.MoveComponentMenu := chkMoveComponentMenu.Checked;

  // File saving
  IdeEnhancements.AutoSave := chkAutoSave.Checked;
  IdeEnhancements.AutoSaveInterval := udMinutes.Position;

  // Object Inspector
  IdeEnhancements.OIFontEnabled := chkOIFontEnabled.Checked;
  IdeEnhancements.OIFont.Assign(FOIFont);
  IdeEnhancements.OICustomFontNames := chkOIFontNames.Checked;
  IdeEnhancements.OIHideHotCmds := chkOIHideHotCmds.Checked;
  IdeEnhancements.OIHideDescPane := chkOIHideDescPane.Checked;

  IdeEnhancements.SaveSettings;
end;

procedure TfmConfiguration.HideUnsupportedIdeItems;
begin
{$IFDEF GX_VER160_up} // Delphi 8 (BDS 1)
  // Only for the old IDEs
  tshOldIdes.TabVisible := False;
{$ENDIF}

{$IFNDEF GX_VER170_up} // Delphi 9/2005 (BDS 2)
  chkAutoCloseMessage.Visible := False;
  chkAutoCloseIgnoreHints.Visible := False;
  chkAutoCloseIgnoreWarnings.Visible := False;
{$ENDIF}

{$IFNDEF GX_VER185_up} // Delphi 2007 (11; BDS 4)
  chkEnhanceBuildEventsDialog.Visible := False;
{$ENDIF}

{$IFNDEF GX_VER210_up} // RAD Studio 2010 (15; BDS 7)
  // These controls were introduced in Delphi 2010
  chkOIHideHotCmds.Visible := False;
  chkOIHideDescPane.Visible := False;
{$ENDIF}
{$IFDEF GX_VER300_up} // RAD Studio 10 Seattle (24; BDS 17)
  // From Delphi 10 on they can be turned on and off in the Object Inspector context menu
  chkOIHideHotCmds.Visible := False;
  chkOIHideDescPane.Visible := False;
{$ENDIF}

{$IFNDEF GX_STARTUP_LAYOUT_FIX_ENABLED}
  chkForceStartupDesktop.Visible := False;
  cbxDesktop.Visible := False;
  l_ForceDestkopAV.Visible := False;
{$ENDIF}

{$IFDEF GX_VER160_up} // Delphi 8 (BDS 1)
  // these are on the debug tab and normally not visible
  btnCPFont.Visible := False;
  chkCPFontEnabled.Visible := False;
{$ENDIF}
end;

procedure TfmConfiguration.chkFontEnabledClick(Sender: TObject);
begin
  btnOIFont.Enabled := chkOIFontEnabled.Checked;
  btnCPFont.Enabled := chkCPFontEnabled.Checked;
end;

procedure TfmConfiguration.btnFontClick(Sender: TObject);
begin
  if Sender = btnOIFont then
  begin
    dlgFont.Font.Assign(FOIFont);
    if dlgFont.Execute then
      FOIFont.Assign(dlgFont.Font);
  end
  else if Sender = btnCPFont then
  begin
    dlgFont.Font.Assign(FCPFont);
    if dlgFont.Execute then
      FCPFont.Assign(dlgFont.Font);
  end;
end;

procedure TfmConfiguration.chkAutoSaveClick(Sender: TObject);
var
  EnableState: Boolean;
begin
  EnableState := (Sender as TCheckBox).Checked;
  lblMinutes.Enabled := EnableState;
  lblEvery.Enabled := EnableState;
  edtMinutes.Enabled := EnableState;
  udMinutes.Enabled := EnableState;
end;

procedure TfmConfiguration.chkCPAsButtonsClick(Sender: TObject);
var
  EnableState: Boolean;
begin
  EnableState := (Sender as TCheckBox).Checked and
                 (Sender as TCheckBox).Enabled;
  chkCPFlat.Enabled := EnableState;
end;

procedure TfmConfiguration.chkCPTabsInPopupClick(Sender: TObject);
var
  EnableState: Boolean;
begin
  EnableState := (Sender as TCheckBox).Checked and
                 (Sender as TCheckBox).Enabled;
  chkCPTabsInPopupAlphaSort.Enabled := EnableState;
end;

procedure TfmConfiguration.chkCPMultiLineClick(Sender: TObject);
var
  EnableState: Boolean;
begin
  EnableState := (Sender as TCheckBox).Checked and
                 (Sender as TCheckBox).Enabled;

  chkCPScrollOpposite.Enabled := EnableState;
  chkCPRaggedRight.Enabled := EnableState;
  if not EnableState then
  begin
    chkCPScrollOpposite.Checked := False;
    chkCPRaggedRight.Checked := False;
  end;
end;

procedure TfmConfiguration.chkMultiLineTabDockHostClick(Sender: TObject);
var
  EnableState: Boolean;
begin
  EnableState := (Sender as TCheckBox).Checked and
                 (Sender as TCheckBox).Enabled;

  chkDefaultMultiLineTabDockHost.Enabled := EnableState;
end;

procedure TfmConfiguration.chkUseCustomFontClick(Sender: TObject);
begin
  if chkUseCustomFont.Checked then begin
    Self.Font.Assign(dlgUIFont.Font);
  end else begin
    GxSetDefaultFont(Self);
  end;
end;

procedure TfmConfiguration.btnEnumerateModulesClick(Sender: TObject);
begin
  GxOtaShowProjectModuleInformation;
end;

procedure TfmConfiguration.btnEumerateActionsClick(Sender: TObject);
begin
  GxOtaShowIDEActions;
end;

procedure TfmConfiguration.btnExportClick(Sender: TObject);
//var
//  fn: string;
begin
//  dlgHelpFile.DefaultExt := 'zip';
//  dlgHelpFile.Filter := 'GExpertSettings (GXSettings*.chm)|GXSettings*.chm';
//  dlgHelpFile.Title := 'Select GExperts Settings';
//  dlgHelpFile.InitialDir :=

//  if not GetOpenSaveDialogExecute(dlgHelpFile) then
//    exit;

//  fn := dlgHelpFile.FileName;
//  SaveAllSettings;
//  ConfigInfo.SaveToFile(fn);
end;

procedure TfmConfiguration.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if ActiveControl is THotKey then
    Exit;
  if (Key = Ord('D')) and (ssCtrl in Shift) then begin
    tshDebug.TabVisible := True;
    pcConfig.ActivePage := tshDebug;
  end;
end;

procedure TfmConfiguration.FormShow(Sender: TObject);
begin
  inherited;
{$ifNdef GExpertsBPL_NoSizeGrip}
{$IFDEF GX_DELPHI2007_UP}
  if pnlButtons.HandleAllocated then
    GxSetWindowSizeGrip(pnlButtonsRight.Handle, True);
{$ENDIF}
{$endif GExpertsBPL_NoSizeGrip}
end;

type TControlCracker = class(TControl);

procedure TfmConfiguration.btnGetFontsClick(Sender: TObject);
var
  Fonts: string;

  procedure AddControl(Control: TControl);
  begin
    if Assigned(Control) then
      Fonts := Fonts + Control.Name + ': ' + TControlCracker(Control).Font.Name + ' ' + IntToStr(TControlCracker(COntrol).Font.Size) + sLineBreak;
  end;

begin
  AddControl(GetIdeMainForm);
  AddControl(GetComponentPaletteTabControl);
  AddControl(GetObjectInspectorForm);
  ShowMessage(Fonts);
end;

procedure TfmConfiguration.btnAppBuilderClick(Sender: TObject);
begin
  OutputComponentList(GetIdeMainForm, False);
end;

procedure TfmConfiguration.btnEditViewClick(Sender: TObject);
begin
  GxOtaShowEditViewDetails;
end;

procedure TfmConfiguration.btnCustomFontClick(Sender: TObject);
begin
  dlgUIFont.Font.Assign(ConfigInfo.CustomFont);
  if dlgUIFont.Execute then
  begin
    chkUseCustomFont.Checked := True;
    Self.Font.Assign(dlgUIFont.Font);
  end;
end;

procedure TfmConfiguration.btnDeleteSuppressedMessageClick(Sender: TObject);
var
  s: string;
  Settings: TGExpertsSettings;
begin
  if not TListBox_GetSelected(lbSuppressedMesages, s) then
    Exit;
  Settings := TGExpertsSettings.Create;
  try
    Settings.WriteBool(TGxMsgBoxAdaptor.ConfigurationKey, s, False);
  finally
    Settings.Free;
  end;
  LoadSuppressedMessages;
end;

procedure TfmConfiguration.chkEnhanceDialogsClick(Sender: TObject);
begin
  UpdateIdeDialogCheckboxes;
end;

procedure TfmConfiguration.UpdateIdeDialogCheckboxes;
var
  EnableState: Boolean;
begin
{$ifdef GExpertsBPL_NoIdeEnhance}
  chkEnhanceDialogs.Enabled := False;
{$endif GExpertsBPL_NoIdeEnhance}
  EnableState := chkEnhanceDialogs.Checked and
                 chkEnhanceDialogs.Enabled;
  chkAllowResize.Enabled := EnableState;
  chkRememberPosition.Enabled := EnableState;
  chkEnhanceSearchPaths.Enabled := EnableState;
  chkEnhanceToolProperties.Enabled := EnableState;
  chkEnhanceInstallPackages.Enabled := EnableState;
  chkEnhanceDockForms.Enabled := EnableState;
  chkEnhanceBuildEventsDialog.Enabled := EnableState;
  chkEnhanceApplicationSettingsDialog.Enabled := EnableState;
{$IFDEF GX_VER170_up} // Delphi 9/2005 (BDS 2)
  chkAutoCloseMessage.Enabled := EnableState;
{$ENDIF}
{$IFDEF GX_STARTUP_LAYOUT_FIX_ENABLED}
  chkForceStartupDesktop.Enabled := EnableState;
{$ENDIF}
end;

end.

