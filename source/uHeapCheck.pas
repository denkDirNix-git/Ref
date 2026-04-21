
unit uHeapCheck;

{$INCLUDE _CompilerOptions.pas}
{$UNDEF TraceDx}

interface

type
  tHeapCheck = record
                 procedure new    ( p: pointer; size: longword );
                 procedure dispose( p: pointer; size: longword );
               end;

var
  HeapCheck:  tHeapCheck;


implementation
uses
  {$IFDEF TraceDx} TraceDx, {$ENDIF}
  Vcl.Dialogs,
  System.SysUtils,
  System.Classes;

type
  tHeapElement = record
                   Adress: pointer;
                   Size  : longword;
                   used  : boolean
                 end;

  pHeapElement = ^theapElement;

var
  Heap: TList;
  Len : TList;

procedure tHeapCheck.new( p: pointer; size: longword );
//var h: pHeapElement;
var i: integer;
begin
  {$IFDEF TraceDx} TTraceDx.Send( 'tHeapCheck.new', integer( p ).ToHexString + ' ' + size.ToString ); {$ENDIF}
  i := Heap.IndexOf( p );
  if i <> -1
    then ShowMessage( 'Pointer exists already' );
//  new( h );
//  h^.Adress := p;
//  h^.Size   := 0;
//  h^.used   := true;
//  Heap.Add( h )
  Heap.Add( p );
  Len.Add( pointer( size ))
end;

procedure tHeapCheck.dispose( p: pointer; size: longword );
var i: integer;
begin
  {$IFDEF TraceDx} TTraceDx.Send( 'tHeapCheck.dispose', integer( p ).ToHexString ); {$ENDIF}
  i := Heap.IndexOf( p );
  if i = -1 then
    ShowMessage( 'dispose unknown Pointer' )
  else
    if integer( Len[i] ) = size then begin
      Heap.Delete( i );
      Len .Delete( i )
      end
    else
    ShowMessage( 'dispose wrong size' )
end;


initialization
  Heap := TList.Create;
  Len  := TList.Create;

finalization
  if Heap.Count > 0 then
    ShowMessage( 'Heap-Leaks: ' );
  Heap.Free;
  Len .Free

end.

