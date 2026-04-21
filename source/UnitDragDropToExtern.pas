
unit UnitDragDropToExtern;

{ --------------------------------------------------------------------------------------------------------------------------------

  Source adapted from
    https://www.delphipraxis.net/205715-drag-drop-von-dateinamen.html    ->  DropSource.zip


  Usage:

  After Drag-Recognition (usually in OnMouseMove with ButtonLeft pressed) call

  1   TControl(Sender).Perform( WM_LBUTTONUP, 0, MakeLong( X, Y) );      // IMPORTANT to stop DragMode after Drop

  2a  DragDropToExtern( 'd:\', ['Test.pas'] );                           // one File,
  2b  DragDropToExtern( 'd:\', TStringDynArray-Var )                     // multiple Filenames in Array
  2c  DragDropToExtern( 'd:\', ['d:\Test.pas'], OnDropped );             // with CallBack-function
  2d  DragDropToExtern( 'd:\', ['d:\Test.pas'], function: boolean        // with anonymous CallBack-function
        begin
          Result := ...
        end);

  The CallBack-function can be used to cancel drop by returning "false" (for example by considering the Drop-Window)

  Result of "DoDragDrop":
  true :  okay
  false:  DragDrop-action cancelled manually by user (<escape> or Click-Right) or by function "OnBeforeDrop"

  -------------------------------------------------------------------------------------------------------------------------------- }

interface

uses
  System.Types,             // TStringDynArray
  System.SysUtils;          // TFunc

function DragDropToExtern( const DragDir: string; const DragFiles: TStringDynArray; OnBeforeDrop: TFunc<boolean> = nil ): boolean;

{ -------------------------------------------------------------------------------------------------------------------------------- }

implementation

uses
  System.Win.ComObj,        // OleCheck
  Winapi.ShlObj,            // pItemIdList
  Winapi.Windows,           // BOOL
  Winapi.ActiveX,           // IDropSource
  System.IOUtils;           // TPath

type
  TDragDrop = class( TInterfacedObject, IDropSource )
                strict private
                  function QueryContinueDrag( fEscapePressed: BOOL; grfKeyState: Longint ): HResult; stdcall;
                  function GiveFeedback( dwEffect: Longint ): HResult; stdcall;
              end;

var
  VDragDrop: TDragDrop;
  CallBack : TFunc<boolean>;

function DragDropToExtern( const DragDir: string; const DragFiles: TStringDynArray; OnBeforeDrop: TFunc<boolean> = nil ): boolean;
var Effect    : DWORD;
    DataObject: IDataObject;

  function GetFileAsDataObject: IDataObject;
  type
    PArrayOfPItemIDList = ^TArrayOfPItemIDList;
    TArrayOfPItemIDList = array[0..MaxWord] of PItemIDList;
  var
    Malloc      : IMalloc;
    Root        : IShellFolder;
    FolderPid   : PItemIDList;
    Folder      : IShellFolder;
    p           : PArrayOfPItemIDList;
    chEaten     : ULONG;
    dwAttributes: ULONG;
    FileCount,i : Integer;
  begin
    Result    := nil;
    FileCount := high( DragFiles ) + 1;
    if ( FileCount = 0 ) or ( FileCount > high( TArrayOfPItemIDList )) then exit;
    OleCheck( SHGetMalloc( Malloc ));
    OleCheck( SHGetDesktopFolder( Root ));
    OleCheck( Root.ParseDisplayName( 0, nil, PWideChar( WideString( DragDir )), chEaten, FolderPid, dwAttributes ));
    try
      OleCheck( Root.BindToObject(FolderPid, nil, IShellFolder, Pointer( Folder )));
      p := AllocMem( SizeOf(PItemIDList) * FileCount );
      try
        for i := 0 to FileCount - 1 do
          OleCheck( Folder.ParseDisplayName( 0, nil, PWideChar( WideString( TPath.GetFileName( DragFiles[i] ))), chEaten, p^[i], dwAttributes ));
        OleCheck( Folder.GetUIObjectOf( 0, FileCount, p^[0], IDataObject, nil, Pointer( Result )));
      finally
        for i := 0 to FileCount - 1 do
          if p^[i] <> nil then
            Malloc.Free( p^[i] );
        FreeMem( p )
      end;
    finally
      Malloc.Free( FolderPid )
    end;
  end;

begin
  DataObject := GetFileAsDataObject();
  Effect     := DROPEFFECT_NONE;
  CallBack   := OnBeforeDrop;
  Result     := WinAPI.ActiveX.DoDragDrop( DataObject, VDragDrop, Integer( DROPEFFECT_COPY ), Integer( Effect ) ) = DRAGDROP_S_DROP
end;

function TDragDrop.QueryContinueDrag( fEscapePressed: BOOL; grfKeyState: Longint ): HResult; stdcall;
begin
  if fEscapePressed or ( grfKeyState and MK_RBUTTON = MK_RBUTTON ) then
    Result := DRAGDROP_S_CANCEL
  else
    if grfKeyState and MK_LBUTTON = 0
      then Result := DRAGDROP_S_DROP
      else Result := S_OK;

  if ( Result = DRAGDROP_S_DROP ) and assigned( CallBack ) and not CallBack then
    Result := DRAGDROP_S_CANCEL
end;

function TDragDrop.GiveFeedback( dwEffect: Longint ): HResult; stdcall;
begin
  Result := DRAGDROP_S_USEDEFAULTCURSORS
end;

initialization
  OleInitialize( nil );
  VDragDrop := TDragDrop.Create;

finalization
  OleUninitialize;
  VDragDrop.Free

end.

