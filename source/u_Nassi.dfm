object frmNassi: TfrmNassi
  Left = 200
  Top = 200
  Caption = 'Struktogramm-Viewer'
  ClientHeight = 800
  ClientWidth = 834
  Color = clBtnFace
  Constraints.MinHeight = 500
  Constraints.MinWidth = 750
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -18
  Font.Name = 'Consolas'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnMouseWheel = FormMouseWheel
  OnResize = FormResize
  PixelsPerInch = 120
  TextHeight = 22
  object Bevel: TBevel
    Left = 0
    Top = 0
    Width = 834
    Height = 4
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alTop
    Shape = bsTopLine
    ExplicitWidth = 840
  end
  object Panel: TPanel
    Left = 0
    Top = 4
    Width = 834
    Height = 796
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    TabOrder = 0
    DesignSize = (
      834
      796)
    object PaintBox: TPaintBox
      Left = 1
      Top = 1
      Width = 801
      Height = 791
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akLeft, akTop, akRight, akBottom]
      PopupMenu = PopupMenu
      OnPaint = PaintBoxPaint
      ExplicitWidth = 813
      ExplicitHeight = 793
    end
    object ScrollBar: TScrollBar
      Left = 803
      Top = 3
      Width = 21
      Height = 790
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akTop, akRight, akBottom]
      Kind = sbVertical
      PageSize = 0
      SmallChange = 12
      TabOrder = 0
      OnChange = ScrollBarChange
      ExplicitLeft = 809
    end
  end
  object MainMenu: TMainMenu
    Left = 72
    Top = 48
    object mItmFile: TMenuItem
      Caption = 'File    '
      object mItmFileOpen: TMenuItem
        Caption = 'Open ...               F4'
        OnClick = mItmFileOpenClick
      end
      object mItmFileOpenClip: TMenuItem
        Caption = 'Open Clip   Ctrl-F4'
        OnClick = mItmFileOpenClipClick
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object mItmFileSaveOne: TMenuItem
        Caption = 'Save View           F2'
        Enabled = False
        OnClick = mItmFileSaveOneClick
      end
      object mItmFileSaveAll: TMenuItem
        Caption = 'Save all        Ctrl-F2'
        Enabled = False
        OnClick = mItmFileSaveAllClick
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object mItmFileRecent0: TMenuItem
        Enabled = False
        Visible = False
        OnClick = mItmFileRecentClick
      end
      object mItmFileRecent1: TMenuItem
        Enabled = False
        Visible = False
        OnClick = mItmFileRecentClick
      end
      object mItmFileRecent2: TMenuItem
        Enabled = False
        Visible = False
        OnClick = mItmFileRecentClick
      end
      object mItmFileRecent3: TMenuItem
        Enabled = False
        Visible = False
        OnClick = mItmFileRecentClick
      end
      object mItmFileRecent4: TMenuItem
        Enabled = False
        Visible = False
        OnClick = mItmFileRecentClick
      end
      object mItmFileRecent5: TMenuItem
        Enabled = False
        Visible = False
        OnClick = mItmFileRecentClick
      end
      object N5: TMenuItem
        Caption = '-'
        Visible = False
      end
      object mItmFileExit: TMenuItem
        Caption = 'Exit         Alt-F4'
        OnClick = mItmFileExitClick
      end
    end
    object mItmView: TMenuItem
      Caption = 'View    '
      object mItmViewMenu: TMenuItem
        Caption = 'Menu             F10'
        Checked = True
        OnClick = mItmViewMenuClick
      end
      object mItmViewFullScreen: TMenuItem
        Caption = 'Full Screen    F12'
        OnClick = mItmViewFullScreenClick
      end
      object mItmViewWidth80: TMenuItem
        Caption = 'Width 80 Chars'
        OnClick = mItmViewWidth80Click
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object mItmViewAutoSubInterface: TMenuItem
        AutoCheck = True
        Caption = 'AutoSub Interface'
        Checked = True
        OnClick = mItmViewAutoSubInterfaceClick
      end
      object mItmViewIndentThen: TMenuItem
        AutoCheck = True
        Caption = 'Indent Then'
        Checked = True
        OnClick = mItmViewIndentThenClick
      end
      object mItmViewCutComment: TMenuItem
        AutoCheck = True
        Caption = 'Cut Comment'
        Checked = True
        OnClick = mItmViewCutCommentClick
      end
    end
    object mItmOptions: TMenuItem
      Caption = 'Options '
      object mItmOptionsSaveVisual: TMenuItem
        Caption = 'Save visual Options                            F11'
        OnClick = mItmOptionsSaveVisualClick
      end
      object mItmOptionsSaveGlobal: TMenuItem
        Caption = 'Save global Options                 Shift-F11'
        OnClick = mItmOptionsSaveGlobalClick
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object mItmOptionsSaveSubViewsLocal: TMenuItem
        AutoCheck = True
        Caption = 'Save Project-SubViews local     Ctrl-F11'
        Enabled = False
        OnClick = mItmOptionsSaveSubViewsLocalClick
      end
    end
    object mItmHelp: TMenuItem
      Caption = 'Help'
      object mItmHelpHelp: TMenuItem
        Caption = 'Help                F1'
        OnClick = mItmHelpHelpClick
      end
      object mItmHelpInfo: TMenuItem
        Caption = 'Info        Shift-F1'
        OnClick = mItmHelpInfoClick
      end
    end
  end
  object PopupMenu: TPopupMenu
    OnPopup = PopupMenuPopup
    Left = 192
    Top = 51
    object pItmSubViewLeave: TMenuItem
      OnClick = pItmSubViewLeaveClick
    end
    object pItmSubViewEnter: TMenuItem
      Caption = 'SubView Enter'
      OnClick = pItmSubViewEnterClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object pItmSubViewCreate: TMenuItem
      Caption = 'SubView Create '
      OnClick = pItmSubViewCreateClick
    end
    object pItmSubViewDestroy: TMenuItem
      Caption = 'SubView Destroy'
      OnClick = pItmSubViewDestroyClick
    end
    object pItmSubViewSetHeader: TMenuItem
      Caption = 'SubView Set Header'
      OnClick = pItmSubViewSetHeaderClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object pItmSearchText: TMenuItem
      Caption = 'Search Text ...'
      ShortCut = 16454
      OnClick = pItmSearchTextClick
    end
    object pItmCopyText: TMenuItem
      Caption = 'Copy Text'
      ShortCut = 16451
      OnClick = pItmCopyTextClick
    end
    object N8: TMenuItem
      Caption = '-'
    end
    object pItmHighlight: TMenuItem
      Caption = 'Highlight'
      object pItmHighlightOn: TMenuItem
        Caption = 'on'
        OnClick = pItmHighlightOnClick
      end
      object pItmHighlightOff: TMenuItem
        Caption = 'off'
        OnClick = pItmHighlightOffClick
      end
      object pItmHighlightPrevOn: TMenuItem
        Caption = 'all prev on'
        OnClick = pItmHighlightPrevOnClick
      end
      object pItmHighlightPrevOff: TMenuItem
        Caption = 'all prev off'
        OnClick = pItmHighlightPrevOffClick
      end
      object pItmHighlightAllOff: TMenuItem
        Caption = 'all off'
        OnClick = pItmHighlightAllOffClick
      end
    end
  end
  object OpenDialog: TOpenDialog
    DefaultExt = 'pas'
    Filter = 'Pascal|*.pas'
    Options = [ofEnableSizing]
    Left = 296
    Top = 51
  end
end
