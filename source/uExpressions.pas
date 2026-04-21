
unit uExpressions;

{$INCLUDE _CompilerOptionsRef.pas}
{$INCLUDE _CompilerOptions.pas}
{ $UNDEF TraceDx}

{ ---------------------------------------------------------------------------------------- }

interface

uses
  uGlobalsParser;

var
  DyaDoppelpunktCnt: word;    // zählt Schachtelungstiefe von Doppelpunkt-Aktivierungen
    // ist nur fürs assert im interface

function  GetTypeNrOfSet( pId: pIdInfo ): tTypeNr;
function  ParseExpression( KeepAcSeq: boolean { true: AcFolge im Aufrufer bereinigen }; out OutExprType: pIdInfo ): pIdInfo;
function  ParseIdentifier( IdType: tIdType; KeepAcSeq: boolean { true: AcFolge im Aufrufer bereinigen }; Start: pIdInfo = nil ): pIdInfo;
function  ParseExpressionList: pIdInfo;
{$IFDEF TestKompatibel}
procedure TestCompatibility( Op1, Op2: pIdInfo );
{$ENDIF}
function  TestFollowType( var pId: pIdInfo ): boolean;
procedure PreParseExpressions;

{ ---------------------------------------------------------------------------------------- }

implementation

uses
  {$IFDEF TraceDx} uTraceDx, {$ENDIF}
  System.SysUtils,
  System.UITypes,
  VCL.Dialogs,
  uGlobals,
  uDeclarations,
  uSystem,
  uScanner,
  uListen;

{$IFDEF TraceDx} type uExpr = class end; {$ENDIF}

{ ---------------------------------------------------------------------------------------- }

(* CheckCompatibility *)
function CheckCompatibility( Op1, Op2: pIdInfo ): boolean;
begin
  // siehe auch unten: CheckOverloadCompatibility()
//  Op1 := TListen.getBaseType( Op1 );
//  Op2 := TListen.getBaseType( Op2 );
  Result := (( Op1 = nil ) or  ( Op2 = nil )                                                    ) or

            (( Op1^.TypeGroup = coUnb ) or ( Op2^.TypeGroup = coUnb )                           ) or
            ( Op1^.TypeGroup = Op2^.TypeGroup )                                                   or

            (( Op1^.TypeGroup in [coInt, coBool, coReal, coStr, coChar, coMethod, coFile, coArrayOf] ) and       // bei diesen...
                                             ( Op1^.TypeGroup = Op2^.TypeGroup )                ) or  // ... reicht immer gleiche Gruppe

            (( [Op1^.TypeGroup] + [Op2^.TypeGroup] = [coInt, coReal] )                          ) or
            (( [Op1^.TypeGroup] + [Op2^.TypeGroup] = [coStr, coChar] )                          ) or
            (( [Op1^.TypeGroup] + [Op2^.TypeGroup] = [coArrayOf, coSet] )                       ) or
            (( [Op1^.TypeGroup] + [Op2^.TypeGroup] = [coPtr, coClass ] )                        ) or  // für Vergleich mit nil

            (( Op1^.TypeGroup in [coSelf, coEnum, coSet] ) and  ( Op1^.TypeNr = Op2^.TypeNr )   ) or
            (( Op1^.TypeGroup = coSet ) and
                                 (( Op1^.TypeNr = cEmptySet ) or ( Op2^.TypeNr = cEmptySet ))   ) or

//im Expr:  (( Op1^.TypeGroup = coEnum ) and  ( Op2^.TypeNr = Op1^.TypeNr + cSetInc)            ) or  // für enum IN Set

            (( Op1^.TypeGroup = coInterf ) and ( Op2^.TypeGroup in [coInterf, coClass ] )       ) or

            (( Op1^.TypeGroup = coPtr ) and
              (( Op1^.MyType = nil ) or ( Op2^.MyType = nil ) or ( Op1^.MyType = Op2^.MyType )) ) or  // ein Ptr untypisiert oder beide gleicher Typ

//im Assign (( [Op1^.TypeGroup] + [Op2^.TypeGroup] = [coMethod, coPtr] )                        ) or  // FuncPtr := func   weil func auf funcTyp weitergeleitet wird, identisch    FuncPtr := @func

            (( Op1^.TypeGroup = coInterf ) and ( Op2^.TypeGroup = coClass )                     ) or  // Class muss Interface auch implementieren!
            false
end;

const
  cMaxPts = 9;

(* CheckCompatibility *)
function CheckOverloadCompatibility( pActual, pFormal: pIdInfo; var pts: tAcSeqIndex ): boolean;

  (* IsParent *)
  function IsParent( pActual: pIdInfo ): boolean;
  { Ist pActual Vorfahre von pFormal? Dann true }
  begin
    repeat pActual := pActual^.MyParent;    // jeder Parent ist auch kompatibel
           if pActual = pFormal then exit( true )
     until pActual = nil;
    Result := false
  end;

begin
  {$IFDEF TraceDx} TraceDx.Send( uExpr, 'CheckOverloadCompatibility', TListen.pIdName( pActual ), TListen.pIdName( pFormal ) ); {$ENDIF}
  Result := true;

  if pFormal = nil                                                              then
    inc( pts, cMaxPts )                                                         else

  if pActual^.TypeNr = pFormal^.TypeNr                                          then     // das passt immer
    inc( pts, cMaxPts )                                                         else

  if ( pActual^.TypeGroup = coUnb ) or ( pFormal^.TypeGroup = coUnb )           then     // kann sein dasses passt
    inc( pts, 0 )                                                               else

  if tIdFlags.IsGenericDummy in pActual^.IdFlags                                then     // Aufruf-Para ist <T>, kann sein dasses passt
    inc( pts, 2 )                                                               else

  if tIdFlags.IsGenericDummy in pFormal^.IdFlags                                then     // Formal-Para ist <T>, das passt immer
    inc( pts, 2 )                                                               else

  if (( pActual^.TypeGroup in [coInt, coBool, coReal, coStr, coChar, coMethod] )and                      // bei diesen...
      ( pActual^.TypeGroup = pFormal^.TypeGroup ))                              then     // ... reicht immer gleiche Gruppe
    inc( pts, 6 )                                                               else

  if (( pActual^.TypeGroup in [coSet, coPtr, {coArray,} coArrayOf, coTArray] ) and                      // bei diesen...
      ( pActual^.TypeGroup = pFormal^.TypeGroup ))                              then
    if ( pActual^.TypeNr = pFormal^.TypeNr )
      then inc( pts, cMaxPts )  // ... reicht gleiche Gruppe UND gleicher BasisTyp
      else inc( pts, 3 )                                                        else

  if (( pActual^.TypeGroup = coClass ) and ( IsParent( pActual )) )             then
    inc( pts, 8 )                                                               else

  if (( pActual^.TypeGroup in [coSelf, coEnum, coSet] ) and
        ({( Op1^.TypeNr = Op2^.TypeNr ) or} ( pActual^.TypeNr = cEmptySet  )))  then
    inc( pts, 0 )                                                               else

  if (( pActual^.TypeGroup = coInt   ) and ( pFormal^.TypeGroup = coReal    )) or  // int kann als real-Parameter genommen werden
     (( pActual^.TypeGroup = coChar  ) and ( pFormal^.TypeGroup = coStr     )) or  // char kann als string-Parameter genommen werden
     (( pActual^.TypeGroup = coSet   ) and ( pFormal^.TypeGroup = coArrayOf )) or  // [1,2,3] sieht aus wie set, ist aber Array-Parameter
     (( pActual^.TypeGroup = coPtr   ) and ( pFormal^.TypeGroup = coClass   ))   then  // nil für class-Type
    inc( pts,  3 )                                                               else

  Result := false;
  {$IFDEF TraceDx} if Result then TraceDx.Send( uExpr, 'Compatibility-Points', pts ) {$ENDIF}
end;

{$IFDEF TestKompatibel}
(* TestCompatibility *)
procedure TestCompatibility( Op1, Op2: pIdInfo );
var s: string;
begin
  if not CheckCompatibility( Op1, Op2 ) then begin
    {$IFDEF TraceDx} TraceDx.Send( uExpr, 'CheckCompatibility-Error', Op1^.Name, Op2^.Name ); {$ENDIF}
    s := pAktFile^.FileName.ToLower + '/' + pAktFile^.li.ToString + '":  ' + pAktFile^.StrList[pAktFile^.li].TrimLeft;
    CompErrorList.Add( TListen.getBlockNameLong( Op1, '.' ) + ' <> ' + TListen.getBlockNameLong( Op2, '.' ) + sLineBreak + '  in file "' + s );
//    asm int 3 end;
    {$IFDEF DEBUG}
//      asm int 3 end;
    {$ELSE}
//      Error( errInkompatibel, '"' + Op1^.Name + '" und "' + Op2^.Name + '"' );
    {$ENDIF}
    // Reparatur nicht möglich, Ac-Flag-setzen auch nicht weil Opx sind evtl nur die Typen, nicht die Variablen
    end
end;
{$ENDIF}

(* TestFollowType *)
function  TestFollowType( var pId: pIdInfo ): boolean;
begin
  Result := ( pId^.MyType <> nil ) and
            (( pId^.Typ = id_Func )                                or
             ( tIdFlags.IsClassType in pId^.IdFlags )              or
             ( tIdFlags.IsInterface in pId^.IdFlags )              or
             ( tIdFlags.IsPointer   in pId^.PrevBlock^.IdFlags ));
  if Result then begin
    if pId^.NextHelper <> nil then                   // nur sinnvoll wenn es auch einen Helper gibt
      ParserState.LastTypeOwner := pId;              // für die Suche nach einem Helper nochmal speichern
    pId := TListen.getBaseType( pId^.MyType );
    end
end;

(* ParseExpressionList *)
function ParseExpressionList: pIdInfo;
begin
  {$IFDEF TraceDx} TraceDx.Call( uExpr, 'List' ); {$ENDIF}
  repeat ParseExpression( false, Result )
   until not Next.getIf( kw_Komma )
end;

(* ParseIdentifier *)
function  ParseIdentifier( IdType: tIdType; KeepAcSeq: boolean { true: AcFolge im Aufrufer bereinigen };
                           Start: pIdInfo = nil { im ParseExpression() wurde der erste Teil evtl schon eingelesen}): pIdInfo;
var DyaDoppelpunkt,Ende,Ende2,
    IsInheritedGeneric,
    IsGenericType, Id        : boolean;
    FirstOverAc              : pAcInfo;
    NextKw                   : tKeyWord;
    AcStartP, AcStart        : tAcSeqIndex;
    IdStart,
    IdSeqIdx, OverStart,
    IdGenStart, iGen, iOver,
    ParaStartProp, ParaStart : tIdSeqIndex;
    SaveId                   : tIdPosInfo;
    s                        : tIdString;
    Anzahl                   : word;
    ExprType, pIdAkt, pId    : pIdInfo;

  { aus historischen Gründen kann ":" in einigen Procs genutzt werden. Wird temporär eingeschaltet. }
  { NICHT dauerhaft weil case-Label mit ":" enden                                                   }
  procedure TestStartDyaDoppelpunkt;
  begin
    if Next.Peek = kw_KlammerAuf
      then DyaDoppelpunkt := ( Result = pSysId[syWrite] ) or ( Result = pSysId[syWriteLn] ) or ( Result = pSysId[syStr] )
      else DyaDoppelpunkt :=   Result = pSysId[syMem];
    if DyaDoppelpunkt then begin
      inc( DyaDoppelpunktCnt );
      KeyWordListe[kw_Doppelpunkt].OpPrio := cOpPrioDPkt    // Sonderfall "Write (x:3)" und "Str (x:3, s)"
      end
  end;

  procedure TestEndDyaDoppelpunkt;
  begin
    if DyaDoppelpunkt then begin
      dec( DyaDoppelpunktCnt );
      if DyaDoppelpunktCnt = 0 then
        KeyWordListe[kw_Doppelpunkt].OpPrio := cNoOp
      end
  end;

  procedure TestVerlaengerung;
  begin
    if ( Next.Id.Pos.Datei = Result^.LastAc^.Position.Datei ) and ( Next.Id.Pos.Zeile = Result^.LastAc^.Position.Zeile ) then begin
      { Next.Id auf voriges Symbol verlängern weil ^ sonst kaum erkennbar: }
      Next.Id.Pos.Laenge := Next.Id.Pos.Laenge + Next.Id.Pos.Spalte - Result^.LastAc^.Position.Spalte;
      Next.Id.Pos.Spalte := Result^.LastAc^.Position.Spalte;
      end;
  end;

  procedure ParseParameterList;
  var acStart : tAcSeqIndex;
      ExprType: pIdInfo;
  begin
    {$IFDEF TraceDx} TraceDx.Send( uExpr, 'ParameterList' ); {$ENDIF}
    ParaStart := IdSequenz.Pegel;
    repeat
      acStart := AcSequenz.Pegel;
      if ParseExpression( true, ExprType ) = nil
        then AcSequenz.Pegel := acStart;     // Expression ist keine Referenz -> muss acRead sein -> acListe Länge 0 setzen
      IdSequenz.Add( ExprType, acStart, AcSequenz.Pegel )
      until not Next.getIf( kw_Komma )
  end;

  procedure FindOverload;
  {$IFDEF TraceDx}
  type aSig = packed array[0..sizeOf(tSignatur)-1] of byte;
       pSig = ^aSig;
  {$ENDIF}
  var ProcOver,
      ParaGenDummy, ParaCall,
      ParaOver, ParaOverSave: pIdInfo;
      OverMaxPts            : integer;
      {$IFDEF TraceDx}
      ParaSignatur          : tSignatur;
      {$ENDIF}
      SuchMethod            : boolean;
      OverIdx, ParaIdx,
      OverMaxIdx,
      Kandidaten, ParaCnt   : word;

  begin
    Kandidaten := ParaStart - OverStart;
    ParaCnt    := IdSequenz.Pegel - ParaStart;
    {$IFDEF TraceDx} TraceDx.Call( uExpr, 'FindOverload aus', Kandidaten ); {$ENDIF}
    if Kandidaten = 0 then
      Error( errOverloadCand, Result^.Name );
    {$IFDEF TraceDx}    // aktuelle Paras anzeigen
      ParaSignatur := IdSequenz.Pegel - ParaStart;
      if ParaCnt > 0 then
        for ParaIdx := 0 to ParaCnt-1 do
          if IdSequenz.Stack[ParaStart+ParaIdx].IdpId <> nil
            then pSig(@ParaSignatur)^[(ParaIdx+1) mod sizeOf( tSignatur )] := lo( IdSequenz.Stack[ParaStart+ParaIdx].IdpId^.TypeNr );
//            then ParaSignatur := ParaSignatur + (( IdSequenz.Stack[ParaStart+ParaIdx].IdpId^.TypeNr and 255 ) shl ( 8*(ParaIdx+1)) );
      TraceDx.Send( uExpr, 'AktPara-Signatur', ParaSignatur.ToHexString( sizeOf(tSignatur)*2 ));
    {$ENDIF}
    OverMaxIdx := ParaStart;
    SuchMethod := tIdFlags.IsClassType in IdSequenz.Stack[OverStart].IdpId^.PrevBlock^.IdFlags;  // Suche Methods oder non-Methods gemäß erster Proc/Func
    { 1. Auf Kompatibilität prüfen und ggf Identitätspunkte summieren: }
    for OverIdx := OverStart to ParaStart-1 do begin
      ProcOver := IdSequenz.Stack[OverIdx].IdpId;
      if ( ProcOver <> nil ) and ( SuchMethod = ( tIdFlags.IsClassType in ProcOver^.PrevBlock^.IdFlags )) then begin       // Schleife über die overload-Procs
        ParaOver     := TListen.GetParam1( ProcOver );
        ParaGenDummy := ProcOver^.SubBlock;    // erster GenericDummy (falls überhaupt vorhanden)
        if ( ParaGenDummy <> nil ) and not ( tIdFlags.IsGenericDummy in ParaGenDummy^.IdFlags )
          then ParaGenDummy := nil;
        {$IFDEF TraceDx} TraceDx.Send( uExpr, OverIdx.ToString + ' Overload-Signatur', IdSequenz.Stack[OverIdx].IdpId^.Signatur.ToHexString( sizeOf(tSignatur)*2 )); {$ENDIF}

        if ParaOver = nil then                  // keine formalen Parameter
          if ParaCnt = 0 then                       // UND keine realen
            IdSequenz.Stack[OverIdx].AcStart := cMaxPts          // es kann nicht besser werden: Gefunden!
          else begin
            dec( Kandidaten );
            IdSequenz.del( OverIdx );
            {$IFDEF TraceDx} TraceDx.Send( uExpr, 'keine formalen aber reale Paras' ); {$ENDIF}
            continue    // mit der nächsten Funktion weitermachen
            end;

        for ParaIdx := ParaStart to IdSequenz.Pegel-1 do begin                              // Schleife über die aktuellen Paras
          ParaCall := IdSequenz.Stack[ParaIdx].IdpId;                                       // aktueller Parameter
          { Sonderfall Generics: procPara-Typ jetzt durch aktuellen Para-Typ ersetzen: }
          if ( ParaGenDummy <> nil ) and ( tIdFlags.IsGenericDummy in ParaGenDummy^.IdFlags ) and    // proc hat formale Generics
             ( IdGenStart < OverStart )                                                       and    // Call hatt reale generics
             ( ParaOver^.MyType = ParaGenDummy ) then begin                                          // AktVar-Typ ist der formale Generic
            {$IFDEF TraceDx} TraceDx.Send( uExpr, 'Umleitung ' + ParaOver^.Name + ' auf ' + ParaGenDummy^.Name ); {$ENDIF}
            ParaOverSave := ParaOver;
            ParaOver     := ParaGenDummy
            end;

          if ParaCall = nil then begin
             // dieser Parameter hat keinen Typ (idUnbekannt). Nicht ausschliessen aber auch keine Punkte sammeln
            if ( ParaOver = nil )  or  not ( tIdFlags.IsParameter in ParaOver^.IdFlags ) then begin
              dec( Kandidaten );
              IdSequenz.del( OverIdx );
              break                        // Schleife über Parameter kann für dies over beendet werden
              end;
            end
          else begin
            if ( ParaOver <> nil )                                      and          // n-ter Wert in SubListe vorhanden
               ( tIdFlags.IsParameter in ParaOver^.IdFlags )            and          // und ist nicht Result oder lokale Var
               (( IdGenStart = OverStart ) or ( ParaGenDummy <> nil ))  and          // wenn reale GenericTypes angegeben => dann müssen auch formale da sein
               CheckOverloadCompatibility( ParaCall, ParaOver^.MyType, IdSequenz.Stack[OverIdx].AcStart ) then
               // ist kompatibel
            else begin   // inkompatibel, leider ausgeschieden
              dec( Kandidaten );
              IdSequenz.del( OverIdx );
              break                        // Schleife über Parameter kann für dies over beendet werden
              end;

            if Kandidaten = 0 then break;
            end;
          if ParaOver = ParaGenDummy
            then ParaOver := ParaOverSave^.NextId
            else ParaOver := ParaOver^.NextId;
          if ParaGenDummy <> nil
            then ParaGenDummy := ParaGenDummy^.NextId
          end;    { for-Schleife aktuelle Paras }

        if Kandidaten = 0
          then begin {$IFDEF TraceDx} TraceDx.Send( uExpr, 'Kandidaten = 0' ); {$ENDIF} break end;

        { braucht over mehr nicht-optionale Parameter als der Aufruf bietet? }
        if ( ParaOver <> nil ) and ( tIdFlags.IsParameter in ParaOver^.IdFlags ) and not ( tIdFlags.optionalPara in ParaOver^.IdFlags ) and
           ( IdSequenz.Stack[OverIdx].IdpId <> nil ) { wurde over oben bereits wegen inkompatibilität gelöscht? } then begin
          dec( Kandidaten );
          IdSequenz.del( OverIdx );
          if Kandidaten = 0
            then begin {$IFDEF TraceDx} TraceDx.Send( uExpr, 'Kandidaten = 0' ); {$ENDIF} break end
          end;

        if ( IdSequenz.Stack[OverIdx].IdpId <> nil ) and ( ParaCnt > 0 ) and ( IdSequenz.Stack[OverIdx].AcStart = cMaxPts * ParaCnt ) then begin
          OverMaxIdx := OverIdx;
          {$IFDEF TraceDx} TraceDx.Send( uExpr, 'Kandidat = maxPts' ); {$ENDIF}
          break
          end    // dieses over passt perfekt, besser kann es nicht mehr werden. Ausstieg
        end      { for-Schleife overload-Procs }
      else begin
        dec( Kandidaten );
        IdSequenz.del( OverIdx );
        end
      end;

    if Kandidaten = 0 then begin
      { keinen kompatiblen gefunden. Entweder wegen fehlender Sourcen oder falscher Kompatibilitäts-Prüfung. Dummy einrichten: }
      Result := TListen.InsertId( Result^.Name + cSymbolOverload, @MainBlock[mbUnDeclaredUnScoped], Result^.Typ, false );
      include( Result^.IdFlags, tIdFlags.OverloadUnresolved );
      if not ( tFileFlags.LibraryPath in pAktUnit^.fiFlags )
        then include( Result^.IdFlags2, tIdFlags2.IdProjectUse );
      TListen.MoveAc( FirstOverAc, Result )
      end
    else begin
      { 2. Unter den kompatiblen den besten suchen: }
      if OverMaxIdx = ParaStart then begin
        OverMaxPts := -1;
        for OverIdx := OverStart to ParaStart-1 do if IdSequenz.Stack[OverIdx].IdpId <> nil then begin
          if tIdFlags.IsClassVirtual in IdSequenz.Stack[OverIdx].IdpId^.IdFlags
            then IdSequenz.Stack[OverIdx].AcStart := 0;    // virtuelle Methode unwahrscheinlich machen, nur für den Notfall
          if IdSequenz.Stack[OverIdx].AcStart > OverMaxPts then begin
            {$IFDEF TraceDx} TraceDx.Send( uExpr, 'OverloadOptimum', IdSequenz.Stack[OverIdx].IdpId^.Signatur.ToHexString( 8 )); {$ENDIF}
            OverMaxPts := IdSequenz.Stack[OverIdx].AcStart; OverMaxIdx := OverIdx end
          end
        end;

      { 3. ggf auf korrekten overload-Id verschieben: }
      if OverMaxIdx <> OverStart then begin
        Result := IdSequenz.Stack[OverMaxIdx].IdpId;
        TListen.MoveAc( FirstOverAc, Result )
        end;
      end;
    {$IFDEF TraceDx} TraceDx.Send( uExpr, 'OverloadWinner', Result^.Signatur.ToHexString( 8 )) {$ENDIF}
  end;

  function GetResult( pId: pIdInfo ): pIdInfo;
  begin
    if pId^.Typ = id_Proc { FOR-Dummy }
      then Result := pId^.PrevBlock^.SubBlock        // direkt über dem FOR-Dummy ist die function
      else Result := pId^.SubBlock;
    while ( Result <> nil ) and not ( tIdFlags.IsResult in Result^.IdFlags ) do
      Result := Result^.NextId
  end;

  function DeclareIsUser( pIdDecl, pIdUse: pIdInfo ): boolean;
  begin
    while pIdUse <> nil do begin
      if pIdDecl = pIduse
        then exit( true )
        else pIdUse := pIdUse^.prevBlock
      end;
    Result := false
  end;

begin  (* ParseIdentifier *)
  {$IFDEF TraceDx} TraceDx.Call( uExpr, 'Identifier', KeepAcSeq ); {$ENDIF}
  Result    := nil;
  Ende      := false;
  IsInheritedGeneric := false;
  IdStart   := IdSequenz.Pegel;
  AcStart   := AcSequenz.Pegel;    // ab hier ggf Acs auf write umstellen nach späterem :=
  OverStart := IdSequenz.Pegel;    // ab hier ggf Ids von overload-Procs sammeln
  if Start = nil then
    case Next.get of
      kw_Literal   : begin
                       Result := LastLiteral;
                       if ( Next.Peek = kw_Punkt ) or ( Next.Peek = kw_EckigeKlammerAuf ) then
                         Result := Result^.MyType     // Fortsetzung nicht unter der Konstanten
                     end;
      kw_INHERITED : begin
                       IdGenStart := IdSequenz.Pegel;   // weil hier schon overloads gesammelt werden, normalerweise pro Id-Part erst in Haupt-repeat-Schleife setzen
                       pIdAkt := AktDeclareOwner;
                       while ( AktDeclareOwner^.PrevBlock <> nil ) and not ( AktDeclareOwner^.PrevBlock^.Typ in [id_Type, id_Unit, id_Program] ) do AktDeclareOwner := AktDeclareOwner^.PrevBlock;   // aktuelle Methode suchen

                       if Next.getIf( kw_Identifier ) then begin
                         Next.Token := kw_INHERITED;
                         IsInheritedGeneric := Next.Peek = kw_Kleiner     // Sonderfall inherited GetModel<TData>.
                         end
                       else
                         Next.Id.Str := AktDeclareOwner^.Name;        // Methode ist nicht angegeben, aus aktuellem Block übernehmen
                       SaveId := Next.Id;
                       SaveId.Str := AktDeclareOwner^.PrevBlock^.Name + cSymbolParentOf;

                       AktDeclareOwner := AktDeclareOwner^.PrevBlock^.MyParent;
                       if AktDeclareOwner <> nil then
                         if AktDeclareOwner = pSysId[syObject] then
                           Result := TListen.InsertIdAc( Next.Id, pSysId[syObject], id_Unbekannt, ac_Read )
                         else begin
                           Result := TListen.SucheIdInBloecken( cNoHash, Next.Id.Str );
                           if IdGenStart < IdSequenz.Pegel then
                             Result := IdSequenz.Stack[IdGenStart].IdpId;   // overloads: erstes Result liefern
                           if Result <> nil then
                             TListen.AddAc( Result, nil, Next.Id.Pos, ac_Read )
                           end;
                       AktDeclareOwner := pIdAkt;
                       if Result = nil then begin  // quasi der else-Zweig, inherited-Parent unknown
                         Result := TListen.InsertId( SaveId.Str,  @MainBlock[mbUnDeclaredUnScoped], id_Unbekannt, false );
                         include( Result^.AcSet, ac_Read );    // nur damit er auch angezeigt wird
                         Result := TListen.InsertIdAc( Next.Id, Result, id_Unbekannt, ac_Read )
                         end
                       else
                         Result^.LastAc^.IdUse := AktDeclareOwner;    // der war falsch eingetragen worden

                       { Zugriff merken für evtl spätere AcTyp-Wandlung: }
                       AcSequenz.Add( Result^.LastAc )
                     end;
      kw_Identifier: ;
      kw_KlammerAuf: begin
                       Result := ParseExpression( KeepAcSeq, ExprType );   // Falls   (ptr)^ := 1
                       if Result = nil then
                         Result := AcSequenz.Stack[AcStart].IdDeclare;     // falls   (ptr+1)^ := 1
                       Next.Test( kw_KlammerZu )
                     end;

      kw_Punkt     : begin
                       {$IFDEF TraceDx} TraceDx.Send( uExpr, 'WorkAround: Operator nicht zum Result-Typ hin aufgelöst, deshalb Fortsetzung unter <Unbekannt>' ); {$ENDIF}
                       Next.get;                                          // Notbehelf falls weder Variable noch Typ bekannt.
                       Result := @MainBlock[mbUnDeclaredUnScoped];        // Z.B. bei operator "-" der seinem substract() ja leider nicht zugeordnet wird.
                     end;                                                 // Es folgt eine Einordnung unter Unbekannt

      else           Error( errSyntaxError, 'Identifier', Next.Id.Str )
      end
  else begin
    Result := Start;    // von aussen übernehmen
    TestFollowType( Result );
    Next.Token := kw_Literal    // kaputt machen um im repeat nicht in Id-Zweig zu gehen
    end;

  repeat
    if Next.Token <> kw_INHERITED then
      IdGenStart := IdSequenz.Pegel;
    if ( Next.Token = kw_Identifier ) or IsInheritedGeneric then begin   // entweder    nach erstem Id    oder   nach Id1.Id2.   NICHT nach Start-Parameter <> nil

      { Generic ? }
      if ( Next.Peek = kw_Kleiner ) and
           (( ParserState.ParseTypeLevel > 0 ) or
            ( IdType in [id_Unbekannt, id_Type, id_Proc, id_Func] ) and Next.TestForGeneric( Next.Id.Pos )) then begin // Generic real Type:   t1 := TSampleClass<Integer,byte>.Create;

        SaveId := Next.Id;                    // nicht im DFM!  ->   verhindern!
        Next.get;    // kw_Kleiner_Generic
        Anzahl := 0;
        repeat if Next.Peek = kw_Identifier then
                 pId := ParseIdentifier( id_Type, false )
               else begin
//                 pId := nil;
                 pId := @DummyIdUnb;
                 { array oder class einfach überlesen. Das "nil" könnte bei overload Probleme machen }
                 repeat Next.get until ( Next.Peek = kw_Groesser ) or ( Next.Peek = kw_Komma )
                 end;
               IdSequenz.Add( pId, 0, 0 );                 // die realen generic-Types, werden gebraucht in: -ParseType()  -Zuordnung zur Methode
               inc( Anzahl )
         until Next.Test2( kw_Groesser, kw_Komma );
        OverStart := IdSequenz.Pegel;                                  // auf dem IdStack liegen 1) GenericDummys  2)  Overload-Procs   3) Aktuelle Parameter

        { Die Unterscheidung Type oder Methode ist schwierig und nicht absolut sicher: }
        pId := nil;
        s := SaveId.Str + '<' + char( $30 + Anzahl ) + '>';   // Types bekommen den generic-Anhang, Methoden nicht
        IsGenericType := ( ParserState.Statement = 0 ) {or ( Next.Peek = kw_Punkt ) so nicht!};           // in Deklarationen gibt es keine Methoden-Aufrufe
        if not IsGenericType then begin
          if Result = nil            // erst nach Type ( MIT <T>! ) suchen
            then pId := TListen.SucheIdInBloecken( cNoHash, s )
            else pId := TListen.SucheIdUnterId( Result, cNoHash, s, false );
          if pId <> nil then
            IsGenericType := true    // Type gefunden: dann ist es ein generic Type.
          else begin
            // kein Type gefunden: nach function ( OHNE <T>! ) suchen
            if Result = nil
              then pId := TListen.SucheIdInBloecken( cNoHash, SaveId.Str )
              else pId := TListen.SucheIdUnterId( Result, cNoHash, SaveId.Str, true );

            if OverStart < IdSequenz.Pegel then
              pId := IdSequenz.Stack[OverStart].IdpId   // Extra weil ich nicht über InsertId() komme. Overload-proc gefunden, es bleibt bei GenericMethod.
            else
              if pId = nil then
                // auch keine function gefunden: dann definiere ich: es ist eine generic function. Das kann falsch sein (z.B. TypeCast)
              else if ( pId^.SubBlock <> nil ) and
                   not ( tIdFlags.IsGenericDummy in pId^.SubBlock^.IdFlags ) then begin
                     pId := nil;
                     IsGenericType := true    // Id als Funktionsname gefunden, ist aber KEINE generic function
                     end
            end
          end;

        if IsGenericType then begin
          if FileOptions.RegKeySymbols then
            TListen.MoveAc( KeywordListe[kw_Kleiner].LastAc, @KeywordListe[kw_Kleiner_GenTypeUse  ] );

          if pId = nil then begin
            SaveId.Str := s;
            Result := TListen.InsertIdAc( SaveId, Result, id_Type, ac_Read )
            end
          else begin
            Result := pId;
            TListen.AddAc( Result, nil, SaveId.Pos, ac_Read );
            end;
          include( Result^.IdFlags, tIdFlags.IsGenericType )
//          if Next.Peek <> kw_Punkt then
//            begin {$IFDEF TraceDx} TraceDx.Ret; {$ENDIF} exit end               // var v: GenType<BaseType1,BaseType2>   ->   in ParseType fortsetzen
          end
        else begin
          if FileOptions.RegKeySymbols then
            TListen.MoveAc( KeywordListe[kw_Kleiner].LastAc, @KeywordListe[kw_Kleiner_GenMethodUse  ] );

          if pId = nil then begin
            if not IsInheritedGeneric then
              Result := TListen.InsertIdAc( SaveId, Result, id_Unbekannt, ac_Read )
            end
          else begin
            Result := pId;
            TListen.AddAc( Result, nil, SaveId.Pos, ac_Read )
            end;
          if tidflags.IsOverload in Result^.IdFlags then begin
            { Die eben gelesenen realen Types auf die genericDummys unter der Methode verteilen. Nur für overloads notwendig: }
            for iOver := OverStart to IdSequenz.Pegel-1 do begin
              pId := IdSequenz.Stack[iOver].IdpId.SubBlock;
              for iGen := IdGenStart to OverStart-1 do begin
                if ( pId = nil ) or not ( tidflags.IsGenericDummy in pId^.IdFlags ) then break;
                {$IFDEF TraceDx} TraceDx.Send( uExpr, 'SetGenericReal', IdSequenz.Stack[iGen].IdpId^.Name, pId^.PrevBlock^.Name ); {$ENDIF}
                if not ( tIdFlags.IsGenericDummy in IdSequenz.Stack[iGen].IdpId^.IdFlags )
                  then TListen.CopyTypeInfos( IdSequenz.Stack[iGen].IdpId, pId );
                pId := pId^.NextId
                end
              end
            end
          end
        end
      else begin
        Result := TListen.InsertIdAc( Next.Id, Result, id_Unbekannt, ac_Read );
        ParserState.LastTypeOwner := nil;
        if (( Result = pSysId[syString] ) and ( Next.Peek = kw_EckigeKlammerAuf ))  or
           ParserState.ExportsClause
          then exit     // Sonderbehandlung für shortstring-Deklaration
        end;

      if ParserState.AssignMethod then
        TListen.ChangeAcType( Result^.LastAc, ac_ReadAdress );    // falls "funcVar := func"   statt  @func

      { Test, ob FktName nach Result umgebogen werden muss: }
      if ( Result^.Typ = id_Func ) and ParserState.MayBeResult and DeclareIsUser( Result^.LastAc^.IdDeclare, Result^.LastAc^.IdUse ) then
        if ( Result^.MyType^.IdFlags * [tIdFlags.IsPointer, tIdFlags.IsClassType, tIdFlags.IsInterface] <> [] ) and
           ( ( Next.Peek = kw_Punkt ) or ( Next.Peek = kw_Pointer ) ) then begin
          { siehe functions.pas, function g5() }
          AcSequenz.Add( Result^.LastAc );
          Result := Result^.MyType
          end
        else
          if ( Next.Peek = kw_EckigeKlammerAuf ) or ( Next.Peek = kw_Punkt ) or ( Next.Peek = kw_DoppelpunktGleich ) then begin
            {$IFDEF TraceDx} TraceDx.Send( uExpr, 'ChangeFncnameToResult', Result^.Name ); {$ENDIF}
            pId := GetResult( Result );
            TListen.MoveAc( Result^.LastAc { das ist Ac der "Function" } , pId { das ist die "Result"-Variable } );
            Result := pId
            end;

      { Zugriff merken für evtl spätere AcTyp-Wandlung: }
      AcSequenz.Add( Result^.LastAc );
      end;

    { Schleife vorbereiten: }
    Ende  := false;
    Ende2 := false;
    if ( Result^.TypeGroup = coMethod ) and ( Next.Peek <> kw_KlammerAuf )
      then NextKw := kw_KlammerAuf     // für parameterlose Methoden auch in die Nach-Bearbeitung gehen
      else NextKw := Next.Peek;

    repeat
      case NextKw of
        kw_Punkt: begin
          Next.get;
          SaveId := Next.Id;               // für Fall "."-ohne-"^" merken
          { es geht nach "." weiter. Muss der bisherige Result auf den Typ umgebogen werden ? }
          if ( tIdFlags.IsClassType in Result^.IdFlags ) or ( tIdFlags.IsInterface in Result^.IdFlags ) then
            { Normalfall CLASS Type / Var: }
            TestFollowType( Result )
          else
            if tIdFlags.IsPointer in Result^.IdFlags then begin
              { Zugriff über deklarierten Pointer, aber OHNE geschriebens Pointer-Symbol (analog Klassen). Das ist erlaubt! }
    //          if Id then TestVerlaengerung;                    // nicht verlängern bei "(a)^." weil nur um ")" verlängert würde
              SaveId.Str := dPtrSymbol;
              Result := TListen.InsertIdAc( SaveId, Result, id_Var, ac_Read );    // "^"-Zugriff eintragen
              AcSequenz.Add( Result^.LastAc );
              { Dem Pointer (wenn möglich) folgen: }
              if TestFollowType( Result ) then begin
                TListen.AddAc( Result, nil, Next.Id.Pos, ac_Read );
                ParserState.LastTypeOwner := nil;
                AcSequenz.Add( Result^.LastAc )
                end;
              end
            else
              { Normalfall RECORD: }
              if IsEnumCopy in Result^.IdFlags then Result := Result^.MyType;  // Sonderfall, siehe Deklaration "IsEnumCopy"

          { bei Schreibweise &Keyword für scoped Identifier, & kann hier weggelassen werden: "UnitX.begin": }
          if Next.get > kw_Identifier then begin
            if FileOptions.RegKeywords then
              TListen.DeleteAc( KeyWordListe[Next.Token].LastAc, true );
            Next.Token := kw_Identifier
            end;
          Ende := true    //     ^[( - Schleife erstmal beenden und aussen mit Identifier weitermachen
          end;

        kw_Pointer: begin
          if KeepAcSeq then AcSequenz.WasPointerOrArray;
          Id := Next.Token = kw_Identifier;
          Next.get;  // kw_Pointer
          if Id then TestVerlaengerung;    // else (Ptr)^
          if tIdFlags.IsPointer in Result^.IdFlags then begin
             { Normalfall Pointer ist bekannt und ordnungsgemäß eingetragen: }
             Result := TListen.InsertIdAc( Next.Id, Result, id_Var, ac_Read );   // Zugriff auf Id "^"
             if not ( ac_Declaration in Result^.AcSet ) then
               include( Result^.IdFlags2, tIdFlags2.IsUnitSystem );        // macht im System.PreParse Löschen des SubBlock kaputt
             AcSequenz.Add( Result^.LastAc );
             if TestFollowType( Result ) then begin                                        // zum Typ springen
               Next.Id.Str := Result^.Name;                                                  // dies und weiteres unter dem Typ-Namen der Variablen eintragen
               Result := TListen.InsertIdAc( Next.Id, Result^.PrevBlock, id_Type, ac_Read );
               ParserState.LastTypeOwner := nil;
               AcSequenz.Add( Result^.LastAc )
               end
             end
          else begin
            include( Result^.IdFlags, tIdFlags.IsPointer );
            { Nicht als Pointer-Variable bekannt, jetzt nachtragen: }
  //          include( Result^.Flags, IsPointer );  das könnte jetzt nachgetragen werden, aber MyType fehlt noch immer
            Result := TListen.InsertIdAc( Next.Id, Result, id_Var, ac_Read );
            AcSequenz.Add( Result^.LastAc )
            end
          end;

        kw_EckigeKlammerAuf: begin
            if tIdFlags.IsPointer in Result^.IdFlags then begin
              { Zugriff über deklarierten Pointer, aber OHNE geschriebens Pointer-Symbol (analog Klassen). Das ist erlaubt! }
    //          if Id then TestVerlaengerung;                    // nicht verlängern bei "(a)^." weil nur um ")" verlängert würde
              NextId.Str := dPtrSymbol;
              Result := TListen.InsertIdAc( NextId, Result, id_Var, ac_Read );    // "^"-Zugriff eintragen
              AcSequenz.Add( Result^.LastAc );
              { Dem Pointer (wenn möglich) folgen: }
              if TestFollowType( Result ) then begin
                TListen.AddAc( Result, nil, Next.Id.Pos, ac_Read );
                ParserState.LastTypeOwner := nil;
                AcSequenz.Add( Result^.LastAc )
                end;
              end;

          if KeepAcSeq then AcSequenz.WasPointerOrArray;
          TestStartDyaDoppelpunkt;         // für mem[$b000:0] aus Turbo-Zeiten
          TestFollowType( Result );        // nur für CLASS-Default-Eigenschaft, wird oben nicht mit abgedeckt
          ParserState.LastTypeOwner := nil;// dafür gibt es keinen Helper
          Anzahl := 0;
          repeat                           { Id[x] }
            inc( Anzahl );
            Next.Test2( kw_EckigeKlammerAuf, kw_Komma );
            Next.Id.Str := dArraySymbol;
            if Result^.Typ = id_Type
              then Result := TListen.InsertIdAc( Next.Id, Result, id_Unbekannt, ac_Read )     // nach FollowType, sonst errBadIdType
              else Result := TListen.InsertIdAc( Next.Id, Result, Result^.Typ , ac_Read );    // const oder var
            AcSequenz.Add( Result^.LastAc );
            ParseExpression( false, ExprType )
          until Next.getIf( kw_EckigeKlammerZu );

          { falls indizierter String-Zugriff auf chars: jetzt Pseudo-Deklaration für array: }
          if ( Anzahl = 1 ) and ( Result^.AcList = Result^.LastAc ) and
             (( TListen.getBaseType( Result^.PrevBlock^.MyType ) = pSysId[syString] ) or
              (                      Result^.PrevBlock           = pSysId[syString] )) then begin
            TListen.CopyTypeInfos( pSysId[syChar], Result );
            if Result^.PrevBlock^.Typ = id_Const
              then Result^.Typ := id_Const
              else Result^.Typ := id_Var;
            include( Result^.IdFlags2, tIdFlags2.IsUnitSystem )
            end;
          TestEndDyaDoppelpunkt
          end;

        kw_KlammerAuf: begin
          AcStartP  := AcSequenz.Pegel;       // Proc-lokalen Pegel für Parameterliste-Acs merken
          ParaStart := IdSequenz.Pegel;       // Proc-lokalen Pegel für Parameterliste-Types merken
          FirstOverAc:= Result^.LastAc;       // hier wurde der Overload-access erstmal eingetragen
          if Next.Peek = kw_KlammerAuf then begin  { nicht bei parameterlosen Proc/Func }    // Id( x, y )     Proc()
            SaveId := Next.Id;               // für Fall "exit" merken
            TestStartDyaDoppelpunkt;         // für write() und str()
            Next.get;  // kw_KlammerAuf
            if Next.Peek <> kw_KlammerZu then begin
              if Result = pSysId[syExit] then begin                             // Verwandele "exit(..)" in acWrite auf "Result"
                SaveId.Str := cSymbolResult;
                TListen.InsertIdAc( SaveId, nil, id_Var, ac_Write );
                include( Result^.LastAc^.AcFlags, tAcFlags.DontFind )           // lieber den Result-Ac finden
                end;
              ParseParameterList;
              if tIdFlags.paraMirror in Result^.IdFlags then begin
                { einige System-Funktionen liefern den ResultTyp abhängig vom Input-Typ:
                         abs       int / real
                         high      enum / int                      input string -> int
                         low        "                               "
                         sqr       int / int64 / extended
                         pred      enum / int / char
                         succ       "
                         StringOfChar   char / ansichar   -> eigentlich string / ansistring, das geht nicht deshalb mirror
                         upcase    char / ansichar               }
                if IdSequenz.Stack[ParaStart].IdpId = nil then
                  Result^.MyType := @DummyIdUnb
                else if ( IdSequenz.Stack[ParaStart].IdpId^.TypeGroup in [coEnum, coChar] )
                  then Result^.MyType := IdSequenz.Stack[ParaStart].IdpId^.MyType      // aus Parameter übernehmen
                  else Result^.MyType := pSysId[syInteger]                             // fest auf integer
                end
              end;
            Next.Test( kw_KlammerZu );
            TestEndDyaDoppelpunkt
            end;
          { 1. Overload-Korrektur: }
          if tIdFlags.IsOverload in Result^.IdFlags then begin
            if ParserState.PropReadWrite then begin
              { komme nicht aus Aufruf mit Parametern sondern property. Die Parameter sind die, die unterm property stehen (siehe Verifikation\classes) }
              pId := Result^.PrevBlock^.SubLast;  // das ist das aktuelle property. Dessen Parameter (also Subs) in die IdSequenz schmeissen:
              ParaStartProp := ParaStart;
              ParaStart := IdSequenz.Pegel;
              while pId <> nil do begin
                IdSequenz.Add( pId^.MyType, 0{irrelevant}, 0 );
                pId := pId^.NextId
                end;
              end;
            FindOverload;     // ggf Result gemäß akt Parametern korrigieren
            TListen.SetIdProjectUse( Result );      // das wurde im InsertIdAc verzögert, JETZT nachholen

            if ParserState.PropReadWrite then begin
              IdSequenz.Pegel := ParaStart;        // alles wieder zurück für folgende acWrite-Auswertung
              ParaStart := ParaStartProp
              end
            end;
          { 2. Parameter-Access ggf auf acWrite: }
          if Result^.Typ <> id_Type then begin   // Typecast, ac bleibt bei ac_read
            pId := TListen.GetParam1( Result );
            for IdSeqIdx := ParaStart to IdSequenz.Pegel-1 do with IdSequenz.Stack[IdSeqIdx] do
              if pId = nil then
                AcSequenz.ChangeAcToUnknown( AcStart, AcEnde )
              else begin
                if tIdFlags.IsWriteParam in pId^.IdFlags then
                  AcSequenz.ChangeAcToWrite( AcStart, AcEnde, ac_ReadAdress );
                {$IFDEF TestKompatibel} TestCompatibility( pId, IdPid ); {$ENDIF}
                pId := pId^.NextId
                end;
            { 2a. Rekursions-Erkennung: }
            if Result^.LastAc^.ZugriffTyp = ac_Read then begin    // nicht bei ReadAdr oder Write
              pId := AktDeclareOwner;
              while pId^.TypeGroup = coMethod do begin
                if Result = pId
                  then include( Result^.LastAc^.AcFlags, tAcFlags.Rekursiv );    // Rekursions-Erkennung, ggf nach ":=" oder "@proc" korrigieren
                pId := pId^.PrevBlock                                            // auch indirekte Rekursion über Schachtelung erkennen
                end
              end
            end;
          { 3. aufräumen : }
          IdSequenz.Pegel := IdGenStart;      // vor-Proc-Pegel wieder herstellen
          AcSequenz.Pegel := AcStartP;       // vor-Proc-Pegel wieder herstellen
          { 4. Funktionen auf Typ weiterleiten: }
          TestFollowType( Result )
          end;
        kw_AS: begin
          Next.get;  // kw_AS
          Result := ParseIdentifier( id_Type, false )
          end
        else
          Ende := true;
          Ende2 := true
        end;
      NextKw := Next.Peek
    until Ende
  until Ende2;

  AcSequenz.BuildAcChain( AcStart );
  if not KeepAcSeq then    // da bei jeder WITH-Nutzung ein ac eingetragen wird muss hier unbedingt restauriert werden
    AcSequenz.Pegel := AcStart;

  if ParserState.Statement > 0 then
    IdSequenz.Pegel := IdStart;
  ParserState.LastTypeOwner := nil;

  if ( IdType <> id_Unbekannt ) and ( Result^.Typ = id_Unbekannt ){ and ( Result^.Typ <> IdType )} then
    TListen.ChangeIdType( Result, IdType )
end;

(* GetTypeNrOfSet *)
function  GetTypeNrOfSet( pId: pIdInfo ): tTypeNr;
begin
  case pId^.TypeGroup of
    coInt : Result := pSysId[cSetInt ]^.TypeNr + cSetInc;
    coChar: Result := pSysId[cSetChar]^.TypeNr + cSetInc;
//  coSet : Result := pId^.TypeNr;
    else    Result := pId^.TypeNr             + cSetInc;
    end;
end;

(* ParseExpression *)
function  ParseExpression( KeepAcSeq: boolean { true: AcFolge im Aufrufer bereinigen }; out OutExprType: pIdInfo ): pIdInfo;
var Ende,
    ExprNegative,
    VarRef  : boolean;
    stm,
    AcStart : word;
    Expected,
    ExprType: pIdInfo;
    MinPrio : tPrio;

  (* calcExprType *)
  procedure calcExprType( pType: pIdInfo; Op: tKeyWord );
  begin
    if OutExprType = nil
      then OutExprType := pType       // nur ein Operand, daraus übernehmen
      else;                           // Out beibehalten ( todo: ggf Wertebereich entsprechend diesem Operanden erweitern
    case KeyWordListe[Op].OpPrio of
      cNoOp: ;
      1    : if OutExprType = nil
               then OutExprType := pType
               else; // ist durch Operator schon gesetzt, evtl auf boolean
      2    : begin
               Expected    := OutExprType;
               OutExprType := pSysId[syBoolean];
             end;
      else   Expected := OutExprType;
             { Sonderfall: char und '+' ergibt string: }
             if ( OutExprType = pSysId[syChar] ) and ( Op = kw_Plus ) then
               pType := pSysId[syString];
             if { Bit-AND/OR?} ( Op in [kw_AND, kw_OR, kw_XOR, kw_NOT] ) and ( OutExprType = pSysId[syBoolean] )
               then // OutExprType := pSysId[syBoolean]     // ist sowieso schon
               else OutExprType := pType                    // Typ übernehmen
      end
  end;

  procedure enlargeIntSize( pType: pIdInfo );
  begin
    if ( OutExprType <> nil ) and ( OutExprType^.TypeNr <= pSysId[syShortInt]^.TypeNr ) then
      if OutExprType^.TypeNr > pType^.TypeNr then
        if ExprNegative and ( pType = pSysId[syCardinal] )
          then OutExprType := pSysId[syInt64]                 // negativ + cardinal -> int64
          else OutExprType := pType                           // größeren Typ übernehmen
  end;

begin  (* ParseExpression *)
  {$IFDEF TraceDx} TraceDx.Call( uExpr, 'Expression', KeepAcSeq ); {$ENDIF}
  Result      := nil;
  Expected    := nil;
  OutExprType := nil;
  VarRef      := true;
  ExprNegative:= false;
  Ende        := false;
  MinPrio     := high( tPrio );
  repeat
    case Next.Peek of
      kw_Literal: begin                                  //    1    'a'    10000.ToString
        VarRef   := false;
        Result   := ParseIdentifier( id_Unbekannt, false );  // wegen 10000.ToString  , 'abc'[1]
        ExprType := Result^.MyType;
        enlargeIntSize( ExprType );                      // integer-Typ ggf vergrößern
        {$IFDEF TestKompatibel} TestCompatibility( Expected, ExprType ) {$ENDIF}
        end;
      kw_INHERITED,
      kw_Identifier: begin                                // v   v.ToString  v(p1)   integer(v)   v[1]   v^
        Result := ParseIdentifier( id_Unbekannt, KeepAcSeq );
        if Result^.Typ = id_Type
          then ExprType := Result                         // TypeCast !!
          else ExprType := Result^.MyType;
        if ExprType <> nil then begin                     // sonst Unbekannt. Unbekannte Ids sind zu ALLEN kompatibel, kein Test
          enlargeIntSize( ExprType );                     // integer-Typ ggf vergrößern
          {$IFDEF TestKompatibel} TestCompatibility( Expected, ExprType ) {$ENDIF}
          end
        end;
      kw_PROCEDURE, kw_FUNCTION: begin                    // anonyme Proc/Func
        inc( ParserState.DeclAnonym );
        stm := ParserState.Statement;
        ParserState.Statement := 0;     // temporär auf "kein Statement" setzen
        ParseDeclarations( do_Anonym, nil );
        ParserState.Statement := stm;
        dec( ParserState.DeclAnonym );
        ExprType := pSysId[syPointer]
        end;
      kw_MonadischPlus, kw_MonadischMinus, kw_NOT: begin                    //  -Id     not b
        VarRef := false;
        if Next.Peek = kw_MonadischMinus then ExprNegative := true;
        if Next.Peek = kw_NOT
          then ExprType := pSysId[syBoolean ]
          else ExprType := pSysId[syShortInt]
        end;
      kw_Klammeraffe: begin                               //  @Id
        Next.get;
        Next.getIf( kw_Klammeraffe );                     // es kann tatsächlich zwei geben, siehe Verifikation\Statements
        VarRef   := false;
        AcStart  := AcSequenz.Pegel;
        ParserState.AssignMethod := false;                        // falls an hier schon ausschalten weil @ für acReadAdr genügt
        Result   := ParseIdentifier( id_Unbekannt, true );        // der unwahrscheinliche Fall "@((x))" geht hiermit nicht
        AcSequenz.ChangeAcEndToWrite( AcStart, ac_ReadAdress );   // Komponenten auf acReadAdr
        ExprType := pSysId[syPointer];
        {$IFDEF TestKompatibel} TestCompatibility( Expected, ExprType ) {$ENDIF}
        end;
      kw_KlammerAuf: begin                                //  (Id+x), Operatoren-Vorrang-Klammerung
        Next.Test( kw_KlammerAuf );
        VarRef := false;    // todo: ???
        Result := ParseExpression( false, ExprType );
        Next.Test( kw_KlammerZu );
        if ( Next.Peek = kw_Punkt ) or ( Next.Peek = kw_EckigeKlammerAuf ) or ( Next.Peek = kw_AS ) or ( Next.Peek = kw_Pointer ) then
          if Result = nil then
            Result := ParseIdentifier( id_Unbekannt, false, ExprType )      // ... aus ('abc').   oder     ('abc'+'d').
          else begin
            Result := ParseIdentifier( id_Unbekannt, false, Result   );     // ... aus (aVar).
            if Result^.Typ = id_Type
              then ExprType := Result                         // TypeCast !!
              else ExprType := Result^.MyType
            end;
        {$IFDEF TestKompatibel} TestCompatibility( Expected, ExprType ) {$ENDIF}
        end;
      kw_EckigeKlammerAuf: begin                          //   [x,y], [], Menge
        VarRef := false;
        Next.get;
        if Next.getIf( kw_EckigeKlammerZu ) then begin
          DummyIdSet.TypeNr := cEmptySet;
          ExprType := @DummyIdSet;
          end
        else begin
          ExprType := ParseExpressionList;
          Next.Test( kw_EckigeKlammerZu );
          if ExprType = nil then
            ExprType := @DummyIdUnb          // unbekannter Ausruck im Set :-(
          else begin
            DummyIdSet.TypeNr := GetTypeNrOfSet( ExprType );
            ExprType := @DummyIdSet;
            end
          end;
        {$IFDEF TestKompatibel} TestCompatibility( Expected, ExprType ) {$ENDIF}
        end;
      kw_NIL: begin
        Next.get;
        Next.getIf( kw_Pointer );        // das kommt in source\vcl\vcl.imaging.GIFimg.pas vor
        VarRef   := false;
        ExprType := pSysId[syPointer];
        {$IFDEF TestKompatibel} TestCompatibility( Expected, ExprType ) {$ENDIF}
        end
      else
        Error( errSyntaxError, '<Expression>', Next.Id.Str )
      end;
    if MinPrio > KeyWordListe[Next.Peek].OpPrio then begin             // wenn neue Prio niedriger als bisheriges min:
      MinPrio := KeyWordListe[Next.Peek].OpPrio;                       // Op niedrigerer Prio gefunden (oder Expr-Ende)
      calcExprType( ExprType, Next.Peek )                  // neuen ExprTyp berechnen
      end;
    if MinPrio = cNoOp then begin                          // Ende
      Ende := true;
      if not VarRef then Result := nil;
      end
    else begin                                             // sonst
      VarRef := false;                                     // Expr mit Op kann keine Variablen-Referenz sein
      if Next.get = kw_IN then begin
        if ExprType = nil
          then DummyIdSet.TypeNr := cEmptySet
          else DummyIdSet.TypeNr := GetTypeNrOfSet( ExprType );
        Expected := @DummyIdSet                            // Sonderfall "IN": enum in set    verknüpft zwei verschiede Typ-Gruppen
        end
      end
  until Ende;
  {$IFDEF TraceDx} TraceDx.Send( uExpr, 'Result', TListen.pIdName( Result ), ' / Type=' + TListen.pIdName( OutExprType )); {$ENDIF}
end;

(* PreParseExpressions *)
procedure PreParseExpressions;
begin
  {$IFDEF TraceDx} TraceDx.Send( uExpr, 'PreParseExpressions' ); {$ENDIF}
  DyaDoppelpunktCnt := 0;
end;

end.
