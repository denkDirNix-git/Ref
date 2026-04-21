
unit uDataIO;

{$DEFINE UnitOneInst}
{$INCLUDE _CompilerOptions.pas}
{ $UNDEF TraceDx}

interface

uses
  System.Classes,
  VCL.ComCtrls, VCL.StdCtrls,
  uGlobalsParser,
  System.SysUtils;  // tProc

const
  cNoSource = '';

type
  TDataIO = record
              class procedure Rename( const f: string );                            static;
              class function  Load  ( const f: string; LoadGUI: tProc< string > ): boolean; static;
              class procedure LoadBatch( const f: string ); static;
              class procedure Save  ();                                             static;
              class procedure Close( aktItem: tIdString; aktKontext: word; Hot: string );        static;
              class function  ShowIniDialog(): boolean;                             static;
            end;

var
  OptionPathMacros,
  OptionNamespace,
  OptionLibPaths: string;

implementation

uses
  {$IFDEF TraceDx} uTraceDx, {$ENDIF}
  System.IOUtils,   // tFileAccess
  System.UITypes,
  System.IniFiles,
  Vcl.Dialogs,
  ufFileOptions,
  uListen,              // UseClipBoard
  uGlobals;

const
  cExtIni  = '.' + cProgname + '.ini';
  cKontext = 3;

{$IFDEF TraceDx} type uData = class end; {$ENDIF}

var
  FileIni : TMemIniFile;
  Filename: string;        // Kopie von OpenDialog.Filename, wird im TFileIO.Load/Rename() gesetzt
  Platform, Version, Build: integer;


{$REGION '-------------- DProj  ---------------' }

procedure TryReadDProj;
const
  cItemGroup      = '    <ItemGroup>';     // Ende des Suchbereiches
  cUnitSearchPath = 'DCC_UnitSearchPath>';
  cDefine         = 'DCC_Define>';
  cNamespace      = 'DCC_Namespace>';
  cDefineDebug    = 'DEBUG';
  cDefineRelease  = 'RELEASE';
  cLongStrings    = 'DCC_LongStrings>';
var s  : string;
    i,j: integer;
    f  : textfile;
    si : set of ( siPath, siPrefix, siDefine, siLongStrings );
begin
  s  := TPath.ChangeExtension( Filename, '.dproj' );
  {$IFDEF UnitPrefixe}
  si := [siPath, siPrefix, siDefine];
  {$ELSE}
  si := [siPath, siDefine];
  {$ENDIF}
if TFile.Exists( s ) then begin
    AssignFile( f, s );
    Reset( f );
    i := -1;
    s := '';
    while not eof( f ) and ( si <> [] ) and ( s <> cItemGroup ) do begin
      readln( f, s );

      if siPath in si then begin
        i := s.IndexOf( cUnitSearchPath );
        if i <> -1 then begin
          s := s.Substring( i + length( cUnitSearchPath ),
                            s.IndexOf( '$' ) - i - length( cUnitSearchPath ) - 1 );
          FileOptions.SearchPathUnit := s;                      // nicht nach UnitLib damit ...
          frmFileOptions.edtSearchPathUnit.Modified := true;    // ... auch Includes dort gesucht werden
          exclude( si, siPath )
          end
        end;

      if siDefine in si then begin
        i := s.IndexOf( cDefine );
        if ( i <> -1 ) and ( s.IndexOf( cDefineDebug ) = -1 ) then begin
          s := s.Substring( i + length( cDefine ),
                            s.IndexOf( '$' ) - i - length( cDefine ) - 1 );
          j := s.IndexOf( cDefineRelease );
          if j <> -1 then begin
            s := s.Remove( j, length( cDefineRelease ));
            if s <> '' then
              if s[j-1] = TPath.PathSeparator then
                s := s.Remove( j-1, 1 )
              else
                if s[j] = TPath.PathSeparator then
                  s := s.Remove( j, 1 )
            end;
          if s <> '' then begin
            FileOptions.DefinedSymbols := FileOptions.DefinedSymbols + TPath.PathSeparator + s;
            frmFileOptions.edtDefinedSymbols.Modified := true;
            end;
          exclude( si, siDefine )
          end
        end;

      {$IFDEF UnitPrefixe}
      if siPrefix in si then begin
        i := s.IndexOf( cNamespace );
        if ( i <> -1 ) and ( s.IndexOf( cDefineDebug ) = -1 ) then begin
          s := s.Substring( i + length( cNamespace ),
                            s.IndexOf( '$' ) - i - length( cNamespace ) - 1 );
          j := s.IndexOf( cDefineRelease );
          if j <> -1 then begin
            s := s.Remove( j, length( cDefineRelease ));
            if s <> '' then
              if s[j-1] = TPath.PathSeparator then
                s := s.Remove( j-1, 1 )
              else
                if s[j] = TPath.PathSeparator then
                  s := s.Remove( j, 1 )
            end;
          if s <> '' then begin
            FileOptions.UnitPrefix := s;
            frmFileOptions.edtUnitPrefix.Modified := true;
            end;
          exclude( si, siPrefix )
          end
        end;
      {$ENDIF}

//      if siLongStrings in si then begin
//       i := s.IndexOf( cLongStrings );
//       if ( i <> -1 ) and ( s[i+length( cLongStrings )] = 'f' ) then
//         IfOptGlobal[cd_LongStrings] := false
//        end
      end;
    CloseFile( f )
    end
end;

{$ENDREGION }

{$REGION '-------------- Data Load/Save  ---------------' }

type
  tIni = ( SecProg, Ver, PathMacros, SearchPathDelphi, EnableDelphiLib, SearchPathUnitLib, SearchPathUnit,
           Defines, CompilePlatform, ProgVersion, DebugRelease, UnitPrefix, EnableUnitPrefix,
           RegKeywords, RegSymbols, ParseForms, ProjectUsedOnly, UseSystemRef, LongStrings, LastItem, AcKontext,
           SecHot, HotKeyList );
const
  cIni : array[tIni] of string
       = ( cProgName, 'Version', 'PathMacros', 'SearchPathDelphi', 'EnableDelphiLib', 'SearchPathUnitLib', 'SearchPathUnit',
                      'Compiler-Defines', 'CompilePlatform', 'DelphiVersion', 'DebugRelease',
                      'UnitPrefix', 'UnitPrefixEnable',
                      'RegisterKeywords', 'RegisterSymbols', 'ParseForms', 'ProjectUsedOnly', 'UseSystemRef', 'LongStrings',
                      'LastItem', 'Context',
                      'HotKey', 'HotKeyList' );

var
  Makros: TArray<string>;

(* CheckMacro *)
function CheckMacro( const s: string ): string;
var ms: string;
    i: integer;
begin
  Result := s;
  for ms in Makros do begin
    i := ms.IndexOf( '=' );
    if i < 1 then continue;
    Result := Result.Replace( ms.Substring( 0, i ), ms.Substring( i+1 ), [rfReplaceAll] )
    end;
end;

function CheckPaths( const s: string ): string;
var a: TArray<string>;
    i: integer;
begin
  a := s.Split( TPath.PathSeparator, TStringSplitOptions.ExcludeEmpty );
  for i := 0 to high(a) do begin
    if not TDirectory.Exists( a[i] ) then
      Error( errDirExist, a[i] );
    if a[i][high(a[i])] <> TPath.DirectorySeparatorChar then
      a[i] := a[i] + TPath.DirectorySeparatorChar
    end;
  Result := string.join( TPath.PathSeparator, a )
end;


(* ReadWriteIni *)
function ReadWriteIni( rw: tFileAccess ): boolean;
{ TODO : read/write alle in INI zu speichernden Daten  }
var ProjDefines: string;
    c: char;
begin
  {$IFDEF TraceDx} TraceDx.Send( uData, 'ReadWriteIni', byte( rw ) ); {$ENDIF}
  result := true;
  with FileIni do begin
    if rw = TFileAccess.faRead then begin
//      if ReadString( cIni[tIni.SecProg], cIni[tIni.Ver], cVersion ) > cVersion then begin
//        {$IFDEF RELEASE} Error( tError.errVersion ); {$ENDIF}
        //ToDo: auf Kompatibilität prüfen / anpassen
//        end;

      FileOptions.PathMacros               := ReadString ( cIni[tIni.SecProg], cIni[tIni.PathMacros       ], OptionPathMacros );
      Makros := FileOptions.PathMacros.Split( [PathSep], TStringSplitOptions.ExcludeEmpty );

      FileOptions.SearchPathDelphi         := ReadString ( cIni[tIni.SecProg], cIni[tIni.SearchPathDelphi ], OptionLibPaths );
      FileOptions.SearchPathDelphiNoMacro  := CheckMacro( FileOptions.SearchPathDelphi );
      FileOptions.SearchPathDelphiNoMacro  := CheckPaths( FileOptions.SearchPathDelphiNoMacro );

      FileOptions.EnableDelphiLib          := ReadBool   ( cIni[tIni.SecProg], cIni[tIni.EnableDelphiLib  ], false );
//      frmFileOptions.chkBoxDelphiLibsClick( nil );
      frmFileOptions.btnResetDelphiLibs.Hint := OptionLibPaths;

      FileOptions.SearchPathUnitLib        := ReadString ( cIni[tIni.SecProg], cIni[tIni.SearchPathUnitLib], EmptyStr );
      FileOptions.SearchPathUnitLibNoMacro := CheckMacro( FileOptions.SearchPathUnitLib );
      FileOptions.SearchPathUnitLibNoMacro := CheckPaths( FileOptions.SearchPathUnitLibNoMacro );

      FileOptions.SearchPathUnit           := ReadString ( cIni[tIni.SecProg], cIni[tIni.SearchPathUnit   ], EmptyStr );
      FileOptions.SearchPathUnitNoMacro    := CheckMacro( FileOptions.SearchPathUnit );
      FileOptions.SearchPathUnitNoMacro    := CheckPaths( FileOptions.SearchPathUnitNoMacro );

      Platform                      := ReadInteger( cIni[tIni.SecProg], cIni[tIni.CompilePlatform], 0 );
      Version                       := ReadInteger( cIni[tIni.SecProg], cIni[tIni.ProgVersion    ], frmFileOptions.cmbBoxVersion.Items.Count-1 );
      Build                         := ReadInteger( cIni[tIni.SecProg], cIni[tIni.DebugRelease   ], 0 );
      FileOptions.DefinedSymbols    := frmFileOptions.cmbBoxPlatform.Items[Platform] + TPath.PathSeparator +
                                       frmFileOptions.cmbBoxVersion .Items[Version]  + TPath.PathSeparator +
                                       frmFileOptions.cmbBoxBuild   .Items[Build];
      ProjDefines                   := ReadString ( cIni[tIni.SecProg], cIni[tIni.Defines       ], EmptyStr );
      if ProjDefines <> EmptyStr then
        FileOptions.DefinedSymbols  := FileOptions.DefinedSymbols + TPath.PathSeparator + ProjDefines.ToUpperInvariant;

      {$IFDEF UnitPrefixe}
      FileOptions.UnitPrefix        := ReadString ( cIni[tIni.SecProg], cIni[tIni.UnitPrefix], OptionNamespace );
      FileOptions.EnableUnitPrefix  := ReadBool   ( cIni[tIni.SecProg], cIni[tIni.EnableUnitPrefix], false );
      frmFileOptions.btnResetNamespace.Hint := OptionNamespace;
      {$ENDIF}

      FileOptions.RegKeywords       := boolean( ReadInteger( cIni[tIni.SecProg], cIni[tIni.RegKeywords   ], 0 ));
      FileOptions.RegKeySymbols     := boolean( ReadInteger( cIni[tIni.SecProg], cIni[tIni.RegSymbols    ], 0 ));
      FileOptions.ParseFormular     := ReadBool   ( cIni[tIni.SecProg], cIni[tIni.ParseForms     ], true     ) and not UseClipBoard;
      FileOptions.ProjectUsedOnly   := ReadBool   ( cIni[tIni.SecProg], cIni[tIni.ProjectUsedOnly], false    );
      FileOptions.UseSystemRef      := ReadBool   ( cIni[tIni.SecProg], cIni[tIni.UseSystemRef   ], false    );
      IfOptGlobal[cd_LongStrings]   := ReadBool   ( cIni[tIni.SecProg], cIni[tIni.LongStrings    ], true     );
      FileOptions.LastItem          := ReadString ( cIni[tIni.SecProg], cIni[tIni.LastItem       ], EmptyStr );
      FileOptions.AcKontext         := ReadInteger( cIni[tIni.SecProg], cIni[tIni.AcKontext      ], cKontext );
      FileOptions.HotKeyList        := ReadString ( cIni[tIni.SecHot ], cIni[tIni.HotKeyList     ], EmptyStr );
      for c := low( tHotKeys ) to high( tHotKeys ) do FileOptions.HotKey[c] := EmptyStr;
      for c in FileOptions.HotKeyList do
        FileOptions.HotKey[c]       := ReadString ( cIni[tIni.SecHot ], cIni[tIni.SecHot] + c    , EmptyStr );

//      {$IFDEF RELEASE}
      {$IFNDEF RefBatch}
      if not UseClipBoard and not TFile.Exists( Filename ) then begin
        TryReadDProj;
        result := TDataIO.ShowIniDialog()
        end
      {$ENDIF}
      end;

    if not TFile.Exists( Filename ) or ( rw = TFileAccess.faWrite ) then
      WriteString ( cIni[tIni.SecProg], cIni[tIni.Ver], cVersion )
    end;
end;

(* ShowIniDialog *)
class function TDataIO.ShowIniDialog(): boolean;
const cSuchStart = 18;    // ab hier nach PathSeperator suchen, DANACH folgen zusätzliche Defines
var d: string;
    i: integer;
begin
  {$IFDEF TraceDx} TraceDx.Call( uData, 'ShowIniDialog' ); {$ENDIF}
  result := false;
  with frmFileOptions do begin
    Caption := 'Project Options  [' + Filename  + cExtIni + ']';
    edtPathMacros        .Text    := FileOptions.PathMacros;
    edtSearchPathDelphi  .Text    := FileOptions.SearchPathDelphi;
    chkBoxDelphiLibs     .Checked := FileOptions.EnableDelphiLib;
    edtSearchPathUnitLib .Text    := FileOptions.SearchPathUnitLib;
    edtSearchPathUnit    .Text    := FileOptions.SearchPathUnit;
    d                             := FileOptions.DefinedSymbols;
    i := FileOptions.DefinedSymbols.IndexOf( TPath.PathSeparator, cSuchStart );
    if i = -1
      then edtDefinedSymbols.Text := ''
      else edtDefinedSymbols.Text := FileOptions.DefinedSymbols.Substring( i+1 );

    {$IFDEF UnitPrefixe}
    edtUnitPrefix           .Text    := FileOptions.UnitPrefix;
    chkBoxUnitPrefix        .Checked := FileOptions.EnableUnitPrefix ;
    {$ENDIF}

    chkBoxKeywords       .Checked := FileOptions.RegKeywords;
    chkBoxKeySymbols     .Checked := FileOptions.RegKeySymbols;
    chkBoxParseFormsFiles.Checked := FileOptions.ParseFormular;
    chkBoxHideLibraryInternals.Checked := FileOptions.ProjectUsedOnly;
    chkBoxUseSystemRef   .Checked := FileOptions.UseSystemRef;
    chkBoxLongStrings    .Checked := IfOptGlobal[cd_LongStrings];
    cmbBoxPlatform       .ItemIndex := Platform;
    cmbBoxVersion        .ItemIndex := Version;
    cmbBoxBuild          .ItemIndex := Build;
    if ShowModal = mrOk then begin
      result := true;

      if edtPathMacros.Modified then begin
        FileOptions.PathMacros := edtPathMacros.Text;
        FileIni.WriteString( cIni[tIni.SecProg], cIni[tIni.PathMacros], FileOptions.PathMacros );
        Makros := FileOptions.PathMacros.Split( [PathSep], TStringSplitOptions.ExcludeEmpty )
        end;

      if edtSearchPathDelphi.Modified or edtPathMacros.Modified then begin
        FileOptions.SearchPathDelphi        := edtSearchPathDelphi.Text;
        FileOptions.SearchPathDelphiNoMacro := CheckMacro( FileOptions.SearchPathDelphi );
        FileOptions.SearchPathDelphiNoMacro := CheckPaths( FileOptions.SearchPathDelphiNoMacro );
        FileIni.WriteString( cIni[tIni.SecProg], cIni[tIni.SearchPathDelphi], edtSearchPathDelphi.Text )
        end;

      if chkBoxDelphiLibs.Checked <> FileOptions.EnableDelphiLib then begin
        FileOptions.EnableDelphiLib := chkBoxDelphiLibs.Checked;
        FileIni.WriteBool( cIni[tIni.SecProg], cIni[tIni.EnableDelphiLib], FileOptions.EnableDelphiLib)
        end;

      if edtSearchPathUnitLib.Modified or edtPathMacros.Modified then begin
        FileOptions.SearchPathUnitLib        := edtSearchPathUnitLib.Text;
        FileOptions.SearchPathUnitLibNoMacro := CheckMacro( FileOptions.SearchPathUnitLib );
        FileOptions.SearchPathUnitLibNoMacro := CheckPaths( FileOptions.SearchPathUnitLibNoMacro );
        FileIni.WriteString( cIni[tIni.SecProg], cIni[tIni.SearchPathUnitLib], edtSearchPathUnitLib.Text )
        end;

      if edtSearchPathUnit.Modified or edtPathMacros.Modified then begin
        FileOptions.SearchPathUnit        := CheckMacro( FileOptions.SearchPathUnit );
        FileOptions.SearchPathUnitNoMacro := CheckMacro( edtSearchPathUnit.Text );
        FileOptions.SearchPathUnitNoMacro := CheckPaths( FileOptions.SearchPathUnitNoMacro );
        FileIni.WriteString( cIni[tIni.SecProg], cIni[tIni.SearchPathUnit ], edtSearchPathUnit.Text )
        end;

      {$IFDEF UnitPrefixe}
      if chkBoxUnitPrefix.Checked <> FileOptions.EnableUnitPrefix then begin
        FileOptions.EnableUnitPrefix := chkBoxUnitPrefix.Checked;
        FileIni.WriteBool( cIni[tIni.SecProg], cIni[tIni.EnableUnitPrefix], FileOptions.EnableUnitPrefix )
        end;

      if edtUnitPrefix.Modified then begin
        FileOptions.UnitPrefix := edtUnitPrefix.Text;
        FileIni.WriteString( cIni[tIni.SecProg], cIni[tIni.UnitPrefix     ], FileOptions.UnitPrefix  )
        end;
      {$ENDIF}

      if ( cmbBoxPlatform.ItemIndex <> Platform ) then begin
        Platform := cmbBoxPlatform.ItemIndex;
        FileIni.WriteInteger( cIni[tIni.SecProg], cIni[tIni.CompilePlatform ], Platform );
        end;

      if ( cmbBoxVersion.ItemIndex <> Version ) then begin
        Version := cmbBoxVersion.ItemIndex;
        FileIni.WriteInteger( cIni[tIni.SecProg], cIni[tIni.ProgVersion ], Version );
        end;

      if ( cmbBoxBuild.ItemIndex <> Build ) then begin
        Build := cmbBoxBuild.ItemIndex;
        FileIni.WriteInteger( cIni[tIni.SecProg], cIni[tIni.DebugRelease ], Build );
        end;

      FileOptions.DefinedSymbols := frmFileOptions.cmbBoxPlatform.Text + TPath.PathSeparator +
                                    frmFileOptions.cmbBoxVersion .Text + TPath.PathSeparator +
                                    frmFileOptions.cmbBoxBuild   .Text;
      if edtDefinedSymbols.Text <> '' then
        FileOptions.DefinedSymbols := FileOptions.DefinedSymbols + TPath.PathSeparator + uppercase( edtDefinedSymbols.Text );

      if FileOptions.DefinedSymbols <> d then begin
        FileIni.WriteString( cIni[tIni.SecProg], cIni[tIni.Defines       ], edtDefinedSymbols.Text );
        end;

      if chkBoxKeywords.Checked <> FileOptions.RegKeywords then begin
        FileOptions.RegKeywords := chkBoxKeywords.Checked;
        {kann nur temporär eingeschaltet werden: }
//        FileIni.WriteInteger( cIni[tIni.SecProg], cIni[tIni.RegKeywords     ], ord( FileOptions.RegKeywords ))
        end;
      if chkBoxKeySymbols.Checked <> FileOptions.RegKeySymbols then begin
        FileOptions.RegKeySymbols := chkBoxKeySymbols.Checked;
        {kann nur temporär eingeschaltet werden: }
//        FileIni.WriteInteger( cIni[tIni.SecProg], cIni[tIni.RegSymbols      ], ord( FileOptions.RegKeySymbols ))
        end;
      if chkBoxParseFormsFiles.Checked <> FileOptions.ParseFormular then begin
        FileOptions.ParseFormular := chkBoxParseFormsFiles.Checked;
        FileIni.WriteBool( cIni[tIni.SecProg], cIni[tIni.ParseForms      ], FileOptions.ParseFormular )
        end;
      if chkBoxHideLibraryInternals.Checked <> FileOptions.ProjectUsedOnly then begin
        FileOptions.ProjectUsedOnly := chkBoxHideLibraryInternals.Checked;
        FileIni.WriteBool( cIni[tIni.SecProg], cIni[tIni.ProjectUsedOnly      ], FileOptions.ProjectUsedOnly )
        end;
      if chkBoxUseSystemRef.Checked <> FileOptions.UseSystemRef then begin
        FileOptions.UseSystemRef := chkBoxUseSystemRef.Checked;
        FileIni.WriteBool( cIni[tIni.SecProg], cIni[tIni.UseSystemRef      ], FileOptions.UseSystemRef )
        end;
//      if chkBoxLongStrings.Checked <> IfOptGlobal[cd_LongStrings] then begin
//        IfOptGlobal[cd_LongStrings] := chkBoxLongStrings.Checked;
      if not chkBoxLongStrings.Checked then begin
        IfOptGlobal[cd_LongStrings] := false;
        FileIni.WriteBool( cIni[tIni.SecProg], cIni[tIni.LongStrings      ], IfOptGlobal[cd_LongStrings] )
        end
      end
    end
end;

(* Rename *)
class procedure TDataIO.Rename( const f: string );
var ReadAgain: boolean;
begin
  {$IFDEF TraceDx} TraceDx.Send( uData, 'Rename', f ); {$ENDIF}
  ReadAgain := TFile.Exists( f + cExtIni ) and
               ( MessageDlg( 'Daten aus "' + f + cExtIni + '" laden?', mtConfirmation, mbOKCancel, 0) = mrOK );
  FileIni.Rename( f + cExtIni, ReadAgain );
  Filename := f;
  if ReadAgain then
    ReadWriteIni( TFileAccess.faRead )
end;

(* Load *)
class function TDataIO.Load( const f: string; LoadGUI: tProc< string > ): boolean;
{ TODO : die aus der Dat gelesenen Daten per Aufruf "SetGUI()" an GUI übergeben }
begin
  {$IFDEF TraceDx} TraceDx.Send( uData, 'Load', f ); {$ENDIF}
  FileIni.Rename( f + cExtIni, true );
  Filename := f;
  Result := ReadWriteIni( TFileAccess.faRead );
//  a := TFile.ReadAllLines( Filename );        // wird vom Parser erledigt
  LoadGUI( FileOptions.LastItem );
end;

(* Load *)
class procedure TDataIO.LoadBatch( const f: string );
var ProjDefines: string;
begin
  with FileIni do begin
    Rename( f + cExtIni, true );

    FileOptions.PathMacros               := ReadString ( cIni[tIni.SecProg], cIni[tIni.PathMacros       ], OptionPathMacros );
    Makros := FileOptions.PathMacros.Split( [PathSep], TStringSplitOptions.ExcludeEmpty );

    FileOptions.SearchPathDelphi         := ReadString ( cIni[tIni.SecProg], cIni[tIni.SearchPathDelphi ], OptionLibPaths );
    FileOptions.SearchPathDelphiNoMacro  := CheckMacro( FileOptions.SearchPathDelphi );
    FileOptions.SearchPathDelphiNoMacro  := CheckPaths( FileOptions.SearchPathDelphiNoMacro );

    FileOptions.EnableDelphiLib   := ReadBool   ( cIni[tIni.SecProg], cIni[tIni.EnableDelphiLib  ], false );
//    frmFileOptions.chkBoxDelphiLibsClick( nil );

    FileOptions.SearchPathUnitLib        := ReadString ( cIni[tIni.SecProg], cIni[tIni.SearchPathUnitLib], EmptyStr );
    FileOptions.SearchPathUnitLibNoMacro := CheckMacro( FileOptions.SearchPathUnitLib );
    FileOptions.SearchPathUnitLibNoMacro := CheckPaths( FileOptions.SearchPathUnitLibNoMacro );

    FileOptions.SearchPathUnit           := ReadString ( cIni[tIni.SecProg], cIni[tIni.SearchPathUnit   ], EmptyStr );
    FileOptions.SearchPathUnitNoMacro    := CheckMacro( FileOptions.SearchPathUnit );
    FileOptions.SearchPathUnitNoMacro    := CheckPaths( FileOptions.SearchPathUnitNoMacro );

//    Platform                      := ReadInteger( cIni[tIni.SecProg], cIni[tIni.CompilePlatform], 0 );
//    Version                       := ReadInteger( cIni[tIni.SecProg], cIni[tIni.ProgVersion    ], frmFileOptions.cmbBoxVersion.Items.Count-1 );
//    Build                         := ReadInteger( cIni[tIni.SecProg], cIni[tIni.DebugRelease   ], 0 );
//    FileOptions.DefinedSymbols    := frmFileOptions.cmbBoxPlatform.Items[Platform] + TPath.PathSeparator +
//                                     frmFileOptions.cmbBoxVersion .Items[Version]  + TPath.PathSeparator +
//                                     frmFileOptions.cmbBoxBuild   .Items[Build];
    FileOptions.DefinedSymbols    := 'MSWINDOWS;VER330;RELEASE';
    ProjDefines                   := ReadString ( cIni[tIni.SecProg], cIni[tIni.Defines       ], EmptyStr );
    if ProjDefines <> EmptyStr then
      FileOptions.DefinedSymbols  := FileOptions.DefinedSymbols + TPath.PathSeparator + ProjDefines.ToUpperInvariant;

    {$IFDEF UnitPrefixe}
    FileOptions.UnitPrefix        := ReadString ( cIni[tIni.SecProg], cIni[tIni.UnitPrefix], OptionNamespace );
    FileOptions.EnableUnitPrefix  := ReadBool   ( cIni[tIni.SecProg], cIni[tIni.EnableUnitPrefix], false );
    {$ENDIF}

    FileOptions.RegKeywords       := boolean( ReadInteger( cIni[tIni.SecProg], cIni[tIni.RegKeywords   ], 0 ));
    FileOptions.RegKeySymbols     := boolean( ReadInteger( cIni[tIni.SecProg], cIni[tIni.RegSymbols    ], 0 ));
    FileOptions.ParseFormular     := ReadBool   ( cIni[tIni.SecProg], cIni[tIni.ParseForms     ], true     ) and not UseClipBoard;
    FileOptions.ProjectUsedOnly   := ReadBool   ( cIni[tIni.SecProg], cIni[tIni.ProjectUsedOnly], false    );
    FileOptions.UseSystemRef      := ReadBool   ( cIni[tIni.SecProg], cIni[tIni.UseSystemRef   ], false    );
    IfOptGlobal[cd_LongStrings]   := ReadBool   ( cIni[tIni.SecProg], cIni[tIni.LongStrings    ], true     );
//    FileOptions.LastItem          := ReadString ( cIni[tIni.SecProg], cIni[tIni.LastItem       ], EmptyStr );
//    FileOptions.AcKontext         := ReadInteger( cIni[tIni.SecProg], cIni[tIni.AcKontext      ], cKontext );
//    FileOptions.HotKeyList        := ReadString ( cIni[tIni.SecHot ], cIni[tIni.HotKeyList     ], EmptyStr );
//    for c := low( tHotKeys ) to high( tHotKeys ) do FileOptions.HotKey[c] := EmptyStr;
//    for c in FileOptions.HotKeyList do
//      FileOptions.HotKey[c]       := ReadString ( cIni[tIni.SecHot ], cIni[tIni.SecHot] + c    , EmptyStr );
    end;
end;

(* Save *)
class procedure TDataIO.Save();
begin
  {$IFDEF TraceDx} TraceDx.Send( uData, 'Save' ); {$ENDIF}
  { TODO : übergebene Dat-Daten aus GUI in Dat speichern }
//  AssignFile( f, Filename );
//  Rewrite( f );
//  CloseFile( f );
end;

(* Close *)
class procedure TDataIO.Close( aktItem: tIdString; aktKontext: word; Hot: string );
var c: char;
begin
  {$IFDEF TraceDx} TraceDx.Send( uData, 'Close' ); {$ENDIF}
  if Filename <> cNoSource then begin
    { TODO : geänderte Daten jetzt in Ini speichern }
    if FileOptions.LastItem <> aktItem then
      FileIni.WriteString( cIni[tIni.SecProg], cIni[tIni.LastItem ], aktItem    );
    if FileOptions.AcKontext <> aktKontext then
      FileIni.WriteInteger( cIni[tIni.SecProg], cIni[tIni.AcKontext], aktKontext );
    if FileOptions.HotKeyList <> Hot then
      FileIni.WriteString( cIni[tIni.SecHot], cIni[tIni.HotKeyList ], Hot );
    for c in Hot do
      FileIni.WriteString( cIni[tIni.SecHot], cIni[tIni.SecHot]+c, FileOptions.HotKey[c] );

    if FileIni.Modified then
      try FileIni.UpdateFile
      except ShowMessage( 'Datei "' + FileIni.Filename + '" konnte nicht erstellt werden' )
      end;
    Filename := cNoSource
    end;
end;

{$ENDREGION }

{$REGION '-------------- Init / Exit ---------------' }

initialization
  {$IFDEF TraceDx} TraceDx.Send( uData, 'initialization' ); {$ENDIF}
  FileIni := TMemIniFile.Create( '' );
  FileIni.AutoSave := false;
  Filename := cNoSource;

finalization
  {$IFDEF TraceDx} TraceDx.Send( uData, 'finalization' ); {$ENDIF}
  FileIni.Free;

{$ENDREGION }

end.
