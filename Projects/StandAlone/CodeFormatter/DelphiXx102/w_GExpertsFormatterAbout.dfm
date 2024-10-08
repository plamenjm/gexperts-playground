object f_GExpertsFormatterAbout: Tf_GExpertsFormatterAbout
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'About GExperts Source Code Formatter'
  ClientHeight = 113
  ClientWidth = 562
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  DesignSize = (
    562
    113)
  PixelsPerInch = 96
  TextHeight = 13
  object l_StandAloneAbout: TLabel
    Left = 8
    Top = 8
    Width = 509
    Height = 13
    Caption = 
      'StandAlone version originally by Ulrich Gerhardt <ulrich.gerhard' +
      't@gmx.de>, extended by Thomas Mueller'
  end
  object l_ExperimentalAbout: TLabel
    Left = 8
    Top = 32
    Width = 398
    Height = 13
    Caption = 
      'Experimental GExperts version by Thomas Mueller https://gexperts' +
      '.dummzeuch.de'
  end
  object l_DelForExp: TLabel
    Left = 8
    Top = 56
    Width = 265
    Height = 13
    Caption = 'Code formatter based on DelForExp by Egbert van Nes'
  end
  object b_AboutGExperts: TButton
    Left = 8
    Top = 80
    Width = 153
    Height = 25
    Caption = 'About &GExperts ...'
    TabOrder = 0
    Visible = False
    OnClick = b_AboutGExpertsClick
  end
  object b_Close: TButton
    Left = 480
    Top = 80
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Cancel = True
    Caption = 'Close'
    TabOrder = 1
    OnClick = b_CloseClick
  end
end
