unit UtilitiesDx;

{$UNDEF TraceDx}

interface

uses
  WinApi.Windows,
  System.Types,
  System.SysUtils,
//    System.UITypes,
  System.Classes,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Graphics,
  Vcl.Menus,
  Vcl.Forms;

  type
    TKeyboard  = record
                   public
                     class function KeyAsync( Key: integer ): boolean; static;
                 end;

    TMyApp     = record
                   public
                     const cSelf = 'DenkDirNix';
                     class procedure Init( const aProgName, aVersion, aVersionMin: string ); static;
                     class var
                       DirExe,
                       DirUser: string;
                       ProgName,
                       Version: string
                 end;

    TIni       = record
                   public
                     const cFormsIni = 'Forms';
                     const cIni       = '.ini';
                     class procedure ReadForm ( const f: TForm ); static;
                     class procedure WriteForm( const f: TForm ); static;
                   private
                     const
                       cPixels    = 'PixelsPerInch';
                       cStyleName = 'StyleName' ;
                       cColor     = 'Color'     ;
                       cFontName  = 'FontName'  ;
                       cFontColor = 'FontColor' ;
                       cFontHeight= 'FontHeight';
                       cLeft      = 'Left'      ;
                       cTop       = 'Top'       ;
                       cWidth     = 'Width'     ;
                       cHeight    = 'Height'    ;
                       cMaximized = 'Maximized' ;

                       cWriteMax  = 9;
                       cCount     = 'Count' ;
                       cItem      = 'Item' ;
                       cPPI       = 120;            // PixelsPerInch auf meinem Entwicklungsrechner
                   public
                     class function  ReadStrList ( const Filename, Key: string; const StrList: TStrings ): integer; static;
                     class procedure WriteStrList( const Filename, Key: string; const StrList: TStrings; Count: integer = cWriteMax ); static;
                 end;

    TDocumentation = record
                       class procedure SaveMainMenuCaptions( mm: TMainMenu ); static;
                     end;

    TCrypto        = record
                       public
                         class function Encode64( const s: string ): string; static;
                         class function Decode64( const s: string ): string; static;
                         class procedure Encode(   var s: TBytes ); static;
                         class procedure Decode(   var s: TBytes ); static;
                       private
                         const
                           Code64 = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+/';
                     end;

    TDebug         = record
                       public
                         class procedure DebugBreak( Trigger: boolean = true ); static;
                     end;

    TUserHint      = record
                       public
                         class procedure Show ( b: TBalloonHint; const Title, Description: string; const Pos: TPoint ); static;
                         class procedure Clear( b: TBalloonHint ); static;
                     end;

    TDimmed        = record
                       public
                         class function ShowModalDimmed(aForm: TForm; aParentForm: TForm; AlphaBlendValue: Integer = 100; BackColor: TColor = clGray; Centered: Boolean = True): TModalResult; static;
                     end;

    TGrowList<T>   = record          // benötigt für Typ-Gleichheit im Nutzer zum Beispiel die Deklaration
                       public        // pServerLineData  = TGrowList< tServerLineData >.pBaseType;   statt   = ^tServerLineData
                         type        pBaseType = ^T;
                         constructor Create( aChunkSize: integer );
                         function    get: pBaseType;
                         procedure   free( const Mem: pBaseType );
                         procedure   Destroy;
                       private
                         type        pFree    = ^tFree;                  // nur für
                                     tFree    = record Next: pFree end;  //         Verwaltung FreiListe
                                     tChunk   = array of T;              // BasisArray
                                     pChunk   = ^tChunk;
                                     tChunks  = array of pChunk;
                         var         ChunkSize: integer;
                                     Chunks   : tChunks;                 // ZeigerArray
                                     Chunk0   : tChunk;                  // erstes Chunk-Element ist sofort da
                                     Used     : integer;                 // 0..ChunkSize
                                     FreeList : pFree
                     end;

//    TLocalTimer   = class
//                      procedure MyTimer;
//                    private
//                      Timer : TTimer;
//                    end;

implementation

uses
  System.IniFiles,
  {$IFDEF TraceDx}
  TraceDx,
  {$ENDIF }
  WinAPI.DwmApi,
  WinApi.ShellAPI,
  Vcl.Dialogs,
  System.IOUtils;



//procedure TLocalTimer.MyTimer;
//begin
// Timer := TTimer.Create(nil);
// Timer.OnTimer := Form1.TimerEvent;
// Timer.Interval := 1000;
// Timer.Enabled := True;
//end;

{$REGION 'TGrowList'}

constructor TGrowList<T>.Create( aChunkSize: integer );
begin
  assert( sizeOf( T ) >= sizeOf( pFree ), 'sizeOf( TMemChunc.T ) zu klein' );
  ChunkSize := aChunkSize;                           // jedes BasisArray hat diese Anzahl Elemente
  SetLength( Chunk0, ChunkSize );                    // als erstes z.B. mal das sofort vorhandene Chunk0-Array
  SetLength( Chunks, 1         );                    // ... auf das ZeigerArray-
  Chunks[0] := @Chunk0;                              // ... -Element 0 zeigt
  Used      := 0;
  FreeList  := nil
end;

procedure TGrowList<T>.Destroy;
var i: integer;
begin
  for i := 1 to high( Chunks ) do
    dispose( Chunks[i] )
end;

procedure TGrowList<T>.free( const Mem: pBaseType );
begin
  pFree( Mem )^.Next := FreeList;
  FreeList := pFree( Mem )
end;

function TGrowList<T>.get: pBaseType;
var Hi: integer;
begin
  if FreeList = nil then begin
    Hi := high( Chunks );
    if Used = ChunkSize then begin                     // aktuelles ZeigerArray aufgebraucht ?
      SetLength( Chunks, Hi+2 );                       // Platz für zusätzlichen Zeiger holen
      inc( Hi );
      new( Chunks[Hi] );                               // neues BasisArray holen
      SetLength( Chunks[Hi]^, ChunkSize );             // diesem auch die Standard-Größe geben
      Used := 0                                        // auf erstes Element zeigen
      end;
    Result := @(Chunks[Hi]^[Used]);                    // aktuelles Element liefern
    inc( Used )                                        // aktuelles := nächstes
    end
  else begin
    Result   := pBaseType( FreeList );                 // es sind noch wieder freigegebene Elemente vorhanden
    FreeList := FreeList^.Next;                        // jetzt eines weniger
    FillChar( Result^, sizeOf( T ), 0 )                // Element genullt zurückgeben
    end
end;

{$ENDREGION TGrowList}

{$REGION 'Keyboard'}
class function TKeyboard.KeyAsync( Key: integer ): boolean;
{ VK_CONTROL, VK_Shift, VK_Menu=Alt, ...}
begin
  Result := GetAsyncKeyState( Key ) and $8000 = $8000
end;
{$ENDREGION Keyboard}

{$REGION 'TMyApp'}

/// <remarks>
/// Kann schon in initialization aufgerufen werden
/// </remarks>
class procedure TMyApp.Init( const aProgName, aVersion, aVersionMin: string );
begin
  {$IFDEF TraceDx} TTraceDx.Call( 'TMyApp.Init', aProgName, aVersion ); {$ENDIF}
  ProgName := aProgName;
  Version  := aVersion;

  DirExe   := ExtractFilePath( Application.ExeName );
  if not DirExe.EndsWith( TPath.DirectorySeparatorChar ) then
    DirExe := DirExe + TPath.DirectorySeparatorChar;

  DirUser  := TPath.GetHomePath + TPath.DirectorySeparatorChar +
                cSelf           + TPath.DirectorySeparatorChar +
                ProgName        + TPath.DirectorySeparatorChar;
  TDirectory.CreateDirectory( DirUser );
end;

{$ENDREGION TMyApp}

{$REGION 'TIni'}

class procedure TIni.ReadForm( const f: TForm );
var IniReg    : TMemIniFile;
    LastPPI,
    MonitorPPI: integer;
begin
  {$IFDEF TraceDx} TTraceDx.Call( 'TIni.ReadForm', f.Name, ', Design-PPI = ' + TIni.cPPI.ToString ); {$ENDIF}
  IniReg := TMemIniFile.Create( TMyApp.DirUser + cFormsIni + cIni );

  LastPPI       := IniReg.ReadInteger( f.Name, cPixels    , f.PixelsPerInch );

  f.LockDrawing;
  if not IsLibrary then
  f.StyleName   := IniReg.ReadString ( f.Name, cStyleName , f.StyleName     );
  f.Color       := IniReg.ReadInteger( f.Name, cColor     , f.Color         );

  if not IsLibrary then
  f.Font.Name   := IniReg.ReadString ( f.Name, cFontName  , f.Font.Name     );
  f.Font.Color  := IniReg.ReadInteger( f.Name, cFontColor , f.Font.Color    );
  f.Font.Height := IniReg.ReadInteger( f.Name, cFontHeight, f.Font.Height   );

  if IniReg.SectionExists( f.Name ) then f.Position := poDesigned;      // bei poMainFormCenter würde Top usw sonst ignoriert, wichtig für ersten Aufruf

  f.SetBounds(     IniReg.ReadInteger( f.Name, cLeft      , f.Left          ),
                   IniReg.ReadInteger( f.Name, cTop       , f.Top           ),
                   IniReg.ReadInteger( f.Name, cWidth     , f.Width         ),
                   IniReg.ReadInteger( f.Name, cHeight    , f.Height        ));

  { Nach SetBounds() stimmt zwar die Abmessungen aber das Form.CurrentPPI evtl nicht (Vcl-Fehler).                }
  { Deshalb die Vcl-verwalteten Längen für CurrentPPI anpassen(!) und danach mit ScaleForPpi() wieder korrigieren }
  f.Width       := MulDiv( f.Width      , f.CurrentPPI, LastPPI );
  f.Height      := MulDiv( f.Height     , f.CurrentPPI, LastPPI );
  f.Font.Height := MulDiv( f.Font.Height, f.CurrentPPI, LastPPI );

  MonitorPPI    := Screen.MonitorFromRect( Rect( f.Left, f.Top, f.Left+f.Width, f.Top+f.Height)).PixelsPerInch;
  if MonitorPPi <> LastPPI then begin  // sonst wird im Scale die Größe auf die vorigen Werte gesetzt (die es hier noch gar nicht gibt)
    if assigned( f.OnBeforeMonitorDpiChanged ) then f.OnBeforeMonitorDpiChanged( f, cPPI , MonitorPPI );   // auch nicht vor der Vcl verwaltete Größen anpassen
    f.ScaleForPPI( MonitorPPI );
    if assigned( f.OnAfterMonitorDpiChanged  ) then f.OnAfterMonitorDpiChanged(  f, cPPI , MonitorPPI );   //  "
    end;

  f.MakeFullyVisible( nil );
  if f.Top < 10 then f.Top := 10;

  if IniReg.ReadBool( f.Name, cMaximized , f.WindowState = TWindowState.wsMaximized )
    then f.WindowState := TWindowState.wsMaximized
    else f.WindowState := TWindowState.wsNormal;

  f.UnlockDrawing;
  IniReg.Free
end;

class procedure TIni.WriteForm( const f: TForm );
var IniReg: TMemIniFile;
begin
  IniReg := TMemIniFile.Create( TMyApp.DirUser + cFormsIni + cIni );

  IniReg.WriteInteger( f.Name, cPixels    , f.CurrentPPI     );
  IniReg.WriteString ( f.Name, cStyleName , f.StyleName      );
  IniReg.WriteString ( f.Name, cColor     , '$' + integer( f.Color).ToHexString );
  IniReg.WriteString ( f.Name, cFontName  , f.Font.Name      );
  IniReg.WriteString ( f.Name, cFontColor , '$' + integer( f.Font.Color).ToHexString );
  IniReg.WriteInteger( f.Name, cFontHeight, f.Font.Height    );
  IniReg.WriteInteger( f.Name, cLeft      , f.Left           );
  IniReg.WriteInteger( f.Name, cTop       , f.Top            );
//  IniReg.WriteInteger( f.Name, cWidth     , f.Width  * f.PixelsPerInch div IniPPI );
  IniReg.WriteInteger( f.Name, cWidth     , f.Width          );
  IniReg.WriteInteger( f.Name, cHeight    , f.Height         );
  IniReg.WriteInteger( f.Name, cMaximized , ord( f.WindowState = TWindowState.wsMaximized ) );

  IniReg.Free
end;

class function TIni.ReadStrList( const Filename, Key: string; const StrList: TStrings ): integer;
var IniReg: TMemIniFile;
begin
  IniReg := TMemIniFile.Create( TMyApp.DirUser + Filename + cIni );
  StrList.Clear;
  Result := IniReg.ReadInteger( Key, cCount, 0 );
  for var i := 1 to Result do
    StrList.Add( IniReg.ReadString( Key, cItem + (i-1).ToString, '' ));
  IniReg.Free
end;

class procedure TIni.WriteStrList( const Filename, Key: string; const StrList: TStrings; Count: integer = cWriteMax );
var IniReg: TMemIniFile;
begin
  if Count > StrList.Count then
    Count := StrList.Count;
  IniReg := TMemIniFile.Create( TMyApp.DirUser + Filename + cIni );

  IniReg.WriteInteger( Key, cCount, Count );
  if Count > 0 then
    for var i := 0 to Count-1 do
      IniReg.WriteString( Key, cItem + i.ToString, StrList[i]);
  IniReg.Free
end;
{$ENDREGION TIni}

{$REGION 'TDocumentation'}

{ Saves MainMenu-Items as Text in File, for documentation only. Called by Ctrl-Shift-F12 }
class procedure TDocumentation.SaveMainMenuCaptions( mm: TMainMenu );
var t: TFileStream;
    f,s: string;
    r,c: word;
    ende: boolean;
    m : TMenuItem;
begin
  if not assigned( mm ) then begin
    ShowMessage( 'Menu (noch) nicht erzeugt' );
    exit
    end;

  f := '___Menu.' + TPath.GetFileNameWithoutExtension( Application.ExeName ) + '.txt';
  t := TFileStream.Create( f, fmCreate );

  for c := 0 to mm.Items.Count - 1 do begin
    s := mm.Items[c].Caption.Replace( '&', '' );
    t.Write( s[low(string)], length( s )*2 );
    t.WriteData( #9 )
    end;

  r := 0;
  repeat
    ende := true;
    t.WriteData( #13 );
    for c := 0 to mm.Items.Count - 1 do begin
      if mm.Items[c].Count > r then begin
        ende := false;
        s := mm.Items[c][r].Caption.Replace( '&', '' );
        t.Write( s[low(string)], length( s )*2 );
        end;
      t.WriteData( #9 )
      end;
    inc( r )
  until ende;
  t.Free;
  ShowMessage( 'Menu "' + f + '" erzeugt' )
end;

{$ENDREGION TDocumentation}

{$REGION 'TDebug'}

{$IFDEF CPUX64}
procedure X64AsmBreak;
asm
  .NOFRAME
  INT 3
end;
{$ENDIF CPUX64}

class procedure TDebug.DebugBreak( Trigger: boolean = true );
begin
  {$IFDEF DEBUG}
  if Trigger and ( DebugHook <> 0 ) then
    {$IFDEF CPUX64}
      X64AsmBreak
    {$ELSE}
      asm int 3 end
    {$ENDIF CPUX64}
  {$ENDIF DEBUG}
end;
{$ENDREGION TDebug}

{$REGION 'TCrypto'}
class function TCrypto.Encode64( const s: string): string;
var
  I: Integer;
  a: Integer;
  x: Integer;
  b: Integer;
begin
  Result := '';
  a := 0;
  b := 0;
  for I := 1 to Length(S) do begin
      x := Ord(S[I]);
    b := b * 256 + x;
    a := a + 8;
    while a >= 6 do begin
      a := a - 6;
      x := b div (1 shl a);
      b := b mod (1 shl a);
      Result := Result + Code64[x + 1];
    end;
  end;
  if a > 0 then begin
      x := b shl (6 - a);
    Result := Result + Code64[x + 1];
  end;
end;

class function TCrypto.Decode64( const s: string): string;
var
  I: Integer;
  a: Integer;
  x: Integer;
  b: Integer;
begin
  Result := '';
  a := 0;
  b := 0;
  for I := 1 to Length(S) do begin
    x := Pos(S[I], Code64) - 1;
    if x >= 0 then begin
        b := b * 64 + x;
      a := a + 6;
      if a >= 8 then begin
          a := a - 8;
        x := b shr a;
        b := b mod (1 shl a);
        x := x mod 256;
        Result := Result + chr(x);
      end;
    end else
      Exit;
  end;
end;

{ nur für TraceDx-extern}
const
  cMax = 1;
  c: array[0..cMax] of byte = ( 17, 193 );

class procedure TCrypto.Encode( var s: TBytes );
var len, i, p: integer;
    sp, b    : byte;
begin
  len := high( s );

  p := 1;
  while p < len do p := p shl 1;
  p := p shr 1;
  sp := s[p];
  b := sp mod (cMax+1);

  for i := 0 to len do
    s[i] := s[i] xor c[b];

  s[p] := c[0] - sp
end;

class procedure TCrypto.Decode( var s: TBytes );
var len, i, p: integer;
    sp, b    : byte;
begin
  len := high( s );

  p := 1;
  while p < len do p := p shl 1;
  p := p shr 1;
  sp := c[0] - s[p];

  b := sp mod (cMax+1);

  for i := 0 to len do
    s[i] := s[i] xor c[b];

  s[p] := sp
end;

{$ENDREGION TCrypto}

{$REGION 'TUserHint'}
class procedure TUserHint.Show( b: TBalloonHint; const Title, Description: string; const Pos: TPoint );
begin
  // Aufruf siehe Test-Anwender
  b.Title       := Title;
  b.Description := Description;
  b.ShowHint( Pos )
end;

class procedure TUserHint.Clear( b: TBalloonHint );
begin
  b.HideHint
end;
{$ENDREGION TUserHint}

{$REGION 'Templates'}
{$WARN NO_RETVAL OFF}
function OffsetInRecord: NativeUInt;
begin
//  Offset := Integer(@rec(nil^).c);
end;
{$WARN NO_RETVAL DEFAULT}
{$ENDREGION Templates}

{$REGION 'Parameters'}
{$ENDREGION Parameters}

{$REGION 'OneInstance'}

{$ENDREGION OneInstance}

{$REGION 'ShowDimmed'}

// uses  WinAPI.DwmApi

(*

kleinere Erst-Variante von Uwe Raabe:

function ShowModalDimmed(Form: TForm; ParentForm: TForm = nil; Centered: Boolean = true; SpaceBelow: Integer = 0):
    TModalResult;
var
  Back: TForm;
  below: Integer;
  P: TPoint;
begin
  Back := TForm.Create(nil);
  try
    Back.Position := poDesigned;
    Back.BorderStyle := bsNone;
    Back.AlphaBlend := true;
    Back.AlphaBlendValue := 192;
    Back.Color := clBlack;
    if ParentForm <> nil then
      Back.SetBounds(ParentForm.Left, ParentForm.Top, ParentForm.Width, ParentForm.Height)
    else
      Back.SetBounds(0, 0, Screen.Width, Screen.Height);
    Back.Show;
    if Centered then begin
      P := TPoint.Create((Back.ClientWidth - Form.Width) div 2, (Back.ClientHeight - Form.Height) div 2);
      below := Back.ClientHeight - (P.Y + Form.Height);
      if below < SpaceBelow then begin
        P.Y := P.Y - (SpaceBelow - below);
        if P.Y < 0 then
          P.Y := 0;
      end;
      P := Back.ClientToScreen(P);
      Form.Position := poDesigned;
      Form.Left := P.X;
      Form.Top := P.Y;
    end;
    result := Form.ShowModal;
    Back.Hide;
  finally
    Back.Free;
  end;
end;
*)
class function TDimmed.ShowModalDimmed(aForm: TForm; aParentForm: TForm; AlphaBlendValue: Integer = 100; BackColor: TColor = clGray; Centered: Boolean = True): TModalResult;
var
  Back: TForm;
  Dummy_Rect: TRect;
  targetAlpha: Integer;
  Dummy_Alpha_inc: Integer;
  alphaDiff: Integer;

  function GetFormShadow(aForm: TForm): TRect;
  var
    R1, R2: TRect;
  begin
    (* Breite eines Schattens einer TForm *)
    Result := default (TRect);
    if (Win32MajorVersion >= 6) and DwmCompositionEnabled then
    begin
      if DwmGetWindowAttribute(aForm.Handle, DWMWA_EXTENDED_FRAME_BOUNDS, @R1, SizeOf(R1)) = S_OK then
      begin
        R2 := aForm.BoundsRect;
        Result.Left := R2.Left - R1.Left; // Linke Breite des Schattens
        if Result.Left < 0 then
          Result.Left := Result.Left * -1;
        Result.Right := (R2.Right - R1.Right) + Result.Left; // Rechte Breite des Schattens
        if Result.Right < 0 then
          Result.Right := Result.Right * -1;
        Result.Top := R2.Top - R1.Top; // Obere Höhe des Schattens
        if Result.Top < 0 then
          Result.Top := Result.Top * -1;
        Result.Bottom := (R2.Bottom - R1.Bottom) + Result.Top; // Untere Höhe des Schattens
        if Result.Bottom < 0 then
          Result.Bottom := Result.Bottom * -1;
      end;
    end;
  end;

begin
  Back := TForm.Create(nil);
  try
    Back.AlphaBlend := True;

    targetAlpha := AlphaBlendValue;
    if targetAlpha > 255 then
      targetAlpha := 255;
    if targetAlpha < 1 then
      targetAlpha := 1;

    Back.AlphaBlendValue := targetAlpha;
    Back.Color := BackColor;
    Back.DoubleBuffered := True;
    Back.BorderStyle := bsNone;

    if aParentForm <> nil then begin
      Back.Position := aParentForm.Position;
      {$IFDEF VER360} Back.RoundedCorners := aParentForm.RoundedCorners; {$ENDIF}
      Dummy_Rect := GetFormShadow(aParentForm);
      Back.SetBounds(aParentForm.Left + Dummy_Rect.Left, aParentForm.Top + Dummy_Rect.Top, aParentForm.Width - Dummy_Rect.Right, aParentForm.Height - Dummy_Rect.Bottom);
    end else begin
      Back.SetBounds(0, 0, Screen.Width, Screen.Height);
    end;
    Back.Show;

    if Centered then begin
      aForm.Position := poMainFormCenter;
    end;

    Result := aForm.ShowModal;
    Back.Hide;
  finally
    Back.Free;
  end;
end;
{$ENDREGION ShowDimmed}


initialization
  ForceCurrentDirectory := true;    // Open und Save-Dialoge nie mit "Eigene Dateien" öffnen

end.
