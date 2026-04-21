
unit ufFileOptions;

{$INCLUDE _CompilerOptions.pas}
{ $UNDEF TraceDx}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Buttons, Vcl.Mask;

type
  TfrmFileOptions = class(TForm)
    edtSearchPathUnit: TLabeledEdit;
    BtnOkay: TBitBtn;
    BtnCancel: TBitBtn;
    edtDefinedSymbols: TLabeledEdit;
    edtUnitPrefix: TLabeledEdit;
    edtSearchPathUnitLib: TLabeledEdit;
    chkBoxKeywords: TCheckBox;
    chkBoxKeySymbols: TCheckBox;
    chkBoxParseFormsFiles: TCheckBox;
    chkBoxUseSystemRef: TCheckBox;
    chkBoxLongStrings: TCheckBox;
    cmbBoxPlatform: TComboBox;
    lblPlatform: TLabel;
    cmbBoxVersion: TComboBox;
    lblVersion: TLabel;
    cmbBoxBuild: TComboBox;
    lblBuild: TLabel;
    MemoDefineHint: TMemo;
    edtSearchPathDelphi: TLabeledEdit;
    chkBoxDelphiLibs: TCheckBox;
    chkBoxUnitPrefix: TCheckBox;
    chkBoxHideLibraryInternals: TCheckBox;
    btnResetDelphiLibs: TButton;
    btnResetNamespace: TButton;
    edtPathMacros: TLabeledEdit;
    procedure FormShow(Sender: TObject);
    procedure chkBoxDelphiLibsClick(Sender: TObject);
    procedure chkBoxUnitPrefixClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnResetNamespaceClick(Sender: TObject);
    procedure btnResetDelphiLibsClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  frmFileOptions: TfrmFileOptions;

implementation

{$R *.dfm}

uses
  uDataIO;

procedure TfrmFileOptions.btnResetDelphiLibsClick(Sender: TObject);
begin
  if chkBoxDelphiLibs.Checked then begin
    edtSearchPathDelphi.Text := OptionLibPaths;
    edtSearchPathDelphi.Modified := true
    end
end;

procedure TfrmFileOptions.chkBoxDelphiLibsClick( Sender: TObject );
begin
  edtSearchPathDelphi.Enabled := chkBoxDelphiLibs.Checked;
  if chkBoxDelphiLibs.Checked then
    edtSearchPathDelphi.Modified := true
end;

procedure TfrmFileOptions.btnResetNamespaceClick(Sender: TObject);
begin
  if chkBoxUnitPrefix.Checked then begin
    edtUnitPrefix.Text := OptionNamespace;
    edtUnitPrefix.Modified := true
    end
end;

procedure TfrmFileOptions.chkBoxUnitPrefixClick( Sender: TObject );
begin
  edtUnitPrefix.Enabled := chkBoxUnitPrefix.Checked;
  if chkBoxUnitPrefix.Checked then
    edtUnitPrefix.Modified := true
end;

procedure TfrmFileOptions.FormCreate(Sender: TObject);
begin
{$IFDEF UnitPrefixe}
  chkBoxUnitPrefix.Enabled := true
{$ENDIF}
end;

procedure TfrmFileOptions.FormShow( Sender: TObject );
begin
  MemoDefineHint.Perform( EM_LINESCROLL, 0, - MemoDefineHint.Perform( EM_GETFIRSTVISIBLELINE, 0, 0 ))
end;

end.

