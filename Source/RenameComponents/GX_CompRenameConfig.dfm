object fmCompRenameConfig: TfmCompRenameConfig
  Left = 336
  Top = 315
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = 'Rename Components Configuration'
  ClientHeight = 368
  ClientWidth = 409
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 14
  object pnlFooter: TPanel
    Left = 0
    Top = 292
    Width = 409
    Height = 76
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      409
      76)
    object pnlButtonsRight: TPanel
      Left = 136
      Top = 0
      Width = 273
      Height = 76
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 2
      object btnOK: TButton
        Left = 32
        Top = 48
        Width = 75
        Height = 25
        Action = acOK
        Caption = '&OK'
        Default = True
        TabOrder = 0
      end
      object btnClose: TButton
        Left = 112
        Top = 48
        Width = 75
        Height = 25
        Action = acCancel
        Cancel = True
        TabOrder = 1
      end
      object btnHelp: TButton
        Left = 192
        Top = 48
        Width = 75
        Height = 25
        Cancel = True
        Caption = '&Help'
        TabOrder = 2
        OnClick = btnHelpClick
      end
    end
    object chkAutoAdd: TCheckBox
      Left = 8
      Top = 21
      Width = 393
      Height = 17
      Anchors = [akLeft, akRight, akBottom]
      Caption = 'Auto-add rules for new components'
      TabOrder = 1
    end
    object chkShowDialog: TCheckBox
      Left = 8
      Top = 2
      Width = 393
      Height = 17
      Anchors = [akLeft, akRight, akBottom]
      Caption = 'Show rename dialog for new components'
      TabOrder = 0
    end
    object b_Tools: TButton
      Left = 8
      Top = 48
      Width = 75
      Height = 25
      Caption = 'Tools >'
      TabOrder = 3
      OnClick = b_ToolsClick
    end
  end
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 409
    Height = 292
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 6
    TabOrder = 0
    object grpNames: TGroupBox
      Left = 6
      Top = 6
      Width = 397
      Height = 280
      Align = alClient
      Caption = 'Rename &Rules'
      TabOrder = 0
      object pnlRules: TPanel
        Left = 2
        Top = 16
        Width = 262
        Height = 262
        Align = alClient
        TabOrder = 0
        object pnlIncSearch: TPanel
          Left = 1
          Top = 1
          Width = 260
          Height = 24
          Align = alTop
          TabOrder = 0
          DesignSize = (
            260
            24)
          object l_Find: TLabel
            Left = 8
            Top = 5
            Width = 30
            Height = 14
            Caption = '&Find: '
            FocusControl = edtFind
          end
          object edtFind: TEdit
            Left = 40
            Top = 1
            Width = 198
            Height = 22
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 0
            OnChange = edtFindChange
            OnKeyDown = edtFindKeyDown
          end
          object btnClear: TButton
            Left = 233
            Top = 1
            Width = 21
            Height = 21
            Anchors = [akTop, akRight]
            Caption = 'X'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBtnText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            TabOrder = 1
            OnClick = btnClearClick
          end
        end
        object pnlNames: TPanel
          Left = 1
          Top = 25
          Width = 260
          Height = 236
          Align = alClient
          TabOrder = 1
          object pc_Names: TPageControl
            Left = 1
            Top = 1
            Width = 258
            Height = 234
            ActivePage = ts_NamesVcl
            Align = alClient
            TabOrder = 0
            OnChange = pc_NamesChange
            object ts_NamesVcl: TTabSheet
              Caption = 'VCL'
            end
            object ts_NamesFmx: TTabSheet
              Caption = 'FMX'
            end
          end
        end
      end
      object pnlRight: TPanel
        Left = 264
        Top = 16
        Width = 131
        Height = 262
        Align = alRight
        TabOrder = 1
        DesignSize = (
          131
          262)
        object btnAdd: TButton
          Left = 8
          Top = 8
          Width = 117
          Height = 26
          Action = acAdd
          TabOrder = 0
        end
        object btnDelete: TButton
          Left = 8
          Top = 40
          Width = 117
          Height = 26
          Action = acDelete
          TabOrder = 1
        end
        object btnOtherProperties: TButton
          Left = 8
          Top = 80
          Width = 117
          Height = 26
          Action = acOtherProperties
          TabOrder = 2
        end
        object lbxOtherProps: TListBox
          Left = 8
          Top = 112
          Width = 121
          Height = 145
          Anchors = [akLeft, akTop, akBottom]
          ItemHeight = 14
          TabOrder = 3
        end
      end
    end
  end
  object TheActionList: TActionList
    Images = dmSharedImages.Images
    OnUpdate = TheActionListUpdate
    Left = 152
    Top = 112
    object acAdd: TAction
      Caption = '&Add'
      ImageIndex = 12
      ShortCut = 45
      OnExecute = acAddExecute
    end
    object acDelete: TAction
      Caption = '&Delete'
      ImageIndex = 13
      ShortCut = 16430
      OnExecute = acDeleteExecute
    end
    object acOtherProperties: TAction
      Caption = 'Other &Properties...'
      OnExecute = acOtherPropertiesExecute
    end
    object acFind: TAction
      Caption = '&Find...'
      ImageIndex = 14
      ShortCut = 16454
      OnExecute = acFindExecute
    end
    object acCancel: TAction
      Caption = 'Cancel'
      OnExecute = acCancelExecute
    end
    object acOK: TAction
      Caption = 'OK'
      OnExecute = acOKExecute
    end
    object acSortByClass: TAction
      Caption = 'By Class'
      OnExecute = acSortByClassExecute
    end
    object acSortByRule: TAction
      Caption = 'By Rename Rule'
      OnExecute = acSortByRuleExecute
    end
  end
  object pmGrid: TPopupMenu
    Images = dmSharedImages.Images
    Left = 108
    Top = 112
    object mnuAdd: TMenuItem
      Action = acAdd
    end
    object mnuDelete: TMenuItem
      Action = acDelete
    end
    object mnuOtherProperties: TMenuItem
      Action = acOtherProperties
    end
    object mnuSep1: TMenuItem
      Caption = '-'
    end
    object mnuFind: TMenuItem
      Action = acFind
    end
    object mnuSep2: TMenuItem
      Caption = '-'
    end
    object mnuSort: TMenuItem
      Caption = 'Sort'
      object mnuSortByClass: TMenuItem
        Action = acSortByClass
      end
      object mnuSortByRule: TMenuItem
        Action = acSortByRule
      end
    end
  end
  object FindDialog: TFindDialog
    Options = [frDown, frDisableMatchCase, frDisableUpDown, frDisableWholeWord]
    OnFind = FindDialogFind
    Left = 64
    Top = 112
  end
  object pm_Extra: TPopupMenu
    Left = 120
    Top = 232
    object mi_ResetTo: TMenuItem
      Caption = 'Reset to'
      object mi_ResetToDefault: TMenuItem
        Caption = '<default>'
        OnClick = mi_ResetToDefaultClick
      end
    end
    object mi_Import: TMenuItem
      Caption = 'Import ...'
      OnClick = mi_ImportClick
    end
    object mi_Export: TMenuItem
      Caption = 'Export ...'
      OnClick = mi_ExportClick
    end
  end
end
