unit ufHistory;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  uGlobalsParser;

type

  TChangeProc = reference to function ( p: pIdInfo; b: boolean ): boolean;

  TfrmHistory = class(TForm)
    lstHistory: TListBox;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure RegisterAkt( ChangeAbs: TChangeProc );
    procedure AddItem( pId: pIdInfo );
    procedure lstHistoryDblClick(Sender: TObject);
    procedure lstHistoryDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  frmHistory: TfrmHistory;

implementation

{$R *.dfm}

uses
  uListen;

const
  cMaxItems = 100;

var
  ChangeAbsPid: TChangeProc;
  Clicked     : boolean = false;


procedure TfrmHistory.AddItem( pId: pIdInfo );
begin
  var i := lstHistory.Items.IndexOfObject( TObject( pId ));
  case i of
   -1: begin
         if lstHistory.Count = cMaxItems then
           lstHistory.Items.Delete( cMaxItems-1 );
         lstHistory.Items.InsertObject( 0, TListen.getBlockNameLongMain( pId, cTrennUse ), TObject( pId ))
       end;
    0: Clicked := false;
  else if Clicked
         then Clicked := false
         else lstHistory.Items.Move( i, 0 )
  end
end;

procedure TfrmHistory.lstHistoryDblClick( Sender: TObject );
begin
  if lstHistory.ItemIndex <> -1 then begin
    ChangeAbsPid( pIdInfo( lstHistory.Items.Objects[lstHistory.ItemIndex] ), true );
    Clicked := true;
    Application.MainForm.Show
    end;
end;

procedure TfrmHistory.lstHistoryDrawItem( Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState );
begin
  var pId := pIdInfo( lstHistory.Items.Objects[Index] );
  with lstHistory.Canvas do begin
    Brush.Color := clBtnFace;        // falls State in [odSelected, odFocused]
    FillRect( Rect );
    Font.Color := cIdShow[pId^.Typ].Color;
    TextOut( Rect.Left, Rect.Top, TListen.getBlockNameLong( pId, dTrennView ) )
    end;
end;

procedure TfrmHistory.RegisterAkt( ChangeAbs: TChangeProc );
begin
  ChangeAbsPid := ChangeAbs
end;

{--------------------------------------------------------------------------------------------------}

procedure TfrmHistory.FormKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
var p: pIdInfo;
begin
  case Key of
  VK_DELETE: if Shift = [ssShift,ssCtrl] then begin
               if lstHistory.Count = 0
                 then p := nil
                 else p := pIdInfo( lstHistory.Items.Objects[0] );
               lstHistory.Clear;
               if p <> nil then AddItem( p )
               end
             else
               if lstHistory.ItemIndex <> -1 then
                 lstHistory.Items.Delete( lstHistory.ItemIndex );
  VK_RETURN: if lstHistory.ItemIndex <> -1 then
               lstHistoryDblClick( lstHistory );
  VK_ESCAPE: Hide;
  VK_F2    : Application.MainForm.Show;
  end;
end;

end.
