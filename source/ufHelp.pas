
unit ufHelp;

{$INCLUDE _CompilerOptions.pas}
{ $UNDEF TraceDx}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmHelp = class(TForm)
    lstBoxHelp: TListBox;
    procedure lstBoxHelpKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  frmHelp: TfrmHelp;

implementation

{$R *.dfm}

procedure TfrmHelp.lstBoxHelpKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
var s: string;
begin
  case Key of
    VK_ESCAPE  : Close;
    VK_ADD,
    VK_SUBTRACT: begin
                   if Key = VK_ADD
                     then Font.Size := Font.Size + 1
                     else if Font.Size > 6 then Font.Size := Font.Size - 1;
                   s := lstBoxHelp.Items[lstBoxHelp.Items.IndexOf( 'Specials' ) + 2];
                   ClientWidth := Canvas.TextWidth( s ) + GetSystemMetrics(SM_CXVSCROLL)
                 end
    end;
end;

end.

