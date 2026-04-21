object frmError: TfrmError
  Left = 0
  Top = 0
  BorderIcons = []
  Caption = 'frmError'
  ClientHeight = 351
  ClientWidth = 530
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  Position = poMainFormCenter
  PixelsPerInch = 120
  DesignSize = (
    530
    351)
  TextHeight = 19
  object lblError: TLabel
    Left = 60
    Top = 50
    Width = 415
    Height = 181
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akTop, akRight, akBottom]
    AutoSize = False
    Caption = 'LabelErr'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -26
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    WordWrap = True
    ExplicitWidth = 421
  end
  object BitBtnOk: TBitBtn
    Left = 324
    Top = 280
    Width = 151
    Height = 51
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akRight, akBottom]
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 0
    OnClick = BitBtnOkClick
    ExplicitLeft = 318
    ExplicitTop = 279
  end
end
