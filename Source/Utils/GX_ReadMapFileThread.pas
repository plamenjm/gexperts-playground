unit GX_ReadMapFileThread;

{$I GX_CondDefine.inc}

interface

uses
  Windows,
  SysUtils,
  Classes,
  SyncObjs,
  u_dzErrorThread;

type
  TReadMapFileThread = class(TErrorThread)
  private
    FSearchPath: TStringList;
    FMapFile: string;
    FResults: TStringList;
    FResultsLock: TCriticalSection;
    FOnFindComplete: TThreadMethod;
    FFileExtensions: TStringList;
  protected
    procedure doExecute; override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure StartFind;
    procedure LockResults;
    procedure ReleaseResults;
    property SearchPath: TStringList read FSearchPath;
    property FileExtensions: TStringList read FFileExtensions;
    property OnFindComplete: TThreadMethod read FOnFindComplete write FOnFindComplete;
    property Results: TStringList read FResults;
  end;

implementation

uses
  u_dzMapFileReader,
  GX_OtaUtils,
  GX_GenericUtils;

{ TReadMapFileThread }

constructor TReadMapFileThread.Create;
begin
  inherited Create(True);
  FResultsLock := TCriticalSection.Create;
  FSearchPath := TStringList.Create;
  FResults := TStringList.Create;
  FFileExtensions := TStringList.Create;
end;

destructor TReadMapFileThread.Destroy;
begin
  inherited;
  FreeAndNil(FFileExtensions);
  FreeAndNil(FResults);
  FreeAndNil(FSearchPath);
  FreeAndNil(FResultsLock);
end;

procedure TReadMapFileThread.doExecute;
var
  UnitIdx: Integer;
  Reader: TMapFileReader;
  FileName: string;
  FilenameOnly: string;
  FilenameExt: string;
  PathIdx: Integer;
  ExtensionIndex: Integer;
begin
  inherited;

  try
    LockResults;
    try
      FResults.Clear;
    finally
      ReleaseResults;
    end;

    Reader := TMapFileReader.Create(FMapFile);
    try
      if Terminated then
        Exit;
      for UnitIdx := 0 to Reader.Units.Count - 1 do begin
        FilenameOnly := Reader.Units[UnitIdx];
        for ExtensionIndex := 0 to FFileExtensions.Count - 1 do begin
          FilenameExt := ChangeFileExt(FilenameOnly, ExtractFileExt(FFileExtensions[ExtensionIndex]));
          for PathIdx := 0 to FSearchPath.Count - 1 do begin
            FileName := AddSlash(FSearchPath[PathIdx]) + FilenameExt;
            if FileExists(FileName) then begin
              LockResults;
              try
                FResults.Add(ExpandFileName(FileName));
              finally
                ReleaseResults;
              end;
            end;
            if Terminated then
              Exit;
          end;
        end;
      end;
    finally
      FreeAndNil(Reader);
    end;
    if Terminated then
      Exit;
    if Assigned(FOnFindComplete) then
      Synchronize(FOnFindComplete);
  except
    on E: Exception do
      MessageBox(0, PChar(E.Message), 'File Search Thread', MB_OK + MB_ICONERROR + MB_APPLMODAL);
  end;
end;

procedure TReadMapFileThread.LockResults;
begin

end;

procedure TReadMapFileThread.ReleaseResults;
begin

end;

procedure TReadMapFileThread.StartFind;
begin
  if GxOtaGetCurrentMapFileName(FMapFile) then begin
{$IFDEF GX_VER210_up}
    Start;
{$ELSE}
    Resume;
{$ENDIF}
  end;
end;

end.
