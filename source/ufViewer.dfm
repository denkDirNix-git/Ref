object frmViewer: TfrmViewer
  Left = 0
  Top = 0
  Caption = 'frmViewer'
  ClientHeight = 596
  ClientWidth = 1006
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -18
  Font.Name = 'Consolas'
  Font.Style = []
  KeyPreview = True
  OnAfterMonitorDpiChanged = FormAfterMonitorDpiChanged
  OnClose = FormClose
  OnCreate = FormCreate
  OnHide = FormHide
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  PixelsPerInch = 120
  TextHeight = 22
  object lstBoxViewer: TListBox
    Left = 0
    Top = 0
    Width = 1006
    Height = 596
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Style = lbVirtualOwnerDraw
    Align = alClient
    ItemHeight = 20
    PopupMenu = PopupMenuViewer
    TabOrder = 0
    OnDrawItem = lstBoxViewerDrawItem
    OnMouseDown = lstBoxViewerMouseDown
    OnMouseMove = lstBoxViewerMouseMove
  end
  object PopupMenuViewer: TPopupMenu
    OnPopup = PopupMenuViewerPopup
    Left = 40
    Top = 40
    object pMnuItmViewerGoto: TMenuItem
      Caption = 'Goto Id'
      OnClick = pMnuItmViewerGotoClick
    end
    object pMnuItmViewCopy: TMenuItem
      Caption = 'Copy Line'
      OnClick = pMnuItmViewCopyClick
    end
    object pMnuItmViewerClose: TMenuItem
      Caption = 'Close'
      OnClick = pMnuItmViewerCloseClick
    end
  end
end
