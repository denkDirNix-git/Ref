
unit uScan;
{$INCLUDE _CompilerOptions.pas}
{ $UNDEF TraceDx}

interface

type
  TScanner = record
               class procedure ScanPas;   static;
               class procedure ScanC;     static;
             end;

var
  SubInterface    : boolean = true;
  OptionRefCalled : boolean = false;


implementation

uses
  System.Character,
  System.SysUtils,
  System.Classes,
  Vcl.Dialogs,
  {$IFDEF TraceDx} uTraceDx, {$ENDIF}
  uGlobalData,
  uBlock,
  uDiagnose,
  uViewer;      // kann vielleicht raus

const
  cUnderscore   = '_';
  cTab          = #9;
  cEOF          = #12;

var
  pcEOF         : char = cEoF;
  cBlank        : char = ' ';
  pc            : pChar;
  LastStartPos,
  AktPos        : tSourcePos;
  AktCommentLine: tSourcePosIdx;
  AktTextArt    : tTextArt;
  AktStatement  : tBlockTyp;
  FirstScan     : boolean = true;
  ScanOneProc,
  InComment,
  BehindColon,
  InId          : boolean;
//  LnLen: word;               tbd


{ setLastNonBlank }
procedure setLastNonBlank( p: tSourcePos ); inline;
begin
  LastNonBlank := p
end;

{ AddTextArt }
procedure AddTextArt( art: tTextArt; pos: tSourcePos );
begin
  if AktTextArt <> art then begin
    AktTextArt := art;
    if MaxTextArtIdx + 2 { zusätzlich 2 Einträge für artSearch } = high( TextArtArray ) then
      SetLength( TextArtArray, high( TextArtArray ) + ( length( Source.Lines ) - LastNonBlank{nicht AktPos wegen btFinal}.ze ) * 2 );  //  pro Restzeile 2 Einträge )
    TextArtArray[MaxTextArtIdx].Pos := pos;
    inc( MaxTextArtIdx );
    TextArtArray[MaxTextArtIdx].Art := AktTextArt
    end
end;

{ incZeile }
procedure incZeile;
label Nochmal;
var ze_: tSourcePosIdx;
begin
  {$IFDEF TraceDx} TraceDx.Send( 'incZeile ' + AktPos.ze.ToString, Source.Lines[abs(AktPos.ze)] ); {$ENDIF}
  Nochmal:
  ze_ := AktPos.ze;
  repeat inc( AktPos.ze );
         if AktPos.ze > high( Source.Lines ) then begin pc := @pcEOF; exit end
  until length( Source.Lines[AktPos.ze].TrimLeft ) > 0;

  if Source.Lang in [lgPascal, lgPascal86] then
    if ( AktPos.ze > ze_ + 1 ) and
     ( pAktBlock^.Typ <> btIf ) // Ausnahme bei if: neuer Block wäre sonst im then-Zweig
    then BehindColon := true;   // immer neuer Block nach Leerzeile

  InId      := false;
  AktPos.sp := 0;
  pc        := @Source.Lines[AktPos.ze][0];

  if ( Source.Lang = lgPascal86 ) and not InComment and ( pc^ = '$' ) then begin
    TBlock.Found( btDummy, AktPos.ze, AktPos.sp );
//    BehindColon := true;
    AddTextArt( artComment, AktPos );
    AktPos.sp := high( Source.Lines[AktPos.ze] );
    setLastNonBlank( AktPos );
    Source.LineInfo[AktPos.ze].Content := [coComment, coCommentIsLine];
    goto Nochmal
  end;

  while ( pc^ = ' ' ) or ( pc^ = cTab ) do begin
    inc( AktPos.sp ); inc( pc ) end;
  Source.LineInfo[AktPos.ze].NonBlank1 := AktPos.sp;

end;

{ incSpalte }
procedure incSpalte;
begin
  if AktPos.sp < high( Source.Lines[AktPos.ze] ) then begin
    inc( AktPos.sp ); inc( pc ) end
  else
    if InId {nur wenn InId, sonst ergibt sich Trennung bereits im Scan} and ( AktPos.sp = high( Source.Lines[AktPos.ze] ))
      then begin inc( AktPos.sp ); pc := @cBlank end      // Dummy um Trennung von der nächsten Zeile zu realisieren
      else incZeile
end;

{ ScannerInit }
function ScannerInit( const ParaProc: string ): boolean;

  function IsProcDeclareLine( const s: string; i: tSourcePosIdx ): boolean;
  var p: tSourcePosIdx;
  begin
    Result := true;
    p := s.IndexOf( 'procedure' );
    if ( p = -1 ) or ( p >= i ) then begin
      p := s.IndexOf( 'function' );
      if ( p = -1 ) or ( p >= i ) then
        if Source.Lang = lgPascal then begin
          p := s.IndexOf( 'constructor' );
          if ( p = -1 ) or ( p >= i ) then begin
            p := s.IndexOf( 'destructor' );
            if ( p = -1 ) or ( p >= i ) then
              Result := false
            end
          end
        else
          Result := false
      end
  end;

  function SearchProcName: tSourcePosIdx;
  var i,j : tSourcePosIdx;
      s, l: string;
      f   : boolean;
  begin
      { Search procName in file }
      s := ParaProc.ToLower;
      f := false;
      for i := high( Source.Lines ) downto 0 do begin
        l := Source.Lines[i].ToLower;
        j := l.IndexOf( s );
        if ( j > 8 ) and                                                            // vorhanden und davor noch Platz für "procedure"
           not l[j-1].IsLetterOrDigit and                                           // direkt vor Procname kein Zeichen
           ( j+length(s) < length( l )) and not l[j+length(s)].IsLetterOrDigit and  // direkt dahinter auch nicht
           IsProcDeclareLine( l, j-8 )                                              // aber proc/func/constr/deconstr
          then begin f := true; break end;
        end;

      if f then begin
        Source.Proc := ParaProc;
        Result := i
        end
      else
        Error( erProcNotFound, ParaProc )
  end;

begin
  {$IFDEF TraceDx} TraceDx.Send( 'TScanner.Init' ); {$ENDIF}
  InComment        := false;
  AktCommentLine   := -1;
  MaxTextArtIdx    := 0;                     // TestArt
  AktTextArt       := artUnknown;            // Eintrag 0
  TextArtArray[0].Art    := artUnknown;       // direkt
  TextArtArray[0].Pos.ze := 0;             // setzen
  TextArtArray[0].Pos.sp := 0;
  Result           := true;
  ScanOneProc      := ( ParaProc <> EmptyStr ) and ( Source.Lang in [lgPascal,lgPascal86] );
  Source.StartLine := 0;
  Source.EndLine   := high( Source.Lines );
  if ScanOneProc then begin
    if ParaProc[0].IsDigit then begin
      AktPos.ze := ParaProc.toInteger;
      if (( AktPos.ze >= 0 )and ( AktPos.ze < high( Source.Lines ))) { and IsProcDeclareLine( Source.Lines[AktPos.ze], MaxInt ) } then begin
        Source.Proc      := EmptyStr;  // Start at specified Line, set ProcName
        Source.StartLine := AktPos.ze
        end
      else
        Error( erLineIsNotProc, ParaProc )
      end
    else begin
      AktPos.ze := SearchProcName;
      Source.StartLine := AktPos.ze - 1
      end;
    // Vor-Kommentar auch noch mitnehmen:
    repeat dec( AktPos.ze )
    until  ( AktPos.ze < 0 ) or ( Source.Lines[AktPos.ze].Trim = EmptyStr )
    end
  else
    AktPos.ze := -1;
  IncZeile
end;

{ TestChar }
function TestChar( c: char ): boolean;
begin
  if AktPos.sp < high( Source.Lines[AktPos.ze] )
    then Result := (pc+1)^.ToLower = c
    else Result := false
end;

{ TestCharInc }
function TestCharInc( c: char ): boolean;
begin
  Result := TestChar( c );
  if Result then incSpalte
end;

{ TScanner.ScanPas }
class procedure TScanner.ScanPas;
const cNoClass       = -1;
var RecordNesting    : integer;
    InStatements,
    InImplementation,
    InConstTypeVar,
    BehindColonOld,
    DelayedColon     : boolean;
    pLetzterBlock    : pBlockInfo;
    spOld, spNeu, z  : tSourcePosIdx;
    LastClass,
    LastClassNonBlank,
    LastBeforeSpecial: tSourcePos;

  { TestWord }
  function TestWord( const s: string ): boolean;
  var i: word;
  begin
    InId := true;
    if AktPos.sp <= length( Source.Lines[AktPos.ze] ) - length( s ) then begin
      for i := 1 to high( s ) do if (pc+i)^.ToLower <> s[i] then exit( false );
      Result := ( AktPos.sp + length( s ) = high( Source.Lines[AktPos.ze] ) + 1 ) or
                not ( (pc+i)^.IsLetterOrDigit  or  ( (pc+i)^ = cUnderscore ));
      if Result then begin
        AddTextArt( artKeyword, AktPos );
        inc( AktPos.sp, length( s ) - 1 );
        inc( pc,        length( s ) - 1 );
        BehindColon := false;
        InId        := false
        end
      end
    else
      Result := false;
  end;

  procedure IgnoreKeyword( l: word );
  begin
    dec( AktPos.sp, l );
    dec( pc, l );
    BehindColon := true;
    InId := true
  end;

  procedure IsStatement;
  begin
    DummyContainsStm := true;
    include( Source.LineInfo[AktPos.ze].Content, coStatement );
    AddTextArt( artStatement, AktPos );
//    setLastNonBlank( AktPos )
  end;

  procedure ProcNoEnd;   // die eben angelegte proc ist forward oder external und hat deshalb kein begin-end
 { proc-Block (und ggf SubView) auflösen und in Stm verwandeln }
   begin
    pAktBlock^.Typ := btFree;
    if pAktBlock^.Prev^.Typ = btSubViewFix then begin
      pAktBlock := pAktBlock^.Prev;
      pAktBlock^.SubInfo.Header := ''
      end;
    pLastBlock     := pAktBlock;
    pAktBlock^.Typ := btDummy;
    pAktBlock^.Sub := nil;
    TextArtArray[MaxTextArtIdx].Art := artStatement   // NICHT als Keyword werten
  end;

  procedure ToNextChar;
  begin
    while pc <> @cBlank do
      if pc^ = ' '
        then incSpalte
        else break
  end;

  function TestNextChar: char;
  var pc_    : pChar;
      AktPos_: tSourcePos;
  begin
    pc_ := pc;
    AktPos_ := AktPos;
    while pc <> @cBlank do
      if pc^ = ' '
        then incSpalte
        else break;
    Result := (pc+1)^;
    pc := pc_;
    AktPos := AktPos_
  end;

  procedure IsUsesConstTypeVar;
  { Für Text-Blöcke nach Uses, Const, Type, Var soll auch nach Leerzeilen die Start-Spalte des ersten Blockes
    für die Folge-Blöcke gelten. Dafür hier Flag "InConstTypeVar" setzen                                      }
  begin
    {$IFDEF MitCTV}
    if RecordNesting = 0 then begin
      InId := true;
      InConstTypeVar := true;
      exclude( pAktBlock^.Flags, flConstTypeVar )
      end
    {$ENDIF}
  end;

begin
  try
    if FirstScan
      then FirstScan := false
      else TBlock.ReUse;
    TBlock.Init;
    ScannerInit( Source.Proc.ToLower );
    setLastNonBlank( AktPos );   // damit ein als erstes gefundenes "procedure" auf vorhergehenden ":" getestet werden kann
    if pc^ = '/' then            // damit Start-Kommentar in der ersten Zeile erfasst wird
      dec( LastNonBlank.ze );
    LastClass.ze    := cNoClass;
    RecordNesting   := 0;
    BehindColon     := true;    // -> falls next = non-Keyword: textBlock aufmachen
    InStatements    := false;   // ich bin nicht in einem Deklarationsteil der Source
    InImplementation:= true;
    InConstTypeVar  := false;
    with AktPos do while pc^ <> cEOF do
      if InId then begin
        include( Source.LineInfo[ze].Content, coStatement );                    // ist hier
        while pc^.IsLetterOrDigit or ( pc^ = cUnderscore ) do begin
          setLastNonBlank( AktPos );
          incSpalte
          end;
        InId := false
        end
      else begin     // alternative Abfrage zu     pc^.isLetter
        DelayedColon     := false;
        DummyContainsStm := true;
        if ( cardinal( pc^ ) or $20 >= $61 ) and ( cardinal( pc^ ) or $20 <= $7A ) then begin
          pLetzterBlock  := pLastBlock;      // hierüber erkennen, ob ein neuer Block angelegt wurde
          BehindColonOld := BehindColon;     // falls nein: im TestWord wrd bei korrektem Keyword BehindColon kaputt gemacht, sichern
          spOld          := sp;              // außerdem wird sp weitergeschaltet, auch sichern
          if InStatements then
            case pc^ of
              {$IFNDEF Pascal86}
              'a','A': if TestWord( 'asm' )         then begin TBlock.Found( btAsm,    ze, sp-2 ); DelayedColon := true end;
              {$ENDIF}
              'b','B': if TestWord( 'begin' )       then begin TBlock.Found( btBegin,  ze, sp-4 ); DelayedColon := true end;
              'c','C': if TestWord( 'case' )        then
                         if RecordNesting = 0       then       TBlock.Found( btCase,   ze, sp-3 );
              'd','D': if TestWord( 'do' )          then begin                                     DelayedColon := true end;
              'e','E': if TestWord( 'else' )        then begin TBlock.Found( btElse,   ze, sp-3 ); DelayedColon := true end else
              {$IFNDEF Pascal86}
                       if TestWord( 'except' )      then begin TBlock.Found( btExcept, ze, sp-5 ); DelayedColon := true end else
              {$ENDIF}
                       if TestWord( 'end' )         then begin TBlock.Found( btEnd,    ze, sp-2 );
                                                               if pLastBlock^.Prev^.Typ = btProc {nicht case,try} then
                                                                 if flAnonymProc in pLastBlock^.Prev^.Flags then
                                                                   DelayedColon := true   // InStatements bleibt true
                                                                 else begin
                                                                     InStatements := false;
                                                                     if ScanOneProc and ( pAktBlock^.Typ = btMain ) then begin
                                                                       sp := high( Source.Lines[ze] );      // Rest der Zeile auch noch
                                                                       setLastNonBlank( AktPos );           // und dann
                                                                       break                                // (evtl vorzeitig) beenden
                                                                       end
                                                                     end
                                                         end;
              'f','F': if TestWord( 'for' )         then       TBlock.Found( btFor,    ze, sp-2 ) else
              {$IFNDEF Pascal86}
                       if TestWord( 'finally' )     then begin TBlock.Found( btFinally,ze, sp-6 ); DelayedColon := true end else
                       if TestWord( 'finalization' )then begin TBlock.Found( btFinal,  ze, sp-11); InStatements := true; DelayedColon := true end else
              {$ENDIF}
                       if TestWord( 'function' )    then begin TBlock.Found( btProc,   ze, sp-7 ); include( pAktBlock^.Flags, flAnonymProc ); InStatements := false end;
              'i','I': if TestWord( 'if' )          then       TBlock.Found( btIf,     ze, sp-1 );
              'o','O': if TestWord( 'of' )          then begin                                     DelayedColon := true end else
              {$IFNDEF Pascal86}
                       if TestWord( 'on' )          then begin TBlock.Found( btOn,     ze, sp-1 )  end;
              {$ELSE}
                       if TestWord( 'otherwise' )   then begin TBlock.Found( btElse,   ze, sp-8 ); DelayedColon := true end;
              {$ENDIF}
              'p','P': if TestWord( 'procedure' )   then begin TBlock.Found( btProc,   ze, sp-8 ); include( pAktBlock^.Flags, flAnonymProc ); InStatements := false end;
              'r','R': if TestWord( 'repeat' )      then begin TBlock.Found( btRepeat, ze, sp-5 ); include( pAktBlock^.Flags, flCompound ); DelayedColon := true end;
              't','T': if TestWord( 'then' )        then begin TBlock.Found( btThen,   ze, sp-3 ); DelayedColon := true end
              {$IFNDEF Pascal86}                                                                                            else
                       if TestWord( 'try' )         then begin TBlock.Found( btTry,    ze, sp-2 ); DelayedColon := true end
              {$ENDIF} ;
              'u','U': if TestWord( 'until' )       then       TBlock.Found( btUntil,  ze, sp-4 );
              'w','W': if TestWord( 'with' )        then       TBlock.Found( btWith,   ze, sp-3 ) else
                       if TestWord( 'while' )       then       TBlock.Found( btWhile,  ze, sp-4 );
              else     InId := true
              end
          else  { not InStatements }
            case pc^ of
              {$IFNDEF Pascal86}
              'a','A': if TestWord( 'asm' )         then begin TBlock.Found( btAsm,    ze, sp-2 ); DelayedColon := true end;
              {$ENDIF}
              'b','B': if TestWord( 'begin' )       then begin TBlock.Found( btBegin,  ze, sp-4 ); InStatements := true; DelayedColon := true end;
              'c','C': if TestWord( 'const' )       then IsUsesConstTypeVar
              {$IFDEF Pascal86}
              ;
              {$ELSE} else
                       if TestWord( 'constructor' ) then
                         if ( RecordNesting = 0 ) and ( Source.Lines[LastNonBlank.ze][LastNonBlank.sp] <> ',' ) then
                           if LastClass.ze = cNoClass then                                           TBlock.Found( btProc,   ze, sp-10 )
                                                    else begin setLastNonBlank( LastClassNonBlank ); TBlock.Found( btProc,   LastClass.ze, LastClass.sp ); LastClass.ze := cNoClass end else else
                       if TestWord( 'class' )       then begin
                                                           if ( Source.Lines[LastNonBlank.ze][LastNonBlank.sp] = '=' ) and ( ze = LastNonBlank.ze{"=" aus CommentLine ausschliessen} ) then { Type-Deklaration } begin
                                                             incSpalte; ToNextChar;
                                                             if ( pc^ = ';'{"T = class;"} ) or ( pc^.ToLower = 'o'{"T = class of C"} ) then
                                                               { "T = class;"  forward-class, OHNE weiteren Inhalt }
                                                             else begin
                                                               if pc^ = '(' then begin
                                                                 { "T = class( TClass );" erkennen }
                                                                 repeat incSpalte until ( pc = @cBlank ) or ( pc^ = ')' );
                                                                 if pc^ = ')' then begin
                                                                   repeat incSpalte until ( ze > LastNonBlank.ze ) or ( pc = @cBlank ) or ( pc^ = ';' );
                                                                   if pc^ = ';' then
                                                                     dec( RecordNesting )    // wird gleich wieder inc
                                                                   end;
                                                                 end;
                                                               inc( RecordNesting );
                                                               end;
                                                             dec( pc ); dec( sp )      // wieder zurück und dieses Zeichen nochmal regulär lesen
                                                             end
                                                           else { class proc-impl  }
                                                             if RecordNesting = 0 then begin
                                                               LastClass.ze := ze; LastClass.sp := sp-4; LastClassNonBlank := LastNonBlank end;
                                                           {$IFDEF TraceDx} if RecordNesting > 0 then TraceDx.Send( 'RecordNesting', RecordNesting ); {$ENDIF}
                                                           pLetzterBlock := nil
                                                         end;
              'd','D': if TestWord( 'dispinterface' )   then begin
                                                           if Source.Lines[LastNonBlank.ze][LastNonBlank.sp] = '=' then begin
                                                             repeat incSpalte until ( pc = @cBlank ) or ( pc^ <> ' ' );
                                                             if pc^ <> ';' then
                                                               inc( RecordNesting );   // sonst leeres interface
                                                             dec( pc ); dec( sp )      // wieder zurück und dieses Zeichen nochmal regulär lesen
                                                             end
                                                           else
                                                             TBlock.Found( btDummy, ze, sp-12 );
                                                           pLetzterBlock := nil
                                                         end else
                       if TestWord( 'destructor' )  then
                         if RecordNesting = 0 then
                           if LastClass.ze = cNoClass then                                           TBlock.Found( btProc,   ze, sp-9 )
                                                    else begin setLastNonBlank( LastClassNonBlank ); TBlock.Found( btProc,   LastClass.ze, LastClass.sp ); LastClass.ze := cNoClass end;
              {$ENDIF}
              'e','E': if TestWord( 'end' )         then if RecordNesting > 0
                                                           then dec( RecordNesting )
                                                           else TBlock.Found( btEnd,    ze, sp-2 ) { Unit-Ende }
              {$IFNDEF Pascal86}                                                                                 else
                       if TestWord( 'external' )    and not InStatements
                                                    and ( Source.Lines[LastNonBlank.ze][LastNonBlank.sp] = ';' )   // davor ein ';' um Variable dieses Namens ausschliessen
                                                    and ( pAktBlock^.Typ = btProc )
                                                    { Korrektur 05.06.22: Nach "external" kommt idR ein String }
//                                                    and ( TestNextChar in [';',''''] )                             // danach ein ';'     "
                                                    then ProcNoEnd
              {$ENDIF} ;
              'f','F': if TestWord( 'function' ) then
                         if InImplementation and
                            ( Source.Lines[LastNonBlank.ze][LastNonBlank.sp] <> ':' ) and
                            ( Source.Lines[LastNonBlank.ze][LastNonBlank.sp] <> '=' ) { sonst aus Var-Deklaration} then begin
                           if RecordNesting = 0       then
                             if LastClass.ze = cNoClass then                                             TBlock.Found( btProc,   ze, sp-7 )
                                                        else begin setLastNonBlank( LastClassNonBlank ); TBlock.Found( btProc,   LastClass.ze, LastClass.sp ); LastClass.ze := cNoClass end
                           end
                         else
                           pLetzterBlock := nil else
              {$IFNDEF Pascal86}
                       if TestWord( 'finalization' )then begin TBlock.Found( btFinal, ze, sp-11 ); DelayedColon := true end  else
              {$ENDIF}
                       if TestWord( 'forward' )     and ( pAktBlock^.Typ = btProc )
                                                    and not InStatements
                                                    and ( Source.Lines[LastNonBlank.ze][LastNonBlank.sp] = ';' )   // davor ein ';' um Variable dieses Namens ausschliessen
                                                    and ( TestNextChar = ';' )                                     // danach ein ';'     "
                                                    then ProcNoEnd;
              {$IFDEF Pascal86}
              'm','M': if TestWord( 'module' )      then begin
                                                         TBlock.Found( btUnit,  ze, sp-5 ); {DelayedColon := true}; InImplementation := false end;
              {$ELSE}
              'i','I': if TestWord('implementation')then begin
                                                           if SubInterface then
                                                               TBlock.Found( btSubViewTmp, ze, sp-13 );
                                                           InImplementation := true;
                                                           TBlock.Found( btDummy, ze, sp-13 );
                                                           pLetzterBlock := nil;
  //                                                         BehindColon := true;
                                                         end else
                       if TestWord('initialization')then begin
                                                              TBlock.Found( btInitial, ze, sp-13 ); InStatements := true; DelayedColon := true end else
                       if TestWord( 'interface' )   then begin
                                                           if Source.Lines[LastNonBlank.ze][LastNonBlank.sp] = '=' then begin
                                                             repeat incSpalte until ( pc = @cBlank ) or ( pc^ <> ' ' );
                                                             if pc^ <> ';' then
                                                               inc( RecordNesting );   // sonst leeres interface
                                                             dec( pc ); dec( sp )      // wieder zurück und dieses Zeichen nochmal regulär lesen
                                                             end
                                                           else
                                                             if SubInterface
                                                               then TBlock.Found( btSubViewFix, ze, sp-8 )
                                                               else TBlock.Found( btDummy,      ze, sp-8 );
                                                           pLetzterBlock := nil
                                                         end;
              {$IFNDEF Pascal86}
              'l','L': if TestWord( 'library' )     then begin TBlock.Found( btUnit,  ze, sp-6 ); InImplementation := true end;
              {$ENDIF}
              'o','O': if TestWord( 'object' )      then begin // ähnlich  class
                                                           if Source.Lines[LastNonBlank.ze][LastNonBlank.sp].ToLower = 'f'
                                                             then // "proc of object;"
                                                             else inc( RecordNesting );
                                                           pLetzterBlock := nil
                                                         end else
                       if TestWord( 'operator' )    then
                                                      if RecordNesting = 0 then
                                                        if LastClass.ze = cNoClass then                                             TBlock.Found( btProc,   ze, sp-7 )
                                                                                   else begin setLastNonBlank( LastClassNonBlank ); TBlock.Found( btProc,   LastClass.ze, LastClass.sp ); LastClass.ze := cNoClass end
                                                        else
                                                          pLetzterBlock := nil;
              'u','U': if TestWord( 'unit' )        then begin TBlock.Found( btUnit,  ze, sp-3 ); {DelayedColon := true}; InImplementation := false end else
                       if TestWord( 'uses' )        then IsUsesConstTypeVar;
              {$ENDIF}
              'p','P': if TestWord( 'program' )     then begin TBlock.Found( btUnit,  ze, sp-6 ); InImplementation := true end else
              {$IFDEF Pascal86}
                       if TestWord( 'private' )     then begin InImplementation := true; IgnoreKeyword( 6 ) end else
              {$ENDIF}
                       if TestWord( 'procedure' )   then
                         if InImplementation and
                            ( Source.Lines[LastNonBlank.ze][LastNonBlank.sp] <> ':' ) and
                            ( Source.Lines[LastNonBlank.ze][LastNonBlank.sp] <> '=' ) { sonst aus Var-Deklaration} then begin
                           if RecordNesting = 0 then
                             if LastClass.ze = cNoClass then                                           TBlock.Found( btProc,   ze, sp-8 )
                                                      else begin setLastNonBlank( LastClassNonBlank ); TBlock.Found( btProc,   LastClass.ze, LastClass.sp ); LastClass.ze := cNoClass end
                           end
                         else
                           pLetzterBlock := nil;
              'r','R': if TestWord( 'record' )      then inc( RecordNesting ) else
                       if TestWord( 'reference' ) and InImplementation then begin
                                                       incSpalte;
                                                       repeat incSpalte until pc^ <> ' ';   // bis "to"
                                                       incSpalte;
                                                       repeat incSpalte until pc^ <> ' ';
                                                       TextArtArray[MaxTextArtIdx].Art := artStatement   // NICHT als Keyword werten
                                                       end;
              't','T': if TestWord( 'type' )        then IsUsesConstTypeVar;
              'v','V': if TestWord( 'var'  )        then IsUsesConstTypeVar;
              else     InId := true
              end;

          if InId then
            IsStatement;

          if pLetzterBlock = pLastBlock then begin
            BehindColon := BehindColonOld;     // Beschreibung
  //          dec( pc, sp-spOld );               // siehe oben
            spNeu := sp;
            sp    := spOld;                       // bei Initialisierung
            end;                               // vor der IF-Abfrage

          if DelayedColon then
            BehindColon := true
          else
            if BehindColon then begin
              TBlock.Found( btDummy, ze, sp );
              BehindColon := false;
              {$IFDEF MitCTV}
              if InConstTypeVar then begin
                { Für diesen ersten CTD-Block setzen. Die Flags der Folge-Blöcke werden im AddBlock gesetzt }
                {$IFDEF TraceDx} TraceDx.Send( 'flConstTypeVar' ); {$ENDIF}
                include( pAktBlock^.Flags, flConstTypeVar );
                InConstTypeVar := false
                end
              {$ENDIF}
              end;

          if pLetzterBlock = pLastBlock then
            sp := spNeu;

          setLastNonBlank( AktPos )
          end

        else begin
          InId := pc^.IsDigit or ( pc^ = cUnderscore );
          if InId then begin
            AddTextArt( artStatement, AktPos );
            if BehindColon then begin
              TBlock.Found( btDummy, ze, sp ); BehindColon := false end;
            setLastNonBlank( AktPos )
            end
          else begin
            LastBeforeSpecial := AktPos;
            case pc^ of
              ';' : begin
                      IsStatement;
                      setLastNonBlank( AktPos );
                      if InStatements {TBlock.VisitSemikolon} then begin
                        DelayedColon := true;
                        TBlock.Found( btSemi, ze, sp )
                        end
                    end;
              '{' : begin
                      InComment := true;
                      AddTextArt( artComment, AktPos );
                      repeat incSpalte until pc^ = '}';
                      for z := LastBeforeSpecial.ze to ze do include( Source.LineInfo[z].Content, coComment );
                      InComment := false;
                    end;
              '(' : if TestChar( '*' ) then begin
                      InComment := true;
                      AddTextArt( artComment, AktPos );
                      incSpalte;
                      repeat incSpalte until ( pc^ = '*' ) and TestChar( ')' );
                      for z := LastBeforeSpecial.ze to ze do include( Source.LineInfo[z].Content, coComment );
                      incSpalte;
                      InComment := false;
                      end
                    else
                      IsStatement;
              {$IFNDEF Pascal86}
              '/' : if TestChar( '/' ) then begin
                      DummyContainsStm := LastBeforeSpecial.sp = source.LineInfo[LastBeforeSpecial.ze].NonBlank1;
                      if ( ze = LastNonBlank.ze ) or
                         (( pLastBlock^.Typ in [btIf{alle Kommentare vorm then sind KEIN neuer Block}{, btDummy}] ) {and not DummyContainsStm} )
                      then
                        if ( pLastBlock^.Typ in btDontShow + [btBegin,btEnd,btCaseEnd] ) and not ( pLastBlock^.prev^.Typ in [btUnit,btProc] )
                          then TBlock.Found( btDummy, LastBeforeSpecial.ze, LastBeforeSpecial.sp )
                          else // an vorigen Block anhängen
                      else
                        if LastBeforeSpecial.sp = source.LineInfo[LastBeforeSpecial.ze].NonBlank1
                          then TBlock.Found( btComment , LastBeforeSpecial.ze, LastBeforeSpecial.sp )
                          else TBlock.Found( btDummyAbs, LastBeforeSpecial.ze, LastBeforeSpecial.sp );
                      AddTextArt( artComment, AktPos );
                      sp := high( Source.Lines[ze] );
                      include( Source.LineInfo[ze].Content, coComment );
                      include( Source.LineInfo[ze].Content, coCommentIsLine );
                      setLastNonBlank( AktPos );
                      incZeile;
                      Continue
                      end
                    else
                      IsStatement;
              '"' : repeat incSpalte until ( pc^ = '"' );
              '@' : begin
                      IsStatement;
                      if pLastBlock^.Prev^.Typ = btAsm then begin
                        repeat incSpalte until pc^ <> '@';
                        InId := true;
                        continue
                        end
                    end;
              '&' : begin
                      IsStatement;
                      InId := true
                    end;
              {$ENDIF}
              '''': begin
                      IsStatement;
                      repeat
                        repeat incSpalte until ( pc^ = '''' )
                      until not TestCharInc( '''' );
                    end;
              ':' : begin
                      IsStatement;
                      if InStatements and ( pLastBlock^.Typ = btCaseSel ) then
                        DelayedColon := true;
  //                      TBlock.Found( btDummy, ze, sp );
                    end;
              #9,
              ' ' : begin repeat incSpalte until pc^ <> ' '; continue end
              else  IsStatement
              end;

            if DelayedColon
              then BehindColon := true
              else if BehindColon then begin BehindColon := false; TBlock.Found( btDummy, LastBeforeSpecial.ze, LastBeforeSpecial.sp ) end;

            setLastNonBlank( AktPos )
            end;
          end;
        incSpalte
        end;
    TBlock.Found( btClose, 0, 0 );
    if Source.StartLine <> 0              // falls Scan auf proc reduziert:
      then Source.EndLine := AktPos.ze;   // nur bis hierhin suchen mit F3
    AktPos.ze := high( AktPos.ze );       // Endekennung für AddTextArt(), diese Zeile wird nie erreicht
    AddTextArt( artUnknown, AktPos );
  //  pLastBlock^.Prev^.TxtEnde.ze := 0;       // der Main-Block kann sonst
  //  pLastBlock^.Prev^.TxtEnde.sp := 0;       // Vorgeschichte enthalten
  except
    Exitcode := 7;
    {$IFDEF TraceDx} TraceDx.Send( 'Scan-Error', RecordNesting ); {$ENDIF}
    if OptionRefCalled
      then raise
      else Error( erScanner, AktPos.ze.toString + ' / ' + AktPos.sp.toString + ' / ' + RecordNesting.ToString  + ' / ' + TBlock.getBlockTyp( pLastBlock^.Typ ))
  end
end;

{ TScanner.ScanC }
class procedure TScanner.ScanC;
const cNoClass       = -1;
var KlammerLevel,
    RundKlammerLevel : word;
    BehindColonOld,
    InProc,
    IsStm,
    DelayedColon     : boolean;
    MayBeProcBlock,
    pLetzterBlock    : pBlockInfo;
    MayBeProcLine,
    spOld, spNeu, z  : tSourcePosIdx;
    LastBeforeSpecial: tSourcePos;

  { TestWord }
  function TestWord( const s: string ): boolean;
  var i: word;
  begin
    InId := true;
    if AktPos.sp <= length( Source.Lines[AktPos.ze] ) - length( s ) then begin
      for i := 1 to high( s ) do if (pc+i)^.ToLower <> s[i] then exit( false );
      Result := ( AktPos.sp + length( s ) = high( Source.Lines[AktPos.ze] )) or
                not ( ( pc+i)^.IsLetterOrDigit or ( ( pc+i)^ = cUnderscore ));
      if Result then begin
        AddTextArt( artKeyword, LastStartPos );
        inc( AktPos.sp, length( s ) - 1 );
        inc( pc,        length( s ) - 1 );
        IsStm := false;
        InId  := false
        end
      end
    else
      Result := false;
  end;

  procedure IsStatement;
  begin
    DummyContainsStm := true;
    include( Source.LineInfo[AktPos.ze].Content, coStatement );
    AddTextArt( artStatement, LastStartPos );
//    setLastNonBlank( AktPos )
  end;

  procedure ScanManyStm; forward;
  procedure ScanBegin; forward;
  function ScanStm: boolean; forward;

  function getNextStm: tBlockTyp;
  label L1;
  var cont: boolean;
      LastEnde,
      SavePos: tSourcePos;
      LastBlockTyp: tBlockTyp;
    procedure SkipId;
    begin
      InId := true;
      while pc^.IsLetterOrDigit or ( pc^ = cUnderscore ) do
        incSpalte;
      dec( AktPos.sp );
      dec( pc );
      InId := false
    end;
    procedure SkipBeginEnd;
    var Count: word;
        LastSave: tSourcePos;
    begin
      LastSave := LastStartPos;
      LastStartPos := AktPos;
//      inc( LastStartPos.sp );
      AddTextArt( artStatement, LastStartPos );
      LastStartPos := LastSave;
      repeat incSpalte until pc^ = '{';  // Anfang gefunden
      Count := 1;
      repeat incSpalte;
        case pc^ of
          '{': inc( Count );    // kann geschachtelt vorkommen?
          '}': dec( Count );
          end;
      until Count = 0;
      Result := btDummyAbs    // NICHT btDummy damit SkipId() nicht aufgerufen wird
    end;
  begin
    cont := false;
    L1:
    if not cont then
      setLastNonBlank( AktPos );
    LastEnde := AktPos;
    DelayedColon     := false;
    DummyContainsStm := true;
    repeat incSpalte until ( pc^ <> ' ' ) and ( pc^ <> cTab );

    if false and not InProc and ( pc^ <> cEOF ) and cont and
       (( pLastBlock^.Prev^.prev = nil ) or not ( pLastBlock^.Prev^.Typ in [btThen,btElse] ) { nicht zwischen then und else } ) then
      if AktPos.ze > lastEnde.ze + 1 then begin
        {$IFDEF TraceDx} TraceDx.Send( 'Insert BlankLine-DummyBlock' ); {$ENDIF}
        AktPos := LastEnde;
        TBlock.Found( btStm, LastStartPos.ze, LastStartPos.sp );
        setLastNonBlank( LastEnde );
        AktPos := LastEnde;
        repeat incSpalte until ( pc^ <> ' ' ) and ( pc^ <> cTab );
        LastStartPos := AktPos;
        AktStatement := btStm;
        exit
        end;

    Result := btDummy;
    IsStm := true;
    if not cont then
      SavePos := AktPos;      // für Start dieses Blocks im AddBlock()
    LastStartPos := AktPos;   // für AddTextArt

    if ( cardinal( pc^ ) or $20 >= $61 ) and ( cardinal( pc^ ) or $20 <= $7A ) then begin
      case cardinal( pc^ ) or $20 of
        $63 {'c','C'}: if TestWord( 'case' )    then Result := btCaseSel  else
                       if TestWord( 'class' )   then SkipBeginEnd         else  // ToDo "class c;" ist auch okay
                       if TestWord( 'catch' )   then {SkipBeginEnd}Result := btExcept;
        $64 {'d','D'}: if TestWord( 'do' )      then Result := btRepeat   else
                       if TestWord( 'default' ) then begin
                         if cont then begin
                           TBlock.Found( btStm, SavePos.ze, SavePos.sp );
                           setLastNonBlank( LastEnde );
//                           SavePos := AktPos
                           SavePos := LastStartPos
                           end;
                         Result := btCaseElse;
                         end;
        $65 {'e','E'}: if TestWord( 'else' )    then Result := btElse     else
                       if TestWord( 'enum' )    then SkipBeginEnd;
        $66 {'f','F'}: if TestWord( 'for' )     then Result := btFor;
        $69 {'i','I'}: if TestWord( 'if' )      then Result := btIf;
        $6E {'n','N'}: if TestWord( 'namespace')then Result := btUnit;
//        $6F {'o','O'}: if TestWord( 'operator' )then asm int 3 end;       // ToDo
        $73 {'s','S'}: if TestWord( 'switch' )  then Result := btCase     else
                       if TestWord( 'struct' )  then SkipBeginEnd;
        $74 {'t','T'}: if TestWord( 'try' )     then Result := btTry;
        $75 {'u','U'}: if TestWord( 'union' )   then SkipBeginEnd;
        $77 {'w','W'}: if TestWord( 'while' )   then Result := btWhile
        end;
        if Result = btDummy then SkipId
        end
    else
      case pc^ of
        '_'    : if TestWord( '__finally' ) then Result := btTry else
                 if TestWord( '__try' )     then Result := btTry else
                 if TestWord( '__except' )  then Result := btTry else
                                                 SkipId;
        '\'    : if TestCharInc( '"' ) or TestCharInc( '''' ) then;       // escape-Seq
        cEof   : begin
                   Result := btNil;
                   AktStatement := btNil;
                   if AktTextArt = artComment
                     then begin LastStartPos := SavePos; AktPos := LastEnde end;
                   exit
                 end;
        '{'    : begin
                   inc( KlammerLevel ); Result := btBegin;
                   if cont and (( MayBeProcBlock <> nil ) or InProc ) then begin
                     if MayBeProcBlock <> nil then begin
                       LastBlockTyp := pLastBlock^.Typ; pLastBlock^.Typ := btProc end;  // Damit folgendes Stm auf keinen Fall NextBlock wird
                     TBlock.Found( btStm, SavePos.ze, SavePos.sp );
                     if MayBeProcBlock <> nil then pLastBlock^.Typ := LastBlockTyp;
                     setLastNonBlank( LastEnde );
                     SavePos := AktPos
                     end;
                 end;
        '}'    : begin
                   dec( KlammerLevel ); Result := btEnd;
                   if cont and InProc then begin
                     TBlock.Found( btStm, SavePos.ze, SavePos.sp );
                     setLastNonBlank( LastEnde );
                     SavePos := AktPos
                     end;
                 end;
        '('    : begin
                   if not InProc and
                      (( KlammerLevel = 0 ) or (( KlammerLevel = 1 ) and ( pAktBlock^.Prev^.Prev <> nil ) and ( pAktBlock^.Prev^.Prev^.Typ = btUnit ) )) then begin
                      MayBeProcBlock := pLastBlock;
                      MayBeProcLine  := AktPos.ze
                      end;
                   inc( RundKlammerLevel )
                 end;
        ')'    : dec( RundKlammerLevel );
        '#'    : begin
                   IsStm := false;
                   AddTextArt( artComment, LastStartPos );
                   cont := AktPos.sp = Source.LineInfo[AktPos.ze].NonBlank1;
                   repeat AktPos.sp := high( Source.Lines[AktPos.ze] );
                          if Source.Lines[AktPos.ze][AktPos.sp] = '\'
                            then incZeile
                            else break
                   until false;
                   if InProc
                     then goto L1
                     else Result := btComment
                 end;
        '/'    : if TestChar( '/' ) then begin
                   IsStm := false;
                   AddTextArt( artComment, LastStartPos );
                   cont := AktPos.sp = Source.LineInfo[AktPos.ze].NonBlank1;
                   AktPos.sp := high( Source.Lines[AktPos.ze] );
                   if InProc
                     then goto L1
                     else Result := btComment
                   end
                 else if TestChar( '*' ) then begin
                   IsStm := false;
                   AddTextArt( artComment, LastStartPos );
                   InComment := true;
                   repeat
                     repeat incSpalte until ( pc^ = '*' )
                   until TestCharInc( '/' );
                   InComment := false;
                   cont := true;
                   if InProc
                     then goto L1
                     else Result := btComment
                   end;
        ':'    : if pAktBlock^.Typ in [btCaseSel,btCaseElse] then
                   Result := btDblPoint;
        ';'    : if InProc then Result := btSemi else MayBeProcBlock := nil;
        '"'    : repeat
                     repeat incSpalte;
                            if pc^ = '\' then begin
                              incSpalte; incSpalte end
                     until ( pc^ = '"' )
                 until not TestCharInc( '"' );
        ''''   : repeat
                     repeat incSpalte until ( pc^ = '''' )
                 until not TestCharInc( '''' )
        end;
   if IsStm then
     IsStatement;
   LastStartPos := SavePos;
   AktStatement := Result;
  end;

  procedure ScanSwitch;
  begin
      {$IFDEF TraceDx} TraceDx.Call( 'ScanSwitch' ); {$ENDIF}
      TBlock.Found( btCase, LastStartPos.ze, LastStartPos.sp );
      repeat until getNextStm = btBegin;
      ScanBegin;
      pLastBlock^.Typ := btCaseEnd;   // statt btEnd
  end;

  function ScanFor: boolean;
  begin
      {$IFDEF TraceDx} TraceDx.Call( 'ScanFor' ); {$ENDIF}
      Result := false;
      TBlock.Found( btFor, LastStartPos.ze, LastStartPos.sp );
      getNextStm;  { '(' }
      repeat getNextStm until RundKlammerLevel = 0;
      if getNextStm = btSemi then begin
        pAktBlock^.Typ := btStm;    { leeres if (); }
        Result := true;
        getNextStm
        end
      else
        Result := ScanStm;
  end;

  function ScanTryFinally: boolean;
  begin
      {$IFDEF TraceDx} TraceDx.Call( 'ScanTryFinally' ); {$ENDIF}
      Result := false;
      TBlock.Found( btWhile, LastStartPos.ze, LastStartPos.sp );
      repeat until getNextStm = btBegin;
      ScanBegin;
      if AktStatement = btSemi then begin
        pAktBlock^.Typ := btStm;    { leeres if (); }
        Result := true;
        getNextStm
        end
      else
        Result := ScanStm
  end;

  function ScanWhile: boolean;
  begin
      {$IFDEF TraceDx} TraceDx.Call( 'ScanWhile' ); {$ENDIF}
      Result := false;
      TBlock.Found( btWhile, LastStartPos.ze, LastStartPos.sp );
      getNextStm;  { '(' }
      repeat getNextStm until RundKlammerLevel = 0;
      if getNextStm = btSemi then begin
        pAktBlock^.Typ := btStm;    { leeres if (); }
        Result := true;
        getNextStm
        end
      else
        Result := ScanStm
  end;

  function ScanRepeat: boolean;
  begin
      {$IFDEF TraceDx} TraceDx.Call( 'ScanRepeat' ); {$ENDIF}
      TBlock.Found( btRepeat, LastStartPos.ze, LastStartPos.sp );
      getNextStm;
      ScanStm;
      TBlock.Found( btUntil, LastStartPos.ze, LastStartPos.sp );
      getNextStm;  { '(' }
      repeat getNextStm until RundKlammerLevel = 0;
      getNextStm;
      Result := aktstatement = btSemi;
  end;

  function ScanIf: boolean;
  var pIf: pBlockInfo;
  begin
      {$IFDEF TraceDx} TraceDx.Call( 'ScanIf' ); {$ENDIF}
      Result := false;
      TBlock.Found( btIf, LastStartPos.ze, LastStartPos.sp );
      pIf := pAktBlock;
      getNextStm;  { '(' }
      repeat getNextStm until RundKlammerLevel = 0;

      if getNextStm = btSemi then begin
        pAktBlock^.Typ := btStm;    { leeres if (); }
        Result := true;
        getNextStm
        end
      else begin
        TBlock.Found( btThen, LastStartPos.ze, LastStartPos.sp );
        Result := ScanStm;
        pAktBlock := pIf;
        if AktStatement = btElse then begin
          DummyContainsStm := true;
          TBlock.Found( btElse, LastStartPos.ze, LastStartPos.sp );
          getNextStm;
          Result := ScanStm
          end
        else begin
          include( pAktBlock^.Flags, flEmptyElse );
          TBlock.Found( btElse, LastStartPos.ze, LastStartPos.sp )
          end
        end;
  end;

  procedure ScanBegin;
  begin
    {$IFDEF TraceDx} TraceDx.Call( 'ScanBegin' ); {$ENDIF}
    TBlock.Found( btBegin, LastStartPos.ze, LastStartPos.sp );
    getNextStm;
    ScanManyStm;
    TBlock.Found( btEnd, LastStartPos.ze, LastStartPos.sp );
    if pLastBlock^.Prev^.Typ = btProc then
      InProc := false;
    getNextStm;
  end;

  function ScanStm: boolean;
  //   Result = true: ich bin bereit für nächstes Stm in ScanManyStm. Weil ';' oder '}' am Ende
  const btFinishStm = [btEnd, btElse{, btCaseSel, btCaseElse}];
  var Start: boolean;
      Count: word;
  begin
      {$IFDEF TraceDx} TraceDx.Call( 'ScanStm' ); {$ENDIF}
      Result := false;
      Start  := true;
      while true do begin
          case AktStatement of
              btNil   : break;
              btSemi  : if RundKlammerLevel = 0 then begin
                          TBlock.Found( btSemi, AktPos.ze, AktPos.sp );
                          getNextStm;
                          Result := not ( AktStatement in btFinishStm );   // für ScanMany: weitermachen
                          break
                          end
                        else
                          getNextStm;
              btUntil,
              btElse,
              btEnd   : break;
              btBegin : if Source.Lines[LastNonBlank.ze][LastNonBlank.sp] = '=' then begin
                          (* Const-Definition wie enum a = {....} *)
                          Count := 1;
                          repeat incSpalte;
                                 case pc^ of
                                   '{': inc( Count );    // kann geschachtelt vorkommen?
                                   '}': dec( Count );
                                   end;
                           until Count = 0;
                          dec( KlammerLevel );  // weil getNextStm nur eine öffnende gesehen hat
                          getNextStm
                          end
                        else begin
                          ScanBegin;
                          Result := not ( AktStatement in btFinishStm );
                          break
                          end;
              btIf    : begin Result := ScanIf; break end;
              btCase  : begin ScanSwitch; Result := not ( AktStatement in btFinishStm );  (* immer true weil endet auf "}" *); break end;
              btCaseSel,
              btCaseElse: begin
                           TBlock.Found( AktStatement {caseSel oder caseElse}, LastStartPos.ze, LastStartPos.sp );
                           repeat until getNextStm = btDblPoint;
                           getNextStm;
                           continue  // damit "Start" nicht auf false gesetzt wird
                         end;
              btFor   : begin Result := ScanFor; break end;
              btWhile :       if Start
                                then begin Result := ScanWhile; break end
                                else begin AktStatement := btUntil; break end;
              btRepeat: begin Result := ScanRepeat; break end;
              btTry   : begin Result := ScanTryFinally; break end;
              btExcept: begin Result := ScanWhile; break end
              else      // Statement oder Comment
                        if Start then
                          TBlock.Found( btDummy, LastStartPos.ze, LastStartPos.sp );
                        getNextStm
              end;
          Start := false
          end;
  end;

  procedure ScanManyStm;
  begin
      {$IFDEF TraceDx} TraceDx.Call( 'ScanManyStm' ); {$ENDIF}
      repeat until not ScanStm;
  end;

  procedure ScanFile;
  var SavePos: tSourcePos;
      pBlock: pBlockInfo;
  begin
      {$IFDEF TraceDx} TraceDx.Call( 'ScanFile' ); {$ENDIF}
      getNextStm;
      if AktStatement = btComment
        then LastNonBlank.ze := -2
        else TBlock.Found( btDummy, LastStartPos.ze, LastStartPos.sp );
      while true do
          case AktStatement of
            btUnit : begin
                       TBlock.Found( btUnit, LastStartPos.ze, LastStartPos.sp );
                       repeat until getNextStm = btBegin;
                       TBlock.Found( btBegin, LastStartPos.ze, LastStartPos.sp );
                       getNextStm;
                       TBlock.Found( btDummy, LastStartPos.ze, LastStartPos.sp );
                     end;
            btEnd  : if pAktBlock^.Prev^.Typ = btUnit then begin   // namespace-end
                       TBlock.Found( btEnd, LastStartPos.ze, LastStartPos.sp );   // namespace-ende
                       pAktBlock := pAktBlock^.Prev;                              // namespace-ebene verlassen
                       getNextStm;
                       if ( pLastBlock^.Typ = btEnd ) and ( AktStatement <> btNil ) then
                         TBlock.Found( btStm, LastStartPos.ze, LastStartPos.sp );
                       setLastNonBlank( AktPos );
                       break
                       end
                     else   // non-proc-end
                       getNextStm;
            btNil  : break;   { = EoF }
            btBegin: if MayBeProcBlock <> nil then begin

                         if true then begin
                           { SubView einfügen }
                           MayBeProcBlock^.Typ := btSubViewFix;
                           include( MayBeProcBlock^.Flags, fl_AutoSubFix );
                           TBlock.Found( btProc, LastStartPos.ze, LastStartPos.sp );
                           pLastBlock^.TxtStart := MayBeProcBlock^.TxtStart;
                           pLastBlock^.TxtEnde  := MayBeProcBlock^.TxtEnde;
                           MayBeProcBlock^.SubInfo.Header := Source.Lines[MayBeProcLine];
                           end
                         else begin
                           { ohne SubView }
                           MayBeProcBlock^.Typ := btProc;
                           include( MayBeProcBlock^.Flags, flCompound )
                           end;

                         MayBeProcBlock := nil;
                         InProc := true;
                         ScanBegin;
                         repeat pAktBlock := pAktBlock^.Prev
                         until pAktBlock^.Typ in [btMain, btBegin];
                         if pAktBlock^.Typ = btMain then begin
                           if ( pLastBlock^.Typ = btEnd ) and ( AktStatement <> btNil ) then
                             TBlock.Found( btDummy, LastStartPos.ze, LastStartPos.sp )
                           end
                         else begin  { NameSpace }
//                           TBlock.Found( btDummy, LastStartPos.ze, LastStartPos.sp )
                           end;
                         InProc := false;
                         end
                     else
                         getNextStm;
            btComment:begin
                       if LastStartPos{AktPos}.ze > LastNonBlank.ze + 1
                         then TBlock.Found( btDummy, LastStartPos.ze, LastStartPos.sp )
                         else pLastBlock^.TxtEnde := AktPos;
                       getNextStm
                     end;
            btDummy: begin
                       if LastStartPos{AktPos}.ze > LastNonBlank.ze + 1
                         then TBlock.Found( btDummy, LastStartPos.ze, LastStartPos.sp );
                       getNextStm
                     end
            else     getNextStm
            end;
  end;

begin
  try
    if FirstScan
      then FirstScan := false
      else TBlock.ReUse;
    TBlock.Init;
    ScannerInit( Source.Proc.ToLower );
    AktPos.sp := -1;
    dec( pc );
//    setLastNonBlank( AktPos );   // damit ein als erstes gefundenes "procedure" auf vorhergehenden ":" getestet werden kann
    KlammerLevel    := 0;
    RundKlammerLevel:= 0;
    MayBeProcBlock  := nil;
    InProc          := false;
    ScanFile;
    (*if AktTextArt = artComment then begin
      // letzten Kommentar-Block einfügen:
      TBlock.Found( btDummy, LastStartPos.ze, LastStartPos.sp );
      setLastNonBlank( AktPos )
      end;*)
    TBlock.Found( btClose, 0, 0 );
    if Source.StartLine <> 0              // falls Scan auf proc reduziert:
      then Source.EndLine := AktPos.ze;   // nur bis hierhin suchen mit F3
    AktPos.ze := high( AktPos.ze );       // Endekennung für AddTextArt(), diese Zeile wird nie erreicht
    LastStartPos := AktPos;
    AddTextArt( artUnknown, LastStartPos );
  //  pLastBlock^.Prev^.TxtEnde.ze := 0;       // der Main-Block kann sonst
  //  pLastBlock^.Prev^.TxtEnde.sp := 0;       // Vorgeschichte enthalten
  except
    Exitcode := 7;
    {$IFDEF TraceDx} TraceDx.Send( 'Scan-Error'); {$ENDIF}
    Error( erScanner, AktPos.ze.toString + ' / ' + AktPos.sp.toString + ' / ' + TBlock.getBlockTyp( pLastBlock^.Typ ))
  end
end;

end.

