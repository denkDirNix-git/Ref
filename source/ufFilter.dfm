object frmFilter: TfrmFilter
  Left = 0
  Top = 0
  ActiveControl = radGrpFilter
  Caption = 'Set Filter'
  ClientHeight = 786
  ClientWidth = 1025
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -20
  Font.Name = 'Arial'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 120
  DesignSize = (
    1025
    786)
  TextHeight = 23
  object lblHint: TLabel
    Left = 430
    Top = 45
    Width = 369
    Height = 23
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Selected Filter shows all Identifiers that ...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGrayText
    Font.Height = -20
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object lblSelect: TLabel
    Left = 20
    Top = 45
    Width = 198
    Height = 23
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Select Filter Condition:'
  end
  object radGrpFilter: TRadioGroup
    Left = 20
    Top = 70
    Width = 381
    Height = 580
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    ItemIndex = 0
    Items.Strings = (
      '&Name'
      '&Type'
      'unresolved (but &qualified)'
      '&Declare only'
      'no &Write'
      'no &Read'
      '&not used Units'
      'Referenced'
      'Re&ferencers'
      'non-&ANSI'
      'Class-&Hierarchy'
      '&MessageHandler'
      '&Generics'
      '&Overloads')
    TabOrder = 0
    OnClick = radGrpFilterClick
  end
  object cmbBoxName: TComboBox
    Left = 113
    Top = 99
    Width = 278
    Height = 26
    Hint = 'Use "." at Start or End to change Compare-behaviour'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    TextHint = 'Enter Identifier (min 2 chars)'
    OnEnter = cmbBoxNameEnter
  end
  object BitBtnFilterCancel: TBitBtn
    Left = 668
    Top = 698
    Width = 151
    Height = 57
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akRight, akBottom]
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 4
  end
  object BitBtnFilterOkay: TBitBtn
    Left = 848
    Top = 698
    Width = 151
    Height = 57
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      0400000000006801000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      3333333333333333333333330000333333333333333333333333F33333333333
      00003333344333333333333333388F3333333333000033334224333333333333
      338338F3333333330000333422224333333333333833338F3333333300003342
      222224333333333383333338F3333333000034222A22224333333338F338F333
      8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
      33333338F83338F338F33333000033A33333A222433333338333338F338F3333
      0000333333333A222433333333333338F338F33300003333333333A222433333
      333333338F338F33000033333333333A222433333333333338F338F300003333
      33333333A222433333333333338F338F00003333333333333A22433333333333
      3338F38F000033333333333333A223333333333333338F830000333333333333
      333A333333333333333338330000333333333333333333333333333333333333
      0000}
    NumGlyphs = 2
    TabOrder = 5
    OnClick = BitBtnFilterOkayClick
  end
  object MemoHint1: TMemo
    Left = 430
    Top = 70
    Width = 550
    Height = 495
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    TabStop = False
    Anchors = [akLeft, akTop, akRight, akBottom]
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGrayText
    Font.Height = -20
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 6
  end
  object MemoHint2: TMemo
    Left = 430
    Top = 568
    Width = 550
    Height = 82
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    TabStop = False
    Anchors = [akLeft, akRight, akBottom]
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGrayText
    Font.Height = -20
    Font.Name = 'Arial'
    Font.Style = [fsItalic]
    Lines.Strings = (
      'Please note for Identifier-Tree in filtered View:'
      'Identifiers in Italics don'#39't match the Filter-Condition but are '
      'needed for showing the filtered Ids in Hierarchy')
    ParentFont = False
    ReadOnly = True
    TabOrder = 7
  end
  object chkBoxDeclareOnly: TCheckBox
    Left = 193
    Top = 223
    Width = 187
    Height = 23
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'ignore Method-Sender'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    Visible = False
  end
  object cmbBoxTyp: TComboBox
    Left = 113
    Top = 139
    Width = 278
    Height = 26
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Style = csDropDownList
    TabOrder = 2
    OnEnter = cmbBoxTypEnter
  end
end
