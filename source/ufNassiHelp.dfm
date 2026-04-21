object frmNassiHelp: TfrmNassiHelp
  Left = 0
  Top = 0
  Caption = 'NassiHelp'
  ClientHeight = 420
  ClientWidth = 796
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Courier New'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 18
  object MemoHelp: TMemo
    Left = 0
    Top = 0
    Width = 796
    Height = 420
    Align = alClient
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
    OnKeyDown = MemoHelpKeyDown
  end
end
