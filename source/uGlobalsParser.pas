
unit uGlobalsParser;

{$INCLUDE _CompilerOptionsRef.pas}
{$INCLUDE _CompilerOptions.pas}
{ $UNDEF TraceDx}

interface

uses
  System.Types,
  System.Classes,
  System.Generics.Collections,
  System.SysUtils,
  VCL.ComCtrls,
  VCL.Graphics,
  VCL.StdCtrls;

const
{ Generierungs-Konstanten }
  gMinInfoCount     = 511 * 8 {wg shl 3};
//  gMinInfoCount     = 511 {wg shl 3};     // kleiner Wert zum tmp-Test

{ Funktions-Konstanten, nicht ändern }
  cPas              = 'pas';
  cExtensionPas     = '.' + cPas;
  cStrStart         = '''';
  cSystemRef        = 'System_Ref.pas';

{ Design-Konstanten }
  dPtrSymbol        = '^';
  dArraySymbol      = '[ ]';    // änderbar
  cTrennUse         = '.';      // nicht änderbar wegen Nutzung für verkettete Unitnamen Name1.Name2.UnitX
  dTrennView        = ' . ';    // änderbar
  cHick             = '"';

{ frmFileOptions-Konstanten }
  cPreDefines       = 3;        // Anzahl der IMMER vordefinierten Compiler-Defines
  cDefinesBits      = 32;       // max Anzahl Defines (on/off wird als Bit verwaltet)

  cSymbolOp       = ' (Operator)';
  cSymbolOverload = ' (Overload)';
  cSymbolParentOf = ' (ParentOf)';

type
  {$IFDEF DEBUG}
  tDebugNr    = integer;
  {$ENDIF}
  tMyTrees    = ( tvAll, _tvFil );

  tProcString = reference to procedure( const s: string );

{$REGION '-------------- Ac-Info ---------------' }

const
  cSpalte0    = 0;
  cZeile0     = 0;
  clOrange    = tColor( $0080FF );

type
  tFileIndex  = word;
  tFileIndex_ = integer;   // damit auch -1 enthalten ist
  tLineIndex  = word;
  tIdLen      = word;
  tRowIndex   = word;
  tAcType     = ( ac_Declaration, ac_Read, ac_Write, ac_ReadAdress, ac_Unknown );
  tAcTypeSet  = set of tAcType;

const
  cAcShow      : array[tAcType] of record Text: string; Color: tColor end = (
                 ( Text: 'Declare'; Color: clGreen   ),
                 ( Text: 'Read'   ; Color: clBlue    ),
                 ( Text: 'Write'  ; Color: clRed     ),
                 ( Text: 'ReadAdr'; Color: clFuchsia ),
                 ( Text: 'Unknown'; Color: clOrange  ));

  cAcDummyUsed= [ac_read];

type
  pIdInfo     = ^tIdInfo;
  ppIdInfo    = ^pIdInfo;
  pAcInfo     = ^tAcInfo;
  ppAcInfo    = ^pAcInfo;

  tAcFlags    = ( DontFind,
                  Rekursiv,
                  AcUnused,          //      dieser Ac wurde verworfen, darf nicht referenziert werden
                  PtrOrArr,
                  AcProjectUse );

  tFilePos    = packed record  { 8 Byte }
                  Datei : tFileIndex;    //  0
                  Zeile : tLineIndex;    //  2
                  Spalte: tRowIndex;     //  4
                  Laenge: tIdLen         //  6
                end;

  tAcInfo     = packed record  { 28 Byte }
                  Position   : tFilePos;         //  0
                  IdUse,                         //  8   der Block in dem der Aufruf stattfindet.
                  IdDeclare  : pIdInfo;          // 16   der Id, in dessen AcListe ich stehe (für alle ACs in Verkettung gleich)
                  NextAc     : pAcInfo;          // 20
                  AcPrev     : pAcInfo;          // 24   neu für ufVia: der Ac, über den der vorige Zugriff stattfand:  a.b[1].c
                  AcFlags    : set of tAcFlags;  // 28
                  ZugriffTyp : tAcType;          // 29
                 _FillBytes  : array[0..1] of byte;             // 30
                  MyAcViaNode: tTreeNode;        // 32  Die Zugriffs-Liste zeigt nur Zugriffe an, die über diesen Id kommen
                  {$IFDEF DEBUG}
                  DebugNr    : tDebugNr;         // 36
                  {$ENDIF}
                end;

{$ENDREGION }

{$REGION '-------------- Id-Info ---------------' }

  tIdString   = string;

  tIdType     = ( id_Unbekannt,
                  id_NameSpace,
                  id_Program, id_Unit,
                  id_Label, id_Const, id_EnumConst, id_Type,
                  id_Var, id_Property, id_Proc, id_Func,
                  id_Init, id_Final,     // dummy-procs
                  id_ConstInt, id_ConstHex, id_ConstBin, id_ConstReal, id_ConstChar, id_ConstStr,
                  id_CompilerControl, id_CompilerDefine, id_CompilerAttribute,
                  id_PascalDirective,
                  id_Impl,               // dummy, wird nur zur Visualisierung der Grenze interface-impl eingetragen
                  id_Virtual,
                  id_KeyWord,
                  id_Filename,
                  id_FileLibrary,
                  id_MainBlock );

  tIdFlags    = ( IsPointer,         //  0 P Pointer-Variable. Nicht im SubId "^" gesetzt!
                  IsClassType,       //  1 C ClassType, ClassVar, Method
                  IsClassVirtual,    //  2 virtuelle Methode
                  NoCopy,            //  3 n Subs dieses Id in CopySub NICHT kopieren. EnumConst, DummyParameter aus Proc-Types
                  IdVirtual,         //  4 v der Owner-Id für den Zugriff auf
                                     //       - Non-ScopedEnums ohne Typ-Bezeichner vorweg
                                     //       - Units der Uses-Liste
                  IsWriteParam,      //  5 W Proc-/Func-Parameter
                  IsDummy,           //  6 d dieser Id x ist nur Platzhalter und wird niemals referenziert. Nicht finden in SucheImBlock
                                     //       - property a[x:integer]
                                     //       - type p = procedure(x:integer);
                  IsEnumCopy,        //  7   dieser Type ist per "type t1 = t2" mit "t2 = (t2a,t2b)" entstanden
                  IsParameter,       //  8   Dummy-Parameter für System-Proc. Nicht anzeigen
                  IsResult,          //  9   dies ist der Id für Funktions-"Result"
                  IsRekursiv,        // 10   dieser Id wird 1-n mal rekursiv aufgerufen
                  IsStatic,          // 11   diesen Id in CopySub NICHT in Var kopieren weil Class-Var/-Proc im record
                  IsOverride,        // 12   evtl overload-Flag aus Parent übernehmen, Parent dann bei Suche nicht angucken
                  IsPrivate,         // 13   private-Felder, auch für Unit-non-Interface Deklarationen: nur in eigener Unit sichtbar
                  IsProtected,       // 14   protected-Felder: wie private + in abgeleiteten Klassen sichtbar (immer zusammen mit private gesetzt)
                  IsStrict,          // 15   strict private / protected
                  IsInterface,       // 16   nicht Class sondern interface
                  IsOperator,        // 17   Pascal-Direktive "Operator"
                  IsOverload,        // 18   Pascal-Direktive "Overload"
                  fromSystemLib,     // 19   Id aus System oder Library-Pfad. Kein func-Result, func-Paras nicht in tree anzeigen
                  optionalPara,      // 20   Proc-Parameter mit default-Wert, optional beim Aufruf
                  IdUnused,          // 21   dieser Id wurde verworfen darf nicht referenziert werden
                  IsHelper,          // 22   dieser type ist ein record- oder class-helper
                  IsGenericType,     // 23   das MyType in type MyType<T> = ...
                  IsGenericDummy,    // 24   das T in type MyType<T> = ...
                  IsDefaultArr,      // 25   property default-array
                  IsConstructor,     // 26   Constructor  ( IdType ist id_Function )
                  IsCopySource,      // 27   Src in CopySub -> nicht als acDeclare-Only filtern
                  IsOutParam,        // 28   Parameter "out x", wird bei Suche nach NoReads NICHT angezeigt
                  paraMirror,        // 29   Sonderbehandlung für Funktionen low,high,succ,pred,sqr
                  isClassVar,        // 30   Class-Var or -Method
                  OverloadUnresolved // 31
                  );

  tIdFlags2   = ( IsForward,         //  0
                  IsUnitSystem,      //  1
                  IsAnonym,          //  2
                  IsSelf,            //  3
                  IsMessage,         //  4
                  IdProjectUse,      //  5  eine non-library-Datei greift auf diesen Id zu (direkt als Text oder über MyType-/MyParent-Kette )
                  HasHotKey,         //  6
                  LiteralSpecial,    //  7  char,string: enthält Notation ^G oder #7     int,real: negativ (noch nicht realisiert)
                  InterfaceSection,  //  8  Deklariert in der Interface-Section
                  f9,
                  f10,f11,f12,f13,f14,f15,f16,f17,f18,f19,
                  f20,f21,f22,f23,f24,f25,f26,f27,f28,f29,
                  f30,f31
                  );

  tIdFlagsTv  = ( hasSub,         // Id hat SubBlock <> nil   UND
//                                        (1)nicht nur virtuell
//                                        (2)bei System und Direktiven: Sub mit Acs
//                                        (3) bei TObject: Sub mit Acs
//                                        (4) bei System: nicht endlos-Parameterliste
//                  isResult,IdUnused, IsCopySource     // gehören eigentlich auch hierher
                  SubTreeOpen );     // Dieser Knoten zeigt Childs an im TreeViewFilter


  tIdFlagsDyn = ( IsFiltered,      // wird im tvFilter angezeigt
                  IsFilteredDummy, // ...ist aber nur als Parent dabei
                  WriteOnly,       // nur ac_Write, acReadAdr und acUnknown anzeigen  (also acRead ausblenden)
                  ViaOnly,         // nur falls ac über Via-Id geht anzeigen
                  UnitOnly         // nur falls ac über gewählte Unit geht anzeigen
                  );

  {$IFDEF TraceDx}
  tSignatur   = int64;
  {$ENDIF}
  tTypeNr     = word;

  tLibraryIdx = byte;
  tHash       = longword;
  tHashedStr  = record Str: tIdString; Hash: tHash end;
  tPrio       = 0..5;

  tTypeGroup  = ( coSelf,  {nur zu sich selbst kompatibel}
                  coUnb,   {zu allen Gruppen kompatibel, für id_Unbekannt}
                  coInt, coEnum, coBool, coReal, coStr, coChar, coPtr, coMethod, coClass, coInterf, coSet, coFile, coRecord, coArray, coArrayOf, coTArray );

  tTypeKind   = ( tkTypeAlias, tkRecord, tkArray, tkArrayOf, tkArrayOfConst, tkSet, tkFile, tkPointer, tkProcFunc,
                  tkClass, tkClassOf, tkInterface, tkGeneric, tkMethod );

  tAktDefines = array of set of 0..cDefinesBits-1;      // jeweils 32 Bits für Defines on/off entsprechend Index in DefinedSymbols

  tIdInfo     = packed record  { 88 Byte }
                  Name       : tIdString;        //  0
                  Typ        : tIdType;          //  4
                  AcSet      : tAcTypeSet;       //  5
                  TypeNr     : tTypeNr;          //  6
                  MyType     : pIdInfo;          //  8     wird für VirtualIds als Zeiger auf echten Typ mißbraucht
                  SubBlock,                      // 12
                  SubLast    : pIdInfo;          // 16
                  NextId     : pIdInfo;          // 20
                  IdFlags    : set of tIdFlags;  // 24
                  IdFlags2   : set of tIdFlags2; //
                  PrevBlock  : pIdInfo;          // 28   --> MyOwner
                  AcList,                        // 32
                  LastAc     : pAcInfo;          // 36
                  MyParent   : pIdInfo;          // 40
                  Hash       : tHash;            // 44
                  OpenCount  : array[tMyTrees] of// 48   Anzahl gerade SICHTBARE Subs (OHNE mich selbst)
                                 integer;        // 52   ebenso für tvFilter
                  lstBox     : packed record
                                 LastTop : integer;        // 56  lstBox
                                 SelectNr: integer;        // 60  lstBox
                                 SelectAc: pAcInfo;        // 64  lstBox
                               end;
                  {$IFDEF DEBUG}
                  DebugNr    : tDebugNr;          // 68
                  {$ENDIF}
                  IdFlagsTv  : array[tMyTrees] of // 72
                                 set of tIdFlagsTv;// 73
                  IdFlagsDyn : set of tIdFlagsDyn; //  74
                  TypeGroup  : tTypeGroup;       //  75        Kompatibilitätsgruppe dieser Const / Type / Var / Func
                  {$IFDEF TraceDx}
                  Signatur   : tSignatur;        //  76
                  {$ENDIF}
                  NextHelper : pIdInfo;          //  84  id_Unit: Liste der von dieser Unit exportierter Helpers
                  MyIdViaNode: tTreeNode;        //  88  Nur während Aufbau der Via-Liste: Dieser Id kommt bereits in diesem TreeNode vor
//                  MyViaIdx : integer;          //  92  AbsoluteIndex des gewählten Node. Hierüber kann er nach AktpId-Wechsel und Tree-Neuaufbau wieder gesetzt werden
                  MyUnitOnly : integer;          //  92  Index in der ComboBoxUnitOnly des gewählten Unit
                  TypeKind   : tTypeKind;        //  96       array, class, ...
                  OpPrio     : tPrio;            //  97  falls Keyword ein Operator ist: dessen Expression-Priorität  /  für Compiler-Schalter: Default-on/off
             _FillWord   : word;                 //  98
                  {Ende}                         // 100
                end;

const
  cConst       = 'CONST';
  cVar         = 'VAR';
  cNoHash      = 0;

  clConst      = clNavy;
  clEnum       = clTeal + $400000;
  cIdShow      : array[tIdType] of record Text: string; Color: tColor end = (
                 ( Text: 'Undeclared'        ; Color: clBlack   ),
                 ( Text: 'NAMESPACE'         ; Color: clBlack   ),
                 ( Text: 'PROGRAM'           ; Color: clMaroon  ),
                 ( Text: 'UNIT'              ; Color: clMaroon  ),
                 ( Text: 'LABEL'             ; Color: clOrange  ),
                 ( Text:  cConst             ; Color: clConst   ),
                 ( Text: 'ENUM'              ; Color: clEnum    ),
                 ( Text: 'TYPE'              ; Color: clGreen   ),
                 ( Text:  cVAR               ; Color: clBlue    ),
                 ( Text: 'PROPERTY'          ; Color: clPurple  ),
                 ( Text: 'PROCEDURE'         ; Color: clRed     ),
                 ( Text: 'FUNCTION'          ; Color: clFuchsia ),
                 ( Text: 'INITIALIZATION'    ; Color: clRed     ),
                 ( Text: 'FINALIZATION'      ; Color: clRed     ),
                 ( Text: 'Literal(int)'      ; Color: clConst   ),
                 ( Text: 'Literal(hex)'      ; Color: clConst   ),
                 ( Text: 'Literal(bin)'      ; Color: clConst   ),
                 ( Text: 'Literal(real)'     ; Color: clConst   ),
                 ( Text: 'Literal(char)'     ; Color: clConst   ),
                 ( Text: 'Literal(string)'   ; Color: clConst   ),
                 ( Text: 'Compiler-Directive'; Color: clBlue    ),
                 ( Text: 'Compiler-Define'   ; Color: clBlue    ),
                 ( Text: 'Compiler-Attribute'; Color: clBlue    ),
                 ( Text: 'Pascal-Directive'  ; Color: clBlue    ),
                 ( Text: 'IMPLEMENTATION'    ; Color: clBlack   ),
                 ( Text: 'VIRTUAL'           ; Color: clGray    ),
                 ( Text: 'Keyword'           ; Color: clBlue    ),
                 ( Text: 'Filename'          ; Color: clBlack   ),
                 ( Text: 'Library-Directory' ; Color: clBlack   ),
                 ( Text: 'Main-Block'        ; Color: clBlack   ));

  cTypeGroup   : array[tTypeGroup] of record Kurz: char; Text: string end = (
                 ( Kurz: ' '; Text: ''               ),
                 ( Kurz: ' '; Text: 'No Declaration' ),
                 ( Kurz: ' '; Text: 'Integer'        ),
                 ( Kurz: ' '; Text: 'Enum'           ),
                 ( Kurz: ' '; Text: 'Bool'           ),
                 ( Kurz: ' '; Text: 'Real'           ),
                 ( Kurz: ' '; Text: 'String'         ),
                 ( Kurz: ' '; Text: 'Char'           ),
                 ( Kurz: ' '; Text: 'Pointer'        ),
                 ( Kurz: ' '; Text: 'Proc/Func'      ),
                 ( Kurz: ' '; Text: 'Class'          ),
                 ( Kurz: ' '; Text: 'Interface'      ),
                 ( Kurz: ' '; Text: 'Set'            ),
                 ( Kurz: ' '; Text: 'File'           ),
                 ( Kurz: ' '; Text: 'Record'         ),
                 ( Kurz: ' '; Text: 'Array[]'        ),
                 ( Kurz: ' '; Text: 'ArrayOf'        ),
                 ( Kurz: ' '; Text: 'TArray'         ));

  cTypeKind   : array[tTypeKind] of record Kurz: char; Text: string end = (
                 ( Kurz: ' '; Text: 'Alias'        ),
                 ( Kurz: ' '; Text: 'Record'       ),
                 ( Kurz: ' '; Text: 'Array'        ),
                 ( Kurz: ' '; Text: 'ArrayOf'      ),
                 ( Kurz: ' '; Text: 'ArrayOfConst' ),
                 ( Kurz: ' '; Text: 'Set'          ),
                 ( Kurz: ' '; Text: 'File'         ),
                 ( Kurz: ' '; Text: 'Pointer'      ),
                 ( Kurz: ' '; Text: 'Proc/Func'    ),
                 ( Kurz: ' '; Text: 'Class'        ),
                 ( Kurz: ' '; Text: 'ClassOf'      ),
                 ( Kurz: ' '; Text: 'Interface'    ),
                 ( Kurz: ' '; Text: 'Generic'      ),
                 ( Kurz: ' '; Text: 'Method'       ) );

type
  tAcSeqIndex = integer;     // für AcSeq

  pIdPtrInfo  = ^tIdPtrInfo;
  tIdPtrInfo  = packed record
                  Block    : pIdInfo;      // zeigt auf den Owner einer relevanten IdListe (with, uses)
                  AcStart,
                  AcEnde   : tAcSeqIndex;
                  NextIdPtr: pIdPtrInfo
                end;

{$ENDREGION }

{$REGION '-------------- Main Block ---------------' }

  tMainBlock           = ( mbBlock0, mbUnDeclaredUnScoped, mbConstInt, mbConstHex, mbConstBin, mbConstReal, mbConstChars, mbConstStrings, {mbGUID,} mbPascalDirs, mbCompilerDirs, mbDefines, mbAttributes, mbKeyWords, mbFilenames );

var
  MainBlock           : array[tMainBlock] of tIdInfo = (
                          ( Name: '<Unit>';                         Typ: id_Unit                                               ),
//                          ( Name: '<Unit (Library)>';               Typ: id_Unit                                               ),
//                          ( Name: '<Unit (SearchPath)>';            Typ: id_Unit                                               ),
//                          ( Name: '<Unit (not found)>';             Typ: id_Unit                                               ),
                          ( Name: '<unresolved (not qualified)>'  ; Typ: id_Unit;             AcSet: [ac_Declaration, ac_Read] ),
                          ( Name: '<int>';                          Typ: id_ConstInt                                           ),
                          ( Name: '<hex>';                          Typ: id_ConstHex                                           ),
                          ( Name: '<bin>';                          Typ: id_ConstBin                                           ),
                          ( Name: '<real>';                         Typ: id_ConstReal                                          ),
                          ( Name: '<char>';                         Typ: id_ConstChar                                          ),
                          ( Name: '<string>';                       Typ: id_ConstStr                                           ),
//                          ( Name: '<GUID>';                         Typ: id_ConstStr                                           ),
                          ( Name: '<Pascal-Directives>';            Typ: id_PascalDirective                                    ),
                          ( Name: '<Compiler-Directives>';          Typ: id_CompilerControl                                    ),
                          ( Name: '<Compiler-Defines>';             Typ: id_CompilerDefine                                     ),
                          ( Name: '<Compiler-Attributes>';          Typ: id_CompilerAttribute                                  ),
                          ( Name: '<KeyWords>';                     Typ: id_KeyWord                                            ),
                          ( Name: '<Filenames>';                    Typ: id_Filename                                           )
                          );
  UnitSystem          : tIdInfo =
                          ( Name: 'System';                         Typ: id_Unit );
  IdMainMain          : tIdInfo;   // in tMainBlock aufnehmen, z.B. als letzten

{$ENDREGION }

{$REGION '-------------- Keyword ---------------' }

type
  tKeyWord    = (kw_Literal,   { alle Konstanten  }
                 kw_Identifier,
                {a} kw_AS, kw_AND, kw_ASM, kw_ARRAY,
                {b} kw_BEGIN,
                {c} kw_CASE, kw_CASE_variant, kw_CLASS, kw_CONST, kw_CONSTRUCTOR,
                {d} kw_DO, kw_DIV, kw_DOWNTO, kw_DESTRUCTOR, kw_DISPINTERFACE,
                {e} kw_END, kw_ELSE, kw_ELSE_case, kw_EXCEPT, kw_EXPORTS,
                {f} kw_FOR, kw_FILE, kw_FINALLY, kw_FUNCTION, kw_FINALIZATION,
                {g} kw_GOTO,
                {h}
                {i} kw_IN, kw_IN_for, kw_IF, kw_IS, kw_INLINE, kw_INTERFACE, kw_INHERITED, kw_IMPLEMENTATION, kw_INITIALIZATION,
                {j}
                {k}
                {l} kw_LABEL, kw_LIBRARY,
                {m} kw_MOD,
                {n} kw_NOT, kw_NIL,
                {o} kw_OF, kw_OR, kw_OBJECT,
                {p} kw_PACKED, kw_PROGRAM, kw_PROPERTY, kw_PROCEDURE,
                {r} kw_RAISE, kw_RECORD, kw_REPEAT, kw_RESOURCESTRING,
                {s} kw_SHL, kw_SHR, kw_SET,
                {t} kw_TO, kw_TRY, kw_THEN, kw_TYPE, kw_THREADVAR,
                {u} kw_UNIT, kw_USES, kw_UNTIL,
                {v} kw_VAR,
                {w} kw_WITH, kw_WHILE,
                {x} kw_XOR,

                 { Operatoren aus zwei Zeichen, kw_Assignment muß letztes bleiben ! }
                 kw_KleinerGleich, kw_GroesserGleich, kw_Ungleich,
                 kw_PunktPunkt, kw_DoppelpunktGleich,
                 kw_KlammerAufStern, kw_SternKlammerZu,

                 { Operatoren aus einem Zeichen }
                 kw_Doppelpunkt, kw_Plus, kw_Minus, kw_Mal, kw_Durch, kw_Punkt,
                 kw_Semikolon, kw_Pointer, kw_Klammeraffe, kw_Ampersand,
                 kw_KlammerAuf, kw_KlammerZu, kw_Gleich, kw_Groesser,
                 kw_Kleiner, kw_Kleiner_GenTypeDef, kw_Kleiner_GenTypeUse, kw_Kleiner_GenMethodDef, kw_Kleiner_GenMethodUse,
                 kw_EckigeKlammerAuf, kw_EckigeKlammerAuf_GUID, kw_EckigeKlammerAuf_Attribut, kw_EckigeKlammerZu, kw_Komma,
                 kw_GeschweifteKlammerAuf, kw_GeschweifteKlammerZu
                );

const
  kw_FirstKeyWordStr   = kw_AS;
  kw_LastKeyWordStr    = kw_XOR;      // ab hier Symbole
  kw_FirstOp1          = kw_Doppelpunkt;
  kw_MonadischPlus     = kw_Plus;
  kw_MonadischMinus    = kw_Minus;
  //...

  cNoOp       = 0;    // dieses Keyword ist kein Operator -> Expression-Parse abbrechen
  cOpPrioKlGl = 2;    // "<" und "=" werden kurzfristig mal cNoOp gesetzt und wieder restauriert
  cOpPrioDPkt = 1;    // ":" wird für write() writeln() str() kurzfristig mal als Op gesetzt
  cOpPrioIN   = 2;

var
  KeyWordListe: array [tKeyWord] of tIdInfo = (
                   ( Name: '<Literal>';        Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: '<Identifier>';     Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'as';               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'and';              Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 4 ),
                   ( Name: 'asm';              Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'array';            Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'begin';            Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'case';             Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'case {variant}';   Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'class';            Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'const';            Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'constructor';      Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'do';               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'div';              Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 4 ),
                   ( Name: 'downto';           Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'destructor';       Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'dispinterface';    Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'end';              Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'else';             Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'else {case}';      Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'except';           Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'exports';          Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'for';              Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'file';             Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'finally';          Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'function';         Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'finalization';     Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'goto';             Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'in';               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: cOpPrioIN ),
                   ( Name: 'in {for}';         Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'if';               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'is';               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 2 ),
                   ( Name: 'inline';           Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'interface';        Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'inherited';        Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'implementation';   Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'initialization';   Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'label';            Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'library';          Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'mod';              Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 4 ),
                   ( Name: 'not';              Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 5 ),
                   ( Name: 'nil';              Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'of';               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'or';               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 3 ),
                   ( Name: 'object';           Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'packed';           Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'program';          Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'property';         Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'procedure';        Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'raise';            Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'record';           Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'repeat';           Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'resourcestring';   Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'shl';              Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 4 ),
                   ( Name: 'shr';              Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 4 ),
                   ( Name: 'set';              Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'to';               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'try';              Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'then';             Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'type';             Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'threadvar';        Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'unit';             Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'uses';             Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'until';            Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'var';              Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'with';             Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'while';            Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: 'xor';              Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 3 ),

                   ( Name: '<=';               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: cOpPrioKlGl ),
                   ( Name: '>=';               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 2 ),
                   ( Name: '<>';               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 2 ),
                   ( Name: '..';               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 1 ),
                   ( Name: ':=';               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: '(*';               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: '*)';               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),

                   ( Name: ':' ;               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: '+' ;               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 3 ),
                   ( Name: '-' ;               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 3 ),
                   ( Name: '*' ;               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 4 ),
                   ( Name: '/' ;               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 4 ),
                   ( Name: '.' ;               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: ';' ;               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: '^' ;               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: '@' ;               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 5 ),
                   ( Name: '&' ;               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: '(' ;               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: ')' ;               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: '=' ;               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 2 ),
                   ( Name: '>' ;               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 2 ),
                   ( Name: '<' ;               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 2 ),
                   ( Name: '< <Type def>';     Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: '< <Type use>';     Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: '< <Method def>';   Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: '< <Method use>';   Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: '[' ;               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: '[ {GUID}';         Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: '[ {Attribut}';     Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: ']' ;               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: ',' ;               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: '{' ;               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 ),
                   ( Name: '}' ;               Typ: id_KeyWord; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbKeyWords]; Hash: 0; OpPrio: 0 )
                  );

const
  cKeyWordLenStart: array['a'..succ('z')] of tKeyWord = (
                      kw_AS, kw_BEGIN, kw_CASE, kw_DO, kw_END, kw_FOR, kw_GOTO, kw_IN, kw_IN, kw_LABEL,
                      kw_LABEL, kw_LABEL, kw_MOD, kw_NOT, kw_OF, kw_PACKED, kw_RAISE, kw_RAISE, kw_SHL,
                      kw_TO, kw_UNIT, kw_VAR, kw_WITH, kw_XOR, succ(kw_XOR), succ(kw_XOR), succ(kw_XOR) );

(*Operatoren:
  5:  @, not
  4:  * / div mod and shl shr {as}
  3:  + - or xor
  2:  = <> < > <= >= in is
  1:  ..   *)

{$ENDREGION }

{$REGION '-------------- Pascal-Direktive ---------------' }

type
  tPascalDirektive     = ( pd_NIL,
                           pd_ABSOLUTE, pd_ABSTRACT, pd_ALIGN, pd_ASSEMBLER, pd_AT, pd_AUTOMATED,

                           pd_CDECL, pd_CONTAINS,
                           pd_DEFAULT, pd_DELAYED, pd_DEPENDENCY, pd_DEPRECATED, pd_DISPID, pd_DYNAMIC,
                           pd_EXPERIMENTAL, pd_EXPORT, pd_EXTERNAL,
                           pd_FAR, pd_FINAL, pd_FORWARD,

                           pd_HELPER,
                           pd_IMPLEMENTS, pd_INDEX, pd_INTERRUPT{veraltet},

                           pd_LIBRARY, pd_LOCAL,
                           pd_MESSAGE,
                           pd_NAME, pd_NEAR, pd_NODEFAULT,
                           pd_ON, pd_OPERATOR, pd_OUT, pd_OVERLOAD, pd_OVERRIDE,
                           pd_PACKAGE, pd_PASCAL, pd_PLATFORM, pd_PRIVATE, pd_PROTECTED, pd_PUBLIC, pd_PUBLISHED,

                           pd_READ, pd_READONLY, pd_REFERENCE, pd_REGISTER, pd_REINTRODUCE, pd_REQUIRES, pd_RESIDENT,
                           pd_SAFECALL, pd_SEALED, pd_STATIC, pd_STDCALL, pd_STORED, pd_STRICT,

                           pd_UNSAFE,
                           pd_VARARGS, pd_VIRTUAL,
                           pd_WINAPI, pd_WRITE, pd_WRITEONLY
                         );

var
  PascalDirektiveListe: array [tPascalDirektive] of tIdInfo = (
                   ( Name: '';             ),
                   ( Name: 'absolute';     Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'abstract';     Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'align';        Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'assembler';    Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'at';           Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'automated';    Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'cdecl';        Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'contains';     Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'default';      Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'delayed';      Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'dependency';   Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'deprecated';   Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'dispid';       Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'dynamic';      Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'experimental'; Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'export';       Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'external';     Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'far';          Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'final';        Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'forward';      Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'helper';       Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'implements';   Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'index';        Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'interrupt';    Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'library';      Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'local';        Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'message';      Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'name';         Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'near';         Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'nodefault';    Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'on';           Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'operator';     Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'out';          Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'overload';     Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'override';     Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'package';      Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'pascal';       Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'platform';     Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'private';      Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'protected';    Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'public';       Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'published';    Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'read';         Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'readonly';     Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'reference';    Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'register';     Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'reintroduce';  Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'requires';     Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'resident';     Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'safecall';     Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'sealed';       Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'static';       Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'stdcall';      Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'stored';       Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'strict';       Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'unsafe';       Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'varargs';      Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'virtual';      Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'winapi';       Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'write';        Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] ),
                   ( Name: 'writeonly';    Typ: id_PascalDirective; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbPascalDirs] )
                 );

type
  tPascalDirektiveSet  = set of tPascalDirektive;

  tPascalDirektiveSets = ( ds_PROC, ds_Hint, ds_CLASS, ds_PROPERTY, ds_ON, ds_NAME, ds_ABSTRACT );

const
  cPascalDirektiveSets: array[tPascalDirektiveSets] of tPascalDirektiveSet = (
  {ds_PROC}              [pd_NEAR, pd_FAR, pd_EXPORT, pd_LOCAL, pd_RESIDENT,     // gibt's nicht mehr
                          pd_ASSEMBLER, pd_OVERRIDE,
                          pd_REGISTER, pd_PASCAL, pd_CDECL, pd_VARARGS, pd_SAFECALL, pd_STDCALL, pd_WINAPI,
                          pd_DEPRECATED, pd_LIBRARY, pd_PLATFORM,
                          pd_STATIC, pd_UNSAFE, pd_EXTERNAL, pd_FORWARD,
                          pd_ABSTRACT, pd_REINTRODUCE, pd_DYNAMIC, pd_VIRTUAL, pd_OVERRIDE, pd_FINAL,
                          pd_OVERLOAD, pd_MESSAGE, pd_INTERRUPT, pd_DISPID],

  {ds_Hint}              [pd_platform, pd_deprecated, pd_library, pd_ALIGN{eigentlich kein Hint, undokumentiert. Aus System.pas}],

  {ds_CLASS}             [pd_PRIVATE, pd_PROTECTED, pd_PUBLIC, pd_PUBLISHED, pd_STRICT, pd_AUTOMATED],

  {ds_PROPERTY}          [pd_INDEX, pd_READ, pd_WRITE,
                          pd_STORED, pd_DEFAULT, pd_NODEFAULT,
                          pd_IMPLEMENTS, pd_DISPID, pd_READONLY, pd_WRITEONLY],

  {ds_ON}                [pd_ON, pd_AT],

  {ds_NAME}              [pd_INDEX, pd_NAME, pd_RESIDENT],

  {ds_ABSTRACT}          [pd_ABSTRACT, pd_SEALED] );

{$ENDREGION }

{$REGION '-------------- Compiler-Direktive ---------------' }

type
  tCompilerDirektiven  = ( cd_Unbekannt,
                           cd_Align, cd_AppType, cd_Assertions, cd_AsmMode {FreePascal},
                           cd_BoolEval,
                           cd_CodeAlign, cd_CodeSegmentAttribute,
                           cd_Define, cd_DebugInfo, cd_DenyPackageUnit, cd_Description, cd_DesignOnly, cd_DefinitionInfo,
                           cd_Else, cd_EndIf, cd_ElseIf, cd_Extension, cd_ExtendedSyntax, cd_ExtendedCompatibility, cd_ExternalSym,
                              cd_ExcessPrecision, cd_EndRegion, cd_EmulateCoProcessor,
                           cd_FiniteFloat, cd_Far,
                           cd_HighcharUnicode, cd_Hints, cd_HppEmit,
                           cd_IfDef, cd_IfNDef, cd_IfOpt, cd_If, cd_IfEnd,
                              cd_ImageBase, cd_ImplicitBuild, cd_ImportedData, cd_Include, cd_IoChecks, cd_Inline,
                           cd_DirectiveK,
                           cd_LibPrefix, cd_LibSuffix, cd_LibVersion, cd_LegacyIfEnd, cd_Link, cd_LocalSymbols, cd_LongStrings,
                           cd_MinStackSize, cd_MaxStackSize, cd_Message, cd_MethodInfo, cd_MinEnumSize,
                              cd_Mode{FreePascal},
                           cd_CoProcessor, cd_NoDefine, cd_NoInclude,
                           cd_ObjExportAll, cd_ObjTypename, cd_OldTypeLayout, cd_OpenStrings, cd_Optimization, cd_OverflowChecks,
                           cd_PointerMath,
                           cd_RangeChecks, cd_RealCompatibility, cd_Region, cd_Resource, cd_Rtti, cd_RunOnly, cd_ReferenceInfo, cd_ResourceReserve,
                           cd_SafeDivide, cd_ScopedEnums, cd_StackFrames, cd_StrongLinkTypes, cd_SoPrefix{wie libprefix},
                              cd_SetPeFlags, cd_SetPeOptFlags, cd_SetPeOsVersion, cd_SetPeSubSysVersion, cd_SetPeUserVersion,
                              cd_StackChecking, cd_StringChecks, cd_SmartCallbacks,
                           cd_TypedAddress, cd_TypeInfo, cd_TextBlock,
                           cd_Undef,
                           cd_VarStringChecks, cd_VarPropSetter,
                           cd_Warn, cd_Warnings, cd_WeakPackageUnit, cd_WeakLinkRtti, cd_WriteableConst,
                           cd_ZeroBasedStrings,
                           cd_Defined, cd_Declared, cd_And, cd_Or, cd_Not, cd_True, cd_False
                         );

const
  { Dies sind die Standard-Werte (durch Ctrol-O-O eingefügt). $K hat keine Langtext-Entsprechung (veraltet).
    $A8,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N-,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1    }

  { Umsetzung 1-Zeichen-Optionen auf Langtext-Optionen}
  cCompilerDirektivenOpt: array['A'..'Z'] of tCompilerDirektiven
                            = ({A} cd_Align{!},       cd_BoolEval,        cd_Assertions,  cd_DebugInfo,      cd_EmulateCoProcessor,
                               {F} cd_Far,            cd_ImportedData,    cd_LongStrings, cd_IoChecks,       cd_WriteableConst,
                               {K} cd_SmartCallbacks, cd_LocalSymbols,    cd_TypeInfo{!}, cd_CoProcessor,    cd_Optimization,
                               {P} cd_OpenStrings,    cd_OverflowChecks,  cd_RangeChecks, cd_StackChecking,  cd_TypedAddress,
                               {U} cd_SafeDivide ,    cd_VarStringChecks, cd_StackFrames, cd_ExtendedSyntax, cd_DefinitionInfo, {!Y und YD auf ReferenceInfo und DefinitionInfo abbilden}
                               {Z} cd_MinEnumSize );

  { falls die Direktive KEINE Option ist gilt diese Umsetzung: }
  cCompilerDirektivenTxt: array['A'..'Z'] of tCompilerDirektiven
                            = ({A} cd_Unbekannt,   cd_Unbekannt,       cd_CodeSegmentAttribute, cd_Description,    cd_Extension,
                               {F} cd_Unbekannt,   cd_Unbekannt,       cd_Unbekannt,            cd_Include,        cd_Unbekannt,
                               {K} cd_Unbekannt,   cd_Link,            cd_MinStacksize,         cd_Unbekannt,      cd_Unbekannt,
                               {P} cd_Unbekannt,   cd_Unbekannt,       cd_Resource,             cd_Unbekannt,      cd_Unbekannt,
                               {U} cd_Unbekannt,   cd_Unbekannt,       cd_StackFrames,          cd_Unbekannt,      cd_Unbekannt,
                               {Z} cd_Unbekannt );

var
  ControlsListe: array [tCompilerDirektiven] of tIdInfo = (                                                        { Opt=2 Lokal=1}{ Lokal/Global,Default,Buchstabe}
    ( Name: '<no Directive>';       Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ),
    ( Name: 'ALIGN';                Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L+ A A<n>
    ( Name: 'APPTYPE';              Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ), // G
    ( Name: 'ASSERTIONS';           Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L+ C
    ( Name: 'ASMMODE';              Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L-
    ( Name: 'BOOLEVAL';             Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L- B
    ( Name: 'CODEALIGN';            Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   1 ), // L
    { nicht in Doku, aber VCL.Controls.   Siehe https://stackoverflow.com/questions/8498569/what-is-the-meaning-of-c-preload-directive }
    ( Name: 'CODESEGMENTATTRIBUTE'; Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   1 ), // L C <Attr>
    ( Name: 'DEFINE';               Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ),
    ( Name: 'DEBUGINFO';            Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+0 ), // G+ D
    ( Name: 'DENYPACKAGEUNIT';      Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L-
    ( Name: 'DESCRIPTION';          Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ), // G
    ( Name: 'DESIGNONLY';           Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L-
    ( Name: 'DEFINITIONINFO';       Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+0 ), // G+ Y YD Y+-
    ( Name: 'ELSE';                 Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ),
    ( Name: 'ENDIF';                Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ),
    ( Name: 'ELSEIF';               Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ),
    ( Name: 'EXTENSION';            Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ), // G  E
    ( Name: 'EXTENDEDSYNTAX';       Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+0 ), // G+ X
    ( Name: 'EXTENDEDCOMPATIBILITY';Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L-
    ( Name: 'EXTERNALSYM';          Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ),
    ( Name: 'EXCESSPRECISION';      Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L+
    ( Name: 'ENDREGION';            Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ),
    { nicht (mehr) in Doku weil veraltet: }
    ( Name: 'EMULATE COPROCESSOR';  Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // G- E
    { nicht in Doku, aber c:\Users\Public\Documents\Embarcadero\Studio\20.0\Samples\Object Pascal\RTL\ComplexNumbers\ Win32OperatorOverload.dpr: }
    ( Name: 'FINITEFLOAT';          Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L-
    { nicht (mehr) in Doku weil veraltet: }
    ( Name: 'FAR';                  Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L- F
    ( Name: 'HIGHCHARUNICODE';      Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L-
    ( Name: 'HINTS';                Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L+
    ( Name: 'HPPEMIT';              Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ),
    ( Name: 'IFDEF';                Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ),
    ( Name: 'IFNDEF';               Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ),
    ( Name: 'IFOPT';                Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ),
    ( Name: 'IF';                   Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ),
    ( Name: 'IFEND';                Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ),
    ( Name: 'IMAGEBASE';            Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ), // G
    ( Name: 'IMPLICITBUILD';        Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+0 ), // G+
    ( Name: 'IMPORTEDDATA';         Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L+ G
    ( Name: 'INCLUDE';              Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ), //    I<Datei>
    ( Name: 'IOCHECKS';             Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L+ I
    { nicht in Doku, aber d:\Prog\_Wissen\Buch\Cantu - ObjectPascal\ObjectPascalHandbook-master\04\InliningTest\ InliningTest.dpr: }
    ( Name: 'INLINE';               Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L+
    { nicht (mehr) in Doku weil veraltet: }
    ( Name: '_DIRECTIVE K';         Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // G- K
    ( Name: 'LIBPREFIX';            Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ), // G
    ( Name: 'LIBSUFFIX';            Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ), // G
    ( Name: 'LIBVERSION';           Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ), // G
    ( Name: 'LEGACYIFEND';          Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ),
    ( Name: 'LINK';                 Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   1 ), // L  L<Datei>
    ( Name: 'LOCALSYMBOLS';         Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+0 ), // G+ L
    ( Name: 'LONGSTRINGS';          Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L+ H
    ( Name: 'MINSTACKSIZE';         Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ), // G  M<min,max>
    ( Name: 'MAXSTACKSIZE';         Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ), // G  M<min,max>
    ( Name: 'MESSAGE';              Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ),
    ( Name: 'METHODINFO';           Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L-
    ( Name: 'MINENUMSIZE';          Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L- Z<n> Z+-
    ( Name: 'MODE';                 Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L-
    { nicht (mehr) in Doku weil veraltet, aber in System\Math.pas: }
    ( Name: 'NUMERIC COPROCESSOR';  Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // G- N
    ( Name: 'NODEFINE';             Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ),
    ( Name: 'NOINCLUDE';            Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ),
    ( Name: 'OBJEXPORTALL';         Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+0 ), // G-
    ( Name: 'OBJTYPENAME';          Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ), // G
    ( Name: 'OLDTYPELAYOUT';        Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L-
    ( Name: 'OPENSTRINGS';          Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L+ P
    ( Name: 'OPTIMIZATION';         Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L+ O
    ( Name: 'OVERFLOWCHECKS';       Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L- Q
    ( Name: 'POINTERMATH';          Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L-
    ( Name: 'RANGECHECKS';          Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L- R
    ( Name: 'REALCOMPATIBILITY';    Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L-
    ( Name: 'REGION';               Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ),
    ( Name: 'RESOURCE';             Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ), //    R<Datei (ggf 2)>
    ( Name: 'RTTI';                 Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   1 ), // L  INHERIT/EXPLICIT [Sichtbarkeit]
    ( Name: 'RUNONLY';              Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L-
    ( Name: 'REFERENCEINFO';        Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ), // G  ->DEFINITIONINFO
    ( Name: 'RESOURCERESERVE';      Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ), // G
    ( Name: 'SAFEDIVIDE';           Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L- U
    ( Name: 'SCOPEDENUMS';          Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L-
    ( Name: 'STACKFRAMES';          Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L- W
    ( Name: 'STRONGLINKTYPES';      Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+0 ), // G-
    ( Name: 'SOPREFIX';             Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ), // G  ->LIBPREFIX
    ( Name: 'SETPEFLAGS';           Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   1 ), // L
    ( Name: 'SETPEOPTFLAGS';        Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   1 ), // L
    ( Name: 'SETPEOSVERSION';       Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   1 ), // L
    ( Name: 'SETPESUBSYSVERSION';   Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   1 ), // L
    ( Name: 'SETPEUSERVERSION';     Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   1 ), // L
    { nicht (mehr) in Doku weil veraltet, aber in System\Math.pas: }
    ( Name: 'STACKCHECKING';        Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // G- S
    ( Name: 'STRINGCHECKS';         Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   1 ), // veraltet
    ( Name: 'SMARTCALLBACKS';       Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   1 ), // G+ K veraltet
    ( Name: 'TYPEDADDRESS';         Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+0 ), // G- T
    ( Name: 'TYPEINFO';             Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L- M
    ( Name: 'TEXTBLOCK';            Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L-
    ( Name: 'UNDEF';                Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ),
    ( Name: 'VARSTRINGCHECKS';      Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L+ V
    { nicht in Doku, aber d:\Prog\_Wissen\Buch\Cantu - ObjectPascal\ObjectPascalHandbook-master\10\VarProp\ VarProp.dpr: }
    ( Name: 'VARPROPSETTER';        Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L-
    ( Name: 'WARN';                 Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ),
    ( Name: 'WARNINGS';             Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L+
    ( Name: 'WEAKPACKAGEUNIT';      Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L-
    ( Name: 'WEAKLINKRTTI';         Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L-
    ( Name: 'WRITEABLECONST';       Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L- J
    ( Name: 'ZEROBASEDSTRINGS';     Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio: 2+1 ), // L- je nach Compiler!
// konstanter Ausdruck nach nach $IF:
    ( Name: 'DEFINED';              Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ),
    ( Name: 'DECLARED';             Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ),
    ( Name: 'AND';                  Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ),
    ( Name: 'OR';                   Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ),
    ( Name: 'NOT';                  Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ),
    ( Name: 'TRUE';                 Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 ),
    ( Name: 'FALSE';                Typ: id_CompilerControl; AcSet: [ac_Read]; PrevBlock: @MainBlock[mbCompilerDirs]; OpPrio:   0 )
   );

type
  tCompilerOptions = packed array[low( tCompilerDirektiven ) .. cd_ZeroBasedStrings] of boolean;

const
  cIfOptGlobal  : tCompilerOptions =                 // Werte siehe Kommentar in ControlsListe
                 ( { } false,
                   {A} true, false, true, false,
                   {B} false,
                   {C} false, false,
                   {D} false, true,  false, false, false, true,
                   {E} false, false, false, false, true,  false, false, true, false, false,
                   {F} false, false,
                   {H} false, true,  false,
                   {I} false, false, false, false, false, false, true,  true, false, true, true,
                   {K} false,
                   {L} false, true , true , false, false, true,  true,
                   {M} false, false, false, false, false, false,
                   {N} false, false, false,
                   {O} false, false, false, true,  true,  false,
                   {P} false,
                   {R} false, false, false, false, false, false, false, false,
                   {S} false, false, false, false, false, false, false, false, false, false, false, false, true,
                   {T} false, false, false,
                   {U} false,
                   {V} true,  false,
                   {W} false, true,  false, false, false,
                   {Z} false );

var
  IfOptGlobal  : tCompilerOptions;

{$ENDREGION }

{$REGION '-------------- Compiler-Attribut ---------------' }

type
  tCompilerAttribute   = ( caRef, caWeak, caUnsafe, caVolatile );

const
  cCompAttr    : array[tCompilerAttribute] of string = ( 'ref', 'weak', 'unsafe', 'volatile' );

{$ENDREGION }

{$REGION '-------------- File-Info ---------------' }

const
  cDefinesFile = '//Pseudo-IniFile';   // Pseudo-Datei für Compiler-Defines aus ini

type
  tIdPosInfo  = packed record   { 12 Byte }
                  Str : tIdString;
                  Pos : tFilePos
                end;

  tFileString = string;

  tFileFlags  = ( LibraryPath,     // Datei wurde über Library-Path gefunden
                  InterfaceRead,   // das Interface ist bereits eingelesen
                  isResourceFile,  // $R
                  hasFormular,     // diese Unit hat auch ein Formular
                  isFormular,      // dies ist das Formular zu einer Unit
                  hasTab,          // TAb-Character in Datei, wird zZ gesetzt aber nicht ausgewertet
                  isNotLatest,     // die Datei wurde geändert und noch nicht neu geparst -> Vorsicht insbesondere bei DragDrop
                  Changed          // Datei wurde geändert, z.B. wegen Flag "ExtraEndIf"
                );

  tHotKeys    = '0'..'Z';

  pFileInfo   = ^tFileInfo;
  tFileInfo   = packed record    { 72 Byte }
                  FileName   : tFileString;         //  0
                  FileHash   : tHash;
                  FileDatum  : TDate;               //  4

                  ImplStart,                        // 12
                  ImplNext   : pIdInfo;             // 16   Falls Unit: Pointer um impl-Ids für andere Dateien unsichtbar zu machen

                  UnitName   : tFileString;         // 20   Falls Unit: Filename ohne .pas
                  MyUnit     : pIdInfo;             // 24   Unit-Id, z.bei B. System.SysUtils: SysUtils
                  UsesListe  : pIdPtrInfo;          // 28   Falls Unit: Unit uses alle Units aus dieser Liste (sind damit in Suche wie ein WITH geöffnet)
                  liMax,
                  li         : tLineIndex;          // 32   Zeilen# der aktuell zu parsenden Zeile
                  riMax,
                  ri         : tRowIndex;           // 34   Spalten# der aktuell zu parsenden Zeile
                  pi         : pChar;
                  StrList    : TStringDynArray;     // 36   Inhalt der Datei als Strings[0..n]
                  prevFile   : tFileIndex_;         // 40   includierende Source
                  LastTop    : integer;             // 44   TopIndex vom letzten Mal
                  MyNode     : TTreeNode;           // 48   Falls Unit: tv-Zeiger
                  MyFileId   : pIdInfo;
                  NextIdInfo : tIdPosInfo;          // 52   Speicher für schon gescannte IdentifierInfos bei Dateiwechsel
                  NextFile   : tFileIndex_;         //      aktuelle Include-Datei der aktuellen Unit vor Interface/Implementation
                  NextLiMax,
                  NextLi     : tLineIndex;          //      aktuelle Zeile  in dieser include-Datei
                  NextRiMax,
                  NextRi     : tRowIndex;           //      aktuelle Spalte in dieser include-Datei
                  NextPi     : pChar;
                  MyIndex    : tFileIndex;          // 64   Index in der StringList DateiListe
                  PidAccess  : tAcTypeSet;          // 66   zum aktuellen Id sind diese Ac-Typen enthalten
                  NextKeyWord: tKeyWord;            // 67   Speicher für schon gescannte Token bei Dateiwechsel
                  CompDefines: tAktDefines;         // 68   array of set of 0..31, Index in DefinesList
                  IfOptLokal : tCompilerOptions;    // 72   array[boolean] über ALLE Compiler-Direktiven, gebraucht wird nur $A..$Z, ScopedEnums
                 _FillOpt    : array[0..0] of byte; //163
                  fiFlags    : set of tFileFlags;   //164   Falls Unit: nur das Interface analysieren
                  LibraryNr  : tLibraryIdx;         //      aus welchem Library-Pfad aud IncludesUnitAll stammt die Datei
//                 _Fill       : array[0..1] of byte  //162
                end;                                //164

var
  NotFoundFiles : TList< tFileString >;
  DateiListe    : System.TArray< pFileInfo >;
  pAktFile      : pFileInfo;
  pPathIds      : pIdInfo;
  RefactorEndIf : boolean = false;
  LastExtraNo,
  LastExtraYes  : string;

const
  cFirstFileV  =  0;     // Index PseudoFile (aus INI-Options gebaut)
  cFirstFile   =  {$IFDEF PseudoFile} 1 {$ELSE} 0 {$ENDIF};
  cKeinFileIndex=-1;
  cExtraLogYes  = 'EndIf_Yes.txt';
  cExtraLogNo   = 'EndIf_No.txt';

{$ENDREGION }

{ --------------------------------------------------------------------------------------------------------------------------- }

var
  Abbruch             : boolean;
  AbbruchMsg          : string;
  IncludesUnitLib,
  IncludesUnit,
  IncludesUnitAll,
  IncludesI,
  UnitPrefixes,
  Defines             : System.TArray< string >;
  DefinesHigh         : word;
  NotImplemented      : string;     // hier werden fürs Err-Protokoll $IF-$ELSEIF-Compiler-Steuerungen gesammelt

  ZaehlerId           : array[tIdType] of longword;
  ZaehlerAc           : array[tAcType] of longword;
  ZaehlerIds,
  ZaehlerAcs          : longword;
  GuiParser           : record
                          RepaintLstBox: tProc;
                        end;
  ProjDir, IniErrName : string;

  FileOptions         : record
                          LastItem,                          // der aus der ini gelesene tv.ItemIndex
                          PathMacros,
                          SearchPathDelphi,
                          SearchPathUnitLib,                 // aus IDE->Tools->Optionen->Sprache
                          SearchPathUnit,                    // aus Project-Optionen
                          SearchPathDelphiNoMacro,           // Macros $BDS entfernt
                          SearchPathUnitLibNoMacro,
                          SearchPathUnitNoMacro,
                          UnitPrefix,                      // Gueltigkeitsbereichsnamen aus IDE-Tools-Optionen z.B. VCL / FMX
                          DefinedSymbols   : string;         // Compiler-Defines aus Projekt-Optionen
                          EnableUnitPrefix,
                          EnableDelphiLib  : boolean;
                          UseSystemRef,
                          ParseFormular,
                          ProjectUsedOnly,                    // siehe Flag tIdFlags2.isUsedByProject
                          RegKeySymbols,
                          RegKeywords      : boolean;
                          AcKontext        : word;            // Anzahl Kontext-Zeilen vor und nach jedem Ac
                          HotKeyList       : string;
                          HotKey           : array[tHotKeys] of string;
                        end;


implementation

{$IFDEF TraceDx}
uses
  uTraceDx;
{$ENDIF}


initialization
  {$IFDEF TraceDx}
    TraceDx.Send( 'uGlobalsParser.initialization' );
  {$ENDIF}
  NotFoundFiles := TList<tFileString>.Create;
  NotFoundFiles.Capacity := 100;

finalization
  {$IFDEF TraceDx}
    TraceDx.Send( 'uGlobalsParser.finalization' );
  {$ENDIF}
  NotFoundFiles.Free

end.
