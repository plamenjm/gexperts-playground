unit GX_BaseExpert;

interface

uses
  Classes, Graphics, Controls,
  {$IFOPT D+} GX_DbugIntf, {$ENDIF}
  GX_ConfigurationInfo, GX_Actions;

type
  TGX_BaseExpert = class(TObject)
  private
{$IF Declared(SendDebugWarning)}
    FNoDisplaynameWarningSent: Boolean;
{$IFEND}
    FCallCount: Integer;
    FShortCut: TShortCut;
    function GetTotalCallCount: Integer;
    procedure SetTotalCallCount(Value: Integer);
  protected
    FBitmap: TBitmap;
    FActive: Boolean;
    FActionInt: IGxAction;
    procedure SetActive(New: Boolean); virtual;
    function GetShortCut: TShortCut; virtual;
    procedure SetShortCut(Value: TShortCut); virtual;
    // Override to load any configuration settings
    procedure InternalLoadSettings(_Settings: IExpertSettings); virtual;
    // Override to save any configuration settings
    procedure InternalSaveSettings(_Settings: IExpertSettings); virtual;
    // do nothing, overridden by TGX_Expert and TEditorExpert because
    // theses settings are "traditionally" stored differently.
    procedure LoadActiveAndShortCut(Settings: TGExpertsSettings); virtual;
    // do nothing, overridden by TGX_Expert and TEditorExpert because
    // theses settings are "traditionally" stored differently.
    procedure SaveActiveAndShortCut(Settings: TGExpertsSettings); virtual;
  public
    ///<sumary>
    /// @returns the internal name of expert for expert identification
    ///          defaults to ClassName </summary>
    class function GetName: string; virtual;
    ///<sumary>
    /// @returns the Subkey used to store configuration details in the registry
    ///          defaults to GetName </summary>
    class function ConfigurationKey: string; virtual;
    ///<sumary>
    /// @returns the file name of an icon associated with
    /// the expert. Do not specify a path.
    /// This bitmap must be included in the
    /// GXIcons.rc file which in turn can be created
    /// from all .bmp files located in the Images
    /// directory by calling the _CreateGXIconsRc.bat
    /// script located in that directory.
    /// It is possible to return an empty string. This
    /// signals that no icon file is available.
    /// Defaults to ClassName. </summary>
    class function GetBitmapFileName: string; virtual;
    ///<summary>
    /// Loads the bitmap for the expert from resources and returns it.
    /// In contrast to GetBitmap, this always loads and creates a new bitmap
    /// or NIL if the bitmap could not be loaded.
    /// @NOTE: The caller is responsible for freeing that bitmap /// </summary>
    class function LoadBitmap: TBitmap; virtual;
    ///<summary>
    /// Name of action to be created for expert; by default,
    /// the action name is constructed from the expert's name. </summary>
    class function GetActionName: string;
    ///<summary>
    /// Caption of a menu item entry.
    /// Defaults to GetName (we don't want any abstract methods),
    /// but descendants should override this method. </summary>
    function GetActionCaption: string; virtual;
  constructor Create;
    destructor Destroy; override;
    function CanHaveShortCut: boolean; virtual; abstract;
    // displays a dialog saying there are no configuration options
    // see also HasConfigOptions
    procedure Configure(_Owner: TWinControl); virtual;
    // @returns true, if the expert maintains a call count. Most experts return true, with
    // the notable exception of the Grep Search expert because its calls are counted
    // by the Grep Results expert.
    function HasCallCount: Boolean; virtual;
    procedure IncCallCount;
    procedure Execute(Sender: TObject); virtual; abstract;
    // Get a reference to the bitmap for menu items, buttons, etc.
    // Note that this bitmap is loaded and unloaded on demand;
    // you will have to .Assign the bitmap to get a permanent copy.
    function GetBitmap: Graphics.TBitmap; virtual;
    // Name to be displayed for the expert in the GExperts
    // *configuration* dialog; this might be different from
    // the action caption (GetActionCaption) but is the default
    // for that as well.
    function GetDisplayName: string; virtual;
    // Describes the purpose of the expert. Displayed
    // as hint if the user points the mouse on the expert's icon
    // in the configuration dialog.
    function GetHelpString: string; virtual;
    // Returns 0, meaning: No default shortcut
    function GetDefaultShortCut: TShortCut; virtual;
    // Returns true, see also Configure
    function HasConfigOptions: Boolean; virtual;
    class function GetSettings: IExpertSettings; virtual;
    // Creates a Settings object and passes it to
    // the virtual methods
    // LoadActiveAndShortCut and InternalLoadSettings
    // override InternalLoadSettings to actually load the settings.
    procedure LoadSettings; overload;
    procedure LoadSettings(_GxSettings: TGExpertsSettings); overload;
    // Creates a Settings object and passes it to
    // the virtual methods
    // SaveActiveAndShortCut and InternalSaveSettings
    // override InternalSaveSettings to actually save the settings.
    procedure SaveSettings; overload;
    procedure SaveSettings(_GxSettings: TGExpertsSettings); overload;
    // Returns an empty string, overridden by TGX_Expert and TEditorExpert
    // to return the correct values.
    class function GetOptionsBaseRegistryKey: string; virtual;
    // Defaults to True
    function IsDefaultActive: Boolean; virtual;
    procedure ClearCallCounts;
    property Active: Boolean read FActive write SetActive;
    property ShortCut: TShortCut read GetShortCut write SetShortCut;
    property CallCount: Integer read FCallCount;
    property TotalCallCount: Integer read GetTotalCallCount;
  end;

type
  TGX_BaseExpertClass = class of TGX_BaseExpert;

implementation

uses
  SysUtils, Dialogs, GX_GxUtils, GX_MessageBox, GX_IconMessageBox;

{ TGX_BaseExpert }

constructor TGX_BaseExpert.Create;
begin
  inherited Create;
  FCallCount := 0;
  FShortCut := GetDefaultShortCut;
end;

destructor TGX_BaseExpert.Destroy;
begin
  FActionInt := nil; // Clear out interface reference.

  FreeAndNil(FBitmap);
  try
    SetTotalCallCount(GetTotalCallCount + FCallCount);
  except
    // ignore exceptions in the destructor
  end; // FI:W501 Empty EXCEPT block

  inherited;
end;

procedure TGX_BaseExpert.ClearCallCounts;
begin
  SetTotalCallCount(0);
  FCallCount := 0;
end;

class function TGX_BaseExpert.ConfigurationKey: string;
begin
  Result := GetName;
end;

procedure TGX_BaseExpert.Configure(_Owner: TWinControl);
resourcestring
  SNoConfigurationOptions = 'There are no configuration options for this expert.';
begin
  MessageDlg(SNoConfigurationOptions, mtInformation, [mbOK], 0);
end;

class function TGX_BaseExpert.LoadBitmap: TBitmap;
var
  BitmapFile: string;
begin
  Result := nil;
  BitmapFile := GetBitmapFileName;
  if BitmapFile <> '' then begin
    if not GxLoadBitmapForExpert(BitmapFile, Result) then begin
{$IF Declared(SendDebugError)}
      SendDebugError('Missing bitmap ' + GetBitmapFileName + ' for ' + Self.ClassName);
{$IFEND}
      GxLoadBitmapForExpert('NoIcon', Result);
    end;
  end;
end;

function TGX_BaseExpert.GetActionCaption: string;
begin
  Result := GetName;
end;

class function TGX_BaseExpert.GetActionName: string;
begin
  // Default action name from expert name; do not localize.
  Result := 'GX_' + GetName + 'Action';
end;

function TGX_BaseExpert.GetBitmap: Graphics.TBitmap;
begin
  if not Assigned(FBitmap) then begin
    FBitmap := LoadBitmap;
  end;
  Result := FBitmap;
end;

class function TGX_BaseExpert.GetBitmapFileName: string;
begin
  Result := ClassName;
end;

function TGX_BaseExpert.GetDefaultShortCut: TShortCut;
begin
  Result := 0;
end;

function TGX_BaseExpert.GetDisplayName: string;
begin
{$IF Declared(SendDebugWarning)}
  if not FNoDisplaynameWarningSent then begin
    SendDebugWarning('The expert ' + Self.ClassName + ' does not provide a human-readable name');
    FNoDisplaynameWarningSent := True;
  end;
{$IFEND}
  Result := Self.ClassName;
end;

function TGX_BaseExpert.GetHelpString: string;
begin
  Result := '';
end;

class function TGX_BaseExpert.GetName: string;
begin
  // This used to send an error to the debug window, but since there is nothing
  // wrong with using the ClassName and it is also described as optional in the
  // sample experts, we no longer do that.
  Result := Self.ClassName;
end;

class function TGX_BaseExpert.GetOptionsBaseRegistryKey: string;
begin
  Result := '';
end;

class function TGX_BaseExpert.GetSettings: IExpertSettings;
begin
  Result := ConfigInfo.GetExpertSettings(ConfigurationKey, GetOptionsBaseRegistryKey);
end;

function TGX_BaseExpert.GetShortCut: TShortCut;
begin
  Result := FShortCut;
end;

function TGX_BaseExpert.HasCallCount: Boolean;
begin
  Result := True;
end;

function TGX_BaseExpert.HasConfigOptions: Boolean;
begin
  Result := True;
end;

procedure TGX_BaseExpert.IncCallCount;
begin
  Inc(FCallCount);
end;

procedure TGX_BaseExpert.InternalLoadSettings(_Settings: IExpertSettings);
begin
  // do nothing
end;

procedure TGX_BaseExpert.InternalSaveSettings(_Settings: IExpertSettings);
begin
  // do nothing
end;

function TGX_BaseExpert.IsDefaultActive: Boolean;
begin
  Result := True;
end;

procedure TGX_BaseExpert.LoadActiveAndShortCut(Settings: TGExpertsSettings);
begin
  // do nothing here, overridden by TGX_Expert and TEditorExpert because
  // theses settings are "traditionally" stored differently.
end;

procedure TGX_BaseExpert.LoadSettings;
var
  Settings: TGExpertsSettings;
begin
  Settings := TGExpertsSettings.Create(GetOptionsBaseRegistryKey);
  try
    LoadSettings(Settings);
  finally
    FreeAndNil(Settings);
  end;
end;

procedure TGX_BaseExpert.LoadSettings(_GxSettings: TGExpertsSettings);
begin
  LoadActiveAndShortCut(_GxSettings);
  InternalLoadSettings(GetSettings);
end;

function TGX_BaseExpert.GetTotalCallCount: Integer;
var
  Settings: TGExpertsSettings;
  ExpSettings: TExpertSettings;
begin
  Settings := TGExpertsSettings.Create(GetOptionsBaseRegistryKey);
  try
    ExpSettings := Settings.CreateExpertSettings(ConfigurationKey);
    try
      Result := ExpSettings.ReadInteger('TotalCallCount', 0);
    finally
      FreeAndNil(ExpSettings);
    end;
  finally
    FreeAndNil(Settings);
  end;
end;

procedure TGX_BaseExpert.SaveActiveAndShortCut(Settings: TGExpertsSettings);
begin
  // do nothing here, overridden by TGX_Expert and TEditorExpert because
  // theses settings are "traditionally" stored differently.
end;

procedure TGX_BaseExpert.SaveSettings;
var
  Settings: TGExpertsSettings;
begin
  Settings := TGExpertsSettings.Create(GetOptionsBaseRegistryKey);
  try
    SaveSettings(Settings);
  finally
    FreeAndNil(Settings);
  end;
end;

procedure TGX_BaseExpert.SaveSettings(_GxSettings: TGExpertsSettings);
begin
  SaveActiveAndShortCut(_GxSettings);

  InternalSaveSettings(GetSettings);
end;

procedure TGX_BaseExpert.SetTotalCallCount(Value: Integer);
var
  Settings: TGExpertsSettings;
  ExpSettings: TExpertSettings;
begin
  Settings := TGExpertsSettings.Create(GetOptionsBaseRegistryKey);
  try
    ExpSettings := Settings.CreateExpertSettings(ConfigurationKey);
    try
      ExpSettings.WriteInteger('TotalCallCount', Value);
    finally
      FreeAndNil(ExpSettings);
    end;
  finally
    FreeAndNil(Settings);
  end;
end;

procedure TGX_BaseExpert.SetActive(New: Boolean);
begin
  if FActive <> New then
    if Assigned(FActionInt) then begin
      if New then
        FActionInt.ShortCut := FShortCut
      else
        FActionInt.ShortCut := 0;
    end;
  FActive := New;
end;

procedure TGX_BaseExpert.SetShortCut(Value: TShortCut);
begin
  FShortCut := Value;
  if FActive and Assigned(FActionInt) then
    FActionInt.ShortCut := FShortCut;
end;

end.
