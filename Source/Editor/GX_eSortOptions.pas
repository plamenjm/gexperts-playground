unit GX_eSortOptions;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  Buttons,
  GX_BaseForm,
  GX_StringList;

type
  TfrmSortOptions = class(TfmBaseForm)
    grpSortOrder: TGroupBox;
    lbxGroupOrder: TListBox;
    btnUp: TBitBtn;
    btnDown: TBitBtn;
    btnOK: TButton;
    btnCancel: TButton;
    procedure btnUpClick(Sender: TObject);
    procedure btnDownClick(Sender: TObject);
    procedure lbxGroupOrderClick(Sender: TObject);
    procedure lbxGroupOrderKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    procedure GetData(_CustomPrefixOrder: TGXUnicodeStringList);
    procedure SetData(_CustomPrefixOrder: TGXUnicodeStringList);
    procedure EnableButtons;
  public
    class function Execute(_Owner: TWinControl; _CustomPrefixOrder: TGXUnicodeStringList): Boolean;
    constructor Create(_Owner: TComponent); override;
  end;

implementation

{$R *.dfm}

uses
  u_dzVclUtils,
  GX_GenericUtils;

{ TfrmSortOptions }

class function TfrmSortOptions.Execute(_Owner: TWinControl; _CustomPrefixOrder: TGXUnicodeStringList): Boolean;
var
  frm: TfrmSortOptions;
begin
  frm := TfrmSortOptions.Create(_Owner);
  try
    frm.SetData(_CustomPrefixOrder);
    Result := (frm.ShowModal = mrOk);
    if Result then
      frm.GetData(_CustomPrefixOrder);
  finally
    FreeAndNil(frm);
  end;
end;

procedure TfrmSortOptions.btnDownClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := lbxGroupOrder.ItemIndex;
  if Idx < lbxGroupOrder.Items.Count - 1 then begin
    lbxGroupOrder.Items.Exchange(Idx, Idx + 1);
    EnableButtons;
  end;
end;

procedure TfrmSortOptions.btnUpClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := lbxGroupOrder.ItemIndex;
  if Idx > 0 then begin
    lbxGroupOrder.Items.Exchange(Idx, Idx - 1);
    EnableButtons;
  end;
end;

constructor TfrmSortOptions.Create(_Owner: TComponent);
var
  LSpacer : Integer;
begin
  inherited;

  TControl_SetMinConstraints(Self);
  LSpacer := grpSortOrder.Left;
  Self.ClientWidth := grpSortOrder.Width +  (2 * LSpacer);
  Self.ClientHeight := btnCancel.Top + btnCancel.Height + LSpacer;

  InitDpiScaler;
end;

procedure TfrmSortOptions.EnableButtons;
begin
  btnUp.Enabled := lbxGroupOrder.ItemIndex > 0;
  btnDown.Enabled := lbxGroupOrder.ItemIndex < lbxGroupOrder.Items.Count - 1;
end;

procedure TfrmSortOptions.GetData(_CustomPrefixOrder: TGXUnicodeStringList);
begin
  _CustomPrefixOrder.Assign(lbxGroupOrder.Items);
end;

procedure TfrmSortOptions.SetData(_CustomPrefixOrder: TGXUnicodeStringList);
begin
  lbxGroupOrder.Items.Assign(_CustomPrefixOrder);
  lbxGroupOrder.ItemIndex := 0;
  EnableButtons;
end;

procedure TfrmSortOptions.lbxGroupOrderClick(Sender: TObject);
begin
  EnableButtons;
end;

procedure TfrmSortOptions.lbxGroupOrderKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
  if Shift = [ssCtrl] then begin
    case Key of
      VK_UP   : begin btnUpClick(nil); Key := 0; end;
      VK_DOWN : begin btnDownClick(nil); Key := 0; end;
    end;
  end;
end;

end.

