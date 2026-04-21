
unit uParser;

{$INCLUDE _CompilerOptionsRef.pas}
{$INCLUDE _CompilerOptions.pas}
{ $UNDEF TraceDx}

{ ---------------------------------------------------------------------------------------- }

interface

uses
  Vcl.ComCtrls,
  System.SysUtils;

type
  TParser = record
              private
                const Self = 'uParser';
              public
                class procedure Init; static;
                class function  Parse( const f: string; rl: TProc ): boolean; static;
            end;

{ ---------------------------------------------------------------------------------------- }

implementation

uses
  {$IFDEF TraceDx} uTraceDx, {$ENDIF}
  System.IOUtils,
  System.Classes,
  System.Types,
  System.Generics.Collections,
  UtilitiesDx,
  uGlobals,
  uGlobalsParser,
  uDeclarations,
  uExpressions,       // nur fürs PreParse
  uStatements,
  uScanner,
  uListen;


const
  cExtErr  = '.' + cProgname + '.err';

{$IFDEF TraceDx} type uParse = class end; {$ENDIF}

var
  ProgType  : tKeyWord;
  FirstUnit : tFileInfo;    // OHNE LibraryPath-Flag
  IdFile    : tIdPosInfo;
  {$IFDEF PseudoFile}
  PseudoFile: tStringDynArray;  // StringList (ohne physische Datei) für Pseudeo-Acs auf $Define und Gültigkeitsbereiche aus Projekt-Optionen (Ref und IDE)
  {$ENDIF}
{ ---------------------------------------------------------------------------------------- }

{$REGION '----------- Parse PROG / UNIT---------------' }

(* ParseIdentifierUnit *)
function  ParseIdentifierUnit( IdTyp: tIdType; AcTyp: tAcType ): pIdInfo;
begin
  {$IFDEF TraceDx} TraceDx.Call( uParse, 'Identifier(Unit)' ); {$ENDIF}
  Result := nil;
  IdFile.Pos := NextId.Pos;
  repeat
    Next.Test( kw_Identifier );
    if Result = nil then
      Result := @MainBlock[mbBlock0];    // Units werden immer im obersten Block aufgehängt, auch unbekannte
    if Next.Peek = kw_Punkt then begin
      Result := TListen.InsertIdAc( Next.Id, Result, id_NameSpace, ac_Read );
      if AcTyp = ac_Declaration
        then TListen.EnterBlock( Result )
      end
    else
      Result := TListen.InsertIdAc( Next.Id, Result, IdTyp, AcTyp )
  until not Next.getIf( kw_Punkt );
  IdFile.Pos.Laenge := Next.Id.Pos.Spalte + Next.Id.Pos.Laenge - IdFile.Pos.Spalte;
  ParseHintDirectives
end;

(* ParseUnitImplementation *)
procedure ParseUnitImplementation( pIdUnit: pIdInfo );
var pId: pIdInfo;
begin
  {$IFDEF TraceDx} TraceDx.Call( uParse, 'UnitImplementation', pIdUnit^.Name ); {$ENDIF}
  //  Next.Test1( kw_IMPLEMENTATION );          ist bereits durch
  pAktUnit^.ImplStart := pIdUnit^.SubLast;

  if not Abbruch then begin
    TListen.EnterBlock( pIdUnit );            // auffrischen nach USES
    ParseDeclarations( do_Implementation, pIdUnit );

    if Next.Test3( kw_INITIALIZATION, kw_BEGIN{PROGRAM und alte Turbo-Unit-Syntax}, kw_END ) <> kw_END then begin
      pId := TListen.InsertIdAc( Next.Id, pIdUnit, id_Init, ac_Declaration );
      TListen.EnterBlock( pId );
      include( pId^.IdFlags, IsDummy );
      ParseStatementList;
      TListen.LeaveBlock;
      if Next.Test2( kw_FINALIZATION, kw_END ) then begin     // final nur wenn auch init
        pId := TListen.InsertIdAc ( Next.Id, pIdUnit, id_Final, ac_Declaration );
        TListen.EnterBlock( pId );
        include( pId^.IdFlags, IsDummy );
        ParseStatementList;
        TListen.LeaveBlock;
        Next.Test( kw_END )
        end;
      end;
    Next.Test( kw_Punkt )
    end;

  if pAktUnit^.ImplStart <> nil then begin
    pAktUnit^.ImplNext  := pAktUnit^.ImplStart^.NextId;      // den Nachfolger (also erster Id des implemetation-Abschnitts) merken
    pAktUnit^.ImplStart^.NextId := nil
    end
end;

(* ParseAllUnitImplementations *)
procedure ParseAllUnitImplementations;
var pidUses: pIdPtrInfo;
    f      : pfileInfo;
    i      : tFileIndex;
begin
  {$IFDEF TraceDx} TraceDx.Call( uParse, 'AllUnitImplementations', high( DateiListe )); {$ENDIF}
  ParserState.Implementations := true;
  i := cFirstFile;
  while i <= high( DateiListe ) do begin
    f := DateiListe[i];
    with f^ do begin   // Anzahl erhöht sich in implementation-uses noch
      if ( UnitName <> '' ) { nur Units } and not ( LibraryPath in fiFlags ) { nicht für Files aus SearchPathIDE } then begin
        TListen.ReEnterFileUnit( i );
        { Helper übernehmen: a:aus eigenem Interface }
        THelper.SetUnitHelpersToTypes( MyUnit^.NextHelper );
        { Helper übernehmen: b:aus used Units  }
        pIdUses := UsesListe;
        while pIdUses <> nil do begin                    // für alle used units
          THelper.SetUnitHelpersToTypes( pIdUses^.Block^.NextHelper );
          pIdUses := pIdUses^.NextIdPtr
          end;

        Helper.ImplHelpers := nil;     // hier werden gleich zusätzliche Helper aus implementation gesammelt
        ParseUnitImplementation( MyUnit );

        { Helper löschen: a:aus used Units  }
        pIdUses := UsesListe;
        while pIdUses <> nil do begin                    // für alle used units
          THelper.ReSetUnitHelpersToTypes( pIdUses^.Block^.NextHelper );
          pIdUses := pIdUses^.NextIdPtr
          end;
        { Helper löschen: b:aus eigenem Interface }
        THelper.ReSetUnitHelpersToTypes( MyUnit^.NextHelper );
        { Helper löschen: c:aus eigener Implementation. Liste wurde direkt im ParseType->record aufgebaut }
        THelper.ReSetUnitHelpersToTypes( Helper.ImplHelpers )
        end;
      inc( i )
      end;
    end;

  for i := cFirstFile to high( DateiListe ) do with DateiListe[i]^ do
    if ImplStart <> nil then
      ImplStart^.NextId := ImplNext             // impl-Ids wieder verfügbar machen
end;

       { Strategie damit die used-Interfaces in der richtigen Reihenfolge geparst werden:
         1. (doppelt) verkettete Liste der Reihenfolge fürs parsen
         2. geparst wird hinterher von vorne hach hinten
         3. Deshalb jede used-Unit an erster Position einketten (ggf vorher ausketten)
         4. Erste Position muss nicht sein, aber VOR der benutzenden Unit, die ja selbst auch in der Kette ist.
            (erste Position ist am einfachsten zu realisieren)
       }

(* ParseUsesList *)
procedure ParseUsesList;
var pIdUses  : pIdInfo;
    InClause,
    newFile  : boolean;
    UsesName : string;
    pUsesFile: pFileInfo;
  procedure SetProjectFlag( pId: pIdInfo );
  begin
    repeat
      include( pId^.IdFlags2, tIdFlags2.IdProjectUse );
      pId := pId^.PrevBlock
    until pId^.Typ = id_MainBlock
  end;
begin
  {$IFDEF TraceDx} TraceDx.Call( uParse, 'UsesList', UsesName ); {$ENDIF}
//  Next.Test( kw_USES );              ist bereits durch
  InClause := false;
  repeat
    pIdUses  := ParseIdentifierUnit( id_Unit, ac_Read );
    UsesName := TListen.getBlockNameLong( pIdUses, cTrennUse );

    if Next.getIf( kw_IN ) then begin
      { Sonderfall:  Dateiname im USES enthalten: UnitMain in 'UnitMain.pas'    Nur im *.DPR }
      InClause := true;
      Next.Test( kw_Literal );
      IdFile.Str := Next.Id.Str.Substring( 1, Next.Id.Str.Length-2 );
      IdFile.Pos := Next.Id.Pos
      end
    else
      IdFile.Str := UsesName + cExtensionPas;

    if false or (pIdUses^.AcList = pIdUses^.LastAc ) then
      { Diese Unit ist auf jeden Fall neu (acRead wurde gerade eingetragen): zugehörige Datei suchen: }
      if TListen.TestEnterFileUnit( IdFile, UsesName, pUsesFile, newFile, pIdUses{ändert sich falls erst über Gültigkeitsbereich gefunden } ) { Datei vorhanden } then begin
        if newFile then begin
          if not (tFileFlags.LibraryPath in pUsesFile^.fiFlags ) then
            SetProjectFlag( pIdUses )
          end;
        TListen.InsertIdPtr( pAktUnit^.UsesListe, pIdUses, pUsesFile^.MyIndex, 0 );   // auf jeden Fall eintragen , auch wenn Unit-File nicht exitiert
        DateiListe[pUsesFile^.MyIndex].MyUnit := pIdUses                              // nicht erst beim parsen der unit eintragen sondern schon beim uses, damit sie im SearchUnitFile() sofort gefunden werden kann
        end
      else
        TListen.InsertIdPtr( pAktUnit^.UsesListe, pIdUses, -1, 0 )   // -1 = File exisitert nicht
    else begin
      { Unit hat schon Ac-Einträge, Datei muss nicht im Dateisystem gesucht werden }
      var i := TListen.SearchUnitFile( pIdUses );
      TListen.InsertIdPtr( pAktUnit^.UsesListe, pIdUses, i, 0 );
      if i <> -1 { -1 = Datei nicht gefunden } then begin
        IdFile.Str := DateiListe[i].FileName;
        TListen.InsertFileId( DateiListe[i].LibraryNr, IdFile )
        end
      end;

  until Next.Test2( kw_Semikolon, kw_Komma );

  if InClause then
    TListen.FreeIdAcSub( @MainBlock[mbConstStrings], false )   // Die IN-Strings werden nur als filename gespeichert, Strings wieder löschen.
end;

(* ParseUnitHeaderAndUses1 *)
procedure ParseUnitHeaderAndUses1( nr: tFileIndex );
var pAc: pAcInfo;
begin
  {$IFDEF TraceDx} TraceDx.Call( uParse, 'UnitHeaderAndUses1', DateiListe[nr]^.FileName ); {$ENDIF}
  TListen.EnterFileUnitMinimal( nr );
  AktDeclareOwner := @MainBlock[mbBlock0];
  Next.get;  // init nach Enter
  case Next.Peek of
    kw_UNIT   : begin
                  Next.get;
                  pAktFile^.MyUnit := ParseIdentifierUnit( id_Unit, ac_Declaration );
                  with pAktFile^.MyUnit^ do if AcList^.ZugriffTyp <> ac_Declaration then begin
                    pAc := AcList;
                    while pAc^.NextAc <> LastAc do pAc := pAc^.NextAc;     // Unit-Deklaration
                    pAc^.NextAc := nil;                                    // als ersten ac setzen.
                    LastAc^.NextAc := AcList;
                    AcList := LastAc;                                      // Ist idR wegen uses ...
                    LastAc := pAc                                          // weiter hinten
                    end;
                  TListen.EnterBlock( pAktFile^.MyUnit );
                  Next.Test( kw_Semikolon );
                  Next.Test( kw_INTERFACE );     //   eine Unit hat immer ein Interface
//                  ParseUses[0].Add( pFileInfo( DateiListe.Objects[0] ));
                  if Next.getIf( kw_USES )
                    then ParseUsesList
                end;
    kw_PROGRAM,
    kw_LIBRARY: begin
                  ProgType    := Next.get;
                  pAktFile^.MyUnit := ParseIdentifierUnit( id_Program, ac_Declaration);
//                  include( pAktFile^.MyUnit^.AcSet, ac_Read );    // Fake:  als benutzt markieren   -> war nur für Filter, dort gelöst
                  TListen.EnterBlock( pAktFile^.MyUnit );
                  if Next.getIf( kw_KlammerAuf ) then
                    repeat
                      Next.Test( kw_Identifier );
                      include( TListen.InsertIdAc( Next.Id, pAktFile^.MyUnit, id_Const, ac_Declaration )^.IdFlags, IsWriteParam );
                    until Next.Test2( kw_KlammerZu, kw_Komma );
                  Next.Test( kw_Semikolon );

                  if Next.getIf( kw_USES )
                    then ParseUsesList
                end;
    kw_Identifier: if NextPascalDirective1( pd_PACKAGE ) then begin
                  ProgType    := kw_Identifier;
                  pAktFile^.MyUnit := ParseIdentifierUnit( id_Program, ac_Declaration);            // testen
//                  include( pAktFile^.MyUnit^.AcSet, ac_Read );    // Fake:  als benutzt markieren, siehe PROGRAM
                  TListen.EnterBlock( pAktFile^.MyUnit );
                  Next.Test( kw_Semikolon );
                  if NextPascalDirective1( pd_REQUIRES ) then
                    ParseUsesList;
                  if NextPascalDirective1( pd_CONTAINS ) then
                    ParseUsesList
                  end
                else
                  Error( errSyntaxError, '<ProgramEntry>', KeyWordListe[Next.get].Name );
    kw_CONST, kw_TYPE, kw_VAR, kw_PROCEDURE, kw_FUNCTION, kw_CONSTRUCTOR, kw_DESTRUCTOR, kw_CLASS: begin
                ProgType    := kw_CONST;
                Next.Id.Str := 'DummyUnit';
//                pAktFile^.MyUnit := TListen.InsertIdAc( Next.Id, AktDeclareOwner, id_Unit, ac_Declaration );
                pAktFile^.MyUnit := TListen.InsertId( Next.Id.Str, AktDeclareOwner, id_Program, false );
                pAktFile^.MyUnit^.AcSet    := [ac_Declaration, ac_Read];    // Fake:  damit sie auch angezeigt wird und als benutzt markieren, siehe PROGRAM
                pAktFile^.MyUnit^.IdFlags2 := [tIdFlags2.IdProjectUse];
                SetLength( pAktFile^.StrList, pAktFile^.liMax + 2 );
                inc( pAktFile^.liMax );
                pAktFile^.StrList[pAktFile^.liMax ] := 'end';
                ParserState.Implementations := true;
                TListen.EnterBlock( pAktFile^.MyUnit );
                ParseDeclarations( do_Implementation, pAktFile^.MyUnit );
                TListen.LeaveBlock
                end;
    else
      Error( errSyntaxError, '<ProgramEntry>', KeyWordListe[Next.get].Name )
  end;
  TListen.PauseUnit
end;

(* ParseUnitInterfaceAndUses2 *)
procedure ParseUnitInterfaceAndUses2( pFileUnit: pFileInfo );
var pIdImpl, pIdUnit: pIdInfo;
begin
  {$IFDEF TraceDx} TraceDx.Call( uParse, 'UnitInterfaceAndUses2', pFileUnit^.FileName ); {$ENDIF}
//  Next.Test( kw_INTERFACE );     //   ist bereits durch
  if pFileUnit^.MyUnit = nil then
    ParseUnitHeaderAndUses1( pFileUnit^.MyIndex );
  pIdUnit := pFileUnit^.MyUnit;
  TListen.EnterBlock( pIdUnit );
  ParseDeclarations( do_Interface, pIdUnit );
  include( pFileUnit^.fiFlags, tFileFlags.InterfaceRead );

  if not ( LibraryPath in pFileUnit^.fiFlags ) then begin
    Next.Test1( kw_IMPLEMENTATION );
    pFileUnit^.ImplStart := pIdUnit^.SubLast;
    pIdImpl := TListen.InsertIdAc( Next.Id, pIdUnit, id_Impl, ac_Declaration );    // im ImplStart merken
    include( pIdImpl^.        IdFlags, IsDummy  );
    include( pIdImpl^.AcList^.AcFlags, DontFind );
    if Next.getIf( kw_USES )
      then ParseUsesList
    end
end;

(* ParserStart *)
procedure ParserStart( fn: tFilestring );
var b         : boolean;
    pFirstFile: pFileInfo;
    pDummy    : pIdInfo;
    SaveLast,
    SaveLast_ : tFileIndex;

  procedure CollectAllHeaders( i: tFileIndex );
  var f: pfileInfo;
  begin
    while i <= high( DateiListe ) do begin
      f := DateiListe[i];
      if f^.UnitName <> '' then
        ParseUnitHeaderAndUses1( f^.MyIndex );
      inc( i )
      end
  end;

  procedure ParseAllInterfaces( von, bis: tFileIndex );
  var i: tFileIndex;

    procedure ParseInterface( pFile: pFileInfo );
    var pUsedUnit: pIdPtrInfo;
    begin
      if Abbruch then exit;
      if ( pFile^.MyUnit <> nil ) and                                          // Datei ist eine Unit ...
         not ( tFileFlags.InterfaceRead in pFile^.fiFlags ) then begin
//         (( pFile^.MyUnit^.SubBlock =  nil ) or                              // SubBlock kann schon Referenzen aus anderen Units enthalten
//          ( pFile^.MyUnit^.SubLast^.Typ <> id_Impl )) then begin             // ... und ist noch nicht analysiert. Problem: Aus dfm kann noch nach impl was kommen
//         not ( ac_Declaration in pFile^.MyUnit^.AcSet ) then begin             // ist noch nicht analysiert
        {$IFDEF TraceDx} TraceDx.Call( uParse, 'Interface', pFile^.MyUnit^.Name ); {$ENDIF}
        pUsedUnit := pFile^.UsesListe;
        while pUsedUnit <> nil do begin
          if pUsedUnit^.AcStart <> -1 { Datei existiert } then
            ParseInterface( DateiListe[pUsedUnit^.AcStart] );
          pUsedUnit := pUsedUnit^.NextIdPtr
          end;
        TListen.ReEnterFileUnit( pFile^.MyIndex );
        ParseUnitInterfaceAndUses2( pFile );
        TListen.PauseUnit
        end;
    end;

  begin
    for i := von to bis do
      ParseInterface( DateiListe[i] )
  end;

begin
  {$IFDEF TraceDx} TraceDx.Call( uParse, 'Start', fn ); {$ENDIF}
  SaveLast   := cFirstFile;
  SaveLast_  := SaveLast;
  IdFile.Str := fn;
  b          := false;
  FillChar( IdFile.Pos, sizeOf( tFilePos ), 0 );
  if FileOptions.UseSystemRef then begin
    IdFile.Str := ProjDir + TPath.DirectorySeparatorChar + cSystemRef;
    if TFile.Exists( IdFile.Str ) then TListen.TestEnterFileUnit( IdFile, 'System.pas', pFirstFile, b, pDummy );
    if not b then begin
//      include( MainBlock[mbFilenames].SubBlock^.IdFlags, tIdFlags.IdUnused );   // wieder löschen/ignorieren
//      MainBlock[mbFilenames].SubBlock := nil;
//      MainBlock[mbFilenames].SubLast  := nil;
      IdFile.Str := TMyApp.DirExe + cSystemRef;
      if TFile.Exists( IdFile.Str ) then TListen.TestEnterFileUnit( IdFile, 'System.pas', pFirstFile, b, pDummy )
      end;
    if b then begin
      NotFoundFiles.Clear;
      include( pFirstFile^.fiFlags, tFileFlags.LibraryPath );
      TListen.EnterFileUnitMinimal( 0 );
      ParseUnitHeaderAndUses1     ( 0 );
      ParseUnitInterfaceAndUses2  ( pFirstFile );
      inc( SaveLast );
      { für SourceFile neu vorbereiten: }
      FillChar( IdFile.Pos, sizeOf( tFilePos ), 0 );
      pAktUnit   := nil;
      IdFile.Str := fn
      end
    else
      Error( errSystemPas, cSystemRef )
    end;
  TListen.TestEnterFileUnit( IdFile, TPath.GetFileNameWithoutExtension( fn ), pFirstFile, b, pDummy );
  repeat
    CollectAllHeaders( SaveLast );       // alle in bekannten Dateien referenzierten Units sammeln und Header einlesen
    if ( ProgType <> kw_UNIT ) and ( SaveLast = SaveLast_ {erster Durchgang} ) then
      { nur Units haben einen interface-Teil, sonst die Start-Datei überspringen }
      inc( SaveLast );
    SaveLast_ := high( DateiListe );        // jetzige Anzahl merken
    ParseAllInterfaces( SaveLast, SaveLast_ );   // für diese Units das Interface parsen UND schon die implementation-Uses
    SaveLast := SaveLast_+1;
  until SaveLast_ = high( DateiListe );         // bis keine neuen Dateien mehr hinzugekommen sind

  if ProgType <> kw_CONST then           // DeclaresOnly sind schon per ParseDeclarations( do_Implementation ) erfasst
    ParseAllUnitImplementations;

  GuiParser.RepaintLstBox()
end;

{$ENDREGION }

{$REGION '-------------- TParser ---------------' }

procedure ParserPreParse;
begin
  ProgType := kw_UNIT;
  ResetZaehler;

  if TFile.Exists( IniErrName + cExtErr) then
    TFile.Delete ( IniErrName + cExtErr );

  PreParseExpressions;
  PreParseStatements
end;

{ TParser.Parse }
class function TParser.Parse( const f: string; rl: TProc ): boolean;
var s:  string;
    vi,
    i :  integer;
    ip: tIdPosInfo;
    p : pIdInfo;

  procedure WriteErrorData( const m: string );
  const cTrenn  = '   ';
  var r  : boolean;
      i  : integer;
      dat: textfile;
  begin
    {$IFDEF TraceDx} TraceDx.Call( uParse, 'WriteErrorData', m ); {$ENDIF}
    assignFile( dat, IniErrName + cExtErr );

    r := true;
    try rewrite( dat ) except r := false end;
    if r then
      try     writeln( dat, m );
              if pAktFile <> nil then with pAktFile^ do begin
                writeln( dat );
                writeln( dat, 'pAktFile = ' + FileName + cTrenn + 'Line=' + li.ToString + cTrenn + 'Column=' + ri.ToString );
                for i := li-3 to li do
                  if ( i >= 0 ) and ( i <= high( StrList )) then
                    writeln( dat, 'Line', i:5, ':', cTrenn + StrList[i] );
                end;
              if AktDeclareOwner <> nil then
                writeln( dat, sLineBreak + 'AktBlock = ' + TListen.getBlockNameLongMain( AktDeclareOwner, dTrennView ));
              writeln( dat );
              if pAktUnit <> nil then begin
                write  ( dat, 'Compiler-Defines (' + ( DefinesHigh + 1 ).ToString + ') = ' );
                for i := 0 to DefinesHigh           do write( dat, Defines[i] + cPlusMinus[SymbolDefined( i )] + cTrenn ); writeln( dat );
                end;
              write  ( dat, 'Not found files  (' + NotFoundFiles.Count.ToString + ') = ' );
              for i := 0 to NotFoundFiles.Count-1 do write( dat, NotFoundFiles [i] +                           cTrenn  ); writeln( dat );
              writeln( dat );
              if NotImplemented <> sLineBreak then
                writeln( dat, '$IF-Problems:', NotImplemented )
      finally
              closefile( dat )
      end
  end;

begin
  {$IFDEF TraceDx} TraceDx.Clear; TraceDx.Call( uParse, 'TParser.Parse' ); {$ENDIF}
  Result := false;
  GuiParser.RepaintLstBox := rl;

  { Include-Paths aus Optionen übernehmen: }
  IncludesUnit    := FileOptions.SearchPathUnitNoMacro   .Split( [ TPath.PathSeparator ] );
  IncludesUnitLib := FileOptions.SearchPathUnitLibNoMacro.Split( [ TPath.PathSeparator ] );
  if FileOptions.EnableDelphiLib then
    IncludesUnitLib := IncludesUnitLib + FileOptions.SearchPathDelphiNoMacro.Split( [ TPath.PathSeparator ] );

  IncludesUnitAll := ['']{für Projekt-Dir}      + IncludesUnit + IncludesUnitLib;
  IncludesI       := ['']{für aktuelleUnit-Dir} + IncludesUnit + IncludesUnitLib;   // NICHT IncludeUnitsAll zuweisen, das wäre nur ein zweiter Name!

  { vordefinierte Compiler-Defines: }
  Defines     := FileOptions.DefinedSymbols.Split( [ TPath.PathSeparator ] );
  DefinesHigh := high( Defines );
  if Defines[DefinesHigh] = EmptyStr then
    dec( DefinesHigh );      // falls in ini mit ";" abgeschlossen wird entsteht ein Leer-Element am Ende -> löschen
  { ab VER230 (XE2) ist DCC immer definiert
  if Defines[1] >= 'VER230' then begin
    inc( DefinesHigh );
    Defines[DefinesHigh] := 'DCC'
    end;}
  assert( DefinesHigh < cDefinesBits, 'zu viele Defines' );
  SetLength( Defines, cDefinesBits );
  UserDefines := DefinesHigh + 1 - cPreDefines;

  try
    pAktUnit := @FirstUnit;   // Dummy mit Flag für die Pre-ParserStart-InsertId()-Aufrufe
    { allgemeine Inits }
    TListen .PreParse;
    TScanner.PreParse;
    ParserPreParse;
    ParserState.ReParse := true;    // das (evtl überflüssige) Erst-PreParse ist durch, ab jetzt ReParse

    { Unit-Namespaces: }
    {$IFDEF UnitPrefixe}
    UnitPrefixes := [''];
    if FileOptions.EnableUnitPrefix and ( FileOptions.UnitPrefix <> '' ) then begin
      UnitPrefixes := UnitPrefixes + FileOptions.UnitPrefix.Split( [ TPath.PathSeparator ] );
      if UnitPrefixes[high( UnitPrefixes )] = EmptyStr then
        SetLength( UnitPrefixes, high( UnitPrefixes ) - 1 );      // falls in ini mit ";" abgeschlossen wird entsteht ein Leer-Element am Ende -> löschen

      for i := 1 to high( UnitPrefixes ) do begin
        p := @MainBlock[mbBlock0];
        for s in UnitPrefixes[i].Split( ['.'] ) do begin
          p := TListen.InsertId( s, p, id_NameSpace, false );    // dieser Insert findet unten falls $IFDEF PseudoFile nochmals statt. Ist aber kein Problem.
          p^.AcSet := cAcDummyUsed
          end;
        TListen.InsertIdPtr( GueltigListe, p, 0, 0 )           // Unter diesen Namespaces muss auch gesucht werden!
        end;
      for i := 1 to high( UnitPrefixes ) do UnitPrefixes[i] := UnitPrefixes[i] + '.'
      end;
    {$ENDIF}

    { SearchPaths nach mbFilenames übernehmen: }
    for i := 1 to high( IncludesUnitAll ) do begin
      s := IncludesUnitAll[i];
      s := '[ ' + TPath.GetFileName( s.Substring( 0, length( s ) - 1 )) + ' ]';
      TListen.InsertId( s, @MainBlock[mbFilenames], id_FileLibrary, false )^.AcSet := cAcDummyUsed
      end;
    TListen.InsertId( '[not found]', @MainBlock[mbFilenames], id_FileLibrary, false )^.AcSet := cAcDummyUsed;
    pPathIds := MainBlock[mbFilenames].SubBlock;
    MainBlock[mbFilenames].SubBlock := nil;
    MainBlock[mbFilenames].SubLast  := nil;

    {$IFDEF PseudoFile}
    { Virtuelle Datei mit Optionen aus Ref und IDE in bauen und IdAcs eintragen: }
    pAktUnit := @FirstUnit;                       // Dummy mit Flag für die Pre-ParserStart-InsertId()-Aufrufe
    AktDeclareOwner := @MainBlock[mbDefines];
    SetLength( PseudoFile, 4 + DefinesHigh + 4 + high( UnitPrefixes ) * 3 );
    TListen.AddFile( cDefinesFile, false );
    PseudoFile[1] := '// Daten aus Projekt-Optionen als Pseude-Code:';
    PseudoFile[3] := '// Teil A:   Defines aus den Ref-Optionen:';
    for i := 0 to DefinesHigh do begin
      PseudoFile[4+i] := '{$DEFINE ' + Defines[i] + ' }';
      ip.Pos.Datei := high( DateiListe ); ip.Pos.Zeile := 4+i; ip.Pos.Spalte := 9; ip.Pos.Laenge := length( Defines[i] );
      p := TListen.InsertId( Defines[i], AktDeclareOwner, id_CompilerDefine, false );
      TListen.AddAc( p, nil, ip.Pos, ac_Write )
      end;
    vi := 4 + DefinesHigh + 2;

    {$IFDEF UnitPrefixe}
    PseudoFile[vi-1] := '';
    PseudoFile[vi] := '// Teil B:   Gültigkeitsbereiche aus den Ref-Optionen:';
    inc( vi );
    for i := 1 to high( UnitPrefixes ) do begin
      PseudoFile[vi] := 'uses ' + UnitPrefixes[i] + '*;';
      ip.Pos.Spalte := 5;
      p  := @MainBlock[mbBlock0];
      for s in UnitPrefixes[i].Split( ['.'] ) do if s <> '' then begin
        ip.Str := s; ip.Pos.Zeile := vi; ip.Pos.Laenge := length( s );
        p := TListen.InsertIdAc( ip, p, id_NameSpace, ac_Read );
        inc( ip.Pos.Spalte, ip.Pos.Laenge + 1 );
        end;
      inc( vi );
      end;
    {$ENDIF}
    SetLength( PseudoFile, vi );
    DateiListe[high( DateiListe )].StrList := PseudoFile;
    pAktUnit := nil;
    {$ENDIF}

    { Jetzt geht's los }
    ParserStart( f );
    Result := true
  except
    {$if not (defined(Ref) and defined(Release))}
    on E: Exception do
      WriteErrorData( E.Message )
    {$IFEND}
  end;
  {$IFDEF FinalChecks}
    if Result then
      try TListen.FinalChecks except Error( errFinalChecks, '' ); Result := false end;
  {$ENDIF}
end;

{$ENDREGION }

{$REGION '-------------- Init ---------------' }

(* TParser.Init *)
class procedure TParser.Init;
{var k: tKeyWord;
    s: string;}
begin
  {$IFDEF TraceDx} TraceDx.Call( Self, 'Init' ); {$ENDIF}
  ParserState.ReParse := false;
  { Kontroll-Ausgabe ob OpPrios richtig zugeordnet sind:
  s := 'cOpPrio =';
  for k := low( tKeyWord ) to high( tKeyWord ) do
    if cOpPrio[k] <> 0 then
      s := s + sLineBreak + cOpPrio[k].ToString + ' ' + GetKeyWordText( k );
  ShowMessage( s ) }
end;

initialization

finalization

{$ENDREGION }

end.
