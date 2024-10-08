{***************************************************************
 * Unit Name: GX_Bookmarks
 * Authors  : Thomas Mueller http://blog.dummzeuch.de
 ****************************************************************}

unit GX_Bookmarks;

{$I GX_CondDefine.inc}

interface

uses
  SysUtils,
  Classes,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ComCtrls,
  ToolsAPI,
  ExtCtrls,
  Menus,
  Types,
{$IFDEF GX_IDE_IS_HIDPI_AWARE}
  u_dzDpiScaleUtils,
{$ENDIF}
  GX_Experts,
  GX_BaseForm,
  GX_IdeDock,
  GX_BookmarkList;

type
  TfmGxBookmarksForm = class(TfmIdeDockForm)
    p_Bookmarks: TPanel;
    lb_Bookmarks: TListBox;
    tim_Update: TTimer;
    pm_Bookmarks: TPopupMenu;
    mi_Delete: TMenuItem;
    mi_Add: TMenuItem;
    mi_Edit: TMenuItem;
    mi_DeleteAll: TMenuItem;
    procedure lb_BookmarksDblClick(Sender: TObject);
    procedure tim_UpdateTimer(Sender: TObject);
    procedure mi_DeleteClick(Sender: TObject);
    procedure mi_AddClick(Sender: TObject);
    procedure mi_EditClick(Sender: TObject);
    procedure lb_BookmarksDrawItem(_Control: TWinControl; _Index: Integer; _Rect: TRect;
      _State: TOwnerDrawState);
    procedure mi_DeleteAllClick(Sender: TObject);
    procedure lb_BookmarksKeyPress(Sender: TObject; var Key: Char);
  private
    FBookmarks: TBookmarkList;
    function GetEditView(var _SourceEditor: IOTASourceEditor;
      var _EditView: IOTAEditView): Boolean;
    procedure Init;
    procedure SetBookmark(const _ModuleName: string; _LineNo: Integer; _BmIdx: Integer = -1);
    procedure DeleteBookmark(const _ModuleName: string; _BmIdx: Integer);
    procedure AddBookmarks(const _ModuleName: string; _EditView: IOTAEditView; _Bookmarks: TBookmarkList);
    function HasChanged(_NewBookmarks: TBookmarkList): Boolean;
    procedure SetListboxItemHeight;
    procedure GotoCurrent;
  protected
{$IFDEF GX_IDE_IS_HIDPI_AWARE}
    procedure ArrangeControls; override;
{$ENDIF}
  public
    constructor Create(_Owner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

uses
{{*}{$IFOPT D+}GX_DbugIntf,{$ENDIF}{*)}
  Windows,
  Graphics,
  u_dzStringUtils,
  u_dzVclUtils,
  GX_GExperts,
  GX_ConfigurationInfo,
  GX_OtaUtils,
  GX_GenericUtils,
  GX_NTAEditServiceNotifier,
  GX_EditBookmark;

type
  TBookmarksExpert = class(TGX_Expert)
  private
{$IFDEF GX_VER170_up}
    FNotifierIdx: Integer;
    procedure EditorViewActivated(_Sender: TObject; _EditView: IOTAEditView);
{$ENDIF}
  protected
    procedure SetActive(New: Boolean); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    function GetActionCaption: string; override;
    class function GetName: string; override;
    function HasConfigOptions: Boolean; override;
    procedure Execute(Sender: TObject); override;
  end;

var
  fmBookmarks: TfmGxBookmarksForm = nil;
  BookmarksExpert: TBookmarksExpert = nil;

{ TGxBookmarksExpert }

constructor TBookmarksExpert.Create;
begin
  inherited Create;

{$IFDEF GX_VER170_up}
  if Assigned(BorlandIDEServices) then begin
    FNotifierIdx := (BorlandIDEServices as IOTAEditorServices).AddNotifier(
      TGxNTAEditServiceNotifierActivate.Create(EditorViewActivated));
  end;
{$ENDIF}

  BookmarksExpert := Self;

//  SetFormIcon(fmBookmarks);
  IdeDockManager.RegisterDockableForm(TfmGxBookmarksForm, fmBookmarks, 'fmGxBookmarksForm');
end;

destructor TBookmarksExpert.Destroy;
begin
  BookmarksExpert := nil;
{$IFDEF GX_VER170_up}
  if FNotifierIdx <> 0 then
    (BorlandIDEServices as IOTAEditorServices).RemoveNotifier(FNotifierIdx);
{$ENDIF}

  FreeAndNil(fmBookmarks);

  inherited Destroy;
end;

procedure TBookmarksExpert.SetActive(New: Boolean);
begin
  if New <> Active then begin
    inherited SetActive(New);
    if New then
      IdeDockManager.RegisterDockableForm(TfmGxBookmarksForm, fmBookmarks, 'fmGxBookmarksForm')
    else begin
      IdeDockManager.UnRegisterDockableForm(fmBookmarks, 'fmGxBookmarksForm');
      FreeAndNil(fmBookmarks);
    end;
  end;
end;

procedure TBookmarksExpert.Execute(Sender: TObject);
begin
  if fmBookmarks = nil then begin
    fmBookmarks := TfmGxBookmarksForm.Create(nil);
    SetFormIcon(fmBookmarks);
  end;
  fmBookmarks.Init;
  IdeDockManager.ShowForm(fmBookmarks);
  EnsureFormVisible(fmBookmarks);
  IncCallCount;
end;

{$IFDEF GX_VER170_up}
procedure TBookmarksExpert.EditorViewActivated(_Sender: TObject; _EditView: IOTAEditView);
begin
  if Assigned(fmBookmarks) then
    fmBookmarks.Init;
end;
{$ENDIF}

function TBookmarksExpert.GetActionCaption: string;
resourcestring
  SMenuCaption = 'Editor Bookmarks';
begin
  Result := SMenuCaption;
end;

class function TBookmarksExpert.GetName: string;
begin
  Result := 'BookmarksExpert';
end;

function TBookmarksExpert.HasConfigOptions: Boolean;
begin
  Result := False;
end;

{ TfmGxBookmarksForm }

constructor TfmGxBookmarksForm.Create(_Owner: TComponent);
begin
  inherited;

  p_Bookmarks.BevelOuter := bvNone;

  TControl_SetMinConstraints(Self);

  SetListboxItemHeight;

  InitDpiScaler;

  if Assigned(BookmarksExpert) then
    BookmarksExpert.SetFormIcon(Self);
end;

destructor TfmGxBookmarksForm.Destroy;
begin
  fmBookmarks := nil;
  FreeAndNil(FBookmarks);
  inherited;
end;

function TfmGxBookmarksForm.GetEditView(var _SourceEditor: IOTASourceEditor;
  var _EditView: IOTAEditView): Boolean;
begin
  Result := False;
  if not GxOtaTryGetCurrentSourceEditor(_SourceEditor) then
    Exit; //==>
  if _SourceEditor.EditViewCount = 0 then
    Exit; //==>
  _EditView := _SourceEditor.GetEditView(0);
  Result := Assigned(_EditView);
end;

procedure TfmGxBookmarksForm.AddBookmarks(const _ModuleName: string; _EditView: IOTAEditView;
  _Bookmarks: TBookmarkList);
var
  i: Integer;
  BmPos: TOTACharPos;
begin
  for i := 0 to 19 do begin
    BmPos := _EditView.BookmarkPos[i];
    if BmPos.Line <> 0 then begin
      _Bookmarks.Add(i, BmPos.Line, BmPos.CharIndex, _ModuleName);
    end;
  end;
end;

function TfmGxBookmarksForm.HasChanged(_NewBookmarks: TBookmarkList): Boolean;
var
  i: Integer;
  bm1: TBookmark;
  bm2: Pointer;
begin
  Result := True;
  if not Assigned(FBookmarks) or (_NewBookmarks.Count <> FBookmarks.Count) then
    Exit;

  for i := 0 to _NewBookmarks.Count - 1 do begin
    bm1 := _NewBookmarks[i];
    bm2 := FBookmarks[i];
    if not bm1.IsSame(bm2) then
      Exit;
  end;

  Result := False;
end;

procedure TfmGxBookmarksForm.Init;
var
  SourceEditor: IOTASourceEditor;
  EditView: IOTAEditView;
  i: Integer;
  bm: TBookmark;
  NewBookmarks: TBookmarkList;
  s: string;
begin
  tim_Update.Enabled := False;
  try
    if not GetEditView(SourceEditor, EditView) then
      Exit;
    NewBookmarks := TBookmarkList.Create;
    try
      AddBookmarks(SourceEditor.Filename, EditView, NewBookmarks);

      if HasChanged(NewBookmarks) then begin
        FreeAndNil(FBookmarks);
        FBookmarks := NewBookmarks;
        NewBookmarks := nil;
        lb_Bookmarks.Items.Clear;
        for i := 0 to FBookmarks.Count - 1 do begin
          bm := FBookmarks[i];
          lb_Bookmarks.AddItem(Format('%d [%d] %s', [bm.Number, bm.Line, ExtractFileName(bm.Module)]), bm);
          if bm.Line > 1 then
            s := ' ' + GxOtaGetEditorLineAsString(EditView, bm.Line - 1)
          else
            s := ' ' + CRLF;
          s := s + '> ' + GxOtaGetEditorLineAsString(EditView, bm.Line);
          s := s + ' ' + GxOtaGetEditorLineAsString(EditView, bm.Line + 1);
          bm.Text := s;
        end;
      end;
    finally
      FreeAndNil(NewBookmarks);
    end;
  finally
    tim_Update.Enabled := True;
  end;
end;

procedure TfmGxBookmarksForm.tim_UpdateTimer(Sender: TObject);
begin
  Init;
end;

procedure TfmGxBookmarksForm.lb_BookmarksDblClick(Sender: TObject);
begin
  GotoCurrent;
end;

procedure TfmGxBookmarksForm.GotoCurrent;
resourcestring
  SCouldNotOpenFile = 'Could not open file %s';
var
  bm: TBookmark;
  fn: string;
  Module: IOTAModule;
  SourceEditor: IOTASourceEditor;
  EditView: IOTAEditView;
begin
  if not TListBox_GetSelectedObject(lb_Bookmarks, Pointer(bm)) then
    Exit;
  fn := bm.Module;

  if not GxOtaMakeSourceVisible(fn) then
    raise Exception.CreateFmt(SCouldNotOpenFile, [fn]);

  Module := GxOtaGetModule(fn);
  if not Assigned(Module) then
    Exit;

  SourceEditor := GxOtaGetSourceEditorFromModule(Module, fn);
  if not Assigned(SourceEditor) then
    Exit;
  SourceEditor.Show;

  if not GxOtaTryGetTopMostEditView(SourceEditor, EditView) then
    Exit;

  EditView.BookmarkGoto(bm.Number);
  EditView.MoveViewToCursor;
  GxOtaFocusCurrentIDEEditControl;
  EditView.Paint;
end;

function TryGetEditView(const _fn: string; out _EditView: IOTAEditView): Boolean;
var
  SourceEditor: IOTASourceEditor;
begin
  SourceEditor := GxOtaGetSourceEditor(_fn);
  Result := Assigned(SourceEditor) and (SourceEditor.EditViewCount > 0);
  if Result then
    _EditView := SourceEditor.EditViews[0];
end;

procedure TfmGxBookmarksForm.DeleteBookmark(const _ModuleName: string; _BmIdx: Integer);
var
  EditView: IOTAEditView;
  SaveCursorPos: TOTAEditPos;
  BmEditPos: TOTAEditPos;
begin
  if not TryGetEditView(_ModuleName, EditView) then
    Exit;

  if EditView.BookmarkPos[_BmIdx].Line <> 0 then begin
    SaveCursorPos := EditView.GetCursorPos;
    try
      BmEditPos.Line := EditView.BookmarkPos[_BmIdx].Line;
      BmEditPos.Col := EditView.BookmarkPos[_BmIdx].CharIndex;
      EditView.SetCursorPos(BmEditPos);
      EditView.BookmarkToggle(_BmIdx);
    finally
      EditView.SetCursorPos(SaveCursorPos);
      EditView.Paint;
    end;
  end;
end;

procedure TfmGxBookmarksForm.SetBookmark(const _ModuleName: string; _LineNo: Integer; _BmIdx: Integer = -1);
var
  EditView: IOTAEditView;
  i: Integer;
  SaveCursorPos: TOTAEditPos;
  BmEditPos: TOTAEditPos;
begin
  if not TryGetEditView(_ModuleName, EditView) then
    Exit;

  if _BmIdx < 0 then begin
    // no bookmark index was given, find the first one that's free
    for i := 0 to 19 do begin
      if EditView.BookmarkPos[i].Line = 0 then begin
        _BmIdx := i;
        Break;
      end;
    end;
    if _BmIdx < 0 then
      Exit; // no free bookmark index found
  end;

  SaveCursorPos := EditView.GetCursorPos;
  try
    BmEditPos.Line := _LineNo;
    BmEditPos.Col := 1;
    EditView.SetCursorPos(BmEditPos);
    EditView.BookmarkRecord(_BmIdx);
  finally
    EditView.SetCursorPos(SaveCursorPos);
  end;
end;

procedure TfmGxBookmarksForm.mi_AddClick(Sender: TObject);
var
  SourceEditor: IOTASourceEditor;
  EditView: IOTAEditView;
  ModuleName: string;
  LineNo: Integer;
  BmIndex: Integer;
begin
  if not GetEditView(SourceEditor, EditView) then
    Exit;
  try
    ModuleName := SourceEditor.Filename;
    LineNo := EditView.CursorPos.Line;
    if not TfmEditBookmarks.Execute(Self, ModuleName, LineNo, BmIndex) then
      Exit;
    SetBookmark(ModuleName, LineNo, BmIndex);
  finally
    Init;
  end;
end;

procedure TfmGxBookmarksForm.mi_DeleteClick(Sender: TObject);
var
  bm: TBookmark;
begin
  if not TListBox_GetSelectedObject(lb_Bookmarks, Pointer(bm)) then
    Exit;
  DeleteBookmark(bm.Module, bm.Number);
end;

procedure TfmGxBookmarksForm.mi_DeleteAllClick(Sender: TObject);
var
  i: Integer;
  bm: TBookmark;
begin
  for i := lb_Bookmarks.Items.Count - 1 downto 0 do begin
    bm := TBookmark(lb_Bookmarks.Items.Objects[i]);
    DeleteBookmark(bm.Module, bm.Number);
  end;
end;

procedure TfmGxBookmarksForm.mi_EditClick(Sender: TObject);
var
  bm: TBookmark;
  ModuleName: string;
  LineNo: Integer;
begin
  if not TListBox_GetSelectedObject(lb_Bookmarks, Pointer(bm)) then
    Exit;

  try
    ModuleName := bm.Module;
    LineNo := bm.Line;
    if not TfmEditBookmarks.Execute(Self, ModuleName, LineNo) then
      Exit;

    SetBookmark(ModuleName, LineNo, bm.Number);
  finally
    Init;
  end;
end;

procedure TfmGxBookmarksForm.lb_BookmarksDrawItem(_Control: TWinControl; _Index: Integer; _Rect: TRect;
  _State: TOwnerDrawState);
resourcestring
  SLine = 'Line %d';
const
  TopOffset = 1;
var
  ListBox: TListBox absolute _Control;
  LbCanvas: TCanvas;
  bm: TBookmark;
  LineHeight: Integer;

  procedure PaintFileHeader(_Rect: TRect);
  var
    TextTop: Integer;
    TopColor: TColor;
    BottomColor: TColor;
    i: Integer;
    FileNameWidth: Integer;
    FileString: string;
    LineText: string;
  begin
    TextTop := _Rect.Top + TopOffset;
    TopColor := clBtnHighlight;
    BottomColor := clBtnShadow;

    LbCanvas.Brush.Color := clBtnFace;
    LbCanvas.Font.Color := clBtnText;
    LbCanvas.FillRect(_Rect);

    _Rect.Right := _Rect.Right + 2;
    if odSelected in _State then
      Frame3D(LbCanvas, _Rect, BottomColor, TopColor, 1)
    else
      Frame3D(LbCanvas, _Rect, TopColor, BottomColor, 1);

    i := LbCanvas.TextWidth('00');
    FileString := ExtractFileName(bm.Module);
    LbCanvas.TextOut(_Rect.Left + i + FScaler.Calc(8), TextTop, FileString);

    LbCanvas.TextOut(_Rect.Left + FScaler.Calc(3), TextTop, IntToStr(bm.Number));

    LineText := Format(SLine, [bm.Line]);

    FileNameWidth := LbCanvas.TextWidth(LineText) + FScaler.Calc(10);
    if (LbCanvas.TextWidth(FileString) + i + FScaler.Calc(10)) <= _Rect.Right - FileNameWidth then
      LbCanvas.TextOut(ListBox.ClientWidth - FileNameWidth, TextTop, LineText);
  end;

  procedure PaintLines(_Rect: TRect);
  var
    TextTop: Integer;
    sl: TStringList;
    i: Integer;
    LineText: string;
    s: string;
    BGNormal: TColor;
    BGBookmark: TColor;
  begin
    if [odSelected, odFocused] * _State = [odSelected, odFocused] then begin
      BGNormal := clHighLight;
      LbCanvas.Font.Color := clHighLightText;
      BGBookmark := BGNormal;
    end else begin
      BGNormal := clWindow;
      LbCanvas.Font.Color := clWindowText;
      BGBookmark := RGB(250, 255, 230);
    end;
    LbCanvas.Brush.Color := BGNormal;
    LbCanvas.FillRect(_Rect);

    TextTop := _Rect.Top + TopOffset;
    sl := TStringList.Create;
    try
      sl.Text := bm.Text;
      for i := 0 to sl.Count - 1 do begin
        s := sl[i];
        LineText := Copy(s, 2);
        s := Copy(s, 1, 1);
        if s = '>' then begin
          LbCanvas.Brush.Color := BGBookmark;
          LbCanvas.FillRect(Rect(_Rect.Left, TextTop, _Rect.Right, TextTop + LineHeight));
        end else
          LbCanvas.Brush.Color := BGNormal;
        LbCanvas.TextOut(_Rect.Left, TextTop, LineText);
        Inc(TextTop, LineHeight);
      end;
    finally
      sl.Free;
    end;
  end;

begin
  bm := TBookmark(ListBox.Items.Objects[_Index]);
  if Assigned(bm) then begin
    LbCanvas := ListBox.Canvas;
    LineHeight := LbCanvas.TextHeight('Mg');
    PaintFileHeader(Rect(_Rect.Left, _Rect.Top, _Rect.Right, _Rect.Top + LineHeight + 2));
    PaintLines(Rect(_Rect.Left, _Rect.Top + LineHeight + 2, _Rect.Right, _Rect.Bottom));
  end;
end;

procedure TfmGxBookmarksForm.SetListboxItemHeight;
var
  cnv: TCanvas;
begin
  cnv := lb_Bookmarks.Canvas;
  cnv.Font := lb_Bookmarks.Font;
  lb_Bookmarks.ItemHeight := (cnv.TextHeight('Mg') + 2) * 4;
end;

procedure TfmGxBookmarksForm.lb_BookmarksKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    GotoCurrent();
end;

{$IFDEF GX_IDE_IS_HIDPI_AWARE}
procedure TfmGxBookmarksForm.ArrangeControls;
begin
  inherited;
  SetListboxItemHeight;
end;
{$ENDIF}

initialization
  RegisterGX_Expert(TBookmarksExpert);
end.
