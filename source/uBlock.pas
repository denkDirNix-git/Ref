
unit uBlock;
{$INCLUDE _CompilerOptions.pas}
{ $ UNDEF TraceDx}

interface

uses
  System.SysUtils,
  uGlobalData;

type
  TBlock    = record
                class procedure Init; static;
                class procedure ReUse; static;
                class function  NewBlock: pBlockInfo; static;
                class procedure FreeBlock( p: pBlockInfo ); static;
                class function  Found( t: tBlockTyp; ze, sp: tSourcePosIdx ): integer; static;
                class function  FinishBlockTxt: boolean; static;
                class function  VisitSemikolon: boolean; static;
                class function  SetSubZeilenDown( b: pBlockInfo ): tLineCount; static;
                class procedure SetSubZeilenUp( p: pBlockInfo; Delta: integer ); static;
//              class procedure RecalculateSubZeilenPrev( p: pBlockInfo ); static;
                class procedure getThenElse(var pThen, pElse: pBlockInfo ); static;
                class procedure ForAllBlocks( userProc: tFunc<pBlockInfo, boolean> ); static;
                class procedure ForAllCursorBlocks( c: tCursorBlock; userProc: tProc<pBlockInfo> ); static;
                class function  getByIndex( i: tBlockIndex ): pBlockInfo; static;
                class function  getBlockTyp( t: tBlockTyp ): string; static;
                class function  getLast( p: pBlockInfo ): pBlockInfo; static;
                class function  TextPosInBlock(p: tSourcePos; b: pBlockInfo): boolean; static;
                class function  SearchBlockByTextPos( Pos: tSourcePos ): pBlockInfo; static;
              end;

var
  LastNonBlank    : tSourcePos;
  pLastBlock,
  pAktBlock       : pBlockInfo;
  DummyContainsStm: boolean;


implementation

uses
  Vcl.Dialogs,
  System.TypInfo,
  {$IFDEF TraceDx} uTraceDx, {$ENDIF}
  uViewer;

var
  BlockListArr0: tBlockListChunk;                    // Variable für die erste Gruppe BlockInfos. Eine Gruppe sollte idR ausreichen
  BlockListArr : array of ^tBlockListChunk;
  BlockArrAkt,
  AktBlock     : integer;


{ TBlock.NewBlock }
class function TBlock.NewBlock: pBlockInfo;
begin
  if AktBlock = cBlockListChunk then begin
    inc( BlockArrAkt );
    if BlockArrAkt > high( BlockListArr ) then begin
      SetLength( BlockListArr, high( BlockListArr ) + 2 );
      new( BlockListArr[BlockArrAkt] )
      end;
    FillChar( BlockListArr[BlockArrAkt]^, sizeOf( tBlockListChunk ), 0 );
    AktBlock := 0
    end
  else
    inc( AktBlock );
  Result := @BlockListArr[BlockArrAkt][AktBlock];
  Result^.Nr := BlockArrAkt * ( cBlockListChunk + 1 ) + AktBlock
end;

{ TBlock.FreeBlock }
class procedure TBlock.FreeBlock( p: pBlockInfo );
begin
  p^.Typ            := btFree;
  p^.Level          := 0;
  p^.SubInfo.Header := ''
end;

{ TBlock.Init }
class procedure TBlock.Init;
begin
  {$IFDEF TraceDx} TraceDx.Send( 'TBlock.Init' ); {$ENDIF}
  AktBlock            := -1;
  BlockArrAkt         :=  0;
  pAktBlock           := NewBlock;
  pLastBlock          := pAktBlock;
  pAktBlock^.Typ      := btMain;
  pAktBlock^.Flags    := [flCompound];
  pAktBlock^.FlagsRun := [flVisible];   // nur als while-Grenze in PaintBlocks
end;

{ TBlock.ReUse }
class procedure TBlock.ReUse;
{ - gibt Speicher aus BlockListArr0 ( identisch mit BlockListArr[0]^ ) frei }
{ - BlockListArr[1]^ und weitere
{ - beim ersten Scan-Durchlauf nicht notwendig }
var i,j,m: tBlockIndex;
begin
  {$IFDEF TraceDx} TraceDx.Send( 'TBlock.ReUse' ); {$ENDIF}

  if BlockArrAkt = 0
    then m := AktBlock              // das reicht wenn nur der erste Chunk benutzt wurde
    else m := cBlockListChunk;
  for j := 0 to m do if BlockListArr0[j].Typ in [btMain] + btSubView then BlockListArr0[j].SubInfo.Header := '';
  FillChar( BlockListArr0, ( m + 1 ) * sizeOf( tBlockInfo ), 0 );

  for i := 1 to BlockArrAkt do begin
    if i = BlockArrAkt
      then m := AktBlock              // das reicht wenn nur der erste Chunk benutzt wurde
      else m := cBlockListChunk;
    for j := 0 to m do if BlockListArr[i]^[j].Typ in btSubView then BlockListArr[i]^[j].SubInfo.Header := '';
    FillChar( BlockListArr[i]^, ( m + 1 ) * sizeOf( tBlockInfo ), 0 );
    end;
end;

{ TBlock.ForAllBlocks }
class procedure TBlock.ForAllBlocks( userProc: tFunc<pBlockInfo, boolean> );
{ stop, wenn userproc-return = true }
var a,i: tBlockIndex;
    p  : pBlockInfo;
begin
  a := 0;
  i := 0;
  p := @BlockListArr0;
  repeat if userProc( p ) then break;
         if i = cBlockListChunk then begin
           if a = BlockArrAkt then break;     // zusätzlicher harter Ausstieg: gerade beim letzten Element ist Schluß
           i := 0;
           inc( a );
           p := @BlockListArr[a][0]
           end
         else begin
           inc( i );
           inc( p )
           end
  until  ( i > AktBlock ) and ( a = BlockArrAkt ) // or ( a > BlockArrAkt )    Optimierung: Abfrage nach oben verlegt als "break"
end;

{ TBlock.ForAllCursorBlocks }
class procedure TBlock.ForAllCursorBlocks( c: tCursorBlock; userProc: tProc<pBlockInfo> );
var p: pBlockInfo;
begin
  p := c.pStart;
  userProc( p );
  while p <> c.pEnde do begin
    p := p^.Next;
    userProc( p )
    end;
end;

{ TBlock.getbyIndex }
class function TBlock.getByIndex( i: tBlockIndex ): pBlockInfo;
begin
  Result := @BlockListArr[i div (cBlockListChunk+1)] [i mod (cBlockListChunk+1)]
end;

{ TBlock.getBlockTyp }
class function TBlock.getBlockTyp( t: tBlockTyp ): string;
begin
  Result := GetEnumName( TypeInfo( tBlockTyp ), ord( t ))  //.SubString( 2 )
end;

{ TBlock.getLast }
class function TBlock.getLast( p: pBlockInfo ): pBlockInfo;
begin
  Result := p^.Sub;
  while Result^.Next <> nil do Result := Result^.Next
end;

{ TBlock.getThenElse }
class procedure TBlock.getThenElse( var pThen, pElse: pBlockInfo );
{ Start mit if-Block^.Sub in pThen }
begin
  while pThen^.Typ <> btThen do pThen := pThen^.Next;
  pElse := pThen^.Next;
  while pElse^.Typ <> btElse do pElse := pElse^.Next
end;

{ CalculateThenBreite }
function CalculateThenPercent( pSubThen, pSubElse: pBlockInfo ): integer;
{ Neu-Berechnung für den Zweig ÜBER dem geänderten Ausblendung-Flag mit Berücksichtigung von Ausblendungen }
begin
  if pSubThen^.SubZeilen = pSubElse^.SubZeilen then
    Result := 50    // insbesondere auch wenn beide 0 !
  else
    if flEmptyElse in pSubElse^.Prev^.Flags then
      Result := 100     // nur then mit Inhalt
    else if flEmptyThen in pSubThen^.Flags
           then Result := 0     // nur else mit Inhalt
           else Result := pSubThen^.SubZeilen * 100 div ( pSubThen^.SubZeilen + pSubElse^.SubZeilen );    // Inhalte gewichten*)

  {$IFDEF TraceDx} TraceDx.Send( 'ThenAnteil[%]',  Result) {$ENDIF}
end;

{ TBlock.TextPosInBlock }
class function TBlock.TextPosInBlock( p: tSourcePos; b: pBlockInfo ): boolean;
begin
  Result := ( b^.TxtStart.ze <= p.ze ) and ( b^.TxtEnde.ze >= p.ze );
  if Result then
    if ( ( b^.TxtStart.ze = p.ze ) and ( b^.TxtStart.sp > p.sp ) )  or
       ( ( b^.TxtEnde .ze = p.ze ) and ( b^.TxtEnde .sp < p.sp ) )  then
       Result := false     // der war's doch nicht
end;

{ TBlock.SearchBlockByTextPos }
class function TBlock.SearchBlockByTextPos( Pos: tSourcePos ): pBlockInfo;
var r: pBlockInfo;
begin
  r := nil;
  TBlock.ForAllBlocks( function( p: pBlockInfo ): boolean
    begin
      Result := TextPosInBlock( Pos, p );
      if Result then
        r := p
    end);
  Result := r
end;

{ TBlock.SetSubZeilenDown }
class function TBlock.SetSubZeilenDown( b: pBlockInfo ): tLineCount;
{ Berechnet SubZeilen und ThenBreite incl Ausblendungen,               }
{ läuft (wegen Addition SubZeilen) über alle DARUNTER liegenden Blöcke }
{ Nach Scan: Aufruf ab Main-Block (allso für alle Blöcke)              }
{ Danach   : bei Create/Close einer Ausblendung manuell/auto           }
var pThen, pElse: pBlockInfo;
    {$IFDEF TraceDx} t: tBlockTyp; {$ENDIF}
begin
  {$IFDEF TraceDx} if b <> nil then t := b^.Prev^.Typ; {$ENDIF}
  Result := 0;
  while b <> nil do with b^ do begin

    if Typ in btSubView then begin
      Subzeilen := 1;
      if Sub <> nil then
        SetSubZeilenDown( Sub )
      end
    else begin
      SubZeilen := TxtZeilen;
      if Sub <> nil then
        inc( SubZeilen, SetSubZeilenDown( Sub ));

      { im if wurde gerade then und else aufaddiert. Den kleineren wieder abziehen da Blöcke nebeneinander dargestellt werden: }
      if Typ = btIf then begin
        pThen := Sub;
        getThenElse( pThen, pElse );
        if pThen^.Subzeilen < pElse^.Subzeilen
          then dec( SubZeilen, pThen^.Subzeilen )     // else ist größer -> then wieder abziehen
          else dec( SubZeilen, pElse^.Subzeilen );    // then ist größer -> else wieder abziehen
        { außerdem die ThenBreite setzen: }
        if ThenBreite >= 0
          then ThenBreite := CalculateThenPercent( pThen, pElse )
          else // wurde manuell auf fixen Wert gesetzt
        end
      end;

    inc( Result, Subzeilen );
    b := Next
    end;
//  {$IFDEF TraceDx} TraceDx.Send( 'SetSubZeilenDown' + GetBlockTyp( t ), Result ); {$ENDIF}
end;

{ TBlock.SetSubZeilenUp }
class procedure TBlock.SetSubZeilenUp( p: pBlockInfo; Delta: integer );
{ Neu-Berechnung für den Zweig ÜBER dem geänderten Ausblendung-Flag mit Berücksichtigung von Ausblendungen }
var pThen, pElse: pBlockInfo;
    AltSub      : tLineCount;
begin
  {$IFDEF TraceDx} TraceDx.Send( 'TBlock.SetSubZeilenUp', p^.Nr, Delta ); {$ENDIF}
    while not ( p^.Typ in[btMain] + btSubView ) do begin    // hier und drüber keine Änderung

      if p^.Typ = btIf then begin
        pThen := p^.Sub;
        getThenElse( pThen, pElse );

        AltSub := p^.SubZeilen;
        if pThen^.Subzeilen > pElse^.Subzeilen
          then p^.SubZeilen := pThen^.SubZeilen + p^.TxtZeilen
          else p^.SubZeilen := pElse^.SubZeilen + p^.TxtZeilen;

        if p^.ThenBreite >= 0
          then p^.ThenBreite := CalculateThenPercent( pThen, pElse )
          else ; // wurde manuell auf fixen Wert gesetzt
        Delta :=  p^.SubZeilen - AltSub
        end
      else
        inc( p^.SubZeilen, Delta );

      p := p^.Prev
      end
end;

{ TBlock.VisitSemikolon }
class function TBlock.VisitSemikolon: boolean;
begin
//  Result := not pAktBlock^.Prev^.Compound
  Result := true
end;

{ TBlock.FinishBlockTxt }
class function TBlock.FinishBlockTxt: boolean;
begin
  Result := false;
  with pLastBlock^ do begin

    TxtEnde.ze := LastNonBlank.ze;
    TxtEnde.sp := LastNonBlank.sp;

    if  ( Typ =   btSubViewFix  )                                              or
       (( Typ in [btBegin, btEnd] ) and not ( prev^.Typ in [btUnit,btProc] ))  or
        ( Typ =   btCaseEnd )                                                  or
        ( Typ in  btDontShow )                                                 then begin
      TxtZeilen := 0;
      if ( Typ <> btSubViewFix ) and (( TxtStart.ze <> TxtEnde.ze ) or ( TxtEnde.sp - TxtStart.sp > 5 )) then
        Result := true
      end
    else
      if TxtStart.ze = TxtEnde.ze then
        if TxtStart.sp <= TxtEnde.sp
          then TxtZeilen := 1
          else TxtZeilen := 0
      else
        TxtZeilen := TxtEnde.ze - TxtStart.ze + 1
    end;
end;

{ AddBlock }
function AddBlock( t: tBlockTyp; ze, sp: tSourcePosIdx ): pBlockInfo;
var pAltBlock: pBlockInfo;
    {$IFDEF TraceDx} s: string; {$ENDIF}

  procedure IsSub;
  var p: pBlockInfo;
  begin
    {$IFDEF TraceDx} TraceDx.Send( 'AddBlockSub', s ); {$ENDIF}
    p := pAltBlock^.Sub;
    if p = nil
      then pAltBlock^.Sub := pAktBlock
      else begin while p^.Next <> nil do p := p^.Next; p^.Next := pAktBlock end;
    pAktBlock^.Prev  := pAltBlock;
    pAktBlock^.Level := pAltBlock^.Level + 1
  end;

  procedure IsNext;
  begin
    {$IFDEF TraceDx} TraceDx.Send( 'AddBlockNext', s ); {$ENDIF}
    pAltBlock^.Next        := pAktBlock;
    pAktBlock^.Prev        := pAltBlock^.Prev;
    pAktBlock^.Level       := pAltBlock^.Level;
  end;

begin
  {$IFDEF TraceDx} s := TBlock.getBlockTyp( t ) + ' ' + Source.Lines[ze].Substring( sp ); {$ENDIF}
  Result := nil;

  if pLastBlock^.Typ = btDummy then
    if DummyContainsStm
      then pLastBlock^.Typ := btStm
      else begin pAktBlock^.Typ := t; exit end;

  TBlock.FinishBlockTxt;
  pAltBlock  := pAktBlock;
  pAktBlock  := TBlock.NewBlock;
  pAktBlock^.Typ         := t;
  pAktBlock^.TxtStart.ze := ze;
  pAktBlock^.TxtStart.sp := sp;

  {$IFDEF MitCTV}
  { Sonderbehandlung: Falls vorheriger Block Var,type,... dann Einrückung aus vorigem übernehmen: }
  if ( pAltBlock^.Typ = btStm ) and ( t <> btSubViewFix ) and ( flConstTypeVar in pAltBlock^.Flags ) then begin
    pAktBlock^.TxtStart.sp := pAltBlock^.TxtStart.sp;
    include( pAktBlock^.Flags, flConstTypeVar )
    end;
  {$ENDIF}

  if ( pAltBlock^.Typ in [btMain, btUnit, btProc, btClass,
                          btBegin, btAsm, btTry, btExcept, btFinally, btOn, btExceptElse,
                          btIf, btThen, btElse, btFor, btWhile, btRepeat,
                          btWith, btCase, btCaseSel, btCaseElse, btInitial, btFinal,
                          btSubViewFix] ) and
     not (( pAltBlock^.Typ =   btThen  )                and ( t = btElse ))  and
     not (( pAltBlock^.Typ in [btBegin, btAsm, btTry] ) and ( t = btEnd  ))
    then IsSub
    else IsNext;

  pLastBlock := pAktBlock;
  Result     := pAktBlock
end;

{ EndBlock }
procedure EndBlock;
var b: pBlockInfo;
{$IFDEF TraceDx} s: string; {$ENDIF}
begin
  {$IFDEF TraceDx} s := 'EndBlock ' + TBlock.getBlockTyp( pAktBlock^.Typ ); {$ENDIF}

  if ( Source.Lang in [lgPascal, lgPascal86] ) and ( pAktBlock^.Typ = btIf ) then begin
    b := pAktBlock^.Sub^.Next;
    while ( b <> nil ) and ( b^.Typ <> btElse ) do b := b^.Next;
    if b = nil then begin
      { es gibt keinen else-Block -> jetzt Dummy hinzufügen: }
      include( pAktBlock^.Flags, flEmptyElse );
      AddBlock( btElse, LastNonBlank.ze, LastNonBlank.sp )
      end
    end;

  pAktBlock := pAktBlock^.Prev;

  {$IFDEF TraceDx}
  if pAktBlock = nil
    then TraceDx.Send( s, 'nil' )
    else TraceDx.Send( s, TBlock.getBlockTyp( pAktBlock^.Typ ))
  {$ENDIF}
end;

{ TBlock.Found }
class function TBlock.Found( t: tBlockTyp; ze,sp: tSourcePosIdx ): integer;
var p: pBlockInfo;
begin
  {$IFDEF TraceDx} TraceDx.Call( 'Found ' +  GetBlockTyp( t ), Source.Lines[ze].Substring( sp ) ); {$ENDIF}
  Result := -1;

  case t of
    btSubViewFix: begin  // nur bei "interface"
                 AddBlock( btSubViewFix, ze, sp )^.Flags := [fl_AutoSubFix];
                 AddBlock( btDummy, ze, sp ); DummyContainsStm := false;
                 TViewer.SetHeader( pAktBlock^.Prev )  // jetzt erst, weil SetHeader den proc-Eintrag braucht
               end;
    btSubViewTmp: begin  // nur bei "implementation"
                 EndBlock; EndBlock
               end;
    btUnit   : include( AddBlock( btUnit,  ze, sp )^.Flags, flCompound );
    btProc   : if Source.Lang = lgC then
                 AddBlock( btProc,  ze, sp )^.Flags := [flCompound]
               else begin
                 if pLastBlock^.Nr > 2 then        // nicht ausblenden, wenn nur-proc mit max einem Kommentar vorweg
                   AddBlock( btSubViewFix, ze, sp )^.Flags := [fl_AutoSubFix];
                 AddBlock( btProc,  ze, sp )^.Flags := [flCompound];
                 if fl_AutoSubFix in pAktBlock^.Prev^.Flags then
                   TViewer.SetHeader( pAktBlock^.Prev )  // jetzt erst, weil SetHeader den proc-Eintrag braucht
               end;
    btInitial: begin
                 AddBlock( btSubViewFix, ze, sp )^.Flags := [fl_AutoSubFix];
                 AddBlock( btInitial, ze, sp )^.Flags := [flCompound];
                 TViewer.SetHeader( pAktBlock^.Prev )  // jetzt erst, weil SetHeader den proc-Eintrag braucht
               end;
    btFinal  : begin
                 while pAktBlock^.Typ <> btSubViewFix { der von initial } do EndBlock;
                 EndBlock;
                 AddBlock( btSubViewFix, ze, sp )^.Flags := [fl_AutoSubFix];
                 AddBlock( btFinal, ze, sp )^.Flags := [flCompound];
                 TViewer.SetHeader( pAktBlock^.Prev )  // jetzt erst, weil SetHeader den proc-Eintrag braucht
               end;
    btClass  : AddBlock( btCase, ze, sp );
    btBegin  : begin
                 if pLastBlock^.Typ = btBegin
                   then include( pLastBlock^.Flags, flDoubleBegin );
                 include( AddBlock( btBegin,  ze, sp )^.Flags, flCompound )
               end;
    btAsm    : include( AddBlock( btAsm,    ze, sp )^.Flags, flCompound );
    btTry    : include( AddBlock( btTry,    ze, sp )^.Flags, flCompound );
    btExcept : begin
                 while pAktBlock^.Typ <> btTry
                    do EndBlock;
                 include( AddBlock( btExcept, ze, sp )^.Flags, flCompound )
               end;
    btFinally: begin
                 while pAktBlock^.Typ <> btTry
                    do EndBlock;
                 include( AddBlock( btFinally,ze, sp )^.Flags, flCompound )
               end;
    btOn     : AddBlock( btOn, ze, sp );
    btEnd    : if Source.Lang = lgC then begin
                   while not ( flCompound in pAktBlock^.Flags ) do
                     EndBlock;

                   if pAktBlock^.Typ in [btCaseSel, btCaseElse] then
                     EndBlock;

                   AddBlock( btEnd, ze, sp );
                   EndBlock;

                   while not ( flCompound in pAktBlock^.Flags ) do
                     EndBlock;

                   Result := pAktBlock^.Level
                   end
               else begin
                   if not ( pAktBlock^.Typ in [btUnit, btBegin, btAsm, {btExcept, btFinally,} btCase, btCaseSel, btCaseElse] ) then
                     repeat EndBlock
                     until ( pAktBlock^.Typ in [btUnit, btBegin, btAsm, btTry, btCase, btCaseSel, btCaseElse] );

                   case pAktBlock^.Typ of
                     btUnit    : AddBlock( btStm, ze, sp );
                     btBegin,
                     btAsm,
                     btTry     : begin
  //                                 EndBlock;
                                   exclude( AddBlock( btEnd, ze, sp )^.Flags, flCompound );
                                   if pAktBlock^.Prev^.Typ = btProc then begin
                                     EndBlock; EndBlock;
                                     if pAktBlock^.Typ = btSubViewFix then
                                       EndBlock
                                     end  // Proc-Ende
                                 end;
                     btCase,
                     btCaseSel,
                     btCaseElse: begin
                                   if pAktBlock^.Typ <> btCase then  // case: ich bin nach ";" schon auf case-Ebene
                                     EndBlock;
                                   AddBlock( btCaseEnd, ze, sp );
                                   EndBlock; EndBlock
                                 end
                     else        asm int 3 end
                     end;
                   Result := pAktBlock^.Level
                   end;
    btClose  : begin
                 AddBlock( btClose, 0, 0 );   // schliesst den vorigen Block über LastNonBlank.ze/sp ab
                 EndBlock;
                 BlockListArr0[0].TxtZeilen := 0;     // das geht jetzt erst nachträglich
                 pAktBlock^.SubZeilen := pAktBlock^.TxtZeilen + SetSubZeilenDown( pAktBlock^.Sub );   // das ist unterm MainBlock
               end;
    btDummyAbs:if pAktBlock^.Typ = btCaseSel then begin
                 { Sonderbehandlung Comment NACH case-stm: Auf Sel-Ebene statt unter diesem Sel einfügen: }
                 EndBlock; AddBlock( btDummy, ze, sp ) end
               else
                 if ( flCompound in pAktBlock^.Flags )             and
                    ( pLastBlock^.Typ = btDummy )                  and
                    ( pLastBlock^.Level = pAktBlock^.Level + 1 )   and
                    ( LastNonBlank.ze >= ze - 1 )                        // falls keine Leerzeile dazwischen!
                   then ze := 1    // Anweisung ist nur für Breakpoint-setzen. Diesen Textblock mit dem vorigen zusammenfassen
                   else begin AddBlock( btDummy, ze, sp ); DummyContainsStm := false end;
    btComment: if pLastBlock^.Typ <> btComment then
                 AddBlock( btComment,  ze, sp );
    btDummy  : case pAktBlock^.Typ of
                 btCase   : AddBlock( btCaseSel,  ze, sp );
                 btCaseSel,
                 btMain   : AddBlock( btDummy,    ze, sp )
                 else       if ( flCompound in pAktBlock^.Flags )             and
                               ( pLastBlock^.Typ = btDummy )                  and
                               ( pLastBlock^.Level = pAktBlock^.Level + 1 )   and
                               ( LastNonBlank.ze >= ze - 1 )                        // falls keine Leerzeile dazwischen!
                              then ze := 1    // Anweisung ist nur für Breakpoint-setzen. Diesen Textblock mit dem vorigen zusammenfassen
                              else begin AddBlock( btDummy, ze, sp ); DummyContainsStm := false end;
                 end;
    btSemi   : while not ( ( flCompound in pAktBlock^.Flags ) or ( pAktBlock^.Typ = btCase ) ) do
                 EndBlock;
    btWith   : AddBlock( btWith, ze, sp );
    btIf     : AddBlock( btIf,   ze, sp );
    btThen   : AddBlock( btThen, ze, sp );
    btElse   : if Source.Lang = lgC then begin
                   while pAktBlock^.Typ <> btIf do EndBlock;
                   AddBlock( btElse, ze, sp );
                   if flEmptyElse in pAktBlock^.Prev^.Flags then
                     while not ( flCompound in pAktBlock^.Flags ) do
                       EndBlock;
                   end
               else begin
                 { ich bin im if oder case }
                 if pAktBlock^.Typ = btThen then
                   include( pAktBlock^.Flags, flEmptyThen );      // leerer then-Zweig
                 if pAktBlock^.Typ = btCaseEnd then begin
                   EndBlock; EndBlock end else
                 if not ( pAktBlock^.Typ in [btCase, btExcept] ) then begin

                   repeat if pAktBlock^.Typ = btElse
                            then include( pAktBlock^.prev^.Flags, flEmptyElse )
                            else EndBlock;
                          if pAktBlock^.Typ =  btElse then begin
                            EndBlock; EndBlock end;   // falls ich im else-Zweig dann dessen if überspringen
                   until  pAktBlock^.Typ in [btIf, btCase, btExcept];
                   end;

                 case pAktBlock^.Typ of
                   btCase  : include ( AddBlock( btCaseElse,   ze, sp )^.Flags, flCompound );
                   btExcept: include ( AddBlock( btExceptElse, ze, sp )^.Flags, flCompound );
                   else                AddBlock( btElse,       ze, sp )
                   end
                   end;
    btFor    : AddBlock( btFor,   ze, sp );
    btWhile  : AddBlock( btWhile, ze, sp );
    btRepeat : AddBlock( btRepeat, ze, sp );
    btUntil  : if Source.Lang = lgC then begin
                   if pAktBlock^.Typ <> btBegin then begin
                     while pAktBlock^.Typ <> btRepeat
                        do EndBlock;
                     EndBlock;
                     end;
                   AddBlock( btUntil,  ze, sp )
                   end
               else begin
                   while pAktBlock^.Typ <> btRepeat
                      do EndBlock;
                   EndBlock;
                   AddBlock( btUntil,  ze, sp )
                   end;
    btStm    : AddBlock( btStm,     ze, sp );
    btCase   : AddBlock( btCase,    ze, sp );
    btCaseStm: AddBlock( btCaseStm, ze, sp );
    btCaseSel: begin
                 while pAktBlock^.Typ <> btCase do EndBlock;
                 include( AddBlock( btCaseSel, ze, sp )^.Flags, flCompound )
               end;
    btCaseElse:begin
                 while pAktBlock^.Typ <> btCase do EndBlock;
                 include( AddBlock( btCaseElse, ze, sp )^.Flags, flCompound )
               end;
    btCaseEnd: begin
                 while pAktBlock^.Typ <> btCase do EndBlock;
                 AddBlock( btCaseEnd,    ze, sp );
                 EndBlock;
                 EndBlock
               end
    else       ShowMessage( 'Error in Found-Type ' {$IFDEF TraceDx} + GetBlockTyp( t ) {$ENDIF} )
    end;
end;

{ FreeBlocks }
procedure FreeBlocks;
var i,j: tBlockIndex;
begin
    {$IFDEF TraceDx} TraceDx.Send( 'FreeBlocks' ); {$ENDIF}
  for i := 1 to high( BlockListArr ) do begin
    for j := 0 to cBlockListChunk do if BlockListArr[i]^[j].Typ in btSubView then BlockListArr[i]^[j].SubInfo.Header := '';
    FreeMem( BlockListArr[i] )
    end
end;

initialization
  SetLength( BlockListArr, 1 );
  BlockListArr[0] := @BlockListArr0;

finalization
  FreeBlocks

end.

