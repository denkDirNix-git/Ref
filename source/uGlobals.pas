
unit uGlobals;

{$INCLUDE _CompilerOptions.pas}
{ $UNDEF TraceDx}

interface

const
  cProgName       = 'Ref';
  cVersion        = '2.0';
  cDebug          = {$IFDEF DEBUG} ' [DEBUG]' {$ELSE} '' {$ENDIF};
  cSubVersion     = '.0';
  cPlusMinus      : array[boolean] of char = ( '-','+' );    // false -> -      true -> +

type
  tError    = ( errActFileOpen,            // diese Fehler zeigen eine Meldung
                errSourceFile,
                errHelpFile,               // und kehren zurück zum Aufrufer
                errInternal,
                errProgIni,
                errFileIni,
                errDirExist,
                errPrepareTree,
                errSaveTree,
                // ab hier Parser-Errors:
                errLineCount,
                errBadIdType,              // diese Fehler erzeugen eine Exception
                errAcStackOverflow,        // die abgefangen werden muss
                errIdStackOverflow,
                errOverloadCand,
                errSyntaxError,
                errSystemPas,
                errDirektive,
                errUnexpectedEOF,
                errNoCallingFile,
                errFileNotFound,
                errNotImplemented,
                errFinalChecks
                );

procedure Error ( e: tError; const s1: string = ''; const s2: string = ''; i: integer = 0 );

implementation

uses
  {$IFDEF TraceDx} uTraceDx, {$ENDIF}
  Vcl.Dialogs,
  System.IOUtils,
  System.SysUtils,
  ufError;

const cErrorString: array[tError] of string =
         ( 'not possible, crtitical work in progress',
           'Source "%s" not found',
           'Helpfile "%s" not found',
           'language not found',
           'Error in ProgIni "%s" reading key "%s"',
           'Error in ProjectIni "%s" reading key "%s"',
           'Directory "%s" not found',
           'PrepareTree',
           'SaveTree',
         // ab hier Parser-Errors:
           'Too many lines:' + slineBreak + '%s',
           'Bad Identifier-Typechange: "%s" -> "%s"',
           'AcStack-Overflow',
           'IdStack-Overflow',
           'No Overload for "%s"',
           'SyntaxError' + sLineBreak + 'Expect: %s' + sLineBreak + 'Found : %s',
           'File "%s" not found',
           'Compiler-Directive expected, found "%s"',
           'UnexpectedEOF in %s of file "%d"',
           'No calling file',
           'Include-file "%s" not found',
           'Not Implemented yet',
           'FinalChecks'
           );


type TUserException = class( Exception );

procedure Error ( e: tError; const s1: string = ''; const s2: string = ''; i: integer = 0 );
var str: string;
begin
  str := Format( cErrorString[e], [s1,s2,i] );
  {$IFDEF TraceDx} TraceDx.Send( '!!! Error', str ); {$ENDIF}
  frmError.lblError.Caption := str;
  {$IFNDEF RefBatch}
  frmError.ShowModal;
  {$ENDIF}
  if e >= tError.errBadIdType then
    raise TUserException.Create( str )
end;

end.
