
unit ufViewer;

{$INCLUDE _CompilerOptions.pas}
{ $UNDEF TraceDx}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  WinApi.ActiveX,
  uListen, uGlobalsParser, Vcl.Menus;

type

//  TfrmViewer = class( TForm, IDropSource )
  TfrmViewer = class( TForm )
    lstBoxViewer: TListBox;
    PopupMenuViewer: TPopupMenu;
    pMnuItmViewerGoto: TMenuItem;
    pMnuItmViewerClose: TMenuItem;
    pMnuItmViewCopy: TMenuItem;
    procedure lstBoxViewerDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lstBoxViewerMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lstBoxViewerMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure Init( p: tFunc<pIdInfo,boolean, boolean> );
    procedure FormHide(Sender: TObject);
    procedure pMnuItmViewerGotoClick(Sender: TObject);
    procedure PopupMenuViewerPopup(Sender: TObject);
    procedure pMnuItmViewerCloseClick(Sender: TObject);
    procedure pMnuItmViewCopyClick(Sender: TObject);
    procedure FormKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure FormAfterMonitorDpiChanged( Sender: TObject; OldDPI, NewDPI: Integer );
  end;

type
  TViewer = record
              public
                class procedure LoadViewerFile( pId: pIdInfo; d: tFileIndex; z: tLineIndex );           static;
                class procedure PreParse; static;
                class function  OnDrop: boolean; static;
                class procedure SendInput( Mode: integer; HasFormular: boolean; const pos: tFilePos ); static;
            end;

var
  frmViewer   : TfrmViewer;

implementation

uses
  {$IFDEF TraceDx} uTraceDx, {$ENDIF}
  WinAPI.ShellAPI,          // OleCheck, DragAccept
  Vcl.Clipbrd,
  SendInputHelper,
  UnitDragDropToExtern,
  UtilitiesDx,
  System.IOUtils;

{$R *.dfm}

{$IFDEF TraceDx} type uViewer = class end; {$ENDIF}

var
  ViewFile  : tFileIndex_ = cKeinFileIndex;
  ViewPos   : tFilePos;
  ViewPId   : pIdInfo     = nil;
  EraseAc,
  FirstAc,
  LastAc    : pAcInfo;
  PageLines,
  Selected  : integer;
  HoverIdAc : pAcInfo;
  TvSelect  : tFunc<pIdInfo, boolean, boolean>;
  lbvCharWidth : integer;

{$REGION '-------------- frmViewer ---------------' }

(* Resize *)
procedure DoResizeFont( DeltaHeight: integer );
begin
  {$IFDEF TraceDx} TraceDx.Send( uViewer, 'Init', DeltaHeight ); {$ENDIF}
  frmViewer.Font.Height               :=  frmViewer.Font.Height - DeltaHeight;
  frmViewer.lstBoxViewer.Canvas.Font  :=  frmViewer.lstBoxViewer.Font;
  lbvCharWidth                        :=  frmViewer.lstBoxViewer.Canvas.TextWidth( 'm' );
  frmViewer.lstBoxViewer.ItemHeight   :=  round( -frmViewer.lstBoxViewer.Canvas.Font.Height * 1.2 )
end;

(* FormCreate *)
procedure TfrmViewer.FormCreate( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Send( uViewer, 'FormCreate' ); {$ENDIF}
  UtilitiesDx.TIni.ReadForm( Self );
  DoResizeFont( 0 )
end;

(* FormHide *)
procedure TfrmViewer.FormHide( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Send( uViewer, 'FormHide' ); {$ENDIF}
  DateiListe[ViewFile]^.LastTop := frmViewer.lstBoxViewer.TopIndex;
end;

(* FormKeyDown *)
procedure TfrmViewer.FormKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
begin
  {$IFDEF TraceDx} TraceDx.Send( uViewer, 'FormKeyDown', Key ); {$ENDIF}
  case Key of
    VK_ESCAPE  : Hide;
    VK_ADD     : DoResizeFont(  1 );
    VK_SUBTRACT: DoResizeFont( -1 );
  end
end;

(* FormAfterMonitorDpiChanged *)
procedure TfrmViewer.FormAfterMonitorDpiChanged( Sender: TObject; OldDPI, NewDPI: Integer );
begin
  DoResizeFont( 0 )
end;

(* FormClose *)
procedure TfrmViewer.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  {$IFDEF TraceDx} TraceDx.Send( uViewer, 'FormClose' ); {$ENDIF}
  Action := caHide
end;

(* FormResize *)
procedure TfrmViewer.FormResize( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Send( uViewer, 'FormResize' ); {$ENDIF}
  PageLines := lstBoxViewer.ClientHeight div lstBoxViewer.ItemHeight
end;

{$ENDREGION }

{$REGION '-------------- GUI gemeinsam ---------------' }

class function TViewer.OnDrop: boolean;
var hWND_Dst,
    hWND_IDE: THandle;
    pt      : TPoint;
begin
  GetCursorPos( pt );
  hWnd_Dst := WindowFromPoint( pt );
  hWnd_Dst := GetAncestor( hWND_Dst, GA_ROOT );
  hWND_IDE := FindWindow( 'TAppBuilder', nil );
  (* Zusätzlich TitleBar prüfen ist überflüssig:
  pc := StrAlloc( 200 );
  GetWindowText( hWnd, pc, 200 );      //    i := SendMessage( hWnd, WM_GetText, 100, NativeUint( pc ));
  s := StrPas( pc );
  StrDispose( pc );
  {$IFDEF TraceDx} TraceDx.Send( uViewer, 'Drop to', s ); {$ENDIF}    //   Ref - Delphi 10.3 - u_Main [wird ausgeführt] [Erzeugt]
  *)
  Result := hWND_Dst = hWND_IDE
end;

class procedure TViewer.SendInput( Mode: integer; HasFormular: boolean; const pos: tFilePos );
{ Mode 0: Wort markieren
       1: Zeile markieren
       2: nur Datei laden }
var SIH: TSendInputHelper;
    i  : word;
begin
  with pos do begin
    SIH := TSendInputHelper.Create;
    try
      { Zielfenster aktivieren: }
      SIH.AddMouseClick( mbLeft );
      if HasFormular then
        SIH.AddVirtualKey( VK_F12, true, true  );                 // Formular wird von IDE automatisch aktiviert. Mit F12 zurückschalten
      if Mode = 2 then
        SIH.AddVirtualKey( VK_HOME, true, true  )
      else begin
        {$IFDEF TraceDx} TraceDx.Send( uViewer, 'Zeile', Zeile+1 ); {$ENDIF}
        { Unfold: }
        SIH.AddShortCut([ssCtrl_,ssShift_], 'k');               // Ctrl-Shift-k
        SIH.AddShortCut([ssCtrl_,ssShift_], 'a');               // Ctrl-Shift-a
        { Goto line }
        SIH.AddShortCut([ssAlt_], 'g');               // Alt-G = goto
        SIH.AddText( (Zeile+1).ToString, false );
        SIH.AddVirtualKey( VK_DELETE, true, true );
        SIH.AddVirtualKey( VK_RETURN, true, true );
        if Mode = 1 then

        else begin
          { aktuelle (evtl persistente) Blockmarkierung löschen }
          // ?
          { ans Ende (für definierten Anfang) }
          SIH.AddVirtualKey( VK_END, true, true  );
          { zurück bis Block-Ende }
          for i := Spalte+Laenge+1 to DateiListe[Datei]^.StrList[Zeile].Length do
            SIH.AddVirtualKey( VK_LEFT, true, true  );

        {$IF false}
          { Variante1: Mit n * Shift-Left markieren: }
          SIH.AddVirtualKey( VK_SHIFT, true, false );
          { zum Markier-Anfang }
          for i := Spalte+1 to Spalte+Laenge do
            SIH.AddVirtualKey( VK_LEFT, true, true  );
          SIH.AddVirtualKey( VK_SHIFT, false, true );
        {$ELSE}
          { Variante2: Blockende und -start markieren: }
    //        { Blockende-Markierung Ctrl-K-K }
          SIH.AddVirtualKey( VK_CONTROL, true, false );
          SIH.AddText( 'kk', false );
          SIH.AddVirtualKey( VK_CONTROL, false, true );
          { nach links gehen: }
          for i := Spalte+1 to Spalte+Laenge do
            SIH.AddVirtualKey( VK_LEFT, true, true  );

          { Blockanfang-Markierung Ctrl-K-B }
          SIH.AddVirtualKey( VK_CONTROL, true, false );
          SIH.AddText( 'kb', false );
          SIH.AddVirtualKey( VK_CONTROL, false, true );
        {$ENDIF}
        end
      end;
      SIH.Flush;
    finally
      SIH.Free;
    end
    end
end;

{$ENDREGION }

{$REGION '-------------- lstBoxViewer ---------------' }

(* CheckPidAccesses *)
procedure CheckPidAccesses( pId: pIdInfo; f: tFileIndex );
var a: pAcInfo;
    i: tFileIndex;
begin
  {$IFDEF TraceDx} TraceDx.Send( uViewer, 'CheckPidAccesses', pId^.Name ); {$ENDIF}
  a := pId^.AcList;
  while ( a <> nil ) and ( a^.Position.Datei <> f ) do
    a := a^.NextAc;
  FirstAc := a;    // erster und letzter ac
  LastAc  := a;    // für pId in aktueller Datei f
  while a <> nil do begin
    if a^.Position.Datei = f then LastAc := a;
    a := a^.NextAc
    end
end;

(* lstBoxViewerMouseMove *)
procedure TfrmViewer.lstBoxViewerMouseMove( Sender: TObject; Shift: TShiftState; X, Y: Integer );

  procedure PaintLine;
  begin
    lstBoxViewer.Canvas.MoveTo( ( EraseAc^.Position.Spalte) * lbvCharWidth,
                                ( EraseAc^.Position.Zeile - lstBoxViewer.TopIndex + 1 ) * lstBoxViewer.ItemHeight - 2 );
    lstBoxViewer.Canvas.LineTo( lstBoxViewer.Canvas.PenPos.X + EraseAc^.Position.Laenge * lbvCharWidth,
                                lstBoxViewer.Canvas.PenPos.Y )

  end;

begin
//  {$IFDEF TraceDx} TraceDx.Send( uViewer, 'lstBoxViewerMouseMove' ); {$ENDIF}
  if ssLeft in Shift then begin
    { DragDrop zur IDE starten: }
    {$IFDEF TraceDx} TraceDx.Send( uViewer, 'lstBoxViewerMouseMove-DragDrop' ); {$ENDIF}
    lstBoxViewer.Perform( WM_LBUTTONUP, 0, MakeLong( X, Y) );   // sonst wird DragDrop nie beendet
//    TControl(Sender).ControlState := TControl(Sender).ControlState - [csLButtonDown];
    with DateiListe[ViewFile]^ do
      if ( FileName = cDefinesFile ) or ( tFileFlags.isFormular in fiFlags ) then
//        ShowUserInfo( 'Formular-Files can''t be dragged' )
      else begin
        DragAcceptFiles( Application.MainForm.Handle, false );
//        ShowUserInfo( 'Drag file ' + Filename );
        if DragDropToExtern( TPath.GetDirectoryName( FileName ), [FileName], TViewer.OnDrop ) then begin
//          ShowUserInfo( 'Dropping file ' + Filename );
          ViewPos.Zeile := Selected;
          TViewer.SendInput( 1, tFileFlags.hasFormular in fiFlags, ViewPos )
          end
        else
//          ShowUserInfo( 'Drop-Point seems not to be the Delphi-IDE' )
        DragAcceptFiles( Application.MainForm.Handle, true );
        end
    end

  else begin
    Y := lstBoxViewer.TopIndex + Y div lstBoxViewer.ItemHeight;
    if Y < lstBoxViewer.Count then begin
      HoverIdAc := TListen.SearchAc ( ViewFile, Y, X div lbvCharWidth );

      if ( EraseAc <> nil ) and ( EraseAc <> HoverIdAc ) then begin
          lstBoxViewer.Canvas.Pen.Color := lstBoxViewer.Color;
          PaintLine;
          EraseAc := nil
        end;

      if HoverIdAc = nil then
        lstBoxViewer.Cursor := crDefault
      else begin
        lstBoxViewer.Cursor := crHandPoint;
        EraseAc := HoverIdAc;
        lstBoxViewer.Canvas.Pen.Color := clBlack;
        PaintLine;
        end
      end
    end
end;

(* PopupMenuViewerPopup *)
procedure TfrmViewer.PopupMenuViewerPopup(Sender: TObject);
begin
  {$IFDEF TraceDx} TraceDx.Send( uViewer, 'PopupMenuViewerPopup' ); {$ENDIF}
  pMnuItmViewerGoto.Enabled := HoverIdAc <> nil;
  if pMnuItmViewerGoto.Enabled
    then pMnuItmViewerGoto.Caption := 'Goto ' + cHick + HoverIdAc^.IdDeclare^.Name + cHick
    else pMnuItmViewerGoto.Caption := 'Goto ...';

end;

(* pMnuItmViewerGotoClick *)
procedure TfrmViewer.pMnuItmViewerGotoClick(Sender: TObject);
begin
  {$IFDEF TraceDx} TraceDx.Send( uViewer, 'pMnuItmViewerGotoClick' ); {$ENDIF}
  tvSelect( HoverIdAc^.IdDeclare, true );
  TViewer.LoadViewerFile( HoverIdAc^.IdDeclare, HoverIdAc^.Position.Datei, HoverIdAc^.Position.Zeile );
  Application.MainForm.BringToFront
end;

(* pMnuItmViewCopyClick *)
procedure TfrmViewer.pMnuItmViewCopyClick(Sender: TObject);
var s: string;
begin
  {$IFDEF TraceDx} TraceDx.Send( uViewer, 'pMnuItmViewCopyClick' ); {$ENDIF}
  s := DateiListe[ViewFile]^.StrList[Selected];
  Clipboard.SetTextBuf( @s[cSpalte0] )
end;

(* pMnuItmViewerCloseClick *)
procedure TfrmViewer.pMnuItmViewerCloseClick(Sender: TObject);
begin
  {$IFDEF TraceDx} TraceDx.Send( uViewer, 'pMnuItmViewerCloseClick' ); {$ENDIF}
  Hide
end;

(* lstBoxViewerMouseDown *)
procedure TfrmViewer.lstBoxViewerMouseDown( Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer );
begin
  {$IFDEF TraceDx} TraceDx.Send( uViewer, 'lstBoxViewerMouseDown' ); {$ENDIF}
  if ssDouble in Shift then begin
    if HoverIdAc <> nil then
      pMnuItmViewerGotoClick( nil )
    end
  else begin
    lstBoxViewer.ItemIndex := -1;    // sonst kann im OnDrawItem nicht ausgesiebt werden
    Y := lstBoxViewer.TopIndex + Y div lstBoxViewer.ItemHeight;
    if Selected <> Y then begin
      Selected := Y;
      lstBoxViewer.Repaint
      end;
    end;
end;

var
  AcBunt: record
            idx: integer;   // letzte Draw-Zeile
            ai,             // AcArray dieser Zeile
            aii: word       // AcArray-Index dieser Zeile
          end;

procedure TfrmViewer.lstBoxViewerDrawItem( Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState );
var s: string;
    a: pAcInfo;
begin
//  {$IFDEF TraceDx} TraceDx.Send( uViewer, 'lstBoxViewerDrawItem', Index ); {$ENDIF}
  if State * [odSelected, odFocused] <> [] then exit;
  s := DateiListe[ViewFile]^.StrList[Index];
  if Index = Selected then begin
    lstBoxViewer.Canvas.Brush.Color := clInfoBk;
    lstBoxViewer.Canvas.Font. Color := clBlack;   // keine Ahnung warum der gesetzt werden muss!
    end;
  lstBoxViewer.Canvas.FillRect( Rect );
  lstBoxViewer.Canvas.TextOut( Rect.Left, Rect.Top, s );
  if ( LastAc <> nil ) and ( Index <= LastAc^.Position.Zeile ) then begin
    a := FirstAc;
    repeat
      if ( a^.Position.Datei = ViewFile ) and ( a^.Position.Zeile = Index ) then begin
        lstBoxViewer.Canvas.Font.Color := cAcShow[a^.ZugriffTyp].Color ;
        lstBoxViewer.Canvas.Font.Style := [fsUnderline];
        lstBoxViewer.Canvas.TextOut( lbvCharWidth * ( a^.Position.Spalte), Rect.Top,
                                     s.Substring(    a^.Position.Spalte, a^.Position.Laenge ))
        end;
      if a = LastAc
        then break
        else a := a^.NextAc
    until false
    end
end;

(* TfrmViewer.Init *)
procedure TfrmViewer.Init( p: tFunc<pIdInfo,boolean,boolean> );
begin
  {$IFDEF TraceDx} TraceDx.Send( uViewer, 'Init' ); {$ENDIF}
  TvSelect  := p
end;

(* LoadViewerFile *)
class procedure TViewer.PreParse;
begin
  frmViewer.Hide;
  ViewFile := cKeinFileIndex;
  ViewPid  := nil;
end;

(* LoadViewerFile *)
class procedure TViewer.LoadViewerFile( pId: pIdInfo; d: tFileIndex; z: tLineIndex );
var neueDatei,
    neuerPId : Boolean;
begin
  {$IFDEF TraceDx} TraceDx.Send( uViewer, 'LoadViewerFile', TListen.pIdName( pId ) ); {$ENDIF}
  neueDatei := ViewFile <> d;
  neuerPId  := ViewPId  <> pId;

  if neueDatei or neuerPId then begin
    if pId = nil then begin
      frmViewer.Caption  := DateiListe[d]^.FileName;
      FirstAc := nil;
      LastAc  := nil
      end
    else begin
      frmViewer.Caption  := cIdShow[pId^.Typ].Text + '  "' + pId^.Name + '"  in  ' + DateiListe[d]^.FileName;
      CheckPidAccesses( pId, d )
      end;
    end;
  ViewPId := pId;
  if neueDatei then begin
    AcBunt.idx := -1;
    if frmViewer.Visible then
      frmViewer.FormHide( nil );
    ViewFile := d;
    frmViewer.lstBoxViewer.Count  := high( DateiListe[ViewFile]^.StrList ) + 1;
    frmViewer.lstBoxViewer.Cursor := crDefault
    end
  else
    frmViewer.lstBoxViewer.Invalidate;    // neuer pId, pAc: alles neu zeichnen

  Selected := z;
  if pId = nil then
    frmViewer.lstBoxViewer.TopIndex := z
  else
    if neueDatei or {neuerPId or} ( z < frmViewer.lstBoxViewer.TopIndex ) or ( z > frmViewer.lstBoxViewer.TopIndex + PageLines-1) then
      if z < PageLines div 3
        then frmViewer.lstBoxViewer.TopIndex := 0
        else frmViewer.lstBoxViewer.TopIndex := z - PageLines div 3;

  frmViewer.Show
end;

{$ENDREGION }

initialization
  ViewPos.Laenge := 0

end.

