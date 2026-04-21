object frmMain: TfrmMain
  Left = 97
  Top = 111
  ClientHeight = 676
  ClientWidth = 1289
  Color = clBtnFace
  Constraints.MinHeight = 375
  Constraints.MinWidth = 625
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -18
  Font.Name = 'Arial'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu
  OnAfterMonitorDpiChanged = FormAfterMonitorDpiChanged
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnMouseWheel = FormMouseWheel
  OnResize = FormResize
  PixelsPerInch = 120
  TextHeight = 21
  object SplitterMain: TSplitter
    Left = 250
    Top = 0
    Width = 6
    Height = 653
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    OnMoved = SplitterMainMoved
    ExplicitTop = 38
    ExplicitHeight = 615
  end
  object lblStatus: TLabel
    Left = 0
    Top = 653
    Width = 1289
    Height = 23
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alBottom
    AutoSize = False
    Caption = 'Status'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clInfoText
    Font.Height = -20
    Font.Name = 'Arial'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    Layout = tlCenter
  end
  object PanelLeft: TPanel
    Left = 0
    Top = 0
    Width = 250
    Height = 653
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alLeft
    BevelEdges = [beLeft, beTop, beBottom]
    BevelWidth = 3
    Color = clBtnHighlight
    Constraints.MinWidth = 250
    ParentBackground = False
    ShowCaption = False
    TabOrder = 0
    ExplicitHeight = 652
    object PaintBox: TPaintBox
      Tag = 1
      Left = 3
      Top = 41
      Width = 214
      Height = 556
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      Color = clBtnFace
      ParentColor = False
      PopupMenu = PopupMenuId
      OnMouseDown = PaintBoxMouseDown
      OnPaint = PaintBoxPaint
      ExplicitLeft = 4
      ExplicitTop = 4
      ExplicitHeight = 554
    end
    object pnlLblFilter: TPanel
      Left = 3
      Top = 597
      Width = 244
      Height = 53
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alBottom
      BevelInner = bvRaised
      BevelOuter = bvLowered
      Caption = 'pnlLblFilter'
      TabOrder = 0
      Visible = False
      ExplicitTop = 596
      object lblFilter: TLabel
        Left = 2
        Top = 2
        Width = 240
        Height = 49
        Hint = 'Filter-Condition and Result'
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alClient
        AutoSize = False
        Color = clCream
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        ParentShowHint = False
        ShowAccelChar = False
        ShowHint = False
        Transparent = False
        Layout = tlCenter
        OnClick = lblFilterClick
        ExplicitLeft = 3
        ExplicitTop = 3
        ExplicitWidth = 237
        ExplicitHeight = 48
      end
    end
    object ScrollBarTv: TScrollBar
      Tag = 1
      AlignWithMargins = True
      Left = 221
      Top = 45
      Width = 22
      Height = 548
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alRight
      Kind = sbVertical
      Max = 0
      PageSize = 0
      TabOrder = 1
      TabStop = False
      OnEnter = ScrollBarTvEnterExit
      OnExit = ScrollBarTvEnterExit
      OnKeyDown = ScrollBarTvKeyDown
      OnScroll = ScrollBarTvScroll
      ExplicitHeight = 547
    end
    object ToolBarId: TToolBar
      Left = 3
      Top = 3
      Width = 244
      Height = 38
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      BorderWidth = 1
      ButtonHeight = 26
      ButtonWidth = 29
      Caption = 'ToolBarId'
      Color = clBtnFace
      EdgeBorders = [ebTop, ebBottom]
      Images = ImageList
      Indent = 1
      List = True
      ParentColor = False
      ParentShowHint = False
      AllowTextButtons = True
      ShowHint = True
      TabOrder = 2
      Wrapable = False
      DesignSize = (
        240
        30)
      object cmbBoxSearch: TComboBox
        Left = 1
        Top = 0
        Width = 174
        Height = 26
        Hint = 'Search incremental. Use "." at Start or End to change behaviour'
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        AutoComplete = False
        AutoCompleteDelay = 200
        Anchors = [akLeft, akTop, akRight]
        DropDownCount = 12
        TabOrder = 0
        TabStop = False
        TextHint = 'Search for Id ...'
        OnChange = cmbBoxSearchChange
        OnDblClick = cmbBoxSearchDblClick
        OnEnter = cmbBoxSearchEnter
        OnExit = cmbBoxSearchExit
        OnKeyPress = cmbBoxSearchKeyPress
      end
      object ToolButton3: TToolButton
        Left = 175
        Top = 0
        Width = 10
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'ToolButton3'
        ImageIndex = 12
        Style = tbsSeparator
      end
      object tBtnIdBack: TToolButton
        Left = 185
        Top = 0
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Action = actIdentifierBack
      end
      object ToolButton8: TToolButton
        Left = 209
        Top = 0
        Width = 8
        Caption = 'ToolButton8'
        ImageIndex = 20
        Style = tbsSeparator
      end
      object tBtnIdFilter: TToolButton
        Left = 217
        Top = 0
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Action = actIdViewFilter
        Style = tbsCheck
      end
    end
  end
  object PanelRight: TPanel
    Left = 256
    Top = 0
    Width = 1033
    Height = 653
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    ShowCaption = False
    TabOrder = 1
    ExplicitWidth = 1027
    ExplicitHeight = 652
    DesignSize = (
      1033
      653)
    object pnlAcsAndFiles: TPanel
      Left = 1
      Top = 39
      Width = 1031
      Height = 613
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      ShowCaption = False
      TabOrder = 1
      ExplicitWidth = 1025
      ExplicitHeight = 612
      object SplitterFiles: TSplitter
        Left = 855
        Top = 1
        Width = 6
        Height = 611
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Align = alRight
        Visible = False
        ExplicitLeft = 854
        ExplicitHeight = 610
      end
      object pnlAcs: TPanel
        Left = 1
        Top = 1
        Width = 854
        Height = 611
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -10
        Font.Name = 'Consolas'
        Font.Style = []
        ParentFont = False
        ShowCaption = False
        TabOrder = 0
        ExplicitWidth = 848
        ExplicitHeight = 610
        object lstBox: TListBox
          Tag = 2
          Left = 1
          Top = 1
          Width = 852
          Height = 609
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          TabStop = False
          Style = lbVirtualOwnerDraw
          Align = alClient
          ItemHeight = 20
          PopupMenu = PopupMenuAc
          TabOrder = 0
          OnDrawItem = lstBoxDrawItem
          OnKeyDown = lstBoxKeyDown
          OnMouseDown = lstBoxMouseDown
          OnMouseMove = lstBoxMouseMove
        end
      end
      object pnlFiles: TPanel
        Left = 861
        Top = 1
        Width = 169
        Height = 611
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Align = alRight
        Constraints.MinWidth = 125
        TabOrder = 1
        Visible = False
        ExplicitLeft = 855
        ExplicitHeight = 610
        object lstBoxHotKey: TListBox
          Left = 1
          Top = 1
          Width = 167
          Height = 609
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Style = lbVirtualOwnerDraw
          Align = alClient
          Color = 15923711
          ItemHeight = 20
          TabOrder = 1
          Visible = False
          OnClick = lstBoxHotKeyClick
          OnDrawItem = lstBoxHotKeyDrawItem
        end
        object lstBoxHistory: TListBox
          Left = 1
          Top = 1
          Width = 167
          Height = 609
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Style = lbVirtualOwnerDraw
          Align = alClient
          Color = 16046785
          ItemHeight = 20
          TabOrder = 2
          Visible = False
        end
        object tvFiles: TTreeView
          Left = 1
          Top = 1
          Width = 167
          Height = 609
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Align = alClient
          HideSelection = False
          Indent = 24
          ReadOnly = True
          RightClickSelect = True
          TabOrder = 0
          TabStop = False
          OnClick = tvFilesClick
          OnCustomDrawItem = tvFilesCustomDrawItem
          OnDblClick = tvFilesDblClick
          OnKeyDown = tvFilesKeyDown
          OnMouseMove = tvFilesMouseMove
          ExplicitHeight = 608
        end
      end
    end
    object btnRunAgain: TButton
      Left = 63
      Top = 119
      Width = 751
      Height = 367
      Margins.Left = 63
      Margins.Top = 38
      Margins.Right = 63
      Margins.Bottom = 38
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = 'Run again'
      Default = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      Visible = False
      WordWrap = True
      OnClick = btnRunAgainClick
      ExplicitWidth = 745
      ExplicitHeight = 366
    end
    object ToolBarAc: TToolBar
      Left = 1
      Top = 1
      Width = 1031
      Height = 38
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      BorderWidth = 1
      ButtonHeight = 27
      ButtonWidth = 129
      Color = clBtnFace
      EdgeBorders = [ebTop, ebBottom]
      Images = ImageList
      Indent = 1
      List = True
      ParentColor = False
      ParentShowHint = False
      AllowTextButtons = True
      ShowHint = True
      TabOrder = 2
      Wrapable = False
      OnResize = ToolBarAcResize
      ExplicitWidth = 1025
      object ToolButton4: TToolButton
        Left = 1
        Top = 0
        Width = 10
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'ToolButton4'
        ImageIndex = 12
        Style = tbsSeparator
      end
      object tBtnKontextPlus: TToolButton
        Left = 11
        Top = 0
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Action = actViewKontextPlus
      end
      object tBtnKontextMinus: TToolButton
        Left = 35
        Top = 0
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Action = actViewKontextMinus
      end
      object ToolButton7: TToolButton
        Left = 59
        Top = 0
        Width = 10
        Style = tbsSeparator
      end
      object tBtnDeclare: TToolButton
        Left = 69
        Top = 0
        Action = actRefDeclaration
        AutoSize = True
        Caption = 'Find Declare'
        Style = tbsTextButton
      end
      object ToolButton6: TToolButton
        Left = 182
        Top = 0
        Width = 10
        Caption = 'ToolButton6'
        ImageIndex = 12
        Style = tbsSeparator
      end
      object chkBoxWriteOnly: TCheckBox
        Left = 192
        Top = 0
        Width = 130
        Height = 27
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabStop = False
        Action = actRefsWriteOnly
        TabOrder = 0
      end
      object ToolButton10: TToolButton
        Left = 322
        Top = 0
        Width = 10
        Caption = 'ToolButton10'
        Style = tbsSeparator
      end
      object tBtnSelectFromVia: TToolButton
        Left = 332
        Top = 0
        Action = actRefsViaSelect
        AutoSize = True
        Caption = 'Select Via...'
        Style = tbsTextButton
      end
      object ToolButton5: TToolButton
        Left = 438
        Top = 0
        Width = 10
        Caption = 'ToolButton5'
        ImageIndex = 12
        Style = tbsSeparator
      end
      object chkBoxViaIdOnly: TCheckBox
        Left = 448
        Top = 0
        Width = 110
        Height = 27
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabStop = False
        Action = actRefsViaOnly
        TabOrder = 3
      end
      object ToolButton9: TToolButton
        Left = 558
        Top = 0
        Width = 10
        Caption = 'ToolButton9'
        ImageIndex = 12
        Style = tbsSeparator
      end
      object cboBoxUnits: TComboBox
        Left = 568
        Top = 0
        Width = 145
        Height = 29
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Style = csDropDownList
        DropDownCount = 24
        Enabled = False
        Sorted = True
        TabOrder = 2
        TabStop = False
        TextHint = '< all Units >'
        OnClick = cboBoxUnitsClick
        OnDropDown = cboBoxUnitsDropDown
      end
      object ToolButton1: TToolButton
        Left = 713
        Top = 0
        Width = 8
        Caption = 'ToolButton1'
        ImageIndex = 12
        Style = tbsSeparator
      end
      object chkBoxUnitOnly: TCheckBox
        Left = 721
        Top = 0
        Width = 100
        Height = 27
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabStop = False
        Caption = 'Unit only'
        Enabled = False
        TabOrder = 1
        OnClick = chkBoxUnitOnlyClick
      end
      object tBtnSepaHelp: TToolButton
        Left = 821
        Top = 0
        Width = 656
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'tBtnSepaHelp'
        ImageIndex = 5
        Style = tbsSeparator
      end
      object tBtnHelp: TToolButton
        Left = 1477
        Top = 0
        Hint = 'Show Help-File'
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Action = actHelpHilfe
      end
    end
  end
  object MainMenu: TMainMenu
    AutoHotkeys = maManual
    Images = ImageList
    Left = 206
    Top = 257
    object MainMenuFile: TMenuItem
      Caption = 'File'
      object mItmFileNew: TMenuItem
        Action = actFileNew
        Caption = 'New'
      end
      object mItmFileOpen: TMenuItem
        Action = actFileOpen
        Caption = 'Open ...'
      end
      object mItmOpenRecent1: TMenuItem
        Caption = 'Recent1'
        ImageIndex = 7
        Visible = False
        OnClick = mItmRecentClick
      end
      object mItmOpenRecent2: TMenuItem
        Caption = 'Recent2'
        ImageIndex = 7
        Visible = False
        OnClick = mItmRecentClick
      end
      object mItmOpenRecent3: TMenuItem
        Caption = 'Recent3'
        ImageIndex = 7
        Visible = False
        OnClick = mItmRecentClick
      end
      object mItmOpenRecent4: TMenuItem
        Caption = 'Recent4'
        OnClick = mItmRecentClick
      end
      object mItmOpenRecent5: TMenuItem
        Caption = 'Recent5'
        ImageIndex = 7
        Visible = False
        OnClick = mItmRecentClick
      end
      object mItmOpenRecent6: TMenuItem
        Caption = 'Recent6'
        OnClick = mItmRecentClick
      end
      object mItmOpenRecent7: TMenuItem
        Caption = 'Recent7'
        OnClick = mItmRecentClick
      end
      object mItmOpenRecent8: TMenuItem
        Caption = 'Recent8'
        OnClick = mItmRecentClick
      end
      object mItmFileOpenClip: TMenuItem
        Caption = 'Open ClipBoard'
        ShortCut = 16499
        OnClick = mItmFileOpenClipClick
      end
      object N11: TMenuItem
        Caption = '-'
      end
      object mItmFileReParse: TMenuItem
        Caption = 'ReParse'
        Enabled = False
        ShortCut = 116
        OnClick = mItmFileReParseClick
      end
      object N12: TMenuItem
        Caption = '-'
      end
      object mItmFileSave: TMenuItem
        Action = actFileSave
        Caption = 'Save'
      end
      object mItmFileSaveAs: TMenuItem
        Action = actFileSaveAs
        Caption = 'Save as ...'
      end
      object mItmFileClose: TMenuItem
        Action = actFileClose
        Caption = 'Close'
        Visible = False
      end
      object mItmProgClose: TMenuItem
        Action = actProgExit
      end
      object mItmProgCloseNoSave: TMenuItem
        Action = actProgExitNoSave
        Visible = False
      end
    end
    object MainMenuIds: TMenuItem
      Caption = 'Identifier'
      object mItmIdSearch: TMenuItem
        Action = actSearch
        Caption = 'Search ...'
      end
      object mItmIdSearchAgain: TMenuItem
        Action = actSearchAgain
        Caption = 'Search again'
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object mItmIdSetFilter: TMenuItem
        Action = actIdSetFilter
      end
      object mItmIdFilter: TMenuItem
        Action = actIdViewFilter
        AutoCheck = True
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object mItmIdBack: TMenuItem
        Action = actIdentifierBack
        Caption = 'Goto previous Id'
      end
      object mItmIdHistory: TMenuItem
        Caption = 'History'
        ShortCut = 113
        OnClick = mItmIdHistoryClick
      end
      object N15: TMenuItem
        Caption = '-'
      end
      object mItmAnsichtReduzieren: TMenuItem
        Action = actIdReduce
      end
    end
    object MainMenuAcs: TMenuItem
      Caption = 'References'
      object mItmRefKontextPlus: TMenuItem
        Action = actViewKontextPlus
        Caption = 'show more'
      end
      object mItmRefKontextMinus: TMenuItem
        Action = actViewKontextMinus
        Caption = 'show less'
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object mItmRefDeclaration: TMenuItem
        Action = actRefDeclaration
      end
      object mItmRefWriteOnly: TMenuItem
        Action = actRefsWriteOnly
        AutoCheck = True
      end
      object N16: TMenuItem
        Caption = '-'
      end
      object mItmRefViaOnly: TMenuItem
        Action = actRefsViaOnly
        AutoCheck = True
      end
      object mItmRefViaSelect: TMenuItem
        Action = actRefsViaSelect
      end
      object N17: TMenuItem
        Caption = '-'
      end
      object mItmRefUnitOnly: TMenuItem
        Caption = 'Unit only'
        OnClick = mItmRefUnitOnlyClick
      end
    end
    object MainMenuView: TMenuItem
      Caption = 'View    '
      object mItmViewFullScreen: TMenuItem
        Action = actViewFullScreen
        AutoCheck = True
        Caption = 'full Screen'
        ShortCut = 123
      end
      object mItmViewZoomPlus: TMenuItem
        Caption = 'Zoom +'
        Hint = 'Vergr'#246#223'ern|Gr'#246#223'ere Schrift  verwenden'
        OnClick = mItmViewZoomPlusClick
      end
      object mItmViewZoomMinus: TMenuItem
        Caption = 'Zoom -'
        Hint = 'Verkleinern|Kleinere Schrift  verwenden'
        OnClick = mItmViewZoomMinusClick
      end
      object mItmViewFiles: TMenuItem
        AutoCheck = True
        Caption = 'FileTree'
        Enabled = False
        ShortCut = 8313
        Visible = False
        OnClick = mItmViewFilesClick
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object mItmViewCounter: TMenuItem
        Caption = 'Id- and Ref-Counts'
        ShortCut = 121
        OnClick = mItmViewCounterClick
      end
      object mItmViewStatusBar: TMenuItem
        AutoCheck = True
        Caption = 'StatusBar'
        Checked = True
        ShortCut = 16505
        OnClick = mItmViewStatusBarClick
      end
      object mItmViewIdHistory: TMenuItem
        Caption = 'Identifier-History'
        ShortCut = 113
        OnClick = mItmIdHistoryClick
      end
    end
    object MainMenuOptions: TMenuItem
      Caption = 'Options  '
      object mItmOptionsPosition: TMenuItem
        Caption = 'Save global and visual Options'
        OnClick = mItmOptionsPositionClick
      end
      object N10: TMenuItem
        Caption = '-'
      end
      object mItmOptionsPathMacros: TMenuItem
        Caption = 'Path-Macros ...'
        OnClick = mItmOptionsPathMacrosClick
      end
      object mItmOptionsDelphiPath: TMenuItem
        Caption = 'Delphi-Source-Paths ...'
        OnClick = mItmOptionsDelphiPathClick
      end
      object mItmOptionsNamespace: TMenuItem
        Caption = 'Namespaces ...'
        OnClick = mItmOptionsNamespaceClick
      end
      object mItmOptionsAutoParse: TMenuItem
        AutoCheck = True
        Caption = 'Auto-Parse after File-Open'
        Checked = True
        OnClick = mItmOptionsAutoParseClick
      end
      object mItmOptionsSourcePathIni: TMenuItem
        AutoCheck = True
        Caption = 'Project-Ini in Source-Path'
        OnClick = mItmOptionsSourcePathIniClick
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object mItmOptionsProjectOptions: TMenuItem
        Caption = 'Project Options ...'
        ShortCut = 16506
        OnClick = mItmOptionsProjectOptionsClick
      end
    end
    object MainMenuRefactor: TMenuItem
      Caption = 'Refactor'
      object mItmRefactorEndIf: TMenuItem
        AutoCheck = True
        Caption = '$ENDIF erg'#228'nzen '
        OnClick = mItmRefactorEndIfClick
      end
    end
    object MainMenuHelp: TMenuItem
      Caption = 'Help'
      object mItmHelpHilfe: TMenuItem
        Action = actHelpHilfe
        Caption = 'Help'
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object mItmHelpInfo: TMenuItem
        Action = actHelpInfo
        Caption = '&Info'
      end
      object mItmHelpMailTo: TMenuItem
        Caption = 'Send eMail ...'
        Visible = False
        OnClick = mItmHelpMailToClick
      end
      object mItmExtraExportDebug: TMenuItem
        Caption = 'Export Debug'
        Enabled = False
        OnClick = mItmExtraExportDebugClick
      end
    end
  end
  object ActionList: TActionList
    Images = ImageList
    Left = 208
    Top = 182
    object actFileNew: TAction
      Category = 'Datei'
      Caption = '&Neu'
      Hint = 'Neu|Neue Datei erstellen'
      ImageIndex = 6
      OnExecute = actFileNewCloseExecute
    end
    object actFileOpen: TAction
      Category = 'Datei'
      Caption = #214'&ffnen'
      Hint = #214'ffnen|Datei '#246'ffnen'
      ImageIndex = 7
      ShortCut = 115
      OnExecute = actFileOpenExecute
    end
    object actFileSave: TAction
      Category = 'Datei'
      Caption = '&Speichern'
      Enabled = False
      Hint = 'Speichern|Datei speichern'
      ImageIndex = 8
      OnExecute = actFileSaveExecute
    end
    object actFileSaveAs: TAction
      Category = 'Datei'
      Caption = 'Speichern &unter...'
      Hint = 'Speichern unter|Datei unter einem anderen Namen speichern'
      Visible = False
      OnExecute = actFileSaveAsExecute
    end
    object actFileClose: TAction
      Category = 'Datei'
      Caption = 'Schlie'#223'en'
      Hint = 'Schlie'#223'en|Datei schlie'#223'en'
      OnExecute = actFileNewCloseExecute
    end
    object actProgExit: TAction
      Category = 'Datei'
      Caption = 'E&xit'
      Hint = 'Exit'
      OnExecute = actProgExitExecute
    end
    object actHelpInfo: TAction
      Category = 'Hilfe'
      Caption = '&Info...'
      Hint = 'Info|Anzeige von Kontakt und Versionsnummer'
      ShortCut = 8304
      OnExecute = actHelpInfoExecute
    end
    object actHelpHilfe: TAction
      Category = 'Hilfe'
      Caption = 'Hilfe'
      Hint = 'Hilfe|'#214'ffnen der Hilfe-Datei'
      ImageIndex = 11
      ShortCut = 112
      OnExecute = actHelpHilfeExecute
    end
    object actProgExitNoSave: TAction
      Category = 'Datei'
      Caption = '... dont save'
      Enabled = False
      Hint = 'Exit without save'
      ShortCut = 8219
      OnExecute = actProgExitNoSaveExecute
    end
    object actViewFullScreen: TAction
      Category = 'View'
      AutoCheck = True
      Caption = 'ganzer Bildschirm'
      Hint = 'Maximieren|auf ganzen Bildschirm maximieren'
      ShortCut = 122
      OnExecute = actViewFullScreenExecute
    end
    object actViewKontextPlus: TAction
      Category = 'View'
      Caption = 'Context +'
      Hint = 'more Context for References'
      ImageIndex = 16
      OnExecute = actViewKontextPlusExecute
    end
    object actViewKontextMinus: TAction
      Category = 'View'
      Caption = 'Kontext -'
      Hint = 'less Context for References'
      ImageIndex = 17
      OnExecute = actViewKontextMinusExecute
    end
    object actSearch: TAction
      Category = 'identifier'
      Caption = 'Suchen ...'
      ImageIndex = 13
      ShortCut = 118
      OnExecute = actSearchExecute
    end
    object actSearchAgain: TAction
      Category = 'identifier'
      Caption = 'Weiter suchen'
      ShortCut = 114
      OnExecute = actSearchAgainExecute
    end
    object actRefsWriteOnly: TAction
      Category = 'References'
      AutoCheck = True
      Caption = 'Writes only'
      Hint = 'nur Write'
      ShortCut = 120
      OnExecute = actRefsWriteOnlyExecute
    end
    object actIdentifierBack: TAction
      Category = 'identifier'
      Caption = 'Back'
      Hint = 'previous Identifier'
      ImageIndex = 3
      OnExecute = actIdentifierBackExecute
    end
    object actIdSetFilter: TAction
      Category = 'identifier'
      Caption = 'Set Filter ...'
      OnExecute = actIdSetFilterExecute
    end
    object actIdViewFilter: TAction
      Category = 'identifier'
      AutoCheck = True
      Caption = 'View Filtered'
      ImageIndex = 19
      OnExecute = actIdViewFilterExecute
    end
    object actIdReduce: TAction
      Category = 'identifier'
      Caption = 'Reduce'
      ShortCut = 122
      OnExecute = actIdReduceExecute
    end
    object actIdFilterName: TAction
      Category = 'identifier'
      Caption = 'Fillter for exact Name'
      OnExecute = actIdFilterNameExecute
    end
    object actIdFilterHierarchy: TAction
      Category = 'identifier'
      Caption = 'Filter Hierarchy'
      OnExecute = actIdFilterHierarchyExecute
    end
    object actRefsViaOnly: TAction
      Category = 'References'
      AutoCheck = True
      Caption = 'Via-Id only'
      OnExecute = actRefsViaOnlyExecute
    end
    object actRefsViaSelect: TAction
      Category = 'References'
      Caption = 'Select...'
      OnExecute = actRefsViaSelectExecute
    end
    object actRefDeclaration: TAction
      Category = 'References'
      Caption = 'Declare'
      ShortCut = 119
      OnExecute = actRefDeclarationExecute
    end
  end
  object ImageList: TImageList
    Left = 208
    Top = 342
    Bitmap = {
      494C010114002000040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000006000000001002000000000000060
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
      0000000000000000000000000000000000000000000000000000FEFEFE01FEFE
      FE01FCFCFC03FBFBFB04FAFAFA05F9F9F906FAFAFA05FAFAFA05F7F7F708F2F2
      F20DE5E5E51AC0C1C151686C6ADCB7B9B8670000000000000000FEFEFE01FEFE
      FE01FCFCFC03FBFBFB04FAFAFA05F9F9F906FAFAFA05FAFAFA05F7F7F708F2F2
      F20DE5E5E51AC0C1C151686C6ADCB7B9B8670000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000F1EEED35D9D1D0ADF9F8F70F000000000000
      00000000000000000000000000000000000000000000FDFDFD02FAFAFA05F7F7
      F708EFEFEF10EBEBEB14E7E7E718E1E1E11EDEDEDE21D9D9D926D4D4D42BCFCF
      CF30585C5AF5777A79FF848A87FF707472D800000000FDFDFD02FAFAFA05F7F7
      F708EFEFEF10EBEBEB14E7E7E718E1E1E11EDEDEDE21D9D9D926D4D4D42BCFCF
      CF30585C5AF5777A79FF848A87FF707472D800000000E3E3E31CB3B3B35E8B91
      8FFD8B908EFF8B908EFF8A908DFF8A8F8DFF8A8F8DFF898E8CFF898E8CFF888D
      8BFF898E8CFDB2B3B25EE3E3E31C000000000000000000000000000000000000
      0000000000000000000000000000BCB2B1B2FAF4F2FFE1DBDB45000000000000
      00000000000000000000000000000000000000000000FCFCFC03F9F9F906F5F5
      F50AECECEC13E8E8E817E3E3E31CDBDBDB24D7D7D728CFCFCF30CBCBCB34ADAE
      AE65777A79FF848A87FFBCBFBDFFD7D8D83A00000000FCFCFC03F9F9F906F5F5
      F50AECECEC13E8E8E817E3E3E31CDBDBDB24D7D7D728CFCFCF30CBCBCB34ADAE
      AE65777A79FF848A87FFBCBFBDFFD7D8D83A00000000F8F8F807AAAEACB9FEFE
      FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFEFEFEFFA7ABAAB9F8F8F807000000000000000000000000000000000000
      0000000000000000000000000000B9AFAEB2F6EEECFFDED9D845000000000000
      00000000000000000000000000000000000000000000FDFDFD02FAFAFA05F5F5
      F50AB8BAB98CA1A5A2C98D908FF49FA29FCCAEB0AF96CFCFCF30C7C7C73C5A5D
      5BF6848A87FFBCBFBDFF656967F40000000000000000FDFDFD02FAFAFA05F5F5
      F50AB8BAB98CA1A5A2C98D908FF49FA29FCCAEB0AF96CFCFCF30C7C7C73C5A5D
      5BF6848A87FFBCBFBDFF656967F4000000000000000000000000909593FFEAED
      ECFFEBEEEDFFEDEFEFFFEEF0EFFFF0F2F1FFF1F3F2FFF2F4F3FFF2F4F3FFF1F3
      F2FFF0F2F2FF8B908EFF00000000000000000000000000000000000000000000
      0000000000000000000000000000BBB1AFA3E4D6D5FFCEC9C84B000000000000
      00000000000000000000000000000000000000000000E1E2E23D929593EDCAC5
      C0FBE9E1D7FFEADBCDFFE8D6C4FFEADBCDFFEAE2D8FFCAC6C0FB898D8AFA9FA5
      A2FF666967F3D5D6D63D000000000000000000000000E1E2E23D929593EDCAC5
      C0FBE9E1D7FFEADBCDFFE8D6C4FFEADBCDFFEAE2D8FFCAC6C0FB898D8AFA9FA5
      A2FF666967F3D5D6D63D00000000000000000000000000000000919694FFEAED
      ECFF858A88FF858A88FF858A88FF858A88FF000000FFC3D6EDFFF4F5F5FFF2F3
      F3FFF1F3F2FF8C9290FF00000000000000000000000000000000000000000000
      0000000000000000000000000000C9BBBBF2DED1D0FF988C8CB5000000000000
      00000000000000000000000000000000000000000000929592EDE1DED8FFEAE4
      DEFFE4C9B0FFE4CAB2FFE5CBB3FFE5CBB3FFE4CAB2FFEAE5DFFFE2DED9FF898D
      8AFAF5F5F50E00000000000000000000000000000000929592EDE1DED8FFEAE4
      DEFFE4C9B0FFE4CAB2FFE5CBB3FFE5CBB3FFE4CAB2FFEAE5DFFFE2DED9FF898D
      8AFAF5F5F50E0000000000000000000000000000000000000000939997FFE8EB
      EAFFE9ECEBFFEBEEEDFFECEEEDFFEDEFEFFFEDF0EFFF3EAFFCFF0079F5FFEEF0
      EFFFEDF0EFFF8F9492FF00000000000000000000000000000000000000000000
      00000000000000000000D3CDCD65E9DCDCFFD1C3C3FFC2B3B3FF847575E50000
      00000000000000000000000000000000000000000000C8C2BBFBE9E2DBFFDFC0
      A2FFE0C2A6FFD2AC8BFFBB8960FFD2AD8CFFE1C3A8FFE0C1A5FFE9E3DCFFC8C2
      BBFB0000000000000000000000000000000000000000C8C2BBFBE9E2DBFFDFC0
      A2FFE0C2A6FFE1C3A8FFE1C4A9FFE1C4A9FFE1C3A8FFE0C1A5FFE9E3DCFFC8C2
      BBFB000000000000000000000000000000000000000000000000959A98FFE6EA
      E9FF858A88FF858A88FF858A88FF858A88FF858A88FF00D4F5FF3EAFFCFF005C
      CEFFBCD0E6FF909693FFFEFEFE01000000000000000000000000000000000000
      000000000000EFECED20CFC2C2EDEADEDDFFD8CBCAFFE6D9D8FFA69695FF0000
      000000000000000000000000000000000000C1C3C183E2D2C1FFD7B08BFFD8B2
      8EFFD9B491FFB47D51FFF4E9DFFFB47D51FFDAB593FFD9B390FFD8B28EFFE2D3
      C3FFC1C3C183000000000000000000000000C1C3C183E2D2C1FFD7B08BFFD8B2
      8EFFD9B491FFDAB593FFDAB693FFDAB693FFDAB593FFD9B390FFD8B28EFFE2D3
      C3FFC1C3C1830000000000000000000000000000000000000000979D9AFFE2E7
      E5FFE3E7E5FFE4E8E6FFE4E8E7FFE5E9E7FFE5E9E7FFE5E9E8FF005CCEFF3EAF
      FCFF0079F5FF5D82AAFF000000000000000000000000C7BFBF89D6CECCDCD9D1
      D06F00000000DCCECFFFFFF6F6FFDBCECDFFD1C3C2FFE5D9D7FFDACCCCFF7E6F
      70E1F2F1F114000000000000000000000000A5A6A2C4DCBFA4FFD4A981FFCA9B
      72FFB47E52FFB57F54FFF5EBE1FFB47D50FFB37C4FFFC99B71FFD5AB84FFDDC0
      A5FFA5A6A2C4000000000000000000000000A5A6A2C4DCBFA4FFD4A981FFCA9B
      72FFB47E52FFB57F54FFB57F53FFB47D50FFB37C4FFFC99B71FFD5AB84FFDDC0
      A5FFA5A6A2C40000000000000000000000000000000000000000989E9CFFE0E5
      E2FF858A88FF858A88FF858A88FF858A88FF858A88FF858A88FF858A88FF00D4
      F5FF3EAFFCFF005CCEFF82AFE67D0000000000000000E5DDDBA3FDFCFB35D0C4
      C3AA9A919091F6ECECFFFCF3F2FFD0C2C1FFCBBDBCFFE6D9D8FFD5C7C5FF7E6C
      6CFF9F95969E0000000000000000000000008E908DF2D9B796FFE4C9B0FFBC8B
      63FFF7EFE7FFF7EFE7FFF7EEE7FFF6EDE5FFF5ECE3FFB9865BFFDAB593FFD5AF
      8BFF8E908DF20000000000000000000000008E908DF2D9B796FFE4C9B0FFBC8B
      63FFF7EFE7FFF7EFE7FFF7EEE7FFF6EDE5FFF5ECE3FFB9865BFFDAB593FFD5AF
      8BFF8E908DF200000000000000000000000000000000000000009BA19EFFE0E4
      E3FFE0E5E2FFE0E4E2FFDFE5E2FFDEE3E1FFDEE3E0FFDDE2E0FFDDE2E0FFDDE2
      E0FF005CCEFF3EAFFCFF0079F5FF0000000000000000FAFAF90900000000CFCA
      CA48B09E9EFFFBF2F1FFFFFDFBFFC4B6B4FFC5B7B6FFF1E6E5FFCEBFBDFFA08E
      8DFF6F5E5DFFF8F7F7090000000000000000A5A6A1C4DCBFA3FFE6CDB5FFD6B4
      97FFB8855CFFB8845CFFF7F0E9FFB78258FFB68157FFD0A784FFDDBA9AFFDBBD
      A1FFA5A6A1C4000000000000000000000000A5A6A1C4DCBFA3FFE6CDB5FFD6B4
      97FFB8855CFFB8845CFFB7845BFFB78258FFB68157FFD0A784FFDDBA9AFFDBBD
      A1FFA5A6A1C400000000000000000000000000000000000000009CA29FFFE0E5
      E3FF858A88FF858A88FF858A88FF858A88FF858A88FF858A88FF858A88FF858A
      88FF949695FF00D4F5FF3EAFFCFF0000000000000000DED8D79CEBE6E5598E7D
      7CE6D3C3C4FFFEFBFAFFFFFEFEFFCABCBBFFC9BBBAFFFBF4F3FFD3C4C2FFA08D
      8BFF806E6DFF9C9596890000000000000000C1C2C183DFCBB8FFE4CAB1FFE8D1
      BCFFEAD5C1FFB8865EFFF8F1EBFFB7835AFFE3C7ADFFE0C1A3FFDDBC9CFFDFCB
      B8FFC1C2C183000000000000000000000000C1C2C183DFCBB8FFE4CAB1FFE8D1
      BCFFEAD5C1FFE9D3BFFFE8D1BBFFE5CAB2FFE3C7ADFFE0C1A3FFDDBC9CFFDFCB
      B8FFC1C2C18300000000000000000000000000000000000000009EA5A2FFE2E7
      E4FFE2E6E4FFE0E5E3FFE0E5E2FFDDE3E0FFDCE1DFFFD9DFDDFFB9BEBCFFFFFF
      FFFFFDFDFDFFE8E9E83A00000000000000000000000000000000DDDBDB30E7DB
      D9FFFFFCFBFFF2EFEEFFE8E1E0FFC5B7B6FFD1C3C2FFE5DBDAFFD8CCCBFFAE9E
      A0FF938284FF5C4B4FFF796E70CE0000000000000000C5BDB2FBE6DBD0FFDCBA
      99FFE8D1BBFFD7B69AFFBD8D66FFD6B294FFE4C9B0FFDAB794FFE6DBD0FFC5BD
      B2FB0000000000000000000000000000000000000000C5BDB2FBE6DBD0FFDCBA
      99FFE8D1BBFFE8D1BCFFE8D1BBFFE6CCB4FFE4C9B0FFDAB794FFE6DBD0FFC5BD
      B2FB000000000000000000000000000000000000000000000000A0A6A3FFE4E8
      E6FF858A88FF858A88FF858A88FF858A88FF858A88FFD4DBD7FFBBC0BDFFFFFF
      FFFFCBCECCFBFEFEFE0200000000000000000000000000000000A298989BE5DA
      D8FFF8F2F2FFEFE8E8FFF4EEEDFFFFFCFCFFFCFAFAFFE0D8D6FFF0EBEAFFDBD3
      D4FFCFC7C8FF514145FF7D6E73FF0000000000000000919490EDDED7CEFFE6DB
      D0FFE3C7ADFFE5CCB4FFE5CCB4FFE4CAB0FFE2C5A9FFE6DBD0FFDED7CEFF9194
      90ED0000000000000000000000000000000000000000919490EDDED7CEFFE6DB
      D0FFE3C7ADFFE5CCB4FFE5CCB4FFE4CAB0FFE2C5A9FFE6DBD0FFDED7CEFF9194
      90ED000000000000000000000000000000000000000000000000A3AAA7FCEBEF
      EDFFE7EBE9FFE4E8E6FFE2E7E4FFE1E6E4FFE6EAE8FFE9EAEAFFF5F6F5FFAEB4
      B1D8F7F8F8130000000000000000000000000000000000000000BAB2B4C7A18C
      88FFA69694FFA59797FFAEA1A0FFB9B3B4FFB7B1B1FF8D7D7CFFA69999FFAEA4
      A4FF928281FF93817EFFD3CCCCFF0000000000000000E2E3E33C919490EDC5BD
      B2FBDFCCB8FFDCBFA3FFD9B897FFDCBFA4FFDFCCB8FFC5BDB2FB919490EDE2E3
      E33C0000000000000000000000000000000000000000E2E3E33C919490EDC5BD
      B2FBDFCCB8FFDCBFA3FFD9B897FFDCBFA4FFDFCCB8FFC5BDB2FB919490EDE2E3
      E33C000000000000000000000000000000000000000000000000C2C7C5AEFEFE
      FEFFFFFFFFFFFFFFFFFFFFFFFFFFFCFCFCFFF0F2F1FFD0D4D2F8AAAFADE9FEFE
      FE02000000000000000000000000000000000000000000000000F0EFEF25D9D1
      D1ECCBC2C3FDA59797FFAEA1A0FFB9B3B4FFB7B1B1FF8D7D7CFFA69999FFB2AA
      A9FFABA1A0FFDED8D8E3BDB7B88D000000000000000000000000000000000000
      0000C1C2C183A5A6A1C48E908DF2A5A6A1C4C1C2C18300000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C1C2C183A5A6A1C48E908DF2A5A6A1C4C1C2C18300000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000EEEDED15B6B0B276A09899A29C9294B79F9597B99D9395B59D9497ABCECB
      CB3FEEEDED150000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000800000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008000
      0000C0C0C0008000000080000000000000000000000000000000000000000000
      0000000000000000000000000000000000008000000080000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000080000000C0C0
      C000800000008000000080000000000000000000000000000000000000000000
      0000000000000000000000000000800000008000000080000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0000000
      0000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000800000008000
      0000800000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080000000C0C0C0008000
      0000800000008000000000000000000000000000000000000000000000000000
      0000000000000000000080000000800000008000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000800000008000
      0000800000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080000000C0C0C000800000008000
      000080000000000000000000000000000000000000000000000080808000C0C0
      C000FFFFFF008080800000000000800000000000000000000000000000000000
      00000000800000000000000000000000000000000000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C00000FFFF0000FFFF0000FFFF00C0C0C000C0C0
      C000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C0C0C000C0C0C000C0C0C000FFFFFF008080800080000000800000008000
      0000000000000000000000000000000000000000000080808000C0C0C000C0C0
      C000C0C0C000FFFFFF0080808000000000000000000000000000000000000000
      80000000800000000000000000000000000000000000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000808080008080800080808000C0C0C000C0C0
      C00000000000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000800000008000
      000080000000000000000000000000000000000000000000000080808000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000FFFFFF0080808000000000000000
      00000000000000000000000000000000000000000000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000FFFFFF00000000000000000000000000000080000000
      8000000080000000800000008000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C0C0C000C0C0C000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000800000008000
      0000800000000000000000000000000000000000000000000000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000FFFFFF00000000000000
      00000000000000000000000000000000000000000000C0C0C000FFFFFF00FFFF
      0000C0C0C000C0C0C000C0C0C000000000000000000000000000000000000000
      80000000800000000000000000000000800000000000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0000000
      0000C0C0C00000000000C0C0C000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008000
      00008000000080000000000000000000000000000000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0000000
      0000000000000000000000000000000000000000000080808000FFFFFF00FFFF
      FF00C0C0C000C0C0C00080808000000000000000000000000000000000000000
      0000000080000000000000000000000080000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C0C0
      C00000000000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00008000000080000000800000000000000000000000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0000000
      000000000000000000000000000000000000000000000000000080808000C0C0
      C000C0C0C0008080800000000000000000000000000000000000000000000000
      000000000000000000000000000000008000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000C0C0C00000000000C0C0C000000000000000000000000000000000000000
      0000000000000000000000000000800000008000000080000000000000000000
      00000000000080000000800000008000000000000000C0C0C000FFFFFF00FFFF
      0000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000008000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000008000000080000000000000000000
      00000000000080000000800000008000000000000000C0C0C000FFFFFF00FFFF
      0000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000008000000000000000
      0000000080000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000008000000080000000000000000000
      0000000000008000000080000000800000000000000000000000FFFFFF00FFFF
      FF00FFFF0000FFFF0000C0C0C000C0C0C000C0C0C000C0C0C000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000008000000000000000
      0000000080000000800000000000000000000000000000000000000000000000
      000000000000FFFFFF000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008000000080000000800000008000
      000080000000800000008000000000000000000000000000000080808000FFFF
      FF00FFFFFF00FFFFFF00C0C0C000C0C0C000C0C0C00080808000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000080000000
      8000000080000000800000008000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080000000800000008000
      0000800000008000000000000000000000000000000000000000000000000000
      0000C0C0C000C0C0C000C0C0C000C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000080000000800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000080000000000000000000000000000000000000000000000000000000
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
      0000000000000000000000000000000000000000000000000000008080000080
      8000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C0000000000000808000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000840084008400840084848400000000000000
      0000000000000000000000000000000000000000000000000000008080000080
      8000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C0000000000000808000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008400840084008400FFFFFF00FFFFFF00C6C6C600848484000000
      0000000000000000000000000000000000000000000000000000008080000080
      8000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C0000000000000808000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000080808000C0C0C000C0C0C0008080
      80000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000008400
      840084008400FFFFFF00FFFFFF000000000000000000C6C6C600C6C6C6008484
      8400000000000000000000000000000000000000000000000000008080000080
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000808000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000080808000C0C0C000C0C0C000FFFF00008080
      80008080800000000000000000000000000000000000FFFFFF00000000000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      000000000000000000000000000000000000848484008400840084008400FFFF
      FF00FFFFFF000000000000000000840084008400840000000000C6C6C600C6C6
      C600848484000000000000000000000000000000000000000000008080000080
      8000008080000080800000808000008080000080800000808000008080000080
      80000080800000808000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000C0C0C000C0C0C000C0C0C000C0C0C0008080
      8000C0C0C00000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000008484840084008400FFFFFF000000
      000000000000840084008400840084008400840084008400840000000000C6C6
      C600C6C6C6008484840000000000000000000000000000000000008080000080
      8000000000000000000000000000000000000000000000000000000000000000
      00000080800000808000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000C0C0C000FFFF0000C0C0C000C0C0C0008080
      8000C0C0C00000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF000000
      0000000000000000000000000000000000008484840000000000000000008400
      840084008400840084000084840000FFFF008400840084008400840084000000
      0000C6C6C600C6C6C60084848400000000000000000000000000008080000000
      0000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C0000000000000808000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000080808000FFFF0000FFFF0000C0C0C0008080
      80008080800000000000000000000000000000000000FFFFFF00000000000000
      0000FFFFFF00FFFFFF00FFFFFF0000000000C0C0C00000000000FFFFFF000000
      0000000000000000000000000000000000008484840084008400840084008400
      8400840084008400840084008400008484008400840084008400840084008400
      840000000000C6C6C60000000000000000000000000000000000008080000000
      0000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C0000000000000808000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000080808000C0C0C000C0C0C0008080
      80000000000000000000000000000000000000000000FFFFFF0000000000C0C0
      C00000000000FFFFFF0000000000C0C0C00000000000C0C0C000000000000000
      0000000000000000000080000000800000000000000084008400FFFFFF008400
      84008400840084008400840084008400840000FFFF0000FFFF00840084008400
      8400840084000000000000000000000000000000000000000000008080000000
      0000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C0000000000000808000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF000000
      0000C0C0C00000000000C0C0C00000000000C0C0C00000000000C0C0C000C0C0
      C000C0C0C000000000008000000080000000000000000000000084008400FFFF
      FF0084008400840084008400840084008400840084000084840000FFFF0000FF
      FF00840084008400840000000000000000000000000000000000008080000000
      0000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C0000000000000808000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C0C0C00000000000C0C0C00000000000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C00080000000800000000000000000000000000000008400
      8400FFFFFF00840084008400840084008400008484008400840000FFFF0000FF
      FF00840084008400840084008400000000000000000000000000008080000000
      0000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C0000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000C0C0C00000000000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C00080000000800000000000000000000000000000000000
      000084008400FFFFFF00840084008400840000FFFF0000FFFF0000FFFF008400
      8400840084008400840000000000000000000000000000000000008080000000
      0000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C00000000000C0C0C000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000C0C0C000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C0000000000080000000800000000000000000000000000000000000
      00000000000084008400FFFFFF00840084008400840084008400840084008400
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080000000800000000000000000000000000000000000
      0000000000000000000084008400FFFFFF008400840084008400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000840084008400840000000000000000000000
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
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000008080000080
      8000008080000080800000808000008080000080800000808000008080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000FFFF00000000000080
      8000008080000080800000808000008080000080800000808000008080000080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF000000000000000000000000000000000000000000FFFFFF0000FFFF000000
      0000008080000080800000808000008080000080800000808000008080000080
      80000080800000000000000000000000000000000000000000007F5B00000000
      0000000000000000000000000000000000000000000064490400644904006449
      0400644904006449040000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF00000000000080800000808000008080000080800000808000008080000080
      80000080800000808000000000000000000000000000000000007F5B00000000
      0000000000000000000000000000000000000000000000000000916B0A007F5B
      00007F5B0000916B0A0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF000000000000000000000000000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000007F5B00000000
      0000000000000000000000000000000000000000000000000000D9A77D00916B
      0A007F5B0000916B0A0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00000000000000
      00000000000000000000000000000000000000000000000000007F5B0000D9A7
      7D000000000000000000000000000000000000000000D9A77D007F5B0000D9A7
      7D00916B0A00916B0A0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF000000000000000000000000000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000D9A77D007F5B
      0000D9A77D000000000000000000D9A77D007F5B00007F5B0000D9A77D000000
      000000000000916B0A0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000D9A7
      7D007F5B00007F5B00007F5B00007F5B0000D9A77D0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000000000000000
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
      0000000000008000000080000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080000000800000008000000080000000800000008000
      0000800000008000000080000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000800000000000000000000000800000000000000000000000800000008000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000008000000080000000800000008000
      0000800000008000000080000000800000000000000000000000000000000000
      0000000000000000000080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000800000000000000000000000800000000000000080000000000000000000
      0000800000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000080000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00800000000000000080808000008080008080
      8000008080008080800080000000FFFFFF000000000000000000000000000000
      00000000000000000000FFFFFF00800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000800000000000000000000000800000000000000080000000000000000000
      0000800000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000080000000FFFFFF0000000000000000000000
      00000000000000000000FFFFFF00800000000000000000808000808080000080
      8000808080000080800080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000080000000800000000000000080000000000000000000
      0000800000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000080000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00800000000000000080808000008080008080
      8000008080008080800080000000FFFFFF00000000000000000000000000FFFF
      FF00800000008000000080000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000080000000800000008000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0080000000FFFFFF0000000000000000000000
      00000000000000000000FFFFFF00800000000000000000808000808080000080
      8000808080000080800080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080000000FFFFFF0080000000000000000000000000000000644904006449
      0400644904006449040064490400000000000000000000000000000000000000
      0000000000007F5B000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000080000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      000000000000000000000000000080000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00800000000000000080808000008080008080
      8000008080008080800080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00800000008000000000000000000000000000000000000000916B0A007F5B
      00007F5B0000916B0A0000000000000000000000000000000000000000000000
      0000000000007F5B000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0080000000FFFFFF000000000000000000FFFF
      FF00800000008000000080000000800000000000000000808000808080000080
      8000808080000080800080000000800000008000000080000000800000008000
      0000800000000000000000000000000000000000000000000000916B0A007F5B
      0000916B0A00D9A77D0000000000000000000000000000000000000000000000
      0000000000007F5B000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      000000000000000000000000000080000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080000000FFFFFF0080000000000000000000000080808000008080008080
      8000008080008080800000808000808080000080800080808000008080008080
      8000008080000000000000000000000000000000000000000000916B0A00916B
      0A00D9A77D007F5B0000D9A77D00000000000000000000000000000000000000
      0000D9A77D007F5B000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0080000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00800000008000000000000000000000000000000000808000808080000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000808080000000000000000000000000000000000000000000916B0A000000
      000000000000D9A77D007F5B00007F5B0000D9A77D000000000000000000D9A7
      7D007F5B0000D9A77D0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      000000000000FFFFFF0000000000800000008000000080000000800000008000
      0000800000000000000000000000000000000000000080808000808080000000
      0000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000000000008080
      8000008080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000D9A77D007F5B00007F5B00007F5B00007F5B
      0000D9A77D000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000808000808080000080
      80000000000000FFFF00000000000000000000FFFF0000000000808080000080
      8000808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000FFFF0000FFFF000000000000000000000000000000
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
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000600000000100010000000000000300000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000C000C000FFFFFE3F800080008001FE3F
      800080008001FE3F80018001C003FE3F80038003C003FE3F80078007C003FC1F
      800F800FC001F81F00070007C003880700070007C001800700070007C001A003
      00070007C001800300070007C003C001800F800FC003C001800F800FC007C001
      800F800FC00FC001F07FF07FFFFFF007FFFFFFF3FFFFFFFFF9FFFFE1FF3FC007
      F9FFFFC1FE3F8003F3C7FF83C07F000173C7F00780F7000127FFC00F00E70001
      07C7801F00C1000000C7801F00E6000001E3000F00F6800003F1000F81FEC000
      0638000FC3BFE0010E38000FFFB7E0071E38801FFFB3F0073F01801FFFC1F003
      7F83C03FFFF3F803FFFFF0FFFFF7FFFFFFFFFFFFFFFFFFFFC001000C000FFE3F
      80010008000FF81F80010001000FE00F80010003000F800780010003000F0003
      80010003000F000180010003000F000080010003000F00018001000700048001
      8001000F0000C0018001000F0000E0008001000FF800F0008001001FFC00F803
      8001003FFE04FC0FFFFF007FFFFFFE3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFEFFDC007001FFFFFC7FFC007000FFFFFC3FBC0070007FFFFE3F7C0070003
      DF83F1E7C0070001DFC3F8CFC0070000DFC3FC1FC007001FCF83FE3FC007001F
      C61BFC1FC007001FE07FF8CFC0078FF1FFFFE1E7C00FFFF9FFFFC3F3C01FFF75
      FFFFC7FDC03FFF8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9FFFFFFFC00FFFF
      F6CFFE008000FFFFF6B7FE000000FFFFF6B7FE000000FFFFF8B780000000FFFF
      FE8F80000001C1FBFE3F80000003C3FBFF7F80000003C3FBFE3F80010003C1F3
      FEBF80030003D863FC9F80070003FE07FDDF807F0003FFFFFDDF80FF8007FFFF
      FDDF81FFF87FFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000
      000000000000}
  end
  object dlgOpen: TOpenDialog
    Options = [ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'User-Datei '#246'ffnen'
    Left = 208
    Top = 486
  end
  object dlgSave: TSaveDialog
    Left = 208
    Top = 410
  end
  object ApplicationEvents: TApplicationEvents
    OnActivate = ApplicationEventsActivate
    Left = 211
    Top = 94
  end
  object PopupMenuId: TPopupMenu
    OnPopup = PopupMenuIdPopup
    Left = 32
    Top = 78
    object PopupItmIdGoto: TMenuItem
      Caption = 'Goto'
      OnClick = PopupItmIdGotoClick
    end
    object N13: TMenuItem
      Caption = '-'
    end
    object PopupItmIdCopy: TMenuItem
      Caption = 'Copy Name'
      OnClick = PopupItmIdCopyClick
    end
    object PopupItmIdCopyLong: TMenuItem
      Caption = 'Copy Name qualified'
      OnClick = PopupItmIdCopyLongClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object pItmIdFilterName: TMenuItem
      Action = actIdFilterName
      Caption = 'Fillter "exact Name"'
    end
    object pItmIdFilterHierarchy: TMenuItem
      Action = actIdFilterHierarchy
      Caption = 'Filter "Hierarchy"'
    end
    object pItmIdSetFilter: TMenuItem
      Action = actIdSetFilter
      Caption = 'Filter ...'
    end
    object N8: TMenuItem
      Caption = '-'
    end
    object pItmIdReduce: TMenuItem
      Action = actIdReduce
      Caption = 'Reduce visible Ids'
    end
    object PopupItmIdSort: TMenuItem
      Caption = 'Sort Sub-Ids (no undo!)'
      Enabled = False
      OnClick = PopupItmIdSortClick
    end
    object PopupItmIdRename: TMenuItem
      Caption = 'Rename'
      OnClick = PopupItmIdRenameClick
    end
  end
  object PopupMenuAc: TPopupMenu
    OnPopup = PopupMenuAcPopup
    Left = 319
    Top = 54
    object PopupItmAcGoto: TMenuItem
      Caption = 'Goto Id'
      OnClick = PopupItmAcGotoClick
    end
    object PopupItmAcGotoUsingId: TMenuItem
      Caption = 'Goto using Id'
      OnClick = PopupItmAcGotoUsingIdClick
    end
    object N14: TMenuItem
      Caption = '-'
    end
    object PopupItmAcNassi: TMenuItem
      Caption = 'Show as Nassi'
      OnClick = PopupItmAcNassiClick
    end
    object PopupItmAcFileViewer: TMenuItem
      Caption = 'Show in FileViewer'
      OnClick = PopupItmAcFileViewerClick
    end
    object N9: TMenuItem
      Caption = '-'
    end
    object PopupItmAcCopy: TMenuItem
      Caption = 'Copy Line'
      OnClick = PopupItmAcCopyClick
    end
    object PopupItmAcCopyLong: TMenuItem
      Caption = 'Copy Line++'
      OnClick = PopupItmAcCopyLongClick
    end
  end
  object PopupMenuFile: TPopupMenu
    OnPopup = PopupMenuFilePopup
    Left = 1171
    Top = 102
    object PopupItmFileView: TMenuItem
      Caption = 'Show in FileViewer'
      OnClick = PopupItmFileViewClick
    end
    object PopupItmFileDefines: TMenuItem
      Caption = 'Compiler-Defines'
      Enabled = False
    end
    object PopupItmFileOptions: TMenuItem
      Caption = 'Compiler-Options'
      Enabled = False
    end
  end
end
