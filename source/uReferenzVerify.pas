
unit uReferenzVerify;

//  Verify bauen:
//  1. Test-Projekt "Test" unter "TestVerify" abspeichern
//  2. "Test" wieder in Projektgruppe aufnehmen, neue GUID für "TestVerify"
//  3. "TestVerify"-Projekt-Optionen auf Standards setzen
//  4. "TestVerify"-AddFile: Unit "uTestVerify", dort AddMenu, Verify-Procs

interface

implementation

uses
  System.IOUtils,
  Vcl.ComCtrls,
  uGlobalsParser,
  ufReferenz,
  ufVia,
  uListen,
  uFunctions,
  uTraceDx;

{$REGION '-------------- Pre / Post ---------------' }

var
  SourcePathIniSave: boolean;

{ Definierten Ausgangszustand vor Verify setzen (einmalig)                   }
{ Individuelle Einstellungen können lokal unter IncHide() vorgenommen werden }
procedure PreAll;
begin
  TraceDx.Events.  SaveAndSet( TraceDx.Events.App.cStandard,                    // fast alle Verify-Application-Events
                               TraceDx.Events.Scr.cStandard,                    //      alle Verify-Screen-Events
                               TraceDx.Events.Frm.cStandard,                    // fast alle Verify-Form-Events (für alle angemeldeten Forms)
                               true                                             // alle Form-SubControl-OnClicks aktivieren
                             );

  TraceDx.Messages.SaveAndSet( TraceDx.Messages.cStandard);                     // keine Message-Types (weil Gefahr der Störung des Testfalls zu gross)

  SourcePathIniSave := frmMain.mItmOptionsSourcePathIni.Checked;                // immer Project-Ini aus SourcePath benutzen für Unabhängigkeit von aktueller Einstellung
  frmMain.mItmOptionsSourcePathIni.Checked := true;
end;

{ gespeicherten Eingangszustand wieder herstellen: }
procedure PostAll;
begin
  TraceDx.Events.  Restore;                                                   // alle Events        wieder auf alten Zustand
  TraceDx.Messages.Restore;                                                   // alle Message-Types wieder auf alten Zustand
  frmMain.mItmOptionsSourcePathIni.Checked := SourcePathIniSave
end;

{$ENDREGION}

{$REGION '-------------- Verify ---------------' }

const
  cRunAgainIntro = 13 {Länge IntroText auf Button};

procedure RenameUI;
const cDataFile = '\Ref\VerifyDx\TestSource\Rename.pas';
begin

    // To Do


  TraceDx.IncHide;   // dieser Teil ist nicht relevant, Trace ausblenden
  frmMain.btnRunAgain.Caption := StringOfChar( ' ', cRunAgainIntro ) + cDataFile;
  frmMain.btnRunAgainClick( nil );

  VerifyDx.SetDataFile( cDataFile );
  TFile.Copy( cDataFile + '.org', cDataFile, true );

  frmMain.cmbBoxSearch.Text := 'MeineVariable';
  frmMain.cmbBoxSearchChange( frmMain.cmbBoxSearch );

  TraceDx.DecHide;
  frmMain.PopupItmIdRenameClick( nil )
end;

procedure Rename;
const cSrcFile = '\Ref\VerifyDx\TestSource\Rename.pas';
      cRenames : array of string = ['MeineVariable', 'tRecord'];
begin
  VerifyDx.SetDataFile( cSrcFile{, true} );             // Client legt ein Data-File an, dies ist das relevante zum prüfen!
  TFile.Copy( cSrcFile + '.org', cSrcFile, true );     //             "

  // Standard-Testdatei laden und parsen
  TraceDx.IncHide;                                       // dieser Teil ist nicht relevant, Trace ausblenden
  frmMain.btnRunAgain.Caption := StringOfChar( ' ', cRunAgainIntro ) + cSrcFile;
  frmMain.btnRunAgainClick( nil );                       // Testdatei parsen
  TraceDx.DecHide( false );                              // keine "Hidden-Lines"-Meldung

  if not frmMain.actIdReduce.Enabled then begin          // falls Option-Dialog mit "Cancel" beendet wurde:
    VerifyDx.Error := 1;                                 // dann liegen keine Identifier vor
    exit                                                 // -> Ausstieg
    end;

  for var s in cRenames do begin
    // Rename-Funktion direkt aufrufen um 'MeineVariable' in 'x' umzubenennen:
    TFncIdentifier.Rename( TListen.SucheIdInBloecken( cNoHash, s ), 'X_' + s );

    TraceDx.IncHide;                                       // folgendes ist wieder irrelevant für Rename-Test
    frmMain.mItmFileReParseClick( nil );                   // Reparse für korrekte Anzeige, passiert normalerweise im PopupItmIdRenameClick()
    TraceDx.DecHide( false );                              // keine "Hidden-Lines"-Meldung
    end
end;

procedure AccessVia;
const cSrcFile = '\Ref\VerifyDx\TestSource\AccessVia.pas';
var   Node: TTreeNode;
      pId: pIdInfo;
      pAc: pAcInfo;
begin
  if not TVerifyRef.ParseSource( cSrcFile ) then begin
    VerifyDx.Error := 1;
    exit
    end;

  { ViaId suchen: }
  pId := TVerifyRef.setAktPidbyName( 'Caption' );
  TraceDx.Send( 'AktPid', pId^.Name );

  Node := frmVia.TreeViewVia.Items.AddChildFirst( Node, 'VerifyTmpNode' );
  frmVia.TreeViewVia.Selected := Node;

  pAc := pId^.AcList;
  while ( pAc^.AcPrev = nil )  or  ( pAc^.AcPrev^.IdDeclare.Name <> 'Form1' ) do
    pAc := pAc^.NextAc;

  Node.Data := pAc;
  frmMain.actRefsViaSelectExecute( nil );

//  frmVia.TreeViewVia.Selected := nil;
//  Node.Free
end;

procedure UnitOnly;
const cSrcFile = '\_Source\Rtl\Common\_RefTest_Common.dpk';
var   pId: pIdInfo;
begin
  if not TVerifyRef.ParseSource( cSrcFile ) then begin
    VerifyDx.Error := 1;
    exit
    end;

  { Verify-Id setzen: }
  pId := TVerifyRef.setAktPidbyName( 'Int64' );
  TraceDx.Send( 'AktPid', pId^.Name );

  { Unit-Liste aufbauen : }
  frmMain.cboBoxUnitsDropDown( nil )                     // hier anfallende Trace-Ausgaben sind für Vergleich
end;

{$ENDREGION}

{$REGION '-------------- Init ---------------' }

procedure InitVerify;
begin
  VerifyDx.DefinePrePostAll( PreAll, PostAll );
  VerifyDx.DefineProc ( 'Rename'    , Rename    );
  VerifyDx.DefineProc ( 'AccessVia' , AccessVia );
  VerifyDx.DefineProc ( 'UnitOnly'  , UnitOnly  );

  //  VerifyDx.DefineGroup( 'Special'  , [
//                                      'File',       @VerifyFile,
//                                      'Export',     @VerifyExport
//                                     ] );
//  VerifyDx.DisableProc( AccessVia );
end;

initialization
  InitVerify;
  TraceDx.AddMenu;

{$ENDREGION}


end.
