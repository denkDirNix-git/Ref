
unit uScanner;

{$INCLUDE _CompilerOptionsRef.pas}
{$INCLUDE _CompilerOptions.pas}
{ $UNDEF TraceDx}

interface

uses
  System.SysUtils,
  uGlobalsParser;

type
  TScanner = record
             public
               class procedure Init( sf: tProcString ); static;   // sf bisher nicht nötig !
               class procedure PreParse; static;
             end;

  TNext    = record
             public
               Token   : tKeyWord;
               Id      : tIdPosInfo;
//               Hash    : tHash;
               procedure init;
               function  get: tKeyWord;
               function  getIf( k: tKeyWord ): boolean;            // true falls Peek=k, und dann auch get. Sonst false
               function  Peek: tKeyWord;
               function  Peek2: char;
               procedure Test ( k           : tKeyWord );            // bei Test... muss kx gefunden werden, sonst Error
               procedure Test1( k           : tKeyWord );
               function  Test2( kTrue,kFalse: tKeyWord ): boolean;
               function  Test3( k0,k1,k2    : tKeyWord ): tKeyWord;
               function  TestForGeneric( p: tFilePos ): boolean;
             private
               ReUse : boolean
             end;

var
  ShowFile   : tProcString;
  OverNextKw : tKeyWord;
  Next       : TNext;
  LastLiteral: pIdInfo;
  kw_IN_Hash : tHash;

function  IsValidIdChar( c: char ): boolean;
procedure JumpFirstLine( f: pFileInfo );
function  NextWord: tKeyWord;
function  SymbolDefined( i: integer ): boolean;
function  NextPascalDirective1NoRead( d: tPascalDirektive ): boolean;
function  NextPascalDirective1( d: tPascalDirektive ): boolean;
function  NextPascalDirective (Erlaubt: tPascalDirektiveSets): tPascalDirektive;
function  NextIsCompilerAttribute: boolean;

implementation

uses
  {$IFDEF TraceDx} uTraceDx, {$ENDIF}
  System.IOUtils,
  System.Character,
  VCL.Forms,
  VCL.Dialogs,
  uSystem, uListen, uExpressions, uGlobals;

const
  cTAB   = #09;
  cEOL   = #10;
  cEOF   = #12;
  cCR    = #13;
  cBlank = ' ';

  cKeyWordTrenner     = '§';
  cOperators1         = ':+-*/.;^@&()=><<<<<[[[],{}';
  cCompilerDirektive  = '$';
  cMaxIfDefEbenen     = 16;

  {$IFDEF TraceDx}
  cColorScanner       = tcDefault;
  cColorSource        = tcGreen;
  {$ENDIF}

{$IFDEF TraceDx} type uScan = class end; {$ENDIF}

var
  IfDefZaehler: 0..cMaxIfDefEbenen;
  IfDefBool   : array[0..cMaxIfDefEbenen ] of ShortInt;    // 0 == Code ausführen
  IfDefEndIf  : array[0..cMaxIfDefEbenen ] of record Line: tLineIndex; Define: string; IfNDef: boolean end;
  IF_manuell  : boolean;

{$REGION '-------------- Peek Char ---------------' }

procedure JumpFirstLine( f: pFileInfo );
begin
  with f^ do begin
    if high( StrList ) > high( tLineIndex )
      then Error( errLineCount, Filename );
    if high( StrList ) = -1
      then begin liMax := 0; li := 1; exit end       // Sonderbehandlung für leere Source
      else liMax := high( StrList );
    li    := cZeile0;                                // erste Zeile
    while ( li <= liMax ) and ( StrList[li] = '' ) do
      inc( li );
    if li <= liMax
      then begin riMax := high( StrList[li] ); pi := @StrList[li][cSpalte0] end
      else begin riMax := 0;                   pi := nil;                   end;
    ri := cSpalte0
  end
end;

procedure JumpNextLine;
begin
  with pAktFile^ do begin
    inc( li );
    while ( li <= liMax ) and ( StrList[li] = '' ) do
      inc( li );
    if li <= liMax
      then begin riMax := high( StrList[li] ); pi := @StrList[li][cSpalte0] end
      else begin riMax := 0;                   pi := nil;                   end;
    ri := cSpalte0
  end
end;

function LookAhead( c: char ): boolean;
begin
with pAktFile^ do
   if ri = riMax
   then LookAhead := false
   else LookAhead := ( pi+1 )^ = c
end;

function LookAheadCh: char;
begin
with pAktFile^ do
  if ri = riMax
    then LookAheadCh := cEOF
    else LookAheadCh := ( pi+1 )^
end;

function PeekChar: char;
var s: string;
    {$IFDEF Debug} p: pointer; {$ENDIF}
begin
  with pAktFile^ do begin
    if ri > riMax then
      if li = liMax then
        if pAktFile^.PrevFile = cKeinFileIndex
          // existiert keine vorhergehende Datei, so soll das letzte Zeichen noch einen
          // Nachfolger haben
          then Result := ';'
          else Result := cEOF
      else
        Result := cEOL
    else begin
      Result := pi^;
      if Result = cTAB then begin
        { TAB führt auch in Courier zu verschobener Anzeige der Zeile. Deshalb hier austauschen: }
        include( pAktFile^.fiFlags, tFileFlags.hasTab );    // falls Datei verändert wird: Original vorher neu laden
//        s := StrList[li];
//        s[ri] := cBlank;                // falsch weil pc0 dann nicht mehr stimmt! Warum hatte ich das damals so gemacht?
//        StrList[li] := s;
        {$IFDEF Debug} p := @StrList[li][ri]; {$ENDIF}
        StrList[li][ri] := cBlank;        // Korrektur
        pi := @StrList[li][ri];
        {$IFDEF Debug} assert( p = pi, 'Tab-Exchange' ); {$ENDIF}
        Result := cBlank
        end
      end
    end
end;

procedure PeekInc; inline;
begin
  inc( pAktFile^.ri );
  inc( pAktFile^.pi )
end;

function PeekCharInc: char; inline;
begin
  PeekCharInc := PeekChar;
  PeekInc
end;

{$ENDREGION }

{$REGION '-------------- Keywords ---------------' }

procedure InsertKeyWordReference( Pos: tFilePos; k: tKeyWord );
var a: pAcInfo;
begin
  if ( not ParserState.AssemblerCode or ( k = kw_END )) and
     ((( k <= kw_LastKeyWordStr ) and FileOptions.RegKeywords   )   or
      (( k >  kw_LastKeyWordStr ) and FileOptions.RegKeySymbols ))  then begin
    {$IFDEF TraceDx} TraceDx.Call( uScan, 'InsertKeyWordReference' ); {$ENDIF}
    TListen.NewAc( a );
    with a^ do begin
      ZugriffTyp := ac_Read;
      Position   := Pos;
      if tFileFlags.LibraryPath in pAktUnit^.fiFlags
        then AcFlags := []
        else AcFlags := [tAcFlags.AcProjectUse];
      IdDeclare  := @KeyWordListe[k];
      IdUse      := AktDeclareOwner;
      NextAc     := nil
      end;
    with KeyWordListe[k] do begin
      if AcList = nil then begin
        AcList := a;
        inc( ZaehlerId[id_KeyWord] );
//        inc( ZaehlerIds );                            nicht zählen ( damit angezeigte Summen übereinstimmen obwohl Keyword-Zähler nicht angezeigt wird)
        end
      else
        LastAc^.NextAc := a;
      LastAc := a;
      if not ( tFileFlags.LibraryPath in pAktUnit^.fiFlags ) then
        include( IdFlags2, tIdFlags2.IdProjectUse )
      end
    end
end;

{$ENDREGION }

{$REGION '-------------- Formular ---------------' }

procedure ParseFormularObject( MyForm: pIdInfo );
var ExprType, pId: pIdInfo;
    AcPegelObjekt : tAcSeqIndex;

  procedure ParseToEnd( b: pIdInfo );
  var pId, pId2: pIdInfo;
      AcStart  : tAcSeqIndex;
      BitMap   : boolean;
  begin
//    while Next.Test3( kw_Identifier, kw_OBJECT, kw_END ) <> kw_END do
    while Next.get <> kw_END do     // auch inline, inherited, siehe samples
//      if Next.Token = kw_OBJECT then begin
      if Next.Token <> kw_Identifier then begin
        TListen.LeaveBlock;
        {if Next.Token = kw_INHERITED         // nicht klar, wo inherited-Symbol dann hin muss
          then ParseFormularObject( b )      // siehe c:\Users\Public\Documents\Embarcadero\Studio\20.0\Samples\Object Pascal\Multi-Device Samples\EMS\ThingPoint ThingConnect IoT Demo\Client\DesktopClient\ClientProject.dpr
          else} ParseFormularObject( MyForm )
        end
      else begin
        pId := TListen.InsertIdAc( Next.Id, b, id_Var, ac_Read );
        AcStart := AcSequenz.Pegel;
        AcSequenz.Add( pId^.LastAc );
        pId := ParseIdentifier( id_Var, true, pId );
        AcSequenz.BuildAcChain( AcPegelObjekt );               // !
        AcSequenz.ChangeAcEndToWrite( AcStart, ac_Write );
        { Sonderfall BitMap wird wie Kommentar abgelegt: }
          while PeekChar = ' ' do PeekCharInc;
          BitMap := PeekChar = '{';
        Next.Test( kw_Gleich );
        if not BitMap then
          case Next.Peek of
            kw_Kleiner :   begin
                           Next.get;
                           while not Next.getIf( kw_Groesser ) do begin
                             Next.Test( kw_Identifier );
                             Next.Id.Str := Next.Id.Str + 's';
                             pId2 := TListen.InsertIdAc( Next.Id, pId , id_Var, ac_Write );
                             Next.Id.Str := dArraySymbol;
                             pId2 := TListen.InsertIdAc( Next.Id, pId2, id_Var, ac_Write );
                             ParseToEnd( pId2 )
                             end;
                           end;
            kw_KlammerAuf: repeat until Next.get = kw_KlammerZu;
            kw_EckigeKlammerAuf: begin
                           Next.get;               // siehe samples
                           if not Next.getIf( kw_EckigeKlammerZu ) then
                             repeat
                               if Next.Test2( kw_Identifier, kw_Literal )
                                 then TListen.InsertIdAc( Next.Id, nil , id_Unbekannt, ac_Read )
                             until Next.Test2( kw_EckigeKlammerZu, kw_Komma )
                           end;

            kw_Ungleich  : Next.get;   // z.B. Panels = <>
//            kw_OBJECT,                             // nach  Bitmap = {048827875}, siehe samples
//            kw_END       : ExprType := nil;        // kommt hoffentlich kein nächster Identifier
            else           ParseExpression( false, ExprType )
            end
        end
  end;

begin
  {$IFDEF TraceDx} TraceDx.Call( uScan, 'ParseFormularObject', MyForm^.Name ); {$ENDIF}
  Next.Test( kw_Identifier );
  AcPegelObjekt := AcSequenz.Pegel;
  if Next.Peek = kw_Doppelpunkt then begin


    pId := TListen.InsertIdAc( Next.Id, MyForm, id_Var, ac_Read );
    AcSequenz.Add( pId^.LastAc );
    Next.get;
    TListen.EnterBlock( pId );
    TListen.SetIdTypeClass( pId );
    Next.Test( kw_Identifier )
    end;

    pId := TListen.InsertIdAc( Next.Id, nil, id_Type, ac_Read );
    if Next.getIf( kw_EckigeKlammerAuf ) then begin
      // c:\Users\Public\Documents\Embarcadero\Studio\20.0\Samples\Object Pascal\Database\FireDAC\Samples\DatS Layer\TableUpdates\TableUpdates.dpr
      ParseExpression( false, ExprType );
      Next.Test( kw_EckigeKlammerZu )
      end;
    if MyForm^.Typ = id_Unit then     // dann ist das der erste Aufruf und MyForm muss mit TForm belegt werden
      MyForm := pId;
    TListen.EnterBlock( MyForm );

  TListen.SetIdTypeClass( pId );
  ParseToEnd( pId );
  AcSequenz.Pegel := AcPegelObjekt;
end;

{$ENDREGION }

{$REGION '-------------- Compiler-Direktive ---------------' }

function SymbolDefined( i: integer ): boolean;
begin
  Result := ( i mod cDefinesBits ) in pAktUnit^.CompDefines[i div cDefinesBits]
end;

procedure InsertCompilerDirektiveReference( Id: tIdPosInfo; Direktive: tCompilerDirektiven );
var a: pAcInfo;
begin
if ( IfDefBool [IfDefZaehler] = 0 ) or
   ( Direktive in [cd_Ifdef, cd_Ifndef, cd_If, cd_IfOpt, cd_Else, cd_Else, cd_ELSEIF, cd_Endif, cd_IFEND,
                   cd_DEFINED, CD_DECLARED, cd_AND, cd_OR, cd_TRUE, cd_FALSE] ) then begin
  TListen.NewAc( a );
  with a^ do begin
    ZugriffTyp := ac_Read;
    Position   := Id.Pos;
    if tFileFlags.LibraryPath in pAktUnit^.fiFlags
      then AcFlags := []
      else AcFlags := [tAcFlags.AcProjectUse];
    IdDeclare  := @ControlsListe[Direktive];
    IdUse      := AktDeclareOwner;
    NextAc     := nil
    end;
  with ControlsListe[Direktive] do begin
    if AcList = nil then begin
      AcList := a;
      inc( ZaehlerId[id_CompilerControl] );
      inc( ZaehlerIds )
      end
    else
      LastAc^.NextAc := a;
    LastAc:= a;
    if not ( tFileFlags.LibraryPath in pAktUnit^.fiFlags ) then
      include( IdFlags2, tIdFlags2.IdProjectUse )
    end
  end
end;

function  ParseDirectives: tCompilerDirektiven;
const cAcRead : array[boolean] of tAcType = ( ac_Unknown, ac_Read  );
      cAcWrite: array[boolean] of tAcType = ( ac_Unknown, ac_Write );
      cUnitName = '*';
type  tGetMode = ( moMain, moFile, moFileString, moString, moDefine, moIF );
{ true, wenn Include gefunden }
var NextControl: tIdPosInfo;
    s          : string;
    opt        : boolean;
    cond       : shortInt;
    i, idx     : integer;

     procedure GetNextControl( Mode: tgetMode );
     type   tSet = set of char;
     const  cMainSet  : tset = ['A'..'Z','a'..'z'             ];
            cDefineSet: tSet = ['A'..'Z','a'..'z','0'..'9','_'];
            cFileSet_ : tset = [cBlank, '}', cTAB, cEOL       ];
     var    TestSet   : tSet;
     begin
       with pAktFile^ do begin
         if Mode = moMain then
           TestSet := cMainSet
         else begin
           while PeekChar in [cBlank, '(', ')'] do PeekInc;            // Zwischen-Blanks
           case Mode of
             moFile  : if PeekChar = cStrStart then
                         Mode := moFileString;
             moDefine: TestSet := cDefineSet;
             moIF    : TestSet := cDefineSet;
             end;
           NextControl.Pos.Datei  := MyIndex;
           NextControl.Pos.Zeile  := li;
           NextControl.Pos.Spalte := ri;
           NextControl.Pos.Laenge := 0;
           NextControl.Str        := '';
           end;
         end;
       case Mode of
       moString: begin
                   NextControl.Pos.Laenge := 2;
                   NextControl.Str := PeekCharInc;
                   repeat NextControl.Str := NextControl.Str + PeekCharInc;
                          inc( NextControl.Pos.Laenge )
                   until  PeekChar = cStrStart;
                   NextControl.Str := NextControl.Str + cStrStart
                 end;
       moFileString: begin
                   PeekCharInc;
                   repeat NextControl.Str := NextControl.Str + PeekCharInc;
                          inc( NextControl.Pos.Laenge )
                   until  PeekChar = cStrStart;
                   inc( NextControl.Pos.Spalte )
                 end;
       moFile  : while not System.SysUtils.CharInSet( PeekChar, cFileSet_ ) do begin
                   NextControl.Str := NextControl.Str + PeekCharInc;
                   inc( NextControl.Pos.Laenge )
                   end;
       else      while System.SysUtils.CharInSet( PeekChar, TestSet ) do begin
                   NextControl.Str := NextControl.Str + PeekCharInc;
                   inc( NextControl.Pos.Laenge )
                   end
       end;
       {$IFDEF TraceDx} TraceDx.Send( uScan, 'GetNextControl', NextControl.Str ) {$ENDIF}
     end;

     function TestDirective: tCompilerDirektiven;
     var h: tHash;
     begin
       h := getHash( NextControl.Str );
       for Result := cd_Align to high( tCompilerDirektiven ) do
         if ( h = ControlsListe[Result].Hash ) and ( NextControl.Str.ToUpper = ControlsListe[Result].Name ) then begin
           {$IFDEF TraceDx} TraceDx.Send( uScan, 'Compiler-Directive', NextControl.Str ); {$ENDIF}
           InsertCompilerDirektiveReference( NextControl, Result );
           exit
           end;
       Result := cd_Unbekannt
     end;

     function MainDirective: tCompilerDirektiven;
     var h  : tHash;
         opt: boolean;

       procedure SetOption( b: boolean );
       begin
         {$IFDEF TraceDx} TraceDx.Send( uScan, 'SetOption ' + ControlsListe[Result].Name, b ); {$ENDIF}
         if ControlsListe[Result].OpPrio and 1 = 1
           then pAktUnit^.IfOptLokal [Result] := b       // lokal
           else           IfOptGlobal[Result] := b       // global
       end;

     begin
       NextControl.Pos.Datei := pAktFile^.MyIndex;
       repeat
         PeekInc; // das "$"-Zeichen überspringen
         NextControl.Pos.Zeile  := pAktFile^.li;
         NextControl.Pos.Spalte := pAktFile^.ri;
         NextControl.Str        := PeekCharInc;
         NextControl.Pos.Laenge := 1;
         if ( PeekChar <= '9' ) or ( NextControl.Str[0].ToUpper = 'Y' ) then begin    // '+'  '-'   '0'..'9'
           if IfDefBool[IfDefZaehler] <> 0 then break;   // dieser Bereich wird gar nicht gelesen
           { abgekürzte (ein Buchstabe) Direktive: }
           if PeekChar = cBlank then begin
             { kein +/- Schalter sondern zB $M <Stack>: }
             Result := cCompilerDirektivenTxt[NextControl.Str[0].ToUpper];
             case Result of
               cd_MinStackSize: InsertCompilerDirektiveReference( NextControl, cd_MaxStackSize );   // hier zusätzlich auch eintragen
               cd_Link        : begin
                                 GetNextControl( moFile );
                                 TListen.TestFileInclude( NextControl, false )
                                end
               end
             end
           else begin
             Result := cCompilerDirektivenOpt[NextControl.Str[0].ToUpper];
             if ( Result = cd_DefinitionInfo ) and ( PeekChar.ToUpper = 'D' ) then
               { Sonderfall $YD: }
               InsertCompilerDirektiveReference( NextControl, cd_ReferenceInfo )   // hier zusätzlich auch eintragen
             else
               { normaler Schalter. Einige Sonderbehandlungen: }
             case Result of
               cd_Align:  begin
                            SetOption( ( PeekChar = '+' ) or ( PeekChar = '8' ) );   {$A1 == $A-    $A8 == $A+ }
                            PeekCharInc
                          end;
               cd_MinEnumSize:  begin
                            SetOption( ( PeekChar = '+' ) or ( PeekChar = '4' ) );   {$Z1 == $Z-    $Z4 == $Z+ }
                            PeekCharInc
                          end;
               cd_DefinitionInfo:
                          InsertCompilerDirektiveReference( NextControl, cd_ReferenceInfo );   // $Y+ $Y- hier zusätzlich auch eintragen
               else       SetOption( PeekCharInc = '+' );
               end
             end;
           {$IFDEF TraceDx} TraceDx.Send( uScan, 'MainDirective', NextControl.Str ); {$ENDIF}
           InsertCompilerDirektiveReference( NextControl, Result );   // kann auch cd_Unbekannt sein, z.B. $E+
           if PeekChar <> ',' then break
           end
         else begin
           GetNextControl( moMain );
           Result := TestDirective;
           if IfDefBool[IfDefZaehler] <> 0 then break;   // dieser Bereich wird nur für ENDIF undso gelesen, hier Abbruch

           if Result = cd_Unbekannt                      // zu verarbeitende Direktiven müssen bekannt sein, na logisch
             then Error( errDirektive, NextControl.Str );

           if 2 and ControlsListe[Result].OpPrio = 2 then begin
             { dies ist ein Schalter, Zustand merken }
             GetNextControl( moDefine );
             case Result of
               cd_ALIGN      : SetOption( NextControl.Str = '8' );
               cd_MinEnumSize: SetOption( NextControl.Str = '4' )
               else            SetOption( NextControl.Str.ToUpper = 'ON' )
               end
             end
           else
             { dies ist kein Schalter aber evtl Zusatz-Aktion notwendig: }
             case Result of
               cd_Link: begin
                          GetNextControl( moFile );
                          TListen.TestFileInclude( NextControl, false )
                        end
               (*cd_Description: begin
                            { den Description-String mit abspeichern: }
                            GetNextControl( moString );
                            TListen.InsertIdAc( NextControl, @MainBlock[mbConstStrings], id_ConstStr, ac_Read )
                            end*)
               end;
           break
           end
         until false
     end;

     function DefineListIndexOf( const s: string ): integer;
     var i: integer;
     begin
       i := pInteger( @s[0] )^;    // Mini-Hash über die ersten beiden Zeichen
       for result := 0 to DefinesHigh do
         if ( i = pInteger( @Defines[result][0] )^ ) and ( Defines[result] = s ) then exit;
       { Symbol nicht enthalten. Jetzt einfügen: }
       inc( DefinesHigh );
       if DefinesHigh mod cDefinesBits = 0 then begin          // wenn 32er-Grenze erreicht: 32 neue Elemente holen. Auch in Files!
         {$IFDEF TraceDx} TraceDx.Send( uScan, 'DefineListIndexOf: Count', DefinesHigh ); {$ENDIF}
         SetLength( Defines, DefinesHigh + cDefinesBits );
         //  auch in Files compDefs um ein Element vergrößern:
         TListen.AddDefinesToFiles
         end;
       Defines[ DefinesHigh ] := s;
       result := DefinesHigh
     end;

     function IfCondition: shortInt;
     var c: char;

       function IfExpression: shortInt;
       var negativ: boolean;
           pId: pIdInfo;
       begin
         Result := 0;
         negativ := false;
         while true do begin
           GetNextControl( moIF );
           if NextControl.Pos.Laenge > 0 then begin
             case TestDirective of
             cd_NOT:
               negativ := true;
             cd_TRUE:
               Result := 0;
             cd_FALSE:
               Result := 1;
             cd_DEFINED: begin
               while PeekCharInc = cBlank do;
               GetNextControl( moDefine );
               if negativ xor ( SymbolDefined( DefineListIndexOf( NextControl.Str.ToUpperInvariant ))  )
                 then Result := 0
                 else Result := 1;
               TListen.InsertIdAc (NextControl, @MainBlock[mbDefines], id_CompilerDefine, cAcRead[IfDefBool [IfDefZaehler-1] = 0] );
               while PeekCharInc = cBlank do
               end;
             cd_DECLARED: begin
               while PeekCharInc = cBlank do;
               GetNextControl( moDefine );
               pId := nil;
               repeat
                 pId := TListen.InsertIdAc (NextControl, pId, id_Unbekannt, ac_Read );
                 if PeekChar = '.' then begin
                   PeekCharInc;
                   GetNextControl( moDefine )
                   end
                 else
                   break
                until false;
               if negativ xor (( ac_Declaration in pId^.AcSet ) or  ( pId^.PrevBlock = @UnitSystem ){weil die kein declaration-Flag haben})
                 then Result := 0
                 else Result := 1;
               while PeekCharInc = cBlank do
               end;
             cd_AND: begin
               negativ := false;
               if ( IfExpression = 0 ) and ( Result = 0 )
                 then Result := 0
                 else Result := 1
               end;
             cd_OR: begin
               negativ := false;
               if ( IfExpression = 0 ) or ( Result = 0 )   // IfExpression auf jeden Fall ausführen
                 then Result := 0
                 else Result := 1
               end
             else
               if NextControl.Str.ToLowerInvariant = 'rtlversion'
                 then TListen.InsertIdAc (NextControl, nil, id_Const, ac_Read )
               else if NextControl.Str.ToLowerInvariant = 'compilerversion'
                 then TListen.InsertIdAc (NextControl, nil, id_Const, ac_Read );
               break
             end;
             {$IFDEF TraceDx} TraceDx.Send( uScan, 'IfExpression', Result ) {$ENDIF}
             end
           else
             break
           end;
         if NextControl.Str <> ''
           then NotImplemented := NotImplemented + sLineBreak + pAktFile^.StrList[pAktFile^.li]
       end;

     begin
       Result := IfExpression
     end;

begin
{$IFDEF TraceDx} TraceDx.Call( uScan, 'ParseDirectives' ); {$ENDIF}
Result := MainDirective;
case Result of
  cd_Unbekannt: ;

  cd_Include:
    if IfDefBool[IfDefZaehler] = 0 then begin
      GetNextControl( moFile );
      LastId := NextControl;
      if LastId.Str[0] = cUnitName
        then LastId.Str := TPath.ChangeExtension( pAktUnit^.FileName, NextControl.Str.Substring( 2 ));
      end
    else
      Result := cd_Unbekannt;
  cd_RESOURCE:
    if IfDefBool[IfDefZaehler] = 0 then begin
      GetNextControl( moFile );
      s := TPath.GetExtension( NextControl.Str ).ToLowerInvariant;
      LastId := NextControl;
      if LastId.Str[0] = cUnitName
        then LastId.Str := TPath.ChangeExtension( pAktUnit^.FileName, NextControl.Str.Substring( 2 ));
      if FileOptions.ParseFormular and (( s = '.dfm' ) or ( s = '.fmx' ) or( s = '.lfm' )) then
        TListen.LeaveFileMinimal
      else begin
        Result := cd_Unbekannt;
        TListen.TestFileInclude( LastId, false )
        end
      end
    else
      Result := cd_Unbekannt;

  cd_DEFINE, cd_UNDEF:
    if IfDefBool [IfDefZaehler] = 0 then begin
      GetNextControl( moDefine );
      idx := DefineListIndexOf( NextControl.Str.ToUpperInvariant );
      if Result = cd_Define
        then include( pAktUnit^.CompDefines[idx div cDefinesBits], idx mod cDefinesBits )
        else exclude( pAktUnit^.CompDefines[idx div cDefinesBits], idx mod cDefinesBits );
      TListen.InsertIdAc( NextControl, @MainBlock[mbDefines], id_CompilerDefine, ac_Write )
      end;

 cd_IFDEF: begin
   GetNextControl( moDefine );
   inc( IfDefZaehler );
   IfDefBool[ IfDefZaehler ] := 1;
   with IfDefEndIf[ IfDefZaehler ] do begin Line := pAktUnit^.li; Define := NextControl.Str; IfNDef := false end;
   if IfDefBool[ IfDefZaehler-1 ] = 0 then begin     // nur gültig, wenn Ebene-1 true
     idx := DefineListIndexOf( NextControl.Str.ToUpperInvariant );
     if SymbolDefined( idx ) then
       IfDefBool[ IfDefZaehler ] := 0
     end;
   TListen.InsertIdAc( NextControl, @MainBlock[mbDefines], id_CompilerDefine, cAcRead[IfDefBool [IfDefZaehler-1] = 0] );
   (*if IfDefBool [IfDefZaehler] <> 0 then
     SkipIfBlock *)  // tbd
   end;
 cd_IFNDEF: begin
   GetNextControl( moDefine );
   inc (IfDefZaehler);
   IfDefBool[ IfDefZaehler ] := 1;
   with IfDefEndIf[ IfDefZaehler ] do begin Line := pAktUnit^.li; Define := NextControl.Str; IfNDef := true end;
   if IfDefBool [IfDefZaehler-1] = 0 then begin     // nur gültig, wenn Ebene-1 true
     idx := DefineListIndexOf( NextControl.Str.ToUpperInvariant );
     if not SymbolDefined( idx ) then
       IfDefBool [IfDefZaehler] := 0
     end;
   TListen.InsertIdAc (NextControl, @MainBlock[mbDefines], id_CompilerDefine, cAcRead[IfDefBool [IfDefZaehler-1] = 0] )
   end;
 cd_ELSE:
   if IfDefBool [IfDefZaehler-1] = 0 then
     dec( IfDefBool [IfDefZaehler] );

 cd_IF: begin
   inc (IfDefZaehler);
   IF_manuell := false;
   cond := IfCondition;
   if IfDefBool [IfDefZaehler-1] <> 0 then
     IfDefBool [IfDefZaehler] := -1
   else
     if IF_manuell
       then dec( IfDefBool [IfDefZaehler] )
       else IfDefBool [IfDefZaehler] := cond
   end;

 cd_IFEND:
   dec (IfDefZaehler);

 cd_ENDIF: begin
   if RefactorEndIf and not ( tFileFlags.LibraryPath in pAktFile^.fiFlags ) then
     if ( pAktFile^.li - IfDefEndIf [ IfDefZaehler ].Line > 0 ) and
        (( pAktFile^.StrList[pAktFile^.li, pAktFile^.ri] = '}' ) or ( pAktFile^.StrList[pAktFile^.li, pAktFile^.ri+1] = '}' )) then begin
       if IfDefEndIf [ IfDefZaehler ].IfNDef
         then s := ' -' + IfDefEndIf [ IfDefZaehler ].Define
         else s := ' '  + IfDefEndIf [ IfDefZaehler ].Define;
       pAktFile^.StrList[pAktFile^.li].Insert( pAktFile^.ri, s );
       inc( pAktFile^.ri,    length( s ));
       inc( pAktFile^.riMax, length( s ));
       pAktFile^.pi := @pAktFile^.StrList[pAktFile^.li, pAktFile^.ri];
       include( pAktFile^.fiFlags, tFileFlags.Changed );
       if LastExtraYes <> pAktFile^.FileName then begin
         LastExtraYes := pAktFile^.FileName;
         TFile.AppendAllText( cExtraLogYes, LastExtraYes + sLineBreak, TEncoding.ANSI )
         end;
       TFile.AppendAllText( cExtraLogYes, Format( '%5u: ', [pAktFile^.li] ) + pAktFile^.StrList[pAktFile^.li] + sLineBreak, TEncoding.ANSI )    // geht ins Current = Projekt-Dir
       end
     else begin
       if LastExtraNo <> pAktFile^.FileName then begin
         LastExtraNo := pAktFile^.FileName;
         TFile.AppendAllText( cExtraLogNo, LastExtraNo + sLineBreak, TEncoding.ANSI )
         end;
       TFile.AppendAllText( cExtraLogNo,  Format( '%5u: ', [pAktFile^.li] ) + pAktFile^.StrList[pAktFile^.li] + sLineBreak, TEncoding.ANSI );
       end;
   dec (IfDefZaehler);
   end;

 cd_IFOPT:
   with pAktFile^ do begin
     while PeekChar = cBlank do PeekInc;            // Zwischen-Blanks
     NextControl.Pos.Datei  := MyIndex;
     NextControl.Pos.Zeile  := li;
     NextControl.Pos.Spalte := ri;
     NextControl.Pos.Laenge := 1;
     NextControl.Str := PeekCharInc;
     Result := cCompilerDirektivenOpt[NextControl.Str[0].ToUpper];   // abgekürzte (ein Buchstabe) Direktive
     InsertCompilerDirektiveReference( NextControl, Result );
     inc (IfDefZaehler);
     if ControlsListe[Result].OpPrio and 1 = 1
       then opt := pAktUnit^.IfOptLokal [Result]
       else opt :=           IfOptGlobal[Result];
     if ( IfDefBool [IfDefZaehler-1] = 0 ) and ( opt = ( PeekCharInc = '+' ) )
       then IfDefBool [IfDefZaehler] := 0
       else IfDefBool [IfDefZaehler] := 1
   end;

 cd_ELSEIF: begin
   cond := IfCondition;
   if IfDefBool [IfDefZaehler-1] <> 0 then
     IfDefBool [IfDefZaehler] := -1    // ist bereits -1
   else
     if IF_manuell then
       dec( IfDefBool [IfDefZaehler] )
     else
       if IfDefBool [IfDefZaehler] <= 0
         then IfDefBool [IfDefZaehler] := -1
         else IfDefBool [IfDefZaehler] := cond
   end;
 end
end;

{$ENDREGION }

{$REGION '-------------- NextWord ---------------' }

function  IsValidIdChar( c: char ): boolean;
begin
  Result := c.IsLetterOrDigit or ( c = '_' )
end;

procedure SkipBlanks;
var Weiter: boolean;

   function SkipComment (GeschweifteKlammer: boolean): boolean;
   { Return true, wenn die folgenden Anweisungen wegen bedingter Compilierung
     übersprungen werden sollen }
   const SuchKommentar: array[boolean] of char = ('*','}');
         KlammerAufTyp: array[boolean] of tKeyWord
                      = (kw_KlammerAufStern, kw_GeschweifteKlammerAuf);
         KlammerZuTyp : array[boolean] of tKeyWord
                      = (kw_SternklammerZu, kw_GeschweifteKlammerZu);
   var LastDirective: tCompilerDirektiven;
       Weiter: boolean;
       CommentId: tIdPosInfo;
   begin
//   {$IFDEF TRACE} TraceOutputS (cDebugSourceLow, 'SkipComment'); {$ENDIF}
   CommentId.Pos.Datei  := pAktFile^.MyIndex;
   CommentId.Pos.Zeile  := pAktFile^.li;
   CommentId.Pos.Laenge := 2-ord( GeschweifteKlammer );
   CommentId.Pos.Spalte := pAktFile^.ri-CommentId.Pos.Laenge;
   InsertKeyWordReference( CommentId.Pos, KlammerAufTyp [GeschweifteKlammer] );
   if PeekChar = cCompilerDirektive
   then LastDirective := ParseDirectives
   else LastDirective := cd_Unbekannt;
   SkipComment := IfDefBool[IfDefZaehler] <> 0;
   with pAktFile^ do begin
     Weiter := true;
     repeat
        case PeekChar of
        '*' : begin
                if not GeschweifteKlammer and LookAhead( ')' )
                  then begin Weiter := false; PeekInc end;
                PeekInc
              end;
        '}' : begin
                if GeschweifteKlammer
                  then Weiter := false;
                PeekInc
              end;
        cEOL: JumpNextLine;
        cEOF: Error( errUnexpectedEOF, 'Comment' + pAktFile^.FileName )
        else  PeekInc
        end;
     until not Weiter;
     CommentId.Pos.Datei  := pAktFile^.MyIndex;
     CommentId.Pos.Zeile  := pAktFile^.li;
     CommentId.Pos.Spalte := pAktFile^.ri-CommentId.Pos.Laenge;
     InsertKeyWordReference( CommentId.Pos, KlammerZuTyp [GeschweifteKlammer] )
     end;
   if  ( LastDirective = cd_Include ) or
      (( LastDirective = cd_Resource ) and FileOptions.ParseFormular ) then begin

     if ( LastDirective = cd_Include ) and ( TPath.GetExtension( LastId.Str ) = '' ) then
       LastId.Str := TPath.ChangeExtension( LastId.Str, cExtensionPas );
//     if TPath.IsRelativePath( LastId.Str ) then
//       LastId.Str := TPath.GetDirectoryName( pAktUnit^.FileName ) + TPath.DirectorySeparatorChar + LastId.Str;
     TListen.TestFileInclude( LastId, true );

     if LastDirective = cd_Resource then begin
       pAktFile^.StrList[pAktFile^.liMax] := pAktFile^.StrList[pAktFile^.liMax] + '.';   // Reserve für overNextKw
       include( pAktFile^.fiFlags, tFileFlags.isResourceFile );
       Next.get;
       if Next.getIf( kw_OBJECT ) or Next.getIf( kw_INHERITED ) then begin    // sonst binäres Format
         include( pAktFile^.fiFlags, tFileFlags.isFormular );
         ParseFormularObject( pAktUnit^.MyUnit );
         TListen.EnterBlock( pAktUnit^.MyUnit ); // der AktDeclareOwner ist im Formular sicher kaputt gegangen
         end;
       TListen.LeaveFile;                      //
       include( pAktFile^.fiFlags, tFileFlags.hasFormular );
       OverNextKw := pAktFile^.NextKeyword;    //  weil dies wird im LeaveFile
       NextId     := pAktFile^.NextIdInfo      //  für include NICHT gemacht
       end;
     end
   end;

   procedure SearchNextComment;
   var Gefunden: boolean;
   begin
  {$IFDEF TraceDx} TraceDx.Call( uScan, 'SearchNextComment' ); {$ENDIF}
   Gefunden := false;
   repeat
      case PeekChar of
      '/' : if LookAhead( '/' ) then
              pAktFile^.ri := pAktFile^.riMax + 1       // falls "//"-Kommentar im IFDEF-Block, der Apostroph enthält
            else PeekInc;
      '''': begin repeat PeekInc until PeekChar = ''''; PeekInc end;
      '"' : {if ParserState.AssemblerCode        // Abfrage sinnlos denn "asm" wird im ifdef-Abschnitt nicht erkannt
              then} begin repeat PeekInc until PeekChar = '"'; PeekInc end;   // wg mov al,"'"
//              else inc (pAktFile^.ri);
      '{' : Gefunden := true;
      '(' : if LookAhead( '*' ) then Gefunden := true else PeekInc;
      cEOL: JumpNextLine;
      cEOF: Error( errUnexpectedEOF, '$UNDEF-Section' + pAktFile^.FileName )
      else PeekInc
      end
   until Gefunden
   end;


begin
//  {$IFDEF TraceDx} TraceDx.Call( uScan, 'SkipBlanks' ); {$ENDIF}
Weiter := true;
while Weiter do with pAktFile^ do
  case PeekChar of
    cEOF  : TListen.LeaveFile;
    cEOL  : begin
              JumpNextLine;
              if li > liMax then begin
                dec( li ); ri := StrList[li].Length; riMax := ri; if ri = 0 then ri := 1; pi := nil end
             end;
     cBlank: PeekInc;
     '{'   : begin PeekInc; if SkipComment(true) then SearchNextComment end;
     '('   : if LookAhead( '*' ) then begin PeekInc; PeekInc; if SkipComment(false) then SearchNextComment end else Weiter := false;
     '/'   : if LookAhead( '/' ) then ri := riMax + 1 else Weiter := false;
     else    Weiter := false
     end;
end;

function  NextWord: tKeyWord;
var p: integer;
    InString, IsReal, Ende: boolean;
    pc0: pChar;

  procedure SetLiteralIntType;
  var i: integer;
      j: int64;
  begin
    // http://docwiki.embarcadero.com/RADStudio/Rio/en/Simple_Types_(Delphi)
    LastLiteral^.TypeGroup := coInt;
    if TryStrToInt( LastLiteral^.Name, i ) then
      if      ( i >= low( shortint )) and ( i <= high( shortint )) then TListen.CopyTypeInfos( pSysId[syShortInt], LastLiteral )
      else if ( i >= low( smallint )) and ( i <= high( smallint )) then TListen.CopyTypeInfos( pSysId[sySmallInt], LastLiteral )
      else if ( i >= low( integer  )) and ( i <= high( integer  )) then TListen.CopyTypeInfos( pSysId[syInteger ], LastLiteral )
      else // Error( er
    else
      if TryStrToInt64( LastLiteral^.Name, j ) then
           if j = integer.MinValue                                 then TListen.CopyTypeInfos( pSysId[syInteger ], LastLiteral )
      else if ( j >= low( Cardinal )) and ( j <= high( Cardinal )) then TListen.CopyTypeInfos( pSysId[syCardinal], LastLiteral )
                                                                   else TListen.CopyTypeInfos( pSysId[syInt64   ], LastLiteral )
      else { MinValue ist -(MaxValue+1) = -9223372036854775808 }
           { try schlägt fehl weil Zahl hier imemr positiv }            TListen.CopyTypeInfos( pSysId[syInt64   ], LastLiteral )
  end;

  procedure pChar2String;
  var c: char;
  begin
    c := pAktFile^.pi^;
    pAktFile^.pi^ := char( 0 );
    NextId.Str := string( pc0 );
    pAktFile^.pi^ := c;
    NextId.Pos.Laenge := NextId.Str.Length
  end;

  procedure NextString;
  const cMultiLineDelim = '''''''';
  var MultiLine, MultiLinePart, Special: boolean;
      pi: integer;

    function SetLiteralStringChar: boolean;
    var dummy: integer;
    begin
      case pc0^ of
        '''': Result := (  NextId.Pos.Laenge = 3 ) or
                        (( NextId.Pos.Laenge = 4 ) and ( (pc0+1)^ = '''' ));
        '^' : Result := NextId.Pos.Laenge = 2;
        '#' : Result := TryStrToInt( NextId.Str.Substring(1), dummy )
      end
    end;

  begin
    OverNextKw := kw_Literal;
    Special    := false;
    MultiLine  := false;
    repeat
      case PeekChar of
        '''': begin
                PeekInc;
                MultiLinePart := false;

                if not InString and ( PeekChar = '''' ) and LookAhead( '''' ) then

                  if  ( pAktFile^.ri+1 = pAktFile^.riMax ) then begin

                    // MultiLine beginnt mit '''LF
                    MultiLinePart := true;

                    if not MultiLine then begin
                      MultiLine := true;
                      NextId.Str := pAktFile^.StrList[pAktFile^.li].Substring( NextId.Pos.Spalte );
                      NextId.Pos.Laenge := Length( NextId.Str )
                      end;

                    repeat JumpNextLine;
                           pi := pAktFile^.StrList[pAktFile^.li].IndexOf( cMultiLineDelim );
                    // MultiLine endet mit <Blanks>'''
                    until  ( pi <> -1 ) and pAktFile^.StrList[pAktFile^.li].TrimLeft.StartsWith( cMultiLineDelim );
                    pAktFile^.ri := pi + length( cMultiLineDelim );
                    inc( pAktFile^.pi, pAktFile^.ri );
                    end;

                if MultiLinePart
                  then MultiLinePart := false
                  else if Instring
                         then if PeekChar = ''''
                                then begin PeekInc; Special := true end
                                else InString := false
                         else InString := true;
                end;
        '^' : if InString
                then PeekInc
                else begin PeekInc; PeekInc; Special := true end;    // z.B.   ^G  für  #7
        '#' : if InString then
                PeekInc
              else begin
                Special := true;
                while ansichar( UpCase (PeekChar)) in ['#','$','0'..'9','A'..'F'] do PeekInc;
                end
        else  if InString
                then PeekInc
                else Ende := true
        end
    until Ende;

    if MultiLine then begin
      for var i := NextId.Pos.Zeile + 1 to pAktFile^.li - 1 do NextId.Str := NextId.Str + pAktFile^.StrList[i].Substring( pi ) + '#13';
      NextId.Str := NextId.Str.Substring( 0, length( NextId.Str ) - 3 ) + ''''''''
      end
    else
      pChar2String;

    if not MultiLine and SetLiteralStringChar then begin
      LastLiteral := TListen.InsertIdAc( NextId, @MainBlock[mbConstChars], id_ConstChar, ac_Read );
      TListen.CopyTypeInfos( pSysId[syChar], LastLiteral )
      end
    else begin
      LastLiteral := TListen.InsertIdAc( NextId, @MainBlock[mbConstStrings], id_ConstStr, ac_Read );
      TListen.CopyTypeInfos( pSysId[syString], LastLiteral )
      end;
    if Special then
      include( LastLiteral^.IdFlags2, tIdFlags2.LiteralSpecial )
    end;

  procedure NextIdentifier;
  begin
    OverNextKw := kw_Identifier;
    while pos( PeekChar, cBlank + cEOL + cOperators1 + '$%' + cEOF ) = 0 do PeekInc;
    pChar2String
  end;

  procedure NextIntReal;
  begin
    OverNextKw := kw_Literal;
    IsReal     := false;

    while true do
      case PeekChar of
        '_',      // ab Delphi 11
        '0'..'9': PeekInc;
        'd'     : if tFileFlags.isFormular in pAktFile^.fiFlags
                    then PeekInc    // integer wird mit "d" abgeschlossen, siehe Samples\DataMod.dfm
                    else break;
        'e', 'E': begin PeekInc; PeekInc { das ist das "+","-" oder <Digit> nach dem "E"}; IsReal := true end;
        '.'     : if not IsReal and LookAheadCh.IsDigit
                    then begin PeekInc; PeekInc { das ist das <Digit> nach dem "."}; IsReal := true end
                    else break
        else      break
        end;
    pChar2String;
    if IsReal then begin
      LastLiteral := TListen.InsertIdAc (NextId, @MainBlock[mbConstReal], id_ConstReal, ac_Read );
      TListen.CopyTypeInfos( pSysId[syExtended], LastLiteral )
      end
    else begin
      LastLiteral := TListen.InsertIdAc (NextId, @MainBlock[mbConstInt ], id_ConstInt, ac_Read );
      SetLiteralIntType
      end
      // Typisierung:     http://docwiki.embarcadero.com/RADStudio/Rio/en/Declared_Constants
  end;

  procedure IdToKeyword;
  var h: tHash;
      c: char;
      k, kMax: tKeyWord;
  begin
    c    := char( byte( pc0^ ) or 32 );    // erstes Zeichen ist immer Buchstabe, Or 32 statt ToLower reicht
    k    := cKeyWordLenStart[      c  ];
    kMax := cKeyWordLenStart[succ( c )];
    h    := getHash( NextId.Str );
    while ( k < kMax ) and (( KeyWordListe[k].Hash <> h ) or ( KeyWordListe[k].Name <> NextId.Str.ToLower )) do inc( k );
    if k < kMax then begin
      OverNextKw := k;
      InsertKeyWordReference( NextId.Pos, k )
      end;
  end;

begin
  SkipBlanks;    { Blanks überlesen }
  { die beiden sind beim letzten Mal schon gelesen worden: }
  Result := OverNextKw;
  LastId := NextId;
  { und jetzt noch ein Symbol weiterlesen auf Vorrat: }
  NextId.Pos.Datei  := pAktFile^.MyIndex;
  NextId.Pos.Zeile  := pAktFile^.li;
  NextId.Pos.Spalte := pAktFile^.ri;
  NextId.Str := '';
  pc0        := pAktFile^.pi;
  Ende       := false;
  InString   := false;
  case PeekChar.ToUpper of
    'A'..'Z': begin
      NextIdentifier;      { Identifier }
      IdToKeyword          { oder Schlüsselwort }
      end;
    '_':
      NextIdentifier;      { Sicher Identifier }
    '&': begin             { folgendes Schlüsselwort wird als Identifier betrachtet }
      NextId.Pos.Laenge := 1;
      PeekInc;
      InsertKeyWordReference( NextId.Pos, kw_Ampersand );
      { direkt dahinter beginnt Id oder Zahl: }
      inc( NextId.Pos.Spalte );
      inc( pc0 );
      if PeekChar.IsDigit
        then NextIntReal
        else NextIdentifier      { Schlüsselwort oder Identifier }
      end;

    '0'..'9': { Integer/Real Zahl }
      NextIntReal;
    '$':
      begin     { Hex-Zahl }
        OverNextKw := kw_Literal;
        PeekInc;
        while ansichar( PeekChar ) in ['0'..'9', 'A'..'F', 'a'..'f', '_'] do PeekInc;
        pChar2String;
        LastLiteral := TListen.InsertIdAc( NextId, @MainBlock[mbConstHex], id_ConstHex, ac_Read );
        SetLiteralIntType
      end;
    '%':
      begin     { Bin-Zahl }
        OverNextKw := kw_Literal;
        PeekInc;
        while ansichar( PeekChar ) in ['0', '1', '_'] do PeekInc;
        pChar2String;
        LastLiteral := TListen.InsertIdAc( NextId, @MainBlock[mbConstBin], id_ConstBin, ac_Read );
        SetLiteralIntType
      end;

    '^' :    { Pointer oder char }
      if (( result = kw_Identifier  )                                   or  // z.B. Deklaration type t= ^tRec;
          ( result = kw_NIL         )                                   or  // siehe ParseIdentifier
          ( result = kw_Pointer     )                                   or  //
          ( result = kw_Doppelpunkt )                                   or  // z.B. Deklaration var pv: ^tRec;
          ( result = kw_OF          ) and ( ParserState.Statement = 0 ) or  // z.B. Deklaration var array of ^t   ABER NICHT: case ch of ^G
          ( result = kw_KlammerZu   )                                   or  // z.B. Statement   tp(p)^.r1 :=
          ( result = kw_EckigeKlammerZu )                               or  // z.B. Statement   tp([0]^.r1 :=
          ( result = kw_Gleich      ) and ParserState.DeclareType )     then begin  // z.B. Statement   p^ :=
        OverNextKw := kw_Pointer;
        NextId.Str := PeekCharInc;
        NextId.Pos.Laenge := 1;
        InsertKeyWordReference( NextId.Pos, OverNextKw )
        end
      else
        NextString;
    '''', '#':    { char oder string }
        NextString;
    '"':
      if ParserState.AssemblerCode then begin
        PeekInc;
        PeekInc;
        PeekInc;
        pChar2String;
        LastLiteral := TListen.InsertIdAc( NextId, @MainBlock[mbConstStrings], id_ConstStr, ac_Read );
        TListen.CopyTypeInfos( pSysId[syChar], LastLiteral )
        end
      else begin
        NextId.Str := PeekCharInc;   // führt zwar zu Syntax-Error aber erstmal registrieren
        NextId.Pos.Laenge := 1
        end

    else
      p := cOperators1.IndexOf( PeekCharInc );
      if p = -1 then
        NextIdentifier // Identifier mit Unicode am Anfang
      else begin
        OverNextKw := tKeyWord( p + ord( kw_FirstOp1 ));
        NextId.Pos.Laenge := 1;
        case OverNextKw of
          kw_Doppelpunkt:
               if PeekChar = '=' then begin
                 PeekInc; OverNextKw := kw_DoppelpunktGleich; NextId.Pos.Laenge := 2 end;
          kw_Punkt:
               if PeekChar = '.'
                 then begin PeekInc; OverNextKw := kw_PunktPunkt; NextId.Pos.Laenge := 2 end
                 else if PeekChar = ')'
                        then begin PeekInc; OverNextKw := kw_EckigeKlammerZu; NextId.Pos.Laenge := 2 end;
          kw_KlammerAuf:
               if PeekChar = '.'
                 then begin PeekInc; OverNextKw := kw_EckigeKlammerAuf; NextId.Pos.Laenge := 2 end;
          kw_Kleiner:
               if PeekChar = '='
                 then begin PeekInc; OverNextKw := kw_KleinerGleich; NextId.Pos.Laenge := 2 end
                 else if PeekChar = '>'
                        then begin PeekInc; OverNextKw := kw_UnGleich; NextId.Pos.Laenge := 2 end;
          kw_Groesser:
               if PeekChar = '='
                 then begin PeekInc; OverNextKw := kw_GroesserGleich; NextId.Pos.Laenge := 2 end;
          end;
        InsertKeyWordReference( NextId.Pos, OverNextKw )
        end
    end;
  {$IFDEF TraceDx}
  if Result <= kw_Identifier
    then TraceDx.Send( uScan, 'Next', LastId.Str, cColorSource )
    else TraceDx.Send( uScan, 'Next', KeywordListe[Result].Name, cColorSource )
  {$ENDIF}
end;

{$ENDREGION }

{$REGION '-------------- Pascal Direktive ---------------' }

procedure InsertPascalDirektiveReference( d: tPascalDirektive );
var a: pAcInfo;
begin
  // LastId.Pos.Laenge := Length (LastId.Str);
  TListen.NewAc( a );
  with a^ do begin
    ZugriffTyp := ac_Read;
    Position   := LastId.Pos;
    if tFileFlags.LibraryPath in pAktUnit^.fiFlags
      then AcFlags := []
      else AcFlags := [tAcFlags.AcProjectUse];
    IdDeclare  := @PascalDirektiveListe[d];
    IdUse      := AktDeclareOwner;
    NextAc     := nil
    end;
  with PascalDirektiveListe[d] do begin
    if AcList = nil then begin
      AcList:= a;
      inc( ZaehlerId[id_PascalDirective] );
      inc( ZaehlerIds )
      end
    else
      LastAc^.NextAc := a;
    LastAc:= a;
    if not ( tFileFlags.LibraryPath in pAktUnit^.fiFlags ) then
      include( IdFlags2, tIdFlags2.IdProjectUse )
    end
end;

function  NextPascalDirective1NoRead( d: tPascalDirektive ): boolean;
begin
  Result := ( Next.Peek = kw_Identifier ) and ( getHash( NextId.Str ) = PascalDirektiveListe[d].Hash ) and ( NextId.Str.ToLower = PascalDirektiveListe[d].Name );
end;

function  NextPascalDirective1( d: tPascalDirektive ): boolean;
var p: integer;
begin
  Result := ( Next.Peek = kw_Identifier ) and ( getHash( NextId.Str ) = PascalDirektiveListe[d].Hash ) and ( NextId.Str.ToLower = PascalDirektiveListe[d].Name );
  if Result then begin
    {$IFDEF TraceDx} TraceDx.Send( uScan, 'NextPascalDirektive1', NextId.Str, cColorSource ); {$ENDIF}
    Next.get;
    InsertPascalDirektiveReference( d )
    end
end;

function NextPascalDirective( Erlaubt: tPascalDirektiveSets ): tPascalDirektive;
var p: integer;
    h: tHash;
begin
  if Next.Peek = kw_Identifier then begin
    h := getHash( NextId.Str );
    for Result := low( tPascalDirektive ) to high( tPascalDirektive ) do
      if ( Result in cPascalDirektiveSets[Erlaubt] ) and ( h = PascalDirektiveListe[Result].Hash ) and ( NextId.Str.ToLower = PascalDirektiveListe[Result].Name ) then begin
        {$IFDEF TraceDx} TraceDx.Send( uScan, 'NextPascalDirektive', NextId.Str, cColorSource ); {$ENDIF}
        Next.get;
        InsertPascalDirektiveReference( Result );
        exit
        end;
    Result := pd_NIL
    end
  else
    Result := pd_NIL
end;

{$ENDREGION }

{$REGION '-------------- Compiler Attribut---------------' }

function NextIsCompilerAttribute: boolean;
var sn,sa: string;
begin
  sn := NextId.Str.ToLowerInvariant;
  for sa in cCompAttr do
    if sa = sn then begin
      Next.Test( kw_Identifier );
      TListen.InsertIdAc( Next.Id, @MainBlock[mbAttributes], id_CompilerAttribute, ac_Read );    // [ref] const   oder    const [ref] - Parameter
      exit( true )
      end;
  result := false
end;

{$ENDREGION }

{$REGION '-------------- TNext ---------------' }

procedure TNext.init;
begin
  OverNextKw := low( tKeyWord );
  ReUse := false
end;

function  TNext.get: tKeyWord;
begin
  if ReUse then
    ReUse := false
  else begin
    Token := NextWord;
    Id    := LastId;
//    Hash  :=
    end;
  get := Token
end;

function  TNext.Peek: tKeyWord;
begin
  Peek := OverNextKw
end;

function  TNext.Peek2: char;
begin
  SkipBlanks;
  Peek2 := PeekChar
end;

function  TNext.getIf( k: tKeyWord ): boolean;
begin
  result := OverNextKw = k;
  if result then get
end;

procedure TNext.Test ( k: tKeyWord ); assembler;
asm
  jmp Test1
end;

procedure TNext.Test1( k: tKeyWord );
begin
  if get <> k then
    Error( errSyntaxError, KeyWordListe[k].Name, Id.Str )
end;

function  TNext.Test2( kTrue, kFalse: tKeyWord ): boolean;
begin
  Test2 := true;
  if get <> kTrue then
    if Token = kFalse
      then Test2 := false
      else Error( errSyntaxError, KeyWordListe[kTrue].Name + ' / ' + KeyWordListe[kFalse].Name, Id.Str )
end;

function  TNext.Test3( k0,k1,k2: tKeyWord ): tKeyWord;
begin
  if ( get <> k0 ) and ( Token <> k1 ) and ( Token <> k2 ) then
    Error( errSyntaxError, KeyWordListe[k0].Name + ' / ' + KeyWordListe[k1].Name + ' / ' + KeyWordListe[k2].Name, Id.Str );
  Test3 := Token
end;

function TNext.TestForGeneric( p: tFilePos ): boolean;
{ Result = true wenn generic, sonst Expression }
var s: string;
    i: integer;
    BeforeId: boolean;     // Zustand: true = before     false = behind
begin
  s := DateiListe[p.Datei].StrList[p.Zeile] + ';;;';
  i := s.IndexOf( '<', p.Spalte + p.Laenge ) + 1;
  {$IFDEF TraceDx} TraceDx.Send( uScan, 'TestForGeneric', s.Substring( i-1) ); {$ENDIF}
  BeforeId := true;
  repeat
    case s[i] of
      ' ': inc( i );    // Blanks überlesen, Zustand beibehalten
      '<',
      '.',
      ',': if BeforeId
             then exit( false )
             else begin inc( i ); BeforeId := true end;
      '>': if BeforeId
             then exit( false )
             else exit( true  );
      '_': ;   // kann nur als Id-Teil vorkommen
      '{': begin
             if s[i+1] = '$' then
               Error( errNotImplemented );
             repeat inc( i )
             until  s[i] = '}';
             inc( i )
           end;
      '(': if s[i+1] = '*' then begin
             if s[i+2] = '$'
               then Error( errNotImplemented )
               else inc( i );
             repeat inc( i )
             until ( s[i] = '*' ) and ( s[i+1] = ')' );
             inc( i, 2 )
             end
           else
             exit( false )
      else if char(s[i]).IsLetterOrDigit then
             if BeforeId then begin
               repeat inc( i );
                until not IsValidIdChar( s[i] );
               BeforeId := false
               end
             else
               exit( false )
           else
             exit( false )
    end
  until false
end;

{$ENDREGION }

{$REGION '-------------- Init / PreParse ---------------' }

(* InitReservedWords *)
procedure InitReservedWords;
var k: tKeyWord;
    d: tPascalDirektive;
    c: tCompilerDirektiven;
begin
  for k := kw_FirstKeyWordStr to kw_LastKeyWordStr do
    KeyWordListe[k].Hash := GetHash( KeyWordListe[k].Name );
  KeyWordListe[kw_CASE_variant].Hash := cNoHash;
  KeyWordListe[kw_ELSE_case   ].Hash := cNoHash;
  KeyWordListe[kw_IN_for      ].Hash := cNoHash;
  kw_IN_Hash                         := KeyWordListe[kw_IN].Hash;

  for d := succ( low( tPascalDirektive )) to high( tPascalDirektive ) do
    PascalDirektiveListe[d].Hash := GetHash( PascaldirektiveListe[d].Name );

  for c := succ( low( tCompilerDirektiven )) to high( tCompilerDirektiven ) do
    ControlsListe[c].Hash := GetHash( ControlsListe[c].Name )
end;

(* PreParseReservedWords *)
procedure PreParseReservedWords;
var k: tKeyWord;
    d: tPascalDirektive;
    c: tCompilerDirektiven;
begin
  {$IFDEF TraceDx} TraceDx.Call( uScan, 'PreParseKeyWordList' ); {$ENDIF}
  for k := succ( kw_Identifier ) to high( tKeyWord ) do
     with KeyWordListe[k] do begin
        AcList   := nil;
        LastAc   := nil;
        IdFlags2 := []
        end;

  for d := succ( pd_NIL ) to high( tPascalDirektive ) do
     with PascalDirektiveListe[d] do begin
        AcList   := nil;
        LastAc   := nil;
        IdFlags2 := []
        end;

  IfOptGlobal := cIfOptGlobal;
  for c := low( tCompilerDirektiven ) to high( tCompilerDirektiven ) do
     with ControlsListe[c] do begin
        AcList   := nil;
        LastAc   := nil;
        IdFlags2 := []
        end;
end;

(* TScanner.PreParse *)
class procedure TScanner.PreParse;
begin
  {$IFDEF TraceDx} TraceDx.Call( uScan, 'PreParse' ); {$ENDIF}
  Next.Init;
  with ParserState do begin
    Implementations := false;
    Statement       := 0;
    DeclAnonym      := 0;
    ParseTypeLevel  := 0;
    PropReadWrite   := false;
    AssemblerCode   := false;
    ParseNoVar      := false;
    TypeId_Needed   := false;
    MayBeResult     := false;
    AssignMethod    := false;
    ExportsClause   := false;
    DeclareType     := false;
    end;
  NotImplemented := '';

  IfDefBool[0] := 0;
  IfDefZaehler := 0;

  PreParseReservedWords
end;

(* TScanner.Init *)
class procedure TScanner.Init( sf: tProcString );
begin
  ShowFile := sf;
  InitReservedWords;
end;

{$ENDREGION }

end.

