
unit uViewer;
{$INCLUDE _CompilerOptions.pas}
//{$UNDEF TraceDx}

interface

uses
  Vcl.Graphics,
  Vcl.ExtCtrls,
  uGlobalData;


type
  tTextRecord = record
                  Pos: tSourcePos;
                  Art: tTextArt
                end;    { diese TextArt gilt bis VOR diese TextPosition }

  TViewer     = record
                  img: TBitmap;
                  class procedure Init; static;
                  class function  getBlockWidth80: integer; static;
                  class function  PaintBlocks( w: integer ): integer; static;
                  class procedure SetFont( d: integer ); static;
                  class procedure SetCursorBlock( x, y: integer ); static;
                  class procedure IncCursorBlock(x, y: integer); static;
                  class function  TestInCursorBlocks( x, y: integer ): boolean; static;
                  class procedure SubViewCreate( var c: tCursorBlock; typ: tBlockTyp ); static;
                  class procedure SubViewDestroy( d: pBlockInfo ); static;
                  class function  getPrevSubView: pBlockInfo; static;
                  class procedure EnterAuslagerung( p: pBlockInfo; var scp: integer ); static;
                  class procedure LeaveAuslagerung( var scp: integer ); static;
                  class procedure SetHeader( p: pBlockInfo ); static;
                  class function  CursorMakeReal( var c: tCursorBlock ): boolean; static;
                end;


var
  Viewer        : TViewer;
  IndentThen    : boolean = true;
  CutComment    : boolean = true;
  CursorBlock   : tCursorBlock;
  TextArtArray  : array of tTextRecord;
  MaxTextArtIdx : integer;
  pSubView      : pBlockInfo = nil;
  SubViewCnt    : array[btSubViewFix..btSubViewAuto] of integer;


implementation

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Character,
  {$IFDEF TraceDx} uTraceDx, {$ENDIF}
  uBlock,
  uDiagnose;

const
  cTextLinksDelta =  3;
  cTextObenDelta  =  3;
  cLevelDelta     = 16;

var
  TextSize        : record
                      CharWidth,
                      TextStdHeight,
                      FontHeightStd,
                      FontHeightMini,
                      BlockEmpty,
                      BlockWidthMin,
                      BlockWidthMinIf: integer
                    end;

  AktTextArtIdx   : integer;
  AktTextArt      : tTextRecord;


{ TViewer.Init }
class procedure TViewer.Init;
begin
  {$IFDEF TraceDx} TraceDx.Send( 'TViewer.Init' ); {$ENDIF}
  CursorBlock.pStart        := nil;
  CursorBlock.pEnde         := nil;
  SubViewCnt[btSubViewFix ] := 0;
  SubViewCnt[btSubViewAuto] := 0;
  pSubView                  := TBlock.getbyIndex( 0 );
  pSubView^.SubInfo.Header  := 'main'
end;

{ TViewer.getBlockWidth80 }
class function TViewer.getBlockWidth80: integer;
begin
  Result := 80 * TextSize.CharWidth + cTextLinksDelta + 1 { siehe CharsPerLine } + 3 { für Rect_Linien }
end;

{ TViewer.SetFont }
class procedure TViewer.SetFont( d: integer );
begin
  with TextSize, Viewer.img.Canvas do begin
    assert( Font.Height < 0 );
    FontHeightStd   := Font.Height + d;
    Font.Height     := FontHeightStd;
    FontHeightMini  := FontHeightStd div 2 - 2;
    CharWidth       := TextWidth ( 'M' );
    TextStdHeight   := TextHeight( 'M' ) + 2;
    BlockEmpty      := TextWidth ( ' else ' );
    BlockWidthMin   := BlockEmpty shl 1;
    BlockWidthMinIf := BlockWidthMin shl 1;
    {$IFDEF TraceDx} TraceDx.Send( 'TViewer.SetFont', TextStdHeight ) {$ENDIF}
    end;
end;

{ TViewer.SetHeader }
class procedure TViewer.SetHeader( p: pBlockInfo );
var i,j: tSourcePosIdx;
begin
  p^.SubInfo.Header := Source.Lines[p^.TxtStart.ze].Substring( p^.TxtStart.sp );
  case p^.Sub^.Typ of
    btProc: begin
              j := p^.TxtStart.ze;
              repeat
                i := p^.SubInfo.Header.IndexOfAny( [')',';'] );
                if i = -1 then begin
                  inc( j );
                  p^.SubInfo.Header := p^.SubInfo.Header + Source.Lines[j]
                  end
              until i <> -1;
              p^.SubInfo.Header := p^.SubInfo.Header.Substring( 0, i + 1 )
            end;
    btIf, btCase, btFor, btWhile, btCaseSel, btWith, btOn:
            if p^.Sub^.Sub^.TxtStart.ze = p^.Sub^.TxtStart.ze then
              p^.SubInfo.Header := p^.SubInfo.Header.Substring( 0, p^.Sub^.Sub^.TxtStart.sp - p^.Sub^.TxtStart.sp ).TrimRight
    end
end;

{ SearchBlock }
function SearchBlock( x, y: integer ): pBlockInfo;

  function DoSearch( b: pBlockInfo ): pBlockInfo;
  var pThen, pElse: pBlockInfo;
  begin
    Result := b;
    while ( Result <> nil ) and ( Result^.Rect.Bottom < y ) do
      Result := Result^.Next;

    if Result <> nil then
      if ( Result^.Sub <> nil )             and       // falls Sub vorhanden
         not ( Result^.Typ in btSubView )   and       // ... aber nicht SubView
         ( Result^.Sub^.Rect.Top < y )      then      // ... und wirklich Sub-Header, also nicht überm ersten SubBlock

        if x <= Result^.Sub^.Rect.Left then
          { im prev bleiben }
        else
          if Result^.Typ = btIf then begin
            pThen := Result^.Sub;                     // Sonderfall IF:
            TBlock.getThenElse( pThen, pElse );
            if x < pThen^.Rect.Right then begin       // links-rechts - Aufteilung
              Result := DoSearch( pThen );
              if ( Result <> nil ) and ( Result^.Rect.Left > x ) then
                Result := nil                         // bin bis in die else-nexte durchgerutscht weil then-Zweig weniger hoch als else
              end
            else
              Result := DoSearch( pElse )
            end
          else
            Result := DoSearch( Result^.Sub )    // Normalfall
  end;

begin
  {$IFDEF TraceDx} TraceDx.Send( 'SearchBlock', x, y ); {$ENDIF}
  Result := DoSearch( pSubView^.Sub )
end;

{ TViewer.SetCursorBlock }
class procedure TViewer.SetCursorBlock( x, y: integer );
var p: pBlockInfo;
begin
  CursorBlock.pStart := SearchBlock( x, y );
  if CursorBlock.pStart = nil then
    CursorBlock.pEnde := nil
  else
    case CursorBlock.pStart^.Typ of
      btBegin : begin
                  CursorBlock.pEnde := CursorBlock.pStart;
                  repeat CursorBlock.pEnde := CursorBlock.pEnde ^.Next
                  until  CursorBlock.pEnde^.Typ = btEnd
                end;
      btEnd   : begin
                  CursorBlock.pEnde := CursorBlock.pStart;
                  p := CursorBlock.pEnde^.Prev^.Sub;
                  repeat if p^.Typ = btBegin
                           then CursorBlock.pStart := p;
                         p := p^.Next
                  until  p = CursorBlock.pEnde
                end;
      btRepeat: begin
                  CursorBlock.pEnde := CursorBlock.pStart;
                  repeat CursorBlock.pEnde := CursorBlock.pEnde ^.Next
                  until  CursorBlock.pEnde^.Typ = btUntil
                end;
      btUntil : begin
                  CursorBlock.pEnde := CursorBlock.pStart;
                  p := CursorBlock.pEnde^.Prev^.Sub;
                  repeat if p^.Typ = btRepeat
                           then CursorBlock.pStart := p;
                         p := p^.Next
                  until  p = CursorBlock.pEnde
                end
      else      CursorBlock.pEnde := CursorBlock.pStart
      end;
end;

{ TViewer.IncCursorBlock }
class procedure TViewer.IncCursorBlock( x, y: integer );
var p,q: pBlockInfo;
begin
  p := SearchBlock( x, y );
  if ( p <> nil ) and ( p^.Prev = CursorBlock.pStart^.Prev ) then begin
    q := CursorBlock.pEnde^.Next; while ( q <> nil ) and ( q <> p ) do q := q^.Next;   // liegt der neue HINTER ptEnde?
    if q = nil then begin
      q := p; while ( q <> nil ) and ( q <> CursorBlock.pStart ) do q := q^.Next end;  // liegt der neue VOR pStart?

    if q <> nil then   // falls in der gleichen next-Ebene gefunden:
      if q = CursorBlock.pStart
        then CursorBlock.pStart := p
        else CursorBlock.pEnde  := p
    end
end;

{ TViewer.TestInCursorBlocks }
class function TViewer.TestInCursorBlocks( x, y: integer ): boolean;
begin
  Result := ( CursorBlock.pStart <> nil )           and
            ( y > CursorBlock.pStart^.Rect.Top    ) and
            ( y < CursorBlock.pEnde ^.Rect.Bottom ) and
            ( x > CursorBlock.pStart^.Rect.Left   ) and
            ( x < CursorBlock.pStart^.Rect.Right  )
end;

{ TViewer.SubViewCreate }
class procedure TViewer.SubViewCreate( var c: tCursorBlock; typ: tBlockTyp );
var pp: ^pBlockInfo;
    a : tLineCount;
    n : tBlockIndex;
begin
  {$IFDEF TraceDx} TraceDx.Send( 'TViewer.SubViewCreate ' + TBlock.getBlockTyp( typ ), c.pStart^.Nr ); {$ENDIF}
  { Vorgänger suchen: }
  pp := @c.pStart^.Prev^.Sub;
  while pp^ <> c.pStart do pp := @pp^.Next;
  { neuen Block init: }
  pp^            := TBlock.NewBlock;
  n              := pp^^.Nr;
  pp^^           := c.pStart^;        // erstmal alles übernehmen, dann korrigieren
  pp^^.Nr        := n;
  pp^^.Typ       := typ;
  pp^^.Next      := c.pEnde^.Next;
  pp^^.Sub       := c.pStart;
  pp^^.TxtZeilen := 1;
  pp^^.SubZeilen := 1;
  c.pEnde^.Next  := nil;
  { verkleinerte SubZeilen berechnen: }
  a := 0;
  TBlock.ForAllCursorBlocks( c, procedure ( p: pBlockInfo )
    begin
      p^.Prev := pp^;               // prev zeigt jetzt auf den btSubViewAnchor
      inc( a, p^.Subzeilen )
    end );
  if typ <> btSubViewTmp then         // hochrechnen dieses neuen Subs ist für tmps nicht notwendig weil sie nie "von oben" gesehen werden
    { ... und hochmelden: }
    TBlock.SetSubZeilenUp( pp^.Prev, 1 - a );
  { Cursor auf den neuen SubView-Anker setzen: }
  c.pStart := pp^;
  c.pEnde  := pp^;
  { automatischer Text für SubView-Beschreibung: }
  SetHeader( pp^ )
end;

{ TViewer.SubViewDestroy}
class procedure TViewer.SubViewDestroy( d: pBlockInfo );
var pp: ^pBlockInfo;
    p : pBlockInfo;
    a : tLineCount;
begin
  {$IFDEF TraceDx} TraceDx.Send( 'TViewer.SubViewDestroy', d^.Nr ); {$ENDIF}
  { Vorgänger suchen: }
  pp := @d^.Prev^.Sub;
  while pp^ <> d do pp := @pp^.Next;
  { dort wieder einhängen: }
  p := d^.Sub;
  while p^.Next <> nil do p := p^.Next;  // letzten ausgeblendeten Block suchen
  p^.Next := d^.Next;
  pp^ := d^.Sub;
  { Cursor auf die ehemaligen SubView-Blöcke setzen: }
  CursorBlock.pStart := pp^;
  CursorBlock.pEnde  := p;
  { wieder echte SubZeilen berechnen: }
  a := 0;
  TBlock.ForAllCursorBlocks( CursorBlock, procedure ( p: pBlockInfo )
    begin
      p^.Prev := d.Prev;               // prev zeigt jetzt wieder auf den bt über dem SubView
      inc( a, p^.Subzeilen )
    end );
  if d^.Typ <> btSubViewTmp then
    { ... und hochmelden: }
    TBlock.SetSubZeilenUp( pp^.Prev, a - 1 );
  TBlock.FreeBlock( d )
end;

{ CursorMakeReal }
class function TViewer.CursorMakeReal( var c: tCursorBlock ): boolean;
{ falls btSubAuto im pStart oder pEnde: auf den echten Block umstellen: }
begin
  if ( c.pStart <> nil ) and (( c.pStart^.Typ in [btSubViewAuto,btSubViewTmp] ) or ( c.pEnde^.Typ in [btSubViewAuto,btSubViewTmp] )) then begin
    {$IFDEF TraceDx} TraceDx.Send( 'CursorMakeRealIn ', TBlock.getBlockTyp( c.pStart^.Typ ) + '-' + TBlock.getBlockTyp( c.pEnde^.Typ ) ); {$ENDIF}
    while c.pStart^.Typ in [btSubViewAuto,btSubViewTmp] do c.pStart := c.pStart^.Sub;
    while c.pEnde ^.Typ in [btSubViewAuto,btSubViewTmp] do begin
      c.pEnde  := c.pEnde ^.Sub;
      while c.pEnde^.Next <> nil do c.pEnde := c.pEnde^.Next
      end;
    {$IFDEF TraceDx} TraceDx.Send( 'CursorMakeRealOut', TBlock.getBlockTyp( c.pStart^.Typ ) + '-' + TBlock.getBlockTyp( c.pEnde^.Typ ) ); {$ENDIF}
    Result := true
    end
  else
    Result := false
end;

{ CursorMakeReal }
class function TViewer.getPrevSubView: pBlockInfo;
begin
  Result := pSubView;
  repeat Result := Result^.Prev
  until Result^.Typ in ( btSubView + [btMain] )
end;

{ CursorMakeVisible }
procedure CursorMakeVisible( var c: tCursorBlock );
{$IFDEF TraceDx} var b: boolean; {$ENDIF}
begin
  if c.pStart <> nil then begin
    {$IFDEF TraceDx}
    b := not ( flVisible in c.pStart^.FlagsRun ) or not ( flVisible in c.pEnde^.FlagsRun );
    if b then
      TraceDx.Send( 'CursorMakeVisibleIn ', TBlock.getBlockTyp( c.pStart^.Typ ) + '-' + TBlock.getBlockTyp( c.pEnde^.Typ ) );
    {$ENDIF}
    while not ( flVisible in c.pStart^.FlagsRun ) do
      { der Cursor-Block ist durch SubViewAuto tiefer gerutscht und nicht sichtbar. Hochholen: }
      c.pStart := c.pStart^.Prev;
    while not ( flVisible in c.pEnde^.FlagsRun ) do
      c.pEnde  := c.pEnde^.Prev;
    {$IFDEF TraceDx} if b then TraceDx.Send( 'CursorMakeVisibleOut ', TBlock.getBlockTyp( c.pStart^.Typ ) + '-' + TBlock.getBlockTyp( c.pEnde^.Typ ) ); {$ENDIF}
    {$IFDEF DEBUG} assert( ( c.pStart^.Nr <> 0 ) and ( c.pEnde^.Nr <> 0 ), 'CursorMakeVisible' ) {$ENDIF}
    end
end;

{ TViewer.EnterAuslagerung }
class procedure TViewer.EnterAuslagerung( p: pBlockInfo; var scp: integer );
begin
  {$IFDEF TraceDx} TraceDx.Send( 'TViewer.EnterAuslagerung', p^.Nr ); {$ENDIF}
  { aktuelle Daten im alten View speichern: }
  pSubView^.SubInfo.ScrollPos := scp;
  { in SubView gehen: }
  pSubView := p;
  { gespeicherte Daten dieses SubView restaurieren: }
  CursorBlock := pSubView^.SubInfo.Cursor;
  scp         := pSubView^.SubInfo.ScrollPos
end;

{ TViewer.LeaveAuslagerung }
class procedure TViewer.LeaveAuslagerung( var scp: integer );
begin
  {$IFDEF TraceDx} TraceDx.Send( 'TViewer.LeaveAuslagerung' ); {$ENDIF}
  if pSubView^.Typ in [btMain, btSubViewFix] then begin
    { aktuelle Daten im SubView speichern: }
    pSubView^.SubInfo.Cursor := CursorBlock;
    CursorMakeReal( pSubView^.SubInfo.Cursor );
    pSubView^.SubInfo.ScrollPos := scp
    end;
  { neuer Cursor zeigt auf alten SubView: }
  CursorBlock.pStart := pSubView;
  CursorBlock.pEnde  := CursorBlock.pStart;
  { SubView verlassen: }
  pSubView := getPrevSubView;
  { gespeicherte Daten dieses MainView restaurieren: }
  scp := pSubView^.SubInfo.ScrollPos
end;

{ TViewer.PaintBlocks }
class function TViewer.PaintBlocks( w{Width}: integer ): integer;       // Result ist die Höhe
var LastWasSkipped: boolean;   // der vorige Block war SubView oder then,else,... und der Text wurde nciht ausgegeben.

  { DestroySubViewsDown }
  procedure DestroySubViewsDown( p: pBlockInfo );
  var n: pBlockInfo;
  { alle nicht-fixen Ausblendungen ab p zurücknehmen: }
  begin
    while p <> nil do begin
      exclude( p^.FlagsRun, flVisible );
      if p^.Sub <> nil then DestroySubViewsDown( p^.Sub );

      while p^.Typ in btSubView - [btSubViewFix] do begin
        n := p^.Sub;
        TViewer.SubViewDestroy( p );
        p := n
        end;

      p := p^.Next
      end;
  end;

  { getNextTextArt }
  procedure getNextTextArt;     // kann StartPos oder EndePos sein, kommt immer alternierend
  begin
    inc( AktTextArtIdx );
    AktTextArt := TextArtArray[AktTextArtIdx];
    Viewer.img.Canvas.Font.Color := clFontTextArt[AktTextArt.Art];
//    if AktTextArt.Art = artKeyword
//      then Viewer.img.Canvas.Font.Style := Viewer.img.Canvas.Font.Style + [fsBold]
//      else Viewer.img.Canvas.Font.Style := Viewer.img.Canvas.Font.Style - [fsBold]
//    {$IFDEF TraceDx} TraceDx.Send( 'getNextTextArt', AktTextArt.Pos.ze, AktTextArt.Pos.sp ) {$ENDIF}
  end;

  function ShowBlock( b: pBlockInfo; r: TRect ): integer;   // Result ist die Höhe
  const cThenElseText    : array[btThen..btElse]              of string = ( 'then', 'else' );
        cSubViewIndicator: array[btSubViewFix..btSubViewAuto] of string = ( #187#187#187#32, #187#32 );
  var ObenAlt: integer;
      c      : tCursorBlock;
      MyThen : pBlockInfo;

    { SkipTextArtTo }
    procedure SkipTextArtTo( ZeSp: tSourcePos );
    begin
      while ( ZeSp.ze > TextArtArray[AktTextArtIdx].Pos.ze ) do inc( AktTextArtIdx );
      while ( ZeSp.ze = TextArtArray[AktTextArtIdx].Pos.ze ) { innerhalb dieser Zeile suchen} and
            ( ZeSp.sp > TextArtArray[AktTextArtIdx].Pos.sp ) do inc( AktTextArtIdx )
    end;

    { getThenWidth }
    function getThenWidth( p: pBlockInfo ): integer;
    var Breite: integer;
    { berechnet für if-Block die then-else-Breite, gewichtet nach Verhältnis der SubZeilenD: }
    begin
      Breite := r.Right - r.Left;

      if p^.ThenBreite < 0 then      // manuell festgelegte absolute Breite
        if -p^.ThenBreite < TextSize.BlockWidthMin
          then begin Result := TextSize.BlockWidthMin; p^.ThenBreite := -Result end   else
        if -p^.ThenBreite > Breite - TextSize.BlockWidthMin
            then begin Result := Breite - TextSize.BlockWidthMin; p^.ThenBreite := -Result end
            else Result := -p^.ThenBreite

      else                      // automatisch festgelegte prozentuale Breite
        if p^.ThenBreite = 0 then
          Result := TextSize.BlockEmpty
        else
          if p^.ThenBreite = 100 then
            Result := Breite - TextSize.BlockEmpty
          else begin
            Result := Breite * p^.ThenBreite div 100;
            { then oder else zu schmal geworden? }
            if Result < TextSize.BlockWidthMin then
              Result := TextSize.BlockWidthMin
            else
              if Breite - Result < TextSize.BlockWidthMin then
                Result := Breite - TextSize.BlockWidthMin
            end;

      {$IFDEF TraceDx} TraceDx.Send( 'ThenBreite', Result, Breite ) {$ENDIF}
    end;


    { ShowBlockText }
    procedure ShowBlockText( w: integer );    { Breite }
    var CharsPerLine, i: tSourcePosIdx;

      procedure ShowSrcLine( Zeile, SpStart, SpEnde: tSourcePosIdx );
      { Zeile gemäß Blockbreite umbrechen: }
      var frei, pBlock, u: tSourcePosIdx;
          s              : string;

        function CheckUmbruch: tSourcePosIdx;
        { ... und dafür die günstigste Stelle suchen: }
        begin
          Result := CharsPerLine;
          while CharsPerLine - Result < Frei do
            if  ( s.Chars[pBlock+Result-1] <> ' ' ) and ( s.Chars[pBlock+Result] <> ' ' ) and
               (( s.Chars[pBlock+Result-1].IsLetterOrDigit or ( s.Chars[pBlock+Result-1] = '_' )) = ( s.Chars[pBlock+Result].IsLetterOrDigit or ( s.Chars[pBlock+Result] = '_' )))
              then dec ( Result )
              else exit;
          Result := CharsPerLine
        end;

        procedure ShowRectLine( const s: string );
        var anzahl, pLine: tSourcePosIdx;
            getNext: boolean;
        begin  { ShowRectLine }
//          {$IFDEF TraceDx} TraceDx.Send( 'ShowRectLine', pBlock, u ); {$ENDIF}
          pLine := pBlock;
          Viewer.img.Canvas.PenPos := Point( r.Left + cTextLinksDelta, r.Top );
          getNext := false;
          while pLine - pBlock < u do begin
            anzahl := u;
            if AktTextArt.Pos.ze = Zeile then

              if spStart + pLine + u >= AktTextArt.Pos.sp then begin
                getNext := true;
                anzahl  := AktTextArt.Pos.sp - ( spStart + pLine );
                end;                            // alles bis zur nächsten Umschaltung ...

            if pLine + anzahl > pBlock + u then begin
              getNext := false;
              anzahl  := pBlock + u - pLine;     // ... aber natürlich begrenzt auf Platz im Rechteck
              end;

//            {$IFDEF TraceDx} TraceDx.Send( 'ShowRectLinePart', s.Substring( pLine, anzahl ) ); {$ENDIF}
            if anzahl > 0 then begin
              Viewer.img.Canvas.TextOut( Viewer.img.Canvas.PenPos.x, r.Top, s.Substring( pLine, anzahl ) );
              inc( pLine, anzahl )
              end;

            if getNext then begin
              getNext := false;
              getNextTextArt
              end
            end;

          inc( r.Top, TextSize.TextStdHeight )
        end;  { ShowRectLine }

        function RestIsComment: boolean;
        begin
          Result := CutComment  and  ( AktTextArt.Art = artComment )  and  ( AktTextArt.Pos.ze > Zeile )
        end;

      begin { ShowSrcLine }
        s := Source.Lines[Zeile].Substring( SpStart, SpEnde - SpStart + 1 );
        {$IFDEF TraceDx} TraceDx.Send( 'ShowSrcLine: ' + s, CharsPerLine ); {$ENDIF}
        pBlock := 0;
        repeat
          Frei := CharsPerLine - (( length( s ) - pBlock ) mod CharsPerLine );    // bei voller Zeilennutzung wären am Blockende frei
          if pBlock + CharsPerLine > high( s ) then begin
            u := high( s ) - pBlock + 1;    // kein Umbruch notwendig
            ShowRectLine( s );
            break                           // fertig
            end
          else begin
            u := CheckUmbruch;              // kann ich Umbruch vorziehen ohne mehr Zeilen zu brauchen?
            ShowRectLine( s );
            if RestIsComment then begin     // falls nach dem vorgezogenen Umbruch nur Kommentar: doch nicht umbrechen
              Viewer.img.Canvas.TextOut( Viewer.img.Canvas.PenPos.x, r.Top - TextSize.TextStdHeight, s.Substring( pBlock+u, CharsPerLine - u ) );
              break
              end
            else
              inc( pBlock, u )
            end;
        until pBlock >= high( s )
      end;  { ShowSrcLine }

      {$IFDEF MitCTV}
      procedure ShowSrcLinePre( Zeile, SpStart, Len: integer );
      { Falls diese Zeile schon vor der BlockStart-Spalte anfängt: Start nach vorne verschieben }
      { Beispiel:   var
                      a: integer;
                  xxx: integer;            // Diese Zeile muß vor der durch "var" festgelegten BlockStart beginnen
                      b: integer;}
      begin
        if SpStart >= Source.LineInfo[Zeile].NonBlank1
          then ShowSrcLine( Zeile, Source.LineInfo[Zeile].NonBlank1, Len )
          else ShowSrcLine( Zeile, SpStart,                          Len )
      end;
      {$ENDIF}

    begin { ShowBlockText }
//      {$IFDEF TraceDx} TraceDx.Send( 'ShowBlockText' ); {$ENDIF}
      with b^ do begin
        CharsPerLine := ( w - cTextLinksDelta - 1 ) div TextSize.CharWidth;
        if CharsPerLine < 10 then CharsPerLine := 10;
        if flHighlight in FlagsRun
          then Viewer.img.Canvas.Brush.Color := clHighlightBack
          else Viewer.img.Canvas.Brush.Color := clBackground;
        inc( r.Top, cTextObenDelta );

        {$IFDEF MitCTV}
        if TxtZeilen = 1 then
          ShowSrcLinePre( TxtStart.ze, TxtStart.sp, TxtEnde.sp )      // abschneiden
        else begin
//          ShowSrcLinePre( TxtStart.ze, TxtStart.sp, 999 );                                              // alles

          for i := 0 to TxtZeilen - 2 do
            ShowSrcLinePre( TxtStart.ze + i, TxtStart.sp, 999 );   // alles

          ShowSrcLinepre( TxtEnde.ze, TxtStart.sp, TxtEnde.sp )
          end;
        {$ELSE}
        if TxtZeilen = 1 then
          ShowSrcLine( TxtStart.ze, TxtStart.sp, TxtEnde.sp )      // abschneiden
        else begin
          ShowSrcLine( TxtStart.ze, TxtStart.sp, 999 );                                              // alles

          for i := 1 to TxtZeilen - 2 do
            if TxtStart.sp >= Source.LineInfo[TxtStart.ze + i].NonBlank1
              then ShowSrcLine( TxtStart.ze + i, Source.LineInfo[TxtStart.ze + i].NonBlank1, 999 )    // alles
              else ShowSrcLine( TxtStart.ze + i, TxtStart.sp,                                999 );   // alles

          if TxtStart.sp >= Source.LineInfo[TxtEnde.ze].NonBlank1
            then ShowSrcLine( TxtEnde.ze, Source.LineInfo[TxtEnde.ze].NonBlank1, TxtEnde.sp )
            else ShowSrcLine( TxtEnde.ze, TxtStart.sp,                           TxtEnde.sp )
          end;
        {$ENDIF}
        end
    end;  { ShowBlockText }

    (* SearchRealPrev *)
    function SearchRealPrev( p: pBlockInfo ): pBlockInfo;
    begin
      while p^.Typ in btSubView do p := p^.Prev;
      Result := p
    end;

  begin   (* ShowBlock *)
//    {$IFDEF TraceDx} TraceDx.Send( 'ShowBlock' ); {$ENDIF}
    ObenAlt := r.Top;
    with Viewer.img.Canvas do
      repeat
       {$IFDEF TraceDx} TraceDx.Send( 'ShowBlock ' + TBlock.getBlockTyp( b^.Typ ), b^.Nr, r.Top ); {$ENDIF}
       include( b^.FlagsRun, flVisible );

       if LastWasSkipped and ( b^.TxtZeilen > 0 ){ falls leerer Block: skip zurückstellen} then begin
         {$IFDEF TraceDx} TraceDx.Send( 'LastWasSkipped' ); {$ENDIF}
         { Die Textausgabe hat die Zeilen der Ausblendung nicht "gesehen" und deshalb den AktCommentIndex nicht incrementiert. }
         { Dies wird hier nachgeholt: }
         SkipTextArtTo( b^.TxtStart );
         dec( AktTextArtIdx );
         getNextTextArt;
         LastWasSkipped := false
         end;

       { links und oben: }
       b^.Rect.Left := r.Left;
       b^.Rect.Top  := r.Top;

       { rechts und (nur bei else) links-Korrektur: }
       if ( b^.Typ = btThen ) { kann weg wenn then-Block nicht mehr selektierbar: } or (( b^.Typ in btSubView ) and ( b^.Sub^.Typ = btThen )) then
         r.Right := r.Left + getThenWidth( b^.Prev ) else
       if b^.Typ = btElse then begin
         r.Top        := ObenAlt;
         b^.Rect.Top  := r.Top;
         r.Left       := r.Right-1;
         b^.Rect.Left := r.Left;
         r.Right      := b^.prev^.Rect.Right
         end;
       b^.Rect.Right := r.Right;

       { falls zu breit: nicht-fixe Ausblendung erzeugen: }
       if ( b^.SubZeilen > 1 ) and
//           ( b^.Typ <> btSubViewFix ) and                                                    { ist in "( b^.SubZeilen > 1 )" enthalten
          ((( b^.Typ <> btIf ) and ( r.Right - r.Left < TextSize.BlockWidthMin   )) or          { falls non-if und zu breit          }
           (( b^.Typ =  btIf ) and ( r.Right - r.Left < TextSize.BlockWidthMinIf )))            { (if-Zweig braucht doppelte Größe)  } and
           not ( b^.Typ in btDontShow + [btBegin, btEnd, btCaseEnd] ) and
//             false and
           not (( b^.Typ = btElse ) and ( flEmptyElse in SearchRealPrev( b^.prev )^.Flags )) { leeren else-Zweig nicht ausblenden } and
           not (( b^.Typ = btThen ) and ( flEmptyThen in                 b^.        Flags )) { leeren then-Zweig nicht ausblenden } and
//             ( Typ <> btSubViewTmp )  {kann nie vorkommen!!!!}
//and             not ( flAusblendungFix in Flags )                                          { AusblendungFix wird sowieso schon  }
           true then begin
         {$IFDEF TraceDx} TraceDx.Send( 'Auto-SubView', b^.Nr ); {$ENDIF}
         c.pStart := b;
         c.pEnde  := b;
         TViewer.SubViewCreate( c, btSubViewAuto );
         exclude( b^.FlagsRun, flVisible );
         b := c.pStart
         end;

       { Textzeilen: }
       if ( b^.Typ = btElse ) and ( flEmptyElse in b^.prev^.Flags ) then begin
         { leerer else-Block: Damit anclickbar Höhe aus dem then-Block übernehmen: }
         inc( r.Top, 4 {MyThen^.Rect.Top - ObenAlt} );
         b^.Rect.Top := r.Top
         end
       else
         if b^.Typ in [btSubViewFix, btSubViewAuto] then begin
           { Ausblendungszeile: }
           inc( SubViewCnt[b^.Typ] );
           Brush.Color := clSubViewBack;
           Font. Color := clSubViewFont;
           r.Bottom := r.Top + cTextObenDelta + TextSize.TextStdHeight;
           FillRect( r );
           inc( r.Top, cTextObenDelta );
           if flHighlight in b^.FlagsRun then
             Brush.Color := clHighlightBack;
           TextOut( r.Left + cTextLinksDelta, r.Top, ( cSubViewIndicator[b^.Typ] + b^.SubInfo.Header ).Substring( 0, ( r.Right - r.Left - cTextLinksDelta ) div TextSize.CharWidth ));
           Font.Color := clFontTextArt[artStatement];
           inc( r.Top, TextSize.TextStdHeight );
           LastWasSkipped := true
           end
         else begin
           { Standard-Block: }
           if b^.Typ in btDontShow then begin
             LastWasSkipped := true;
             { Platz für "then" und "else" schaffen: }
             inc( r.Top, 4 ); b^.Rect.Top := r.top
             end
           else
             if b^.TxtZeilen > 0 then
               { Text anzeigen }
               ShowBlockText( b^.Rect.Right - b^.Rect.Left );

           if ( b^.Typ in [btBegin, btEnd, btCaseEnd] ) and ( b^.prev^.Typ <> btProc )
               then LastWasSkipped := true;

           if b^.Sub <> nil then begin
             { jetzt erst alle SubBlöcke komplett durchgehen: }
             if  ( b^.Typ in [btClass, btThen, btElse, btFor, btWhile, btRepeat, btWith, btCase, btCaseSel, btCaseElse, btTry, btExcept, btFinally, btOn, btExceptElse, btAsm, btInitial, btFinal] - btDontShow ) or
                 ( IndentThen and ( b^.Typ = btIf ))                                    or
                (( b^.Typ in [btBegin] )         and ( b^.prev^.Typ in [btUnit, btProc] )) or     // das Haupt-begin-end unterm proc oder prog auch
                (( b^.Typ in [btProc, btBegin] ) and ( b^.Typ = b^.prev^.Typ ))                     // und lokale procs   und   unnötige begin-end-Blöcke
               then inc( r.Left, cLevelDelta );

             { hier werden rekursiv die SubBlöcke aufgerufen: }
             inc( r.Top, ShowBlock( b^.Sub, r ) );

             if ( b^.Typ = btIf ) and ( flEmptyThen in b^.Sub^.Flags ) then
               { Sonderfall leerer then-Zweig unterm if: Damit then anclickbar Höhe analog if-Block(ist dort noch nicht in Bottom hinterlegt): }
               b^.Sub^.Rect.Bottom := r.Top + 1;

             r.Left := b^.Rect.Left   // Einrückung ggf wieder rückgängig machen
             end
           end;

       b^.Rect.Bottom := r.Top + 1;     // weil die Linie 1 ÜBER Rect.Bottom und Rect.Right gezeichnet wird

       { Rechteck aussen um die Textzeilen: }
       if ( b^.Typ = btProc ) or ( b^.Level = 1 )
         then Brush.Color := clRectLinesProc
         else Brush.Color := clRectLines;
       FrameRect( b^.Rect );
       if b^.Typ in btDontShow then begin
         { Texte "then" und "else" }
         Brush.Color := clBackground;
         Font.Color  := clKeywordMini;
         Font.Height := TextSize.FontHeightMini;
         TextOut( r.Left+6, ObenAlt +{weil Height negativ} TextSize.FontHeightMini div 2 + 3, cThenElseText[b^.Typ] );
         Font.Color  := clFontTextArt[artStatement];
         Font.Height := TextSize.FontHeightStd;
         LastWasSkipped := true;

         { Sonderbehandlung if-then-else: }
         if b^.Typ = btThen then
           MyThen := b                  // Merken für Anpassung der beiden Höhen von then und else sobald "else" gelesen ist
         else { = btElse }
           if MyThen^.Rect.Bottom - 1 > r.Top then
             r.Top := MyThen^.Rect.Bottom - 1   // else ist kleiner -> an then anpassen
           else begin                           // then ist kleiner -> linke Then-Linie genauso hoch wie else-Linie machen
             Pen.Color := clRectLines;
             MoveTo( MyThen^.Rect.Left, b^.Rect.Top ); LineTo( MyThen^.Rect.Left, b^.Rect.Bottom );
//               Pen.Color := clBackground
             end
         end;

       { Rechteck-Korrekturen für repeat und end: }
       if b^.Typ in [btUntil, btEnd] then begin
         { until-Kasten soll links oben zum repeat hin offen sein: }
         Pen.Color := clBackground;
         MoveTo( b^.Rect.Left + 1, b^.Rect.Top ); LineTo( b^.Rect.Left + cLevelDelta, b^.Rect.Top );
         Pen.Color := clRectLines
         end;

       b := b^.Next
      until b = nil;               // SubLevel immer bis zum Ende der Kette

    Result := r.Top - ObenAlt
  end;

begin
  {$IFDEF TraceDx} TraceDx.Line; TraceDx.Send( 'TStruct.PaintBlocks, Width', w, pSubView^.Nr ); {$ENDIF}
  if w > Viewer.img.Width then begin
    {$IFDEF TraceDx} TraceDx.Send( 'TStruct.PaintBlocks: set new Width', w ); {$ENDIF}
    try    Viewer.img.Width := w;
    except Error( erStructSize, '' )
    end;
    end;

  CursorMakeReal( CursorBlock );
  { Auto-Ausblendungen reset: }
  DestroySubViewsDown( pSubView^.Sub );

  { den ersten für diese Auslagerung relevanten Kommentar suchen: }
  AktTextArtIdx  := 0;
  LastWasSkipped := true;

  Viewer.img.Canvas.Brush.Color := clBackground;
  Viewer.img.Canvas.FillRect( Rect( 0, 0, w, Viewer.img.Height ) );

  Result := ShowBlock( pSubView^.Sub, Rect( 1, 1, w-2, 0 ) );

  if Result > Viewer.img.Height then begin
    {$IFDEF TraceDx} TraceDx.Send( 'TStruct.PaintBlocks: set new Heigth', Result ); {$ENDIF}
    try    Viewer.img.Height := Result;           // jetzt isses hoch genug,
    except Error( erStructSize, '' )
    end;
    Result := TViewer.PaintBlocks( w )          // nochmal berechnen
    end;

  TDiagnose.CheckTree;
  CursorMakeVisible( CursorBlock )
end;

end.

