
unit uDeclarations;

{$INCLUDE _CompilerOptionsRef.pas}
{$INCLUDE _CompilerOptions.pas}
{ $UNDEF TraceDx}

{ ---------------------------------------------------------------------------------------- }

interface

uses
  uGlobalsParser,
  System.Classes,
  VCL.ComCtrls,
  VCL.StdCtrls,
  System.SysUtils;

const
  cSymbolResult = 'Result';

type
  tDeklaration  = ( do_Implementation, do_Interface, do_Parameter, do_Anonym, do_Record, do_Class );

procedure ParseHintDirectives;
procedure ParseDeclarations( DeclOrt: tDeklaration; const pIdOwner: pIdInfo );
procedure ParseType( pIdOwner: pIdInfo; Anzahl: word ); forward;

{ ---------------------------------------------------------------------------------------- }

implementation

uses
  {$IFDEF TraceDx} uTraceDx, {$ENDIF}
  System.IOUtils,
  System.TypInfo,
  WinAPI.Windows,    // TDirectory.getCurrentDirectory
  VCL.Dialogs,
  System.Character,
  uGlobals,
  uExpressions, uStatements,
  uSystem, uScanner, uListen;

const
  cSymbolAnonym = '*anonymous';
  cSymbolSelf   = 'Self';

  cProcTyp      : array[boolean] of tIdType = ( id_Proc, id_Func );
  cOverFlags    = [tIdFlags.IdUnused,tIdFlags.isStatic];

type
  {$IFDEF TraceDx} uDecl = class end; {$ENDIF}
  tProcDirs     = set of ( NoBody );

var
  PosStrResult  : tIdPosInfo = ( Str : cSymbolResult );
  PosStrSelf    : tIdPosInfo = ( Str : cSymbolSelf   );
  DummyIdOver   : tIdInfo    = ( Name: 'DummyOver'; IdFlags: cOverFlags );
  UnbekanntEndeClass: pIdInfo = nil;

{ ---------------------------------------------------------------------------------------- }

(* ParseProcDirectives *)
function ParseProcDirectives: tProcDirs;     // incl Hint-Direktiven
var p, ExprType: pIdInfo;
    Pegel: tIdSeqIndex;
begin
  Result := [];
  repeat
    Next.getIf( kw_Semikolon );
    case Next.Peek of
      kw_INLINE,
      kw_LIBRARY    : Next.get;      { inline ist dummerweise Keyword, nur überlesen.    Besser: Unter Kw löschen und bei Direktive eintragen }
      kw_Identifier : {kein Keyword->evtl Direktive}
                      case NextPascalDirective( ds_PROC ) of
                        pd_NIL       : break;
                        pd_FORWARD   : begin
                                         include( Result, NoBody );
                                         include( AktDeclareOwner^.IdFlags2, tIdFlags2.IsForward )
                                       end;
                        pd_OVERLOAD  : include( AktDeclareOwner^.IdFlags, IsOverload );
                        pd_OVERRIDE  : begin
                                         include( AktDeclareOwner^.IdFlags, IsOverride );
                                         { falls overridden ein overload war braucht das overload hier nicht angegeben werden. Für REF aber doch setzen: }
                                         Pegel := IdSequenz.Pegel;
                                         p := TListen.SucheIdUnterId( AktDeclareOwner^.PrevBlock^.MyParent, AktDeclareOwner^.Hash, AktDeclareOwner^.Name, true );
                                         IdSequenz.Pegel := Pegel;
                                         if ( p <> nil ) and ( tIdFlags.IsOverload in p^.IdFlags )
                                           then include( AktDeclareOwner^.IdFlags, IsOverload )
                                       end;
                        pd_VIRTUAL   : include( AktDeclareOwner^.IdFlags, IsClassVirtual );
                        pd_STATIC    : include( AktDeclareOwner^.IdFlags, IsStatic       );
                        pd_EXTERNAL  : begin
                                         include( Result, NoBody );
                                         if not Next.getIf( kw_Semikolon ) then begin
                                           if not NextPascalDirective1NoRead( pd_NAME ) then
                                             ParseExpression( false, ExprType );             // external <id> name ... | external name ... (System.RegularExpressionAPI.pas)
                                           if NextPascalDirective( ds_NAME ) <> pd_NIL then
                                             ParseExpression( false, ExprType );
                                           if NextPascalDirective1( pd_DEPENDENCY ) then   // nur ANDROID?
                                             repeat ParseExpression( false, ExprType )
                                             until  not Next.getIf( kw_Komma );
                                           NextPascalDirective1( pd_DELAYED )
                                           end
                                       end;
                        pd_DISPID    : ParseExpression( false, ExprType );
                        pd_MESSAGE   : begin
                                         if Next.Test2( kw_Identifier, kw_Literal ) then
                                           TListen.InsertIdAc( Next.Id, nil, id_Const, ac_Read );
                                         include( AktDeclareOwner^.IdFlags2, IsMessage )
                                       end;
                        pd_DEPRECATED: Next.getIf( kw_Literal )        // siehe Gruppe dsHint, ParseHintDirectives
                        end
    else              break
    end
  until false
(*  if ( Next.Token <> kw_Semikolon ) and   { normale ProcFunc-Deklaration }
     ( Next.Peek  <> kw_Gleich    ) and   { initialisierte ProcFunc-Var}
     ( Next.Peek  <> kw_BEGIN     )       { anonyme ProcFunc als Parameter }
    then Error( er_SyntaxError, '<Direktive>' + cExpectedFound + Next.Id.Str )  // todo: Fehlermeldung ist noch falsch*)
end;

procedure ParseHintDirectives;
begin
  if Next.Token <> kw_Semikolon then    // Hint-Direktiven immer OHNE Semikolon direkt hinter der Deklaration
    repeat
      case Next.Peek of
        kw_LIBRARY    : Next.get;      { inline ist dummerweise Keyword, nur überlesen.    Besser: Unter Kw löschen und bei Direktive eintragen }
        kw_Identifier : {kein Keyword->evtl Direktive}
                        case NextPascalDirective( ds_Hint ) of
                          pd_DEPRECATED: Next.getIf( kw_Literal );
                          pd_ALIGN     : Next.Test2( kw_Literal, kw_Identifier );    // 1,2,4,8,16 sind erlaubt
                          pd_NIL       : break
                          end
        else            break
      end
    until false
end;

(* ParseType *)
procedure ParseType( pIdOwner: pIdInfo; Anzahl: word );
var i, ArrayDims,
    TypeNrSave    : word;
    IdPegel       : tIdSeqIndex;
    b             : boolean;
    SaveId        : tIdPosInfo;
    SaveHash      : tHash;
//    LastString,
    ExprType, pId : pIdInfo;

  procedure ParseHelper;
  begin
    { nur bei CLASS-Helper erlaubt: }
    if Next.getIf( kw_KlammerAuf ) then
      repeat pidOwner^.MyParent := ParseIdentifier( id_Type, false )           // Vorfahren des Helpers.
       until Next.Test2( kw_KlammerZu, kw_Komma );
    Next.Test( kw_FOR );
    include( pIdOwner^.IdFlags, tIdFlags.IsHelper );
    pId := ParseIdentifier( id_Type, false );

    pIdOwner.MyType := pId;                       // für Kompatibilität
    pIdOwner.TypeNr := pId^.TypeNr;               // für Kompatibilität

    pId := TListen.getBaseType( pId );            // helper gilt für alle aliase bis hoch zum BaseType. Nur dort vermerken
    pId^.NextHelper := pIdOwner;                  // Verweis auf Helper eintragen. Vorhandener Helper wird ggf übergebügelt

    if ParserState.Implementations then begin
      {$IFDEF TraceDx} TraceDx.Send( uDecl, 'Helper', TListen.pIdName( pIdOwner ) + ' ->', pId^.Name ); {$ENDIF}
      pIdOwner^.NextHelper := Helper.ImplHelpers;
      Helper.ImplHelpers   := pIdOwner              // diesen Helper unter Helper.ImplHelpers einketten damit er nach Ende der Unit gelöscht werden kann
      end
    else begin
      pIdOwner^.NextHelper         := pAktUnit^.MyUnit^.NextHelper;   // Helper in Interface-Sammlung einketten
      pAktUnit^.MyUnit^.NextHelper := pIdOwner
      end;

    (*while pId^.MyType <> nil do begin             // falls alias auch auf Vorgänger übertragen
      pId := pId^.MyType;
      pId^.NextHelper := pIdOwner
      end;*)
  end;

  procedure CheckOperators( pIdOwner: pIdInfo );
  { In dieser Class nach Operators suchen und ggf overload-Flag wieder löschen: }
  var IdPegel: tIdSeqIndex;
      pId    : pIdInfo;
  begin
    IdPegel := IdSequenz.Pegel;
    inc( ParserState.Statement );    // manipulieren damit overloads gesucht werden
    pId := pIdOwner^.SubBlock;
    while pId <> nil do begin
      if tIdFlags.IsOperator in pId^.IdFlags then begin
        TListen.SucheIdUnterId( pIdOwner, pId^.Hash, pId^.Name, false );
        if IdPegel = IdSequenz.Pegel - 1    //  = es gibt nur diesen einen Operator, kein overload
          then exclude( pId^.IdFlags, tIdFlags.IsOverload );
        IdSequenz.Pegel := IdPegel    // zurück
        end;
      pId := pId^.NextId
      end;
    dec( ParserState.Statement )    // zurück
  end;

(* ParseType *)
begin
  {$IFDEF TraceDx} TraceDx.Call( uDecl, 'Type', pIdOwner^.Name ); {$ENDIF}
  inc( ParserState.ParseTypeLevel );
  IdPegel := IdSequenz.Pegel;    // ab hier ggf die real generic Types
  if Next.Peek <= kw_Identifier then
    if NextPascalDirective1( pd_REFERENCE ) then begin    // todo: besser und schneller über neuen Hash abfangen
      Next.Test( kw_TO );
      ParseType( pIdOwner, Anzahl )    // jetzt kommt proc/func
      end
    else begin
      KeyWordListe[kw_Gleich ].OpPrio := cNoOp;    // "=" leitet in der Regel(!) TypedConst ein
      KeyWordListe[kw_Kleiner].OpPrio := cNoOp;    // "<" leitet GenericType ein
      ParserState.ParseNoVar := true;

      if pIdOwner^.Typ = id_Type then begin   // Korrektur 21.5.22:
        SaveHash := pIdOwner^.Hash;           // Testfall: type t = ...;   TClass = class type t = t; ... end    // letztes "t" bezieht sich auf erstes
        pIdOwner^.Hash := cNoHash;            // Aber    : TClass = class Var: TClass; ... end                   // letztes "TClass" bezieht sich auf eigenes
        end;                                  // >>> pIdOwner-Name darf noch nicht referenziert werden

      pId := ParseExpression( false, ExprType );                // Expression nur wegen SubRange!?

      if pIdOwner^.Typ = id_Type then         // Korrektur 21.5.22:
        pIdOwner^.Hash := SaveHash;           // ggf Hash wieder herstellen

      ParserState.ParseNoVar := false;
      KeyWordListe[kw_Kleiner].OpPrio := cOpPrioKlGl;
      KeyWordListe[kw_Gleich ].OpPrio := cOpPrioKlGl;

      if pId <> nil then begin
        if tIdFlags.IsGenericType in pId^.IdFlags then begin
          TListen.CopySub( pId, pIdOwner );

          if pId = pSysId[syTArray] then
            TListen.AddAc( pIdOwner^.SubBlock, nil, Next.Id.Pos, ac_Declaration );   // TArray: das [] gibt's nicht im Text, braucht aber einen Zugriff
          { Die realen Typen sind als IdSequenz hinterlegt: }
          TListen.SetRealGenericTypes( pId^.SubBlock, pIdOwner^.SubBlock, IdPegel ); // .. und DORT die Typen ersetzen:
          pId      := pIdOwner;           // falls mehrere Variablen:
          pIdOwner := pIdOwner^.NextId;   // passend vorbereiten
          dec( Anzahl )
          end
        else
          if pId = pSysId[syString] then
            { auf shortstring umändern? }
            if Next.getIf( kw_EckigeKlammerAuf ) then begin
              { bei string[ hört ParseExpression vorzeitig auf, hier weiter: }
              TListen.MoveAc( pId^.LastAc, pSysId[syShortString] );                   // ac von string -> shortstring
              TListen.AddAc( pSysId[syShortString]^.SubBlock, nil, Next.Id.Pos, ac_Read );
              TListen.CopyTypeInfos( pSysId[syShortString], pIdOwner );
              Next.Id.Str := dArraySymbol;
              TListen.InsertIdAc( Next.Id, pIdOwner, id_Var, ac_Declaration );         // [] unter Owner eintragen (nicht in CopySub passiert wegen library)
              TListen.CopyTypeInfos( pSysId[syAnsiChar], pIdOwner^.SubBlock );
              ParseExpression( false, ExprType );
              Next.Test( kw_EckigeKlammerZu );
              pId      := pIdOwner;           // falls mehrere Variablen:
              pIdOwner := pIdOwner^.NextId;   // passend vorbereiten
              dec( Anzahl )
              end
            else begin
              if not pAktUnit^.IfOptLokal[cd_LongStrings] then begin
                TListen.MoveAc( pId^.LastAc, pSysId[syShortString] );                  // ac von string -> shortstring
                TListen.CopyTypeInfos( pSysId[syShortString], pIdOwner );
                Next.Id.Str := dArraySymbol;
                TListen.InsertId( Next.Id.Str, pIdOwner, id_Var, false );  // [] unter shortstring eintragen
                TListen.CopyTypeInfos( pSysId[syAnsiChar], pIdOwner^.SubBlock );
                pId      := pIdOwner;           // falls mehrere Variablen:
                pIdOwner := pIdOwner^.NextId;   // passend vorbereiten
                dec( Anzahl )
                end
              end
        else begin
          if pId^.Typ = id_Unbekannt then
            TListen.ChangeIdType( pId, id_Type );

          { Test auf Sonderfall, siehe Deklaration IsEnumCopy: }
          if ( pIdOwner^.Typ = id_Type ) and ( pId^.SubBlock <> nil ) and ( pId^.SubBlock^.Typ = id_EnumConst ) then
            include( pIdOwner^.IdFlags, tIdFlags.IsEnumCopy )
          end
        end;

      { Typ auf die deklarierten IDs kopieren }
      if pId = nil then begin
        if ExprType <> nil then begin
          for i := 1 to Anzahl do begin               // SubRange-Typ:
            TListen.CopyTypeInfos( ExprType, pIdOwner );
            pIdOwner := pIdOwner^.NextId
            end
          end
        end
      else
        for i := 1 to Anzahl do begin              // alle anderen (also per Id referenzierten) Typen
          TListen.CopySub( pId, pIdOwner );
          pIdOwner := pIdOwner^.NextId
          end
      end
  else begin
    case Next.get of
      kw_Minus, kw_Plus: begin
        { SubRange kann auch mit + oder - anfangen. NOT und "(" ist nicht erlaubt: }
        KeyWordListe[kw_Gleich].OpPrio := cNoOp;            // "=" leitet in der Regel(!) TypedConst ein
        ParseExpression( false, ExprType );                // SubRange!
        KeyWordListe[kw_Gleich].OpPrio := cOpPrioKlGl;       // restaurieren
        if ExprType <> nil then begin
          for i := 1 to Anzahl do begin              // SubRange-Typ
            TListen.CopyTypeInfos( ExprType, pIdOwner );
            pIdOwner := pIdOwner^.NextId
            end
          end;
        dec( ParserState.ParseTypeLevel );
        exit
        end;
      kw_INTERFACE, kw_DISPINTERFACE: begin
        pIdOwner^.IdFlags := pIdOwner^.IdFlags + [tidFlags.NoCopy, tidFlags.IsInterface];
        if Next.Peek = kw_Semikolon then
          include( pIdOwner^.IdFlags2, tidFlags2.IsForward )
        else begin             // sonst forward
          TListen.EnterBlock( pIdOwner );
          inc( ParserState.RecordLevel );
          if Next.getIf( kw_KlammerAuf ) then
            repeat
              pId := ParseIdentifier( id_Type, false );
              include( pId^.IdFlags, IsInterface )
            until Next.Test2( kw_KlammerZu, kw_Komma );
//          LastString := MainBlock[mbConstStrings].SubLast;  // hier schon merken für GUID wegen preFetch -> gestrichen weil GUID sind strings!
          if Next.getIf( kw_EckigeKlammerAuf ) then begin   // [Interface-GUID]
            if FileOptions.RegKeySymbols then
              TListen.MoveAc( KeywordListe[kw_EckigeKlammerAuf].LastAc, @KeywordListe[kw_EckigeKlammerAuf_GUID  ] );
            if Next.getIf( kw_Literal ) then
//              if ( LastString <> nil ) and ( LastString^.AcList = LastString^.LastAc )
//                then TListen.MoveGUID( LastString )                                        // String kommt das erste Mal vor. So SOLL es sein!
//                else TListen.InsertIdAc( Next.Id, @MainBlock[mbGUID], id_Const, ac_Read ) // zusätzlich unter GUIDs einhängen
            else
              ParseIdentifier( id_Unbekannt, false );
            Next.Test( kw_EckigeKlammerZu )
            end;
          if Next.Peek <> kw_END then
            ParseDeclarations( do_Class, pIdOwner );
          Next.getIf( kw_END );
          dec( ParserState.RecordLevel );
          TListen.LeaveBlock
          end;
        pIdOwner^.TypeGroup := coInterf;
//        pIdOwner^.IdFlags := pIdOwner^.IdFlags + [tidFlags.NoCopy, tidFlags.IsInterface] // nach oben???
        end;
      kw_CLASS, kw_OBJECT: begin
        pIdOwner^.IdFlags := pIdOwner^.IdFlags + [tidFlags.NoCopy, tidFlags.IsClassType];
        b := Next.Token = kw_CLASS;
        if Next.Peek = kw_Semikolon then
          include( pIdOwner^.IdFlags2, tIdFlags2.IsForward )
        else begin                // sonst forward
          TListen.EnterBlock( pIdOwner );
          if Next.getIf( kw_OF ) then begin
            pId := ParseIdentifier( id_Type, false );
            TListen.CopyTypeInfos( pId, pIdOwner )
            end
          else begin
            if NextPascalDirective1( pd_HELPER ) then
              ParseHelper
            else begin
              if Next.Peek = kw_Identifier then NextPascalDirective( ds_ABSTRACT );
              if Next.getIf( kw_KlammerAuf ) then begin
                pidOwner^.MyParent := ParseIdentifier( id_Type, false );
                if pIdOwner^.MyParent <> pSysId[syObject] then
                  TListen.SetIdTypeClass( pidOwner^.MyParent );                // nicht "TObject^.MyParent := TObject" setzen

                { Sonderfall:   type Tabc    = class...
                                     Tabc<T> = class( Tabc ) }
                    if pIdOwner = pIdOwner^.MyParent then
                      pIdOwner^.MyParent := nil;            // weil Tabc zur Zeit der gleiche Id ist wie Tabc<T>

                while Next.Test2( kw_Komma, kw_KlammerZu ) do begin
                  pId := ParseIdentifier( id_Type, false );                    // alle weiteren sind Interfaces
                  pId^.TypeGroup := coInterf;
                  pId^.IdFlags := pId^.IdFlags + [tidFlags.NoCopy, tidFlags.IsInterface]
                  end
                end
              else
                if b then pidOwner^.MyParent := pSysId[syObject];    // kein Parent angegegeben -> TObject
              end;

            inc( ParserState.RecordLevel );
            if ( Next.Peek <> kw_END ) and ( Next.Peek <> kw_Semikolon ) then begin
              if UnbekanntEndeClass = nil then begin
                UnbekanntEndeClass := MainBlock[mbUnDeclaredUnScoped].SubLast;    // damit nur der neueste Unbekannt-Teil durchsucht werden muss
                ParseDeclarations( do_Class, pIdOwner );
                UnbekanntEndeClass := nil
                end
              else
                ParseDeclarations( do_Class, pIdOwner )   // class in class
              end;
            CheckOperators( pIdOwner );
            Next.getIf( kw_END );

            if tIdFlags.IsHelper in pIdOwner^.IdFlags then
              TListen.InsertVirtualId( pIdOwner^.MyType, pIdOwner );     // Helper zeigt auf HelpedType weil er auf dessen Felder zugreifen kann

            dec( ParserState.RecordLevel )
            end;
          TListen.LeaveBlock
          end;
        pIdOwner^.TypeGroup := coClass
        end;
      kw_RECORD: begin
        pIdOwner^.TypeGroup := coRecord;
        if NextPascalDirective1( pd_HELPER )
          then ParseHelper;
        inc( ParserState.RecordLevel );
        TListen.EnterBlock( pIdOwner );
        ParseDeclarations( do_Record, pIdOwner );
        CheckOperators( pIdOwner );
        Next.Test( kw_END );

        if ( tIdFlags.IsHelper in pIdOwner^.IdFlags ) and ( pIdOwner^.MyType^.SubBlock <> nil {für flache Typen nicht notwendig}) then
          TListen.InsertVirtualId( pIdOwner^.MyType, pIdOwner );     // Helper zeigt auf HelpedType weil er auf dessen Felder zugreifen kann

        TListen.LeaveBlock;
        dec( ParserState.RecordLevel )
        end;
      kw_ARRAY: begin
        inc( ParserState.RecordLevel );
        if Next.getIf( kw_EckigeKlammerAuf ) then begin
          pIdOwner^.TypeGroup := coArray;
          ArrayDims := 0;
          pId := pIdOwner;
          repeat
            inc( ArrayDims );
            TListen.EnterBlock( pId );
            Next.Id.Str := dArraySymbol;
            pId := TListen.InsertIdAc( Next.Id, pId, id_Var, ac_Declaration );
            ParseExpression( false, ExprType )        // statt ParseType, um CopySub mit Flag- und MyType-Kopie zu vermeiden
          until  Next.Test2( kw_EckigeKlammerZu, kw_Komma )
          end
        else begin   { offenes Array: }
          DummyIdArrayOf.TypeNr := pIdOwner^.TypeNr;    // übernehmen
          TListen.CopyTypeInfos( @DummyIdArrayOf, pIdOwner );
          ArrayDims := 1;
//          include( pIdOwner^.IdFlags, tIdFlags.IsClassType );
          TListen.EnterBlock (pIdOwner);
          Next.Id.Str := dArraySymbol;
          pId := TListen.InsertIdAc( Next.Id, pIdOwner, id_Var, ac_Declaration )
          end;
        Next.Test( kw_OF );
        if Next.getIf( kw_CONST ) then begin
          TListen.ChangeIdType( pId, id_Const );
          pIdOwner^.TypeGroup := coSet;
          pIdOwner^.TypeNr    := cEmptySet           // damit kompatibel zum aktuellen Parameter
          end
        else
          ParseType( pId, 1 );
        for i := 1 to ArrayDims do TListen.LeaveBlock;
        dec( ParserState.RecordLevel )
        end;
      kw_PACKED:
        ParseType( pIdOwner, Anzahl );
      kw_TYPE: begin
        TypeNrSave := pIdOwner^.TypeNr;
        pId := ParseIdentifier( id_Type, false );
        TListen.CopySub( pId, pIdOwner );
        if pIdOwner^.TypeGroup <> coEnum then
          pIdOwner^.TypeNr := TypeNrSave;         // neuer Typ ist NICHT kompatibel. Ausser wenn ENUM, sonst passen die Enum-Consts nicht
//        exclude( pIdOwner^.IdFlags, IsHelper );   // ggf löschen
        pIdOwner^.NextHelper := nil               // und den auch nicht übernehmen
        end;
      kw_Pointer: begin
        include( pIdOwner^.IdFlags, IsPointer );
        pIdOwner^.TypeGroup := coPtr;
//        if pIdOwner^.Typ <> id_Type then pIdOwner^.MyType := pSysId[syPointer];
        TListen.EnterBlock( pIdOwner );
        pId := TListen.InsertIdAc( Next.Id, pIdOwner, id_Var, ac_Declaration );
        Next.Test( kw_Identifier );
        TListen.CopyTypeInfos( TListen.InsertIdAc( Next.Id, nil, id_Type, ac_Read ), pId );
//      falls auch p = ^Unit.Type vorkommen ( ist aber nicht erlaubt! ) kann stattdessen:
//        TListen.CopyTypeInfos( ParseExpression( false, ExprType ), pId );

        if ( Next.Id.Pos.Datei = pId^.LastAc^.Position.Datei ) and ( Next.Id.Pos.Zeile = pId^.LastAc^.Position.Zeile ) then
          { Next.Id auf folgendes Symbol verlängern weil ^ sonst kaum erkennbar, rein visuell: }
          pId^.LastAc^.Position.Laenge := Next.Id.Pos.Laenge + Next.Id.Pos.Spalte - pId^.LastAc^.Position.Spalte;
        TListen.LeaveBlock
        end;

      kw_KlammerAuf: begin                 // TEnum = (c1, c2, c3)
        include( pIdOwner^.IdFlags, tidFlags.NoCopy );
        TListen.EnterBlock( pIdOwner );
        if not pAktUnit^.IfOptLokal[cd_ScopedEnums] then
          TListen.InsertVirtualEnum( pIdOwner );

        if pIdOwner^.Typ = id_Type
          then inc( TypeCount, cSetInc )                 // einen für zugehörigen set freihalten
          else pIdOwner^.TypeNr := TListen.GetTypeNr;    // Enum hat keinen TypeDef: jetzt eine Nummer für enums und vars holen
        pIdOwner^.TypeGroup := coEnum;

        repeat
          Next.Test( kw_Identifier );
          { wenn Enums in einer Record-Variablen deklariert werden landen sie ausserhalb aller umgebenden Records und Arrays (AktDeclOwnerEnum): }
          pId := TListen.InsertIdAc( Next.Id, pIdOwner, id_EnumConst, ac_Declaration );
          TListen.CopyTypeInfos( pIdOwner, pId );
          if Next.getIf( kw_Gleich ) then
            ParseExpression( false, ExprType );    // EnumConst bekommt konkrete Ordinalzahl zugewiesen
          if not pAktUnit^.IfOptLokal[cd_ScopedEnums] and ( InterfaceSection in pIdOwner^.IdFlags2 ) then
            include( pId^.IdFlags2, InterfaceSection )
        until Next.Test2( kw_KlammerZu, kw_Komma );

//        pIdOwner^.MyType := nil;
        TListen.LeaveBlock
        end;

      kw_SET: begin
        Next.Test( kw_OF );
        ParseType( pIdOwner, Anzahl );
        pIdOwner^.TypeNr    := GetTypeNrOfSet( pIdOwner );
        pIdOwner^.MyType    := nil;
        pIdOwner^.TypeGroup := coSet
        end;
      kw_FILE: begin
        if Next.getIf( kw_OF ) then
          ParseType( pIdOwner, Anzahl );
        TListen.CopyTypeInfos( @DummyIdFile, pIdOwner )      // Basistyp gilt nicht für pIdOwner
        end;
      kw_PROCEDURE, kw_FUNCTION: begin
        TListen.EnterBlock( pIdOwner );
        if Next.getIf( kw_KlammerAuf ) then begin
//          AktDeclareOwner := AktDeclareOwner^.PrevBlock;
          ParseDeclarations( do_Parameter, pIdOwner );
//          AktDeclareOwner := pIdOwner;
          Next.Test( kw_KlammerZu );
          pId := AktDeclareOwner^.SubBlock;
          while pId <> nil do begin
            if not ( tIdFlags.IsGenericDummy in pId^.IdFlags ) then
              include( pId^.IdFlags, tIdFlags.IsDummy );
            pId := pId^.NextId
            end;
          end;
        if Next.getIf( kw_Doppelpunkt ) then
          ParseIdentifier( id_Type, false );        // da hier nicht CopySub-kopiert werden muss reicht ParseIdentifier
        if Next.getIf( kw_OF ) then  // Instanz-Prozeduren
          Next.Test( kw_OBJECT );
        ParseProcDirectives;   // Pascal-Direktiven
        TListen.LeaveBlock;
        include( pIdOwner^.IdFlags, tidFlags.NoCopy );     // jetzt erst, weil bei function sonst im ParseType->copySub überschrieben
        pIdOwner^.TypeGroup := coMethod
//        pIdOwner^.SubBlock := nil;        // ALLE Deklarationen wegschmeißen
//        while NextPascalDirective( ds_STDCALL ) = pd_STDCALL do;          ???   wo gibt's das ???
        //while Next.PeekGet( kw_Semikolon ) and ( NextPascalDirective( ds_PROC ) <> pd_KeinePascalDirektive ) do
        end
      else
        Error( errSyntaxError, '<Type-Declaration>', Next.Id.Str )
      end;
    { bin noch im ELSE-Zweig, also für alle Nicht-Identifier: }
    pId := pIdOwner^.NextId;     // siehe if-start
    for i := 2 to Anzahl do begin
      TListen.CopySub( pIdOwner, pId );
      pId := pId^.NextId
      end
    end;
  IdSequenz.Pegel := IdPegel;
  dec( ParserState.ParseTypeLevel )
end;

(* ParseDeclarations *)
procedure ParseDeclarations( DeclOrt: tDeklaration; const pIdOwner: pIdInfo );
type
  tVisibility             = ( visPUBLIC, visPRIVATE, visPROTECTED );
var
  DeclTyp                 : tKeyWord;
  CasedRecord, CasedConst,
  kwx_Operator, kwx_Out,
  pd_Moeglich,
  ClassDecl,Weiter, Strct : boolean;
  Visibility              : tVisibility;
  MerkAc                  : pAcInfo;
  UnbekanntEndeType,
  pIdTemp,
  pIdCase, pIdResultUnsafe: pIdInfo;

  (* ParseDeclaration *)
  procedure ParseDeclaration( const pIdOwner: pIdInfo );
  const cVarProp: array[boolean] of tIdType = ( id_Var, id_Property );
        cAcType : array[boolean] of tAcType = ( ac_Declaration, ac_Read );
        cIfcFlag: array[boolean] of set of tIdFlags2 = ( [], [InterfaceSection] );
  var PosStr              : tIdPosInfo;
      ProcDirektiven      : tProcDirs;
      AnzahlClass, i      : integer;
      AnzahlVar, Anzahl   : word;
      Qualified,
      Write               : boolean;
      IdSeq               : tIdSeqIndex;
      pIdOverload,
      ExprType, pIdSelf,
      pIdLokal, //pIdClass,
      pId, pIdDecl        : pIdInfo;
      GenPos              : array[0..11] of tIdPosInfo;
      GenPosNext          : word;
      SaveHash            : tHash;
      TmpId               : tIdInfo;
      AltTypeNr           : tTypeNr;

  procedure SetClassVisibility( b: boolean; pId: pIdInfo );
    begin
      if Visibility <> visPUBLIC then
          if Visibility = visPROTECTED
              then  include( pId^.IdFlags, tIdFlags.IsProtected )
              else  include( pId^.IdFlags, tIdFlags.IsPrivate   );
      if b then include( pId^.IdFlags, tIdFlags.isClassVar );
      if Strct then include( pId^.IdFlags, tIdFlags.IsStrict )
    end;

  procedure ParseIdList( IdTyp: tIdType );
      function DeclareNext: pIdInfo;
      begin
      Next.Test( kw_Identifier );
      Result := TListen.InsertIdAc( Next.Id, pIdOwner, IdTyp, ac_Declaration );
      if DeclOrt = do_Parameter then
        if DeclTyp = kw_Var then
          if kwx_Out
            then Result^.IdFlags := Result^.IdFlags + [tIdFlags.IsParameter, tIdFlags.IsWriteParam, tIdFlags.IsOutParam]
            else Result^.IdFlags := Result^.IdFlags + [tIdFlags.IsParameter, tIdFlags.IsWriteParam                     ]
        else
          Result^.IdFlags := Result^.IdFlags + [tIdFlags.IsParameter];
      if DeclOrt = do_Interface then
        include( Result^.IdFlags2, InterfaceSection );
      SetClassVisibility( ClassDecl, Result )
      end;
    begin
      AnzahlVar := 1;   // in Parametern kann "const a,b: integer" vorkommen
      pIdDecl := DeclareNext;
      while Next.getIf( kw_Komma ) do begin
        DeclareNext;
        inc( AnzahlVar )
        end
    end;

  (* ParseTypedConstUnknown *)
  procedure ParseTypedConstUnknown( pId: pIdInfo );                 // todo: etwas intelligenter machen, acs für SubVars
  var Kl: word;    // KlammerEbene
      pIdTypedConst: pIdInfo;
  begin
    Kl := 0;
    repeat case Next.get of
             kw_KlammerAuf: inc( Kl );
             kw_KlammerZu : dec( Kl );
             kw_Identifier: if Next.Peek <> kw_Doppelpunkt then begin
                              pIdTypedConst := TListen.InsertIdAc( Next.Id, nil, id_Unbekannt, ac_Read );
                              if Next.Peek = kw_Punkt then
                                ParseIdentifier( id_Unbekannt, false, pIdTypedConst )
                              end
             end
    until Kl = 0
  end;

  (* ParseTypedConst *)    // nicht benutzt weil der Vorteil nur die vielen Record-Namen wären
  procedure xParseTypedConst( const pIdTopOwner: pIdInfo );
  const cIdTyp     : array[boolean] of tIdType = ( id_Var  , id_Const );
        cAcTyp     : array[boolean] of tAcType = ( ac_Write, ac_Read  );
  var   idConstVar : tIdType;
        acReadWrite: tAcType;

    (* ParseTypedConstSub *)
    function ParseTypedConstSub( pIdOwner: pIdInfo ): boolean;    // true = Array
    var pIdSub: pIdInfo;
    begin
      {$IFDEF TraceDx} TraceDx.Call( uDecl, 'ParseTypedConstSub', pIdOwner^.Name ); {$ENDIF}

      if Next.getIf( kw_KlammerAuf ) then
        if pIdOwner^.SubBlock = nil then
          {if pIdOwner^.Typ = id_Unbekannt
            then} ParseTypedConstUnknown( pIdOwner )
            {else ParseExpression( false, ExprType )}
        else begin
//          if pIdOwner <> pIdTopOwner then
//            TListen.AddAc( pIdOwner^.SubBlock, nil, Next.Id.Pos, acReadWrite );         // KlammerAuf

          if pIdOwner^.SubBlock^.Name = dArraySymbol then
            repeat ParseTypedConstSub( pIdOwner^.SubBlock )
            until  Next.Test2( kw_KlammerZu, kw_Komma )

          else
            repeat if Next.getIf( kw_Identifier ) then begin
                     pIdSub := TListen.InsertIdAc( Next.Id, pIdOwner, idConstVar, acReadWrite );
                     Next.Test( kw_Doppelpunkt );
                     ParseTypedConstSub( pIdSub )
                     end
            until  Next.Test2( kw_KlammerZu, kw_Semikolon )

          end
      else
        ParseExpression( false, ExprType )
    end;

  begin
  idConstVar  := cIdTyp[pIdTopOwner^.Typ = id_Const];   // idConst bei const, idVar   bei var und unbekannt
  acReadWrite := cAcTyp[idConstVar       = id_Const];   // acRead  bei const, acWrite bei var und unbekannt
  TListen.EnterBlock( pIdTopOwner );                    // OpenBlock falls SubBlock sicher existiert
  ParseTypedConstSub( pIdTopOwner );
  TListen.LeaveBlock
  end;

  (* ParseDeclaration *)
  begin
    {$IFDEF TraceDx} TraceDx.Call( uDecl, 'Declaration', pIdOwner^.Name ); {$ENDIF}
    pIdDecl := pIdOwner;
    case DeclTyp of
      {  LABEL  }
      kw_LABEL:
        repeat
          if Next.Test2( kw_Literal, kw_Identifier ) then
            TListen.DeleteAc( LastLiteral^.LastAc, true );    //  Literal NUR unter Block eintragen, unter Const wieder löschen
          TListen.InsertIdAc( Next.Id, pIdOwner, id_Label, ac_Declaration )^.IdFlags2 := cIfcFlag[DeclOrt = do_Interface]
        until Next.Test2( kw_Semikolon, kw_Komma );
      {  CONST  RESOURCESTRING  }
      kw_CONST, kw_RESOURCESTRING: begin
        ParseIdList( id_Const );

        // Korrektur 21.5.22:
        SaveHash := pIdDecl^.Hash;               // Testfall: const c = ...;   TClass = class const c = c; ... end    // letztes "c" bezieht sich auf erstes
        if AktDeclareOwner^.Typ = id_Type then   // siehe Verifikation\Consts.pas: innerhalb Type KEIN Selbst-Bezug
          pIdDecl^.Hash := cNoHash;              // Problem : c: T = sizeOf(c)                                        // c bezieht sich auf eigenes (geht im Compiler weil sizeof sich auf Typ bezieht)

        //        SetClassVisibility( false{DeclOrt in [do_Record, do_Class]}, pIdDecl );   // nochmal wegen allgemeinerer Bedingung
        if Next.getIf( kw_Doppelpunkt ) then begin    // Typed Const
          ParserState.TypeId_Needed := ( DeclOrt = do_Parameter ) and ( Next.Peek = kw_Identifier {nicht ARRAY oder PROC} );
          ParseType( pIdDecl, AnzahlVar );
          ParserState.TypeId_Needed := false;
          if ( pIdDecl^.SubBlock <> nil ) and ( pIdDecl^.SubBlock^.AcList = pIdDecl^.SubBlock^.LastAc ) { nur beim ersten Mal } then begin
            pIdLokal := pIdDecl;
            for i := 1 to AnzahlVar do begin
              TListen.SetSubConst( pIdLokal );   // alle Subs sind auch const
              pIdLokal := pIdLokal^.NextId
              end
            end;
          if Next.getIf( kw_Gleich ) then begin
            if DeclOrt = do_Parameter then                           // Parameter als optional kennzeichnen
              include( pIdDecl^.IdFlags, tIdFlags.optionalPara );   // kann nur einer sein
            if Next.Peek = kw_KlammerAuf
              then ParseTypedConstUnknown( pIdDecl )
              else ParseExpression( false, ExprType )
            end
          end
        else
          if Next.getIf( kw_Gleich ) then begin
            ParseExpression( false, ExprType );
            TListen.CopyTypeInfos( ExprType, pIdDecl )
            end;
        // Korrektur 21.5.22:
        pIdDecl^.Hash := SaveHash;           // ggf Hash wieder herstellen

        ParseHintDirectives
        end;
      {  TYPE  }
      kw_TYPE: begin
        ParserState.DeclareType := true;
        Next.Test( kw_Identifier );           // hier kann nur einer stehen

        { Generic type formal Type:                  type TSampleClass <T> }
        if Next.Peek = kw_Kleiner then begin
          if FileOptions.RegKeySymbols then
            TListen.MoveAc( KeywordListe[kw_Kleiner].LastAc, @KeywordListe[kw_Kleiner_GenTypeDef] );
          Next.Id.Str := Next.Id.Str + cGenericDummy;   // Vorbereitung für generic
          pIdDecl := TListen.InsertIdAc( Next.Id, pIdOwner, id_Type, ac_Declaration );
          Next.get;   // kw_Kleiner_Generic
          TListen.EnterBlock( pIdDecl );
          AnzahlVar := 0;
          repeat Next.Test( kw_Identifier );           // hier kann nur einer stehen
                 inc( AnzahlVar );
                 pId := TListen.InsertIdAc( Next.Id, pIdDecl, id_Type, ac_Declaration );
                 include( pId^.IdFlags, IsGenericDummy );
                 if Next.getIf( kw_Doppelpunkt ) then          // Constraint, Zusicherung an Generic-Type
                   repeat
                     if Next.Peek = kw_Identifier then begin
                       pId^.MyType := ParseIdentifier( id_Type, false );
                       pId^.TypeNr := pId^.MyType^.TypeNr
                       end
                     else
                       case Next.get of
                         kw_CLASS,
                         kw_CONSTRUCTOR: begin
                                           pId^.MyType  := pSysId[syObject];
                                           pId^.TypeNr  := pId^.MyType^.TypeNr;
                                           pId^.IdFlags := pId^.IdFlags + [tIdFlags.NoCopy, tIdFlags.IsClassType]
                                         end;
                         kw_RECORD     : ;
                       else              Error( errSyntaxError, 'CLASS', Next.Id.Str )
                       end
                   until not Next.getIf( kw_Komma )
           until Next.Test3( kw_Groesser, kw_Komma, kw_Semikolon ) = kw_Groesser;
          TListen.SetIdGeneric( pIdDecl, AnzahlVar );
          TListen.LeaveBlock
          end
        else   { normal eintragen: }
          pIdDecl := TListen.InsertIdAc( Next.Id, pIdOwner, id_Type, ac_Declaration );

        if DeclOrt = do_Interface then
          include( pidDecl^.IdFlags2, InterfaceSection );
        SetClassVisibility( false{DeclOrt in [do_Record, do_Class]}, pIdDecl );

        Next.Test( kw_Gleich );
        ParserState.DeclareType := false;
        AltTypeNr := pIdDecl^.TypeNr;            // diese hatte der neue Typ präventiv erhalten

        ParseType( pIdDecl, 1 );               // Der gerade deklarierte Typname darf innerhalb der

        if ( pIdDecl^.TypeNr < AltTypeNr ) {kein neuer Typ sondern alias}
          then dec( TypeCount );                // Nummern sparen

        if pIdDecl^.Typ <> id_Unbekannt then
          TListen.TestIdForUnbekannt( pIdDecl, UnbekanntEndeType );
        ParseHintDirectives
        end;
      {  VAR  kw_THREADVAR  kw_PROPERTY  kw_NOT  }
      kw_VAR, kw_THREADVAR, kw_PROPERTY, kw_NOT: begin
        ParseIdList( cVarProp[DeclTyp = kw_PROPERTY] );
        pIdLokal := pIdDecl;
        Anzahl   := 0;    // EnterBlocks bei Array-Eigenschaften zählen
        if ( DeclTyp = kw_PROPERTY ) and Next.getIf( kw_EckigeKlammerAuf ) then begin
          { Array-Eigenschaft }
          repeat
            repeat
              TListen.EnterBlock( pIdLokal );
              inc( Anzahl );
              Next.Id.Str := dArraySymbol;
              pIdLokal := TListen.InsertIdAc( Next.Id, pIdLokal, id_Property, ac_Declaration );
              if Next.getIf( kw_CONST ) or Next.getIf( kw_VAR ) or
                 ( ( Next.Peek = kw_Identifier ) and NextPascalDirective1( pd_OUT ) ) then;
              Next.Test( kw_Identifier );
              AktDeclareOwner := pIdDecl;                // InsertIdAc soll zum AktDeclareOwner passen
              include( TListen.InsertIdAc( Next.Id, pIdDecl, Id_Var, ac_Declaration )^.IdFlags, tIdFlags.IsDummy );   // diese Var nie finden
              AktDeclareOwner := pIdLokal^.PrevBlock     // ... und zurück
            until not Next.getIf( kw_Komma );
            if Next.getIf( kw_Doppelpunkt ) then
              ParseType( pIdDecl^.SubBlock^.NextId, Anzahl )

          until Next.Test2( kw_EckigeKlammerZu, kw_Semikolon )
          end;

        if Next.getIf( kw_Doppelpunkt ) then begin
          { Hier wird der Typ der Variablen gelesen: }
          ParserState.TypeId_Needed := ( DeclOrt = do_Parameter ) and ( Next.Peek = kw_Identifier {nicht ARRAY oder PROC} );
          ParseType( pIdLokal, AnzahlVar );
          ParserState.TypeId_Needed := false;
          {$IFDEF TestKompatibel}   // nur notwendig wenn Typ-Prüfung stattfindet, für Funktion irrelevant
          { falls mehrere Variablen eines Direkt-Typs: Typnummer vergeben und verteilen: }
          if ( AnzahlVar > 1 ) and ( pIdLokal^.TypeNr = cNoTypeNr ) then begin
            pIdLokal^.TypeNr := TListen.GetTypeNr;
            pId := pIdLokal^.NextId;
            for i := 2 to AnzahlVar do begin pId^.TypeNr := pIdLokal^.TypeNr; pId := pId^.NextId end
            end;
          {$ENDIF}
          for i := 1 to Anzahl do TListen.LeaveBlock;

          if DeclTyp <> kw_PROPERTY then
            ParseHintDirectives;    // für normale Variablen kommt Hint-Direktive VOR dem "="

          if Next.getIf( kw_Gleich ) then begin
            TListen.AddAc( pIdDecl, nil, Next.Id.Pos, ac_Write );
            if DeclOrt = do_Parameter then                             // Parameter als optional kennzeichnen
                include( pIdDecl^.IdFlags, tIdFlags.optionalPara );   // kann nur einer sein
            if Next.Peek = kw_KlammerAuf then begin
//              allen Subs einen acWrite anhängen, ähnlich wie TListen.SetSubConst()
              ParseTypedConstUnknown( pIdDecl );
              end
            else begin
              include( pIdDecl^.LastAc^.AcFlags, DontFind );   // das wird in ParseTypedConst nicht getan
              ParseExpression( false, ExprType )
              end
            end
          else
            if NextPascalDirective1( pd_ABSOLUTE ) then begin
              KeyWordListe[kw_Doppelpunkt].OpPrio := cOpPrioDPkt;    // für TURBO Seg:Ofs
              ParseExpression( false, ExprType );
              KeyWordListe[kw_Doppelpunkt].OpPrio := cNoOp
              end
          end
        else
          if DeclTyp = kw_PROPERTY then
            { property ohne Typ übernimmt den Typ vom Parent: }
            if pIdOwner^.MyParent <> nil then begin
              {$IFDEF TraceDx} TraceDx.Send( uDecl, 'Property-Type übernehmen', pIdOwner^.MyParent^.Name ); {$ENDIF}
              SaveHash := pIdLokal^.Hash;   // die Suche muss unter Owner (statt eigentlich Parent) beginnen damit Visibility "Protected" passt
              pIdLokal^.Hash := cNoHash;    // dafür den Hash unter Owner kaputt machen damit im Parent weitergesucht wird
              pId := TListen.SucheIdUnterId( pIdOwner, pIdLokal^.Hash, pIdLokal^.Name, true );    // IdPegel bleibt unverändert im property
              pIdLokal^.Hash := SaveHash;
              if pId <> nil then
                TListen.CopyVarTypeInfos( pId, pIdLokal )
              end;

        if DeclTyp = kw_PROPERTY then begin
          while Next.Peek = kw_Identifier{kein Keyword->evtl Direktive} do
            case NextPascalDirective( ds_PROPERTY ) of
             pd_READ,
             pd_WRITE     : begin
                              Write := Next.Id.Pos.Laenge = 5;
                              { normalerweise werden overloads nur in Statements zugeordnet. Hier ausnahmsweise auch: }
                              ParserState.PropReadWrite := true;    // siehe SucheIdUnterId
                              IdSeq                     := IdSequenz.Pegel;
                              pIdLokal := ParseIdentifier( id_Unbekannt, false, nil );
                              IdSequenz.Pegel           := IdSeq;
                              ParserState.PropReadWrite := false;
                              { Read und Write in Class-Deklarationen: Falls nicht in eigener CLASS gefunden in Vorfahren suchen:
                              if ( pIdLokal^.PrevBlock <> pIdOwner ) and ( pIdDecl^.PrevBlock^.MyParent <> nil ) then begin
                                pId := TListen.SucheIdUnterId( pIdDecl^.PrevBlock^.MyParent, cNoHash, Next.id.Str, true );
                                if pId <> nil then
                                  TListen.MoveAc( pIdLokal^.LastAc, pId )
                                end; }
                              if Write and ( pIdLokal^.Typ = id_Var ) then
                                TListen.ChangeAcType( pIdLokal^.LastAc, ac_Write )
                            end;
             pd_DISPID,
             pd_INDEX,
             pd_STORED    : ParseExpression( false, ExprType );
             pd_DEFAULT   : begin
                              PosStr := Next.Id;
                              PosStr.Str := pidDecl^.Name;
                              ParseExpression( false, ExprType );
                              TListen.InsertIdAc( PosStr, AktDeclareOwner, id_Unbekannt, ac_Write )
                            end;
             pd_READONLY,
             pd_WRITEONLY,
             pd_NODEFAULT : ;
             pd_IMPLEMENTS: repeat ParseIdentifier( id_Type, false )
                              until not Next.getIf( kw_Komma )
             end;
          { ein anschließendes DEFAULT nach Semikolon definiert die Standard-Eigenschaft (immer ein ARRAY !!!) des Objektes: }
          if Next.getIf( kw_Semikolon ) and ( Next.Peek = kw_Identifier ) and NextPascalDirective1( pd_DEFAULT ) then begin
            include( pIdDecl^.SubBlock^.IdFlags, tIdFlags.IsDefaultArr );
            TListen.InsertVirtualId( pIdDecl, pIdDecl^.PrevBlock )
            end
          end;
        ParseHintDirectives
        end;
      {  PROCEDURE  kw_FUNCTION  kw_CONSTRUCTOR  kw_DESTRUCTOR  }
      kw_PROCEDURE, kw_FUNCTION{auch Operator}, kw_CONSTRUCTOR, kw_DESTRUCTOR: begin
        pIdSelf     := nil;   // nur gegen Compiler Warnung
        pIdOverload := nil;
        pIdLokal    := nil;
        AnzahlClass := 0;
        case DeclOrt of
          do_Anonym: begin
            GenPosNext  := 0;
            AnzahlClass := 1;
            Next.Id.Str := cSymbolAnonym;
            pIdDecl := TListen.InsertIdAc( Next.Id, pIdOwner, cProcTyp[( DeclTyp in [kw_FUNCTION, kw_CONSTRUCTOR] )], ac_Declaration );
            TListen.EnterBlock( pIdDecl );
            Include( pIdDecl^.        IdFlags , tIdFlags .IsDummy  );    // falls mehrere: nicht finden sondern immer neu anlegen
            Include( pIdDecl^.        IdFlags2, tIdFlags2.IsAnonym );
            Include( pIdDecl^.LastAc^.AcFlags , tAcFlags .DontFind )     // nicht finden
            end;

          do_Interface, do_Class, do_Record, do_Parameter: begin
            { Namens-Qualifizierungen können vorkommen, siehe Interfaces.pas }
//          assert ( AcSequenz.Pegel = 0, AcSequenz.Pegel.ToString );    auskommentiert wegen Verifikation->anonym.pas
            Qualified := false;
            repeat
              Next.Test( kw_Identifier );
              inc( AnzahlClass );
              PosStr := Next.Id;                // jetzigen Id merken weil Next durch generics evtl verpfuscht wird
              GenPosNext := 0;

              if kwx_Operator {and ( Next.Peek = kw_KlammerAuf )} { Operator hat immer Parameter und kann kein generic sein} then
                PosStr.Str := PosStr.Str + cSymbolOp;

              if Next.getIf( kw_Kleiner ) then begin
                if FileOptions.RegKeySymbols then
                  TListen.MoveAc( KeywordListe[kw_Kleiner].LastAc, @KeywordListe[kw_Kleiner_GenMethodDef] );
                repeat Next.Test( kw_Identifier );
                       GenPos[GenPosNext] := Next.Id;
                       inc( GenPosNext );
                       if Next.getIf( kw_Doppelpunkt ) then                          // generic constaint: class, record, <type>, constructor
                         repeat Next.get until not Next.getIf( kw_Komma )
                until  Next.Test3( kw_Groesser, kw_Komma, kw_Semikolon ) = kw_Groesser
                end;

              if Next.Peek = kw_Punkt then begin
                { ein Type (also mit Fortsetzung "." wurde gelesen }
                Qualified := true;
                if GenPosNext > 0 then
                  PosStr.Str := PosStr.Str + '<' + char( $30 + GenPosNext ) + '>';    // Typ ist durch die Anzahl Generics eindeutig
                pIdDecl := TListen.InsertIdAc( PosStr, nil, id_Type, ac_Read );
                for i := 0 to GenPosNext-1 do
                   pId := TListen.InsertIdAc( GenPos[i], nil, id_Type, ac_Read );
                TListen.EnterBlock( pIdDecl )
                end
              else begin
                { abschliessend jetzt die proc: }
                if Qualified
                  then // bezieht sich auf proc aus Interface
                  else PosStr.Str := PosStr.Str + cGenericDummy;   // auf jeden Fall ein Neuer, Generic-Dummy nur zur Eindeutigkeit

                pIdDecl := TListen.InsertIdAc( PosStr, pIdDecl, id_Unbekannt, ac_Declaration );  // erst mal IdUnbekannt wegen constructor, siehe unten
                TListen.EnterBlock( pIdDecl );

                for i := 0 to GenPosNext-1 do begin
                   pId := TListen.InsertIdAc( GenPos[i], pIdDecl, id_Unbekannt, ac_Declaration );
                   TListen.SetAsGenType( pId, i+1 {+1 nur für Vergleichs-Kompatibilität})
                   end;
                if not Qualified
                  then TListen.SetIdGeneric( pIdDecl, 0 )    // generische Methoden behalten ihren Basisnamen, also OHNE "<1>"
                end;
            until not Next.getIf( kw_Punkt );

            if DeclOrt = do_Interface then
              include( pIdDecl^.IdFlags2, InterfaceSection );
            { 22.05.22: }
            { Interface-Member sind immer public
              Sonst Fehler bei: TClass = class ( T, I ) strict private procedure TClassProc; I.proc = TClassProc; ... }
            if ( DeclOrt = do_Class ) and ( tIdFlags.IsInterface in pIdDecl^.PrevBlock^.IdFlags ) then begin
              if Next.Peek = kw_Gleich then
                TListen.ChangeAcType( pIdDecl^.LastAc, ac_Write )    // hier ist acWrite
              end
            else
              SetClassVisibility( ClassDecl, pIdDecl );

            if kwx_Operator
              then include( pIdDecl^.IdFlags, tIdFlags.IsOverload  )   // Operatoren können overload sein OHNE Direktive. Erstmal setzen, später (CheckOperator) korrigieren
            end;

          do_Implementation: begin
            { Manche Deklaration gibt es schon im Interface, der class/record oder forward. Mit Typ als Namens-Qualifizierung: }
            repeat
              Next.Test( kw_Identifier );
              inc( AnzahlClass );
              GenPosNext := 0;
              PosStr := Next.Id;                // jetzigen Id merken weil Next durch generics evtl verpfuscht wird

              if kwx_Operator and ( Next.Peek = kw_KlammerAuf{nicht beim Qualifier} ) { Operator kann kein generic sein} then
                Next.Id.Str := Next.Id.Str + cSymbolOp;

              if Next.getIf( kw_Kleiner ) then begin
                if FileOptions.RegKeySymbols then
                  TListen.MoveAc( KeywordListe[kw_Kleiner].LastAc, @KeywordListe[kw_Kleiner_GenMethodDef] );
                repeat Next.Test( kw_Identifier );
                       GenPos[GenPosNext] := Next.Id;
                       inc( GenPosNext )
                until  Next.Test3( kw_Groesser, kw_Komma, kw_Semikolon ) = kw_Groesser;
                Next.Id := PosStr;
                if Next.Peek = kw_Punkt then // nur wenn ein Type (also mit Fortsetzung "." gelesen wurde)
                  Next.Id.Str := PosStr.Str + '<' + char( $30 + GenPosNext ) + '>'    // Typ ist durch die Anzahl Generics eindeutig
                end;

              pId := TListen.SucheIdUnterId( pIdDecl, cNoHash, Next.Id.Str, false );

              if pId = nil then begin
                // Fall 1:  NEUER Id.  Kommt nicht im Interface oder class vor. Ist also kein Type sondern die proc/func. Kann kein generic oder overload sein
                assert( GenPosNext = 0 );
                if Next.Peek = kw_Punkt
                  then pIdDecl := TListen.InsertIdAc( Next.Id, pIdDecl, id_Type     , ac_Read        )   // neuer Id
                  else pIdDecl := TListen.InsertIdAc( Next.Id, pIdDecl, id_Unbekannt, ac_Declaration )   // neuer Id
                end
              else begin
                // Fall 2:  Schon bekannter Id.
                if ( Next.Peek <> kw_Punkt ) and
                   ( (   ClassDecl                  <> ( tIdFlags.isClassVar    in pId^.IdFlags ) )  or
                     ( ( DeclTyp = kw_CONSTRUCTOR ) <> ( tIdFlags.IsConstructor in pId^.IdFlags ) )) then begin
                  { gesucht wurde Class-Method, gefunden eine nicht-Class-Method. Oder umgekehrt. Das passt nicht. Nochmal suchen: }
                  pIdLokal := pId;
                  include( pIdLokal^.IdFlags, tIdFlags.IsOverload );
                  pIdLokal^.Hash := pIdLokal^.Hash xor 1;    // diesen jetzt mal nicht finden
                  pId := TListen.SucheIdUnterId( pIdDecl, cNoHash, Next.Id.Str, false );
                  pIdLokal^.Hash := pIdLokal^.Hash xor 1     // und wieder reparieren
                  end;

//                if ( Next.Peek <> kw_Punkt ) and (

                pIdDecl := pId;
                if ( Next.Peek <> kw_Punkt ) and         // nicht für Qualifier
                   (( tIdFlags.IsOverload in pIdDecl^.IdFlags )  {or
                    ( kwx_Operator and ( pIdDecl^.AcList <> pIdDecl^.LastAc ) )}) then begin   // operator: ist nicht zwingend overload
                  // Fall 2a:  Overload. pIdDecl muss nach Parameterliste ggf korrigiert werden, erstmal unter DummyId einhängen:
                  pIdOverload           := pIdDecl;                   // den ersten merken
                  DummyIdOver.PrevBlock := pIdDecl^.PrevBlock;
                  DummyIdOver.Typ       := pIdDecl^.Typ;    // proc oder func
                  DummyIdOver.SubBlock  := nil;
                  DummyIdOver.SubLast   := nil;              // dies hier schon initialisieren für gemeinsames AddAc() und EnterBlock()
                  DummyIdOver.MyType    := nil;
                  DummyIdOver.TypeNr    := cNoTypeNr;
                  DummyIdOver.TypeGroup := coSelf;
                  DummyIdOver.IdFlags   := cOverFlags;
//                  if tFileFlags.LibraryPath in pAktUnit^.fiFlags
//                    then DummyIdOver.IdFlags2 := []
//                    else DummyIdOver.IdFlags2 := [tIdFlags2.IsUsedByProject];
                  {$IFDEF TraceDx}
                  DummyIdOver.Signatur  := 0;               // sonst wird nicht neu berechnet
                  {$ENDIF}
                  pIdDecl               := @DummyIdOver;
                  end
                else
                  ;// Fall 2b:  sicher kein overload -> pIdDecl stimmt

                if GenPosNext > 0 then begin
                  include( pIdDecl^.IdFlags, tIdFlags.IsGenericType );
                  // Generic-Dummys von oben jetzt eintragen:
                  pIdLokal := pIdDecl^.SubBlock;
                  for i := 0 to GenPosNext-1 do
                    if pIdOverload = nil then begin
                      TListen.AddAc( pIdLokal, nil, GenPos[i].Pos, ac_Declaration );
                      pIdLokal := pIdLokal^.NextId    // alle eingetragenen Generic-Dummy durchgehen
                      end
                    else
                      TListen.SetAsGenType( TListen.InsertIdAc( GenPos[i], pIdDecl, id_Unbekannt, ac_Declaration ), i + 1 {+1 nur für Vergleichs-Kompatibilität})
                  end;
                TListen.AddAc( pIdDecl, nil, Next.Id.Pos, cAcType[pId^.Typ = id_Type] )
                end;
              TListen.EnterBlock( pIdDecl )
            until not Next.getIf( kw_Punkt );

            { Spezial-Nachbehandlung für overload: }
            if pIdOverload <> nil then
//               ( IsOverload in pIdDecl^.IdFlags ) or                                    // overload: bei der ersten func noch nicht gesetzt!
//               ( kwx_Operator and ( pIdDecl^.AcList <> pIdDecl^.LastAc ) ) then
              {if DeclOrt in [do_Interface, do_Record, do_Class] then} begin   // operator: ist nicht zwingend overload
                end
            end
        end;
        KeyWordListe[kw_IN].Hash := kw_IN_Hash;    // Id ist jetzt komplett eingelesen, "IN" für Statements wieder aktivieren

        { kann sich nochmal ändern (deshalb unten nochmal). Aber hier setzen, damit Proc-Name NICHT als Typ gefunden werden kann }
        TListen.ChangeIdType( pIdDecl, cProcTyp[( DeclTyp in [kw_FUNCTION, kw_CONSTRUCTOR] )] );

        { Parameterliste ( ggf auch zweimal ) lesen }
        if Next.getIf( kw_KlammerAuf ) then begin
//          AktDeclareOwner := AktDeclareOwner^.PrevBlock;      // Typen von Parametern erst ab der Ebene darüber suchen
          ParseDeclarations( do_Parameter, pIdDecl );
//          AktDeclareOwner := pIdDecl;                         // ...damit ( WParam: WPARAM ) funktioniert
          Next.Test( kw_KlammerZu )
          end;

        pIdDecl^.TypeGroup := coMethod;
        if DeclTyp = kw_CONSTRUCTOR then begin
          pIdDecl^.MyType := pIdDecl^.PrevBlock;    // ist nämlich eigentlich eine function (aber ohne explizite Typ-Angabe)
//          pIdDecl^.TypeGroup := coClass;
//          include( pIdDecl^.IdFlags, tIdFlags.IsConstructor );     nach unten hinter overload verschoben
          pIdDecl^.IdFlags := pIdDecl^.IdFlags + ( pIdDecl^.MyType^.IdFlags * [tIdFlags.IsPointer, tIdFlags.IsClassType])
          end;

        if Next.getIf( kw_Doppelpunkt ) then begin
          assert( DeclTyp = kw_FUNCTION );
//          ParseType( pIdDecl, 1 );
          ParserState.ParseNoVar := true;                            // wäre überflüssig wenn ParseType folgen würde
          IdSeq := IdSequenz.Pegel;               // ab hier ggf die real generic Types
          pIdDecl^.MyType  := ParseIdentifier( id_Type, false );    // aber dies ist schneller
          ParserState.ParseNoVar := false;
          pIdDecl^.TypeNr     := pIdDecl^.MyType^.TypeNr;
          pIdDecl^.NextHelper := pIdDecl^.MyType^.NextHelper;
          pIdDecl^.IdFlags    := pIdDecl^.IdFlags + ( pIdDecl^.MyType^.IdFlags * [tIdFlags.IsPointer, tIdFlags.IsClassType]);
          if tIdFlags.IsGenericType in pIdDecl^.MyType^.IdFlags then begin
            { Die realen Typen sind als IdSequenz hinterlegt: }
//            TListen.CopySub( pId, pIdDecl );                                          // Jetzt in die erste Variable kopieren
//            TListen.SetRealGenericTypes( pId^.SubBlock, pIdDecl^.SubBlock, IdPegel ); // .. und DORT die Typen ersetzen:
            IdSequenz.Pegel := IdSeq
            end
          end;

        {$IFDEF TraceDx}          // nur noch für TraceDx-Log-Lesbarkeit
        if pIdDecl^.Signatur = 0 then begin
          pIdDecl^.Signatur := TListen.CalcSignatur( pIdDecl );
          if GenPosNext > 0
            then pIdDecl^.Signatur := pIdDecl^.Signatur + ( GenPosNext shl 4 );
          if kwx_Operator then
            pIdDecl^.Signatur := ( pIdDecl^.Signatur shl 8 ) + ( pIdDecl^.TypeNr and 255 )   // bei Operatoren kommt der Result-Typ ins Low-Byte
          end;
        {$ENDIF}

        if pIdOverload <> nil then begin   // overload kann auch parameterlose Proc gewesen sein, deshalb nicht in kw_KlammerAuf-if
          if TListen.InsertOverloadId( pIdDecl, pidOverload ) then begin   // per Signatur einsortieren  oder  auch evtl ein neuer
            { veraltet: falls generisch: Der erste <T>-Access (die "<T>-Deklaration" aus "procedure pro<T>" ) hängt noch unter pIdOverload: }
            end;

          pIdDecl^.IdFlags := pIdDecl^.IdFlags + pIdOverload^.IdFlags - [tIdFlags.IsStatic, tIdFlags.IsConstructor{siehe Verfikation\Classes}];
          if tIdFlags.IsGenericType in DummyIdOver.IdFlags then       // das generic-Flag für <T> kann noch dazugekommen sein,
            include( pIdDecl^.IdFlags, tIdFlags.IsGenericType );      // jetzt nachtragen
          TListen.EnterBlock( pIdDecl )                    // pIdDecl und damit auch AktDeclareBlock war DummyIdOver, jetzt richtig setzen
          end;

        if pIdDecl^.Typ <> cProcTyp[( DeclTyp in [kw_FUNCTION, kw_CONSTRUCTOR] )] then
          TListen.ChangeIdType( pIdDecl, cProcTyp[( DeclTyp in [kw_FUNCTION, kw_CONSTRUCTOR] )] );   // hier erst richtig weil pIdDecl sich geändert haben kann

        if DeclTyp = kw_CONSTRUCTOR
          then include( pIdDecl^.IdFlags, tIdFlags.IsConstructor );

        if DeclOrt = do_Parameter
          then ProcDirektiven := []
          else ProcDirektiven := ParseProcDirectives;   { Direktiven }

        if (( DeclOrt = do_Implementation ) and not ( NoBody in ProcDirektiven )) or ( DeclOrt = do_Anonym ) then begin
          if DeclTyp = kw_FUNCTION then begin
            { Result einfügen und aus FktName typisieren }
            PosStrResult.Pos := pIdDecl^.LastAc^.Position;
            pId := TListen.InsertIdAc( PosStrResult, pIdDecl, id_Var, ac_Declaration );
            include( pId^.IdFlags, tIdFlags.IsResult );
            if pIdDecl^.MyType = nil
              then // kommt vor: rtl\common\System.Classes.TComponent.EndInvoke  //Error( errNoTypeForResult, TListen.getBlockNameLong( pIdDecl, dTrennView ))
              else TListen.CopySub( pIdDecl^.MyType, pId );
//            TListen.CopyTypeInfos( pIdDecl^.MyType, pId )
            end;

          { jetzt kommt der Inhalt: }
          if ( AnzahlClass > 1 ) and not ( tIdFlags.IsStatic in pIdDecl^.IdFlags ) {and not ( DeclTyp = kw_CONSTRUCTOR ) kommt doch vor in: Cantu/11/IntfDemo} then begin
            { implizite Variable "Self" bei Nicht-Klassenmethoden einfügen: }
            PosStrSelf.Pos := pIdDecl^.PrevBlock^.LastAc^.Position;
            pIdSelf := TListen.InsertIdAc( PosStrSelf, pIdDecl, id_Var, ac_Declaration );
            include( pIdSelf^.IdFlags2, tIdFlags2.IsSelf );
            if IsHelper in pIdDecl^.PrevBlock^.IdFlags
              then TListen.CopyVarTypeInfos( pIdDecl^.PrevBlock, pIdSelf )
              else TListen.CopyTypeInfos   ( pIdDecl^.PrevBlock, pIdSelf );
            pIdSelf^.IdFlags := [tIdFlags.IsClassType]
            end;

        { Neu:
//        for i := 1 to AnzahlClass do TListen.LeaveBlock;    // falls procedure TClassInner.TClassOuter.p()...
//        TListen.EnterBlock( pIdDecl );                      // ... darf nur Outer im Such-Zugriff sein
        TListen.InsertIdPtr( WithListe, pIdDecl, AcStart, AcSequenz.Pegel );
        }

          ParseDeclarations( do_Implementation, pIdDecl );
          if Next.Peek = kw_ASM
            then ParseStatement
            else ParseStatementBlock;

          if AnzahlClass > 1 then   { implizite Variable "Self" falls nicht benutzt (AcList enthält nur Declare) wieder löschen: }
            if ( pIdSelf <> nil ) and ( pIdSelf^.AcList^.NextAc = nil ) then
              TListen.FreeIdAcSub_Ausketten( pIdSelf )
          end;
//        for i := 1 to AnzahlClass do TListen.LeaveBlock;      das kann nach "procedure Typ_aus_Interface.Pro" zum falschen führen
        TListen.EnterBlock( pIdOwner );                         // Start-Owner wieder herstellen

        if ( DeclOrt = do_Class ) and Next.getIf( kw_Gleich ) then
          ParseIdentifier( pIdDecl^.Typ, false );

        if DeclOrt = do_Class then
          TListen.TestIdForUnbekannt( pIdDecl, UnbekanntEndeClass )
        end
      else
        Error( errSyntaxError, '<Declaration>', Next.Id.Str )
      end
  end;

(* ParseDeclarations *)
begin
  {$IFDEF TraceDx} TraceDx.Call( uDecl, 'Declarations', GetEnumName( TypeInfo( tDeklaration ), ord( DeclOrt )) ); {$ENDIF}
  Weiter          := true;
  CasedRecord     := false;
  CasedConst      := false;
  ClassDecl       := false;
  UnbekanntEndeType   := nil;
  DeclTyp         := kw_NOT;                           // jeder Parameter ist per Standard Wert-Übergabe (wenn kein VAR,CONST,PROC,FUNC)
  Visibility      := visPUBLIC;
  Strct           := false;
  pIdResultUnsafe := nil;
  kwx_Operator    := false;
  kwx_Out         := false;
  pd_Moeglich     := true;

  while Weiter do begin
    if pd_Moeglich {nur VOR den Schlüsselwörtern VAR...} and ( DeclOrt in [do_Record, do_Class] ) then
      while Next.Peek = kw_Identifier{kein Keyword->evtl Direktive} do begin
        case NextPascalDirective( ds_CLASS ) of
          pd_NIL      : break;
          pd_AUTOMATED, // http://docwiki.embarcadero.com/RADStudio/Rio/en/Classes_and_Objects_(Delphi)#Automated_Members_.28Win32_Only.29
          pd_PUBLISHED,
          pd_PUBLIC   : begin Visibility := visPUBLIC   ; Strct := false; DeclTyp := kw_NOT; ClassDecl := false end;
          pd_PRIVATE  : begin Visibility := visPRIVATE  ; Strct := false; DeclTyp := kw_NOT; ClassDecl := false end;
          pd_PROTECTED: begin Visibility := visPROTECTED; Strct := false; DeclTyp := kw_NOT; ClassDecl := false end;
          pd_STRICT   : begin
                          Strct     := true;
                          DeclTyp   := kw_NOT;
                          ClassDecl := false;
                          if NextPascalDirective( ds_CLASS ) = pd_PRIVATE
                            then Visibility := visPRIVATE
                            else Visibility := visPROTECTED
                        end
          else          Error( errSyntaxError, 'PUBLIC', Next.Id.Str )
          end
        end;
    case Next.Peek of
      kw_CLASS,
      kw_LABEL, kw_CONST, kw_TYPE, kw_VAR, kw_PROPERTY, kw_PROCEDURE, kw_FUNCTION, kw_RESOURCESTRING, kw_THREADVAR, kw_CONSTRUCTOR, kw_DESTRUCTOR: begin
        pd_Moeglich := false;
        ClassDecl := Next.getIf( kw_CLASS );      // Klassen-Vars/Propertys/-Methoden der Art "class property xy "
        KeyWordListe[kw_IN].Hash := cNoHash;      // nach "operator" ist "in" als non-keyword erlaubt -> temporär abschalten
        if ( Next.Peek = kw_Identifier ) and ClassDecl and NextPascalDirective1( pd_OPERATOR ) then begin
          // http://docwiki.embarcadero.com/RADStudio/Rio/en/Operator_Overloading_(Delphi)
          DeclTyp      := kw_FUNCTION;
          kwx_Operator := true         //DeclOrt = do_Record     {einmal reicht}
          end
        else begin
          DeclTyp := Next.get;  // Normalfall
          KeyWordListe[kw_IN].Hash := kw_IN_Hash    // kein Operator, "IN" für Statements wieder aktivieren
          end;
        { ein neuer Type-Block. UnbekanntEnde für vorwärts-referenzierte Pointer merken und nach TYPE-Deklaration aufzulösen versuchen }
        if DeclTyp = kw_Type then
          UnbekanntEndeType := MainBlock[mbUnDeclaredUnScoped].SubLast;    // damit nur der neueste Unbekannt-Teil durchsucht werden muss

        if DeclOrt = do_Anonym then begin
          ParseDeclaration( AktDeclareOwner );
          Weiter := false
          end
        end;
      kw_Literal, kw_Identifier, kw_Plus, kw_Minus, kw_NOT:
        if CasedConst then begin
          ParseExpressionList;
          Next.Test( kw_Doppelpunkt );
          Next.Test( kw_KlammerAuf  );
          CasedConst := false
          end
        else begin
          pd_Moeglich := true;
          if ( DeclOrt = do_Parameter ) and NextPascalDirective1( pd_OUT ) then begin
            DeclTyp := kw_VAR;
            kwx_Out := true
            end;
          { die eigentliche Deklaration: }
          ParseDeclaration( pIdOwner );
          if kwx_Operator then begin
            if DeclOrt in [do_Record, do_Class] then
              pIdOwner^.SubLast^.IdFlags := pIdOwner^.SubLast^.IdFlags + [tIdFlags.IsOperator, tIdFlags.IsOverload];   // Flag für die operator-function setzen
            kwx_Operator := false
            end;

          if kwx_Out then
            kwx_Out := false;

          if pIdResultUnsafe <> nil then begin   // es gab ein [result:unsafe]
            if DeclTyp = kw_FUNCTION then begin
//              TListen.MoveAc( pIdResultUnsafe^.LastAc, pIdOwner^.SubLast^.SubBlock );  // nach jetzt existierender Var "result" verschieben
              TListen.MoveAc( pIdResultUnsafe^.LastAc, pIdOwner^.SubLast^.SubBlock );
              if pIdResultUnsafe^.AcList = nil then
                TListen.FreeIdAcSub_Ausketten( pIdResultUnsafe )
              end;
            pIdResultUnsafe := nil
            end;
          if ( DeclOrt = do_Parameter ) or                        // nach const-Parameter ist der nächste standardmäßig OHNE Keyword wieder var-Parameter
             ( DeclTyp = kw_PROCEDURE ) or ( DeclTyp = kw_FUNCTION )  // nach proc/func/... auch wieder auf not
            then DeclTyp := kw_NOT
          end;
      kw_EckigeKlammerAuf: begin
        if FileOptions.RegKeySymbols then
          TListen.MoveAc( KeywordListe[kw_EckigeKlammerAuf].LastAc, @KeywordListe[kw_EckigeKlammerAuf_Attribut  ] );
        Next.get;    //  [Attribut ref unsafe weak volatile] oder Attribut-Class
        repeat
          if not NextIsCompilerAttribute then begin
            pIdResultUnsafe := ParseIdentifier( id_Unbekannt, false );
            if pIdResultUnsafe^.Name.ToLowerInvariant = cSymbolResult.ToLowerInvariant then
              // [result:unsafe]: erst nach Lesen der function kann unter result eingetragen werden deshalb pIdResult merken
              if Next.getIf( kw_Doppelpunkt )
                then NextIsCompilerAttribute
                else pIdResultUnsafe := nil
            else begin
              if Next.getIf( kw_Doppelpunkt ) then
                NextIsCompilerAttribute    // [<var>:unsafe]   http://docwiki.embarcadero.com/RADStudio/Rio/en/Automatic_Reference_Counting_in_Delphi_Mobile_Compilers#The_Unsafe_Attribute
              else
                if pIdResultUnsafe^.Name.ToLowerInvariant = 'default' then begin
                  // https://www.delphipraxis.net/203439-default-wert-fuer-record-methode.html#post1457704
                  // http://docwiki.embarcadero.com/Libraries/Rio/de/System.Classes.DefaultAttribute
                  TListen.MoveAc( pIdResultUnsafe^.LastAc, @PascalDirektiveListe[pd_DEFAULT] );    // default-Attribut wird von Delphi benutzt um Pascal-Direktive "default" auf Strings usw. zu erweitern
                  if pIdResultUnsafe^.AcList = nil then
                    TListen.FreeIdAcSub_Ausketten( pIdResultUnsafe )
                  end
                else
                  if pIdResultUnsafe.PrevBlock = @MainBlock[mbUnDeclaredUnScoped] then begin
                    pIdTemp {ist gerade frei} := TListen.InsertId( pIdResultUnsafe^.Name, @MainBlock[mbAttributes], id_CompilerAttribute, false );
                    TListen.MoveAc( pIdResultUnsafe^.LastAc, pIdTemp );
                    if pIdResultUnsafe^.AcList = nil then
                      TListen.FreeIdAcSub_Ausketten( pIdResultUnsafe )
                    end
                  else
                    TListen.CopyLastAc( pIdResultUnsafe, @MainBlock[mbAttributes] );   // sonst [<var>]: unter der Variablen UND unter Attributen ablegen
              pIdResultUnsafe := nil
              end;
            end
         until not Next.getIf( kw_Komma );
        Next.Test( kw_EckigeKlammerZu )
        end;
      kw_EXPORTS: begin
        Next.get;
        ParserState.ExportsClause := true;
        repeat
          ParseIdentifier( id_Unbekannt, false );
          if Next.getIf( kw_KlammerAuf ) then
            repeat until Next.get = kw_KlammerZu;
          while true do
            case NextPascalDirective( ds_NAME ) of
              pd_NIL     : break;
              pd_INDEX,
              pd_NAME    : ParseExpression( false, pIdCase );    // 'a' + 'b' ist hier möglich
              pd_RESIDENT:
              end
        until Next.Test2( kw_Semikolon, kw_Komma );
        ParserState.ExportsClause := false
        end;
      kw_CASE: begin
        CasedRecord := true;
        DeclTyp     := kw_NOT;
        Next.get;    // CASE
        if FileOptions.RegKeywords then
          TListen.MoveAc( KeywordListe[kw_CASE].LastAc, @KeywordListe[kw_CASE_variant] );
        Next.Test( kw_Identifier );
        if Next.Peek = kw_Doppelpunkt then begin       // record case b: boolean of
          pIdCase := TListen.InsertIdAc( Next.Id, pidOwner, id_Var, ac_Declaration );
          Next.get;   // Doppelpunkt
          ParseType( pIdCase, 1 )
          end
        else                                           //  record case boolean of
          TListen.InsertIdAc( Next.Id, nil, id_Type, ac_Read );    // KEINE Variable anlegen. Typ ist flach, also kein Copy oder Aufräumen hinterher notwendig
        Next.Test( kw_OF );
        CasedConst := true
        end;
      kw_KlammerZu:
        if CasedRecord then begin
          Next.get;  // kw_KlammerZu
          Next.getIf( kw_Semikolon );
          CasedConst := true
          end
        else
          Weiter := false;
      kw_Semikolon:
          Next.get;   //          Weiter := true
      else
        Weiter := false
      end
    end
end;

end.
