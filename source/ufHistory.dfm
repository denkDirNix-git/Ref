object frmHistory: TfrmHistory
  Left = 0
  Top = 0
  Caption = 'History'
  ClientHeight = 541
  ClientWidth = 778
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  OnKeyDown = FormKeyDown
  PixelsPerInch = 120
  TextHeight = 21
  object lstHistory: TListBox
    Left = 0
    Top = 0
    Width = 778
    Height = 541
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Style = lbOwnerDrawFixed
    Align = alClient
    Color = clBtnFace
    ExtendedSelect = False
    ItemHeight = 20
    TabOrder = 0
    OnDblClick = lstHistoryDblClick
    OnDrawItem = lstHistoryDrawItem
    ExplicitWidth = 772
    ExplicitHeight = 540
  end
end
