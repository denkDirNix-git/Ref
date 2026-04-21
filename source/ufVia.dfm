object frmVia: TfrmVia
  Left = 0
  Top = 0
  Caption = 'frmVia'
  ClientHeight = 451
  ClientWidth = 440
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 120
  DesignSize = (
    440
    451)
  TextHeight = 20
  object TreeViewVia: TTreeView
    Left = 20
    Top = 26
    Width = 395
    Height = 300
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akTop, akRight, akBottom]
    HideSelection = False
    Indent = 24
    ReadOnly = True
    TabOrder = 0
    OnCustomDrawItem = TreeViewViaCustomDrawItem
    ExplicitWidth = 389
    ExplicitHeight = 299
  end
  object BitBtn1: TBitBtn
    Left = 244
    Top = 384
    Width = 171
    Height = 51
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akRight, akBottom]
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 1
    ExplicitLeft = 238
    ExplicitTop = 383
  end
  object BitBtn2: TBitBtn
    Left = 20
    Top = 384
    Width = 171
    Height = 51
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akBottom]
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 2
    ExplicitTop = 383
  end
  object btnExpand: TButton
    Left = 20
    Top = 334
    Width = 94
    Height = 24
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akBottom]
    Caption = 'Expand all'
    TabOrder = 3
    OnClick = btnExpandClick
    ExplicitTop = 333
  end
  object btnCollapse: TButton
    Left = 122
    Top = 334
    Width = 94
    Height = 24
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akBottom]
    Caption = 'Collapse all'
    TabOrder = 4
    OnClick = btnCollapseClick
    ExplicitTop = 333
  end
  object btnSearch: TButton
    Left = 321
    Top = 334
    Width = 94
    Height = 24
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akRight, akBottom]
    Caption = 'Search...'
    TabOrder = 5
    OnClick = btnSearchClick
    ExplicitLeft = 315
    ExplicitTop = 333
  end
  object btnSearchAgain: TButton
    Left = 219
    Top = 334
    Width = 94
    Height = 24
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akRight, akBottom]
    Caption = 'Search again'
    TabOrder = 6
    OnClick = btnSearchAgainClick
    ExplicitLeft = 213
    ExplicitTop = 333
  end
end
