object fmExpertManager: TfmExpertManager
  Left = 277
  Top = 202
  ActiveControl = lvExperts
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = 'Expert Manager'
  ClientHeight = 263
  ClientWidth = 578
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 14
  object StatusBar: TStatusBar
    Left = 0
    Top = 244
    Width = 578
    Height = 19
    Panels = <>
    ParentFont = True
    SimplePanel = False
    UseSystemFont = False
  end
  object lvExperts: TListView
    Left = 0
    Top = 24
    Width = 578
    Height = 220
    Align = alClient
    Columns = <
      item
        Caption = 'Expert'
        Width = -1
        WidthType = (
          -1)
      end
      item
        Caption = 'DLL File Name'
        Width = -2
        WidthType = (
          -2)
      end>
    ColumnClick = False
    LargeImages = ilStateImages
    ReadOnly = True
    RowSelect = True
    PopupMenu = pmItems
    StateImages = ilStateImages
    TabOrder = 1
    ViewStyle = vsReport
  end
  object ToolBar: TToolBar
    Left = 0
    Top = 0
    Width = 578
    Height = 24
    AutoSize = True
    DisabledImages = dmSharedImages.DisabledImages
    Flat = True
    Images = dmSharedImages.Images
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    Wrapable = False
    object tbnSave: TToolButton
      Left = 0
      Top = 0
      Action = actFileSave
    end
    object tbnRevert: TToolButton
      Left = 23
      Top = 0
      Action = actFileRevert
    end
    object tbnSep1: TToolButton
      Left = 46
      Top = 0
      Width = 8
      Style = tbsSeparator
    end
    object tbnEnable: TToolButton
      Left = 54
      Top = 0
      Action = actExpertEnable
    end
    object tbnDisable: TToolButton
      Left = 77
      Top = 0
      Action = actExpertDisable
    end
    object tbnSep2: TToolButton
      Left = 100
      Top = 0
      Width = 8
      Style = tbsSeparator
    end
    object tbnAdd: TToolButton
      Left = 108
      Top = 0
      Action = actExpertAdd
    end
    object tbnRemove: TToolButton
      Left = 131
      Top = 0
      Action = actExpertRemove
    end
    object tbnSep3: TToolButton
      Left = 154
      Top = 0
      Width = 8
      Style = tbsSeparator
    end
    object tb_MoveUp: TToolButton
      Left = 162
      Top = 0
      Action = actExpertMoveUp
    end
    object tb_MoveDown: TToolButton
      Left = 185
      Top = 0
      Action = actExpertMoveDown
    end
    object tbnSep4: TToolButton
      Left = 208
      Top = 0
      Width = 8
      Style = tbsSeparator
    end
    object tbnHelp: TToolButton
      Left = 216
      Top = 0
      Action = actHelpHelp
    end
  end
  object pmItems: TPopupMenu
    Images = dmSharedImages.Images
    Left = 32
    Top = 96
    object mitEnableExpert: TMenuItem
      Action = actExpertEnable
    end
    object mitDisableExpert: TMenuItem
      Action = actExpertDisable
    end
    object mitPopSep1: TMenuItem
      Caption = '-'
    end
    object mitRemoveExpert: TMenuItem
      Action = actExpertRemove
    end
    object mi_PopSep2: TMenuItem
      Caption = '-'
    end
    object mi_MoveUpExpert: TMenuItem
      Action = actExpertMoveUp
    end
    object mi_MoveDownExpert: TMenuItem
      Action = actExpertMoveDown
    end
  end
  object Actions: TActionList
    Images = dmSharedImages.Images
    OnUpdate = ActionsUpdate
    Left = 160
    Top = 48
    object actExpertEnable: TAction
      Category = 'Experts'
      Caption = '&Enable'
      Hint = 'Enable expert'
      ImageIndex = 43
      ShortCut = 16453
      OnExecute = actExpertEnableExecute
      OnUpdate = actExpertEnableUpdate
    end
    object actExpertDisable: TAction
      Category = 'Experts'
      Caption = '&Disable'
      Hint = 'Disable expert'
      ImageIndex = 32
      ShortCut = 16452
      OnExecute = actExpertDisableExecute
      OnUpdate = actExpertDisableUpdate
    end
    object actExpertAdd: TAction
      Category = 'Experts'
      Caption = '&Add...'
      Hint = 'Add new expert...'
      ImageIndex = 41
      ShortCut = 16449
      OnExecute = actExpertAddExecute
    end
    object actExpertRemove: TAction
      Category = 'Experts'
      Caption = '&Remove'
      Hint = 'Remove expert'
      ImageIndex = 42
      ShortCut = 16466
      OnExecute = actExpertRemoveExecute
      OnUpdate = actExpertRemoveUpdate
    end
    object actExpertMoveUp: TAction
      Category = 'Experts'
      Caption = 'Move &up'
      Hint = 'Move expert up'
      ImageIndex = 93
      ShortCut = 16422
      OnExecute = actExpertMoveUpExecute
    end
    object actExpertMoveDown: TAction
      Category = 'Experts'
      Caption = 'Move &down'
      Hint = 'Move expert down'
      ImageIndex = 92
      ShortCut = 16424
      OnExecute = actExpertMoveDownExecute
    end
    object actFileSave: TAction
      Category = 'File'
      Caption = '&Save to registry'
      Hint = 'Save experts to registry'
      ImageIndex = 31
      ShortCut = 16467
      OnExecute = actFileSaveExecute
    end
    object actFileRevert: TAction
      Category = 'File'
      Caption = '&Revert changes'
      Hint = 'Revert changes'
      ImageIndex = 2
      ShortCut = 16474
      OnExecute = actFileRevertExecute
    end
    object actFileExit: TAction
      Category = 'File'
      Caption = 'E&xit'
      Hint = 'Exit'
      ImageIndex = 8
      ShortCut = 32883
      OnExecute = actFileExitExecute
    end
    object actHelpHelp: TAction
      Category = 'Help'
      Caption = '&Help'
      Hint = 'Help'
      ImageIndex = 0
      ShortCut = 112
      OnExecute = actHelpHelpExecute
    end
    object actHelpContents: TAction
      Category = 'Help'
      Caption = '&Contents'
      Hint = 'Help contents'
      OnExecute = actHelpContentsExecute
    end
    object actHelpAbout: TAction
      Category = 'Help'
      Caption = '&About...'
      Hint = 'About...'
      ImageIndex = 16
      OnExecute = actHelpAboutExecute
    end
  end
  object ilStateImages: TImageList
    Left = 160
    Top = 96
    Bitmap = {
      494C010104000900200010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000002000000001002000000000000020
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000840000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000840000008400000000000000000000000000000000000000
      0000000084000000840000000000000000000000000000000000000000000000
      0000000000000000000000840000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF0000FF0000008400000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000084000000840000000000000000000000000000000000000000000000
      8400000084000000000000000000000000000000000000000000000000000000
      0000FFFFFF000000FF000000FF0000008400000000000000000000000000FFFF
      FF000000FF000000FF0000008400000000000000000000000000000000000000
      000000000000FFFFFF0000FF0000008400000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF0000FF000000FF000000FF00000084000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF000000FF000000FF0000008400000000000000000000000000FFFFFF000000
      FF000000FF000000840000000000000000000000000000000000000000000000
      0000FFFFFF000000FF000000FF000000FF000000840000000000FFFFFF000000
      FF000000FF000000FF0000008400000000000000000000000000000000000000
      0000FFFFFF0000FF000000FF000000FF00000084000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF0000FF000000FF000000FF000000FF000000FF000000840000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF000000FF000000FF000000FF000000840000000000FFFFFF000000FF000000
      FF000000FF000000840000000000000000000000000000000000000000000000
      000000000000FFFFFF000000FF000000FF000000FF00000084000000FF000000
      FF000000FF00000084000000000000000000000000000000000000000000FFFF
      FF0000FF000000FF000000FF000000FF000000FF000000840000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF0000FF
      000000FF000000FF00000084000000FF000000FF000000FF0000008400000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF000000FF000000FF000000FF00000084000000FF000000FF000000
      FF00000084000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF000000FF000000FF000000FF000000FF000000
      FF00000084000000000000000000000000000000000000000000FFFFFF0000FF
      000000FF000000FF00000084000000FF000000FF000000FF0000008400000000
      0000000000000000000000000000000000000000000000000000FFFFFF0000FF
      000000FF00000084000000000000FFFFFF0000FF000000FF000000FF00000084
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF000000FF000000FF000000FF000000FF000000FF000000
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFFFF000000FF000000FF000000FF000000
      8400000000000000000000000000000000000000000000000000FFFFFF0000FF
      000000FF00000084000000000000FFFFFF0000FF000000FF000000FF00000084
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00000000000000000000000000FFFFFF0000FF000000FF000000FF
      0000008400000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF000000FF000000FF000000FF00000084000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF000000FF000000FF000000FF000000FF000000
      FF0000008400000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00000000000000000000000000FFFFFF0000FF000000FF000000FF
      0000008400000000000000000000000000000000000000000000000000000000
      FF000000FF000000FF00000000000000000000000000FFFFFF0000FF000000FF
      000000FF00000084000000000000000000000000000000000000000000000000
      000000000000FFFFFF000000FF000000FF000000FF000000FF000000FF000000
      8400000000000000000000000000000000000000000000000000000000000000
      FF000000FF000000FF00000000000000FF000000FF00000084000000FF000000
      FF000000FF000000840000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000FF000000FF
      000000FF000000840000000000000000000000000000000000000000FF00FFFF
      FF00FF000000FFFFFF000000FF00000000000000000000000000FFFFFF0000FF
      000000FF000000FF000000840000000000000000000000000000000000000000
      0000FFFFFF000000FF000000FF000000FF00000084000000FF000000FF000000
      FF000000840000000000000000000000000000000000000000000000FF00FFFF
      FF00FF000000FFFFFF000000FF00000000000000840000000000FFFFFF000000
      FF000000FF000000FF0000008400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF0000FF
      000000FF000000FF00000084000000000000000000000000FF00FFFFFF000000
      0000FFFFFF00FFFFFF00FFFFFF000000FF00000000000000000000000000FFFF
      FF0000FF000000FF00000084000000000000000000000000000000000000FFFF
      FF000000FF000000FF000000FF000000840000000000FFFFFF000000FF000000
      FF000000FF00000084000000000000000000000000000000FF00FFFFFF000000
      0000FFFFFF00FFFFFF00FFFFFF000000FF00000000000000000000000000FFFF
      FF000000FF000000FF0000008400000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF0000FF000000FF00000084000000000000000000000000FF00FF000000FFFF
      FF000000FF0000000000000000000000FF000000000000000000000000000000
      0000FFFFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF000000FF000000FF0000008400000000000000000000000000FFFFFF000000
      FF000000FF00000084000000000000000000000000000000FF00FF000000FFFF
      FF000000FF0000000000000000000000FF000000000000000000000000000000
      0000FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF000000000000000000000000000000FF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00000000000000000000000000000000000000FF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF00FFFF
      FF00FF000000FFFFFF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF00FFFF
      FF00FF000000FFFFFF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF000000FF000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF000000FF000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000200000000100010000000000000100000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFDFFFFFFF9F3
      FDFFF8FFF3E7F0E1F8FFF07FE1C3F041F07FE03FE083F803E03FC01FF007FC07
      C01FC20FF80FFE0FC20FE707FC1FFC07E707C183F80FC003FF8380C1F0078041
      FFC180E1E08380E1FFE180F3E1C380F3FFF380FFF3E780FFFFFF80FFFFFF80FF
      FFFFC1FFFFFFC1FFFFFFFFFFFFFFFFFF00000000000000000000000000000000
      000000000000}
  end
  object MainMenu: TMainMenu
    AutoHotkeys = maManual
    Left = 32
    Top = 48
    object mitFile: TMenuItem
      Caption = '&File'
      object mitFileSavetoregistry: TMenuItem
        Action = actFileSave
      end
      object mitFileRevertchanges: TMenuItem
        Action = actFileRevert
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object mitFileExit: TMenuItem
        Action = actFileExit
      end
    end
    object mitExpert: TMenuItem
      Caption = '&Expert'
      object mitExpertEnable: TMenuItem
        Action = actExpertEnable
      end
      object mitExpertDisable: TMenuItem
        Action = actExpertDisable
      end
      object mitSep1: TMenuItem
        Caption = '-'
      end
      object mitExpertAdd: TMenuItem
        Action = actExpertAdd
      end
      object mitExpertRemove: TMenuItem
        Action = actExpertRemove
      end
      object mi_Sep2: TMenuItem
        Caption = '-'
      end
      object mi_ExpertMoveUp: TMenuItem
        Action = actExpertMoveUp
      end
      object mi_ExpertMoveDown: TMenuItem
        Action = actExpertMoveDown
      end
    end
    object mitHelp: TMenuItem
      Caption = '&Help'
      object mitHelpHelp: TMenuItem
        Action = actHelpHelp
      end
      object mitHelpContents: TMenuItem
        Action = actHelpContents
      end
      object mitSep2: TMenuItem
        Caption = '-'
      end
      object mitHelpAbout: TMenuItem
        Action = actHelpAbout
      end
    end
  end
end
