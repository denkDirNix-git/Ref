
unit uSystem;

{$INCLUDE _CompilerOptions.pas}
{ $UNDEF TraceDx}

interface

uses
  uGlobalsParser,
  uListen;

type
  enSysIds   = ( syInt64, syCardinal, syInteger, sySmallInt, syShortInt,    // Reihenfolge gemäß cSystem
                 sySingle, syDouble, syReal, syExtended,
                 syBoolean, syPointer,
                 syString, syChar, syAnsiChar,
                 syShortString,                  // ShortStringArr,
                 syObject = syShortString+2,     // ClassName, Create, Destroy, Free,
                 syClass = syObject+5,
                 syTArray,
                 syWrite = syTArray+3, syWriteLn, syStr,        // im Parser benötigt wegen ":" in Expressions
                 syMem,                            //                    "
                 syExit );                         // im Parser benötigt wegen acWrite auf Result
  tTypeNrBig = cardinal;

const     (*
  pSysId  : array[enSysIds] of pIdInfo;
           = (     // Zeiger auf vom Parser benötigte SysIds, könnte auch durch @IdArray0[sy...] ersetzt werden
  {Int}        @IdArray0[ 0], @IdArray0[ 1], @IdArray0[ 2], @IdArray0[ 3], @IdArray0[ 4],
  {Real}       @IdArray0[ 5], @IdArray0[ 6], @IdArray0[ 7], @IdArray0[ 8],
  {bool,ptr}   @IdArray0[ 9], @IdArray0[10], @IdArray0[11],
  {string}     @IdArray0[12], @IdArray0[13], @IdArray0[14],
  {short}      @IdArray0[15], @IdArray0[16],
  {class}      @IdArray0[17], @IdArray0[18],
  {write,str}  @IdArray0[19], @IdArray0[20], @IdArray0[21],
  {mem}        @IdArray0[22],
  {exit}       @IdArray0[23] );  *)

  cSetInt    = sySmallInt;     // alle Ints werden für SET auf SmallInt abgebildet (weil Byte nicht exportiert wird)
  cSetChar   = syAnsiChar;     // alle Ints werden für SET auf AnsiChar abgebildet
  cSetInc    = 1;              // ein SET hat die TypeNr Basisklasse + 1

  cNoTypeNr  = 0;              // hier sollte eine TypeNr extra reserviert sein
  cEmptySet  = cNoTypeNr;      // leerer Set, mit alles Set-Types kompatibel
  cGroupInt  = [0,1,2,3,4];
  cGroupReal = [5,6,7,8];
  cGroupPtr  = [10];
  cGroupStr  = [11,12,13,14,15];

var
  LastSystemId : pIdInfo;     // alle weiteren Ids nach diesem werden im PreParse gelöscht
  TypeCountSys,
  TypeCount    : tTypeNrBig;
  pSysId       : array[enSysIds] of pIdInfo;

  DummyIdUnb    : tIdInfo = ( Name: 'Unb'    ; Typ: id_Type; PrevBlock: @IdMainMain; Hash: cNoHash; TypeGroup: coUnb    );
  DummyIdEnum   : tIdInfo = ( Name: 'Enum'   ; Typ: id_Type; PrevBlock: @IdMainMain; Hash: cNoHash; TypeGroup: coEnum   );
  DummyIdSet    : tIdInfo = ( Name: 'SetOf'  ; Typ: id_Type; PrevBlock: @IdMainMain; Hash: cNoHash; TypeGroup: coSet    );
  DummyIdFile   : tIdInfo = ( Name: 'FileOf '; Typ: id_Type; PrevBlock: @IdMainMain; Hash: cNoHash; TypeGroup: coFile   );
  DummyIdArrayOf: tIdInfo = ( Name: 'ArrayOf'; Typ: id_Type; PrevBlock: @IdMainMain; Hash: cNoHash; TypeGroup: coArrayOf);   // für "array of" als Parameter

function  UnitSystemInit: word;
procedure LoadSystemIds;
procedure UnitSystemPreParse;

implementation

uses
  {$IFDEF TraceDx} uTraceDx, {$ENDIF}
  VCL.Dialogs;

const
  cExit        = 'Exit';
  cMaxSystemId = 284;

type
  {$IFDEF TraceDx} uSys = class end; {$ENDIF}
  enSysTypesIntern = ( syByte = ord(high(enSysIds))+1,      // weitere sysIds, die aber nur intern gebraucht werden
                       syWord, syLongWord,
                       syThreadId, syLongInt,
                       syNativeInt, syNativeUInt                // Reihenfolge gemäß cSystem
            // todo ...
                     );

  enSysPara = ( spTypeUnbekannt,
                spC, spV,
                spCV, spVC,
                spCC, spVCC,
                spCVC,
                spVV, spCVV,
                spCCC, spCCCC,          // Write
                spVVV, spCVVV,          // Read    ( immer MIT File-Angabe (nicht von CON) )
                spVCV, spVVCV,          // BlockRead
                spCCV, spVCCV,          // BlockWrite
                spVCCC                  // SetLength (kann mehrere Array-Dimensionen setzen, nicht dokumentiert)

//                spVVVV, spCVVV, spVCCC, spCVCC,
//                spCVCV1, spCVCV2,     // BlockRead
//                spCCCV1, spCCCV2      // BlockWrite
              );

const
  cLastSysType  = pred( syWrite );

  cSysPara: array[enSysPara] of tIdInfo = (      { Für ALLE System-Procs -> prevBlock ist nicht gesetzt! }
             {spType } ( Name: 'Type'; Typ: id_Type;  TypeGroup: coUnb ),   // den gibt es nur, damit overload-checks auf Parameter-MyTypes zugreifen können
             {spC    } ( Name: cConst; Typ: id_Const; MyType: @cSysPara[spTypeUnbekannt]; NextId: nil                         ; IdFlags: [tIdFlags.fromSystemLib, tIdFlags.IsParameter, tIdFlags.optionalPara];                        TypeGroup: coUnb ),
             {spV    } ( Name: cVar  ; Typ: id_Var  ; MyType: @cSysPara[spTypeUnbekannt]; NextId: nil                         ; IdFlags: [tIdFlags.fromSystemLib, tIdFlags.IsParameter, tIdFlags.optionalPara, tIdFlags.IsWriteParam]; TypeGroup: coUnb ),
             {spCV   } ( Name: cConst; Typ: id_Const; MyType: @cSysPara[spTypeUnbekannt]; NextId: @cSysPara[enSysPara.spV    ]; IdFlags: [tIdFlags.fromSystemLib, tIdFlags.IsParameter, tIdFlags.optionalPara];                        TypeGroup: coUnb ),
             {spVC   } ( Name: cVar  ; Typ: id_Var  ; MyType: @cSysPara[spTypeUnbekannt]; NextId: @cSysPara[enSysPara.spC    ]; IdFlags: [tIdFlags.fromSystemLib, tIdFlags.IsParameter, tIdFlags.optionalPara, tIdFlags.IsWriteParam]; TypeGroup: coUnb ),
             {spCC   } ( Name: cConst; Typ: id_Const; MyType: @cSysPara[spTypeUnbekannt]; NextId: @cSysPara[enSysPara.spC    ]; IdFlags: [tIdFlags.fromSystemLib, tIdFlags.IsParameter, tIdFlags.optionalPara];                        TypeGroup: coUnb ),
             {spVCC  } ( Name: cVar  ; Typ: id_Var  ; MyType: @cSysPara[spTypeUnbekannt]; NextId: @cSysPara[enSysPara.spCC   ]; IdFlags: [tIdFlags.fromSystemLib, tIdFlags.IsParameter, tIdFlags.optionalPara, tIdFlags.IsWriteParam]; TypeGroup: coUnb ),
             {spCVC  } ( Name: cConst; Typ: id_Const; MyType: @cSysPara[spTypeUnbekannt]; NextId: @cSysPara[enSysPara.spVC   ]; IdFlags: [tIdFlags.fromSystemLib, tIdFlags.IsParameter, tIdFlags.optionalPara];                        TypeGroup: coUnb ),
             {spVV   } ( Name: cVar  ; Typ: id_Var  ; MyType: @cSysPara[spTypeUnbekannt]; NextId: @cSysPara[enSysPara.spV    ]; IdFlags: [tIdFlags.fromSystemLib, tIdFlags.IsParameter, tIdFlags.optionalPara, tIdFlags.IsWriteParam]; TypeGroup: coUnb ),
             {spCVV  } ( Name: cConst; Typ: id_Const; MyType: @cSysPara[spTypeUnbekannt]; NextId: @cSysPara[enSysPara.spVV   ]; IdFlags: [tIdFlags.fromSystemLib, tIdFlags.IsParameter, tIdFlags.optionalPara];                        TypeGroup: coUnb ),
             {spCCC  } ( Name: cConst; Typ: id_Const; MyType: @cSysPara[spTypeUnbekannt]; NextId: @cSysPara[enSysPara.spCC   ]; IdFlags: [tIdFlags.fromSystemLib, tIdFlags.IsParameter, tIdFlags.optionalPara];                        TypeGroup: coUnb ),
             {spCCCC } ( Name: cConst; Typ: id_Const; MyType: @cSysPara[spTypeUnbekannt]; NextId: @cSysPara[enSysPara.spCCC  ]; IdFlags: [tIdFlags.fromSystemLib, tIdFlags.IsParameter, tIdFlags.optionalPara];                        TypeGroup: coUnb ),
             { für write() und so könnte man noch mehr brauchen ... }


             {spVVV  } ( Name: cVar  ; Typ: id_Var  ; MyType: @cSysPara[spTypeUnbekannt]; NextId: @cSysPara[enSysPara.spVV   ]; IdFlags: [tIdFlags.fromSystemLib, tIdFlags.IsParameter, tIdFlags.optionalPara, tIdFlags.IsWriteParam]; TypeGroup: coUnb ),
             {spCVVV } ( Name: cConst; Typ: id_Const; MyType: @cSysPara[spTypeUnbekannt]; NextId: @cSysPara[enSysPara.spVVV  ]; IdFlags: [tIdFlags.fromSystemLib, tIdFlags.IsParameter, tIdFlags.optionalPara];                        TypeGroup: coUnb ),

             {spVCV  } ( Name: cVar  ; Typ: id_Var  ; MyType: @cSysPara[spTypeUnbekannt]; NextId: @cSysPara[enSysPara.spCV   ]; IdFlags: [tIdFlags.fromSystemLib, tIdFlags.IsParameter, tIdFlags.optionalPara, tIdFlags.IsWriteParam]; TypeGroup: coUnb ),
             {spVVCV } ( Name: cVar  ; Typ: id_Var  ; MyType: @cSysPara[spTypeUnbekannt]; NextId: @cSysPara[enSysPara.spVCV  ]; IdFlags: [tIdFlags.fromSystemLib, tIdFlags.IsParameter, tIdFlags.optionalPara, tIdFlags.IsWriteParam]; TypeGroup: coUnb ),

             {spCCV  } ( Name: cConst; Typ: id_Const; MyType: @cSysPara[spTypeUnbekannt]; NextId: @cSysPara[enSysPara.spCV   ]; IdFlags: [tIdFlags.fromSystemLib, tIdFlags.IsParameter, tIdFlags.optionalPara];                        TypeGroup: coUnb ),
             {spVCCV } ( Name: cVar  ; Typ: id_Var  ; MyType: @cSysPara[spTypeUnbekannt]; NextId: @cSysPara[enSysPara.spCCV  ]; IdFlags: [tIdFlags.fromSystemLib, tIdFlags.IsParameter, tIdFlags.optionalPara, tIdFlags.IsWriteParam]; TypeGroup: coUnb ),

             {spVCCC } ( Name: cVar  ; Typ: id_Var  ; MyType: @cSysPara[spTypeUnbekannt]; NextId: @cSysPara[enSysPara.spCCC  ]; IdFlags: [tIdFlags.fromSystemLib, tIdFlags.IsParameter, tIdFlags.optionalPara, tIdFlags.IsWriteParam]; TypeGroup: coUnb )
            );

{$REGION '--------- System Ids ---------------' }

  {  special Flags:
     - isEnumCopy      nächste TypeNr für SET of type freihalten
     - isResult        EnterSub  (Parent)
     - isRekursiv      LeaveSub  (LastChild)
     - IdUnused        MyType ist als Delta-Offset in MyType als integer hinterlegt
  }

var
  cSystem: array[0..cMaxSystemId] of tIdInfo = (
            // SysId-Types für Basis-Typen von Literals, werden auch im Parser gebraucht
{ coInt: }
            ( Name: 'Int64'      ; Typ: id_Type ; IdFlags: [tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt ),     // absteigende Reihenfolge
            ( Name: 'Cardinal'   ; Typ: id_Type ; IdFlags: [tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt ),     // wichtig für calcCompatibility()
            ( Name: 'Integer'    ; Typ: id_Type ; IdFlags: [tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt ),
            ( Name: 'SmallInt'   ; Typ: id_Type ; IdFlags: [tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt ),
            ( Name: 'ShortInt'   ; Typ: id_Type ; IdFlags: [tIdFlags.NoCopy, tIdFlags.IsEnumCopy]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt ),
{ coReal: }
            ( Name: 'Single'     ; Typ: id_Type ; IdFlags: [tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coReal ),
            ( Name: 'Double'     ; Typ: id_Type ; IdFlags: [tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coReal ),
            ( Name: 'Real'       ; Typ: id_Type ;                             IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coReal ),
            ( Name: 'Extended'   ; Typ: id_Type ; IdFlags: [tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coReal ),
{ coBool: }
            ( Name: 'Boolean'    ; Typ: id_Type ; IdFlags: [tIdFlags.IsEnumCopy,tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coBool ),
{ coPtr: }
            ( Name: 'Pointer'    ; Typ: id_Type ; IdFlags: [tIdFlags.IsPointer]; IdFlags2: [tIdFlags2.InterfaceSection];  TypeGroup: coPtr ),
              { hier kein Sub-Pointer weil niemals ungecastete Zugriffe stattfinden }
{ coStr,coChar: }
            ( Name: 'String'     ; Typ: id_Type ; IdFlags: [tIdFlags.NoCopy]    ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coStr  ),
            ( Name: 'Char'       ; Typ: id_Type ;                                 IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coChar ),
            ( Name: 'AnsiChar'   ; Typ: id_Type ; IdFlags: [tIdFlags.IsEnumCopy]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coChar ),
            ( Name: 'ShortString'; Typ: id_Type ; IdFlags: [tIdFlags.IsResult]  ; IdFlags2: [tIdFlags2.InterfaceSection];  TypeGroup: coStr ),
              ( Name: dArraySymbol ; Typ: id_Var  ; MyType: @IdArray0[ord( syAnsiChar)]; IdFlags: [tIdFlags.IsRekursiv]; TypeGroup: coChar ),

            ( Name: 'TObject'    ; Typ: id_Type ;                                      IdFlags: [tIdFlags.IsClassType, tIdFlags.NoCopy, tIdFlags.IsResult]; IdFlags2: [tIdFlags2.InterfaceSection];          TypeGroup: coClass ),
              ( Name: 'ClassName'  ; Typ: id_Func ; MyType: @IdArray0[ord( syString)];                                                                                 TypeGroup: coMethod),
              ( Name: 'Create'     ; Typ: id_Func ; MyType: @IdArray0[ord( syObject)];   IdFlags: [tIdFlags.IsClassType, tIdFlags.IsConstructor];                      TypeGroup: coMethod),
              ( Name: 'Destroy'    ; Typ: id_Proc ;                                                                                                                    TypeGroup: coMethod),
              ( Name: 'Free'       ; Typ: id_Proc ;                                      IdFlags: [tIdFlags.isRekursiv];                                               TypeGroup: coMethod),
            ( Name: 'TClass'     ; Typ: id_Type ;                                      IdFlags: [tIdFlags.IsClassType, tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection];                             TypeGroup: coClass ),
            ( Name: 'TArray<1>'  ; Typ: id_Type ; IdFlags: [tIdFlags.IsGenericType,tIdFlags.IsResult]; IdFlags2: [tIdFlags2.InterfaceSection];  {MyType: @DummyIdArrayOf;            {TypeGroup: coArrayOf; }                                                           TypeGroup: coTArray),
              ( Name: 'T'        ; Typ: id_Unbekannt{kein "echter" Typ};            IdFlags: [tIdFlags.IsGenericDummy];                                                {TypeGroup: coUnb}),
              ( Name: dArraySymbol;Typ: id_Var  ; MyType: Pointer( 1 );           IdFlags: [tIdFlags.isRekursiv,tIdFlags.IdUnused];                                  {TypeGroup: coUnb}),

// SysId-Procs für Spezial-Parsing-Syntax
            ( Name: 'Write'      ; Typ: id_Proc ; SubBlock: @cSysPara[enSysPara.spCCCC]; SubLast: @cSysPara[enSysPara.spC]; IdFlags2: [tIdFlags2.InterfaceSection] ),
            ( Name: 'WriteLn'    ; Typ: id_Proc ; SubBlock: @cSysPara[enSysPara.spCCCC]; SubLast: @cSysPara[enSysPara.spC]; IdFlags2: [tIdFlags2.InterfaceSection] ),
            ( Name: 'Str'        ; Typ: id_Proc ; SubBlock: @cSysPara[enSysPara.spCV  ]; SubLast: @cSysPara[enSysPara.spV]; IdFlags2: [tIdFlags2.InterfaceSection] ),
            ( Name: 'Mem'        ; Typ: id_Var  ; IdFlags2: [tIdFlags2.InterfaceSection] ),
            ( Name: cExit        ; Typ: id_Proc ; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC]; IdFlags2: [tIdFlags2.InterfaceSection] ),

{ --------------- bis hierher Reihenfolge analog type enSysIds --------------------- }

// alle weiteres Types Const Var:
            ( Name: 'Byte'       ; Typ: id_Type ; IdFlags: [tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection];           TypeGroup: coInt ),
            ( Name: 'Word'       ; Typ: id_Type ; IdFlags: [tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection];           TypeGroup: coInt ),
            ( Name: 'LongWord'   ; Typ: id_Type ; MyType: @IdArray0[ord( syCardinal )]; IdFlags: [tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection];           TypeGroup: coInt ),
            ( Name: 'TThreadId'  ; Typ: id_Type ; MyType: pIdInfo(1); IdFlags: [tIdFlags.IdUnused]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt ),      // pidInfo(1) == 1 Eintrag vorher
            ( Name: 'LongInt'    ; Typ: id_Type ; IdFlags: [tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection];           TypeGroup: coInt ),
            ( Name: 'NativeInt'  ; Typ: id_Type ; IdFlags: [tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection];           TypeGroup: coInt ),
            ( Name: 'NativeUInt' ; Typ: id_Type ; IdFlags: [tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection];           TypeGroup: coInt ),

{ --------------- bis hierher Reihenfolge analog type enSysTypeIntern --------------------- }

            ( Name: 'UInt8'      ; Typ: id_Type ; MyType: @IdArray0[ord( syByte     )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt ),
            ( Name: 'Int8'       ; Typ: id_Type ; MyType: @IdArray0[ord( syShortInt )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt ),
            ( Name: 'UInt16'     ; Typ: id_Type ; MyType: @IdArray0[ord( syWord     )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt ),
            ( Name: 'Int16'      ; Typ: id_Type ; MyType: @IdArray0[ord( sySmallInt )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt ),
            ( Name: 'UInt32'     ; Typ: id_Type ; MyType: @IdArray0[ord( syCardinal )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt ),
            ( Name: 'Int32'      ; Typ: id_Type ; MyType: @IdArray0[ord( syInteger  )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt ),
            ( Name: 'UInt64'     ; Typ: id_Type ; MyType: @IdArray0[ord( syCardinal )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt ),
            ( Name: 'FixedInt'   ; Typ: id_Type ; MyType: @IdArray0[ord( syInteger  )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt ),
            ( Name: 'FixedUInt'  ; Typ: id_Type ; MyType: @IdArray0[ord( syCardinal )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt ),

            ( Name: 'IInterface' ; Typ: id_Type ;                                      IdFlags: [tIdFlags.IsInterface, tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInterf ),
            ( Name: 'IUnknown'   ; Typ: id_Type ;                                      IdFlags: [tIdFlags.IsInterface, tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInterf ),
            ( Name: 'IInvokable' ; Typ: id_Type ;                                      IdFlags: [tIdFlags.IsInterface, tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInterf ),
            ( Name: 'IEnumerator'; Typ: id_Type ;                                      IdFlags: [tIdFlags.IsInterface, tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInterf ),
            ( Name: 'IEnumerable'; Typ: id_Type ;                                      IdFlags: [tIdFlags.IsInterface, tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInterf ),
            ( Name: 'IComparable'; Typ: id_Type ;                                      IdFlags: [tIdFlags.IsInterface, tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInterf ),
            ( Name: 'IDispatch'  ; Typ: id_Type ;                                      IdFlags: [tIdFlags.IsInterface, tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInterf ),

            ( Name: 'TInterfacedObject'; Typ: id_Type ;                                IdFlags: [tIdFlags.IsClassType, tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection]; MyParent: @IdArray0[ord( syObject )];TypeGroup: coClass ),
            ( Name: 'TInterfacedClass' ; Typ: id_Type ;                                IdFlags: [tIdFlags.IsClassType, tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection];                             TypeGroup: coClass ),
            ( Name: 'TAggregatedObject'; Typ: id_Type ;                                IdFlags: [tIdFlags.IsClassType, tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection]; MyParent: @IdArray0[ord( syObject )];TypeGroup: coClass ),
            ( Name: 'TContainedObject' ; Typ: id_Type ;                                IdFlags: [tIdFlags.IsClassType, tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection]; MyParent: @IdArray0[ord( syObject )];TypeGroup: coClass ),


            ( Name: 'Comp'       ; Typ: id_Type ;                                       IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coReal ),

            ( Name: 'Currency'   ; Typ: id_Type                                        ; IdFlags2: [tIdFlags2.InterfaceSection] ),
            ( Name: 'TDateTime'  ; Typ: id_Type ; MyType: @IdArray0[ord( syDouble )]; IdFlags2: [tIdFlags2.InterfaceSection];   TypeGroup: coReal ),
            ( Name: 'PDateTime'  ; Typ: id_Type ;                                         IdFlags: [tIdFlags.IsPointer, tIdFlags.IsResult]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coPtr ),
            ( Name: dPtrSymbol   ; Typ: id_Var  ; MyType: pIdInfo( 2 );                   IdFlags: [tIdFlags.IsRekursiv,tIdFlags.IdUnused]; TypeGroup: coReal),
            ( Name: 'TDate'      ; Typ: id_Type ; MyType: @IdArray0[ord( syDouble )]; IdFlags2: [tIdFlags2.InterfaceSection];   TypeGroup: coReal ),
            ( Name: 'TTime'      ; Typ: id_Type ; MyType: @IdArray0[ord( syDouble )]; IdFlags2: [tIdFlags2.InterfaceSection];   TypeGroup: coReal ),

            ( Name: 'LongBool'   ; Typ: id_Type ; IdFlags: [tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection];           TypeGroup: coBool ),
            ( Name: 'AnsiString' ; Typ: id_Type ;                                       IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coStr  ),
            ( Name: 'WideString' ; Typ: id_Type ; MyType: @IdArray0[ord( syString)];    IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coStr  ),
            ( Name: 'UnicodeString';Typ:id_Type ; MyType: @IdArray0[ord( syString)];    IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coStr  ),
            ( Name: 'RawByteString';Typ:id_Type ; MyType: @IdArray0[ord( syString)];    IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coStr  ),
            ( Name: 'WideChar'   ; Typ: id_Type ; MyType: @IdArray0[ord( syChar  )];    IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coChar ),
            ( Name: 'TextFile'   ; Typ: id_Type ;                                       IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coFile ),

{ Pointer: }
            ( Name: 'pInt64'     ; Typ: id_Type ;                                         IdFlags: [tIdFlags.IsPointer, tIdFlags.IsResult]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coPtr ),
            ( Name: dPtrSymbol   ; Typ: id_Var  ; MyType: @IdArray0[ord( syInt64)];       IdFlags: [tIdFlags.IsRekursiv];                                                           TypeGroup: coInt ),
            ( Name: 'pCardinal'  ; Typ: id_Type ;                                         IdFlags: [tIdFlags.IsPointer, tIdFlags.IsResult]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coPtr ),
            ( Name: dPtrSymbol   ; Typ: id_Var  ; MyType: @IdArray0[ord( syCardinal)];    IdFlags: [tIdFlags.IsRekursiv];                                                           TypeGroup: coInt ),
            ( Name: 'pInteger'   ; Typ: id_Type ;                                         IdFlags: [tIdFlags.IsPointer, tIdFlags.IsResult]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coPtr ),
            ( Name: dPtrSymbol   ; Typ: id_Var  ; MyType: @IdArray0[ord( syInteger)];     IdFlags: [tIdFlags.IsRekursiv];                                                           TypeGroup: coInt ),
            ( Name: 'pSmallInt'  ; Typ: id_Type ;                                         IdFlags: [tIdFlags.IsPointer, tIdFlags.IsResult]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coPtr ),
            ( Name: dPtrSymbol   ; Typ: id_Var  ; MyType: @IdArray0[ord( sySmallInt)];    IdFlags: [tIdFlags.IsRekursiv];                   TypeGroup: coInt ),
            ( Name: 'pByte'      ; Typ: id_Type ;                                         IdFlags: [tIdFlags.IsPointer, tIdFlags.IsResult]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coPtr ),
            ( Name: dPtrSymbol   ; Typ: id_Var  ; MyType: @IdArray0[ord( syByte)]    ;    IdFlags: [tIdFlags.IsRekursiv];                   TypeGroup: coInt ),
            ( Name: 'pShortInt'  ; Typ: id_Type ;                                         IdFlags: [tIdFlags.IsPointer, tIdFlags.IsResult]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coPtr ),
            ( Name: dPtrSymbol   ; Typ: id_Var  ; MyType: @IdArray0[ord( syShortInt)];    IdFlags: [tIdFlags.IsRekursiv];                   TypeGroup: coInt ),

            ( Name: 'pExtended'  ; Typ: id_Type ;                                         IdFlags: [tIdFlags.IsPointer, tIdFlags.IsResult]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coPtr ),
            ( Name: dPtrSymbol   ; Typ: id_Var  ; MyType: @IdArray0[ord( syExtended)];    IdFlags: [tIdFlags.IsRekursiv];                   TypeGroup: coReal ),
            ( Name: 'pSingle'    ; Typ: id_Type ;                                         IdFlags: [tIdFlags.IsPointer, tIdFlags.IsResult]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coPtr ),
            ( Name: dPtrSymbol   ; Typ: id_Var  ; MyType: @IdArray0[ord( sySingle)];      IdFlags: [tIdFlags.IsRekursiv];                   TypeGroup: coReal ),
            ( Name: 'pDouble'    ; Typ: id_Type ;                                         IdFlags: [tIdFlags.IsPointer, tIdFlags.IsResult]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coPtr ),
            ( Name: dPtrSymbol   ; Typ: id_Var  ; MyType: @IdArray0[ord( syDouble)];      IdFlags: [tIdFlags.IsRekursiv];                   TypeGroup: coReal ),

            ( Name: 'pBoolean'   ; Typ: id_Type ;                                         IdFlags: [tIdFlags.IsPointer, tIdFlags.IsResult]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coPtr ),
            ( Name: dPtrSymbol   ; Typ: id_Var  ; MyType: @IdArray0[ord( syBoolean)];     IdFlags: [tIdFlags.IsRekursiv];                   TypeGroup: coReal ),

            ( Name: 'pPointer'   ; Typ: id_Type ;                                         IdFlags: [tIdFlags.IsPointer, tIdFlags.IsResult]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coPtr ),
            ( Name: dPtrSymbol   ; Typ: id_Var  ; MyType: @IdArray0[ord( syPointer)];     IdFlags: [tIdFlags.IsRekursiv];                   TypeGroup: coReal ),

            ( Name: 'pString'    ; Typ: id_Type ;                                         IdFlags: [tIdFlags.IsPointer, tIdFlags.IsResult]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coPtr ),
            ( Name: dPtrSymbol   ; Typ: id_Var  ; MyType: @IdArray0[ord( syString)];      IdFlags: [tIdFlags.IsRekursiv];                   TypeGroup: coStr ),
            ( Name: 'pWideString'; Typ: id_Type ;                                         IdFlags: [tIdFlags.IsPointer, tIdFlags.IsResult]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coPtr ),
            ( Name: dPtrSymbol   ; Typ: id_Var  ; MyType: @IdArray0[ord( syString)];      IdFlags: [tIdFlags.IsRekursiv];                   TypeGroup: coStr ),
            ( Name: 'pUnicodeString';Typ:id_Type;                                         IdFlags: [tIdFlags.IsPointer, tIdFlags.IsResult]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coPtr ),
            ( Name: dPtrSymbol   ; Typ: id_Var  ; MyType: @IdArray0[ord( syString)];      IdFlags: [tIdFlags.IsRekursiv];                   TypeGroup: coStr ),
            ( Name: 'pChar'      ; Typ: id_Type ;                                         IdFlags: [tIdFlags.IsPointer, tIdFlags.IsResult]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coPtr ),
            ( Name: dPtrSymbol   ; Typ: id_Var  ; MyType: @IdArray0[ord( syChar)];        IdFlags: [tIdFlags.IsRekursiv];                   TypeGroup: coChar ),
            ( Name: 'pWideChar'  ; Typ: id_Type ;                                         IdFlags: [tIdFlags.IsPointer, tIdFlags.IsResult]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coPtr ),
            ( Name: dPtrSymbol   ; Typ: id_Var  ; MyType: @IdArray0[ord( syChar)];        IdFlags: [tIdFlags.IsRekursiv];                   TypeGroup: coChar),
            ( Name: 'pShortString';Typ: id_Type ;                                         IdFlags: [tIdFlags.IsPointer, tIdFlags.IsResult]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coPtr ),
            ( Name: dPtrSymbol   ; Typ: id_Var  ; MyType: @IdArray0[ord( syShortString)]; IdFlags: [tIdFlags.IsRekursiv];                   TypeGroup: coStr ),
            ( Name: 'pAnsiChar'  ; Typ: id_Type ;                                         IdFlags: [tIdFlags.IsPointer, tIdFlags.IsResult]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coPtr ),
            ( Name: dPtrSymbol   ; Typ: id_Var  ; MyType: @IdArray0[ord( syAnsiChar)];    IdFlags: [tIdFlags.IsRekursiv];                   TypeGroup: coChar ),

            ( Name: 'pWord'      ; Typ: id_Type ;                                         IdFlags: [tIdFlags.IsPointer, tIdFlags.IsResult]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coPtr ),
            ( Name: dPtrSymbol   ; Typ: id_Var  ; MyType: @IdArray0[ord( syWord)];        IdFlags: [tIdFlags.IsRekursiv];                   TypeGroup: coInt ),

            ( Name: 'HResult'    ; Typ: id_Type ; MyType: @IdArray0[ord( syInteger )] ;                                                     IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt ),
            ( Name: 'TGUID'      ; Typ: id_Type ;                                                                                           IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coSelf ),
            ( Name: 'PGUID'      ; Typ: id_Type ;                                         IdFlags: [tIdFlags.IsPointer, tIdFlags.IsResult]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coPtr ),
            ( Name: dPtrSymbol   ; Typ: id_Var  ; MyType: pIdInfo( 2 );                   IdFlags: [tIdFlags.IsRekursiv,tIdFlags.IdUnused]; TypeGroup: coSelf ),
            ( Name: 'THandle'    ; Typ: id_Type ; MyType: @IdArray0[ord( syNativeUInt)];                                                    IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt ),
            ( Name: 'TMarshal'   ; Typ: id_Type ;                                         IdFlags: [tIdFlags.IsClassType, tIdFlags.NoCopy]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coClass ),
            ( Name: 'TMethod'    ; Typ: id_Type ;                                                                                           IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coSelf ),
            ( Name: 'PMethod'    ; Typ: id_Type ;                                         IdFlags: [tIdFlags.IsPointer, tIdFlags.IsResult]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coPtr ),
            ( Name: dPtrSymbol   ; Typ: id_Var  ; MyType: pIdInfo( 2 );                   IdFlags: [tIdFlags.IsRekursiv,tIdFlags.IdUnused]; TypeGroup: coSelf ),
            ( Name: 'TMonitor'   ; Typ: id_Type ;                                                                                           IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coSelf ),
            ( Name: 'PMonitor'   ; Typ: id_Type ;                                         IdFlags: [tIdFlags.IsPointer, tIdFlags.IsResult]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coPtr ),
            ( Name: dPtrSymbol   ; Typ: id_Var  ; MyType: pIdInfo( 2 );                   IdFlags: [tIdFlags.IsRekursiv,tIdFlags.IdUnused]; TypeGroup: coSelf ),

            ( Name: 'Variant'    ; Typ: id_Type ;                                                                                           IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coUnb  ),
            ( Name: 'TVarData'   ; Typ: id_Type ;                                                                                           IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coRecord ),
            ( Name: 'PVarData'   ; Typ: id_Type ;                                         IdFlags: [tIdFlags.IsPointer, tIdFlags.IsResult]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coPtr ),
            ( Name: dPtrSymbol   ; Typ: id_Var  ; MyType: pIdInfo( 2 );                   IdFlags: [tIdFlags.IsRekursiv,tIdFlags.IdUnused]; TypeGroup: coSelf ),
            ( Name: 'varEmpty'   ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varNull'    ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varSmallint'; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varInteger' ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varSingle'  ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varDouble'  ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varCurrency'; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varDate'    ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varOleStr'  ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varDispatch'; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varError'   ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varBoolean' ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varVariant' ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varUnknown' ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varShortInt'; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varByte'    ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varWord'    ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varLongWord'; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varUInt32'  ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varInt64'   ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varUInt64'  ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varRecord'  ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varStrArg'  ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varObject'  ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varUStrArg' ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varString'  ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varAny'     ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varUString' ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varTypeMask'; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varArray'   ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'varByRef'   ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),

            ( Name: 'vtInteger'  ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'vtBoolean'  ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'vtChar'     ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'vtExtended' ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'vtString'   ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'vtPointer'  ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'vtPChar'    ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'vtObject'   ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'vtClass'    ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'vtWideChar' ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'vtPWideChar'; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'vtAnsiString';Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'vtCurrency' ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'vtVariant'  ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'vtInterface'; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'vtWideString';Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'vtInt64'    ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'vtUnicodeString';Typ:id_Const;MyType:@IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),

            ( Name: 'False'      ; Typ: id_Const; MyType: @IdArray0[ord( syBoolean )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coBool ),
            ( Name: 'True'       ; Typ: id_Const; MyType: @IdArray0[ord( syBoolean )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coBool ),
            ( Name: 'MaxInt'     ; Typ: id_Const; MyType: @IdArray0[ord( syInteger )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'MaxWord'    ; Typ: id_Const; MyType: @IdArray0[ord( syWord    )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'sLineBreak' ; Typ: id_Const; MyType: @IdArray0[ord( syString  )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coStr  ),
            ( Name: 'RTLVersion' ; Typ: id_Const; MyType: @IdArray0[ord( sySingle  )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coReal ),
            ( Name: 'CompilerVersion';Typ:id_Const;MyType:@IdArray0[ord( sySingle  )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coReal ),
            ( Name: 'DebugHook'  ; Typ: id_Var   ; MyType: @IdArray0[ord( syByte   )]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'HINST'      ; Typ: id_Type ;                                      IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt  ),
            ( Name: 'MainInstance';Typ: id_Var   ; MyType: pIdInfo(1); IdFlags: [tIdFlags.IdUnused]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt ),
            ( Name: 'hInstance'  ; Typ: id_Var   ; MyType: pIdInfo(2); IdFlags: [tIdFlags.IdUnused]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt ),

{!}         ( Name: 'Abs'        ; Typ: id_Func ; MyType: @IdArray0[ord( syInteger )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags: [tIdFlags.ParaMirror]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Addr'       ; Typ: id_Func ; MyType: @IdArray0[ord( syPointer )]; SubBlock: @cSysPara[enSysPara.spV   ]; SubLast: @cSysPara[enSysPara.spV] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'AllocMem'   ; Typ: id_Func ; MyType: @IdArray0[ord( syPointer )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Append'     ; Typ: id_Func ; MyType: @IdArray0[ord( syInteger )]; SubBlock: @cSysPara[enSysPara.spV   ]; SubLast: @cSysPara[enSysPara.spV] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'ArcTan'     ; Typ: id_Func ; MyType: @IdArray0[ord( syExtended)]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Assert'     ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spCC  ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
{wegen Verwechslungsgefahr deaktiviert:
            ( Name: 'Assign'     ; Typ: id_Func ; MyType: @IdArray0[ord( syInteger )]; SubBlock: @cSysPara[enSysPara.spVCCC]; SubLast: @cSysPara[enSysPara.spVCCC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),}
            ( Name: 'Assigned'   ; Typ: id_Func ; MyType: @IdArray0[ord( syBoolean)];  SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'AssignFile' ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spVC  ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
//                   AtomicCmpExchange
//                   AtomicDecrement
//                   AtomicExchange
//                   AtomicIncrement
            ( Name: 'BlockRead'  ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spVVCV]; SubLast: @cSysPara[enSysPara.spV] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'BlockWrite' ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spVCCV]; SubLast: @cSysPara[enSysPara.spV] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Break'      ; Typ: id_Proc ;                                                                                                                 IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
//                   BuiltInArcTan
//                   BuiltInArcTan2
//                   BuiltInCos               high      enum / int
//                   BuiltInLn                low        "
//                   BuiltInLnXPlus1          sqr       int / int64 / extended
//                   BuiltInLog10             pred      enum / int / char
//                   BuiltInLog2              succ       "
//                   BuiltInSin               upcase    char / ansichar
//                   BuiltInSqrt
//                   BuiltInTan
            ( Name: 'ChDir'      ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Chr'        ; Typ: id_Func ; MyType: @IdArray0[ord( syChar    )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
{wegen Verwechslungsgefahr deaktiviert:
            ( Name: 'Close'      ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spVVVV]; SubLast: @cSysPara[enSysPara.spVVVV] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),}
            ( Name: 'CloseFile'  ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spV   ]; SubLast: @cSysPara[enSysPara.spV] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
//          ( Name: 'CmdLine'    ; Typ: id_Var  ;
            ( Name: 'Concat'     ; Typ: id_Func ; MyType: @IdArray0[ord( syString)]  ; SubBlock: @cSysPara[enSysPara.spCCCC]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Continue'   ; Typ: id_Proc ;                                                                                                                 IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Copy'       ; Typ: id_Func ; MyType: @IdArray0[ord( syString  )]; SubBlock: @cSysPara[enSysPara.spCCC]; SubLast: @cSysPara[enSysPara.spC] ;  IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Dec'        ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spVC  ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
           {( Name: 'Default'    ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spCCCC]; SubLast: @cSysPara[enSysPara.spCCCC] ; TypeGroup: coMethod ),
            darf nicht rein weil default auch als Attribut vorkommen kann, siehe Attributes.pas }
            ( Name: 'Delete'     ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spVCC ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Dispose'    ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'EoF'        ; Typ: id_Func ; MyType: @IdArray0[ord( syBoolean )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'EoLn'       ; Typ: id_Func ; MyType: @IdArray0[ord( syBoolean )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Erase'      ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
//          ( Name: 'ErrorAddr'  ; Typ: id_Var  ;
//          ( Name: 'ErrorProc'  ; Typ: id_Var  ;
//          ( Name: 'ExceptProc' ; Typ: id_Var  ;
            ( Name: 'Exclude'    ; Typ: id_Proc                                      ; SubBlock: @cSysPara[enSysPara.spVC  ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Exit'       ; Typ: id_Proc ;                                                                                                                 IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'ExitCode'   ; Typ: id_Var  ; MyType: @IdArray0[ord( syInteger )];                                                                            IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt ),
//          ( Name: 'ExitProc'   ; Typ: id_Var  ;
            ( Name: 'Exp'        ; Typ: id_Func ; MyType: @IdArray0[ord( syExtended)]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
//                   Fail
            ( Name: 'FileMode'   ; Typ: id_Var  ; MyType: @IdArray0[ord( syByte    )];                                                                            IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt ),
            ( Name: 'FilePos'    ; Typ: id_Func ; MyType: @IdArray0[ord( syInteger )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'FileSize'   ; Typ: id_Func ; MyType: @IdArray0[ord( syInteger )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'FillChar'   ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spVCC ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Finalize'   ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spVC  ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Flush'      ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'FreeMem'    ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spCC  ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'GetDir'     ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spCV  ]; SubLast: @cSysPara[enSysPara.spV] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'GetLastError';Typ: id_Func ; MyType: @IdArray0[ord( syInteger )];                                                                            IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'GetMem'     ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spVC  ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'GetTickCount';Typ: id_Func ; MyType: @IdArray0[ord( syCardinal)];                                                                            IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Halt'       ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Hi'         ; Typ: id_Func ; MyType: @IdArray0[ord( syByte    )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
{!}         ( Name: 'High'       ; Typ: id_Func ; MyType: @IdArray0[ord( syInteger )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags: [tIdFlags.ParaMirror]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Inc'        ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spVC  ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Include'    ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spVC  ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
//             ( n: 'Initialize'; Typ: id_Proc ;
            ( Name: 'Insert'     ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spCVC ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Int'        ; Typ: id_Func ; MyType: @IdArray0[ord( syExtended)]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'IOResult'   ; Typ: id_Func ; MyType: @IdArray0[ord( syInteger )];                                                                            IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'IsConsole'  ; Typ: id_Var  ; MyType: @IdArray0[ord( syBoolean )];                                                                            IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coBool   ),
            ( Name: 'MainThreadID';Typ: id_Var  ; MyType: @IdArray0[ord( syCardinal)];                                                                            IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt    ),
            ( Name: 'IsLibrary'  ; Typ: id_Var  ; MyType: @IdArray0[ord( syBoolean )];                                                                            IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coBool   ),
            ( Name: 'Length'     ; Typ: id_Func ; MyType: @IdArray0[ord( syInteger )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Ln'         ; Typ: id_Func ; MyType: @IdArray0[ord( syExtended)]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Lo'         ; Typ: id_Func ; MyType: @IdArray0[ord( syByte    )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'HGLOBAL'    ; Typ: id_Type ;                                                                                                                 IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coInt ),
            ( Name: 'LoadResource';Typ: id_Func ; MyType: pIdInfo( 1 );                SubBlock: @cSysPara[enSysPara.spCC  ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags: [tIdFlags.IdUnused];   IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
{!}         ( Name: 'Low'        ; Typ: id_Func ; MyType: @IdArray0[ord( syInteger )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags: [tIdFlags.ParaMirror]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
//                  MemoryBarrier
            ( Name: 'MkDir'      ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'move'       ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spCVC ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
//          ( Name: 'MulDivInt64'; Typ: id_Func ; MyType: @IdArray0[ord( syPointer )]; SubBlock: @cSysPara[enSysPara.spVCCC]; SubLast: @cSysPara[enSysPara.spVCCC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'New'        ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spV   ]; SubLast: @cSysPara[enSysPara.spV] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Odd'        ; Typ: id_Func ; MyType: @IdArray0[ord( syBoolean )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Ord'        ; Typ: id_Func ; MyType: @IdArray0[ord( syByte    )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'ParamCount' ; Typ: id_Func ; MyType: @IdArray0[ord( syInteger )];                                                                            IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'ParamStr'   ; Typ: id_Func ; MyType: @IdArray0[ord( syString  )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Pi'         ; Typ: id_Func ; MyType: @IdArray0[ord( syExtended)];                                                                            IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Pos'        ; Typ: id_Func ; MyType: @IdArray0[ord( syInteger )]; SubBlock: @cSysPara[enSysPara.spCCC ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
{!}         ( Name: 'Pred'       ; Typ: id_Func ; MyType: @IdArray0[ord( syInteger )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags: [tIdFlags.ParaMirror]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Ptr'        ; Typ: id_Func ; MyType: @IdArray0[ord( syPointer )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Random'     ; Typ: id_Func ; MyType: @IdArray0[ord( syInteger )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags: [tIdFlags.IsOverload]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Random'     ; Typ: id_Func ; MyType: @IdArray0[ord( syExtended )];                                                                              IdFlags: [tIdFlags.IsOverload]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Randomize'  ; Typ: id_Proc ;                                                                                                                    IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Read'       ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spCVVV]; SubLast: @cSysPara[enSysPara.spV] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'ReadLn'     ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spCVVV]; SubLast: @cSysPara[enSysPara.spV] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'ReallocMem' ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spVC  ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Rename'     ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spVC  ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'ReportMemoryLeaksOnShutdown'; Typ: id_Var  ; MyType: @IdArray0[ord( syBoolean    )];                                                         IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coBool ),

            ( Name: 'Reset'      ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spVC  ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Rewrite'    ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spVC  ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'RmDir'      ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Round'      ; Typ: id_Func ; MyType: @IdArray0[ord( syInt64   )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'RunError'   ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Seek'       ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spCC  ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'SeekEoF'    ; Typ: id_Func ; MyType: @IdArray0[ord( syBoolean )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'SeekEoLn'   ; Typ: id_Func ; MyType: @IdArray0[ord( syBoolean )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
//          ( Name: 'SetInOutRes'; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spCCCC]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'SetLastError';Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'SetLength'  ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spVCCC]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'SetString'  ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spVCC ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'SetTextBuf' ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spCVC ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Sin'        ; Typ: id_Func ; MyType: @IdArray0[ord( syExtended)]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'SizeOf'     ; Typ: id_Func ; MyType: @IdArray0[ord( syInteger )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Sleep'      ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Slice'      ; Typ: id_Func ; MyType: @IdArray0[ord( syPointer )]; SubBlock: @cSysPara[enSysPara.spCC  ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
{!}         ( Name: 'Sqr'        ; Typ: id_Func ; MyType: @IdArray0[ord( syInteger )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags: [tIdFlags.ParaMirror]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Sqrt'       ; Typ: id_Func ; MyType: @IdArray0[ord( syExtended)]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags: [tIdFlags.ParaMirror]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'StringOfChar';Typ: id_Func ; MyType: @IdArray0[ord( syString  )]; SubBlock: @cSysPara[enSysPara.spCC  ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags: [tIdFlags.ParaMirror]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
{!}         ( Name: 'Succ'       ; Typ: id_Func ; MyType: @IdArray0[ord( syInteger )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags: [tIdFlags.ParaMirror]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
//          ( Name: 'Swap'       ; Typ: id_Func ; MyType: @IdArray0[ord( syPointer )]; SubBlock: @cSysPara[enSysPara.spVCCC]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
{wegen Verwechslungsgefahr deaktiviert:
            ( Name: 'Text'      ; Typ: id_Type ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coFile ), }
            ( Name: 'Trunc'      ; Typ: id_Func ; MyType: @IdArray0[ord( syInt64   )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Truncate'   ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'TypeHandle' ; Typ: id_Func ; MyType: @IdArray0[ord( syPointer )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'TypeInfo'   ; Typ: id_Func ; MyType: @IdArray0[ord( syPointer )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
//          ( Name: 'TypeOf'     ; Typ: id_Func ; MyType: @IdArray0[ord( syPointer )]; SubBlock: @cSysPara[enSysPara.spVCCC]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
{!}         ( Name: 'UpCase'     ; Typ: id_Func ; MyType: @IdArray0[ord( syInteger )]; SubBlock: @cSysPara[enSysPara.spC   ]; SubLast: @cSysPara[enSysPara.spC] ; IdFlags: [tIdFlags.ParaMirror]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod ),
            ( Name: 'Val'        ; Typ: id_Proc ;                                      SubBlock: @cSysPara[enSysPara.spCVV ]; SubLast: @cSysPara[enSysPara.spV] ; IdFlags: [tIdFlags.IsRekursiv]; IdFlags2: [tIdFlags2.InterfaceSection]; TypeGroup: coMethod )
//          ( Name: 'VarArrayRedim';Typ:id_Proc ;
//          ( Name: 'VarCast'    ; Typ: id_Proc ;
//          ( Name: 'VarClear'   ; Typ: id_Proc ;
//          ( Name: 'VarCopy'    ; Typ: id_Proc ;
//                   YieldProcessor

(*
             { Turbo: (http://direct.turbopascal.org) }
{s.o.}      ( Name: 'Mem'        ; Typ: id_Var  ;         p: ( id_Unbekannt, id_Unbekannt, id_Unbekannt, id_Unbekannt ) ),
            ( Name: 'Input'      ; Typ: id_Var  ;         p: ( id_Unbekannt, id_Unbekannt, id_Unbekannt, id_Unbekannt ) ),
            ( Name: 'Output'     ; Typ: id_Var  ;         p: ( id_Unbekannt, id_Unbekannt, id_Unbekannt, id_Unbekannt ) ),
            *)
           );
{$ENDREGION }

{$REGION '--------- PreParse ---------------' }

(* UnitSystemPreParse *)
procedure UnitSystemPreParse;
begin
  {$IFDEF TraceDx} TraceDx.Send( uSys, 'PreParse' ); {$ENDIF}
  UnitSystem.SubLast           := @IdArray0[cMaxSystemId];
  { ACs auf System-Unit löschen: }
  UnitSystem.AcSet             := [ac_Read];     // ggf im PrepareSys wieder rausnehmen
  UnitSystem.AcList            := nil;
  UnitSystem.LastAc            := nil;
//  UnitSystem.NextId          := nil;           passiert schon im PostParse
  UnitSystem.SubLast           := LastSystemId;   // System-Ids auf die vordefinierten beschränken,
  UnitSystem.TypeGroup         := coSelf;         // kann auf coUnb wechseln, z.B. in GExperts.largefile.pas
  UnitSystem.IdFlags2          := [];
  UnitSystem.IdFlagsTv[tvAll]  := [];
  UnitSystem.IdFlagsTv[_tvFil] := [];
  UnitSystem.OpenCount[tvAll]  := 0;
  UnitSystem.OpenCount[_tvFil] := 0;

  LastSystemId^.NextId         := nil;            // alle neu hinzugekommenen (über "System.xxx") wieder vergessen:
  TypeCount                    := TypeCountSys;

//  beim allerersten PreParse eigentlich nicht notwendig:
    pSysId[syTArray]^.Name := '';                 // wurde für Anzeige auf TArray<T> manipuliert, also neuer String. Explizit freigeben vor überbügeln
    move( cSystem, IdArray0, sizeOf( cSystem ) ); // cSystem -> LaufzeitArray

  UnitSystem.SubBlock := @IdArray0[0]             // Element 0 wurde evtl aus der Liste entfernt, Ptr wieder herstellen
end;

{$ENDREGION }

{$REGION '--------- Init/Exit ---------------' }

(* LoadSystemIds *)
procedure LoadSystemIds;

  function LoadSub( start: word; prev: pIdInfo ): word;
  begin
//    {$IFDEF TraceDx} TraceDx.CallRet( uSys, 'LoadSub', start ); {$ENDIF}
    while true do with IdArray0[start] do begin
      Hash := GetHash( Name );
      include( IdFlags , fromSystemLib  );
      include( IdFlags2, IsUnitSystem );
      if ( Typ = id_Func ) and ( MyType = nil ) then
        asm int 3 end;
      {$IFDEF DEBUG} DebugNr := start; {$ENDIF}
      PrevBlock := prev;
      {  special Flags:
         - isEnumCopy      nächste TypeNt für set of type freihalten
         - isResult        EnterSub  (Parent)
         - isRekursiv      LeaveSub  (LastChild)
         - IdUnused        MyType ist als Offset in MyType als NativeInt hinterlegt. Immer positiv, MyType liegt VOR Verwendung }
      if tIdFlags.IdUnused in IdFlags then
        MyType := @IdArray0[start-NativeInt( MyType )];
      if MyType <> nil then begin
        TListen.CopyTypeInfos( MyType, @IdArray0[start] );
        if Typ in [id_Proc,id_Func] then TypeGroup := coMethod;     // wurde von copytype falsch besetzt
        end;

      if Typ = id_Type then begin
        inc( TypeCountSys );
        TypeNr := pWord( @TypeCountSys )^;
        if tIdFlags.IsEnumCopy in IdFlags then
          inc( TypeCountSys, cSetInc )                   // eine TypeNr für set of <type> freilassen
        end;

      if IsResult in IdFlags then begin
        SubBlock := @IdArray0[start+1];                  // EnterBlock
        start := LoadSub( start+1, @IdArray0[start] );
        SubLast := @IdArray0[start];
        end
      else
        if IsRekursiv in IdFlags then begin
          IdFlags := IdFlags - [tIdFlags.IsEnumCopy, tIdFlags.IsResult, tIdFlags.IsRekursiv, tIdFlags.IdUnused];   // reset all special flags
          Result := start;                               // LeaveBlock
          break
          end;

      NextId  := @IdArray0[start+1];
      IdFlags := IdFlags - [tIdFlags.IsEnumCopy, tIdFlags.IsResult, tIdFlags.IsRekursiv, tIdFlags.IdUnused];   // reset all special flags
      inc( start )
      end;
  end;

begin
  {$IFDEF TraceDx} TraceDx.Call( uSys, 'LoadSystemIds' ); {$ENDIF}
  move( cSystem, IdArray0, sizeOf( cSystem ) );     // cSystem -> LaufzeitArray
  assert( IsRekursiv in LastSystemId^.IdFlags );    // cSystem richtig ausgefüllt?  Mehr Kontrolle einbauen
  LoadSub( 0, @UnitSystem );                        // in Laufzeit-Array komplett verketten
  IdArray0[cMaxSystemId].NextId := nil;
  move( IdArray0, cSystem, sizeOf( cSystem ) )      // und diesen Zustand für Reparse zurück nach cSystem
end;

(* UnitSystemInit *)
function UnitSystemInit: word;
var si: enSysIds;
begin
  {$IFDEF TraceDx} TraceDx.Call( uSys, 'UnitSystemInit' ); {$ENDIF}
  assert( sizeOf( NativeInt ) = sizeOf( pointer));
  UnitSystem.Hash := GetHash( UnitSystem.Name );
  TypeCountSys    := cNoTypeNr;   // 0=cNoTypeNr bleibt aber für nachträglich erkannte Typen und "kein Parameter" in Signatur reserviert
  LastSystemId    := @IdArray0[cMaxSystemId];
  for si := low(enSysIds) to high(enSysIds) do pSysId[si] := @IdArray0[ord(si)];

  { Ids aus System.pas einfügen: }
  LoadSystemIds;
  if pSysId[syExit]^.Name <> cExit then     // Assert führt hier nur zu Runtime Error 217
    ShowMessage( 'Fehler in SystemIds: Statt ' + cExit + ' gefunden: ' + pSysId[syExit]^.Name );
//  include( MainBlock[mbSystem].IdFlags, tIdFlags.fromSystemLib );    // auch hier setzen, damit "System" im Filter nicht falsch gefunden wird
  UnitSystem.PrevBlock:= @MainBlock[mbBlock0];
  UnitSystemInit      := cMaxSystemId + 1
  end;

{$ENDREGION }

end.

