unit ufFilter;
{$INCLUDE _CompilerOptions.pas}
{$UNDEF TraceDx}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Buttons;

type
  TfrmFilter = class(TForm)
    cmbBoxName: TComboBox;
    BitBtnFilterCancel: TBitBtn;
    BitBtnFilterOkay: TBitBtn;
    MemoHint1: TMemo;
    lblHint: TLabel;
    MemoHint2: TMemo;
    chkBoxDeclareOnly: TCheckBox;
    radGrpFilter: TRadioGroup;
    cmbBoxTyp: TComboBox;
    lblSelect: TLabel;
    procedure cmbBoxNameEnter(Sender: TObject);
    procedure radGrpFilterClick(Sender: TObject);
    procedure BitBtnFilterOkayClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure cmbBoxTypEnter(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
    procedure PreParse;
  end;

type
  tFilters = ( fiText,
               fiPerType,
               fiUndeclared, fiDeclareOnly,
               fiNoWrites,   fiNoReads,
               fiUnusedUnit, fiUnitCalls,
               fiReferencers,
               fiNonANSI,
               fiHierarchy,
               fiMessages,
               fiGenerics,
               fiOverloads
               );

const ShortCuts = 'NTQDWRNUFAHM';  // PC';   -1{disabled}

var
  frmFilter: TfrmFilter;

implementation

uses
  {$IFDEF TraceDx} TraceDx, {$ENDIF}
  uGlobalsParser;

{$R *.dfm}

  // Selected Filter shows all Identifiers that ...
const cHintText: array[tFilters] of string = (
  // fiText
  '...start with the Search-String.' + sLineBreak +
                                       sLineBreak +
  'Search-Options:'  + sLineBreak  +
  '"." as first char' + sLineBreak +
  '     Id contains SearchString'  + sLineBreak +
                                     sLineBreak +
  '"." as last  char' + sLineBreak +
  '     Id ends with SearchString' + sLineBreak +
                                     sLineBreak +
  'Options can be combined.',

  // fiPerType
  '... match the selected Identifier-Type.',

  // fiUndeclared
  '1. have no Declaration (because of missing file).' + sLineBreak +
                                                        sLineBreak +
  '2. but are qualified (like ClassVar.Method)'       + sLineBreak +
  '    so they don''t appear in <unresolved>-Block.',

  //fiDeclareOnly
  '...are declared but never referenced.'                + sLineBreak +
                                                           sLineBreak +
  'Coloured in gray instead of Identifier-Type-specific' + sLineBreak +
  '(which is the same as in unfiltered View).'           + sLineBreak,
//                                                           sLineBreak +
//  'The Method-"Sender" is very often not referenced, so to minimize the resulting tree you can optionally ignore them.',

  //fiNoWrites,
  '... are of Id-type "Variable" and have reading but no writing References.' + sLineBreak +
                                                               sLineBreak +
   'Parameters are considered only if they are OUT-Parameters.',

  //fiNoReads,
  '... have no reading Reference'                            + sLineBreak +
                                                               sLineBreak +
   'Parameters are considered only if they are not VAR- or OUT-Parameters' + sLineBreak +
                                                                             sLineBreak +
   'Function-Result-Variables are not considered.',

  //fiUnusedUnit,
  '... are UNITs whose Interfaces-Identifiers are never used.',

  //fiUnitCalls,
  '... are referenced by the selected Unit.'                 + sLineBreak +
                                                               sLineBreak +
  'This results in the same Id-Tree as if you had loaded only this Unit into Ref.' + sLineBreak +
                                                                                     sLineBreak +
  'The selected Unit itself is NOT included.',

  //fiReferencers
  '... reference the selected Identifier.'                   + sLineBreak +
                                                               sLineBreak +
  'May be seen as if you load the Identifiers Reference-List into the Id-tree.',

  //fiNonANSI
  '... contain one or more non-ANSI-Characters.',

  //fiHierarchy
  '... are part of the actual Identifiers Class-Hierarchy.'   + sLineBreak +
                                                                sLineBreak +
  'This includes all Interfaces implemented in these Classes.',

  //fiMessages
  '... are Message-Handlers.',

  //fiGenerics
  '... are Generic-Types or -Methods.',

  //fiOverloads
  '... are overloaded Methods.'
  );


procedure TfrmFilter.BitBtnFilterOkayClick( Sender: TObject );
begin
  ModalResult := mrOk;
  case tFilters( radGrpFilter.ItemIndex ) of
    fiText       : if Length( cmbBoxName.Text ) <= 1 then ModalResult := mrNone;
    fiUnusedUnit : if MainBlock[mbUnDeclaredUnScoped].SubBlock <> nil then
                     ShowMessage( 'Double-Check Results, there are unresolved Identifiers' )
  end
end;

procedure TfrmFilter.cmbBoxNameEnter( Sender: TObject );
begin
  radGrpFilter.ItemIndex := 0
end;

procedure TfrmFilter.cmbBoxTypEnter( Sender: TObject );
begin
  radGrpFilter.ItemIndex := 1
end;

procedure TfrmFilter.FormCreate( Sender: TObject );
var t: tidType;
begin
  for t := id_Label to id_Final do cmbBoxTyp.Items.Add( cIdShow[t].Text.ToLower );
  cmbBoxTyp.DropDownCount := cmbBoxTyp.Items.Count;
  radGrpFilterClick( nil )    // Memo für ItemIndex 0 laden
end;

procedure TfrmFilter.FormKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
var i: integer;
begin
  {$IFDEF TraceDx}
  if ( ( Key = VK_MENU{=Alt} ) or ( Key = VK_SHIFT ) or ( Key = VK_CONTROL ) )
    then exit
    else TTraceDx.Send( 'FormKeyDown', Key );
  {$ENDIF}
  case Key of
  VK_RETURN: BitBtnFilterOkayClick( nil );
  VK_UP    : if radGrpFilter.ItemIndex = 0
               then radGrpFilter.ItemIndex := radGrpFilter.Items.Count-1
               else radGrpFilter.ItemIndex := radGrpFilter.ItemIndex-1;
  VK_DOWN  : if radGrpFilter.ItemIndex = radGrpFilter.Items.Count-1
               then radGrpFilter.ItemIndex := 0
               else radGrpFilter.ItemIndex := radGrpFilter.ItemIndex+1;
  else
    if ( ActiveControl <> cmbBoxName ) or ( Shift = [ssAlt] ) then begin
      i := ShortCuts.IndexOf( char( Key ));
      case tFilters( i ) of
        fiText   : cmbBoxName.SetFocus;
        fiPerType: cmbBoxTyp.SetFocus;
        else       radGrpFilter.SetFocus;
                   radGrpFilter.ItemIndex := i
      end;
      Key := 0
      end
  end
end;

procedure TfrmFilter.PreParse;
begin
  radGrpFilter.ItemIndex := 0;
  radGrpFilterClick( nil )
end;

procedure TfrmFilter.radGrpFilterClick( Sender: TObject );
begin
  MemoHint1.Text := sLineBreak + cHintText[tFilters(radGrpFilter.ItemIndex)]
end;

end.

