unit GX_IdeFormEnhancer;

interface

{$I GX_CondDefine.inc}

uses
  SysUtils,
  Classes,
  Controls,
  Forms;

type
  TIDEFormEnhancements = class
  public
    class function GetEnabled: Boolean;// static;
    class procedure SetEnabled(const Value: Boolean); //static;
    class function GetAllowResize: Boolean; //static;
    class procedure SetAllowResize(const Value: Boolean); //static;
    class function GetRememberPosition: Boolean; //static;
    class procedure SetRememberPosition(const Value: Boolean); //static;
  end;

implementation

uses Windows, Dialogs, ExtCtrls,
  ActnList, Menus, ComCtrls,
  GX_GenericUtils, GX_IdeFormChangeManager, GX_IdeManagedFormHandler,
  GX_IdeManagedForm;

type
  TIDEFormEnhancer = class(TObject)
  private
    FAllowResize: boolean;
    FRememberPosition: Boolean;
    FFormCallbackHandle: TFormChangeHandle;
    ///<summary>
    /// frm can be nil </summary>
    procedure HandleFormChanged(_Sender: TObject; _Form: TCustomForm);
  protected
    constructor Create;
    destructor Destroy; override;
    property AllowResize: Boolean read FAllowResize write FAllowResize;
    property RememberPosition: Boolean read FRememberPosition write FRememberPosition;
  end;

//const
//  FormsToChange: array[0..13] of TFormChanges = (
//    (
//      FormClassNames: 'TSrchDialog';
//      FormEnhancer: TManagedFormSrchDialog;
//      MakeResizable: True;
//      RememberSize: True;
//      RememberWidth: True;
//      RememberPosition: False;
//      RememberSplitterPosition: False;
//      ResizePictureDialogs: False;
//      ComboDropDownCount: 15;
//    ),
//    (
//      FormClassNames: 'TRplcDialog';
//      FormEnhancer: TManagedFormRplcDialog;
//      MakeResizable: True;
//      RememberSize: True;
//      RememberWidth: True;
//      RememberPosition: False;
//      RememberSplitterPosition: False;
//      ResizePictureDialogs: False;
//      ComboDropDownCount: 15;
//    ),
//    (
//      FormClassNames: 'TDefaultEnvironmentDialog';
//      FormEnhancer: TManagedFormDefaultEnvironmentDialog;
//      MakeResizable: True;
//      RememberSize: True;
//      RememberWidth: False;
//      RememberPosition: True;
//      RememberSplitterPosition: True;
//      ResizePictureDialogs: False;
//      ComboDropDownCount: 15;
//    ),
//    (
//      FormClassNames: 'TImageListEditor';
//      FormEnhancer: TManagedFormImageListEditor;
//      MakeResizable: True;
//      RememberSize: True;
//      RememberWidth: False;
//      RememberPosition: True;
//      RememberSplitterPosition: False;
//      ResizePictureDialogs: True;
//      ComboDropDownCount: 15;
//    ),
//    (
//      FormClassNames: 'TPictureEditorDlg';
//      FormEnhancer: TManagedFormPictureEditDlg;
//      MakeResizable: True;
//      RememberSize: True;
//      RememberWidth: False;
//      RememberPosition: True;
//      RememberSplitterPosition: False;
//      ResizePictureDialogs: True;
//      ComboDropDownCount: 15;
//    ),
//    (
//      FormClassNames: 'TLoadProcessDialog;TDotNetOptionForm;TPasEditorPropertyDialog;'
//        + 'TCppProjOptsDlg;TReopenMenuPropertiesDialog;'
//        + 'TActionListDesigner;TFieldsEditor;TDBGridColumnsEditor;TDriverSettingsForm';
//      FormEnhancer: TManagedForm;
//      MakeResizable: True;
//      RememberSize: True;
//      RememberWidth: False;
//      RememberPosition: True;
//      RememberSplitterPosition: True;
//      ResizePictureDialogs: False;
//      ComboDropDownCount: 15;
//    ),
//    (
//      FormClassNames: 'TProjectOptionsDialog';
//      FormEnhancer: TManagedFormProjectOptionsDialog;
//      MakeResizable: True;
//      RememberSize: True;
//      RememberWidth: False;
//      RememberPosition: True;
//      RememberSplitterPosition: True;
//      ResizePictureDialogs: False;
//      ComboDropDownCount: 15;
//    ),
//    (
//      FormClassNames: 'TDelphiProjectOptionsDialog';
//      FormEnhancer: TManagedForm;
//      MakeResizable: True;
//      RememberSize: True;
//      RememberWidth: False;
//      RememberPosition: True;
//      RememberSplitterPosition: True;
//      ResizePictureDialogs: False;
//      ComboDropDownCount: 0; // changing the dropdown count seems to result in intermittent invalid pointer operations in Delphi 10.1
//    ),
//    (
//      FormClassNames: 'TPasEnvironmentDialog';
//      FormEnhancer: TManagedFormPasEnvironmentDialog;
//      MakeResizable: True;
//      RememberSize: True;
//      RememberWidth: False;
//      RememberPosition: True;
//      RememberSplitterPosition: True;
//      ResizePictureDialogs: False;
//      ComboDropDownCount: 15;
//    ),
//    (
//      FormClassNames: 'TConnEditForm';
//      FormEnhancer: TManagedFormConnEditForm;
//      MakeResizable: True;
//      RememberSize: True;
//      RememberWidth: False;
//      RememberPosition: True;
//      RememberSplitterPosition: True;
//      ResizePictureDialogs: False;
//      ComboDropDownCount: 15;
//    ),
//    (
//      FormClassNames: 'TPakComponentsDlg';
//      FormEnhancer: TManagedFormPakComponentsDlg;
//      MakeResizable: True;
//      RememberSize: True;
//      RememberWidth: False;
//      RememberPosition: True;
//      RememberSplitterPosition: True;
//      ResizePictureDialogs: False;
//      ComboDropDownCount: 15;
//    ),
//    (
//      FormClassNames: 'TOrderedListEditDlg;TInheritedListEditDlg;TBufferListFrm;TMenuBuilder';
//      FormEnhancer: TManagedForm;
//      MakeResizable: False;
//      RememberSize: True;
//      RememberWidth: False;
//      RememberPosition: True;
//      RememberSplitterPosition: False;
//      ResizePictureDialogs: False;
//      ComboDropDownCount: 15;
//    ),
//    (
//      FormClassNames: 'TGalleryBrowseDlg;TProjectResourcesDlg';
//      FormEnhancer: TManagedFormFixFormPositioningOnly;
//      MakeResizable: False;
//      RememberSize: false;
//      RememberWidth: false;
//      RememberPosition: false;
//      RememberSplitterPosition: False;
//      ResizePictureDialogs: False;
//      ComboDropDownCount: 0;
//    ),
//    (
//      FormClassNames: 'TAboutBox';
//      FormEnhancer: TManagedFormAboutBox;
//      MakeResizable: False;
//      RememberSize: false;
//      RememberWidth: false;
//      RememberPosition: false;
//      RememberSplitterPosition: False;
//      ResizePictureDialogs: False;
//      ComboDropDownCount: 0;
//    )
//  );

var
  PrivateIdeFormEnhancer: TIDEFormEnhancer = nil;

{ TIDEFormEnhancer }

constructor TIDEFormEnhancer.Create;
begin
  inherited;
  FFormCallbackHandle := TIDEFormChangeManager.RegisterFormChangeCallback(HandleFormChanged)
end;

destructor TIDEFormEnhancer.Destroy;
begin
  TIDEFormChangeManager.UnregisterFormChangeCallback(FFormCallbackHandle);
  inherited;
end;

procedure TIDEFormEnhancer.HandleFormChanged(_Sender: TObject; _Form: TCustomForm);
var
  i: Integer;
//   Changes: TFormChanges;
//  Enhancer: TManagedForm;
  Handlers: TList;
  ClsName: string;
  Handler: TManagedFormHandler;
begin
  if not Assigned(_Form) then
    Exit; //==>

  if csDesigning in _Form.ComponentState then
    Exit; //==>

  ClsName := _Form.ClassName;
  if StringInArray(ClsName, ['TAppBuilder', 'TMessageForm', 'TPropertyInspector', 'TObjectTreeView', 'TEditWindow']) then
    Exit;

  Handlers := TList.Create;
  try
    TManagedFormHandlerFactory.GetHandlers(_Form, Handlers);
    for i := 0 to Handlers.Count - 1 do begin
      Handler := TManagedFormHandler(Handlers[i]);
      Handler.SetChangeEnabled(sfcStorePosition, RememberPosition);
      Handler.SetChangeEnabled(sfcStoreSize, AllowResize);
      Handler.Execute(_Form);
    end;
  finally
    FreeAndNil(Handlers);
  end;

  Exit;

  (*
  Unreachable code
  begin
    Changes.MakeResizable := Changes.MakeResizable and AllowResize;
    Changes.RememberSize := Changes.RememberSize and AllowResize;
    Changes.RememberPosition := Changes.RememberPosition and RememberPosition;
    Changes.RememberSplitterPosition := Changes.RememberSplitterPosition;
    Changes.RememberWidth := Changes.RememberWidth and AllowResize;
    Changes.ResizePictureDialogs := Changes.ResizePictureDialogs;
    Changes.ComboDropDownCount := Changes.ComboDropDownCount;
    Enhancer := Changes.FormEnhancer.Create(_Form);
    Enhancer.Init(Changes);
  end;
  *)
end;

{ TIDEFormEnhancements }

class function TIDEFormEnhancements.GetAllowResize: Boolean;
begin
  Result := Assigned(PrivateIdeFormEnhancer) and PrivateIdeFormEnhancer.AllowResize;
end;

class function TIDEFormEnhancements.GetEnabled: Boolean;
begin
  Result := Assigned(PrivateIdeFormEnhancer);
end;

class function TIDEFormEnhancements.GetRememberPosition: Boolean;
begin
  Result := Assigned(PrivateIdeFormEnhancer) and PrivateIdeFormEnhancer.RememberPosition;
end;

class procedure TIDEFormEnhancements.SetAllowResize(const Value: Boolean);
begin
  if Assigned(PrivateIdeFormEnhancer) then
    PrivateIdeFormEnhancer.AllowResize := Value;
end;

class procedure TIDEFormEnhancements.SetEnabled(const Value: Boolean);
begin
  if Value and (not Assigned(PrivateIdeFormEnhancer)) then
    PrivateIdeFormEnhancer := TIDEFormEnhancer.Create
  else if not Value then
    FreeAndNil(PrivateIdeFormEnhancer);
end;

class procedure TIDEFormEnhancements.SetRememberPosition(const Value: Boolean);
begin
  if Assigned(PrivateIdeFormEnhancer) then
    PrivateIdeFormEnhancer.RememberPosition := Value;
end;

initialization
finalization
  TIDEFormEnhancements.SetEnabled(False);

end.

