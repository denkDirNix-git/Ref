
unit uStatements;

{$INCLUDE _CompilerOptionsRef.pas}
{$INCLUDE _CompilerOptions.pas}
{ $UNDEF TraceDx}

{ ---------------------------------------------------------------------------------------- }

interface

procedure ParseStatementBlock;
procedure ParseStatement;
procedure ParseStatementList;
procedure PreParseStatements;

{ ---------------------------------------------------------------------------------------- }

implementation

uses
  {$IFDEF TraceDx} uTraceDx, {$ENDIF}
  uGlobals,
  uGlobalsParser,
  uDeclarations,
  uExpressions,
  uSystem,
  uScanner,
  uListen;

const
  cSymbolTry = 'try-on';
  cSymbolFor = 'for-Block';

{$IFDEF TraceDx} type uStm = class end; {$ENDIF}

var
  ForNesting : word;
  DummyIdFor : tIdInfo = ( Name: cSymbolFor; Typ: id_DummyProc; IdFlags: [tidFlags.IdUnused] );

{ ---------------------------------------------------------------------------------------- }

(* ParseStatementBlock *)
procedure ParseStatementBlock;
begin
  Next.Test( kw_BEGIN );
  ParseStatementList;
  Next.Test( kw_END )
end;

(* ParseStatement *)
procedure ParseStatement;
var ExprType, pId  : pIdInfo;
    pAcFor         : pAcInfo;
    ForPos         : tFilePos;
    stop,
    StmBlock       : boolean;
    stm,i,AnzahlVar: word;
    AcStart        : tAcSeqIndex;
begin
  {$IFDEF TraceDx} TraceDx.Send( uStm, 'Statement' ); {$ENDIF}
  assert( DyaDoppelpunktCnt = 0 );
  if ( ParserState.Statement > 0 ) or ( ParserState.DeclAnonym > 0 ) or ( IdSequenz.Pegel = 0 )
    then
    else IdSequenz.Pegel := 1;
  assert( ( ParserState.Statement > 0 ) or ( ParserState.DeclAnonym > 0 ) or ( IdSequenz.Pegel = 0 ), 'IdSequenz.Pegel = ' + IdSequenz.Pegel.ToString );
  inc( ParserState.Statement );
  case Next.Peek of
    kw_Literal: begin     //  { ist unbedingt Label }
      Next.get;
      TListen.InsertIdAc( Next.Id, AktDeclareOwner, id_Label, ac_Write );
      TListen.DeleteAc( LastLiteral^.LastAc, false );    //  Literal unter Const wieder löschen
//      TListen.InsertIdAc( Next.Id, AktDeclareOwner, id_Label, ac_Write );
      Next.Test( kw_Doppelpunkt );
      ParseStatement
      end;
    kw_Identifier, kw_INHERITED, kw_KlammerAuf: begin
      AcStart := AcSequenz.Pegel;
      ParserState.MayBeResult := true;
      pId := ParseIdentifier( id_Unbekannt, true );
      ParserState.MayBeResult := false;                             // hinterm := ist für FktName niemals Umwandlung in Result notwendig

      if Next.getIf( kw_DoppelpunktGleich ) then begin
        { Assignment: }
//        AcSequenz.ChangeAcToResult  ( AcStart           );            // func ggf auf Result umbiegen
        AcSequenz.ChangeAcEndToWrite( AcStart, ac_Write );            // Komponenten auf acWrite
        if ( pId^.TypeGroup = coMethod ) and { nicht für anonyme proc/func:} ( Next.Peek = kw_Identifier )
          then ParserState.AssignMethod := true;                    // funcVar := func  statt  @func  erzeugt so auch acReadAdr
        ParseExpression( false, ExprType );
        if pId^.TypeGroup = coMethod then
          ParserState.AssignMethod := false                    // wieder ausschalten
         { Zuweisung "pFunc := func"  statt   "pFunc := @func"  ist Typ-kompatibel!
           Kann aber in TestCompatibility nicht geprüft werden weil ExprType schon FuncResult-Type }
        else
          {$IFDEF TestKompatibel} TestCompatibility( pId, ExprType ) {$ENDIF}
        end
      else begin
        AcSequenz.Pegel := AcStart;
        if Next.getIf( kw_Doppelpunkt ) then begin
          { Label: }
          TListen.ChangeAcType( pid^.LastAc, ac_Write );
          ParseStatement
          end
        else
        end  { Prozedur-Call ist oben bereits abgehandelt }
      end;
    kw_Klammeraffe: begin
      Next.get;                                                     // Assignment an proc/func:   @p := exitProc
      ParseStatement
      end;
    kw_Semikolon: ;   // empty statement
    kw_BEGIN:
      ParseStatementBlock;
    kw_ASM: begin        //  es kann geben:      jmp  @end     mov al,"'"
      ParserState.AssemblerCode := true;
      stop := false;
      repeat
        case Next.get of
          kw_END        : stop := true;
          kw_Literal    : ; // Nicht löschen, könnten interessant sein!   TListen.DeleteLastAccess( );
          kw_Identifier : ;
          kw_Klammeraffe: begin
                            repeat until Next.get <> kw_Klammeraffe;
                            if ( Next.Token = kw_END ) and ( KeyWordListe[kw_END].LastAc <> nil ) then
                              { nur END wird (hier falsch) als Keyword registriert: }
                              TListen.DeleteAc( KeyWordListe[kw_END].LastAc, true );
                            //todo: Literal NUR unter Block eintragen, unter Const wieder löschen
                            if not ( OverNextKw in [kw_Klammeraffe, kw_END] )
                              then Next.get
                          end;
          end
      until stop;
      ParserState.AssemblerCode := false
      end;
    kw_GOTO: begin
      Next.get;
      if Next.Test2( kw_Literal, kw_Identifier) then
        TListen.DeleteAc( LastLiteral^.LastAc, true ) ;  { Literal unter Const wieder löschen }
      TListen.InsertIdAc( Next.Id, AktDeclareOwner, id_Label, ac_Read )                                    { Label im Block eintragen }
      end;
    kw_IF: begin
      Next.get;
      ParseExpression( false, ExprType );
      Next.Test( kw_THEN );
      ParseStatement;
      if Next.getIf( kw_ELSE ) then ParseStatement
      end;
    kw_CASE: begin
      Next.get;
      ParseExpression( false, pId );
      Next.Test( kw_OF);
      while not Next.getIf( kw_ELSE ) and not Next.getIf( kw_END ) do begin
        ExprType := ParseExpressionList;
        {$IFDEF TestKompatibel} TestCompatibility( pId, ExprType ); {$ENDIF}
        Next.Test( kw_Doppelpunkt );
        ParseStatement;
        Next.getIf( kw_Semikolon )
        end;
     if Next.Token = kw_ELSE then begin
      if FileOptions.RegKeywords then
        TListen.MoveAc( KeywordListe[kw_ELSE].LastAc, @KeywordListe[kw_ELSE_case] );
       ParseStatementList;
       Next.Test( kw_END )
       end
     end;
    kw_CONST: begin
      stm := ParserState.Statement;
      ParserState.Statement := 0;     // temporär auf "kein Statement" setzen
      Next.get;
      Next.Test( kw_Identifier );
      pId := TListen.InsertIdAc( Next.Id, AktDeclareOwner, id_Const, ac_Declaration );

      if Next.getIf( kw_Doppelpunkt ) then
        ParseType( pId, 1 );

      ParserState.Statement := stm;     // wieder herstellen
      if Next.getIf( kw_Gleich ) then begin
        ParseExpression( false, ExprType );
        if pId^.MyType = nil then
          if ExprType <> nil then begin         // keine explizite Typisierung vorhanden: jetzt aus Wert ableiten
            if ExprType^.TypeGroup = coInt then
              ExprType := pSysId[syInteger];        // falls kein Typ angegeben UND numerisch: IMMER integer
            TListen.CopyTypeInfos( ExprType, pId )
            end
          else
            pId^.TypeGroup := coUnb
        end;
//      ParserState.Statement := stm     // vor ParseExpression() gezogen für Verify.CodeVarOverload
      end;
    kw_VAR: begin
      stm := ParserState.Statement;
      ParserState.Statement := 0;     // temporär auf "kein Statement" setzen
      Next.get;
      Next.Test( kw_Identifier );
      pId := TListen.InsertIdAc( Next.Id, AktDeclareOwner, id_Var, ac_Declaration );

{      if ForNesting > 0 then begin
        if not ( tIdFlags.IsDummy in pId^.IdFlags ) then    // bin ich schon im Dummy-For-Block ?
        end;
 }
      AnzahlVar := 1;
      while Next.getIf( kw_Komma ) do begin
        Next.Test( kw_Identifier );
        TListen.InsertIdAc( Next.Id, AktDeclareOwner, id_Var, ac_Declaration );
        inc( AnzahlVar )
        end;

      if Next.getIf( kw_Doppelpunkt ) then
        ParseType( pId, AnzahlVar );

      ParserState.Statement := stm;     // wieder herstellen
      if Next.getIf( kw_DoppelpunktGleich ) then begin
        TListen.AddAc( pId, nil, Next.Id.Pos, ac_Write );
        ParseExpression( false, ExprType );
        if pId^.MyType = nil then
          if ExprType <> nil then begin         // keine explizite Typisierung vorhanden: jetzt aus Wert ableiten
            if ExprType^.TypeGroup = coInt then
              ExprType := pSysId[syInteger];        // falls kein Typ angegeben UND numerisch: IMMER integer
            TListen.CopyTypeInfos( ExprType, pId )
            end
          else
            pId^.TypeGroup := coUnb
        end;
//      ParserState.Statement := stm     // vor ParseExpression() gezogen für Verify.CodeVarOverload
      end;
    kw_FOR:
      begin
      Next.get;
      StmBlock := false;

      if ForNesting = 0 then begin
        ForPos := Next.Id.Pos;                      // For-Position merken
        TListen.NewAc( pAcFor );                    // den pAc JETZT holen damit er unten ggf auch als Grenze für MoveAcsUp() genutzt werden kann
        DummyIdFor.PrevBlock := AktDeclareOwner;    // für LeaveBlock
        TListen.EnterBlock( @DummyIdFor )
        end;
      inc( ForNesting );
                                                    // kw_IN wird im ParseExpression() mit bearbeitet
      KeyWordListe[kw_IN].OpPrio := cNoOp;
      if Next.getIf( kw_VAR ) then begin             // in-Code-Declaration
        StmBlock := true;
        Next.Test( kw_Identifier );
        pId := TListen.InsertIdAc( Next.Id, AktDeclareOwner, id_Var, ac_Declaration );
        TListen.AddAc( pId, nil, Next.Id.Pos, ac_Write );
        if Next.getIf( kw_Doppelpunkt ) then
          ParseType( pId, 1 )
        end
      else begin
        pId := ParseIdentifier( id_Var, false );            // kann auch scoped sein, siehe Verifikation\Verify.Statements.pas. Aber nicht strukturiert
        TListen.ChangeAcType( pId^.LastAc, ac_Write );      // ohne VAR-Deklaration: es wurde  ein acRead angelegt, jetzt wechseln
        end;

      if Next.Test2( kw_DoppelpunktGleich, kw_IN ) then begin
        ParseExpression( false, ExprType );
        if pId^.MyType = nil then
          if ExprType <> nil then begin         // keine explizite Typisierung vorhanden: jetzt aus Wert ableiten
            if ExprType^.TypeGroup = coInt then
              ExprType := pSysId[syInteger];        // falls kein Typ angegeben UND numerisch: IMMER integer
            TListen.CopyTypeInfos( ExprType, pId )
            end
        else
          pId^.TypeGroup := coUnb;
        Next.Test2( kw_TO, kw_DOWNTO )
        end
      else
        if FileOptions.RegKeywords then
          TListen.MoveAc( KeywordListe[kw_IN].LastAc, @KeywordListe[kw_IN_for] );

      KeyWordListe[kw_IN].OpPrio := cOpPrioIN;
      ParseExpression( false, ExprType );
      Next.Test( kw_DO );
      ParseStatement;
      dec( ForNesting );
      if ForNesting = 0 then begin
        TListen.LeaveBlock;
        if DummyIdFor.SubBlock = nil then begin
          { for-Block wurde nicht gebraucht. Für alle innerhalb For angelegten Acs den IdUse korrigieren: }
          DummyIdFor.PrevBlock := AktDeclareOwner;          // Ziel für IdUse der Acs im MoveLastAcsUp
          TListen.MoveLastAcsUp( @DummyIdFor, pAcFor );    // alle unter DummyFor neuen Acs eine Ebene hoch
          include( pAcFor^.AcFlags, tAcFlags.AcUnused )     // der geholte pAc ist leider überflüssig, wegschmeissen
          end
        else begin
          { echten For Block anlegen: }
          pId := TListen.InsertId( DummyIdFor.Name, AktDeclareOwner, id_DummyProc, false );   // den pAc habe ich schon, kommt gleich
          include( pId^.IdFlags, tIdFlags.IsDummy );    // damit mehrere for-Blöcke parallel exisiteren können

          TListen.AddAc( pId, pAcFor, ForPos, ac_Declaration );  // das FOR bekommt jetzt seinen ac_Declare angehängt
          include( pId^.AcList^.AcFlags, tAcFlags.DontFind );    // warum sollte ich ihn finden wollen? Ginge aber...

          pId^.SubBlock := DummyIdFor.SubBlock;                  // alle for-lokalen Variablen ...
          pId^.SubLast  := DummyIdFor.SubLast;                   // ... umhängen
          DummyIdFor.SubBlock := nil;                            // und reset für nächstes for
          DummyIdFor.SubLast  := nil;
          { für alle unter DummyFor angelegten Ids den PrevBlock und bei deren Acs den IdDeclare korrigieren: }
          TListen.CaptureSubIds( pId );
          { für alle zuletzt unter DummyFor angelegten Acs den IdUse korrigieren: }
          DummyIdFor.PrevBlock := pid;                  // Ziel für IdUse der Acs im MoveLastAcsUp
          TListen.MoveLastAcsUp( @DummyIdFor, pAcFor )         // alle Acs seit pAcFor eine Ebene hoch
          end
        end
      end;
    kw_WHILE: begin
      Next.get;
      ParseExpression( false, ExprType );
      Next.Test( kw_DO );
      ParseStatement
      end;
    kw_REPEAT: begin
      Next.get;
      ParseStatementList;
      Next.Test( kw_UNTIL );
      ParseExpression( false, ExprType )
      end;
    kw_WITH: begin
      Next.get;
      AnzahlVar := 0;
      repeat
        inc( AnzahlVar );
        AcStart := AcSequenz.Pegel;
        pId := ParseIdentifier( id_Unbekannt, true );
        TestFollowType( pId );
        TListen.InsertIdPtr( WithListe, pId, AcStart, AcSequenz.Pegel )
      until Next.Test2( kw_Do, kw_Komma );
      ParseStatement;
      for i := 1 to AnzahlVar do begin
        AcSequenz.Pegel := WithListe^.AcStart;
        TListen.LeaveWith
        end
      end;
    kw_TRY: begin
      Next.get;
      ParseStatementList;
      if Next.Test2( kw_Except, kw_Finally ) then begin
        while NextPascalDirective( ds_ON ) = pd_ON do begin
          StmBlock := false;
          if Next.Peek2 = ':' then begin
            StmBlock := true;
            Next.Id.Str := cSymbolTry;
            pId := TListen.InsertIdAc( Next.Id, AktDeclareOwner, id_DummyProc, ac_Declaration );   // als Träger für folgende try-lokale(!) Variable
            include( pId^.        IdFlags, tIdFlags.IsDummy  );
            include( pId^.LastAc^.AcFlags, tAcFlags.DontFind );
            TListen.EnterBlock( pId );
            Next.Test( kw_Identifier );
            pId := TListen.InsertIdAc( Next.Id, pId, id_Var, ac_Declaration );
            Next.Test( kw_Doppelpunkt );
            ExprType := ParseIdentifier( id_Type, false );
            TListen.SetIdTypeClass( ExprType );
            TListen.CopyTypeInfos( ExprType, pId );
            TListen.SetIdTypeClass( pId );
            end
          else begin
            pId := ParseIdentifier( id_Type, false );
            TListen.SetIdTypeClass( pId )
            end;
          Next.Test( kw_DO );
          ParseStatement;
          if StmBlock then
            TListen.LeaveBlock;
          Next.getIf( kw_Semikolon )
          end;
        Next.getIf( kw_ELSE )
        end;
      ParseStatementList;
      Next.Test( kw_End )
      end;
    kw_RAISE: begin
      Next.get;
      if Next.Peek = kw_Identifier then begin
        ParseExpression( false, ExprType );
        if NextPascalDirective( ds_ON ) = pd_AT then
          ParseExpression( false, ExprType )
        end
      end
    end;
  dec( ParserState.Statement )
end;

(* ParseStatementList *)
procedure ParseStatementList;
begin
  repeat ParseStatement
  until  not Next.getIf( kw_Semikolon )
end;

(* PreParseStatements *)
procedure PreParseStatements;
begin
  {$IFDEF TraceDx} TraceDx.Send( uStm, 'PreParseStatements' ); {$ENDIF}
  ForNesting := 0;
end;

end.
