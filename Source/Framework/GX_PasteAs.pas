unit GX_PasteAs;

interface

uses
  Windows, SysUtils, Classes, Controls,
  GX_ConfigurationInfo, GX_EditorExpert;

type
  TPasteAsType = (paStringArray, paAdd, paSLineBreak,
    paChar10, paChar13, paChars1310, paCRLF, paCR_LF);

  TPasteAsHandler = class
  private
    FCreateQuotedString: Boolean;
    FPasteAsType: TPasteAsType;
    FAddExtraSpaceAtTheEnd: Boolean;
    FShowOptions: Boolean;
    function DetermineIndent(ALines: TStrings): Integer;
  public
    constructor Create;
    procedure LoadSettings(_Settings: IExpertSettings);
    procedure SaveSettings(_Settings: iExpertSettings);
    procedure ConvertToCode(ALines: TStrings; AOnlyUpdateLines: Boolean);
    procedure ExtractRawStrings(ALines: TStrings; ADoAddBaseIndent: Boolean);
    function  ExecuteConfig(_ConfigExpert: TEditorExpert; _Owner: TWinControl; _ForceShow: Boolean): Boolean;
    class procedure GetTypeText(AList: TStrings);
    property CreateQuotedString: Boolean read FCreateQuotedString write FCreateQuotedString;
    property PasteAsType: TPasteAsType read FPasteAsType write FPasteAsType;
    property AddExtraSpaceAtTheEnd: Boolean read FAddExtraSpaceAtTheEnd write FAddExtraSpaceAtTheEnd;
    property ShowOptions: Boolean read FShowOptions write FShowOptions;
  end;

var
  PasteAsHandler: TPasteAsHandler;

implementation

uses
  StrUtils,
  u_dzStringUtils, u_dzVclUtils,
  GX_OtaUtils, GX_ePasteAs, GX_GenericUtils;

const
  cPasteAsTypeText: array[TPasteAsType] of String = (
    '%s,', 'Add(%s);', '%s + sLineBreak +',
    '%s + #10 +', '%s + #13 +', '%s + #13#10 +', '%s + CRLF +', '%s + CR_LF +');
  cStringSep = '''';

{ TPasteAsHandler }

constructor TPasteAsHandler.Create;
begin
  inherited Create;
  FCreateQuotedString := True;
  FPasteAsType := paStringArray;
  FAddExtraSpaceAtTheEnd := True;
end;

class procedure TPasteAsHandler.GetTypeText(AList: TStrings);
var
  AType: TPasteAsType;
begin
  for AType := Low(TPasteAsType) to High(TPasteAsType) do
    AList.AddObject(cPasteAsTypeText[AType], TObject(Integer(AType)));
end;

procedure TPasteAsHandler.LoadSettings(_Settings: IExpertSettings);
begin
  PasteAsType := TPasteAsType(_Settings.ReadEnumerated('PasteAsType', TypeInfo(TPasteAsType), Ord(paStringArray)));
  CreateQuotedString := _Settings.ReadBool('CreateQuotedString', True);
  AddExtraSpaceAtTheEnd := _Settings.ReadBool('AddExtraSpaceAtTheEnd', True);
  ShowOptions := _Settings.ReadBool('ShowOptions', True);
end;

procedure TPasteAsHandler.SaveSettings(_Settings: IExpertSettings);
begin
  _Settings.WriteEnumerated('PasteAsType', TypeInfo(TPasteAsType), Ord(FPasteAsType));
  _Settings.WriteBool('CreateQuotedString', FCreateQuotedString);
  _Settings.WriteBool('AddExtraSpaceAtTheEnd', FAddExtraSpaceAtTheEnd);
  _Settings.WriteBool('ShowOptions', FShowOptions);
end;

function TPasteAsHandler.DetermineIndent(ALines: TStrings): Integer;
var
  i: Integer;
  Line: string;
  FCP: Integer;
begin
  Result := MaxInt;
  for i := 0 to ALines.Count-1 do
  begin
    Line := ALines[i];
    FCP := GetFirstCharPos(Line, [' ', #09], False);
    if FCP < Result then
      Result := FCP;
  end;
end;

procedure TPasteAsHandler.ConvertToCode(ALines: TStrings; AOnlyUpdateLines: Boolean);
var
  I, FirstCharPos: Integer;
  ALine, BaseIndent, ALineStart, ALineEnd, ALineStartBase, AAddDot: String;
begin
  FirstCharPos := DetermineIndent(ALines);
  // this works, because FirstCharPos is the smallest Indent for all lines
  BaseIndent := LeftStr(ALines[0], FirstCharPos - 1);

  ALineStart := '';
  ALineEnd := '';
  ALineStartBase := '';
  AAddDot := '';
  case FPasteAsType of
    paStringArray: ALineEnd := ',';
    paAdd:
    begin
      if not AOnlyUpdateLines then
      begin
        ALineStartBase := Trim(GxOtaGetCurrentSelection(False));
        if (ALineStartBase <> '') and (ALineStartBase[Length(ALineStartBase)] <> '.') then
          AAddDot := '.';
        ALineStartBase := ALineStartBase + AAddDot;
      end;
      ALineStart := 'Add(';
      ALineEnd := ');';
    end;
    paSLineBreak: ALineEnd := ' + sLineBreak +';
    paChar10: ALineEnd := '#10 +';
    paChar13: ALineEnd := '#13 +';
    paChars1310: ALineEnd := '#13#10 +';
    paCRLF: ALineEnd := ' + CRLF +';
    paCR_LF: ALineEnd := ' + CR_LF +';
  end;

  for I := 0 to ALines.Count-1 do
  begin
    ALine := Copy(ALines[I], FirstCharPos);

    if FCreateQuotedString then
      ALine := AnsiQuotedStr(ALine + IfThen(FAddExtraSpaceAtTheEnd, ' '), cStringSep);

    ALine := ALineStart + ALine;
    if ALineStartBase <> '' then
      ALine := IfThen(I = 0, AAddDot, ALineStartBase) + ALine;
    if (I < ALines.Count-1) or (FPasteAsType = paAdd) then
      ALine := ALine + ALineEnd;

    ALines[I] := BaseIndent + ALine;

    if not AOnlyUpdateLines then
      GxOtaInsertLineIntoEditor(ALine + sLineBreak);
  end;
end;

procedure TPasteAsHandler.ExtractRawStrings(ALines: TStrings; ADoAddBaseIndent: Boolean);
var
  i, FirstCharPos, FirstQuotePos, LastQuotePos: Integer;
  Line, BaseIndent: String;
  sl: TStringList;
begin
  FirstCharPos := DetermineIndent(ALines);
  // this works, because FirstCharPos is the smallest Indent for all lines
  BaseIndent := LeftStr(ALines[0], FirstCharPos - 1);

  sl := TStringList.Create;
  try
    for i := 0 to ALines.Count-1 do
    begin
      Line := Trim(Copy(ALines[i], FirstCharPos));

      FirstQuotePos := GetFirstCharPos(Line, [cStringSep], True);
      LastQuotePos := GetLastCharPos(Line, [cStringSep], True);
      if (FirstQuotePos > 0) and (LastQuotePos > 0) then
      begin
        Line := Copy(Line, FirstQuotePos, LastQuotePos - FirstQuotePos + 1);
        // It's not "not FCreateQuotedString" because this is the ExtractRawStrings method
        // the ConvertToCode will add the quotes again, if FCreateQuotedString is true.
        if FCreateQuotedString then
          Line := AnsiDequotedStr(Line, cStringSep);
       sl.Add(IfThen(ADoAddBaseIndent, BaseIndent) + TrimRight(Line));
      end;
    end;

    ALines.Assign(sl);
  finally
    FreeAndNil(sl);
  end;
end;

function TPasteAsHandler.ExecuteConfig(_ConfigExpert: TEditorExpert; _Owner: TWinControl; _ForceShow: Boolean): Boolean;
begin
  Result := True;
  if not FShowOptions and not _ForceShow then
    Exit; //==>

  Result := TfmPasteAsConfig.Execute(_Owner,
    FPasteAsType, FCreateQuotedString, FAddExtraSpaceAtTheEnd, FShowOptions);
  if Result then
    if Assigned(_ConfigExpert) then
      _ConfigExpert.SaveSettings;
end;

initialization
  PasteAsHandler := TPasteAsHandler.Create;

finalization
  FreeAndNil(PasteAsHandler);

end.

