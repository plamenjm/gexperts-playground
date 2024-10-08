object fmMacroSelect: TfmMacroSelect
  Left = 366
  Top = 321
  ActiveControl = edtFilter
  BorderStyle = bsSizeToolWin
  Caption = 'Select Macro Template'
  ClientHeight = 328
  ClientWidth = 423
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 14
  object pnlMain: TPanel
    Left = 0
    Top = 26
    Width = 423
    Height = 303
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 6
    TabOrder = 1
    object lvMacros: TListView
      Left = 6
      Top = 6
      Width = 411
      Height = 291
      Align = alClient
      Columns = <
        item
          Caption = 'Name'
          MinWidth = 50
          Width = 100
        end
        item
          Caption = 'Description'
          MinWidth = 100
          Width = 250
        end>
      ColumnClick = False
      HideSelection = False
      ReadOnly = True
      RowSelect = True
      SortType = stText
      TabOrder = 0
      ViewStyle = vsReport
      OnDblClick = lstMacrosDblClick
    end
  end
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 423
    Height = 26
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      423
      26)
    object lblFilter: TLabel
      Left = 8
      Top = 7
      Width = 26
      Height = 14
      Caption = '&Filter'
      FocusControl = edtFilter
    end
    object edtFilter: TEdit
      Left = 48
      Top = 4
      Width = 240
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      OnChange = edtFilterChange
      OnKeyDown = edtFilterKeyDown
    end
    object pnlButtonsRight: TPanel
      Left = 298
      Top = 0
      Width = 125
      Height = 26
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 2
      object btnConfiguration: TButton
        Left = 15
        Top = 1
        Width = 103
        Height = 25
        Caption = '&Configure...'
        TabOrder = 0
        OnClick = btnConfigurationClick
      end
    end
    object btnClear: TButton
      Left = 288
      Top = 3
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
end
