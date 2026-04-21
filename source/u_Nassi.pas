
unit u_Nassi;
{$INCLUDE _CompilerOptions.pas}
{ $UNDEF TraceDx}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.AppEvnts,
  Vcl.StdCtrls, Vcl.Menus, Vcl.ComCtrls;

{$INCLUDE NassiCommon.pas}

type
  TfrmNassi = class(TForm)
    ScrollBar: TScrollBar;
    PaintBox: TPaintBox;
    MainMenu: TMainMenu;
    mItmFile: TMenuItem;
    mItmView: TMenuItem;
    mItmOptions: TMenuItem;
    mItmHelp: TMenuItem;
    mItmHelpHelp: TMenuItem;
    mItmHelpInfo: TMenuItem;
    mItmFileExit: TMenuItem;
    Bevel: TBevel;
    Panel: TPanel;
    mItmViewMenu: TMenuItem;
    PopupMenu: TPopupMenu;
    pItmSubViewCreate: TMenuItem;
    pItmSubViewEnter: TMenuItem;
    pItmSubViewLeave: TMenuItem;
    pItmSubViewDestroy: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    pItmHighlight: TMenuItem;
    pItmHighlightOn: TMenuItem;
    pItmHighlightOff: TMenuItem;
    pItmHighlightAllOff: TMenuItem;
    mItmOptionsSaveGlobal: TMenuItem;
    N3: TMenuItem;
    mItmFileOpen: TMenuItem;
    OpenDialog: TOpenDialog;
    N4: TMenuItem;
    N5: TMenuItem;
    mItmFileRecent0: TMenuItem;
    mItmFileRecent1: TMenuItem;
    mItmFileRecent2: TMenuItem;
    mItmFileRecent3: TMenuItem;
    mItmFileRecent4: TMenuItem;
    mItmFileRecent5: TMenuItem;
    mItmOptionsSaveSubViewsLocal: TMenuItem;
    mItmViewFullScreen: TMenuItem;
    N6: TMenuItem;
    pItmHighlightPrevOn: TMenuItem;
    pItmHighlightPrevOff: TMenuItem;
    pItmSubViewSetHeader: TMenuItem;
    mItmViewWidth80: TMenuItem;
    N7: TMenuItem;
    mItmFileSaveOne: TMenuItem;
    mItmFileSaveAll: TMenuItem;
    mItmViewIndentThen: TMenuItem;
    mItmViewAutoSubInterface: TMenuItem;
    N8: TMenuItem;
    pItmCopyText: TMenuItem;
    pItmSearchText: TMenuItem;
    mItmFileOpenClip: TMenuItem;
    mItmOptionsSaveVisual: TMenuItem;
    mItmViewCutComment: TMenuItem;
    procedure ApplicationEventsActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure ScrollBarChange(Sender: TObject);
    procedure mItmHelpHelpClick(Sender: TObject);
    procedure mItmHelpInfoClick(Sender: TObject);
    procedure mItmFileExitClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mItmViewMenuClick(Sender: TObject);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pItmSubViewLeaveClick(Sender: TObject);
    procedure pItmSubViewEnterClick(Sender: TObject);
    procedure pItmSubViewCreateClick(Sender: TObject);
    procedure PopupMenuPopup(Sender: TObject);
    procedure pItmSubViewDestroyClick(Sender: TObject);
    procedure pItmHighlightOnClick(Sender: TObject);
    procedure pItmHighlightOffClick(Sender: TObject);
    procedure pItmHighlightAllOffClick(Sender: TObject);
    procedure mItmOptionsSaveGlobalClick(Sender: TObject);
    procedure mItmFileOpenClick(Sender: TObject);
    procedure mItmFileRecentClick(Sender: TObject);
    procedure mItmViewFullScreenClick(Sender: TObject);
    procedure pItmHighlightPrevOnClick(Sender: TObject);
    procedure pItmHighlightPrevOffClick(Sender: TObject);
    procedure pItmSubViewSetHeaderClick(Sender: TObject);
    procedure mItmViewWidth80Click(Sender: TObject);
    procedure mItmFileSaveOneClick(Sender: TObject);
    procedure mItmFileSaveAllClick(Sender: TObject);
    procedure mItmViewIndentThenClick(Sender: TObject);
    procedure mItmOptionsSaveSubViewsLocalClick(Sender: TObject);
    procedure mItmViewAutoSubInterfaceClick(Sender: TObject);
    procedure pItmCopyTextClick(Sender: TObject);
    procedure pItmSearchTextClick(Sender: TObject);
    procedure mItmFileOpenClipClick(Sender: TObject);
    procedure mItmOptionsSaveVisualClick(Sender: TObject);
    procedure mItmViewCutCommentClick(Sender: TObject);
  private
    { Private-Deklarationen }
    procedure WMDROPFILES ( var Msg: TMessage ); message WM_DROPFILES;
    procedure NassiMessage( var Msg: TMessage ); message WM_Nassi;
  public
    { Public-Deklarationen }
  end;

var
  frmNassi : TfrmNassi;
  scanning: boolean = false;

procedure DoStartNassiBatch;
procedure OnAllCreatedNassi;
procedure LoadParameters;
procedure NassiFromRef( const f: string; Lines: TArray<string>; ScanStart, SuchZeile, SuchSpalte: Integer; const SuchText: string );

implementation

{$R *.dfm}

uses
  WinAPI.ShellAPI,          // OleCheck, DragAccept
  System.IOUtils,
  System.UITypes,
  System.Types,
  System.Math,
  System.Character,
  Vcl.Clipbrd,
//  Vcl.Printers,
  UtilitiesDx,
  {$IFDEF TraceDx} uTraceDx, {$ENDIF}
  System.IniFiles,
  uGlobalData,
  ufNassiHelp,
  uScan,
  uBlock,
  {$IFDEF DEBUG}
    uDiagnose,
  {$ENDIF}
  uViewer;


const
  cProgName       = 'Nassi' {$IFDEF Pascal86} + '86' {$ENDIF};
  cProgNameExt    = 'nassi';
  cDenkDirNix     = 'DenkDirNix';
  cMailTo         = 'mailto: ' + cDenkDirNix + '@mail.de';
  cExtIni         = '.ini';
  cShowSubView    = '  ->  ';

  cStrukWidth     =  1920;
  cStrukHeight    = 20000;

  { Programm-Ini: }
  cMenu           = 'Menu';
  cSubInterface   = 'SubInterface';
  cIndentThen     = 'IndentThen';
  cCutComments    = 'CutComments';

type
  tSubViewFile    = TextFile;
  TSearch         = record
                      SuchText: string;
                      Pos     : tSourcePos;
                      ArtIndex: integer;      // Index in TextArtArray, wo das aktuelle SuchErgebnis (die Position) hinterlegt ist
                      procedure Init;
                      function  getSearchText: boolean;
                      procedure DeleteLastSearch;
                      function  DoSearch: boolean;
                      procedure DoF3Search;
                      procedure SetCursor;
                      procedure Found;
                    end;

var
  aktStructHeight : integer = -1;
  aktPaintBoxWidth: integer = -1;
  InActivate,
  FromClipBoard,
  SubViewChanged  : boolean;                      // muss neu gespeichert werden
  Search          : TSearch;
  ParaCount       : integer;
  ParaStr         : array[0..2] of string;

{$REGION '-------------------- Close -------------------- ' }

function CurrentDirAsFileName: string;
const cErsatz = '_';
begin
  Result    := getCurrentDir;
  Result[1] := cErsatz;
  Result    := Result.Replace( TPath.DirectorySeparatorChar, cErsatz ) + cErsatz
end;

(* FileClose *)
procedure FileClose;
var f      : tSubViewFile;
    s      : string;
    changed: boolean;
begin
  if not FromClipBoard and ( Source.Name <> EmptyStr ) then begin
    {$IFDEF TraceDx} TraceDx.Send( 'FileClose', Source.Name ); {$ENDIF}
    if SubViewChanged and not OptionRefCalled then begin
      if Source.Proc = ''
        then s := Source.Name +                     '.' + cProgNameExt
        else s := Source.Name + '.' + Source.Proc + '.' + cProgNameExt;

      if not frmNassi.mItmOptionsSaveSubViewsLocal.Checked
        then s := TMyApp.DirUser + CurrentDirAsFileName + s;

      AssignFile( f, s );
      try     Rewrite( f );
      except  ShowMessage( 'Can''t write to Source-Directory.' + sLineBreak + 'Using User-Directory instead' );
              AssignFile( f, TMyApp.DirUser + CurrentDirAsFileName + s );
              Rewrite( f )
      end;

      try     changed := false;
              TBlock.ForAllBlocks( function( p: pBlockInfo ): boolean
                begin
                  Result := false;
                  if p^.Typ = btSubViewFix then begin
                    while p^.Sub^.Typ in btSubView do p := p^.Sub;      // falls SubViewFix auf weitere SubViews zeigt: ganz nach unten durchhangeln
                    if not ( fl_AutoSubFix in p^.Flags ) then begin
                      writeLn( f, p^.Sub^.Nr.ToString + sLineBreak + TBlock.getLast( p )^.Nr.ToString + sLineBreak + p^.SubInfo.Header );
                      changed := true
                      end
                    end
                end );
      finally closefile( f );
              if not changed then Erase( f )
      end
      end;
    frmNassi.mItmOptionsSaveSubViewsLocal.Checked := false
    end;
end;

(* FormClose *)
procedure TfrmNassi.FormClose( Sender: TObject; var Action: TCloseAction );
(*
var f: textfile;
    i: integer;
    s: string;*)
begin
  {$IFDEF TraceDx} TraceDx.Send( 'FormClose' ); {$ENDIF}
  OnResize := nil;          // ein sonst evtl kommendes FormResize macht Ärger
  (* assignfile( f, UserDir + cProgName + cIniRecent + cExtIni );
  try
    rewrite( f );
    for i := 0 to cRecentMax do
      if mItmFile.Items[mItmFileRecent0.MenuIndex+i].Caption = EmptyStr
        then writeln( f, EmptyStr )
        else writeln( f, mItmFile.Items[mItmFileRecent0.MenuIndex+i].Hint )
  finally
    CloseFile( f )
  end; *)
  FileClose;
  Viewer.img.Free
end;

(* mItmFileExitClick *)
procedure TfrmNassi.mItmFileExitClick( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Send( 'mItmFileExitClick' ); {$ENDIF}
  Close
end;

{$ENDREGION}

{$REGION '-------------------- Blöcke-Struktur -------------------- ' }

(* PaintBoxPaint *)
procedure TfrmNassi.PaintBoxPaint( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Send( 'PaintBoxPaint', ScrollBar.Position ); {$ENDIF}
  { off, solange direkt in die PaintBox gemalt wird, siehe OnCreate }
  PaintBox.Canvas.CopyRect( PaintBox.ClientRect, Viewer.img.Canvas, Rect( 0, ScrollBar.Position, aktPaintBoxWidth, ScrollBar.Position + PaintBox.ClientHeight ));

  { Cursor drübermalen: }
  if CursorBlock.pStart <> nil then with PaintBox.Canvas do begin
    Brush.Color := clRectLinesCurs;
    FrameRect( System.Types.Rect( CursorBlock.pStart^.Rect.Left+1, CursorBlock.pStart^.Rect.Top-ScrollBar.Position+1, CursorBlock.pStart^.Rect.Right-1, CursorBlock.pEnde^.Rect.Bottom-ScrollBar.Position-1 ));
    Brush.Color := clRectLines
    end;
end;

(* ScrollBarChange *)
procedure TfrmNassi.ScrollBarChange( Sender: TObject );
begin
//  {$IFDEF TraceDx} TraceDx.Send( 'ScrollBarChange' ); {$ENDIF}
  PaintBox.Invalidate
end;

{ ScrollBlock }
procedure ScrollBlock( p: pBlockInfo );
{ schiebt einen Block (der im aktuellen View liegt) in den sichtbaren Bereich: }
const cRand = 30;
var d: integer;
begin
  {$IFDEF TraceDx} TraceDx.Send( 'ScrollBlock', p^.Rect.Top, frmNassi.ScrollBar.Position ); {$ENDIF}
  if p^.Rect.Top < frmNassi.ScrollBar.Position then
    frmNassi.ScrollBar.Position := p^.Rect.Top - cRand
  else begin
    if p^.Sub = nil
      then d := p^.Rect.Bottom
      else d := p^.Sub^.Rect.Top;
    if d > frmNassi.ScrollBar.Position + frmNassi.PaintBox.ClientHeight then
     frmNassi.ScrollBar.Position := p^.Rect.Top - cRand
    end
end;

(* BerechneNassi *)
procedure BerechneNassi;
begin
//  exit;
  {$IFDEF TraceDx} TraceDx.Send( 'BerechneNassi' ); {$ENDIF}
  aktStructHeight := TViewer.PaintBlocks( aktPaintBoxWidth ) + 2;
  frmNassi.ScrollBar.Max := Max( 0, aktStructHeight - frmNassi.PaintBox.ClientHeight );
  frmNassi.ScrollBar.LargeChange := 3 * frmNassi.PaintBox.ClientHeight div 4;
  frmNassi.PaintBox.Invalidate
end;

(* ProcessSource *)
procedure ProcessSource;

  procedure LoadNassi;
  var f  : tSubViewFile;
      i,j: tBlockIndex;
      s  : string;
      c  : tCursorBlock;
  begin
    SubViewChanged := false;
    if OptionRefCalled then exit;
    if Source.Proc = ''
      then s := Source.Name                     + '.' + cProgNameExt
      else s := Source.Name + '.' + Source.Proc + '.' + cProgNameExt;

    frmNassi.mItmOptionsSaveSubViewsLocal.Checked := TFile.Exists( s );

    if not frmNassi.mItmOptionsSaveSubViewsLocal.Checked then begin
      s := TMyApp.DirUser + CurrentDirAsFileName + s;
      if not TFile.Exists( s ) then exit
      end;

    if TFile.GetLastWriteTime( s ) > TFile.GetLastWriteTime( Source.Name ) then begin
      AssignFile( f, s );
      try   Reset( f );
            while not eof( f ) do begin
              readLn( f, i );
              readLn( f, j );
              c.pStart := TBlock.getByIndex( i );
              c.pEnde  := TBlock.getByIndex( j );
              readLn( f, s );
              if not ( fl_AutoSubFix in c.pStart^.prev^.Flags ) and ( c.pStart^.Level = c.pEnde^.Level ) then begin  // automatisch erzeugte proc-Ausblendung
                TViewer.SubViewCreate( c, btSubViewFix );
                c.pStart^.SubInfo.Header := s
                end
              end;
      finally closeFile( f )
      end
      end
    else
      {$IFDEF TraceDx} TraceDx.Send( 'LoadNassi', 'Nassi älter als Source' ) {$ENDIF}
  end;

begin
  {$IFDEF TraceDx} TraceDx.Send( 'ProcessSource' ); {$ENDIF}
  if not OptionBatchMode and not Viewer.img.Empty then begin
    frmNassi.PaintBox.Canvas.Brush.Color := clBackground;
    frmNassi.PaintBox.Canvas.FillRect( frmNassi.PaintBox.Canvas.ClipRect );
    frmNassi.PaintBox.Canvas.TextOut( frmNassi.ClientWidth div 2 - 20, frmNassi.ClientHeight div 2, 'Loading...' );
    end;
  Source.Date := TFile.GetLastWriteTime( Source.Name );
  scanning := true;
  if not OptionRefCalled then    // bei Aufruf aus Ref NICHT ist die SuchPosition schon belegt, nicht löschen
    Search.Init;
  case Source.Lang of
    lgC     : TScanner.ScanC;
    lgPascal86,
    lgPascal: TScanner.ScanPas;
    else      Error( erNotSupported )
  end;
  scanning := false;
  if Source.StartLine <> 0 then begin
    if Source.Proc = EmptyStr
      then Source.Caption := Source.Caption + ' > ' + Source.Lines[Source.StartLine].TrimLeft
      else Source.Caption := Source.Caption + ' > ' + Source.Proc;
    frmNassi.Caption := Source.Caption
    end;

  {$IFDEF DEBUG}
  if not TDiagnose.SaveBlocksToFile then begin
    if not OptionBatchMode
      then frmNassi.Caption := 'Ergebnis-tree ungleich OK-Vorlage';
    ExitCode := 9  //  = ord( tErrBatch.Compare );
    end;
  {$ENDIF}
  if not OptionBatchMode then begin
    TViewer.Init;
    LoadNassi;
    BerechneNassi;
    frmNassi.Cursor := crDefault
    end
end;

(* DoHighLight *)
procedure DoHighLight( HighLightOn, AllPrev: boolean );
const cIgnoreSubs = [btProc, btIf, btCase, btWhile, btFor, btExcept];
var SaveCursor: tCursorBlock;

  procedure SetHighLight( var fl: tBlockFlagSetRun );
  begin
    if HighLightOn
      then include( fl, flHighlight )
      else exclude( fl, flHighlight )
  end;

  procedure SetAllSubs( p: pBlockInfo );
  begin
    if not ( p^.Typ in cIgnoreSubs ) then begin
      p := p^.Sub;
      while p <> nil do begin
        SetHighLight( p^.FlagsRun );
          SetAllSubs( p );
        p := p^.Next
        end
      end
  end;

  procedure SetRekusiv( p0: pBlockInfo );
  var p,q: pBlockInfo;
  begin
    if not ( p0^.Typ in [btMain, btUnit, btProc] ) then begin
      SetHighLight( p0^.FlagsRun );
      q := p0^.prev;
      p := q^.Sub;
      if not ( q^.Typ in cIgnoreSubs ) then
        while p <> p0 {von den prevs nochmal down bis zu mir} do begin
          SetHighLight( p^.FlagsRun );
          SetAllSubs( p );
          p := p^.Next
          end;
      SetRekusiv( q )
      end
  end;

begin
  {$IFDEF TraceDx} TraceDx.Send( 'DoHighLight', HighLightOn, AllPrev ); {$ENDIF}
  SaveCursor := CursorBlock;   // weil CursorBlock geht im BerechneNassi verloren
  TBlock.ForAllCursorBlocks( CursorBlock, procedure( p: pBlockInfo )
    begin
//      SetHighLight( p^.Flags );      // geht leider nicht aus anonym
      if HighLightOn
        then include( p^.FlagsRun, flHighlight )
        else exclude( p^.FlagsRun, flHighlight )
    end );

  if AllPrev then
    SetRekusiv( CursorBlock.pEnde );

  BerechneNassi;
  CursorBlock := SaveCursor
end;

(* PaintBoxMouseDown *)
procedure TfrmNassi.PaintBoxMouseDown( Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer );
const valShift = 1; valCtrl = 4; valDouble = 32;
begin
  {$IFDEF TraceDx} TraceDx.Send( 'PaintBoxMouseDown' ); {$ENDIF}
  if Button = mbLeft then
    case word( Shift ) and ( valShift + valCtrl ) of
      0       : if ssDouble in Shift then begin
                  PopupMenuPopup( nil );
                  if pItmSubViewEnter.Enabled
                    then pItmSubViewEnterClick( nil )
                  end
                else
                 TViewer.SetCursorBlock( x, y + ScrollBar.Position );
      valCtrl : if ssDouble in Shift then
                   DoHighLight( flHighlight in CursorBlock.pStart^.FlagsRun, true )
                else begin   // Highlight
                  if not TViewer.TestInCursorBlocks( x, y + ScrollBar.Position ) then
                    TViewer.SetCursorBlock( x, y + ScrollBar.Position );
                  DoHighLight( not ( flHighlight in CursorBlock.pStart^.FlagsRun ), false )
                  end;
      valShift: TViewer.IncCursorBlock( x, y + ScrollBar.Position );   // Cursor verlängern
      valShift+
      valCtrl : begin  { Cursor verlängern auf ganzen Sub: }
                  if not TViewer.TestInCursorBlocks( x, y + ScrollBar.Position ) then
                    TViewer.SetCursorBlock( x, y + ScrollBar.Position );
                  CursorBlock.pStart := CursorBlock.pStart^.Prev^.Sub;
                  CursorBlock.pEnde  := CursorBlock.pStart;
                  while CursorBlock.pEnde^.Next <> nil do CursorBlock.pEnde := CursorBlock.pEnde^.Next
                end
      end

  else   // Button = mbRight, vor Popup des Menüs
    if not TViewer.TestInCursorBlocks( x, y + ScrollBar.Position )
      then TViewer.SetCursorBlock( x, y + ScrollBar.Position );
  PaintBox.Invalidate
end;

{$ENDREGION}

{$REGION '-------------------- Popup-Menü Highlight-------------------- ' }

(* pItmHighlightOnClick *)
procedure TfrmNassi.pItmHighlightOnClick( Sender: TObject );
begin
  DoHighLight( true, false )
end;

(* pItmHighlightOffClick *)
procedure TfrmNassi.pItmHighlightOffClick( Sender: TObject );
begin
  DoHighLight( false, false )
end;

(* pItmHighlightAllPrevOnClick *)
procedure TfrmNassi.pItmHighlightPrevOnClick( Sender: TObject );
begin
  DoHighLight( true, true )
end;

(* pItmHighlightAllPrevOffClick *)
procedure TfrmNassi.pItmHighlightPrevOffClick( Sender: TObject );
begin
  DoHighLight( false, true )
end;

(* pItmHighlightAllOffClick *)
procedure TfrmNassi.pItmHighlightAllOffClick( Sender: TObject );
begin
  TBlock.ForAllBlocks( function( p: pBlockInfo ): boolean
    begin
      Result := false;
      exclude( p^.FlagsRun, flHighlight )
    end );
  BerechneNassi
end;

{$ENDREGION}

{$REGION '-------------------- Popup-Menü SubView -------------------- ' }

(* pItmSubViewCreateClick *)
procedure TfrmNassi.pItmSubViewCreateClick( Sender: TObject );
var scp: integer;
    c  : tCursorBlock;
begin
  {$IFDEF TraceDx} TraceDx.Send( 'pItmSubViewCreateClick' ); {$ENDIF}
  if CursorBlock.pStart^.Typ in btDontShow then
    ShowMessage( 'Sorry, a SubView of Type "' + TBlock.getBlockTyp( CursorBlock.pStart^.Typ ).Substring( 2 ) + '" cannot be created.' + sLineBreak +
                 'You can use' + sLineBreak + sLineBreak +
                 '  - "SubView Enter as"' + sLineBreak + sLineBreak +
                 '  - "SubView Create" for inner Blocks' )
  else begin
    if ( CursorBlock.pStart^.Typ = btSubViewAuto ) and ( CursorBlock.pEnde = CursorBlock.pStart ) then begin
      CursorBlock.pStart^.Typ := btSubViewFix;
      BerechneNassi
      end
    else begin
      c := CursorBlock;
      TViewer.CursorMakeReal( CursorBlock );
      TBlock.ForAllCursorBlocks( c, procedure( p: pBlockInfo )
        begin
          if p^.Typ = btSubViewAuto then
            TViewer.SubViewDestroy( p )
        end );

      scp := ScrollBar.Position;
      TViewer.SubViewCreate( CursorBlock, btSubViewFix );
      BerechneNassi;
      if scp > CursorBlock.pStart^.Rect.Top then
        ScrollBar.Position := CursorBlock.pStart^.Rect.Top;
      end;
    SubViewChanged := true
    end
end;

(* pItmSubViewDestroyClick *)
procedure TfrmNassi.pItmSubViewDestroyClick( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Send( 'pItmSubViewDestroyClick' ); {$ENDIF}
  TViewer.SubViewDestroy( CursorBlock.pStart );
  BerechneNassi;
  SubViewChanged := true
end;

(* pItmSubViewEnterClick *)
procedure TfrmNassi.pItmSubViewEnterClick( Sender: TObject );
var scp: integer;
    c  : tCursorBlock;
begin
  {$IFDEF TraceDx} TraceDx.Send( 'pItmSubViewEnterClick' ); {$ENDIF}
  c := CursorBlock;
  if ( CursorBlock.pStart <> CursorBlock.pEnde ) or not ( CursorBlock.pStart^.Typ in ( btSubView + [btMain] )) then begin
    { Enter obwohl es gar kein SubBlock ist. Jetzt einen temporären erzeugen: }
      TViewer.CursorMakeReal( CursorBlock );
      TBlock.ForAllCursorBlocks( c, procedure( p: pBlockInfo )
        begin
          if p^.Typ = btSubViewAuto then
            TViewer.SubViewDestroy( p )
        end );
    TViewer.SubViewCreate( CursorBlock, btSubViewTmp )
    end;

  scp := ScrollBar.Position;
  TViewer.EnterAuslagerung( CursorBlock.pStart, scp );   // scp kommt zurück mit früher gespeicherter Position, siehe unten
  BerechneNassi;
  Caption := Source.Caption + cShowSubView + pSubView^.SubInfo.Header;
  ScrollBar.Position := scp
end;

(* pItmSubViewLeaveClick *)
procedure TfrmNassi.pItmSubViewLeaveClick( Sender: TObject );
var scp: integer;
    tmp: pBlockInfo;
begin
  {$IFDEF TraceDx} TraceDx.Send( 'pItmSubViewLeaveClick' ); {$ENDIF}
  if pSubView^.Typ = btMain then
    Close
  else begin
    PaintBox.Canvas.Brush.Color := clSilver;
    PaintBox.Canvas.FillRect( PaintBox.ClientRect );
    scp := ScrollBar.Position;
    tmp := pSubView;
    TViewer.LeaveAuslagerung( scp );

    if tmp^.Typ = btSubViewTmp then begin
      { temporäre Auslagerung nach Verlassen auch wieder zerstören: }
      TViewer.CursorMakeReal( CursorBlock );
      TViewer.SubViewDestroy( tmp )
      end;

    BerechneNassi;
    Caption := Source.Caption + cShowSubView + pSubView^.SubInfo.Header;
    ScrollBar.Position := scp
    end
end;

(* pItmSubViewSetHeaderClick *)
procedure TfrmNassi.pItmSubViewSetHeaderClick( Sender: TObject );
var s: string;
begin
  if ( CursorBlock.pStart <> nil ) and ( CursorBlock.pStart^.Typ in btSubView ) then begin
    s := InputBox( 'Set header for selected SubView', '', CursorBlock.pStart^.SubInfo.Header );
    if s <> CursorBlock.pStart^.SubInfo.Header then begin
      CursorBlock.pStart^.SubInfo.Header := s;
      BerechneNassi;
      if not ( fl_AutoSubFix in CursorBlock.pStart^.Flags )
        then SubViewChanged := true
      end
    end
  else begin
    s := InputBox( 'Set header for actual SubView'  , '', pSubView^.SubInfo.Header );
    if s <> pSubView^.SubInfo.Header then begin
      pSubView^.SubInfo.Header := s;
      Caption := Source.Caption + cShowSubView + s;
      if not ( fl_AutoSubFix in pSubView^.Flags )
        then SubViewChanged := true
      end
    end;
end;

{$ENDREGION}

{$REGION '-------------------- Popup-Menü sonst -------------------- ' }

(* PopupMenuPopup *)
procedure TfrmNassi.PopupMenuPopup( Sender: TObject );
var p        : pBlockInfo;
    CursorSet,
    Cursor1  : boolean;
begin
  {$IFDEF TraceDx} TraceDx.Send( 'PopupMenuPopup' ); {$ENDIF}
  p := CursorBlock.pStart;
  CursorSet := p <> nil;                                                  // Block-Curser ist sichtbar
  Cursor1   := p = CursorBlock.pEnde;                                     // Curser  umfasst genau einen Block

  pItmSubViewCreate   .Enabled := CursorSet
                              and ( not Cursor1 or  ( p^.Typ <> btSubViewFix ))   // entweder mehrere oder nicht bereits fix
                              and (( CursorBlock.pStart <> pSubView^.Sub) or ( CursorBlock.pEnde <> TBlock.getLast( pSubView ))) ;   // Curser ungleich SubView (das wäre sonst doppelt)

  pItmSubViewDestroy  .Enabled := CursorSet and Cursor1 and ( p^.Typ = btSubViewFix ) and not ( fl_AutoSubFix in p^.Flags );

  pItmSubViewSetHeader.Enabled := // pItmSubViewDestroy.Enabled or not ( p^.Typ in btSubView );
                                  ( pSubView <> nil ) and ( not CursorSet or Cursor1 );

  pItmSubViewEnter    .Enabled := CursorSet and ( pItmSubViewCreate.Enabled or ( p^.Typ = btSubViewFix ));
  if CursorSet and Cursor1 and ( p^.Typ in btSubView )
    then pItmSubViewEnter.Caption := 'SubView Enter'
    else pItmSubViewEnter.Caption := 'SubView Enter as';

  if CursorSet and ( p^.Typ in btSubView )
    then pItmSubViewSetHeader.Caption := 'SubView Set Header'
    else pItmSubViewSetHeader.Caption := 'ActView Set Header';

//pItmSubViewLeave    .Enabled := CursorSet ;     // ist immer enabled
  if ( pSubView = nil ) or ( pSubView^.Typ = btMain )
    then pItmSubViewLeave.Caption := 'Exit ' + cProgName
    else pItmSubViewLeave.Caption := 'SubView Leave';

  pItmHighlightOn     .Enabled := CursorSet and not ( flHighlight in p^.FlagsRun );
  pItmHighlightOff    .Enabled := CursorSet and     ( flHighlight in p^.FlagsRun );
  pItmHighlightPrevOn .Enabled := CursorSet and ( ( p^.prev <> nil ) and not ( p^.prev^.Typ in [btUnit, btProc] ));
  pItmHighlightPrevOff.Enabled := CursorSet and ( ( p^.prev <> nil ) and not ( p^.prev^.Typ in [btUnit, btProc] ));
  pItmHighlightAllOff .Enabled := pSubView <> nil;

  pItmSearchText      .Enabled := pSubView <> nil;
  pItmCopyText        .Enabled := CursorSet and Cursor1;
end;

(* pItmCopyTextClick *)
procedure TfrmNassi.pItmCopyTextClick( Sender: TObject );
var s: string;

  function getBlockText: string;
  var i: tSourcePosIdx;
  begin
    with CursorBlock.pStart^ do

      if Typ in btSubView then
        Result := SubInfo.Header
      else
        if TxtZeilen = 1 then
          Result := Source.Lines[TxtStart.ze].Substring( TxtStart.sp, TxtEnde.sp - TxtStart.sp + 1 )      // abschneiden
        else begin
          Result := Source.Lines[TxtStart.ze].Substring( TxtStart.sp );                              // alles

          for i := 1 to TxtZeilen - 2 do
            if TxtStart.sp >= Source.LineInfo[TxtStart.ze + i].NonBlank1
              then Result := Result + sLineBreak + Source.Lines[TxtStart.ze + i].Substring( Source.LineInfo[TxtStart.ze + i].NonBlank1 )    // alles
              else Result := Result + sLineBreak + Source.Lines[TxtStart.ze + i].Substring( TxtStart.sp );

          if TxtStart.sp >= Source.LineInfo[TxtEnde.ze].NonBlank1
            then Result := Result + sLineBreak + Source.Lines[TxtEnde.ze].Substring( Source.LineInfo[TxtEnde.ze].NonBlank1, TxtEnde.sp - Source.LineInfo[TxtEnde.ze].NonBlank1 + 1 )
            else Result := Result + sLineBreak + Source.Lines[TxtEnde.ze].Substring( TxtStart.sp, TxtEnde.sp - TxtStart.sp + 1 )
          end
  end;

begin
  s := getBlockText;
  Clipboard.SetTextBuf( @s[0] )
end;

{$ENDREGION}

{$REGION '-------------------- Save bmp -------------------- ' }

(* SaveBitmapToFile *)
function SaveBitmapToFile( h, w: integer ): boolean;
var hs,
    fn: string;
    b : TBitmap;
    r : TRect;
    i : integer;
    p : pBlockInfo;

  function MakeRealBlock( p: pBlockInfo ): pBlockInfo;
  begin
    Result := p^.Sub;
    while Result^.Typ in btSubView do
      Result := Result^.Sub
  end;

begin
  {$IFDEF TraceDx} TraceDx.Send( 'SaveBitmapToFile' ); {$ENDIF}
  if Source.Proc = EmptyStr
    then fn := ''
    else fn := '.' + Source.Proc;

  if pSubView^.Typ = btMain then
    fn := Source.Name + fn + '_0_1_main.bmp'
  else begin
    hs := pSubView^.SubInfo.Header;
    for i := 0 to high( hs ) do
      if not TPath.IsValidFileNameChar( hs[i] ) then
        hs[i] := '_';
    p := TViewer.getPrevSubView;
    fn := Source.Name + fn + Format( '_%d_%d_', [MakeRealBlock( p )^.Nr, MakeRealBlock( pSubView )^.Nr] ) + hs + '.bmp'
    end;

//  Viewer.img.SaveToFile( fn );      geht nicht weil ganzes, idR viel zu grosses img wird gespeichert
  Result := true;
  b := TBitmap.create;
  try b.SetSize( w, h );
      r := Rect( 0, 0, w, h );
      b.Canvas.CopyRect( r, Viewer.img.canvas, r );
      try    b.SaveToFile( fn )
      except ShowMessage( 'IO-Error writing *.bmp' );
             Result := false
      end
  finally
      b.Free
  end;

  (*if TFile.Exists( fn + '.OK' ) then
    if not AreFilesEqual( fn, fn + '.OK' ) then begin
      {$IFDEF TraceDx} TraceDx.Send( 'BitmapCompare', 'Error' ); {$ENDIF}
      Result := false;
      ExitCode := 9  //  = ord( tErrBatch.Compare );
      end*)
end;

(* mItmFileSaveOneClick *)
procedure TfrmNassi.mItmFileSaveOneClick( Sender: TObject );
begin
  SaveBitmapToFile( aktStructHeight, aktPaintBoxWidth )
end;

(* mItmFileSaveAllClick *)
procedure TfrmNassi.mItmFileSaveAllClick( Sender: TObject );
var scp: integer;
    s  : pBlockInfo;
begin
  s := pSubView;
  TBlock.ForAllBlocks( function( p: pBlockInfo ): boolean
    begin
      Result := false;
      if p^.Typ in ( btSubView + [btMain] ) then begin
        TViewer.EnterAuslagerung( p, scp );   // scp kommt zurück mit früher gespeicherter ScrollBar-Position, hier irrelevant
        BerechneNassi;
        if not SaveBitmapToFile( aktStructHeight, aktPaintBoxWidth ) then
          Result := true
        end
    end );
  TViewer.EnterAuslagerung( s, scp );
  BerechneNassi
end;

{$ENDREGION}

{$REGION '-------------------- Extern -------------------- ' }

(* LoadParameters *)
procedure LoadParameters;
{ Normalstart: Parameter vom Betriebssystem übernehmen: }
var i: integer;
begin
  {$IFDEF TraceDx} TraceDx.Send( 'LoadParameters' ); {$ENDIF}
  ParaCount := ParamCount;
  for i := 0 to min( ParaCount, 2 ) do ParaStr[i] := ParamStr( i )
end;

procedure SetLanguage( l: tLanguage ); forward;

(* NassiFromRef *)
procedure NassiFromRef( const f: string; Lines: TArray<string>; ScanStart, SuchZeile, SuchSpalte: Integer; const SuchText: string );
{ Start aus Ref: Parameter vom Aufrufer übernehmen: }
begin
  {$IFDEF TraceDx} TraceDx.Send( 'NassiFromRef' ); {$ENDIF}
  OptionRefCalled := true;
  Source.Name     := EmptyStr;              // damit bei einem zweiten Aufruf nicht noch die erste Source gespeichert ist, Problem bei OnResize
  ParaCount       := 2;
  ParaStr[1]      := f;
  ParaStr[2]      := ScanStart.ToString;
  Source.Lines    := Lines;
  Application.CreateForm( TfrmNassi, frmNassi );
  frmNassi.mItmFileOpen.Enabled := false;   // keine anderen Sources nachladen
  try
    OnAllCreatedNassi;
    SetLanguage( lgPascal );           // wenn ich aus Ref komme kann ich auch non-pas-Extensions als pas behandeln
    Search.SuchText := SuchText;
    Search.Pos.ze   := SuchZeile;
    Search.Pos.sp   := SuchSpalte;
    Search.Found;
    frmNassi.ShowModal  // nicht mehrfach aufrufen
  except
    frmNassi.OnResize := nil;             //  kommt sonst beim Beenden
    frmNassi.Free;
    ShowMessage( 'Nassi not available' )
  end;
end;

{$ENDREGION}

{$REGION '-------------------- Create-Open -------------------- ' }

(* SetLanguage *)
procedure SetLanguage( l: tLanguage );
begin
  {$IFDEF TraceDx} TraceDx.Send( 'SetLanguage', ord( l ) ); {$ENDIF}
  Source.Lang := l;
  if not OptionBatchMode then
    frmNassi.mItmViewAutoSubInterface.Visible := l in [lgPascal,lgPascal86]
  { Keywords entsprechend aktivieren: }
end;

(* LoadFile *)
procedure LoadFile( const s: string );

  (*procedure AddTorecent;
  var i,j: byte;
  begin
    { Datei schon in Recent-Liste vorhanden ? }
    j := cRecentMax;
    for i := 0 to cRecentMax do
      if lowercase( s ) = lowercase( frmNassi.mItmFile.Items[frmNassi.mItmFileRecent0.MenuIndex+i].Hint ) then begin
        j := i;    // wenn ja, im folgenden FOR nur ab hier verschieben
        break
        end;

    { Datei 3 wird zu 4, 2 zu 3, 1 zu 2. Nur oberhalb evtl schon vorhandenen s }
    for i := j downto 1 do begin
      frmNassi.mItmFile.Items[frmMain.mItmFileRecent0.MenuIndex+i].Hint    := frmMain.mItmFile.Items[frmMain.mItmFileRecent0.MenuIndex+i-1].Hint;
      frmNassi.mItmFile.Items[frmMain.mItmFileRecent0.MenuIndex+i].Caption := frmMain.mItmFile.Items[frmMain.mItmFileRecent0.MenuIndex+i-1].Caption;
      frmNassi.mItmFile.Items[frmMain.mItmFileRecent0.MenuIndex+i].Enabled := true
      end;

    { Neue Datei wird erster Recent-Eintrag: }
    frmNassi.mItmFile.Items[frmMain.mItmFileRecent0.MenuIndex].Hint    := s;
    frmNassi.mItmFile.Items[frmMain.mItmFileRecent0.MenuIndex].Caption := TPath.GetFileName( s );
    frmNassi.mItmFile.Items[frmMain.mItmFileRecent0.MenuIndex].Enabled := true
  end;*)

begin
  {$IFDEF TraceDx} TraceDx.Send( 'LoadFile', s ); {$ENDIF}
  if Source.Name <> EmptyStr then
    FileClose;

  FromClipBoard := false;
  if TFile.Exists( s ) then begin
    (*AddToRecent;*)
    if ( TPath.GetExtension( s ).ToLower = '.pas' ) {$IFNDEF Pascal86} or ( TPath.GetExtension( s ).ToLower = '.dpr' ) {$ENDIF} then
      {$IFDEF Pascal86}
      SetLanguage( lgPascal86 ) else
      {$ELSE}
      SetLanguage( lgPascal   ) else
      {$ENDIF}
    if   TPath.GetExtension( s ).ToLower = '.dpr' then
      SetLanguage( lgPascal   ) else
    if ( TPath.GetExtension( s ).ToLower = '.cpp' ) or ( TPath.GetExtension( s ).ToLower = '.c'   ) then
      SetLanguage( lgC        ) else
    if ( TPath.GetExtension( s ).ToLower = '.bat' ) or ( TPath.GetExtension( s ).ToLower = '.cmd' ) then
      SetLanguage( lgBatch    )
    else
      SetLanguage( lgUnknown );
    if not OptionRefCalled   // sonst bereits geladen
      then Source.Lines := TFile.ReadAllLines( s );
    SetLength( Source.LineInfo,     length( Source.Lines )     );
    SetLength( TextArtArray,        length( Source.Lines ) * 2 );
    TextArtArray[0].Pos.ze := -1;
    TextArtArray[0].Art    := artUnknown;

    if Source.Name <> EmptyStr then begin
      FillChar( Source.LineInfo[0], sizeOf( tLineInfo       ) * length( Source.Lines ), 0 );   // beim Reload gleicher oder anderer Source evtl notwendig
      FillChar( TextArtArray   [0], sizeOf( TextArtArray[0] ) * length( Source.Lines ), 0 )
      end;
    SetCurrentDir( TPath.GetDirectoryName( s ));
    Source.Name := TPath.GetFileName( s );
    Source.Proc := EmptyStr;
    if not OptionBatchMode then with frmNassi do begin
      Source  .Caption := cProgName + ' ' + cVersion + ':   ' + Source.Name;
      frmNassi.Caption := Source.Caption;
      ScrollBar.Position := 0;
      PaintBox.OnMouseDown := PaintBoxMouseDown;
      mItmOptionsSaveSubViewsLocal.Enabled := not OptionRefCalled;  // false wenn aus Ref
      mItmFileSaveOne             .Enabled := true;
      mItmFileSaveAll             .Enabled := true;
      end
    end
  else
    Error( erFileNotFound, s )
end;

(* FormCreate *)
procedure TfrmNassi.FormCreate( Sender: TObject );
const cProgram = 'Program';
var b  : boolean;
    Ini: TMemIniFile;
begin
  {$IFDEF TraceDx} TraceDx.Call( 'TfrmNassi.FormCreate' ); {$ENDIF}
  TIni.ReadForm( Self );

  Ini := TMemIniFile.Create( TMyApp.DirUser + 'Program.ini' );
  if not Ini.ReadBool( cProgram, cMenu        , true ) then mItmViewMenu.Click;
  if not Ini.ReadBool( cProgram, cSubInterface, true ) then mItmViewAutoSubInterface.Click;
  if not Ini.ReadBool( cProgram, cIndentThen  , true ) then mItmViewIndentThen.Click;
  if not Ini.ReadBool( cProgram, cCutComments , true ) then mItmViewCutComment.Click;
  Ini.Free;

  b := false;
//  try
         Viewer.img := TBitmap.Create;
         var DivTry: integer := 1;
         repeat
           try    Viewer.img.SetSize( Min( cStrukWidth, Screen.Width ), cStrukHeight div DivTry );
                  {$IFDEF TraceDx} TraceDx.Call( 'Nassi Height', cStrukHeight div DivTry ); {$ENDIF}
                  b := true
           except inc( DivTry )    // Hier bleibt von der Exception ein (oder mehrere) MemoryLeak
           end;
         until b; //false;
//  except Error( erStructSize, '' )
//  end;
  Viewer.img.Canvas.Font := Font;
  TViewer.SetFont( 0 );    // 0 == kein Delta zu Default
end;

(* OnAllCreated *)
procedure OnAllCreatedNassi;
begin
  {$IFDEF TraceDx} TraceDx.Call( 'OnAllCreatedNassi' ); {$ENDIF}
  if not OptionRefCalled then begin
    DragAcceptFiles( frmNassi.Handle, true );    // an's Ende weil "Handle" vorher nicht stabil ist?
    Application.OnActivate := frmNassi.ApplicationEventsActivate
    end;
  if ParaCount > 0 then begin
    if not OptionRefCalled then  // der macht nämlich gleich ein eigenes ShowModal()
      frmNassi.Show;
    LoadFile( TPath.GetFullPath( ParaStr[1] ));  // eParameter kann relativ sein
    if ( ParaCount >= 2 ) and ( ParaStr[2][0] <> '-' )
      then Source.Proc := ParaStr[2];
    ProcessSource;
    ParaCount := 0     // Aufrufparameter gelten nur für diese erste Datei
    end;
end;

(* ApplicationEventsActivate *)
procedure TfrmNassi.ApplicationEventsActivate( Sender: TObject );
var ParaProc: string;
begin
  {$IFDEF TraceDx} TraceDx.Send( 'ApplicationEventsActivate' ); {$ENDIF}
  if InActivate
    then exit    // nicht doppelt aufrufen
    else InActivate := true;
  if ( Source.Name <> EmptyStr ) and
     ( TFile.GetLastWriteTime( Source.Name ) <> Source.Date ) then
    if MessageDlg( 'Source changed. Reparse?', mtWarning, mbOKCancel, 0 ) = mrOK then begin
      ParaProc := Source.Proc;    // wird in LoadFile leider gelöscht
      LoadFile( Source.Name );
      if ( ParaProc <> '' ) and not ParaProc[0].IsDigit
        then Source.Proc := ParaProc;
      ProcessSource;
      PaintBox.Invalidate  // Event kommt hier nicht von selbst
      end
    else
      Source.Date := TFile.GetLastWriteTime( Source.Name );
  InActivate := false
end;

(* WMDROPFILES *)
procedure TfrmNassi.WMDROPFILES( var Msg: TMessage );
{ Ausserdem "DragAcceptFiles" in FormCreate eintragen }
{ R014 aus Buch Borland Delphi3 für Profis: }
var size     : integer;
    Dateiname: PChar;
begin
  {$IFDEF TraceDx} TraceDx.Send( 'WMDROPFILES' ); {$ENDIF}
  inherited;
  size := DragQueryFile( Msg.WParam, 0 , nil, 0 ) + 1;
  Dateiname := StrAlloc( size );
  DragQueryFile( Msg.WParam, 0, Dateiname, size );
  DragFinish( Msg.WParam );
  if not scanning then begin
    Application.BringToFront;
    Application.OnActivate := nil;                          // kurz mal ausschalten damit
    LoadFile( StrPas( Dateiname ));                         // im LoadFile -> Application.ProcessMessages
    ProcessSource;                                          // (und auch hier )
    Application.OnActivate := ApplicationEventsActivate;    // nicht "ApplicationEventsActivate" kommt
    PaintBox.Repaint
    end;
  StrDispose( Dateiname )
end;

(* DoStartBatch *)
procedure DoStartNassiBatch;
begin
  {$IFDEF TraceDx} TraceDx.Send( 'DoStartBatch' ); {$ENDIF}
  OptionBatchMode := true;
  LoadFile( TPath.GetFullPath( ParamStr( 1 ) ));
  if ( ParamCount >= 2 ) and ( ParamStr( 2 )[0] <> '-' )
    then Source.Proc := ParamStr( 2 );
  ProcessSource
end;

(* mItmFileOpenClick *)
procedure TfrmNassi.mItmFileOpenClick( Sender: TObject );
begin
  if OpenDialog.Execute then begin
    LoadFile( OpenDialog.Filename );
    ProcessSource
    end;
end;

(* mItmFileOpenClipClick *)
procedure TfrmNassi.mItmFileOpenClipClick( Sender: TObject) ;
var s: TStringDynArray;
    f: string;
begin
  if Clipboard.HasFormat( CF_TEXT ) then begin
    s := Clipboard.AsText.Split( [sLineBreak, #10] );
    f := TPath.GetTempPath + 'NassiFromClip.pas';
    TFile.WriteAllLines( f, s );
    LoadFile( f );
    FromClipBoard := true;
    ProcessSource
    end;
end;

(* mItmFileRecentClick *)
procedure TfrmNassi.mItmFileRecentClick( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'mItmFileRecentClick', TMenuItem( Sender ).Caption ); {$ENDIF}
  LoadFile( TMenuItem( Sender ).Hint );
  ProcessSource
end;

{$ENDREGION}

{$REGION '-------------------- Search -------------------- ' }

(* Init *)
procedure TSearch.Init;
begin
  Pos.sp   := -1;
  ArtIndex := -1;
end;

(* getSearchText *)
function TSearch.getSearchText: boolean;
begin
  Search.SuchText := InputBox( 'Search for Text', 'Enter Text', Search.SuchText );
  Result := Search.SuchText <> '';
  if not Result then begin
    DeleteLastSearch;
    BerechneNassi
    end
end;

(* DeleteLastSearch *)
procedure TSearch.DeleteLastSearch;
begin
  { falls vorhanden altes Suchergebnis löschen: }
  if ArtIndex <> -1 then begin
    move( TextArtArray[ArtIndex+2], TextArtArray[ArtIndex], ( MaxTextArtIdx - ArtIndex + 1{das Ende-Element} ) * sizeOf( TextArtArray[0] ));
    ArtIndex := -1
    end
end;

(* SetCursor *)
procedure TSearch.SetCursor;
var p: pBlockInfo;
begin
  {$IFDEF TraceDx} TraceDx.Send( 'SetCursor' ); {$ENDIF}
  p := TBlock.SearchBlockByTextPos( Pos );
  CursorBlock.pStart := p;
  if p <> nil then begin
    repeat CursorBlock.pStart := CursorBlock.pStart^.Prev
    until CursorBlock.pStart^.Typ in ( btSubView + [btMain] );
    CursorBlock.pEnde := CursorBlock.pStart;
    frmNassi.pItmSubViewEnterClick( nil );
    CursorBlock.pStart := p;
    { ScrollBar passend setzen: }
    ScrollBlock( p );
    end;
  CursorBlock.pEnde := p
end;

(* DoSearch *)
function TSearch.DoSearch: boolean;
var s: string;
begin
  {$IFDEF TraceDx} TraceDx.Send( 'DoSearch', Pos.ze, Pos.sp ); {$ENDIF}
  Result := true;
  s := SuchText.ToLower;
  Pos.sp := source.Lines[pos.ze].ToLower.IndexOf( s, Pos.sp );
  if Pos.sp = -1 then begin
    inc( Pos.ze );
    while Pos.ze <= Source.EndLine do begin
      Pos.sp := source.Lines[pos.ze].ToLower.IndexOf( s );
      if Pos.sp = -1
        then inc( Pos.ze )
        else break
      end;
    Result := Pos.sp <> -1
    end;
  if Result then
    Found
end;

(* Found *)
procedure TSearch.Found;
begin
  {$IFDEF TraceDx} TraceDx.Send( 'TSearch.Found', Pos.ze, Pos.sp ); {$ENDIF}
  ArtIndex := 0;
  repeat inc( ArtIndex ) until ( TextArtArray[ArtIndex].Pos.ze >= Pos.ze ) and
                              (( TextArtArray[ArtIndex].Pos.ze >  Pos.ze ) or ( TextArtArray[ArtIndex].Pos.sp >= Pos.sp ));
  move( TextArtArray[ArtIndex], TextArtArray[ArtIndex+2], ( MaxTextArtIdx - ArtIndex + 1{das Ende-Element} ) * sizeOf( TextArtArray[0] ));
  TextArtArray[ArtIndex  ].Pos := Pos;
//    TextArtArray[ArtIndex  ].Art := artSearch;    bleibt gleich
  TextArtArray[ArtIndex+1].Pos := Pos; inc( TextArtArray[ArtIndex+1].Pos.sp, length( SuchText ));
  TextArtArray[ArtIndex+1].Art := artSearch;
  TextArtArray[ArtIndex+2].Art := TextArtArray[ArtIndex].Art;
  SetCursor
end;

(* DoF3Search *)
procedure TSearch.DoF3Search;
var ArtIndexWasSet: boolean;
begin
  {$IFDEF TraceDx} TraceDx.Send( 'DoF3Search' ); {$ENDIF}
  ArtIndexWasSet := ArtIndex <> -1;
  Search.DeleteLastSearch;
  if ( CursorBlock.pStart <> nil ) and not TBlock.TextPosInBlock( Pos, CursorBlock.pStart )
    then Pos := CursorBlock.pStart^.TxtStart
    else inc( Pos.sp );
  if not DoSearch then begin
    Pos.ze := Source.StartLine;
    Pos.sp := 0;
    if not DoSearch then begin
      if ArtIndexWasSet then BerechneNassi;
      ShowMessage( '"' + SuchText + '" not found' )
      end
    end
end;

(* pItmSearchTextClick *)
procedure TfrmNassi.pItmSearchTextClick( Sender: TObject );
begin
  if Search.getSearchText then
    Search.DoF3Search
end;

{$ENDREGION}

{$REGION '-------------------- Form -------------------- ' }

(* FormKeyDown *)
procedure TfrmNassi.FormKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
var w: integer;

begin
  {$IFDEF TraceDx} if Key in [VK_SHIFT, VK_CONTROL, VK_MENU]
                then exit
                else TraceDx.Call( 'FormKeyDown', Key ); {$ENDIF}

  if ( Source.Name <> EmptyStr ) or ( Key = VK_ESCAPE ) or ( Key = VK_F1 ) or ( Key = VK_F4 ) then
    case Key of
      VK_ESCAPE  : if ( pSubView = nil ) or ( pSubView^.Typ = btMain )
                     then Close
                     else pItmSubViewLeaveClick( nil );
      VK_RETURN  : begin
                     PopupMenuPopup( nil );
                     if pItmSubViewEnter.Enabled
                       then pItmSubViewEnterClick( nil )
                   end;
      VK_BACK    : if pSubView^.Typ <> btMain
                     then pItmSubViewLeaveClick( nil );
      VK_INSERT  : begin
                     PopupMenuPopup( nil );
                     if pItmSubViewCreate.Enabled then
                       pItmSubViewCreateClick( nil )
                   end;
      VK_DELETE  : begin
                     PopupMenuPopup( nil );
                     if pItmSubViewDestroy.Enabled then
                       pItmSubViewDestroyClick( nil )
                   end;
      ord( 'C' ) : if ssCtrl in Shift then begin
                     PopupMenuPopup( nil );
                     if pItmCopyText.Enabled then
                       pItmCopyTextClick( nil )
                     end;
      ord( 'F' ) : if ssCtrl in Shift then
                     pItmSearchTextClick( nil );
      VK_F3      : begin
                     if Search.SuchText = ''
                       then if not Search.getSearchText then exit;
                     Search.DoF3Search
                   end;
      VK_F2      : if ssCtrl in Shift
                     then mItmFileSaveAllClick( nil )
                     else mItmFileSaveOneClick( nil );
      {$IFDEF DEBUG}
      VK_F9      : if ssCtrl in Shift then begin
                     LoadFile( Source.Name );
                     ProcessSource;
                     PaintBox.Invalidate  // Event kommt hier nicht von selbst
                     end
                   else
                     TDiagnose.SaveBlocksToFile;
      {$ENDIF}
      VK_F1      : if ssShift in Shift
                     then mItmHelpInfoClick( nil )
                     else mItmHelpHelpClick( nil );
      VK_F4      : if ssAlt in Shift then
                     Close
                   else
                     if ssCtrl in Shift
                       then mItmFileOpenClipClick( nil )
                       else mItmFileOpenClick    ( nil );
      VK_F11     : if ssCtrl  in Shift then mItmOptionsSaveSubViewsLocal.Checked := not mItmOptionsSaveSubViewsLocal.Checked else
                   if ssShift in Shift then mItmOptionsSaveGlobalClick( nil )
                                       else mItmOptionsSaveVisualClick( nil );
      VK_F12     : mItmViewFullScreenClick( nil );
      VK_ADD,
      VK_SUBTRACT: if ssCtrl in Shift then begin
                     if Key = VK_ADD
                       then                       begin Font.Height := Font.Height - 1; TViewer.SetFont( -1 ) end
                       else if Font.Size > 8 then begin Font.Height := Font.Height + 1; TViewer.SetFont( +1 ) end;
                     BerechneNassi
                     end
                   else
                     if Key = VK_ADD
                       then Width := Width + Screen.Width div 10
                       else Width := Width - Screen.Width div 10;
  //                   FormResize( nil )            // wird automatisch aufgerufen
      VK_LEFT,
      VK_RIGHT   : if ( ssAlt in Shift ) and ( CursorBlock.pStart <> nil ) and ( CursorBlock.pStart = CursorBlock.pEnde ) and ( CursorBlock.pStart^.Typ = btIf ) then begin
                     w := Viewer.img.Canvas.TextWidth( 'M' );   // eigentlich in TextSize.CharWidth
                     with CursorBlock.pStart^ do
                       if Key = VK_LEFT then
                         if ThenBreite < 0
                           then inc( ThenBreite, w )
                           else ThenBreite := - ( Sub^.Rect.Right - Sub^.Rect.Left - w )
                       else
                         if ThenBreite < 0
                           then dec( ThenBreite, w )
                           else ThenBreite := - ( Sub^.Rect.Right - Sub^.Rect.Left + w );
                     BerechneNassi
                     end;
      {$IFDEF TraceDx}
      VK_F8      : if ssCtrl in Shift
                     then TraceDx.Clear
                     else TraceDx.Line;
      {$ENDIF}
      end;
end;

(* FormKeyUp *)
procedure TfrmNassi.FormKeyUp( Sender: TObject; var Key: Word; Shift: TShiftState );
begin
  {$IFDEF TraceDx} TraceDx.Send( 'FormKeyUp', Key ); {$ENDIF}
  case Key of
    VK_F10     : mItmViewMenuClick( nil )
    end
end;

(* FormMouseWheel *)
procedure TfrmNassi.FormMouseWheel( Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean );
begin
  {$IFDEF TraceDx} TraceDx.Send( 'FormMouseWheel', WheelDelta, WHEEL_DELTA ); {$ENDIF}
  { noch nicht in neue Version eingeflossen: }
  ScrollBar.Position := ScrollBar.Position - ( WheelDelta div WHEEL_DELTA ) * ScrollBar.SmallChange
end;

(* FormResize *)
procedure TfrmNassi.FormResize( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'FormResize' ); {$ENDIF}
  mItmViewFullScreen.Checked := WindowState = wsMaximized;
  mItmViewWidth80.Checked    := ClientWidth = TViewer.getBlockWidth80 + ScrollBar.Width + 5;
  if Source.Name <> EmptyStr then begin
    if PaintBox.ClientWidth <> aktPaintBoxWidth then begin
      aktPaintBoxWidth := PaintBox.ClientWidth;
      {$IFDEF TraceDx} TraceDx.Send( 'PaintBox.ClientWidth', aktPaintBoxWidth ); {$ENDIF}
      BerechneNassi
      end;
    ScrollBar.Max := Max( 0, aktStructHeight - PaintBox.ClientHeight );
    ScrollBar.LargeChange := 3 * PaintBox.ClientHeight div 4
    end
  else
    aktPaintBoxWidth := PaintBox.ClientWidth;
end;

{$ENDREGION}

{$REGION '-------------------- View -------------------- ' }

(* mItmViewFullScreenClick *)
procedure TfrmNassi.mItmViewFullScreenClick( Sender: TObject );
begin
  if WindowState = wsNormal
    then WindowState := wsMaximized
    else WindowState := wsNormal;
//  mItmViewFullScreen.Checked := WindowState = wsMaximized     wird im FormResize gesetzt
end;

(* mItmViewMenuClick *)
procedure TfrmNassi.mItmViewMenuClick( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Send( 'mItmViewMenuClick' ); {$ENDIF}
  if Menu = nil       // Achtung: danach ist Tastatur einmal blockiert
    then Menu := MainMenu
    else Menu := nil;
  Perform( WM_LBUTTONDOWN, 0, 0 );     // hierdurch wird eine komische Tastatur-Blockade aufgehoben
//Perform( WM_LBUTTONUP  , 0, 0 )      // darf nicht!
end;

(* mItmViewAutoSubInterfaceClick *)
procedure TfrmNassi.mItmViewAutoSubInterfaceClick( Sender: TObject );
begin
  SubInterface := mItmViewAutoSubInterface.Checked;
  if Source.Name <> EmptyStr then
    ShowMessage( 'Changed for next Sources' )
end;

procedure TfrmNassi.mItmViewCutCommentClick( Sender: TObject );
begin
  CutComment := mItmViewCutComment.Checked;
  if Source.Name <> EmptyStr then
    BerechneNassi
end;

(* mItmViewThenClick *)
procedure TfrmNassi.mItmViewIndentThenClick( Sender: TObject );
begin
  IndentThen := mItmViewIndentThen.Checked;
  if Source.Name <> EmptyStr then
    BerechneNassi
end;

(* mItmViewWidth80Click *)
procedure TfrmNassi.mItmViewWidth80Click( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Send( 'mItmViewWidth80Click' ); {$ENDIF}
  ClientWidth := TViewer.getBlockWidth80 + ScrollBar.Width + 5
end;

{$ENDREGION}

{$REGION '-------------------- NassiTabs -------------------- ' }

var
  NassiTabHandle: HWND = 0;

procedure DoSend( L: LPARAM );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'SndN', frmNassi.Handle, L ); {$ENDIF}
  if SendMessage( NassiTabHandle, WM_Nassi, frmNassi.Handle {Absenderkennung}, L ) > 0 then begin
    ShowMessage( 'Fehler in DoSend, Message = ' + L.ToString );
    halt
    end;
end;

procedure TfrmNassi.NassiMessage( var Msg: TMessage );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'RcvN', Msg.LParamLo, Msg.LParamHi ); {$ENDIF}
  case tMessages( Msg.WPARAM ) of
    SendPanelHandle: begin
                       NassiTabHandle := Msg.LParam;
                       DoSend( Panel.Handle );
//                       Application.MainFormOnTaskBar := false;
//                       Hide
                     end;
    GetPanelHandle : ; // für NassiTabs
    DoSetBounds    : SetBounds( Left, Top, Msg.LParamLo, Msg.LParamHi );
    else             ShowMessage( 'Fehler in NassiMessage = ' + Msg.Msg.ToString );
                     halt
    end
end;

{$ENDREGION}

{$REGION '-------------------- Options -------------------- ' }

(* mItmOptionsSaveVisualClick *)
procedure TfrmNassi.mItmOptionsSaveVisualClick( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Send( 'mItmOptionsSaveVisualClick' ); {$ENDIF}
  TIni.WriteForm( Self );
end;

(* mItmOptionsSaveGlobalClick *)
procedure TfrmNassi.mItmOptionsSaveGlobalClick( Sender: TObject );
const cProgram = 'Program';
var Ini: TMemIniFile;
begin
  {$IFDEF TraceDx} TraceDx.Send( 'mItmOptionsSaveGlobalClick' ); {$ENDIF}
  Ini := tMemIniFile.Create( TMyApp.DirUser + 'Program.ini' );
  Ini.WriteString( cProgram, cProgName    , cVersion     );
  Ini.WriteBool  ( cProgram, cMenu        , Menu <> nil  );
  Ini.WriteBool  ( cProgram, cSubInterface, SubInterface );
  Ini.WriteBool  ( cProgram, cIndentThen  , IndentThen   );
  Ini.WriteBool  ( cProgram, cCutComments , CutComment   );
  Ini.Free;
end;

(* mItmOptionsSaveSubViewsLocalClick *)
procedure TfrmNassi.mItmOptionsSaveSubViewsLocalClick( Sender: TObject );
var s: string;
begin
  {$IFDEF TraceDx} TraceDx.Send( 'mItmOptionsSaveSubViewsLocalClick', mItmOptionsSaveSubViewsLocal.Checked ); {$ENDIF}
  if mItmOptionsSaveSubViewsLocal.Checked then begin
    if Source.Proc = ''
      then s := Source.Name +                     '.' + cProgNameExt
      else s := Source.Name + '.' + Source.Proc + '.' + cProgNameExt;
    if TFile.Exists( TMyApp.DirUser + CurrentDirAsFileName + s ) then
      CopyFile( pChar( TMyApp.DirUser + CurrentDirAsFileName + s ), pChar( s ), false )
    end
end;

{$ENDREGION}

{$REGION '-------------------- Help -------------------- ' }

(* mItmHelpHelpClick *)
procedure TfrmNassi.mItmHelpHelpClick( Sender: TObject );
var s: string;
begin
  s := TMyApp.DirExe + {$IFDEF Pascal86} 'Nassi' {$ELSE} cProgName {$ENDIF} + 'Help.txt';
  if TFile.Exists( s ) then begin
    if not assigned( frmNassiHelp ) then begin
      frmNassiHelp := tfrmNassiHelp.Create( frmNassi );
      frmNassiHelp.Caption := 'Hilfe für ' + cProgName;
      frmNassiHelp.MemoHelp.Lines.LoadFromFile( s );
      frmNassiHelp.MemoHelp.Perform( EM_LINESCROLL, 0, frmNassiHelp.MemoHelp.Lines.IndexOf( 'Bedienung' ) )
      end;
    if Sender = nil
      then frmNassiHelp.ShowModal
      else frmNassiHelp.Show
    end
  else
    ShowMessage( 'Hilfe "' + s + '" nicht gefunden' )
end;

(* mItmHelpInfoClick *)
procedure TfrmNassi.mItmHelpInfoClick( Sender: TObject );
begin
  MessageDlg( cProgName + ' ' + cVersion + sLineBreak + sLineBreak + cMailTo, mtInformation, [mbOK], 0 )
end;

{$ENDREGION}

initialization
  {$IFDEF TraceDx}
    TraceDx.Send( 'initialization u_Nassi' );
  {$ENDIF}
  // https://docs.microsoft.com/en-us/windows/win32/api/errhandlingapi/nf-errhandlingapi-seterrormode
//  SetErrorMode( SEM_FAILCRITICALERRORS );
  TMyApp.Init( cProgName, cVersion, '2'  )

end.

