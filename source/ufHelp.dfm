object frmHelp: TfrmHelp
  Left = 0
  Top = 0
  Caption = 'frmHelp'
  ClientHeight = 525
  ClientWidth = 1003
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -18
  Font.Name = 'Courier New'
  Font.Style = []
  Position = poMainFormCenter
  PixelsPerInch = 120
  TextHeight = 20
  object lstBoxHelp: TListBox
    Left = 0
    Top = 0
    Width = 1003
    Height = 525
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    ItemHeight = 20
    TabOrder = 0
    OnKeyDown = lstBoxHelpKeyDown
    ExplicitWidth = 997
    ExplicitHeight = 524
  end
end
