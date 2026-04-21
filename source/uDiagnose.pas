
unit uDiagnose;
{$INCLUDE _CompilerOptions.pas}
{ $UNDEF TraceDx}
{ $DEFINE Rect}

interface

type
  TDiagnose = record
                class function SaveBlocksToFile: boolean; static;
                class function CheckTree: boolean; static;
              end;


implementation

uses
  System.Classes,
  System.IOUtils,
  System.SysUtils,
  System.Types,
  System.Math,
  Vcl.Dialogs,
  {$IFDEF TraceDx} uTraceDx, {$ENDIF}
  uBlock,
  uViewer,
  uGlobalData;


function AreFilesEqual( const FileNameA, FileNameB: string; BlockSize: Integer = 4096 ): Boolean;
var
  a: TBytes;
  b: TBytes;
  cntA: Integer;
  cntB: Integer;
  readerA: TStream;
  readerB: TStream;
begin
  Result := False;
  readerA := TFileStream.Create(FileNameA, fmOpenRead);
  try
    readerB := TFileStream.Create(FileNameB, fmOpenRead);
    try
      SetLength(a, BlockSize);
      SetLength(b, BlockSize);
      repeat
        cntA := readerA.Read(a, BlockSize);
        cntB := readerB.Read(b, BlockSize);
        if ( cntA <> cntB ) or not CompareMem(@a[0], @b[0], cntA) then Exit
      until cntA < BlockSize;
      Result := True
    finally
      readerB.Free
    end;
  finally
    readerA.Free
  end;
end;

class function TDiagnose.SaveBlocksToFile: boolean;
const cSepa = ' | ';
      cFlags: array[tBlockFlags] of char = ( 'c', 'A', 'y', 'B', 't', 'e', 'V', '7' );
var fn: string;
    f : TextFile;
begin
  {$IFDEF TraceDx} TraceDx.Send( 'TDiagnose.SaveBlocksToFile' ); {$ENDIF}
  if Source.Proc = EmptyStr
    then fn := Source.Name                     + '.tree'
    else fn := Source.Name + '.' + Source.Proc + '.tree';
  AssignFile( f, fn);
  Rewrite( f );
  {$IFDEF Rect}
  WriteLn( f, ' Nr  L   Typ               Flags   prev Next Sub      Ze  Sp   Ze  Sp     L    T    R    B     z   Z  Then   Text'   );
  WriteLn( f, '-------------------------------------------------------------------------------------------------------------------' );
  {$ELSE}
  WriteLn( f, ' Nr  L   Typ               Flags   prev Next Sub      Ze  Sp   Ze  Sp    z   Z  Then   Text'   );
  WriteLn( f, '---------------------------------------------------------------------------------------------' );
  {$ENDIF}

  TBlock.ForAllBlocks( function( p: pBlockInfo ): boolean
    var s: string;
        j: integer;

    function Ptr( p: pBlockInfo ): string;
    begin
      if p = nil then result := '-' else result := IntToStr( p^.Nr )
    end;

    begin
      Result := false;
      with p^ do begin
        s := '        ';
        for j := ord( low( tBlockFlags )) to ord( high( tBlockFlags )) do
          if tBlockFlags( j ) in Flags then s[j] := cFlags[tBlockFlags( j )];
        write  ( f, Format( '%3d%3d  %-16.16s   %s  %-4.4s %-4.4s %-4.4s', [Nr, Level, StringOfChar( ' ', Min( Level, 12 ) ) + TBlock.getBlockTyp( Typ ).Substring( 2 ), s, ptr( prev ), ptr( next ), ptr( Sub )] ));
        {$IFDEF Rect}
        write  ( f, Format( ' %4d%4d %4d%4d %5d%5d%5d%5d  %4d%4d%5d', [TxtStart.ze, TxtStart.sp, TxtEnde.ze, TxtEnde.sp, Rect.Left, Rect.Top, Rect.Right, Rect.Bottom, TxtZeilen, SubZeilen, ThenBreite] ));
        {$ELSE}
        write  ( f, Format( ' %4d%4d %4d%4d %4d%4d%5d', [TxtStart.ze, TxtStart.sp, TxtEnde.ze, TxtEnde.sp, TxtZeilen, SubZeilen, ThenBreite] ));
        {$ENDIF}
        case TxtZeilen of
          0:   s := '';
          1:   s := Source.Lines[TxtStart.ze].Substring( TxtStart.sp,  TxtEnde.sp - TxtStart.sp + 1 )
          else s := Source.Lines[TxtStart.ze].Substring( TxtStart.sp );
               for j := TxtStart.ze + 1 to TxtEnde.ze - 1 do s := s + cSepa + Source.Lines[j];
               if ( TxtStart.ze <> TxtEnde.ze ) and ( TxtEnde.ze >= 0 ) then
                 s := s + cSepa + Source.Lines[TxtEnde.ze].Substring( 0, TxtEnde.sp + 1 )
          end;
        writeln( f, cSepa + StringOfChar( ' ', Level ) + s )
        end
      end );

  CloseFile( f );

  Result := true;
  if TFile.Exists( fn + '.OK' ) then
    if not AreFilesEqual( fn, fn + '.OK' ) then begin
      {$IFDEF TraceDx} TraceDx.Send( 'TreeCompare', 'Error' ); {$ENDIF}
      Result := false
      end
end;

class function TDiagnose.CheckTree: boolean;

  function CheckSubTree( p: pBlockInfo ): boolean;
  begin
    Result := false;
    while p <> nil do begin
      if ( p^.Typ = btFree ) or
         ( p^.Prev^.Typ = btFree )  or
         (( p^.SubInfo.Cursor.pStart <> nil ) and ( p^.SubInfo.Cursor.pStart^.Typ = btFree )) or
         (( p^.SubInfo.Cursor.pEnde  <> nil ) and ( p^.SubInfo.Cursor.pEnde ^.Typ = btFree ))
         then begin
        {$IFDEF TraceDx} TraceDx.Send( 'CheckSubTree-Error', p^.Nr ); {$ENDIF}
        ShowMessage( 'CheckSubTree-Error ' + p^.Nr.ToString );
        Result := true
        end;
      if p^.Sub <> nil then CheckSubTree( p^.Sub );
      p := p^.Next
      end
  end;
begin
  Result := CheckSubTree( TBlock.getByIndex( 1 )) and   // 0 nicht weil hat keinen prev
            { Cursor auch prüfen: }
            (( CursorBlock.pStart = nil ) or ( CursorBlock.pStart^.Typ <> btFree )) and
            (( CursorBlock.pEnde  = nil ) or ( CursorBlock.pEnde ^.Typ <> btFree ))
end;

end.

