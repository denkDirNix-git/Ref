
unit ufNassiHelp;

{$INCLUDE _CompilerOptions.pas}
{ $UNDEF TraceDx}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmNassiHelp = class(TForm)
    MemoHelp: TMemo;
    procedure MemoHelpKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  frmNassiHelp: TfrmNassiHelp;

implementation

{$R *.dfm}

procedure TfrmNassiHelp.MemoHelpKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
begin
  case Key of
    VK_ESCAPE  : Close;
    VK_ADD,
    VK_SUBTRACT: if Key = VK_ADD
                   then Font.Size := Font.Size + 1
                   else if Font.Size > 6 then Font.Size := Font.Size - 1;
    end;
end;

end.

