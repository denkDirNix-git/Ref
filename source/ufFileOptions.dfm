object frmFileOptions: TfrmFileOptions
  Left = 0
  Top = 0
  ActiveControl = edtSearchPathUnitLib
  BorderIcons = []
  ClientHeight = 918
  ClientWidth = 732
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -20
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poMainFormCenter
  ShowHint = True
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 120
  DesignSize = (
    732
    918)
  TextHeight = 24
  object lblPlatform: TLabel
    Left = 30
    Top = 518
    Width = 75
    Height = 24
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Platform'
  end
  object lblVersion: TLabel
    Left = 261
    Top = 518
    Width = 66
    Height = 24
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Version'
  end
  object lblBuild: TLabel
    Left = 503
    Top = 518
    Width = 44
    Height = 24
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Build'
  end
  object edtSearchPathUnit: TLabeledEdit
    Left = 30
    Top = 275
    Width = 654
    Height = 32
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 220
    EditLabel.Height = 24
    EditLabel.Margins.Left = 4
    EditLabel.Margins.Top = 4
    EditLabel.Margins.Right = 4
    EditLabel.Margins.Bottom = 4
    EditLabel.Caption = 'SearchPath Project-Units'
    LabelSpacing = 2
    TabOrder = 4
    Text = ''
  end
  object BtnOkay: TBitBtn
    Left = 534
    Top = 844
    Width = 150
    Height = 41
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akRight, akBottom]
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 20
  end
  object BtnCancel: TBitBtn
    Left = 354
    Top = 844
    Width = 151
    Height = 41
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akRight, akBottom]
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 19
  end
  object edtDefinedSymbols: TLabeledEdit
    Left = 30
    Top = 452
    Width = 654
    Height = 32
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 149
    EditLabel.Height = 24
    EditLabel.Margins.Left = 4
    EditLabel.Margins.Top = 4
    EditLabel.Margins.Right = 4
    EditLabel.Margins.Bottom = 4
    EditLabel.Caption = 'Defined Symbols'
    LabelSpacing = 2
    TabOrder = 8
    Text = ''
  end
  object edtUnitPrefix: TLabeledEdit
    Left = 30
    Top = 363
    Width = 654
    Height = 32
    Hint = 'copied from global Options'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 113
    EditLabel.Height = 24
    EditLabel.Margins.Left = 4
    EditLabel.Margins.Top = 4
    EditLabel.Margins.Right = 4
    EditLabel.Margins.Bottom = 4
    EditLabel.Caption = 'Unit-Prefixes'
    Enabled = False
    LabelSpacing = 2
    TabOrder = 5
    Text = ''
  end
  object edtSearchPathUnitLib: TLabeledEdit
    Left = 30
    Top = 192
    Width = 654
    Height = 32
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 420
    EditLabel.Height = 24
    EditLabel.Margins.Left = 4
    EditLabel.Margins.Top = 4
    EditLabel.Margins.Right = 4
    EditLabel.Margins.Bottom = 4
    EditLabel.Caption = 'SearchPath Project-Units (parse Interface only)'
    LabelSpacing = 2
    TabOrder = 3
    Text = ''
  end
  object chkBoxKeywords: TCheckBox
    Left = 30
    Top = 698
    Width = 191
    Height = 36
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akBottom]
    Caption = 'Collect Keywords'
    TabOrder = 13
    ExplicitTop = 697
  end
  object chkBoxKeySymbols: TCheckBox
    Left = 280
    Top = 698
    Width = 191
    Height = 36
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akBottom]
    Caption = 'Collect KeySymbols'
    TabOrder = 14
    ExplicitTop = 697
  end
  object chkBoxParseFormsFiles: TCheckBox
    Left = 30
    Top = 741
    Width = 209
    Height = 37
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akBottom]
    Caption = 'Parse Formular-Files'
    Checked = True
    State = cbChecked
    TabOrder = 15
    ExplicitTop = 740
  end
  object chkBoxUseSystemRef: TCheckBox
    Left = 280
    Top = 785
    Width = 209
    Height = 36
    Hint = 'in addition to built-in System.pas'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akBottom]
    Caption = 'Use System_Ref.pas'
    TabOrder = 18
    ExplicitTop = 784
  end
  object chkBoxLongStrings: TCheckBox
    Left = 30
    Top = 785
    Width = 209
    Height = 36
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akBottom]
    Caption = 'long Strings ($H+)'
    Checked = True
    State = cbChecked
    TabOrder = 17
    ExplicitTop = 784
  end
  object cmbBoxPlatform: TComboBox
    Left = 30
    Top = 548
    Width = 181
    Height = 32
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    TabOrder = 9
    Text = 'MSWINDOWS'
    Items.Strings = (
      'MSWINDOWS'
      'ANDROID'
      'IOS'
      'MACOS'
      'LINUX'
      'POSIX')
  end
  object cmbBoxVersion: TComboBox
    Left = 261
    Top = 549
    Width = 182
    Height = 32
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    ItemIndex = 29
    TabOrder = 10
    Text = 'VER370'
    Items.Strings = (
      'VER70'
      'VER80'
      'VER90'
      'VER100'
      'VER120'
      'VER130'
      'VER140'
      'VER150'
      'VER160'
      'VER170'
      'VER180'
      'VER190'
      'VER200'
      'VER210'
      'VER220'
      'VER230'
      'VER240'
      'VER250'
      'VER260'
      'VER270'
      'VER280'
      'VER290'
      'VER300'
      'VER310'
      'VER320'
      'VER330'
      'VER340'
      'VER350'
      'VER360'
      'VER370')
  end
  object cmbBoxBuild: TComboBox
    Left = 503
    Top = 549
    Width = 181
    Height = 32
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    ItemIndex = 0
    TabOrder = 11
    Text = 'RELEASE'
    Items.Strings = (
      'RELEASE'
      'DEBUG')
  end
  object MemoDefineHint: TMemo
    Left = 30
    Top = 589
    Width = 654
    Height = 57
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    TabStop = False
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGray
    Font.Height = -14
    Font.Name = 'Tahoma'
    Font.Style = [fsItalic]
    Lines.Strings = (
      
        'The IDE may define some more Symbols (add to "Defined Symbols" i' +
        'f needed):'
      'WIN32 / WIN64'
      'ANDROID32 / ANDROID64'
      'OSX32 / OSX64'
      'MACOS32 / MACOS64'
      'LINUX32 / LINUX64'
      'CPUX86 / CPU386 / CPUX64'
      'CPUARM / CPUARM32 / CPUARM64'
      'CPU32BITS / CPU64BITS'
      'FRAMEWORK_VCL / FRAMEWORK_FMX'
      'ASSEMBLER'
      'UNICODE'
      'AUTOREFCOUNT'
      'CONSOLE'
      'NATIVECODE')
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 12
    WordWrap = False
  end
  object edtSearchPathDelphi: TLabeledEdit
    Left = 30
    Top = 112
    Width = 654
    Height = 32
    Hint = 'copied from global Options'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 430
    EditLabel.Height = 24
    EditLabel.Margins.Left = 4
    EditLabel.Margins.Top = 4
    EditLabel.Margins.Right = 4
    EditLabel.Margins.Bottom = 4
    EditLabel.Caption = 'SearchPath Delphi-Source (parse Interface only)'
    Enabled = False
    LabelSpacing = 2
    TabOrder = 0
    Text = ''
  end
  object chkBoxDelphiLibs: TCheckBox
    Left = 598
    Top = 87
    Width = 86
    Height = 24
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akTop, akRight]
    Caption = 'enable'
    TabOrder = 2
    OnClick = chkBoxDelphiLibsClick
  end
  object chkBoxUnitPrefix: TCheckBox
    Left = 598
    Top = 338
    Width = 86
    Height = 24
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akTop, akRight]
    Caption = 'enable'
    Enabled = False
    TabOrder = 7
    OnClick = chkBoxUnitPrefixClick
  end
  object chkBoxHideLibraryInternals: TCheckBox
    Left = 280
    Top = 741
    Width = 341
    Height = 37
    Hint = 'in addition to built-in System.pas'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akBottom]
    Caption = 'Hide Library-internal Ids and Ref'#39's'
    Checked = True
    State = cbChecked
    TabOrder = 16
    ExplicitTop = 740
  end
  object btnResetDelphiLibs: TButton
    Left = 527
    Top = 87
    Width = 71
    Height = 24
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akTop, akRight]
    Caption = 'Reset'
    TabOrder = 1
    OnClick = btnResetDelphiLibsClick
  end
  object btnResetNamespace: TButton
    Left = 527
    Top = 338
    Width = 71
    Height = 24
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akTop, akRight]
    Caption = 'Reset'
    TabOrder = 6
    OnClick = btnResetNamespaceClick
  end
  object edtPathMacros: TLabeledEdit
    Left = 30
    Top = 32
    Width = 654
    Height = 32
    Hint = 'copied from global Options'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 214
    EditLabel.Height = 24
    EditLabel.Margins.Left = 4
    EditLabel.Margins.Top = 4
    EditLabel.Margins.Right = 4
    EditLabel.Margins.Bottom = 4
    EditLabel.Caption = 'Macros for Search-Paths'
    LabelSpacing = 2
    TabOrder = 21
    Text = ''
  end
end
