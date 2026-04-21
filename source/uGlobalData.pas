
unit uGlobalData;
{$INCLUDE _CompilerOptions.pas}
{ $UNDEF TraceDx}

interface

uses
  System.UITypes,
  System.Types;

const
  cVersion        = '2.0.0' + {$IFDEF DEBUG} ' [Debug]' {$ELSE} ' ' {$ENDIF};
  cBlockListChunk = 1023;


type
  tBlockIndex     = longword;
  tBlockTyp       = ( btNil, btFree,
                      btSubViewFix, btSubViewAuto, btSubViewTmp,
                      btClass,
                      btMain, btUnit, btProc, btInitial, btFinal,
                      btBegin, btAsm, btTry, btExcept, btFinally, btOn, btExceptElse,
                      btStm, btDummy, btDummyAbs, btComment,
                      btIf, btThen, btElse,
                      btFor, btWhile, btWith,
                      btRepeat, btUntil,
                      btCase, btCaseSel, btCaseElse, btDblPoint, btCaseStm, btCaseEnd,
                      btEnd, btSemi,
                      btClose );

  tBlockFlags     = ( flCompound, fl_AutoSubFix{beim Scan automatisch angelegter SubView}, flAnonymProc, flDoubleBegin{X-Tools-Macke}, flEmptyThen, flEmptyElse, flConstTypeVar, fl_7 );
  tBlockFlagsRun  = ( flHighlight, flVisible, fl_r2, fl_r3, fl_r4, fl_r5, fl_r6, fl_r7 );
  tBlockFlagSet   = set of tBlockFlags;
  tBlockFlagSetRun= set of tBlockFlagsRun;

const
   btDontShow     = [btThen, btElse];
   btSubView      = [btSubViewFix, btSubViewAuto, btSubViewTmp];


type
  tSourcePosIdx   = integer;
  tSourcePos      = packed record ze, sp: tSourcePosIdx end;
  tLineCount      = integer;
  tContent        = ( coStatement, coComment, coCommentIsLine{ggf zusätzlich zu coComment} );


  pBlockInfo      = ^tBlockInfo;
  tCursorBlock    = record pStart, pEnde: pBlockInfo end;

  tBlockInfo      = packed record
                      Nr        : tBlockIndex;                    // Numerierung, nur für Diagnose
                      Level     : byte;                           // Schachtelung
                      Typ       : tBlockTyp;
                      Flags     : tBlockFlagSet;
                      FlagsRun  : tBlockFlagSetRun;
                      Next,                                       // selbe Ebene
                      Prev,                                       // drüber
                      Sub       : pBlockInfo;                     // drunter
                      TxtStart,
                      TxtEnde   : tSourcePos;
                      TxtZeilen,                                  // ganze Zeilen von TxtStart bis -Ende
                      SubZeilen : tLineCount;                     // über alle Subs: ganze Zeilen incl. mit Korrektur für Ausblendungen
  {todo:}             SubCharCnt: cardinal;                       // über alle Subs: Anzahl Zeichen
  {todo:}             MaxLineLen: tSourcePosIdx;                  // über alle Subs: längste Zeile
                      Rect      : tRect;                          // Rechteck
                      ThenBreite: integer;                        // nur btIf: der then-Block nimmt diesen Prozenzsatz der if-Breite ein (SubZeilen-abhängig)
                      SubInfo   : packed record                   // nur btSubViewAnchor: zum Setzen bei Wiedereintritt oder Rückkehr
                                    ScrollPos: integer;         //   dies war vorm LeaveSub die ScrollBar-Position
                                    Cursor   : tCursorBlock;    //                          ... und der pCursorBlock
                                    Header   : string           //   automatisch generierter oder eingegebener Header-Text dieser Ausblendung
                                  end
                    end;

  tBlockListChunk = array[0..cBlockListChunk] of tBlockInfo;

  tLineInfo       = packed record
                      NonBlank1 : tSourcePosIdx;                 // das erste Statement- oder Comment-Zeichen dieser Zeile
                      Content   : set of tContent
                    end;

  tLanguage       = ( lgUnknown, lgPascal, lgPascal86, lgC, lgJava, lgBasic, lgBatch );
  tTextArt        = ( artUnknown, artStatement, artComment, artKeyword, artSearch );


var
  Source          : record
                      Name,                             // ohne Directory (Source-Dir ist immer CurrentDir )
                      Proc     : string;
                      Caption  : string;
                      Date     : TDateTime;
                      Lang     : tLanguage;
                      Lines    : TArray<string>;
                      LineInfo : array of tLineInfo;
                      StartLine,
                      EndLine  : integer                // Bereichseingrenzung für Suche wenn nur eine proc gescannt wurde
                    end;

  OptionBatchMode : boolean = false;

  clFontTextArt   : array[tTextArt] of tColor = ( TColorRec.Gray{unbekannt}, TColorRec.Black{clStatement}, TColorRec.Green{clComment}, TColorRec.Blue{clKeyWord}, TColorRec.Red{artSearch} );
  clKeywordMini   : tColor = TColorRec.Lightblue;
  clRectLines     : tColor = $C0C0C0;  //   TColorRec.Gray;
  clRectLinesProc : tColor = TColorRec.Black;
  clRectLinesCurs : tColor = TColorRec.Navy;

  clBackground    : tColor = TColorRec.White;
  clHighlightBack : tColor = $E8E8FF;  //   TColorRec.Lightsalmon;

  clSubViewFont   : tColor = TColorRec.Black;
  clSubViewBack   : tColor = TColorRec.Lightgoldenrodyellow;


type
  tErrorType = ( erFileNotFound, erNotSupported, erScanner, erProcNotFound, erLineIsNotProc, erStructSize );

procedure Error( e: tErrorType; s: string = '' );


implementation

uses
  System.SysUtils,
  {$IFDEF TraceDx} uTraceDx, {$ENDIF}
  Vcl.Forms,
  Vcl.Dialogs;


procedure Error( e: tErrorType; s: string = '' );
const cErrMessage: array[tErrorType] of string = (
        'File "%s" not found',
        'not supported',
        'Scanner/Parser Error (may be $IF(DEF)-Problem)' + slineBreak + 'Line / Row / ClassNesting / Block  =  %s',
        'Proc "%s" not found',
        'Line %s constains no Proc-Declaration',
        'out of memory for this size' );
begin
  {$IFDEF TraceDx} TraceDx.Send( 'Error', Format( cErrMessage[e], [s] ) ); {$ENDIF}
  ShowMessage( Format( cErrMessage[e], [s] ));
  {$IFDEF DEBUG} ReportMemoryLeaksOnShutdown := false; {$ENDIF}
  if assigned( Application.MainForm ) then
    Application.MainForm.OnResize := nil;
  halt
end;

end.

