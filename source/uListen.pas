
unit uListen;

{$INCLUDE _CompilerOptionsRef.pas}
{$INCLUDE _CompilerOptions}
{ $UNDEF TraceDx}
{ $DEFINE HEAPCHECK }

interface

uses
  System.Classes,
  System.SysUtils,
  VCL.ComCtrls,
  uGlobalsParser;

const
  id_DummyProc  = id_Proc;
  cGenericDummy = '<->';

  gMaxAcSeq     =  80;      // das sollte locker immer reichen für Ac-Folge pro ParseIdentifier()
  gMaxIdSeq     = 250;      // das sollte locker immer reichen für Id-Folge pro ParseIdentifier()

type
  tIdSeqIndex = integer;

  tIdSeq  = record
              Stack: packed array[0..gMaxIdSeq] of
                       record IdpId  : pIdInfo;      // ParseExpression() legt hier die Id-Ac-Type-Folge ab. Auch geschachtelt! Und ...
                              AcStart,               // ... SearchIdentifier() legt hier overloads zu einem Such-Id ab
                              AcEnde : tAcSeqIndex
                       end;
              MaxPegel,
              Pegel: tIdSeqIndex;
              procedure PreParse;
              procedure Add( pId: pIdInfo; start,ende: tAcSeqIndex );
              procedure Del( idx: tIdSeqIndex );
            end;

  TListen = record
              class procedure Init( sf: tProcString ); static;
              class procedure DisposeFileInfo( f: pFileInfo ); static;
              class procedure xDeleteUserSystemAcs; static;
              class procedure PreParse; static;
//              class function  getAcNameLong( pAc: pAcInfo; const Trenn: string): string; static;
              class procedure SetAcPrev( LastAc: pAcInfo; var pAcPrev: pAcInfo ); static;
              class function  getBlockNameLong( b: pIdInfo; const Trenn: string ): string; static;
              class function  getBlockNameLongMain(b: pIdInfo; const Trenn: string): string; static;
              class function  ShowAcSet( ac: tAcTypeSet ): string; static;
              class function  pIdName( pId: pIdInfo ): string; static;
              class function  SearchAc( d: tFileIndex; z: tLineIndex; s: tRowIndex ): pAcInfo; static;
              class procedure SaveToFile( const f: string ); static;

              class procedure NewAc( var p: pAcInfo ); static;    // -> private
              class procedure incAcPtr( var pAc: pAcInfo ); static;
              class procedure FreeAc( pAc: pAcInfo ); static;
              class procedure FinalChecks; static;
              class procedure FreeIdAcSub( pKillMain: pIdInfo; KillMainId: boolean ); static;
              class procedure FreeIdAcSub_Ausketten( Kill: pIdInfo ); static;

              class function  InsertFileId( iLib: tLibraryIdx; f: tIdPosInfo ): pIdInfo; static;
              class procedure TestFileInclude( f: tIdPosInfo; Enter: boolean ); static;
              class function  TestEnterFileUnit(f: tIdPosInfo; u: tIdString; out pFile: pFileInfo; out newFile: boolean; out pIdUses: pIdInfo ): boolean; static;
              class procedure EnterFileUnitMinimal( fi: tFileIndex ); static;
              class procedure AddFile( const s: tFileString; Enter: boolean ); static;
              class procedure AddDefinesToFiles; static;
              class function  SearchUnitFile( pUnit: pIdInfo ): tFileIndex_; static;
              class procedure PauseUnit; static;
              class procedure ReEnterFileUnit( fi: tFileIndex ); static;
              class procedure LeaveFile       ; static;
              class procedure LeaveFileMinimal; static;

              class procedure EnterBlock( pId: pIdInfo ); static;
              class procedure LeaveBlock;                 static;

              class procedure InsertIdPtr( var ptrListe: pIdPtrInfo; pIdNeu: pIdInfo; s,e: tAcSeqIndex ); static;
              class procedure ClearIdPtrList( var ptrListe: pIdPtrInfo ); static;
              class procedure LeaveWith; static;

              class procedure SetRealGenericTypes( Source, Dest: pIdInfo; IdPegel: tIdSeqIndex ); static;

              class procedure InsertVirtualId  ( pIdDest: pidInfo; b: pIdInfo ); static;
              class procedure InsertVirtualEnum( pIdDest: pidInfo             ); static;
              class procedure SetIdTypeClass( pId: pidInfo             ); static;

              class function  GetTypeNr: tTypeNr; static;
              class procedure CopyTypeInfos( pSource, pDest: pIdInfo ); static;
              class procedure CopyVarTypeInfos( pSource, pDest: pIdInfo); static;

              class function  SucheUnitId( b: pIdInfo; h: tHash; const IdStr: tIdString): pIdInfo; static;
              class function  SucheIdInBloecken( h: tHash; const IdStr: tIdString ): pIdInfo; static;
              class function  SucheIdUnterId(  b: pIdInfo; h: tHash; const IdStr: tIdString; SearchVirtuals: boolean ): pIdInfo; static;
              class procedure SetIdProjectUse( pId: pIdInfo ); static;
              class procedure AddAc( pId: pIdInfo; pAc: pAcInfo; const Pos: tFilePos; AcType: tAcType ); static;
              class procedure SetIdGeneric( pId: pIdInfo; a: word ); static;
              class function  InsertId  ( const IdStr: string; b: pIdInfo; IdType: tIdType; followVirtual: boolean ): pIdInfo; static;
              class function  InsertIdAc( const Id: tIdPosInfo; b: pIdInfo; IdType: tIdType; AcType: tAcType ): pIdInfo; static;
              class procedure IncAc( var pAc: pAcInfo; var ai, aii: word ); static;
              class function  SearchNextFileAc( d: tFileIndex; z: tLineIndex; var ai, aii: word ): pAcInfo; static;
              class function  GetParam1( pId: pIdInfo ): pIdInfo; static;

              {$IFDEF TraceDx}
              class function  CalcSignatur( pIdDecl: pIdInfo ): tSignatur; static;
              {$ENDIF}
              class function  getBaseType( pId: pIdInfo): pIdInfo; static;
              class function  InsertOverloadId( var pIdDecl: pIdInfo; pIdStart: pIdInfo ): boolean; static;

              class procedure ChangeAcType( pAc: pAcInfo; NewAc : tAcType ); static;
              class procedure ChangeIdType( pId: pIdInfo; NewTyp: tIdType ); static;
              class procedure SetAsGenType( pId: pIdInfo; TypNr: tTypeNr ); static;
//              class procedure CopySubAll( Source, Dest: pIdInfo ); static;
              class procedure CopySub( Source, Dest: pIdInfo ); static;
              class procedure SetSubConst( pId: pIdInfo ); static;
              class procedure DeleteAc( pAc: pAcInfo; forget: boolean ); static;
              class procedure MoveAc  ( pAc: pAcInfo; pIdNeu: pIdInfo); static;
              class procedure CopyLastAc( pIdFrom, pIdTo: pIdInfo ); static;
              class procedure CaptureSubIds( pIdOwner: pIdInfo ); static;
              class procedure MoveLastAcsUp( pId: pIdInfo; pAcEnde: pAcInfo ); static;
//              class procedure MoveGUID( pIdLastAlt: pIdInfo); static;

              class procedure TestIdForUnbekannt( pIdBekannt, pIdUnbekannt: pIdInfo ); static;
            end;

  THelper = record
              ImplHelpers: pIdInfo;   // die Kette aller Helper aus Unit-Interfaces hängt unter UnitInfo; hier nur die aus der aktuellen Unit-Implementation
//              class procedure TestForHiddenIds( Helper, helped: pIdInfo ); static;
//              class procedure ResetHiddenIds( helped: pIdInfo ); static;
              class procedure SetUnitHelpersToTypes( pIdHelp: pIdInfo ); static;
              class procedure ReSetUnitHelpersToTypes( pIdHelp: pIdInfo ); static;
            end;

  tAcSeq  = record
              Stack: packed array[0..gMaxAcSeq] of pAcInfo;   // ParseIdentifier() legt hier die Ac-Folge ab. Auch geschachtelt!
              MaxPegel,
              Pegel: tAcSeqIndex;
              procedure PreParse;
              procedure Add( pAc: pAcInfo );
              procedure WithUsed( w: pIdPtrInfo );
              procedure WasPointerOrArray;
//              procedure ChangeAcToResult  ( start: tAcSeqIndex );
              procedure ChangeAcEndToWrite( start: tAcSeqIndex; ac: tAcType );
              procedure ChangeAcToWrite  ( start,ende: tAcSeqIndex; ac: tAcType );
              procedure ChangeAcToUnknown ( start,ende: tAcSeqIndex );
              procedure BuildAcChain( start: tAcSeqIndex );
            end;

  tIdArray       = packed array[0..gMinInfoCount] of tIdInfo;
  tIdAcArrayIdx  = word;

var
  IdArray0       : tIdArray;
  StdNameSpace   : pIdInfo;
  LastId,
  NextId         : tIdPosInfo;
  UserDefines    : word;           // fürs Projekt zusätzlich zu cPreDefines per ini definierte Symbole
  UseClipBoard   : boolean;
  pAktUnit       : pFileInfo;
  FreeIdList     : pIdInfo;
  FreeAcList     : pAcInfo;
  AktDeclOwnerEnum,
  AktDeclareOwner: pIdInfo;
  GueltigListe,
  WithListe      : pIdPtrInfo;
  AcSequenz      : tAcSeq;
  IdSequenz      : tIdSeq;
  {$IFDEF TestKompatibel}
    CompErrorList  : tStringList;
  {$ENDIF}
  Helper         : THelper;
  ParserState    : record                      // leider sind Parser-Kontext-Infos für andere Komponenten notwendig
                     ReParse        : boolean;
                     Statement,                // -> für overload-Auswertung
                     DeclAnonym     : word;
                     RecordLevel    : word;    // -> innerhalb Records deklarierte Enum-Bez werden auf der Record-Ebene gespeichert und gesucht
                     ParseTypeLevel : word;
                     AssemblerCode  : boolean; // -> für Scanner: "'" ist char
                     Implementations,          // -> für helper-export-Zuordnung
                     SearchOverload,           // -> für SucheId(): der erste gefundene war ein overload, mindestens noch eine Ebene höher suchen
                     ParseNoVar,               // -> für SucheIdImBlock(), löst enum-scope-Problem
                     TypeId_Needed,            // -> für Suche nur nach Id mit id_Type (oder Unit/Namespace/Unbekannt)
                     PropReadWrite,            // -> bin im property-read oder -write, hier muss ggf auch im non-Statement nach overloads gesucht werden
                     MayBeResult,              // -> für Umwandlung FktName in Result, false ausser vor :=
                     AssignMethod,             // -> für ParseExpression, pFunc := funcVar
                     ExportsClause,            // -> für ParseIdentifier, overload-exports-Parameter vom Aufrufer auswerten
                     DeclareType    : boolean; // -> für Scanner um ^G (char) und ^P (Pointer) zu unterscheiden
                     LastTypeOwner  : pIdInfo; // -> vor Ptr-Fortsetzung auf Typ erst nochmal speichern für Suche nach Helper
                   end;

procedure ResetZaehler;
function  GetHash( const Id: tIdString ): tHash;

implementation

uses
  {$IFDEF TraceDx} uTraceDx, {$ENDIF}
  Winapi.Windows,
  System.IOUtils,
  UtilitiesDx,
  VCL.Forms,
  VCL.Clipbrd,
  VCL.Dialogs,   { ShowMessage }
  uSystem, uGlobals,
//  ufReferenz,     // nur für frmMain.mItmOptionsSourcePathIni.Checked
  {$IFDEF HEAPCHECK } uHeapCheck, {$ENDIF}
  uScanner;

const
  dVirtualKennung   = '0_';   // nur zur Erkennung virtueller Ids im Array am veränderten Namen
  cDontCopyFlags    = [{NoCopy, }IsGenericDummy, fromSystemLib, IsCopySource, IsGenericType, IsParameter];
  cPrivacyFlags     = [IsStrict, IsPrivate, IsProtected];

var
  {$IFDEF TestHash}
  ZaehlerHash   : array [tHash] of tHash;
  NameHash      : array [tHash] of tIdentifierString;
  {$ENDIF}
  saCache       : pAcInfo;

type
  {$IFDEF TraceDx} uList = class end; {$ENDIF}
  tAcArray      = array[0..gMinInfoCount shl 2] of tAcInfo;
  pIdArray      = ^tIdArray;
  pAcArray      = ^tAcArray;


var
  ShowFile      : tProcString;
  NextIdIndex   : tIdAcArrayIdx = 0;
  NextAcIndex   : tIdAcArrayIdx = 0;
  NextIdIndex_  : tIdAcArrayIdx = 0;        // nach Init Keywords und System
  VirtualCount  : integer;
  CntIdCompares,
  HashCollisions: longword;

  AcArray0      : tAcArray;

  IdArrays      : array of pIdArray;
  AcArrays      : array of pAcArray;


procedure TestAbbruch;
begin
  {$IFNDEF RefBatch}       // <Escape> kann auch noch vom Abbruch eines anderen Programms kommen ...
  Application.ProcessMessages;
  if TKeyboard.KeyAsync( VK_ESCAPE ) then begin
    Abbruch    := true;
    AbbruchMsg := '  Canceling ...'
    end;
  GuiParser.RepaintLstBox()
  {$ENDIF}
end;

{$REGION '-------------- Init ---------------' }

class procedure TListen.Init( sf: tProcString );
begin
  ShowFile := sf
end;

{$ENDREGION }

{$REGION '-------------- Speicher ---------------' }

{ NewId }
procedure NewId( var p: pIdInfo; const n: string );
begin
  if FreeIdList = nil then begin
    if NextIdIndex > high( tIdArray )then begin
      {$IFDEF TraceDx} TraceDx.Call( uList, 'NewIdArray', NextIdIndex ); {$ENDIF}
      SetLength( IdArrays, high( IdArrays )+2 );
      new( IdArrays[high( IdArrays )] );               // nächstes Id-VerwaltungsElement holen
      {$IFDEF HEAPCHECK} HeapCheck.new( IdArrays[high( IdArrays )], sizeOf( IdArrays[high( IdArrays )]^ ) ); {$ENDIF}
      FillChar( IdArrays[high( IdArrays )]^, sizeOf( IdArrays[high( IdArrays )] ^), 0 );
      NextIdIndex := 0
      end;
    p := @IdArrays[high(IdArrays)]^[NextIdIndex];
    assert( ( p^.SubBlock = nil ) and ( p^.IdFlags = [] ) and ( p^.NextId = nil ) );    // Sicherheitsabfrage ob WIRKLICH genullt
    {$IFDEF DEBUG} p^.DebugNr := high( IdArrays ) * high( tIdArray ) + NextIdIndex; {$ENDIF}
    inc( NextIdIndex )
    end
  else begin                         // aus der Liste der zurückgegebenen holen
    p := FreeIdList;
    FreeIdList := FreeIdList^.NextId;
    p^.NextId  := nil;
    p^.IdFlags := []
    end;
  p^.Name := n
end;

{ FreeId }
procedure FreeId( pId: pIdInfo );
var    okay: boolean;
       {$IFDEF DEBUG}
       dbNr: tDebugNr;
       {$ENDIF}
begin
  okay := ( NextIdIndex > 0 ) and                                        // sonst war gerade der Wechsel zum nächsten IdArrays[]
          ( pId = @IdArrays[high(IdArrays)]^[NextIdIndex-1] );
  {$IFDEF TraceDx}
    TraceDx.Call( uList, 'FreeId ' + cPlusMinus[okay] + ' ' + pId^.Name );
    VerifyDx.IncHide;          // Adresse ist jedes Mal unterschiedlich
    TraceDx.Add( '', pId );
    VerifyDx.DecHide;
  {$ENDIF}

  assert( pId^.SubBlock = nil );
  assert( pId^.AcList   = nil );
  pId^.Name := '';    // sonst Speicher-Leck
  assert( ZaehlerId[pId^.Typ] > 0 );
  dec( ZaehlerId[pId^.Typ] );
  dec( ZaehlerIds );
  {$IFDEF DEBUG}
  dbNr := pId^.DebugNr;     // retten
  {$ENDIF}
  FillChar( pId^, sizeof( tIdInfo ), 0 );
  {$IFDEF DEBUG}
  pId^.DebugNr := dbNr;
  {$ENDIF}

  if okay then
    dec( NextIdIndex )
  else begin
    pId^.NextId := FreeIdList;
    pId^.IdFlags := pId^.IdFlags + [tIdFlags.IsDummy, tIdFlags.IdUnused ];
    FreeIdList := pId
    end;
end;

{ NewAc }
class procedure TListen.NewAc( var p: pAcInfo );
begin
  if NextAcIndex > high( tAcArray )then begin
    {$IFDEF TraceDx} TraceDx.Call( uList, 'NewAcArray', NextAcIndex ); {$ENDIF}
    SetLength( AcArrays, high( AcArrays )+2 );
    new( AcArrays[high( AcArrays )] );       // nächstes Access-VerwaltungsElement holen
    {$IFDEF HEAPCHECK} HeapCheck.new( AcArrays[high( AcArrays )], sizeOf( AcArrays[high( AcArrays )]^ )); {$ENDIF}
//    FillChar( AcArrays[high( AcArrays )]^, sizeOf( AcArrays[high( AcArrays )] ^), 0 );      Heap ist immer genullt
    NextAcIndex := 0
    end;
  p := @AcArrays[high(AcArrays)][NextAcIndex];
//  fillchar( p^, sizeof( tAcInfo ), 0 );
  {$IFDEF DEBUG} p^.DebugNr := high( AcArrays ) * high( tAcArray ) + NextAcIndex; {$ENDIF}
  inc( NextAcIndex )
end;

class procedure TListen.incAcPtr( var pAc: pAcInfo );
var i: tIdAcArrayIdx;
begin
  // könnte verbessert werden: nur auf = Chunk-Ende prüfen
  i := 0;
  while ( i < high( AcArrays ) ) and
        (( UIntPtr( pAc ) < UIntPtr( @AcArrays[i][0] )) or ( UIntPtr( pAc ) > UIntPtr( @AcArrays[i][high(tAcArray)] ))) do
    inc( i );
  if pAc = @AcArrays[i][high(tAcArray)]
    then pAc := @AcArrays[i+1][0]
    else inc( pAc )
end;

{ FreeAc }
class procedure TListen.FreeAc( pAc: pAcInfo );
var    okay: boolean;
begin
  okay := ( NextAcIndex > 0 ) and                                        // sonst war gerade der Wechsel zum nächsten IdArrays[]
          ( pAc = @AcArrays[high(AcArrays)][NextAcIndex-1] );
  {$IFDEF TraceDx} TraceDx.Call( uList, 'FreeAc' + cPlusMinus[okay] + ' unter ' + pAc^.IdDeclare^.Name, UIntPtr( pAc ).toHexString( 8 ) ); {$ENDIF}
  assert( ZaehlerAc[pAc^.ZugriffTyp] > 0 );
  dec( ZaehlerAc[pAc^.ZugriffTyp] );
  dec( ZaehlerAcs );
  if okay then begin
    dec( NextAcIndex );
    FillChar( pAc^, sizeOf( tAcInfo ), 0 )
    end
  else    // ReUse nicht möglich, Ac-Speicher geht verloren
    pAc^.AcFlags := pAc^.AcFlags + [tAcFlags.DontFind, tAcFlags.AcUnused]
end;

{ FinalChecks }
class procedure TListen.FinalChecks;
var i,j,max: tIdAcArrayIdx;
    pId    : pIdInfo;
    pAc    : pAcInfo;
    s1     : tIdType;
    s2     : tAcType;
    sum    : longword;

  function ErrorInSubBlock( pIdOwner: pIdInfo ): boolean;
  var pId: pIdInfo;
  begin
    Result := false;
    pId := pIdOwner^.SubBlock;
    while pId <> nil do
      if ( ( pId^.IdFlags * [tIdFlags.fromSystemLib,tIdFlags.IsParameter] <> [tIdFlags.fromSystemLib,tIdFlags.IsParameter] )   // SystemProcParas haben keinen prevBlock
                  and ( pId^.PrevBlock <> pIdOwner ))                                                                          or
         ( tIdFlags.IdUnused in pId^.IdFlags )
        then exit( true )                  // Sub-Id ist deleted
        else if ( pId^.NextId = nil ) and ( pId <> pidOwner^.SubLast )
               then exit( true )           // der über Next erreichte letzte ist nicht der LastId des Parent
               else pId := pId^.NextId
  end;

  function ErrorInAcList( pIdOwner: pIdInfo ): boolean;
  var pAc: pAcInfo;
  begin
    Result := false;
    pAc := pIdOwner^.AcList;
    while pAc <> nil do
      if ( pAc^.IdDeclare <> pIdOwner )        or
         ( tAcFlags.AcUnused in pAc^.AcFlags )
        then exit( true )
        else if ( pAc^.NextAc = nil ) and ( pAc <> pIdOwner^.LastAc )
               then exit( true )           // der über Next erreichte letzte ist nicht der LastAc des Parent
               else pAc := pAc^.NextAc
  end;

begin
  {$IFDEF TraceDx} TraceDx.Call( uList, 'FinalChecks' ); {$ENDIF}

  sum := 0;
  for s1 := id_Unbekannt to id_PascalDirective do inc( sum, ZaehlerId[s1] );
  if sum <> ZaehlerIds - ZaehlerId[id_Impl] - ZaehlerId[id_Virtual] - ZaehlerId[id_Filename] - ZaehlerId[id_FileLibrary] then
    {$IFDEF DEBUG}
      asm int 3 end;
    {$ELSE}
      ShowMessage( 'FinalChecksIdSum ' + sum.toString );
    {$ENDIF}

  sum := 0;
  for s2 := ac_Declaration to ac_Unknown do inc( sum, ZaehlerAc[s2] );
  if sum <> ZaehlerAcs then
    {$IFDEF DEBUG}
      asm int 3 end;
    {$ELSE}
      ShowMessage( 'FinalChecksAcSum ' + sum.toString );
    {$ENDIF}

  for i := 0 to high( IdArrays ) do begin
    pId := @IdArrays[i]^[0];
    if i = high( IdArrays )
      then max := NextIdIndex-1         // der letzte Id-Block wird zZ nur bis hierher genutzt
      else max := high( tIdArray );     // alle anderen bis zum Ende
    for j := 0 to max do if not ( tIdFlags.IdUnused in pId^.IdFlags ) then begin
      if ( tIdFlags.IdUnused in pId^.PrevBlock^.IdFlags )                               or
         ( ErrorInSubBlock( pId )                                                       or
         ( ( pId^.SubLast <> nil ) and ( pId^.SubLast^.NextId <> nil )))                or
         ErrorInAcList( pId )                                                           or
         (( pId^.MyType   <> nil ) and ( tIdFlags.IdUnused in pId^.MyType  ^.IdFlags )) or
         (( pId^.MyParent <> nil ) and ( tIdFlags.IdUnused in pId^.MyParent^.IdFlags )) or
         (( pId^.LastAc   <> nil ) and ( pId^.LastAc^.NextAc <> nil ))                   or
         false                                                                           then begin
        {$IFDEF TraceDx} TraceDx.Send( uList, 'FinalChecks Id', pId^.Name ); {$ENDIF}
        {$IFDEF DEBUG}
          asm int 3 end;
        {$ELSE}
          ShowMessage( 'FinalChecksId ' + pId^.Name )
        {$ENDIF}
        end;
      inc( pId )
      end
    end;

  for i := 0 to high( AcArrays ) do begin
    pAc := @AcArrays[i]^[0];
    if i = high( AcArrays )
      then max := NextAcIndex-1         // der letzte Id-Block wird zZ nur bis hierher genutzt
      else max := high( tAcArray );     // alle anderen bis zum Ende
    for j := 0 to max do if not ( tAcFlags.AcUnused in pAc^.AcFlags ) then begin
      if ( tIdFlags.IdUnused in pAc^.IdUse^.IdFlags + pAc^.IdDeclare^.IdFlags )  or
         false                                                                   then begin
        {$IFDEF TraceDx} TraceDx.Send( uList, 'FinalChecks Ac', pAc^.IdDeclare^.Name, pAc^.IdUse^.Name ); {$ENDIF}
        {$IFDEF DEBUG}
          asm int 3 end
        {$ELSE}
          ShowMessage( 'FinalChecksAc ' + pAc^.IdDeclare^.Name + ' ' + pAc^.IdUse^.Name )
        {$ENDIF}
        end;
      inc( pAc )
      end
    end;

end;

{$ENDREGION }

{$REGION '-------------- Dateien ---------------' }

{ AddFile }
class procedure TListen.AddFile( const s: tFileString; Enter: boolean );
var f: pFileInfo;
begin
  {$IFDEF TraceDx} TraceDx.Call( uList, 'AddFile', high( DateiListe ) ); {$ENDIF}
  new( f );
  {$IFDEF HEAPCHECK} HeapCheck.new( f, sizeOf( f^ ) );  {$ENDIF}
  { Speicher ist NICHT genullt !!! }
  FillChar( f^, sizeOf( tFileInfo ), 0 );
  with f^ do begin
    MyIndex   := high( DateiListe ) + 1;
    MyUnit    := nil;
    FileName  := s;
    try
      if UseClipBoard and ( high( DateiListe ) = -1 ) then begin
        FileDatum := 0;
        StrList   := Clipboard.AsText.Split( [sLineBreak, #10] )
        end
      else if s = cDefinesFile then
        // Virtuelle Datei mit Compiler-Defines aus Projekt-Optionen
        else begin
          FileDatum := TFile.GetLastWriteTime( s );
          if Enter then StrList := TFile.ReadAllLines( s )
          end
    except
      ShowMessage( 'Can''t load file ' + s )
    end;
    prevFile := cKeinFileIndex;
    if Enter then JumpFirstLine( f );
    { für Compiler-Defines: }
    SetLength( CompDefines, ( DefinesHigh div cDefinesBits ) + 1 );    // normalerweise 1 Element. Falls aber mehr als 32 Defines existieren: entsprechend mehr Platz reservieren
    PCardinal( @CompDefines[0] )^ := ( 1 shl ( cPreDefines + UserDefines ) ) - 1;      // [0,1,2] für WINDOWS, VERxxx, DEBUG
    { für Compiler-Options: }
    IfOptLokal := IfOptGlobal    // dort sind für lokale Options die Standardwerte
    end;
  SetLength( DateiListe, high( DateiListe ) + 2 );
  DateiListe[high( DateiListe )] := f;
  if high( DateiListe ) and 7 = 1 then TestAbbruch
end;

{ AddDefinesToFiles }
class procedure TListen.AddDefinesToFiles;
{ die FileInfos werden mit Platz für 32 Defines-Bits erzeugt. Falls mehr benötigt wird: Hier jeweils 32 neue Bits hinzufügen. }
var i: tFileIndex;
    h: word;
begin
  h := high( DateiListe[0]^.CompDefines ) + 2;   // um ein Element (cDefinesBits=32 Bits) verlängern
  for i := 0 to high( DateiListe ) do
    SetLength( DateiListe[i]^.CompDefines, h )
end;

{ TListen.EnterFileUnitMinimal }                // nach TScanner
class procedure TListen.EnterFileUnitMinimal( fi: tFileIndex );
begin
  pAktFile   := DateiListe[fi];
  pAktUnit   := pAktFile;
  OverNextKw := pAktFile^.NextKeyword;
  NextId     := pAktFile^.NextIdInfo;
  ShowFile( pAktFile^.FileName )
end;

{ TListen.ReEnterFileUnit }                // aufgerufen nach "PauseUnit()"
class procedure TListen.ReEnterFileUnit( fi: tFileIndex );
begin
  pAktUnit     := DateiListe[fi];
  {$IFDEF TraceDx} TraceDx.Call( uList, 'ReEnterFileUnit', pAktUnit^.FileName ); {$ENDIF}
//  if pAktUnit^.NextFile <>
  pAktFile     := Dateiliste[pAktUnit^.NextFile];
  if pAktFile <> pAktUnit then begin
    pAktFile^.prevFile := pAktUnit^.MyIndex;
    pAktFile^.liMax := pAktUnit^.NextLiMax;
    pAktFile^.riMax := pAktUnit^.NextRiMax;
    pAktFile^.li    := pAktUnit^.NextLi;
    pAktFile^.ri    := pAktUnit^.NextRi;
    pAktFile^.pi    := pAktUnit^.NextPi
    end;
  OverNextKw   := pAktUnit^.NextKeyword;
  NextId       := pAktUnit^.NextIdInfo;
  ShowFile( pAktFile^.FileName )
end;

{ TListen.InsertFileId }
class function TListen.InsertFileId( iLib: tLibraryIdx; f: tIdPosInfo ): pIdInfo;
  var i: integer;
  begin
    if iLib = 0 then
      Result := TListen.InsertIdAc( f, @MainBlock[mbFilenames], id_Filename, ac_Read )
    else begin
      Result := pPathIds;
      for i := 2 to iLib do Result := Result ^.NextId;
      Result := TListen.InsertIdAc( f, Result, id_Filename, ac_Read )
      end;
  end;

{ TListen.TestEnterFileUnit }
class function TListen.TestEnterFileUnit( f: tIdPosInfo; u: tIdString; out pFile: pFileInfo; out newFile: boolean; out pIdUses: pIdInfo ): boolean;
var AnzahlDateien: tFileIndex_;
    fi           : tFileIndex;
    LibraryPath  : boolean;
    idxLibrary   : tLibraryIdx;
    Hash         : tHash;
    pId          : pIdInfo;
    sArr         : TArray<string>;

  {$IFDEF UnitPrefixe}
  { SearchUnitInPaths }
  function SearchUnitInPaths: boolean;
  var n: word;
  begin
    idxLibrary := 0;
    while idxLibrary <= high( IncludesUnitAll ) do begin
      n := 0;
      while n <= high( UnitPrefixes ) do
        if FileExists( IncludesUnitAll[idxLibrary] + UnitPrefixes[n] + f.Str ) then begin
          f.Str := ExpandFilename( IncludesUnitAll[idxLibrary] + UnitPrefixes[n] + f.Str );
          LibraryPath := idxLibrary > high( IncludesUnit ) + 1;    // dann aus IncludesIDE-Suchpfad

          if n > 0 then begin
            // Datei über Prefix-Ergänzung gefunden: Vollständigen Unit-Id richtig eintragen
            u := UnitPrefixes[n] + u;          // beides an Prefix
            Hash := getHash( u );              // ... anpassen
            sArr := UnitPrefixes[n].Split( ['.'] );
            SetLength( sArr, length( sArr ) - 1 );   // letztes Element ist leer
            var b: pIdInfo := @MainBlock[mbBlock0];   // Block für Eintragung des nächsten NameSpacae
            var uAlt: pIdInfo := b^.SubLast;             // hier war die Unit durch ParseIdentifierUnit() abgelegt worden
            for var s in sArr do begin
              pId := TListen.SucheUnitId( b, getHash( s ), s.ToLowerInvariant );
              if pId = nil
                then b := TListen.InsertId( s, b, id_NameSpace, false )    // kommt das erste Mal vor
                else b := pId                                              // war aus anderem uses schon bekannt
              end;
            pIdUses := TListen.InsertId( uAlt^.Name, b, id_Unit, false );  // pIdUses ist out-Parameter!
            // Ac war unter "Unbekannt"-Unit -> jetzt verschieben
            TListen.MoveAc( uAlt^.AcList, pIdUses );
            // "Unbekannt"-Unit mit NameSpaces wieder löschen
            var uNeu := pIdUses;
            while ( uAlt^.PrevBlock^.Typ      = id_NameSpace )             and
                  ( uAlt^.PrevBlock^.SubBlock = uAlt^.PrevBlock^.SubLast ) and
                  ( uAlt^.PrevBlock^.AcList   = uAlt^.PrevBlock^.LastAc  ) do begin
//              asm int 3 end
              ;
              uAlt := uAlt^.PrevBlock;
              uNeu := uNeu^.prevBlock;
              TListen.MoveAc( uAlt^.AcList, uNeu )
              end;
            TListen.FreeIdAcSub_Ausketten( uAlt )
            end;
          // Eintrag (auch für n=0) in DateiListe[] suchen:
          for var i := 0 to length( DateiListe ) - 1 do
            if DateiListe[i].FileName.ToLowerInvariant = f.Str.ToLowerInvariant then begin
              fi := i;
              pFile := DateiListe[fi];
              break
              end;

          exit( true )
          end
        else
          inc( n );
      inc( idxLibrary )
      end;

    { kommt unten nochmal vor, doppelt? }
    pId := pPathIds;
    while pId^.NextId <> nil do pId := pId^.NextId;     //  Block "[not found]"
    InsertIdAc( f, pId, id_Filename, ac_Read );

    if NotFoundFiles.IndexOf( f.Str ) = -1 then
      NotFoundFiles.Add( f.Str );
    Result := false
  end;
 {$ELSE}
  { SearchUnitInPaths }
  function SearchUnitInPaths: boolean;
  begin
    idxLibrary := 0;
    while idxLibrary <= high( IncludesUnitAll ) do begin
      if FileExists( IncludesUnitAll[idxLibrary] + f.Str ) then begin
        f.Str := ExpandFilename( IncludesUnitAll[idxLibrary] + f.Str );
        LibraryPath := idxLibrary > high( IncludesUnit ) + 1;    // dann aus IncludesIDE-Suchpfad
        exit( true )
        end
      else
        inc( idxLibrary )
      end;

    { kommt unten nochmal vor, doppelt? }
    pId := pPathIds;
    while pId^.NextId <> nil do pId := pId^.NextId;     //  Block "[not found]"
    InsertIdAc( f, pId, id_Filename, ac_Read );

    if NotFoundFiles.IndexOf( f.Str ) = -1 then
      NotFoundFiles.Add( f.Str );
    Result := false
  end;
 {$ENDIF}

  begin
  {$IFDEF TraceDx} TraceDx.Call( uList, 'TestEnterFileUnit', f.Str ); {$ENDIF}
  Result      := true;
  LibraryPath := false;
  NewFile     := false;
  Hash        := getHash( u );
//  if TPath.GetFileName( f ) = 'system.pas' then begin Error( errSystem ); exit end;
  fi := cFirstFile;
  AnzahlDateien := high( DateiListe );
  while fi <= AnzahlDateien do
    if ( DateiListe[fi]^.FileHash = Hash ) and ( DateiListe[fi]^.UnitName.ToLowerInvariant = u.ToLowerInvariant ) then begin
      pFile      := DateiListe[fi];
      idxLibrary := pFile^.LibraryNr;
      f.Str      := pFile^.FileName;
      InsertFileId( idxLibrary, f );
      exit
      end   // Unit schon bekannt
    else
      inc( fi );
  if not (( UseClipBoard and ( fi = 0 )) or SearchUnitInPaths ) then
    exit( false );   // Unit nicht vorhanden

  { File als Identifier eintragen: }
  if pAktUnit = nil
    then pId := InsertId( f.Str, @MainBlock[mbFilenames], id_Filename, false )
    else pId := InsertFileId( idxLibrary, f );
  pId^.AcSet := cAcDummyUsed;    // Damit's im tree erscheint
  pId^.IdFlags2 := [tIdFlags2.IdProjectUse];

  if fi = high( DateiListe ) + 1 then begin
    AddFile( f.Str, true );
    NewFile := true;
    pFile := DateiListe[fi];
    pFile^.UnitName := u;
    pFile^.FileHash := Hash;  // getHash( f.Str );
    pFile^.LibraryNr := idxLibrary;
    pFile^.MyFileId  := pId;
    if LibraryPath then
      pFile^.fiFlags := [tFileFlags.LibraryPath]
    end;
end;

{ TListen.TestFileInclude }
class procedure TListen.TestFileInclude( f: tIdPosInfo; Enter: boolean );
var AnzahlDateien,
    AltFileIndex: tFileIndex_;
    fi: tFileIndex;
    Hash: tHash;
    pId: pIdInfo;

  { SearchIncludeInPaths }
  function SearchIncludeInPaths: boolean;
  var fi: tFileIndex;
      pId: pIdInfo;
      RelDir: boolean;
  begin
    RelDir := TPath.IsRelativePath( LastId.Str );
    if not RelDir then
      Result := FileExists( f.Str )                     // absoluter Pfad -> NUR dort suchen
    else begin                                      // reletiver Pfad -> Dir der aktuellen Unit   UND   SuchPfade
      IncludesI[0] := TPath.GetDirectoryName( pAktUnit^.FileName ).ToLowerInvariant + TPath.DirectorySeparatorChar;
      fi := 0;
      Result := false;
      while fi <= high( IncludesI ) do
        if FileExists( IncludesI[fi] + f.Str )
          then begin f.Str := ExpandFilename( IncludesI[fi] + f.Str ); Result := true; break end
          else inc( fi )
      end;

    if not Result then begin
      pId := pPathIds;
      while pId^.NextId <> nil do pId := pId^.NextId;
      InsertIdAc( f, pId, id_Filename, ac_Read );

      if NotFoundFiles.IndexOf( f.Str ) = -1 then
        NotFoundFiles.Add( f.Str );
    end
  end;

begin
  {$IFDEF TraceDx} TraceDx.Call( uList, 'TestFileInclude', f.Str ); {$ENDIF}
  fi := cFirstFile;
  if not SearchIncludeInPaths
    then exit;  // Inc  nicht vorhanden

  Hash := getHash( f.Str );
  AnzahlDateien := high( DateiListe );
  while fi <= AnzahlDateien do
    if ( DateiListe[fi]^.FileHash = Hash ) and ( DateiListe[fi]^.FileName.ToLowerInvariant = f.Str.ToLowerInvariant )
      then break             // Include schon in Dateiliste, mit diesem fi weitermachen
      else inc( fi );
//  LeaveFileMinimal;
  AltFileIndex := pAktFile^.MyIndex;
//  EnterFileUnitMinimal
  if fi = high( DateiListe ) + 1 then
    AddFile( f.Str, Enter );

  pId := InsertIdAc( f, DateiListe[AltFileIndex].MyFileId, id_Filename, ac_Read );

  if Enter then begin
    pAktFile := DateiListe[fi];
    with pAktFile^ do begin
      ShowFile( FileName );
      // auch für schon bekannte Includes (die ja nochmals durchlaufen werden!)
      PrevFile := AltFileIndex;            // nur für frmViewer (Datei-Ansicht) und FileTree
      JumpFirstLine( pAktFile );
      // nur für neue Dateien:
      if fi > AnzahlDateien then begin      // NEUE Datei: immer für Units, bei Include nur einmal
        {$IFDEF TraceDx} TraceDx.Send( uList, 'New File ' + f.Str, fi ); {$ENDIF}
        MyFileId := pId;
        UnitName := '';
        FileHash := Hash;
        if high( StrList ) = -1 then LeaveFile
        end;
      end
    end
  else begin
    DateiListe[fi]^.prevFile := AltFileIndex;            // nur für frmViewer (Datei-Ansicht) und FileTree
    DateiListe[fi]^.UnitName := '';
    DateiListe[fi]^.FileHash := Hash;
    DateiListe[fi]^.MyFileId := pId;
    end
end;

{ TListen.PauseUnit }
class procedure TListen.PauseUnit;
begin
  pAktUnit^.NextFile    := pAktFile^.MyIndex;
  pAktUnit^.NextLiMax   := pAktFile^.liMax;
  pAktUnit^.NextRiMax   := pAktFile^.riMax;
  pAktUnit^.NextLi      := pAktFile^.li;
  pAktUnit^.NextRi      := pAktFile^.ri;
  pAktUnit^.NextPi      := pAktFile^.pi;
  pAktUnit^.NextKeyWord := OverNextKw;
  pAktUnit^.NextIdInfo  := NextId;
end;

{ TListen.LeaveFileMinimal }                // nach TScanner
class procedure TListen.LeaveFileMinimal;
begin
  pAktFile^.NextKeyWord := OverNextKw;
  pAktFile^.NextIdInfo  := NextId;
end;

{ TListen.LeaveFile }
class procedure TListen.LeaveFile;
begin
  with pAktFile^ do begin
    {$IFDEF TraceDx} TraceDx.Call( uList, 'LeaveFile', FileName); {$ENDIF}
    if PrevFile = cKeinFileIndex then
      Error( errNoCallingFile, FileName )
    else begin
      if pAktFile^.UnitName <> '' then begin  // Unit
        LeaveFileMinimal;
        EnterFileUnitMinimal( PrevFile )
        end
      else begin  // Include
//        LeaveFileMinimal;
  pAktFile     := DateiListe[PrevFile];
//        EnterFileUnitMinimal( PrevFile );
        end;
//      PrevFile := cKeinFileIndex;          // PrevFile ungültig machen, um zirkuläre Referenzen zu erkennen
      end;
    ShowFile( pAktFile^.FileName )
    end
end;

class function TListen.SearchUnitFile( pUnit: pIdInfo ): tFileIndex_;
begin
  for Result := 0 to high( DateiListe ) do
    if DateiListe[Result].MyUnit = pUnit then exit;
  Result := -1
end;


{$ENDREGION }

{$REGION '-------------- Blöcke ---------------' }

{ eröffnet ggf einen Sub-Block beim Deklarieren }
class procedure TListen.EnterBlock( pId: pIdInfo );
begin
{$IFDEF TraceDx} TraceDx.Call( uList, 'EnterBlock', pId^.Name );  {$ENDIF}
AktDeclareOwner := pId;
if ParserState.RecordLevel = 0 then AktDeclOwnerEnum := AktDeclareOwner
end;

{ verlässt einen Sub-Block nach dem Deklarieren }
class procedure TListen.LeaveBlock;
begin
{$IFDEF TraceDx} TraceDx.Call( uList, 'LeaveBlock', AktDeclareOwner^.Name + ' >>', AktDeclareOwner^.PrevBlock^.Name ); {$ENDIF}
AktDeclareOwner := AktDeclareOwner^.PrevBlock;
if ParserState.RecordLevel = 0 then AktDeclOwnerEnum := AktDeclareOwner
end;

{$ENDREGION }

{$REGION '-------------- IdPtr-Liste ---------------' }

(* InsertIdPtr *)
class procedure TListen.InsertIdPtr( var ptrListe: pIdPtrInfo; pIdNeu: pIdInfo; s,e: tAcSeqIndex );
{ trägt einen weiteren IdPtr in die übergebene Liste (With, Uses, ParameterTypes) ein: }
var pw: pIdPtrInfo;
begin
  {$IFDEF TraceDx} TraceDx.Call( uList, 'Insert Unit/With', pidName( pIdNeu ) ); {$ENDIF}
  new( pw );
  {$IFDEF HEAPCHECK} HeapCheck.new( pw, sizeOf( pw^ )); {$ENDIF}
  pw^.Block     := pIdNeu;
  pw^.AcStart   := s;
  pw^.AcEnde    := e;
  pw^.NextIdPtr := ptrListe;
  ptrListe      := pw
end;

(* ClearIdPtrList *)
class procedure TListen.ClearIdPtrList( var ptrListe: pIdPtrInfo );
var pw: pIdPtrInfo;
begin
  //{$IFDEF TraceDx} TraceDx.Call( uList, 'ClearIdPtrList' ); {$ENDIF}
  while ptrListe <> nil do begin
    pw       := ptrListe;
    ptrListe := ptrListe^.NextIdPtr;
    Dispose( pw );
    {$IFDEF HEAPCHECK} HeapCheck.Dispose( pw, sizeOf( pw^ ) ); {$ENDIF}
    end
end;

(* LeaveWith *)
class procedure TListen.LeaveWith;
var w: pIdPtrInfo;
begin
  {$IFDEF TraceDx} TraceDx.Call( uList, 'LeaveWith', WithListe^.Block^.Name ); {$ENDIF}
  w         := WithListe;
  WithListe := WithListe^.NextIdPtr;
  Dispose( w );
  {$IFDEF HEAPCHECK} HeapCheck.Dispose( w, sizeOf( w^ ) ); {$ENDIF}
end;

{$ENDREGION }

{$REGION '-------------- Parent ---------------' }


{$ENDREGION }

{$REGION '-------------- Helper ---------------' }

class procedure THelper.SetUnitHelpersToTypes( pIdHelp: pIdInfo );
begin
  while pIdHelp <> nil do begin                  // für alle verketteten helper
    {$IFDEF TraceDx} TraceDx.Call( uList, 'SetUnitHelpersToTypes', pIdHelp^.MyType^.Name  ); {$ENDIF}
    if pIdHelp^.MyType^.NextHelper = nil  {siehe else-Zweig}
      then pIdHelp^.MyType^.NextHelper := pIdHelp
      else ; // der erste gefundene ist der letzte deklarierte und der gewinnt
    pIdHelp := pIdHelp^.NextHelper
    end;
end;

class procedure THelper.ReSetUnitHelpersToTypes( pIdHelp: pIdInfo );
begin
  while pIdHelp <> nil do begin                  // für alle verketteten helper
    {$IFDEF TraceDx} TraceDx.Call( uList, 'ReSetUnitHelpersToTypes', pIdHelp^.MyType^.Name  ); {$ENDIF}
    pIdHelp^.MyType^.NextHelper := nil;
    pIdHelp := pIdHelp^.NextHelper
    end;
end;

{$ENDREGION }

{$REGION '-------------- Virtual ---------------' }

{ TListen.InsertVirtualId }
class procedure TListen.InsertVirtualId( pIdDest: pidInfo; b: pIdInfo );
var pId: pIdInfo;
    Id : tIdPosInfo;
begin
  {$IFDEF TraceDx} TraceDx.Call( uList, 'InsertVirtualId', pIdDest^.Name ); {$ENDIF}
  Id.Str := dVirtualKennung + pIdDest.Name;
//  Id.Pos := pIdDest.AcList^.Position;
  pId := InsertId( Id.Str, b, id_Virtual, false );
  pId^.MyType := pIdDest;
  if pId^.Typ = id_Type then begin
    pId^.TypeNr := pIdDest^.TypeNr;   // kann weg wegen id_Virtual
    dec( TypeCount )
    end;
//  pId^.Hash   := cNoHash;
  include( pId^.        IdFlags, tIdFlags.IdVirtual );
//  include( pId^.LastAc^.AcFlags, tAcFlags.DontFind  );
  inc( VirtualCount )    // einen Dummy-Ac zählen
end;

{ TListen.InsertVirtualEnum }
class procedure TListen.InsertVirtualEnum( pIdDest: pidInfo );
var Block: pIdInfo;
begin
  {$IFDEF TraceDx} TraceDx.Call( uList, 'InsertVirtualEnum', pIdDest.Name ); {$ENDIF}
  Block := pIdDest^.PrevBlock;
  while not ( Block^.Typ in [id_Program, id_Unit, id_Proc, id_Func] ) do
    Block := Block^.PrevBlock;
  InsertVirtualId( pIdDest, Block )
end;

{$ENDREGION }

{$REGION '----------- IdSequenz ---------------' }

(* tIdSeq.PreParse *)
procedure tIdSeq.PreParse;
begin
  {$IFDEF TraceDx} TraceDx.Call( uList, 'tIdSeq.PreParse' ); {$ENDIF}
//  assert( Pegel = 0 );             // nach Error evtl <> 0
  MaxPegel := 0;
  Pegel    := 0
end;

(* tIdSeq.Add *)
procedure tIdSeq.Add( pId: pIdInfo; start,ende: tAcSeqIndex );
begin
  if Pegel = high( Stack ) then Error( errIdStackOverflow );
  Stack[Pegel].IdpId   := pId;
  Stack[Pegel].AcStart := start;
  Stack[Pegel].AcEnde  := ende;
  inc( Pegel );
  if Pegel > MaxPegel then inc( MaxPegel )
end;

procedure tIdSeq.Del( idx: tIdSeqIndex );
begin
  {$IFDEF TraceDx} TraceDx.Call( uList, 'tIdSeq.Delete', Stack[idx].IdpId^.Signatur.ToHexString( 8 ) ); {$ENDIF}
  Stack[idx].IdpId := nil
end;

{$ENDREGION }

{$REGION '----------- AcSequenz ---------------' }

(* tAcSeq.PreParse *)
procedure tAcSeq.PreParse;
begin
  {$IFDEF TraceDx} TraceDx.Call( uList, 'tAcSeq.PreParse' ); {$ENDIF}
//  assert( Pegel = 0 );             // nach Error evtl <> 0
  MaxPegel := 0;
  Pegel    := 0
end;

(* tAcSeq.AddToAcList *)
procedure tAcSeq.Add( pAc: pAcInfo );
begin
  if Pegel = high( Stack ) then Error( errAcStackOverflow );
  Stack[Pegel] := pAc;
  inc( Pegel );
  if Pegel > MaxPegel then
    inc( MaxPegel )
end;

(* tAcSeq.WithUsed *)
procedure tAcSeq.WasPointerOrArray;
begin
  { dieser Ac erfolgte in der Ac-Sequenz über "^" oder "[": }
  include( Stack[Pegel-1]^.AcFlags, tAcFlags.PtrOrArr )
end;

(* tAcSeq.WithUsed *)
procedure tAcSeq.WithUsed( w: pIdPtrInfo );
var i: tAcSeqIndex;
begin
  for i := w^.AcStart to w^.AcEnde-1 do Add( Stack[i] )
end;

(* tAcSeq.ChangeAcToResult
procedure tAcSeq.ChangeAcToResult( start: tAcSeqIndex );
var i,j: tAcSeqIndex;
    pId: pIdInfo;

  function GetResult( pId: pIdInfo ): pIdInfo;
  begin
    assert( not ( tIdFlags.fromLibrary in pId^.IdFlags ));  // System- und Library-Funktionen haben kein Result
    if pId^.Typ = id_Proc { FOR-Dummy }
      then Result := pId^.PrevBlock^.SubBlock        // direkt über dem FOR-Dummy ist die function
      else Result := pId^.SubBlock;
    while ( Result <> nil ) and not ( tIdFlags.IsResult in Result^.IdFlags ) do
      Result := Result^.NextId
  end;

begin
  {$IFDEF TraceDx} TraceDx.Send( 'tAcSeq.ChangeAcToResult' ); {$ENDIF}
  assert( start <= Pegel );
  for i := Pegel - 1 downto start do
    { Falls Result eine function ist und unter Funktionsname angesprochen wird: nach SubBlock-Id "Result" umhängen: }
    if ( Stack[i]^.IdDeclare^.Typ = id_Func ) and

       ( ( Stack[i]^.IdDeclare = Stack[i]^.IdUse ) or     // natürlich nicht wenn eine andere Funktion aufgerufen wird

         (( Stack[i]^.IdUse^.Typ = id_DummyProc ) and ( Stack[i]^.IdDeclare = Stack[i]^.IdUse^.PrevBlock )) ) and  // Sonderfall For-Block

       { nur wenn (1) letzter Id  OR  (2) Funktions-Typ ist NICHT Pointer oder Array: Beispiel:  f(x)^ := 1 }
       (( i = Pegel-1 ) or not ( tAcFlags.PtrOrArr in Stack[i]^.AcFlags ))
      then begin
      {$IFDEF TraceDx} TraceDx.Send( 'tAcSeq.ChangeFncnameToResult', Stack[i]^.IdDeclare^.Name ); {$ENDIF}
      exclude( Stack[i]^.AcFlags, tAcFlags.Rekursiv );    // doch nicht rekursiv sondern result-Zuweisung
      pId := GetResult( Stack[i]^.IdUse );
      assert( tIdflags.IsResult in pId^.IdFlags );
      TListen.MoveAc( Stack[i] { das ist Ac der "Function" } , pId { das ist die "Result"-Variable } );
      pId := Stack[i]^.IdDeclare;   // die auf den jetzt umgehängten folgenden Sub-Ids unter den neuen hängen
      { Alle Subs HINTER dem umgehängten entsprechend mitziehen: }
      for j := i+1 to Pegel-1 do begin
        pId := TListen.SucheIdUnterId( pId, Stack[j]^.IdDeclare^.Hash, Stack[j]^.IdDeclare^.Name, true );
        TListen.MoveAc( Stack[j], pId )
        end
      end;
end;                       *)

(* tAcSeq.ChangeAcToWrite *)
procedure tAcSeq.ChangeAcToWrite( start,ende: tAcSeqIndex; ac: tAcType );
const cIdOkay = [id_Unbekannt,
                 id_Const,          // writable typed const (von früher)
                 id_Type,           // für die auf den Typ umgeleiteten Pointer-Zugriffe
                 id_Var, id_Property
                 {id_Proc, id_Func}]; // für @proc :=
var i: tAcSeqIndex;
begin
  {$IFDEF TraceDx} TraceDx.Call( uList, 'tAcSeq.ChangeAcToWrite' ); {$ENDIF}
  for i := ende - 1 downto start do
    if ( i = ende-1 ) { den letzten Id-Teil immer, z.B. p := ... wenn p ist Pointer OHNE MyType, also NICHT auf MyType umgeleitet } or
       ( ( Stack[i]^.IdDeclare^.Typ in cIdOkay ) and
         ( Stack[i]^.IdDeclare^.IdFlags * [tIdFlags.IsPointer, tIdFlags.IsClassType] = [] ) )
(*    if ( Stack[i]^.IdDeclare^.Typ in cIdOkay ) and
       ( ( i = ende-1 ) { den letzten Id-Teil immer, z.B. p := ... wenn p ist Pointer OHNE MyType, also NICHT auf MyType umgeleitet } or
         ( Stack[i]^.IdDeclare^.IdFlags * [tIdFlags.IsPointer, tIdFlags.IsClassType] = [] ) ) *)
      then TListen.ChangeAcType( Stack[i], ac )
      else break
end;

(* tAcSeq.ChangeAcEndToWrite *)
procedure tAcSeq.ChangeAcEndToWrite( start: tAcSeqIndex; ac: tAcType );
begin
  {$IFDEF TraceDx} TraceDx.Call( uList, 'tAcSeq.ChangeAcEndToWrite' ); {$ENDIF}
  ChangeAcToWrite( start, Pegel, ac );
  Pegel := start
end;

(* tAcSeq.ChangeAcToUnknown *)
procedure tAcSeq.ChangeAcToUnknown( start,ende: tAcSeqIndex );
const cIdOkay = [id_Unbekannt,
                 id_Type,           // für die auf den Typ umgeleiteten Pointer-Zugriffe
                 id_Var];
var i: tAcSeqIndex;
begin
  {$IFDEF TraceDx} TraceDx.Call( uList, 'tAcSeq.ChangeAcToUnknown' ); {$ENDIF}
  for i := ende - 1 downto start do
    if ( Stack[i]^.IdDeclare^.Typ in cIdOkay ) and
       ( ( i = ende-1 ) { den letzten Id-Teil immer, z.B. p := ... wenn p ist Pointer OHNE MyType, also NICHT auf MyType umgeleitet } or
         ( Stack[i]^.IdDeclare^.IdFlags * [tIdFlags.IsPointer, tIdFlags.IsClassType] = [] ))
      then TListen.ChangeAcType( Stack[i], ac_Unknown )
      else break
end;

procedure tAcSeq.BuildAcChain( start: tAcSeqIndex );
var i: tAcSeqIndex;
begin
  {$IFDEF TraceDx} TraceDx.Call( uList, 'tAcSeq.BuildAcChain' ); {$ENDIF}
  for i := Pegel - 1 downto start + 1 do
    Stack[i]^.AcPrev := Stack[i-1];
//  Stack[start]^.AcPrev := nil           // ist sowieso nil
end;

{$ENDREGION }

{$REGION '------------- Id/Ac suchen --------------' }

(* GetParam1 *)
class function TListen.GetParam1( pId: pIdInfo ): pIdInfo;
begin
  Result := pId^.SubBlock;
  while ( Result <> nil ) and
        (( tIdFlags.IsGenericDummy in Result^.IdFlags ) or not ( tIdFlags.IsParameter in Result^.IdFlags )) do
    Result := Result^.NextId
end;

class function TListen.SucheUnitId( b: pIdInfo; h: tHash; const IdStr: tIdString ): pIdInfo;
begin
  Result := b^.SubBlock;
  while ( Result <> nil ) and (( h <> Result^.Hash ) or ( IdStr <> Result^.Name.ToLowerInvariant )) do
    Result := Result^.NextId
end;

{ TListen.SearchAc }
class function TListen.SearchAc( d: tFileIndex; z: tLineIndex; s: tRowIndex ): pAcInfo;
var i,j,max: word;
begin
  if saCache <> nil then with saCache^.Position do
    if ( Datei = d ) and ( Zeile = z ) and ( Spalte <= s ) and ( Spalte + Laenge > s ) then begin
      Result := saCache;
//      {$IFDEF TraceDx} TraceDx.Send( uList, 'SearchAc Cache-Hit' ); {$ENDIF}
      exit
      end;
//  {$IFDEF TraceDx} TraceDx.Send( uList, 'SearchAc Cache-Miss' ); {$ENDIF}
  for i := 0 to high( AcArrays ) do begin
    Result := @AcArrays[i]^[0];
    if i = high( AcArrays )
      then max := NextAcIndex-1         // der letzte Id-Block wird zZ nur bis hierher genutzt
      else max := high( tAcArray );     // alle anderen bis zum Ende

    for j := 0 to max do begin
      if not ( tAcFlags.DontFind in Result^.AcFlags ) then with Result^.Position do
        if ( Datei = d ) and ( Zeile = z ) and ( Spalte <= s ) and ( Spalte + Laenge > s ) then begin
          saCache := Result;
//            {$IFDEF TraceDx} TraceDx.Send( uList, 'SearchAc finds', Result^.IdDeclare^.Name ); {$ENDIF}
          Exit
          end;
      inc( Result )
      end
    end;
  Result := nil     // nichts gefunden
end;

{ SucheIdInBloecken }
class function TListen.SucheIdInBloecken( h: tHash; const IdStr: tIdString ): pIdInfo;
var SuchEbene: ( SuchWith, SuchBlock, SuchUnitId, SuchUses, {SuchStdNameSpace,} SuchSystem, {$IFDEF UnitPrefixe} SuchGueltig, {$ENDIF} SuchUnbekannt, SuchEnde );
    u,w,g: pIdPtrInfo;
    b: pIdInfo;
//    OverPegel: tIdSeqIndex;

  function TestUnitId: boolean;
  { auch den Namen der Unit testen: }
  begin
    Result := false;
    while b^.PrevBlock <> @MainBlock[mbBlock0] do
      b := b^.PrevBlock;
    with b^ do
      if ( Hash = h ) and ( Typ in [id_NameSpace, id_Program, id_Unit] ) then
        if AnsiSameText( Name, IdStr )
          then Result := true
          else inc( HashCollisions )
  end;
begin
//  {$IFDEF TraceDx} TraceDx.Call( uList, 'SucheIdInBloecken', IdStr + ' ab', AktDeclareOwner^.Name ); {$ENDIF}
  if h = cNoHash then h := GetHash( IdStr );
  Result := nil;
  b      := AktDeclareOwner;
  w      := WithListe;
  g      := GueltigListe;
  if pAktUnit = nil
    then u := nil
    else u := pAktUnit^.UsesListe;
//  OverPegel := IdSequenz.Pegel;
  SuchEbene := low( SuchEbene );
  repeat
    case SuchEbene of
      SuchWith:  if w = nil then
                   inc( SuchEbene )
                 else begin
                   Result := TListen.SucheIdUnterId( w^.Block, h, IdStr, true );
                   if Result = nil
                     then w := w^.NextIdPtr
                     else AcSequenz.WithUsed( w )
                   end;
      SuchBlock: begin
                   Result := TListen.SucheIdUnterId( b, h, IdStr, true );
                   if Result = nil then
                     if b^.Typ in [id_Program, id_Unit] then     // Korrektur: Bei ERSTER Unit ist Schluss
                       inc( SuchEbene )
                     else begin
                       { In Class INNERHALB anderer Class darf ich Ids der äußeren Class nicht finden.
                         Ausser wenn es sich um Type handelt!   Deshalb zur Zeit nicht realisiert. Ansatz: }
//                       if ( b^.Typ = id_Type )  and  ( IsClassType in b^.IdFlags )
//                         then repeat b := b^.PrevBlock until b^.Typ in [id_Program,id_Unit,id_MainBlock]
//                         else        b := b^.PrevBlock;
                       b := b^.PrevBlock;
                       if b = @MainBlock[mbUnDeclaredUnScoped] then   // da will ich (jetzt noch nicht) hin...
                         b := pAktUnit^.MyUnit                     // ...erst mal in meiner Unit gucken
                       end
                 end;
      SuchUnitId:if TestUnitId               // den eigenen Unit-Namen nochmal extra suchen
                   then Result := b
                   else inc( SuchEbene );
      SuchUses:  if u = nil then
                   inc( SuchEbene )        // hier könnte eigentlich schon stop für overload-Suche sein...
                 else begin
                   b := u^.Block;
                   Result := TListen.SucheIdUnterId( b, h, IdStr, true );
                   if Result = nil then begin
                     if TestUnitId      // auch unter dem Namen der Unit suchen
                       then Result := b
                       else u := u^.NextIdPtr
                     end
                   end;
(*      SuchStdNameSpace: begin           { eigentlich überflüssig, siehe ParseProg!!! }
                   Result := TListen.SucheIdUnterId( StdNameSpace, h, IdStr, true );
                   if Result = nil
                     then inc( SuchEbene )
                 end;*)
      SuchSystem:begin
                   b := @UnitSystem;                  // Optimierung-Idee:
                   if TestUnitId then                          // Units nur als unverketteter Id unterm tFileInfo ablegen
                     Result := b                               // SucheUnterId() sucht nicht "unter" sondern "ab" (also SubBlock übergeben)
                   else begin
                     Result := TListen.SucheIdUnterId( b, h, IdStr, true );
                     if Result = nil then
                       inc( SuchEbene )
//                       if OverPegel = IdSequenz.Pegel
//                         then inc( SuchEbene )
//                         else Result := IdSequenz.Stack[OverPegel].IdpId   // overloads können nicht in in Unbekannt-Liste sein. Erstes Result liefern
                     end
                 end;
      {$IFDEF UnitPrefixe}
      SuchGueltig:if g = nil then
                   inc( SuchEbene )
                 else begin
                   Result := TListen.SucheIdUnterId( g^.Block, h, IdStr, true );
                   if Result = nil
                     then g := g^.NextIdPtr;
//                     else AcSequenz.WithUsed( g )    // nicht nötig für Namespaces
                   end;
      {$ENDIF}
     SuchUnbekannt:begin
                   Result := TListen.SucheIdUnterId( @MainBlock[mbUnDeclaredUnScoped], h, IdStr, true );
                   if Result = nil then
                     inc( SuchEbene )
                 end
     end
  until ( Result <> nil ) or ( SuchEbene = high( SuchEbene ) );
  {$IFDEF TraceDx} if w <> nil then TraceDx.Send( uList, 'Gefunden unter WITH', w^.Block^.Name ) {$ENDIF}
  //{$IFDEF TraceDx} if Result <> nil then TraceDx.Send( uList, 'Gefunden unter', Result^.prevBlock^.Name ) {$ENDIF}
end;   { SucheIdInBloecken }

var SucheIdCtrl: record
                   Nesting: word;
                   StartBlock: pIdInfo;
                   IsHelper: boolean
                 end;

{ TListen.SucheIdUnterId }
class function TListen.SucheIdUnterId( b: pIdInfo; h: tHash; const IdStr: tIdString; SearchVirtuals: boolean ): pIdInfo;
var BaseType,
    pHelper,
    Result_: pIdInfo;

  function ScanTypeAliase( var p: pIdInfo ): boolean;
  begin
    while ( p <> nil ) and ( p^.NextHelper = nil ) do p := p^.MyType;
    Result := p <> nil
  end;

  function TestVisibility( pId: pIdInfo): Boolean;
    function SameUnit: boolean;
    var a: pIdInfo;
    begin
      Result := pId^.AcList^.Position.Datei = pAktUnit^.MyIndex;
      if not Result and ( DateiListe[pId^.AcList^.Position.Datei]^.MyUnit = nil {Include-Datei} ) then begin
        a := pId^.PrevBlock;
        while a^.MyType <> nil do a := a^.MyType;               { Datei suchen, in der der pId deklariert wurde }
        while not ( a^.Typ in [id_Program, id_Unit] ) do
          a := a^.PrevBlock;
        Result := a = pAktUnit^.MyUnit
        end;
      {$IFDEF TraceDx} if not Result then TraceDx.Send( uList, 'Visibility: not SameUnit', pId^.Name ) {$ENDIF}
    end;
    function SameClass: boolean;
    var a: pIdInfo;
    begin
      a := AktDeclareOwner;
      while not ( a^.Typ in [id_Program, id_Unit, id_Type] ) do
        a := a^.PrevBlock;
      Result := a = pId^.PrevBlock;
      {$IFDEF TraceDx} if not Result then TraceDx.Send( uList, 'Visibility: not SameClass', pId^.Name ) {$ENDIF}
    end;
    function SubClass: boolean;
    var a,c: pIdInfo;
    begin
      a := AktDeclareOwner;
      while not ( a^.Typ in [id_Program, id_Unit, id_Type] ) do a := a^.PrevBlock;
      a := a^.MyParent;

      c := pId^.PrevBlock;
      while not ( c^.Typ in [id_Program, id_Unit, id_Type] ) do c := c^.PrevBlock;

      while a <> nil do begin
        if a = c then exit( true );
        a := a^.MyParent
        end;
      Result := false;
      {$IFDEF TraceDx} if not Result then TraceDx.Send( uList, 'Visibility: not SubClass', pId^.Name ) {$ENDIF}
    end;
    function ViaSubClass: boolean;
    var a,c: pIdInfo;
    begin
      a := SucheIdCtrl.StartBlock; { Block von aussen };
      if a^.Typ <> id_Type then a := a^.MyType;
//      a := a^.MyParent;

      c := pId^.PrevBlock;
      while c^.Typ <> id_Type do c := c^.PrevBlock;

      while a <> nil do begin
        if a = c then exit( true );
        a := a^.MyParent
        end;
      Result := false;
      {$IFDEF TraceDx} if not Result then TraceDx.Send( uList, 'Visibility: not via SubClass', pId^.Name ) {$ENDIF}
    end;
    function ViaPrevBlock: boolean;
    var a: pIdInfo;
    begin
      Result := false;
      a := AktDeclareOwner^.PrevBlock;
      while not Result and not ( a^.Typ in [id_Program, id_Unit] ) do
        if a = pId^.PrevBlock
          then Result := true
          else a := a^.PrevBlock;
    end;
  begin
    {$IFDEF TraceDx} TraceDx.Call( uList, 'TestVisibility', TListen.pIdName( pId ) ); {$ENDIF}
    (* gemäß Theorie:   strict private   :               in Method of same Class
                        strict protected :               in Method of same Class or SubClass
                               private   :  same Unit
                               protected :  same Unit or via          SubClass                   *)
    Result := ViaPrevBlock;  // Symbol ist in umgebender Class -> das ist wie SameClass
    if not Result then
      if tIdFlags.IsStrict in pId^.IdFlags then
        if tIdFlags.IsPrivate in pId^.IdFlags
          then Result := SameClass
          else Result := SameClass or SubClass
      else
        if tIdFlags.IsPrivate in pId^.IdFlags
          then Result := SameUnit
          else Result := SameUnit or ViaSubClass
  end;

  begin
//  {$IFDEF TraceDx} TraceDx.Call( uList, 'SucheId ', IdStr + ' unter', pIdName( b ) ); {$ENDIF}
  Result := nil;
  if b = nil then exit;

  if SucheIdCtrl.Nesting = 0 then begin
    SucheIdCtrl.StartBlock := b;    // für private-Auswertung {siehe oben}
    SucheIdCtrl.IsHelper   := tIdFlags.IsHelper in b^.IdFlags;
    ParserState.SearchOverload := false
    end;
  inc( SucheIdCtrl.Nesting );
  if h = cNoHash then h := GetHash( IdStr );

  { 1. falls kein Helper-Type aber helped Type/var: }
  if ( b^.Typ in [id_Const..id_Property, id_Func, id_ConstInt..id_ConstStr] ) and
     not SucheIdCtrl.IsHelper and not ( tIdFlags.IsHelper in b^.IdFlags ) and   // Endlosschleife für helper verhindern: erster und voriger Block dürfen kein Helper sein
     not ( ( b^.Typ = id_Func ) and ( b = AktDeclareOwner )) and   // nicht, wenn unter fkt deklariert wird
     SearchVirtuals and
     true then begin
    if ( ParserState.LastTypeOwner <> nil ) and ( ParserState.LastTypeOwner^.NextHelper <> nil ) then begin
      { die Variable hat bereits einen Helper zugeordnet bekommen, diesen weiterhin benutzen. NICHT auf einen aktuelleren wechseln! }
      pHelper := ParserState.LastTypeOwner^.NextHelper;
      ParserState.LastTypeOwner := nil
      end else
    if b^.NextHelper <> nil then begin
      pHelper := b^.NextHelper;
      if ParserState.LastTypeOwner <> nil then ParserState.LastTypeOwner^.NextHelper := pHelper
      end
    else begin
      pHelper := b^.MyType;
      if ScanTypeAliase( pHelper ) then begin
        pHelper := pHelper^.NextHelper;
        if ParserState.LastTypeOwner <> nil then ParserState.LastTypeOwner^.NextHelper := pHelper
        end
      else
        pHelper := nil;
      end;
    if pHelper <> nil then begin
      {$IFDEF TraceDx} TraceDx.Send( uList, 'Search in Helper', getBlockNameLong( pHelper, dTrennView )); {$ENDIF}
      Result := SucheIdUnterId( pHelper, h, IdStr, true {ggf auch im helper-Parent suchen: class helper (ParentHelper) for ...});                  // festen Helper nutzen
      if Result <> nil then begin
        dec( SucheIdCtrl.Nesting ); exit
        end
      end
    end;

  Result := b^.SubBlock;
  while { not Gefunden and } ( Result <> nil ) do with Result^ do begin
    { 2. falls flag virtual: erstmal dort suchen: }
    if SearchVirtuals and ( tIdFlags.IdVirtual in IdFlags ) then
      if not SucheIdCtrl.IsHelper                  and       // falls vom non Helper
             ( tIdFlags.IsHelper in b^.IdFlags )   and       // über dessen Helper
         not ( tIdFlags.IsHelper in MyType^.IdFlags )        // zum Helped Type: NICHT machen wegen Endlosschleife
        then Result := nil
        else Result := SucheIdUnterId( MyType, h, IdStr, SearchVirtuals )
    else begin
    { zuletzt normale Suche: }
      inc( CntIdCompares );
      Result_ := Result;
      Result  := nil;
      if ( Hash = h ) and
         ( not ParserState.TypeId_Needed or ( Typ in [id_Type, id_Unit, id_NameSpace, id_Unbekannt] )) and
          { siehe Tests Enum und Classes2: }
         ( not ParserState.ParseNoVar or                                 // nicht in id_Type-Erwartung
           not ( Typ in [id_Var, id_Property, id_Proc, id_Func] ) or     // alles andere kann in Type kommen: (Enum-)Const, Unitnamen
           ( tIdFlags.fromSystemLib in IdFlags ))  then begin              // sizeOf, high aus System ist auch in SubRange erlaubt
        inc( HashCollisions );
        if AnsiSameText( Name, IdStr ) then begin
          dec( HashCollisions );
          if not ( tIdFlags.IsDummy in IdFlags ) and
             (
//             ( ParserState.Statement = 0 )                                 or    // in Deklaration: alle finden
               ( IdFlags * [tIdFlags.IsPrivate, tIdFlags.IsProtected] = [] ) or
               TestVisibility( Result_ ) )
            then Result := Result_
          end
        {$IFDEF DEBUG} else Hash := h    { diese Zeile dient nur als möglicher Breakpoint } {$ENDIF}
        end;
      end;

    if Result = nil then
      Result := NextId
    else begin
      if ParserState.SearchOverload or
         (( tIdFlags.IsOverload in Result^.IdFlags ) and
          ( ParserState.Statement > 0 ) or ParserState.PropReadWrite ) then begin
        ParserState.SearchOverload := tIdFlags.IsOverload in Result^.IdFlags;   // falls dies kein overload ist: Overload-Suche wieder abschalten
        if not ParserState.SearchOverload then
          SearchVirtuals := false;     // overload-Suche endet mit dieser Ebene. Im Parent braucht nicht mehr gesucht werden
        IdSequenz.Add( Result, 0, 0 );    // overload: Liste ergänzen (Acs sind hier irrelevant) und weitersuchen:
        {$IFDEF TraceDx} TraceDx.Send( uList, 'Found overload', getBlockNameLong( Result, dTrennView )); {$ENDIF}
        Result := NextId
        end
      else
        break                    // Id gefunden, Ausstieg
      end
    end;

  if ( Result = nil ) and ( b <> nil ) and SearchVirtuals and ( b^.MyParent <> nil ) then begin
    {$IFDEF TraceDx} TraceDx.Send( uList, 'Search in Parent of ' + b^.Name, b^.MyParent^.Name ); {$ENDIF}
    Result := SucheIdUnterId( b^.MyParent, h, IdStr, SearchVirtuals );
    end;
  dec( SucheIdCtrl.Nesting )
  end;   { SucheIdImBlock }

{$ENDREGION }

{$REGION '------------ Types / Numbers ---------------' }

{ GetTypeNr }
class function TListen.GetTypeNr: tTypeNr;
type pTypeNr = ^tTypeNr;
begin
  if TypeCount = high( TypeCount )
    then TypeCount := TypeCountSys           // einfach wieder zurücksetzen :-)
    else inc( TypeCount );
  Result := pTypeNr( @TypeCount )^           // nur die beiden low-Bytes
end;

{ CopyTypeInfos }
class procedure TListen.CopyTypeInfos( pSource, pDest: pIdInfo );
begin
//  {$IFDEF TraceDx} TraceDx.Call( uList, 'CopyTypeInfos', pDest^.Name ); {$ENDIF}
  pDest^.MyType := pSource;                  // kopiert einen idType nach Dest
  if pSource <> nil then begin
//    assert( pSource^.typ = id_Type );      // wird bei enum auch mit Source idVar benutzt
    pDest^.TypeNr     := pSource^.TypeNr;
    pDest^.TypeGroup  := pSource^.TypeGroup;
    pDest^.TypeKind   := pSource^.TypeKind;
    pDest^.MyParent   := pSource^.MyParent;
//    pDest^.IdFlags    := pDest^.IdFlags + ( pSource^.IdFlags - cDontCopyFlags - cPrivacyFlags );    hier NICHT wegen uSystem-Init
    pDest^.NextHelper := getBaseType( pSource )^.NextHelper
    end
end;                                                                   // zusammenlegen

{ CopyVarTypeInfos }
class procedure TListen.CopyVarTypeInfos( pSource, pDest: pIdInfo );
begin
//  {$IFDEF TraceDx} TraceDx.Call( uList, 'CopyVarTypeInfos', pDest^.Name ); {$ENDIF}
  pDest^.MyType     := pSource^.MyType;      // kopiert den MyType nach Dest
  pDest^.TypeNr     := pSource^.TypeNr;
  pDest^.TypeGroup  := pSource^.TypeGroup;
  pDest^.TypeKind   := pSource^.TypeKind;
  pDest^.MyParent   := pSource^.MyParent;
  if pSource^.MyType <> nil then
    pDest^.IdFlags    := pDest^.IdFlags + ( pSource^.MyType^.IdFlags - cDontCopyFlags - cPrivacyFlags );
  pDest^.NextHelper := getBaseType( pSource )^.NextHelper
end;

{$ENDREGION }

{$REGION '------------ Hash ---------------' }

{ OldGetHash }
function OldGetHash( const Id: tIdString ): tHash;
var w1,w2,w3: word;
begin
  w1 := ( ord( UpCase( Id[cSpalte0  ] )) mod 32 );
  w2 := ( ord( UpCase( Id[high( Id )] )) shl  1 );
  w3 := ( ( high( Id ) mod 64 ) shl 10 );
  OldGetHash := w1+w2+w3
end;

{ GetHash }
function GetHash( const Id: tIdString ): tHash;
asm
  push ebx
  mov edx, eax
  sub edx, 4
  mov eax, [edx]       // Länge -> eax
  mov ebx, [edx+4]     // erste zwei Zeichen -> ebx
  and ebx, $ff1fff1f   // upper case ( durch Ausblenden, damit werden Ziffern auf '@'..'I' und 'P'..'Y' gemappt ), v0 und vp haben also denselben Hash
  shl eax, 1           // mal 2 = sizeof( widechar )
  add edx, eax
  mov ecx, [edx]       // vorletztes Zeichen und letztes -> ecx
  and ecx, $ff1fff1f   // upper case
  rol ecx, 6           // erste Zeichen 6 nach links
  rol eax, 27          // Länge 28 nach links (ein Shift war oben schon)
  shl  ax, 12
  or  eax, ecx         // Ergebnis
  or  eax, ebx         // 31..28 27..22 21..16 15..12 11..6 5..0
  pop  ebx             // LenHi    chX    ch2  LenLow chX-1  ch1
end;

{$ENDREGION }

{$REGION '------------ InsertIdAc / CopySub ---------------' }

{ TListen.pIdName }
class function TListen.pIdName( pId: pIdInfo ): string;
begin
  if pId = nil
    then Result := 'nil'
    else Result := pId^.Name
end;

class procedure TListen.SetIdProjectUse( pId: pIdInfo );
begin
  if not ( tFileFlags.LibraryPath in pAktUnit^.fiFlags ) then  { dies war ein Zugriff aus dem Projekt. Für ganzen Baum setzen: }
    repeat if tIdFlags2.IdProjectUse in pId^.IdFlags2
             then break;
           include( pId^.IdFlags2, tIdFlags2.IdProjectUse );
           pId := pId^.PrevBlock
    until  false
end;

{$IFDEF TraceDx} var InsertIdAc_: boolean = false; {$ENDIF}

{ TListen.AddAc }
class procedure TListen.AddAc( pId: pIdInfo; pAc: pAcInfo; const Pos: tFilePos; AcType: tAcType );
begin
  {$IFDEF TraceDx} if not InsertIdAc_ then TraceDx.Send( uList, 'Ac++', pId^.Name, cAcShow[AcType].Text ); {$ENDIF}
  if pAc = nil then NewAc( pAc );
  with pAc^ do begin
    ZugriffTyp := AcType;
    Position   := Pos;
    if tFileFlags.LibraryPath in pAktUnit^.fiFlags
      then AcFlags := []
      else AcFlags := [tAcFlags.AcProjectUse];
    IdUse      := AktDeclareOwner;
    IdDeclare  := pId;
    NextAc     := nil;
    AcPrev     := nil;             // wird bei Id-Kette in ParseIdentifier() auf den Vorgänger gesetzt
    inc( ZaehlerAc[AcType] );
    inc( ZaehlerAcs );
    {$IFDEF TraceDx} if ( lo( ZaehlerAc[ac_Read] ))     = 1 then
    {$ELSE}     if ( ZaehlerAc[ac_Read] ) and 4095 = 1 then {$ENDIF}
      TestAbbruch
    end;

  with pId^ do begin
    if AcList = nil
      then AcList := pAc                // neuen Access in Idliste hinten einfügen
      else LastAc^.NextAc := pAc;
    LastAc := pAc;
    Include( AcSet, AcType )
    end;

  if not ( tIdFlags.IsOverload in pId^.IdFlags ) then
    SetIdProjectUse( pId )
end;

{ TListen.InsertId }
class function TListen.InsertId( const IdStr: string; b: pIdInfo; IdType: tIdType; followVirtual: boolean ): pIdInfo;
var h: tHash;
    OverPegel: tIdSeqIndex;
begin
  {$IFDEF TraceDx} if not InsertIdAc_ then TraceDx.Send( uList, 'Id++', IdStr ); {$ENDIF}
  h := GetHash( IdStr );
  OverPegel := IdSequenz.Pegel;
  if b = nil then begin
    Result := SucheIdInBloecken( h, IdStr );     // Block unbekannt -> alles ab AktDeclareOwner absuchen
    if Result = nil
      then b := @MainBlock[mbUnDeclaredUnScoped]
      else b := Result^.PrevBlock
    end
  else begin
    if ( b^.PrevBlock = @UnitSystem ) and ( b^.SubBlock <> nil ) and ( tIdFlags.IsParameter in b^.SubBlock^.IdFlags ) then
      b := @MainBlock[mbUnDeclaredUnScoped];    // unter SystemIds mit Parametern (Unendlich-Schleife!) NICHTS zusätzliches anhängen
    Result := SucheIdUnterId( b, h, IdStr, followVirtual );    // Block ist klar  -> nur auf "exisitert schon" gucken
    end;

  if OverPegel < IdSequenz.Pegel then
    Result := IdSequenz.Stack[OverPegel].IdpId;   // overloads können nicht in in Unbekannt-Liste sein. Erstes Result liefern

  if Result = nil then begin
    {$IFDEF TraceDx} TraceDx.Add( '** [' + b^.Name + ']' ); {$ENDIF}
//    assert( ( b^.SubBlock = nil ) or not ( tIdFlags.IsParameter in b^.SubBlock^.IdFlags ), 'Insert hinter SystemPara' );
    NewId( Result, IdStr );
    with Result^ do begin
      Name       := IdStr;
      Typ        := IdType;
      Hash       := h;
      PrevBlock  := b;
      if Typ = id_Type then
        TypeNr := GetTypeNr;
      inc( ZaehlerId[IdType] );
      inc( ZaehlerIds );
      {$IFDEF TestHash}
      if ZaehlerHash[IdHash] = 0
      then NameHash[IdHash] := Name
      else NameHash[IdHash] := NameHash[IdHash] + ' / ' + Name;
      inc( ZaehlerHash[IdHash] );
      {$ENDIF}
      end;
    with b^ do begin    // neuen Id in Blockliste hinten einfügen
      if SubBlock = nil
        then SubBlock := Result
        else SubLast^.NextId := Result;
      SubLast := Result
      end
    end
  else
    case Result^.Typ of    { diese beiden dürfen aktualisiert werden: }
      id_Unbekannt: if IdType <> id_Unbekannt then ChangeIdType( Result, IdType );
      id_NameSpace: if IdType =  id_Unit      then ChangeIdType( Result, IdType );
      id_Property : ;   // beim Lesen des Formulars wird property als var erwartet
      id_Program,
      id_Unit     : ;  { dies ist die Unit System, bleibt auch nach "System.SysUtils" bei Unit statt NameSpace }
      else          {$IFDEF TestKompatibel}
                    if ( IdType <> id_Unbekannt ) and
                       ( Result^.PrevBlock <> @MainBlock[mbUnDeclaredUnScoped] ) and   // Unbekannte können beliebig unterschiedlich sein
                       ( IdType <> id_Property  ) and  { SubKomponenten einer property bleiben bei var und so }
                       ( IdType <> Result^.Typ ) then
                      if ( Result^.PrevBlock^.NextHelper <> nil ) or     // falls helper vorhanden: Id-Überlagerung, siehe CopySub()
                         ( tIdFlags.IsDefaultArr       in Result^.IdFlags ) or   // falls default-property: eigentlicher owner ist ein anderer
                         ( IdType = id_Var ) and ( Result^.Typ = id_Const )   // const-Parameter-Subs sind bei zweiter Deklaration schon auf const
                        then // ausnahmsweise erlaubt
                        else Error( errBadIdType, getBlockNameLong( Result, '.' ) + ': ' + cIdShow[Result^.Typ].Text, cIdShow[IdType].Text )
                    {$ENDIF}
      end;
end;

(* TListen.InsertIdAc *)
class function TListen.InsertIdAc( const Id: tIdPosInfo; b: pIdInfo; IdType: tIdType; AcType: tAcType ): pIdInfo;
begin
  {$IFDEF TraceDx} InsertIdAc_ := true; TraceDx.Call( uList, 'IdAc++', Id.Str, cAcShow[AcType].Text ); {$ENDIF}
  Result := InsertId( Id.Str, b, IdType, AcType <> ac_Declaration );
  { falls neuer unbekannt-Eintrag TypeGroup statt Stardardwert coSelf auf coUnb setzen.
    NICHT, wenn Eintrag aus System-Library kopiert wurde, z.B. pInteger-SubBlock "^", der schon TypeGrout coInt hat }
  if ( Result^.AcList = nil ) and ( AcType <> ac_Declaration ) and   // erster Eintrag ist nicht ac_Declaration
     ( IdType in [id_Unbekannt, id_Label..id_Func] )           and
     ( Result^.TypeGroup = coSelf )                            and
     not ( tIdFlags.fromSystemLib in Result^.IdFlags )           then
    Result^.TypeGroup := coUnb;    // ohne Deklaration keine TypeGroup, also standardmäßig kompatibel zu allen
  AddAc( Result, nil, Id.Pos, AcType );
  {$IFDEF TraceDx} InsertIdAc_ := false {$ENDIF}
end;

{ TListen.CopySub }
class procedure TListen.CopySub( Source, Dest: pIdInfo );
var   SrcIsType: boolean;

  function CopySubSub( Source, Dest: pIdInfo ): boolean;
  var pId   : pIdInfo;
      IdInfo: tIdPosInfo;
  begin
    Result := false;
    while Source <> nil do begin
      if ( Source.Typ in [id_Var, id_Property, id_Virtual] )            and
         not ( tidFlags.isClassVar     in Source^.IdFlags ) and             //  z.B. class var NICHT kopieren
         not ( tidFlags.IsGenericDummy in Source^.IdFlags ) then begin
        IdInfo.Str := Source^.Name;
        if ( Source^.AcList <> nil ) and ( Source^.AcList^.ZugriffTyp = ac_Declaration ) then begin
          IdInfo.Pos := Source^.AcList^.Position;    // setzt voraus, dass Deklaration im ERSTEN Access steht
          pId := InsertIdAc( IdInfo, Dest, Source^.Typ, Source^.AcList^.ZugriffTyp );
          pId^.AcList^.AcFlags := Source^.AcList^.AcFlags    // acProjectUse kopieren
          end
        else   // fromLibrary   und   Sonderfall shortstring[]
          pId := InsertId( IdInfo.Str, Dest, Source^.Typ, false );
        if SrcIsType then include( Source^.IdFlags, IsCopySource );   // nicht bei Deklaration var v1,v2: t1
        {$IFDEF HelpersHide}
        if tIdFlags.IsHelper in pId^.PrevBlock^.IdFlags then
          TListen.DeleteAc( pId^.LastAc, true )    // dieser IdStr wird von einem Helper-Sub überlagert. NICHT neu anlegen
        else {$ENDIF} begin
          TListen.CopyVarTypeInfos( Source, pId );
          pId^.IdFlags := Source^.IdFlags - cDontCopyFlags;
          if not ( tIdFlags.NoCopy in Source^.IdFlags ) then
            CopySubSub( Source^.SubBlock, pId )    //   auch darunterliegendes kopieren
          end
        end
      else
        if ( ac_Declaration in Source^.AcSet ) and not ( tidFlags.IsGenericDummy in Source^.IdFlags ) then         // ohne Deklaration zusätzlich eingetragene Komponente reicht NICHT für VirtualId
          Result := true;

      Source := Source^.NextId
      end;
  end;

begin
  assert( Source <> nil ); assert( Dest <> nil );
//  {$IFDEF TraceDx} TraceDx.Call( uList, 'CopySub', Source^.Name, Dest^.Name ); {$ENDIF}

  SrcIsType := Source^.Typ = id_Type;
  if SrcIsType
    then TListen.CopyTypeInfos   ( Source, Dest )
    else TListen.CopyVarTypeInfos( Source, Dest );
  Dest^.IdFlags := Dest^.IdFlags + ( Source^.IdFlags - cDontCopyFlags - cPrivacyFlags );

  if SrcIsType and not ( Source^.TypeGroup in [coTArray] ) then  { TArray ist generic und wird bei Nutzung jeweils passend ausgefüllt. BaseType ist also evtl falsch }
    Source := getbaseType( Source );          // type-aliase überspringen

  if Source^.SubBlock = nil                  then exit;
  if tIdFlags.IsClassType in Source^.IdFlags then exit;
  if tIdFlags.IsInterface in Source^.IdFlags then exit;
  if tIdFlags.IsResult    in Source^.IdFlags then exit;
  if tIdFlags.NoCopy      in Source^.IdFlags then exit;

  if ( tIdFlags.IsParameter in Dest^.IdFlags ) and
     ( Dest^.AcList         <> nil )           and
     ( Dest^.AcList^.NextAc <> nil )           and
     ( [Dest^.AcList^.ZugriffTyp] + [Dest^.AcList^.NextAc^.ZugriffTyp] = [ac_Declaration] )
     then exit; // die Komponenten dieses strukturierten Parameters sind bereits deklariert. Nicht noch einmal !

  if ( Dest^.Typ = id_Type ) and ( Source <> pSysId[syTArray] ) then begin
    TListen.InsertVirtualId( Source, Dest );       // type-alias!  Nur bei strukturierten Typen notwendig
    exit
    end
  else;

  if CopySubSub( Source^.SubBlock, Dest ) then
    if (( tIdFlags.IsClassType in Source^.IdFlags ) and ( Source = Dest^.MyType ))
      then { kommt das überhaupt vor -> Testfall? } if Source = Source then else   // nur Code für einen Breakpoint
      else TListen.InsertVirtualId( Source, Dest )        // es gab auch Subs ausser var. Zugriff virtuell
end;

{ TListen.SetIdGeneric }
class procedure TListen.SetIdGeneric( pId: pIdInfo; a: word );
begin
  if a = 0 then
    SetLength( pId^.Name, length( pId^.Name ) - length( cGenericDummy ))            // <0> wieder löschen
  else begin
    include( pId^.IdFlags, tIdFlags.IsGenericType );
    pId^.Name[length( pId^.Name ) - 2] := char( $30 + a )     // Anzahl generics im Namen hinterlegen
    end;
  pId^.Hash := GetHash( pId^.Name )
end;

{ TListen.SetIdTypeClass }
class procedure TListen.SetIdTypeClass( pId: pidInfo );
begin
  {$IFDEF TraceDx} TraceDx.Call( uList, 'SetIdTypeClass', pId^.Name ); {$ENDIF}
  if pId <> pSysId[syObject] then begin
    pId^.TypeGroup := coClass;
  //  if pId^.MyParent = nil then                               // unbekannte Class
  //    pId^.MyParent := pSysId[syObject];                      // hat nicht (unbedingt) TObject als direkten Vorfahren
    pId^.IdFlags := pId^.IdFlags + [tIdflags.NoCopy, tIdflags.IsClassType]
    end
end;

{ TListen.SetSubConst }
class procedure TListen.SetSubConst( pId: pIdInfo );
  procedure SetSubConstSub( pId: pIdInfo );
  begin
    while pId <> nil do begin
      if pId^.Typ = id_Var then begin
        ChangeIdType( pId, id_Const );
        if ( pId^.IdFlags * [tIdFlags.IsPointer, tIdFlags.IsClassType] = [] ) then
          SetSubConstSub ( pId^.SubBlock );
        end;
      pId := pId^.NextId
      end;
  end;
begin
  {$IFDEF TraceDx} TraceDx.Call( uList, 'SetSubConst', pId^.Name ); {$ENDIF}
  if pId^.IdFlags * [tIdFlags.IsPointer, tIdFlags.IsClassType] = [] then
    SetSubConstSub ( pId^.SubBlock );
end;

{$ENDREGION }

{$REGION '--------- Generics ---------------' }

class procedure TListen.SetRealGenericTypes( Source, Dest: pIdInfo; IdPegel: tIdSeqIndex );

  procedure SetRealType( pId: pIdInfo );
  begin
    while pId <> nil do begin
      if pId^.MyType = Source then begin
//        CopyTypeInfos( IdSequenz.Stack[IdPegel].IdpId, pId );
        CopySub( IdSequenz.Stack[IdPegel].IdpId, pId );
        end;
      SetRealType( pId^.SubBlock );
      pId := pId^.NextId
      end
  end;

begin
  while ( Source <> nil ) and ( tIdFlags.IsGenericDummy in Source^.IdFlags ) do begin
//    if IdSequenz.Stack[IdPegel].IdpId <> nil then    // ist nil, wenn im real generic kein Id steht sondern direkt "array" oder "class"
      SetRealType( Dest );
    Source := Source^.NextId;
    inc( IdPegel )
    end
end;

{$ENDREGION }

{$REGION '--------- Overload ---------------' }

{ getBaseType }
class function TListen.getBaseType( pId: pIdInfo): pIdInfo;
begin
  Result := pId;
  if Result <> nil then
    while ( Result^.MyType <> nil ) and ( Result^.MyType <> @DummyIdArrayOf ) do
      Result := Result^.MyType
end;

{$IFDEF TraceDx}
{ TListen.CalcSignatur }
class function TListen.CalcSignatur( pIdDecl: pIdInfo ): tSignatur;
type aSig = packed array[0..sizeOf(tSignatur)-1] of byte;
     pSig = ^aSig;
var  pid  : pIdInfo;
     idx  : byte;
begin
//  {$IFDEF TraceDx} TraceDx.Call( uList, 'CalcSignatur', pIdDecl^.Name ); {$ENDIF}
  Result := 0;
  idx    := 0;
  pId    := getParam1( pIdDecl );
  while pId <> nil do begin
    inc( idx );
    pSig(@Result)^[idx mod sizeOf( tSignatur )] := lo( getBaseType( pId )^.TypeNr );
    pId := pId^.NextId
    end;
  pSig(@Result)^[0] := idx
end;
{$ENDIF}

{ TListen.InsertOverloadId }
class function TListen.InsertOverloadId( var pIdDecl: pIdInfo; pIdStart: pIdInfo ): boolean;
{ pIdDecl in : der Dummy
          out: der gefundene richtige overload-Id }
var pId, pIdFirst: pidInfo;
    {$IFDEF TraceDx} Signatur: tSignatur; {$ENDIF}

  procedure MoveSubAcs( pIdSource, pIdDest: pIdInfo );
  var pAcNext, pAc: pAcInfo;
      pIdKill: pIdInfo;
  begin                                // 1. alle Ids unter Dummy löschen, sind nämlich unterm gefundenen overload schon vorhanden
    pIdDest := pIdDest^.SubBlock;      // 2. vorher alle Acs unter diesen Ids moven
    while pIdSource <> nil do begin
      pAc := pIdSource^.AcList;
      while pAc <> nil do begin
        pAcNext := pAc^.NextAc;     // vorher merken, wird im MoveAc() auf nil gesetzt
        MoveAc( pAc, pIdDest );
        pAc := pAcNext
        end;
      pIdSource^.AcList := nil;
      pIdKill   := pIdSource;
      pIdSource := pIdSource^.NextId;
      pIdDest   := pIdDest^.NextId;
      TListen.FreeIdAcSub( pIdKill, true )   // 3. Id mit allen Subs und Acs löschen
      end;
  end;

  procedure SetPrevBlock( pIdOwner: pIdInfo );
  var pId: pIdInfo;
  begin
    pId := pIdOwner^.SubBlock;
    while pId <> nil do begin pId^.PrevBlock := pIdOwner; pId := pId^.NextId end
  end;

  function SignaturEqual( pId1, pId2: pIdInfo ): boolean;
  begin
    if tIdFlags.IsOperator in pId1^.IdFlags then
      if getBaseType( pId1^.MyType ) <> getBaseType( pId2^.MyType ) then exit( false );   // NUR für Operatoren: Result-Typ muss auch passen
    pId1 := pId1^.SubBlock;
    pId2 := pId2^.SubBlock;

    while ( pId1 <> nil ) and ( pId2 <> nil ) and ( tIdFlags.IsParameter in pId1^.IdFlags ) and ( tIdFlags.IsParameter in pId2^.IdFlags ) do begin
      if tIdFlags.IsGenericDummy in pId1^.IdFlags then begin
        if not ( tIdFlags.IsGenericDummy in pId2^.IdFlags ) then exit( false )     // beide müssen generic-Dummys sein sonst false
        end
      else if ( getBaseType( pId1^.MyType ) = getBaseType( pId2^.MyType ))  or     // Basistypen müssen übereinstimmen   ODER
              (( pId1^.MyType <> nil ) and ( pId2^.MyType <> nil )   and
               ( tIdFlags.IsGenericDummy in pId1^.MyType^.IdFlags )  and           // beide Basistypen generic-Dummys
               ( tIdFlags.IsGenericDummy in pId2^.MyType^.IdFlags ))
             then
             else exit( false );                                                   // -> sonst false
      pId1 := pId1^.NextId;
      pId2 := pId2^.NextId;
      end;
    Result := (( pId1 = nil ) or not ( tIdFlags.IsParameter in pId1^.IdFlags ))  and
              (( pId2 = nil ) or not ( tIdFlags.IsParameter in pId2^.IdFlags ))
  end;

begin
  {$IFDEF TraceDx} TraceDx.Call( uList, 'InsertOverloadId', pIdDecl^.Signatur.ToHexString( sizeOf(Signatur)*2 ) ); {$ENDIF}
  pIdFirst := pIdStart;
  {$IFDEF TraceDx} Signatur := pIdDecl^.Signatur;  {$ENDIF}
  while pIdStart <> nil do
    if ( pIdStart^.Hash = pIdFirst^.Hash ) and SignaturEqual( pIdStart, pIdDecl ) and AnsiSameText( pIdStart^.Name, pIdFirst^.Name ) then begin
      { alle SubIds-Acs vom Dummy hierhin: }
      pIdDecl^.PrevBlock := pIdStart;
      MoveLastAcsUp( pIdDecl, pIdDecl^.AcList );   // die letzten Acs deren IdUse auf pIdDecl zeigt: pIdUse nach pIdDecl^.prev umbiegen
      MoveAc( pIdDecl^.AcList, pIdStart );         // der Proc-Declare selbst wurde eben nicht erreicht, extra move

      MoveSubAcs( pIdDecl^.SubBlock, pIdStart );     // und für alle Sub-Ids das Unused-Flag setzen
      pIdDecl := pIdStart;                           // den gefundenen overload-Id auch zurückliefern
      exit( pIdFirst <> pIdStart )                   // falls der gefundene nicht der erste ist wird vom Aufrufer noch der overload-ac_declare verschoben
      end
    else
      pIdStart := pIdStart^.NextId;

  { Signatur nicht gefunden. pIdDecl jetzt zusätzlich in PrevBlock einhängen. Dafür den Namen verhunzen: }
  pId := InsertId( ' ' + pIdFirst^.Name, pIdDecl^.PrevBlock, pIdDecl^.Typ, false );
  pId^.Name     := pIdFirst^.Name;      // Namen und Hash wieder herstellen
  pId^.Hash     := pIdFirst^.Hash;      //    aus pIdFirst weil identisch!
  {$IFDEF TraceDx} pId^.Signatur := Signatur; {$ENDIF}           // Signatur aus Dummy übernehmen
  { die Sub-Ids umhängen: }
  pId^.SubBlock := pidDecl^.SubBlock;   // Subs können direkt aus Dummy übernommen werden
  pId^.SubLast  := pidDecl^.SubLast;    //  "
  SetPrevBlock( pId );                  // der PrevBlock meiner SubIds zeigt noch auf Dummy -> auf neuen Id umbiegen
  { alle seit Umbiegung auf overload neu hinzugekommenenen Acs: IdUse umbiegen: }
  pIdDecl^.PrevBlock := pId;
  MoveLastAcsUp( pIdDecl, pIdDecl^.AcList );   // die Acs abwärts bis Proc-Declare (deren IdUse auf pIdDecl zeigt): pIdUse nach pIdDecl^.prev umbiegen
  MoveAc( pIdDecl^.AcList, pId );              // der Proc-Declare selbst wurde eben nicht erreicht, extra move

  TListen.CopyVarTypeInfos( pidDecl, pId );
  pId^.IdFlags  := pidDecl^.IdFlags;    //  "
  exclude( pId^.IdFlags, tIdFlags.IdUnused );
  SetIdProjectUse( pId );
  pIdDecl       := pId;                 // den neuen overload-Id auch zurückliefern
  Result        := true                 // und vom Aufrufer den overload-ac_declare verschieben
end;

{$ENDREGION }

{$REGION '------------- Id/Ac suchen (only for Colored ViewFile) --------------' }

{ TListen.IncAc }
class procedure TListen.IncAc( var pAc: pAcInfo; var ai, aii: word );
begin
  if aii = high( tAcArray ) then begin
    inc( ai );
    aii := 0;
    pAc := @AcArrays[ai]^[0]
    end
  else begin
    inc( aii );
    if ( ai = high( AcArrays ) ) and ( aii >= NextAcIndex )
      then pAc := nil
      else inc( pAc )
    end
end;

{ TListen.SearchNextFileAc }
class function TListen.SearchNextFileAc( d: tFileIndex; z: tLineIndex; var ai, aii: word ): pAcInfo;
var i, j, min, max: word;
begin
  {$IFDEF TraceDx} TraceDx.Call( uList, 'SearchNextFileAc ' + ai.ToString + ' ' + aii.ToString, z ); {$ENDIF}
  min := aii;
  for i := ai to high( AcArrays ) do begin
    if i = high( AcArrays )
      then max := NextAcIndex-1
      else max := high( tAcArray );
    Result := @AcArrays[i]^[min];
    for j := min to max do
      if not ( tAcFlags.DontFind in Result^.AcFlags ) and ( Result^.Position.Datei = d ) and ( Result^.Position.Zeile >= z )
        then begin ai := i; aii := j; exit end
        else inc( Result );
    min := 0
    end;
  Result := nil;
end;

{$ENDREGION }

{$REGION '--- Id/Ac löschen, ändern und anzeigen ----' }

{ TListen.ChangeAcType }
class procedure TListen.ChangeAcType( pAc: pAcInfo; NewAc: tAcType );
var LokalAc: pAcInfo;
    AltAc  : tAcType;
    pId    : pIdInfo;
begin
  AltAc := pAc^.ZugriffTyp;
  if AltAc <> NewAc then begin
    {$IFDEF TraceDx} TraceDx.Call( uList, 'ChangeAcType', pAc^.IdDeclare^.Name, cAcShow[NewAc].Text ); {$ENDIF}
    pId := pAc^.IdDeclare;
    { todo: neuen Zugrifftyp setzen: }
    pAc^.ZugriffTyp := NewAc;
    inc( ZaehlerAc[NewAc] );
    Include( pId^.AcSet, NewAc );
    { alten Zugrifftyp löschen, ggf auch aus SummenMenge entfernen: }
    dec( ZaehlerAc[AltAc] );
    LokalAc := pId^.AcList;
    while ( LokalAc <> nil ) and ( LokalAc^.ZugriffTyp <> AltAc ) do LokalAc := LokalAc^.NextAc;
    if LokalAc = nil then Exclude( pId^.AcSet, AltAc )   // kommt nirgends mehr vor
    end
end;

{ TListen.ChangeIdType }
class procedure TListen.ChangeIdType( pId: pIdInfo; NewTyp: tIdType );
begin
  dec( ZaehlerId[pId^.Typ] );
  inc( ZaehlerId[NewTyp  ] );
  pId^.Typ := NewTyp;
  if NewTyp = id_Type then
    pId^.TypeNr := GetTypeNr
end;

{ TListen.ChangeIdTypeNoCount }
class procedure TListen.SetAsGenType( pId: pIdInfo; TypNr: tTypeNr);
begin
  dec( ZaehlerId[pId^.Typ] );
  inc( ZaehlerId[id_Type ] );
  pId^.Typ    := id_Type;
  pId^.TypeNr := TypNr;
  include( pId^.IdFlags, tIdFlags.IsGenericDummy );
  include( pId^.IdFlags, tIdFlags.IsParameter    )     // weil in ParseIdentifier\FindOverload der Parameter durch den DummyTyp ersetzt wird
end;

{ nötig?    TListen.SetAcPrev }
class procedure TListen.SetAcPrev( LastAc: pAcInfo; var pAcPrev: pAcInfo );
begin
  LastAc^.AcPrev := pAcPrev;
  pAcPrev := LastAc;
end;

{ TListen.getAcNameLong}
//class function TListen.getAcNameLong( pAc: pAcInfo; const Trenn: string ): string;
//begin
//  Result := pAc^.IdDeclare^.Name;
//  pAc := pAc^.AcPrev;
//  while pAc <> nil do begin
//    Result := pAc^.IdDeclare^.Name + Trenn + Result;
//    pAc := pAc^.AcPrev
//    end
//end;

{ TListen.getBlockNameLong }
class function TListen.getBlockNameLong( b: pIdInfo; const Trenn: string ): string;
begin
  if b^.PrevBlock = @IdMainMain then
    Result := '<Wurzel>'
  else begin
    Result := b^.Name;
    while b^.PrevBlock^.PrevBlock <> @IdMainMain do begin
      b := b^.PrevBlock;
      Result := b^.Name + Trenn + Result
      end
    end
end;

{ TListen.getBlockNameLongMain }
class function TListen.getBlockNameLongMain( b: pIdInfo; const Trenn: string ): string;
begin
  result := b^.Name;
  while b^.PrevBlock <> @IdMainMain do begin
    b := b^.PrevBlock;
    result := b^.Name + Trenn + result
    end;
end;

(* ShowAcSet *)
class function TListen.ShowAcSet( ac: tAcTypeSet ): string;
const cZugriff: array[tAcType] of char = ('D','R','W','A','X');    // Declare, Read, Write, ReadAdr, Unknown
var   i: tAcType;
begin
  Result := StringOfChar( ' ', ord( high( tAcType ))+1 );
  for i := low( tAcType ) to high( tAcType ) do
    if i in ac then Result[ord(i)] := cZugriff[i]
end;

(* FreeIdAcSub *)
class procedure TListen.FreeIdAcSub( pKillMain: pIdInfo; KillMainId: boolean );
var pIdKill, pId: pIdInfo;
    pKillAc, pAc: pAcInfo;
begin
  {$IFDEF TraceDx} TraceDx.Call( uList, 'FreeIdAcSub', pKillMain^.Name ); {$ENDIF}
  pId := pKillMain^.SubBlock;
  while pId <> nil do begin
    pIdKill := pId;
    pId := pId^.NextId;
    FreeIdAcSub( pIdKill, true )
    end;
  pAc := pKillMain^.AcList;
  while pAc <> nil do begin
    pKillAc := pAc;
    pAc := pAc^.NextAc;
    TListen.FreeAc( pKillAc )
    end;
  pKillMain^.SubBlock := nil;
  pKillMain^.SubLast  := nil;
  pKillMain^.AcList   := nil;
  pKillMain^.LastAc   := nil;
  if KillMainId then
    FreeId( pKillMain )
end;

(* FreeIdAcSub_Ausketten *)
class procedure TListen.FreeIdAcSub_Ausketten( Kill: pIdInfo );
{ löscht "Kill" aus seiner Liste}
{ - Self: wenn in methode nicht genutzt                            kettet im Parent aus und
  - Result: wenn in function nicht genutzt                         löscht mit allen Acs und Subs usw
  - Unbekannt-Ids wenn später aufgelöst (Pointer, Objekte) }
var pId: pIdInfo;
begin
  {$IFDEF TraceDx} TraceDx.Call( uList, 'FreeIdAcSub_Ausketten', Kill^.Name ); {$ENDIF}

  with Kill^.PrevBlock^ do begin
    { 1.  Vorgänger suchen: }
    if SubBlock = Kill then begin
      {Vorgaenger=} pId := nil;
      SubBlock := SubBlock^.NextId
      end
    else begin
      pId := SubBlock;
      while pId^.NextId <> Kill do pId := pId^.NextId;
      pId^.NextId := Kill^.NextId;
      end;
    { 2. }
    if SubLast = Kill then
      SubLast := pId
    end;
  FreeIdAcSub( Kill, true )
end;

(* TestIdForUnbekannt *)
class procedure TListen.TestIdForUnbekannt( pIdBekannt, pIdUnbekannt: pIdInfo );
var pAc: pAcInfo;

  procedure SucheInUnbekanntListe( var Start: pIdInfo; h: tHash; const Id: tIdString);
  begin
  while Start <> nil do with Start^ do
     if ( Hash = h ) and AnsiSameText( Name, Id )           // todo: HashCollision Zähler
     then break
     else Start := NextId
  end;   { SucheInUnbekanntListe }

  procedure MyTypesUmbiegen( pId: pIdInfo );
  begin
    while pId <> nil do begin
      {if pId^.SubBlock <> nil then} MyTypesUmbiegen( pId^.SubBlock );
      if pId^.MyType = pIdUnbekannt then begin
        {$IFDEF TraceDx} TraceDx.Send( uList, 'Umbiegen', pId^.Name ); {$ENDIF}
        pId^.MyType := pIdBekannt
        end;
      pId := pId^.NextId
      end  { MyTypesUmbiegen }
  end;

begin
//  {$IFDEF TraceDx} TraceDx.Call( uList, 'TestIdForUnbekannt', BlockpId^.Name ); {$ENDIF}
if pIdUnbekannt = nil
then pIdUnbekannt := MainBlock[mbUnDeclaredUnScoped].SubBlock
else pIdUnbekannt := pIdUnbekannt^.NextId;

SucheInUnbekanntListe( pIdUnbekannt, pIdBekannt^.Hash, pIdBekannt^.Name) ;
if pIdUnbekannt <> nil then begin  //UnbekanntGefunden (Unbekannt, Single)
   {$IFDEF TraceDx} TraceDx.Send( uList, 'Unbekannt "' + pIdUnbekannt^.Name + '" wird umgehängt'); {$ENDIF}
   { für die bisher unbekannten Acs den Declarer umbiegen: }
   pAc := pIdUnbekannt^.AcList;
   while pAc <> nil do begin pAc^.IdDeclare := pIdBekannt; pAc := pAc^.NextAc end;
   { echte Access-Liste an die (bisher) unbekannte anhängen: }
   pIdBekannt^.LastAc^.NextAc := pIdUnbekannt^.AcList;
   pIdBekannt^.LastAc := pIdUnbekannt^.LastAc;
   pIdBekannt^.AcSet  := pIdBekannt^.AcSet + pIdUnbekannt^.AcSet;
   { alle Deklarationen der aktuellen Ebene auf MyType-Referenzen nach Unbekannt testen }
   MyTypesUmbiegen( pIdBekannt^.PrevBlock^.SubBlock );
   pIdUnbekannt^.AcList := nil;                // Wichtig!!! AcList ist umgehängt worden, soll also NICHT gelöscht werden!
   FreeIdAcSub_Ausketten( pIdUnbekannt )
   end
end;

(* TestReducedAcSet *)
procedure TestReducedAcSet( pId: pIdInfo; AcTyp: tAcType );
var pAc: pAcInfo;
begin
  pAc := pId^.AcList;
  while pAc <> nil do
    if pAc^.ZugriffTyp = AcTyp
      then exit
      else pAc := pAc^.NextAc;
  Exclude( pId^.AcSet, AcTyp )   // AcTyp wurde nicht in der Liste gefunden, also rausnehmen aus Set
end;

(* DeleteAc *)
class procedure TListen.DeleteAc( pAc: pAcInfo; forget: boolean );
var preAc: pAcInfo;
begin
  { 1. unterm Owner ausketten: }
  with pAc^.IdDeclare^ do begin
    if AcList = pAc then begin
      preAc  := nil;
      AcList := pAc^.NextAc    // pAc ist der erste
      end
    else begin
      preAc := AcList;
      while preAc^.NextAc <> pAc do preAc := preAc^.NextAc;
      preAc^.NextAc := pAc^.NextAc;
      end;
    if LastAc = pAc then
      LastAc := preAc
    end;
  { 2. Owner anpassen: }
  TestReducedAcSet( pAc^.IdDeclare, pAc^.ZugriffTyp );
  { 3. ggf recyclen: }
  if forget then
    FreeAc( pAc )
end;

(* MoveAc *)
class procedure TListen.MoveAc( pAc: pAcInfo; pIdNeu: pIdInfo );
begin
  {$IFDEF TraceDx} TraceDx.Call( uList, 'MoveAc', pAc^.IdDeclare^.Name, pIdNeu^.Name ); {$ENDIF}
  with pIdNeu^ do begin   // unter pIdNeu hinten anhängen
    if LastAc <> nil then
      LastAc^.NextAc := pAc;
    LastAc := pAc;
    if AcList = nil then
      AcList := pAc;
    include( AcSet, pAc^.ZugriffTyp )
    end;
  DeleteAc( pAc, false );                       // unter altem (jetzigem Noch-) Owner ausketten
  pAc^.NextAc    := nil;
  pAc^.IdDeclare := pIdNeu
end;

(* CopyLastAc *)
class procedure TListen.CopyLastAc( pIdFrom, pIdTo: pIdInfo );
var Id: tIdPosInfo;
begin
  Id.Str := pIdFrom^.Name;
  Id.Pos := pIdFrom^.LastAc^.Position;
  include( TListen.InsertIdAc( Id, pIdTo, pIdFrom^.Typ, ac_Read )^.LastAc^.AcFlags, tAcFlags.DontFind )
end;

(* MoveSubIdsUp *)
class procedure TListen.CaptureSubIds( pIdOwner: pIdInfo );
var pAc: pAcInfo;
    pId: pIdInfo;
begin
  pId := pIdOwner^.SubBlock;
  while pId <> nil do begin
    pId^.PrevBlock := pIdOwner;
    pAc := pId^.AcList;
    while pAc <> nil do begin
      pAc^.IdDeclare := pId;
      pAc := pAc^.NextAc
      end;
    pId := pId^.NextId
    end
end;

(* MoveLastAcsUp *)
class procedure TListen.MoveLastAcsUp( pId: pIdInfo; pAcEnde: pAcInfo );
{ ab dem letzten Ac rückwärts suchen: solange useBlock = pId: useBlock auf pId^.prevBlock setzen }
{ Voraussetzung: es sind nur soviele Acs, dass max ein AcArrays-Wechsel stattfindet }
var idx: tIdAcArrayIdx;
    adx: word;
    pAc: pacInfo;
begin
  {$IFDEF TraceDx} TraceDx.Call( uList, 'MoveLastAcsUp', pId^.Name ); {$ENDIF}
  adx := high( AcArrays );
  idx := NextAcIndex-1;
  pAc := @AcArrays[adx][idx];
  while pAc <> pAcEnde do begin
    if pAc^.IdUse = pId then begin
      {$IFDEF TraceDx} TraceDx.Send( uList, 'MoveLastAcsUp', pAc^.IdDeclare^.Name ); {$ENDIF}
      pAc^.IdUse := pId^.PrevBlock;
      end;
    if idx = 0 then begin
      {$IFDEF TraceDx} TraceDx.Send( uList, 'MoveLastAcsUp: AcArray-Wechsel!!!' ); {$ENDIF}
//      {$IFDEF DEBUG} asm int 3 end; {$ENDIF}    // noch nicht getestet: jetzt tun!
      dec( adx );                               // in vorigen Block wechseln
      idx := high( tAcArray );
      pAc := @AcArrays[adx][idx]
      end
    else begin
      dec( idx );
      dec( pAc )
      end
    end
end;

(* MoveGUID
class procedure TListen.MoveGUID( pIdLastAlt: pIdInfo{der Vorgänger des umzuhängenden} );
var pId: pIdInfo;
begin
  if pIdLastAlt = nil then begin
    pId := MainBlock[mbConstStrings].SubLast;
    { unter Strings aushängen: }
    MainBlock[mbConstStrings].SubBlock := nil;
    MainBlock[mbConstStrings].SubLast  := nil
    end
  else begin
    pId := pIdLastAlt^.NextId;
    { unter Strings aushängen: }
    pIdLastAlt^.NextId := nil;
    MainBlock[mbConstStrings].SubLast  := pIdLastAlt
  end;
  { unter GUID einhängen: }
  if MainBlock[mbGUID].SubBlock = nil
    then MainBlock[mbGUID].SubBlock := pId
    else MainBlock[mbGUID].SubLast^.NextId := pId;
  MainBlock[mbGUID].SubLast := pId;
  pId^.PrevBlock := @MainBlock[mbGUID];
  pId^.NextId    := nil
end;        *)

{$ENDREGION }

{$REGION '--------- TListen Init/Exit ---------------' }

class procedure TListen.xDeleteUserSystemAcs;
  procedure DeleteAcs( pId: pIdInfo );
  begin
    while pId <> nil do with pId^ do begin
      AcList := nil;
      LastAc := nil;
      AcSet  := [];
      DeleteAcs( SubBlock );
      pId := NextId
      end
  end;
begin
  DeleteAcs( LastSystemId^.NextId );
  NextAcIndex := 0
end;

(* ResetZaehler *)
procedure ResetZaehler;
begin
  FillChar( ZaehlerId, SizeOf( ZaehlerId ), 0 );
  FillChar( ZaehlerAc, SizeOf( ZaehlerAc ), 0 );
  ZaehlerIds    := 0;
  ZaehlerAcs    := 0;
end;

{ TListen.SaveToFile }
class procedure TListen.SaveToFile( const f: string );
const cCntWidth = 10;
    cFlagStr= 'Flags  : ^=Pointer C=ClassType V=Virtual n=NoCopy i=InternVirtual W=WriteParam'          + sLineBreak +
              '         d=Dummy e=enum <=Parameter r=result R=rekursiv s=ClassStatic o=Override'        + sLineBreak +
              '         P=Private p=protected S=strict I=Interface +=operator O=Overload L=Library'     + sLineBreak +
              '         ==optionalPara x=not Used h=helper G=GenericType g=GenericDummy D=Default'      + sLineBreak +
              '         K=constructor Y=CopySource >=Out-Parameter, m=ParaMirror c=class var/method'    + sLineBreak +
              '         Q=UnresolvedOverload'                                                           + sLineBreak +
              '         F=forward s=UnitSystem a=anonym S=Self m=MsgHdlr P=Projekt #=Literal'           + sLineBreak +
              '         I=InterfaceSection'
              ;// S=TypeSet F=TypeFile';
    cZugrStr= 'Zugriff: D=Declaration R=Read W=Write A=ReadAdress X=Unknown';
    cGrpStr = 'Gruppe : x=alle i=Int e=Enum b=Bool r=Real s=Str c=Char P=Ptr M=Method C=Class I=Interface'     + sLineBreak +
              '         [=Set F=File R=Record A=Array O=ArrayOf T=TArray';
    cBool   : array[boolean] of string = ( 'false', 'True' );
var t: text;
    m: tMainBlock;
    ac: tAcType;
    id: tIdType;
    u: integer;
    p: pIdInfo;
    f0,f1: string;

  procedure SaveBlock( l: word; pIdOwner, pId: pIdInfo );
  const
    cFlags  : array[tIdFlags] of char
            = ('^','C','V','n','i','W','d','e','<','r','R','s','o','P','p','S','I','+','O','L','=','x','h','G','g','D','K','Y','>','m','c','Q');
    cFlags2 : array[tIdFlags2] of char
            = ('F','s','a','S','m','P','H','#','I','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-');
    cTypeGrp: array[tTypeGroup] of char = ( ' ','x','i','e','b','r','s','c','P','M','C','I','[','F','R','A','O','T');
    cShowHelper = false;//true;
  var
    pAc    : pAcInfo;
    e,zu,fl_0, fl_1,
    sMyHelper,
    sMyParent,
    sTyp,
    sMyType: string;
    i, cnt : longword;
  begin
    while pId <> nil do with pId^ do begin
//      {$IFDEF TraceDx} TraceDx.Send( uList, 'SaveToFile', pId^.Name ); {$ENDIF}
      if not ( (tIdFlags.fromSystemLib in IdFlags ) and ( AcList = nil )) then begin  // System-Ids nur wenn AccessListe vorhanden
//        if pid.Name = 'Winapi' then
//          e := '';
        assert( pIdOwner = PrevBlock, pId^.Name );
        if pIdOwner = PrevBlock
          then e := ''
          else e := ' Owner?';

        sTyp := cIdShow[Typ].Text;

        if MyType <> nil
          then sMyType := MyType^.Name
          else sMyType := '-';

        if MyParent <> nil
          then sMyParent := MyParent^.Name
          else sMyParent := '';

        if cShowHelper then
          if NextHelper = nil
            then sMyHelper := ''
            else sMyHelper := NextHelper^.Name;

        pAc := AcList;
        cnt := 0;
        while pAc <> nil do begin inc( cnt ); if tAcFlags.Rekursiv in pAc^.AcFlags then include( IdFlags, tidflags.IsRekursiv ); pAc := pAc^.NextAc end;

        fl_0 := f0;
        for i := ord( low( tIdFlags )) to ord( high( tIdFlags )) do
          if tIdFlags(i) in IdFlags then fl_0[i+cSpalte0] := cFlags[tIdFlags(i+cSpalte0)];
        fl_1 := f1;
        for i := ord( low( tIdFlags2 )) to 8 {ord( high( tIdFlags ))} do
          if tIdFlags2(i) in IdFlags2 then fl_1[i+cSpalte0] := cFlags2[tIdFlags2(i+cSpalte0)];

        zu := showAcSet( AcSet );

        if Typ = id_Filename then begin
          Name[0] := UpCase( Name[0] );   // LW-Buchstabe immer groß
          sMyHelper := Name
          end;
        Writeln( t, Format(                              '%-24.24s %-10.10s %s ' +               '%-9.9s %s%s' + '  %s%4d %-9.9s  %s',
                           [StringOfChar(' ', l shl 1 ) + Name,    sTyp,    cTypeGrp[TypeGroup], sMyType,fl_0,fl_1, zu,cnt,sMyParent,sMyHelper] ) );

        if SubBlock <> nil
          then SaveBlock( l+1, pId, SubBlock )
        end;
      pId := NextId
      end;
  end;

  procedure ShowIdListe;
  var i,j,max: word;
      pId: pIdInfo;
  begin
  for i := 0 to high( IdArrays ) do begin
    if i = 0
      then j := NextIdIndex_
      else j := 0;
    pId := @IdArrays[i]^[j];
    if i = high( IdArrays )
      then max := NextIdIndex-1         // der letzte Id-Block wird zZ nur bis hierher genutzt
      else max := high( tIdArray );     // alle anderen bis zum Ende
    repeat
      writeln( t, i:2, j:6, ' ', pId^.Name );
      inc( pId );
      inc( j )
    until j > max;
    end;
  end;

  procedure ShowAcListe;
  var i,j,max: word;
      pAc: pAcInfo;
  begin
  for i := 0 to high( AcArrays ) do begin
    j := 0;
    pAc := @AcArrays[i]^[j];
    if i = high( AcArrays )
      then max := NextAcIndex-1         // der letzte Id-Block wird zZ nur bis hierher genutzt
      else max := high( tAcArray );     // alle anderen bis zum Ende
    repeat
      if pAc^.Position.Datei <> 0 then
        writeln( t, i:2, j:6, ' ', DateiListe[pAc^.Position.Datei]^.StrList[pAc^.Position.Zeile] );
      inc( pAc );
      inc( j )
    until j > max;
    end;
  end;

  procedure SaveArray( const a: array of tIdInfo );
  { Controls, Defines, Keywords }
  var pId: pIdInfo;
      pAc: pAcInfo;
      i  : word;
      cnt: longword;
  begin
    for i := 0 to high( a ) do begin
      pId := @a[i];
      if pId^.AcList <> nil then begin
        pAc := pId^.AcList;
        cnt := 0;
        while pAc <> nil do begin inc( cnt ); pAc := pAc^.NextAc end;
        writeln( t, Format( '%-24.24s ' + '%-20.20s %s'       +          '     R   %4d              ',
                           [pId^.Name,    cIdShow[pId^.Typ].Text,f0+f1,            cnt] ) );
        end
      end
  end;

  procedure SaveFiles;
  var i : tFileIndex_;
      u : integer;
      n : string;
      pu: pIdPtrInfo;
  begin
    for i := cFirstFile to high( DateiListe ) do with DateiListe[i]^ do begin
      if UnitName = '' then n := '<$I>' else n := UnitName;
      write( t, Format( '%3d %-20.20s %-72.72s', [i, n, Filename.ToLowerInvariant] ));
      if UnitName <> '' then begin
        u := 0;
        pu := UsesListe;
        while pu <> nil do begin inc( u ); pu := pu^.NextIdPtr end;
        write( t, 'Uses:', u:3 );
        if LibraryPath in fiFlags then write( t, ' LibraryPath' );
        write( t, '   $DEFINED:' );
        for u := UserDefines + cPreDefines to DefinesHigh do
          if u mod cDefinesBits in CompDefines[u div cDefinesBits] then
            write( t, ' ' + Defines[u] )
        end
      else
        if prevFile <> cKeinFileIndex then
           write( t, '$I by ' + DateiListe[prevFile]^.FileName.ToLowerInvariant );
      writeln( t )
      end;
  end;

  procedure SaveOptions( const s0: string; const a: TArray< string >; Start: word );
  var i: integer;
  begin
//    if high( a ) >= Start then begin
      writeln( t );
      writeln( t, '=== Option ', s0, ' ===' );
      for i := Start to high( a ) do
        writeln( t, a[i] )
//      end
  end;

  function MainBlockHeader( m: tMainBlock ): string;
  begin
    Result := sLineBreak + '=== ' + MainBlock[m].Name + ' ==='
  end;

{ SaveToFile }
begin
// {$IFDEF TraceDx} TraceDx.Call( uList, 'TListen.SaveToFile' ); {$ENDIF}
  if UseClipBoard then exit;
  f0 := StringOfChar( ' ', ord( high( tIdFlags  ))+1 );
  f1 := StringOfChar( ' ', 8 {ord( high( tIdFlags2 ))}+1 );
  u := 0;
  p := MainBlock[mbUnDeclaredUnScoped].SubBlock;
  while p <> nil do begin inc( u ); p := p^.NextId end;
  assignfile( t, f );
  try
    rewrite( t );
    writeln( t, cFlagStr );
    writeln( t, cZugrStr );
    writeln( t, cGrpStr  );
    writeln( t );
    writeln( t, (high( IdArrays ) * succ( high( tIdArray )) + NextIdIndex - NextIdIndex_   ):cCntWidth, ' Identifier' );
    writeln( t, (high( AcArrays ) * succ( high( tAcArray )) + NextAcIndex - VirtualCount   ):cCntWidth, ' Zugriffe'   );
    writeln( t, CntIdCompares                                                               :cCntWidth, ' Identifier-Vergleiche' );
    writeln( t, HashCollisions                                                              :cCntWidth, ' Hash gleich aber String ungleich' );
    writeln( t, u                                                                           :cCntWidth, ' Einträge in Unbekannt-Liste' );
    writeln( t, AcSequenz.MaxPegel                                                          :cCntWidth, ' maximale Länge geschachtelter Ac-Folge'{ (' + gMaxAcSeq.ToString + ')'} );
    writeln( t, IdSequenz.MaxPegel                                                          :cCntWidth, ' maximale Länge geschachtelter Id-Folge'{ (' + gMaxIdSeq.ToString + ')'} );
  //  writeln( t, NextIdIndex_                                                                :cCntWidth, ' Anzahl System-Ids' );
    writeln( t, VirtualCount                                                                :cCntWidth, ' Anzahl virtual Id/Ac' );
    writeln( t, succ( high( IdArrays ))                                                     :cCntWidth, ' Anzahl IdArrays' );
    writeln( t, succ( high( AcArrays ))                                                     :cCntWidth, ' Anzahl AcArrays' );
  //  writeln( t, TypeCountSys                                                                :cCntWidth, ' Anzahl SystemTypes' );
  //  writeln( t, TypeCount                                                                   :cCntWidth, ' Anzahl Types' );

    writeln( t, sLineBreak + '=== Dateien ===' );
    SaveFiles;

    SaveOptions( 'Includes Unit' , IncludesUnitAll, 1 );
    SaveOptions( 'UnitPrefixes'  , UnitPrefixes,    1  );
    SaveOptions( 'DefinedSymbols', FileOptions.DefinedSymbols.Split( [ TPath.PathSeparator ] ), 0 );

    writeln( t );
    writeln( t, '  Name                   IdTyp      G MyType    ------------------Flags------------------  Acs   Cnt Parent    Helper' );
    writeln( t, '-----------------------------------------------------------------------------------------------------------------------' );

    for m in [low( tMainBlock ) .. mbConstStrings, tMainBlock.mbDefines .. tMainBlock.mbAttributes, mbFilenames ] do begin
      if MainBlock[m].SubBlock <> nil then writeln( t, MainBlockHeader( m ) );    // Die mbDirektiven-Blöcke sind noch nicht aufbereitet und werden hier NICHT ausgegeben
      SaveBlock( 0, @MainBlock[m], MainBlock[m].SubBlock )
      end;

    writeln( t, sLineBreak + '=== Pascal-Direktiven ===' );                      // sondern hier nochmal extra
    SaveArray( PascalDirektiveListe );
    writeln( t, sLineBreak + '=== Compiler-Controls ===' );
    SaveArray( ControlsListe );

    if FileOptions.RegKeywords then begin
       writeln( t, sLineBreak + '=== KeyWords ===' );
       SaveArray( KeyWordListe );
       end;

    writeln( t, sLineBreak + '=== Id- und Ac-Zähler ===' );
    for id := low( tIdType) to pred( high( tIdType )) do writeln( t, ZaehlerId[id]:cCntWidth, ' Id_', cIdShow[id].Text ); writeln( t );
    for ac := low( tAcType) to       high( tAcType )  do writeln( t, ZaehlerAc[ac]:cCntWidth, ' Ac_', cAcShow[ac].Text ); writeln( t );

    {$IFDEF TestKompatibel}
    if CompErrorList.Count > 0 then begin
      writeln( t, sLineBreak + '=== Inkompatible Operatoren ===' );
      for u := 0 to CompErrorList.Count-1 do
        writeln( t, CompErrorList[u] )
      end;
    {$ENDIF}

    if NotImplemented <> EmptyStr then
      writeln( t, sLineBreak + '=== $(ELSE)IF ===' + NotImplemented );

  finally
    CloseFile( t )
  end
end;

(* DisposeIdNames *)
procedure DisposeIdNames( idx, min: tIdAcArrayIdx );
var i: tIdAcArrayIdx;
begin
  for i := min to high( tIdArray ) do
    IdArrays[idx]^[i].Name := ''
end;

(* DisposeFileInfo *)
class procedure TListen.DisposeFileInfo( f: pFileInfo );
begin
  with f^ do begin
    TListen.ClearIdPtrList( UsesListe  );
    Filename  := '';
    UnitName  := '';
    FileDatum := 0;
    dispose( f );
    {$IFDEF HEAPCHECK} HeapCheck.Dispose( f, sizeOf( tFileInfo ) ); {$ENDIF}
    end;
end;

(* DisposeListen *)
procedure DisposeListen;
var f: tFileIndex_;
    i: tIdAcArrayIdx;
begin
  {$IFDEF TraceDx} TraceDx.Send( uList, 'DisposeListen, Anzahl Dateien' , high( DateiListe )); {$ENDIF}
  { Datei-Infos freigeben. Element 0 wurde nicht benutzt: }
  for f := cFirstFileV to high( DateiListe ) {AnzahlDateien} do
    TListen.DisposeFileInfo( DateiListe[f] );
  SetLength( DateiListe, 0 );
  pAktFile := nil;
  pAktUnit := nil;

  TListen.ClearIdPtrList( WithListe    );
  TListen.ClearIdPtrList( GueltigListe );

  { Id und Ac: alle ausser erster Liste löschen: }
  for i := 1 to high( IdArrays ) do begin
    DisposeIdNames( i, 0 );
    dispose( IdArrays[i] );
    {$IFDEF HEAPCHECK} HeapCheck.Dispose( IdArrays[i], sizeOf( IdArrays[i]^ ) ); {$ENDIF}
    end;   // DisposeIdNames wird evtl automatisch im dispose gemacht, testen
  for i := 1 to high( AcArrays ) do begin
    dispose( AcArrays[i] );
    {$IFDEF HEAPCHECK} HeapCheck.Dispose( AcArrays[i], sizeOf( AcArrays[i]^ ) ); {$ENDIF}
    end;

  SetLength( IdArrays, 1 );
  SetLength( AcArrays, 1 )
end;

(* TListen.PreParse *)
class procedure TListen.PreParse;
var b: tMainBlock;
{$IFDEF TestHash} i: word; {$ENDIF}
{$IFDEF TestHash} h: TextFile; {$ENDIF}
begin
  {$IFDEF TraceDx} TraceDx.Call( uList, 'PreParse'          ); {$ENDIF}
  {$IFDEF TraceDx} TraceDx.Send( 'NextIdIndex', NextIdIndex ); {$ENDIF}
  {$IFDEF TraceDx} TraceDx.Send( 'NextAcIndex', NextAcIndex ); {$ENDIF}

  Abbruch := false;
  AbbruchMsg := '  Parser is working.  Press <Escape> to cancel ...';
  UnitSystemPreParse;                   // als erstes, weil braucht noch die alten pointer

  if NextIdIndex_ = 0 then begin       // beim ersten Durchlauf merken
    assert( high( IdArrays    ) = 0, 'cMinInfoCount zu klein für Ids' );
    NextIdIndex_  := NextIdIndex        // 357
    end
  else
    NextIdIndex   := NextIdIndex_;       // Alle Blöcke und Ids aus Inits bleiben dauerhaft erhalten!!!

  SucheIdCtrl.Nesting     := 0;
  NextAcIndex    := 0;
  VirtualCount   := 0;
  HashCollisions := 0;
  CntIdCompares  := 0;
  {$IFDEF TestKompatibel}
    CompErrorList.Clear;
   {$ENDIF}
  FreeIdList     := nil;
  FreeAcList     := nil;

  DisposeListen;
  DisposeIdNames( 0, NextIdIndex );   // die Strings in den gleich zu nullenden IdInfos löschen, sonst SpeicherLeck
  { recyclete Ids und Acs null setzen: }
  FillChar( IdArray0[NextIdIndex], ( high(tIdArray)-NextIdIndex+1 ) * sizeOf( tIdInfo ), 0 );
  FillChar( AcArray0[NextAcIndex], ( high(tAcArray)-NextAcIndex+1 ) * sizeOf( tAcInfo ), 0 );

  IdMainMain.OpenCount[tvAll]  := 0;
  IdMainMain.OpenCount[_tvFil] := 0;
  for b := low( tMainBlock ) to high( tMainBlock ) do begin
    MainBlock[b].Typ               := id_MainBlock;
    MainBlock[b].SubBlock          := nil;
    MainBlock[b].SubLast           := nil;
    MainBlock[b].AcSet             := cAcDummyUsed;    // löschen falls Block leer bleibt
    MainBlock[b].IdFlagsTv[tvAll]  := [];
    MainBlock[b].IdFlagsTv[_tvFil] := [];
    MainBlock[b].OpenCount[tvAll]  := 0;
    MainBlock[b].OpenCount[_tvFil] := 0;
    end;
  { mbBlock0 zeigt NUR auf System: }
  MainBlock[mbBlock0].SubBlock := @UnitSystem;
  MainBlock[mbBlock0].SubLast  := @UnitSystem;

  saCache := nil;
  ParserState.RecordLevel := 0;       // wenn >0 dann innerhalb Record/Class. Suchebene nicht vertiefen !

  AcSequenz.PreParse;
  IdSequenz.PreParse;

  {$IFDEF TestHash}
  assignfile (h, HomeDir + '_Hash.dat');
  rewrite (h);
  for i := 0 to 65535 do if ZaehlerHash[i] > 0 then begin
    writeln (h, i:5, ZaehlerHash[i]:7, '  ', NameHash[i]);
    ZaehlerHash[i] := 0;
    NameHash   [i] := '';
    end
  closefile (h);
  {$ENDIF}

//  UnitSystemPreParse
end;

(* InitListen *)
procedure InitListen;
var b: tMainBlock;
begin
  {$IFDEF TraceDx} TraceDx.Call( uList, 'Init' ); {$ENDIF}

  SetLength( IdArrays, 1 );
  IdArrays[0] := @IdArray0;

  WithListe    := nil;
  GueltigListe := nil;

  SetLength( AcArrays, 1 );
  AcArrays[0] := @AcArray0;

  assert( NextIdIndex = NextIdIndex_ );

  IdMainMain.Name              := 'IdMainMain';
  IdMainMain.Typ               := id_MainBlock;
  IdMainMain.IdFlags2          := [tIdFlags2.IdProjectUse];
  IdMainMain.IdFlagsTv[tvAll]  := [tIdFlagsTv.hasSub, tIdFlagsTv.SubTreeOpen];
  IdMainMain.IdFlags2          := [tIdFlags2.IdProjectUse];
  IdMainMain.IdFlagsTv[_tvFil] := [tIdFlagsTv.hasSub, tIdFlagsTv.SubTreeOpen];
  IdMainMain.SubBlock          := @MainBlock[low ( tMainBlock )];
  IdMainMain.SubLast           := @MainBlock[high( tMainBlock )];

  for b := low( tMainBlock ) to high( tMainBlock ) do
    MainBlock[b].PrevBlock := @IdMainMain
end;

{$ENDREGION }

{$REGION '-------------- Init / Exit ---------------' }

initialization
  {$IFDEF TraceDx} TraceDx.Call( uList, 'initialization' ); {$ENDIF}
  {$IFDEF TestKompatibel} CompErrorList := TStringList.Create; {$ENDIF}
  InitListen;
  NextIdIndex := UnitSystemInit;
//  UnitSystemSubsInit;
  TScanner.Init( ShowFile );      // erst Listen, dann Scanner

finalization
  {$IFDEF TraceDx} TraceDx.Call( uList, 'finalization' ); {$ENDIF}
  DisposeListen;
  {$IFDEF TestKompatibel} CompErrorList.Free; {$ENDIF}

{$ENDREGION }

end.
