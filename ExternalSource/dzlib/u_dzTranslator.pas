{.GXFormatter.config=twm}
unit u_dzTranslator;

{$INCLUDE 'dzlib.inc'}

{$IFNDEF NO_TRANSLATION}
// for now uses gnugettext
{$DEFINE gnugettext}
{$ELSE}
{$IFNDEF NO_TRANSLATION_HINT}
{$MESSAGE HINT 'translation is turned off, remove NO_TRANSLATION define to turn it on'}
{$ENDIF}
{$ENDIF}

// if defined, any code requiring VCL units is omited below, use this for WinAPI only programs
{.$define NoVCL}

interface

uses
  SysUtils,
{$IFDEF gnugettext}
  // NOTE: If you don't want any translations, define "NO_TRANSLATION" for your project
  gnugettext, // libs\dxgettext\lib
  languagecodes,
{$ENDIF}
  Classes;

const
  DZLIB_TRANSLATION_DOMAIN = 'dzlib';

type
{$IFDEF gnugettext}
  DomainString = gnugettext.DomainString;
  LanguageString = gnugettext.LanguageString;
  ComponentNameString = gnugettext.ComponentNameString;
  MsgIdString = gnugettext.MsgIdString;
  TranslatedUnicodeString = gnugettext.TranslatedUnicodeString;
{$ELSE}
{$IFNDEF UNICODE}
  UnicodeString = WideString;
{$ENDIF}
  DomainString = string;
  LanguageString = string;
  ComponentNameString = string;
  MsgIdString = UnicodeString;
  TranslatedUnicodeString = UnicodeString;
{$ENDIF}

function _(const _s: MsgIdString): TranslatedUnicodeString;
/// we can't inline this function because we don't want to add gnugettext to units using it

function GetText(const _s: MsgIdString): TranslatedUnicodeString;
/// we can't inline this function because we don't want to add gnugettext to units using it

function dzGetText(const _s: MsgIdString): TranslatedUnicodeString;
/// we can't inline this function because we don't want to add gnugettext to units using it

function DGetText(const _s: MsgIdString; const _TextDomain: DomainString = ''): TranslatedUnicodeString;
/// we can't inline this function because we don't want to add gnugettext to units using it

///<summary> use this if you pass variables rather than constants to avoid warnings in the dxgettext tool </summary>
function dzDGetText(const _s: MsgIdString; const _TextDomain: DomainString = ''): TranslatedUnicodeString;
/// we can't inline this function because we don't want to add gnugettext to units using it

///<summary> translate using the DZLIB_TRANSLATION_DOMAIN </summary>
function dzlibGetText(const _s: MsgIdString): TranslatedUnicodeString;
procedure TranslateComponent(_Object: TComponent; const _TextDomain: DomainString = '');
procedure RetranslateComponent(_Object: TComponent; const _TextDomain: DomainString = '');
procedure AddDomainForResourceString(const _Domain: DomainString);
procedure SelectTextDomain(const _Domain: DomainString);
procedure TP_GlobalIgnoreClass(_IgnClass: TClass);
function TP_TryGlobalIgnoreClass(_IgnClass: TClass): Boolean;
procedure TP_GlobalIgnoreClassProperty(_IgnClass: TClass; const _PropertyName: ComponentNameString);
///<summary>
/// Sets the language to use </summary>
procedure UseLanguage(const _LanguageCode: LanguageString);
function GetCurrentLanguage: LanguageString; deprecated; // use GetCurrentLocaleName instead
function GetCurrentLocaleName: LanguageString;
///<summary>
/// Sets the language to use if the desired language is not available, defaults to English </summary>
procedure SetDefaultLanguage(const _LanguageCode: LanguageString);

///<summary>
/// gets a list of languages for which translations are available </summary>
procedure GetListOfLanguages(const _Domain: DomainString; _Codes: TStrings; _Languages: TStrings = nil);

type
  {: use this for translation of special strings that might not be in the same language
     as the program (e.g. a German program generating an English report }
  IdzTranslator = interface ['{FD88CFEE-F2D6-45FB-BBD2-D3C6BE066683}']
    function GetText(const _s: MsgIdString): TranslatedUnicodeString;
  end;

function GenerateTranslator(const _LanguageCode: LanguageString): IdzTranslator;

implementation

{$IFNDEF CONSOLE}
{$IFNDEF NoVCL}
uses
  Windows,
  Controls,
  ActnList,
  Graphics,
  ExtCtrls;
{$ENDIF NoVCL}
{$ENDIF CONSOLE}

function _(const _s: MsgIdString): TranslatedUnicodeString;
begin
{$IFDEF gnugettext}
  Result := gnugettext._(_s);
{$ELSE}
  Result := _s;
{$ENDIF}
end;

function GetText(const _s: MsgIdString): TranslatedUnicodeString;
begin
  Result := u_dzTranslator._(_s);
end;

function dzGetText(const _s: MsgIdString): TranslatedUnicodeString;
begin
  Result := u_dzTranslator._(_s);
end;

function DGetText(const _s: MsgIdString; const _TextDomain: DomainString = ''): TranslatedUnicodeString;
begin
{$IFDEF gnugettext}
  Result := gnugettext.DGetText(_TextDomain, _s);
{$ELSE}
  Result := _s;
{$ENDIF}
end;

function dzDGetText(const _s: MsgIdString; const _TextDomain: DomainString = ''): TranslatedUnicodeString;
begin
  Result := DGetText(_s, _TextDomain);
end;

function dzlibGetText(const _s: MsgIdString): TranslatedUnicodeString;
begin
  Result := dzDGetText(_s, DZLIB_TRANSLATION_DOMAIN);
end;

procedure TranslateComponent(_Object: TComponent; const _TextDomain: DomainString = '');
begin
{$IFDEF gnugettext}
  gnugettext.TranslateComponent(_Object, _TextDomain);
{$ENDIF}
end;

procedure RetranslateComponent(_Object: TComponent; const _TextDomain: DomainString = '');
begin
{$IFDEF gnugettext}
  gnugettext.RetranslateComponent(_Object, _TextDomain);
{$ENDIF}
end;

procedure AddDomainForResourceString(const _Domain: DomainString);
begin
{$IFDEF gnugettext}
  gnugettext.AddDomainForResourceString(_Domain);
{$ENDIF}
end;

procedure SelectTextDomain(const _Domain: DomainString);
begin
{$IFDEF gnugettext}
  gnugettext.textdomain(_Domain);
{$ENDIF}
end;

procedure TP_GlobalIgnoreClass(_IgnClass: TClass);
begin
{$IFDEF gnugettext}
  gnugettext.TP_GlobalIgnoreClass(_IgnClass);
{$ENDIF}
end;

function TP_TryGlobalIgnoreClass(_IgnClass: TClass): Boolean;
begin
{$IFDEF gnugettext}
  Result := gnugettext.TP_TryGlobalIgnoreClass(_IgnClass);
{$ELSE}
  Result := True;
{$ENDIF}
end;

procedure TP_GlobalIgnoreClassProperty(_IgnClass: TClass; const _PropertyName: ComponentNameString);
begin
{$IFDEF gnugettext}
  gnugettext.TP_GlobalIgnoreClassProperty(_IgnClass, _PropertyName);
{$ENDIF}
end;

const
  DEFAULT_LANGUAGE = 'en';
var
  gblDefaultLanguage: LanguageString = DEFAULT_LANGUAGE;

procedure UseLanguage(const _LanguageCode: LanguageString);
{$IFDEF gnugettext}
var
  Codes: TStringList;
  CurLang: LanguageString;
  i: Integer;
  p: Integer;
{$ENDIF}
begin
{$IFDEF gnugettext}
  gnugettext.UseLanguage(_LanguageCode);

  CurLang := gnugettext.GetCurrentLocaleName;
  Codes := TStringList.Create;
  try
    GetListOfLanguages('default', Codes);
    for i := 0 to Codes.Count - 1 do begin
      if SameText(CurLang, Codes[i]) then begin
        // There is a translation for this language and country, everything is fine
        Exit; //-->
      end;
    end;
    // no translation found, try without the country code
    p := Pos('_', CurLang);
    if p <> 0 then begin
      CurLang := Copy(CurLang, 1, p - 1);
      for i := 0 to Codes.Count - 1 do begin
        if SameText(CurLang, Codes[i]) then begin
          // There is a translation for this language but not country, we can live with that
          Exit; //-->
        end;
      end;
    end;
  finally
    FreeAndNil(Codes);
  end;

  // we found no translation for this language, so we use the default language
  gnugettext.UseLanguage(gblDefaultLanguage);
{$ENDIF}
end;

procedure SetDefaultLanguage(const _LanguageCode: LanguageString);
begin
  if _LanguageCode = '' then
    gblDefaultLanguage := DEFAULT_LANGUAGE
  else
    gblDefaultLanguage := _LanguageCode;
{$IFDEF gnugettext}
  UseLanguage(gnugettext.GetCurrentLocaleName);
{$ENDIF}
end;

procedure GetListOfLanguages(const _Domain: DomainString; _Codes: TStrings; _Languages: TStrings = nil);
{$IFDEF gnugettext}
var
  i: Integer;
{$ENDIF}
begin
{$IFDEF gnugettext}
  _Codes.Clear;
  gnugettext.DefaultInstance.GetListOfLanguages(_Domain, _Codes);
  if Assigned(_Languages) then begin
    _Languages.Clear;
    for i := 0 to _Codes.Count - 1 do begin
      _Languages.Add(languagecodes.getlanguagename(_Codes[i]));
    end;
  end;
{$ENDIF}
end;

function GetCurrentLanguage: LanguageString;
begin
  Result := GetCurrentLocaleName;
end;

function GetCurrentLocaleName: LanguageString;
begin
{$IFDEF gnugettext}
  Result := gnugettext.GetCurrentLocaleName;
{$ELSE}
  Result := '';
{$ENDIF}
end;

type
  TdzTranslator = class(TInterfacedObject, IdzTranslator)
  protected
{$IFDEF gnugettext}
    fGetTextInstance: TGnuGettextInstance;
{$ENDIF}
  protected
    function GetText(const _s: MsgIdString): TranslatedUnicodeString;
  public
    constructor Create(const _LanguageCode: LanguageString);
  end;

constructor TdzTranslator.Create(const _LanguageCode: LanguageString);
begin
  inherited Create;
{$IFDEF gnugettext}
  fGetTextInstance := TGnuGettextInstance.Create;
  fGetTextInstance.UseLanguage(_LanguageCode);
{$ENDIF}
end;

function TdzTranslator.GetText(const _s: MsgIdString): TranslatedUnicodeString;
begin
{$IFDEF gnugettext}
  Result := fGetTextInstance.GetText(_s);
{$ELSE}
  Result := _s;
{$ENDIF}
end;

function GenerateTranslator(const _LanguageCode: LanguageString): IdzTranslator;
begin
  Result := TdzTranslator.Create(_LanguageCode);
end;

{$IFDEF gnugettext}
initialization
//  Windows.MessageBox(0, 'attach debugger now', 'u_dzTranslator', 0);
  SetDefaultLanguage(DEFAULT_LANGUAGE);

  // translate runtime library
  AddDomainForResourceString('delphi');

{$IFNDEF CONSOLE}
{$IFNDEF NoVCL}
  // ignore these VCL properties / classes
  TP_GlobalIgnoreClassProperty(TAction, 'Category');
  TP_GlobalIgnoreClassProperty(TControl, 'ImeName');
  TP_GlobalIgnoreClassProperty(TControl, 'HelpKeyword');
  TP_TryGlobalIgnoreClass(TFont);
  TP_GlobalIgnoreClassProperty(TNotebook, 'Pages');
{$ENDIF NoVCL}
{$ENDIF CONSOLE}
// for more ignores, see u_dzTranslatorDB, u_dzTranslatorADO and other u_dzTranslatorXxx units

{$IFDEF DXGETTEXTDEBUG}
  gnugettext.DefaultInstance.DebugLogToFile(ExtractFilePath(GetModuleName(HInstance)) + 'dxgettext.log');
{$ENDIF DXGETTEXTDEBUG}

{$ENDIF gnugettext}
end.

