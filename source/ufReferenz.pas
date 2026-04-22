(*******************************)
(*  Ref                        *)
(*  DenkDirNix                 *)
(*  06.06.2019 -               *)
(*******************************)

unit ufReferenz;

{ $DEFINE UnitOneInst}
{$INCLUDE _CompilerOptionsRef.pas}
{$INCLUDE _CompilerOptions.pas}

interface

uses
  Winapi.Windows, System.Classes, Vcl.Graphics, Vcl.Forms, Vcl.Controls,
  Vcl.Menus, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.ImgList, Vcl.StdActns, Vcl.ActnList, Vcl.ToolWin, System.Actions,
  { zusätzlich: }
  WinApi.Messages, System.ImageList, Vcl.AppEvnts;

type
  TfrmMain = class( TForm )
    dlgOpen: TOpenDialog;
    dlgSave: TSaveDialog;
    ActionList: TActionList;
    actFileNew: TAction;
    actFileOpen: TAction;
    actFileSave: TAction;
    actFileSaveAs: TAction;
    actProgExit: TAction;
    actHelpInfo: TAction;
    ImageList: TImageList;
    MainMenu: TMainMenu;
    MainMenuFile: TMenuItem;
    mItmFileNew: TMenuItem;
    mItmFileOpen: TMenuItem;
    mItmFileSave: TMenuItem;
    mItmFileSaveAs: TMenuItem;
    mItmProgClose: TMenuItem;
    MainMenuIds: TMenuItem;
    mItmIdSearch: TMenuItem;
    mItmIdSearchAgain: TMenuItem;
    MainMenuHelp: TMenuItem;
    mItmHelpInfo: TMenuItem;
    actHelpHilfe: TAction;
    mItmHelpHilfe: TMenuItem;
    MainMenuOptions: TMenuItem;
    mItmOptionsPosition: TMenuItem;
    mItmFileClose: TMenuItem;
    actFileClose: TAction;
    actProgExitNoSave: TAction;
    mItmProgCloseNoSave: TMenuItem;
    mItmOptionsProjectOptions: TMenuItem;
    actViewFullScreen: TAction;
    MainMenuView: TMenuItem;
    mItmViewFullScreen: TMenuItem;
    mItmViewZoomPlus: TMenuItem;
    mItmViewZoomMinus: TMenuItem;
    mItmViewStatusBar: TMenuItem;
    SplitterMain: TSplitter;
    mItmOpenRecent1: TMenuItem;
    mItmOpenRecent2: TMenuItem;
    mItmOpenRecent3: TMenuItem;
    mItmOpenRecent5: TMenuItem;
    N2: TMenuItem;
    mItmFileReParse: TMenuItem;
    btnRunAgain: TButton;
    actViewKontextPlus: TAction;
    actViewKontextMinus: TAction;
    N3: TMenuItem;
    mItmRefKontextPlus: TMenuItem;
    mItmRefKontextMinus: TMenuItem;
    PanelLeft: TPanel;
    PanelRight: TPanel;
    mItmViewCounter: TMenuItem;
    actSearch: TAction;
    actSearchAgain: TAction;
    ApplicationEvents: TApplicationEvents;
    actRefsWriteOnly: TAction;
    MainMenuAcs: TMenuItem;
    N4: TMenuItem;
    mItmRefWriteOnly: TMenuItem;
    actIdentifierBack: TAction;
    mItmIdBack: TMenuItem;
    mItmAnsichtReduzieren: TMenuItem;
    mItmFileOpenClip: TMenuItem;
    MainMenuRefactor: TMenuItem;
    mItmExtraExportDebug: TMenuItem;
    N5: TMenuItem;
    mItmOptionsSourcePathIni: TMenuItem;
    N6: TMenuItem;
    pnlAcsAndFiles: TPanel;
    lstBox: TListBox;
    tvFiles: tTreeView;
    SplitterFiles: TSplitter;
    ToolBarAc: TToolBar;
    cmbBoxSearch: TComboBox;
    tBtnIdBack: TToolButton;
    tBtnKontextMinus: TToolButton;
    tBtnSepaHelp: TToolButton;
    tBtnHelp: TToolButton;
    tBtnKontextPlus: TToolButton;
    tBtnIdFilter: TToolButton;
    ToolButton3: TToolButton;
    actIdSetFilter: TAction;
    actIdViewFilter: TAction;
    N7: TMenuItem;
    mItmIdFilter: TMenuItem;
    mItmIdSetFilter: TMenuItem;
    ToolButton4: TToolButton;
    N10: TMenuItem;
    mItmOptionsAutoParse: TMenuItem;
    mItmHelpMailTo: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    PaintBox: TPaintBox;
    pnlLblFilter: TPanel;
    lblFilter: TLabel;
    ScrollBarTv: TScrollBar;
    pnlAcs: TPanel;
    pnlFiles: TPanel;
    lstBoxHotKey: TListBox;
    lstBoxHistory: TListBox;
    PopupMenuId: TPopupMenu;
    PopupItmIdGoto: TMenuItem;
    PopupItmIdSort: TMenuItem;
    PopupItmIdRename: TMenuItem;
    PopupItmIdCopy: TMenuItem;
    PopupItmIdCopyLong: TMenuItem;
    actIdReduce: TAction;
    PopupMenuAc: TPopupMenu;
    PopupItmAcGoto: TMenuItem;
    PopupItmAcFileViewer: TMenuItem;
    PopupItmAcGotoUsingId: TMenuItem;
    PopupMenuFile: TPopupMenu;
    PopupItmFileView: TMenuItem;
    PopupItmFileDefines: TMenuItem;
    PopupItmFileOptions: TMenuItem;
    PopupItmAcCopy: TMenuItem;
    PopupItmAcCopyLong: TMenuItem;
    mItmOptionsDelphiPath: TMenuItem;
    N1: TMenuItem;
    pItmIdFilterName: TMenuItem;
    N8: TMenuItem;
    pItmIdSetFilter: TMenuItem;
    pItmIdFilterHierarchy: TMenuItem;
    pItmIdReduce: TMenuItem;
    actIdFilterName: TAction;
    actIdFilterHierarchy: TAction;
    lblStatus: TLabel;
    mItmViewFiles: TMenuItem;
    N13: TMenuItem;
    N9: TMenuItem;
    PopupItmAcNassi: TMenuItem;
    N14: TMenuItem;
    mItmRefactorEndIf: TMenuItem;
    mItmOptionsNamespace: TMenuItem;
    mItmIdHistory: TMenuItem;
    N15: TMenuItem;
    mItmViewIdHistory: TMenuItem;
    tBtnSelectFromVia: TToolButton;
    actRefsViaOnly: TAction;
    actRefsViaSelect: TAction;
    mItmRefViaOnly: TMenuItem;
    mItmRefViaSelect: TMenuItem;
    mItmRefDeclaration: TMenuItem;
    actRefDeclaration: TAction;
    tBtnDeclare: TToolButton;
    ToolButton7: TToolButton;
    ToolBarId: TToolBar;
    ToolButton8: TToolButton;
    chkBoxWriteOnly: TCheckBox;
    ToolButton6: TToolButton;
    chkBoxUnitOnly: TCheckBox;
    ToolButton5: TToolButton;
    cboBoxUnits: TComboBox;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    chkBoxViaIdOnly: TCheckBox;
    ToolButton1: TToolButton;
    mItmOpenRecent4: TMenuItem;
    mItmOpenRecent6: TMenuItem;
    mItmOpenRecent7: TMenuItem;
    mItmOpenRecent8: TMenuItem;
    mItmOptionsPathMacros: TMenuItem;
    N16: TMenuItem;
    N17: TMenuItem;
    mItmRefUnitOnly: TMenuItem;
    procedure actFileOpenExecute(Sender: TObject);
    procedure actFileSaveExecute(Sender: TObject);
    procedure actProgExitExecute(Sender: TObject);
    procedure actHelpInfoExecute(Sender: TObject);
    procedure actFileSaveAsExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actHelpHilfeExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure mItmOptionsPositionClick(Sender: TObject);
    procedure actFileNewCloseExecute(Sender: TObject);
    procedure actProgExitNoSaveExecute(Sender: TObject);
    procedure ToolBarAcResize(Sender: TObject);
    procedure mItmOptionsProjectOptionsClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure actViewFullScreenExecute(Sender: TObject);
    procedure mItmViewZoomPlusClick(Sender: TObject);
    procedure mItmViewZoomMinusClick(Sender: TObject);
    procedure mItmViewStatusBarClick(Sender: TObject);
    procedure mItmRecentClick(Sender: TObject);
    procedure mItmFileReParseClick(Sender: TObject);
    procedure btnRunAgainClick(Sender: TObject);
    procedure lstBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lstBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lstBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure actViewKontextPlusExecute(Sender: TObject);
    procedure actViewKontextMinusExecute(Sender: TObject);
    procedure mItmViewCounterClick(Sender: TObject);
    procedure SplitterMainMoved(Sender: TObject);
    procedure actSearchExecute(Sender: TObject);
    procedure actSearchAgainExecute(Sender: TObject);
    procedure actRefsWriteOnlyExecute(Sender: TObject);
    procedure lstBoxKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure actIdentifierBackExecute(Sender: TObject);
    procedure ApplicationEventsActivate(Sender: TObject);
    procedure mItmFileOpenClipClick(Sender: TObject);
    procedure mItmExtraExportDebugClick(Sender: TObject);
    procedure mItmOptionsSourcePathIniClick(Sender: TObject);
    procedure tvFilesCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure lblFilterClick(Sender: TObject);
    procedure cmbBoxSearchKeyPress(Sender: TObject; var Key: Char);
    procedure mItmHelpMailToClick(Sender: TObject);
    procedure mItmOptionsAutoParseClick(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure actIdViewFilterExecute(Sender: TObject);
    procedure ScrollBarTvScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure ScrollBarTvKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure ScrollBarTvEnterExit(Sender: TObject);
    procedure cmbBoxSearchChange(Sender: TObject);
    procedure actIdSetFilterExecute(Sender: TObject);
    procedure cmbBoxSearchDblClick(Sender: TObject);
    procedure tvFilesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lstBoxHotKeyDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lstBoxHotKeyClick(Sender: TObject);
    procedure PopupItmIdGotoClick(Sender: TObject);
    procedure PopupItmIdSortClick(Sender: TObject);
    procedure PopupMenuIdPopup(Sender: TObject);
    procedure PopupItmIdRenameClick(Sender: TObject);
    procedure PopupItmIdCopyClick(Sender: TObject);
    procedure PopupItmIdCopyLongClick(Sender: TObject);
    procedure actIdReduceExecute(Sender: TObject);
    procedure PopupMenuAcPopup(Sender: TObject);
    procedure PopupItmAcGotoClick(Sender: TObject);
    procedure PopupItmAcFileViewerClick(Sender: TObject);
    procedure PopupItmAcGotoUsingIdClick(Sender: TObject);
    procedure PopupItmFileViewClick(Sender: TObject);
    procedure PopupMenuFilePopup(Sender: TObject);
    procedure tvFilesClick(Sender: TObject);
    procedure tvFilesDblClick(Sender: TObject);
    procedure PopupItmAcCopyClick(Sender: TObject);
    procedure PopupItmAcCopyLongClick(Sender: TObject);
    procedure tvFilesMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure mItmOptionsDelphiPathClick(Sender: TObject);
    procedure actIdFilterNameExecute(Sender: TObject);
    procedure actIdFilterHierarchyExecute(Sender: TObject);
    procedure mItmViewFilesClick(Sender: TObject);
    procedure cmbBoxSearchExit(Sender: TObject);
    procedure PopupItmAcNassiClick(Sender: TObject);
    procedure mItmRefactorEndIfClick(Sender: TObject);
    procedure mItmOptionsNamespaceClick(Sender: TObject);
    procedure FormAfterMonitorDpiChanged(Sender: TObject; OldDPI, NewDPI: Integer);
    procedure mItmIdHistoryClick(Sender: TObject);
    procedure actRefsViaOnlyExecute(Sender: TObject);
    procedure actRefsViaSelectExecute(Sender: TObject);
    procedure actRefDeclarationExecute(Sender: TObject);
    procedure cmbBoxSearchEnter(Sender: TObject);
    procedure chkBoxUnitOnlyClick(Sender: TObject);
    procedure cboBoxUnitsDropDown(Sender: TObject);
    procedure cboBoxUnitsClick(Sender: TObject);
    procedure mItmOptionsPathMacrosClick(Sender: TObject);
    procedure mItmRefUnitOnlyClick(Sender: TObject);
  protected
    procedure WMDROPFILES ( var Msg: TMessage ); message WM_DROPFILES;
    procedure WMENDSESSION( var Msg: TWMEndSession ); message WM_ENDSESSION;
  private
    { Private-Deklarationen }
    procedure DoRefsViaChange( enable: boolean );
  public
    { Public-Deklarationen }
  end;

{$IFDEF RefVerify}
  TVerifyRef=record
               private
                 class procedure TraceOn( b: boolean ); static;
               public
                 class function  getAktPid: pointer; static;
                 class procedure setAktPid( p: pointer; HideTrace: boolean = true ); static;
                 class function  setAktPidbyName( const n: string; HideTrace: boolean = true ): pointer; static;
                 class function  ParseSource( const n: string; HideTrace: boolean = true ): boolean; static;
             end;
{$ENDIF}

var
  frmMain: TfrmMain;

{$IFDEF RefBatch}
procedure DoStartBatch( s: string );    // nur für Aufruf im Batch-Mode
{$ENDIF}
procedure OnAllCreated;

{ **************************************************************************************************** }

implementation

{$REGION '-------------- Uses ---------------' }

uses
  {$IFDEF TraceDx} uTraceDx, {$ENDIF}
  {$IFDEF UnitOneInst} uOneInstDx , {$ENDIF}
  WinAPI.ShellAPI,          // OleCheck, DragAccept
  WinAPI.ShlObj,          // pItemIdList
  Vcl.Clipbrd,
  System.Win.ComObj,
  UnitDragDropToExtern,
  System.DateUtils,
  System.IOUtils,
  System.SysUtils,
  System.StrUtils,   // ifthen
  System.IniFiles,
  System.UITypes,    // sonst Warning bei MessageDlg
  System.Diagnostics,// TStopWatch
  System.Character,
//  System.Rtti,       // für TRttiEnumerationType
  UtilitiesDx,
  uGlobals, ufHelp,
  uListen, uGlobalsParser,   // Pfui!
  ufViewer, ufFilter,
  uSystem,
  {$IFNDEF RefBatch}
  u_Nassi,
  {$ENDIF}
  uScanner,
  ufVia,
  ufHistory,
  uFunctions,
  uParser,
  uDataIO;

{$R *.dfm}

{$ENDREGION }

{$REGION '-------------- const / type / var ---------------' }

const
  cExtensionDpr   = '.dpr';
  cExtensionDpk   = '.dpk';
  cExtensionDproj = '.dproj';
  cExtensionTree  = '.tree';
  cDenkDirNix     = 'DenkDirNix';
  cMailTo         = 'mailto: ' + cDenkDirNix + '@mail.de';
  cOptionChar     = '-';
  cSearchStartEnd = '.';
  cAtBlock        = '  @ ';
  cClipboardFile  = '$ClipBoard$';    // interne Kennung "Source hat keine Datei sondern ClipBoard als Grundlage"
  cDragThreshold  = 2;
  cLenRunAgain    = 13;
  cViaId          = 'Via Id only';

type
  {$IFDEF TraceDx} uMain = class end; {$ENDIF}
  tCtrlTags       = ( ctFiles, ctMyTv, ctList );
  tCmpMode        = ( cfNul, cfNormal, cfMiddle, cfEnd, cfMiddleEnd );
  tCmpData        =  record
                       CmpMode   : tCmpMode;
                       SearchText: string;
                       SearchHash: tHash;
                     end;
  tShowTypeOf     = ( toNull, toTypeName, toProcFunc, toHierarchy );     // alles andere (positive Werte im Tag) ist toType oder toParent

var
  ProgIni         : TMemIniFile;
  CtrlArray       : array[tCtrlTags] of TWinControl;

  HotKey          : array[tHotKeys] of pIdInfo;
  CtrlDown        : boolean;
  lbCharWidth     : integer;

  AktIdVia        : pIdInfo = nil;        // der Via-Tree ist gültig für ...
  pAcVia          : pAcInfo = nil;        //

  pIdUnitOnly     : pIdInfo = nil;        // aktuelle Unit für InUnitOnly

//  BalloonHint     : TBalloonHint;

const
  cHint           : array[tMyTrees] of string = ( 'filtered', 'all' );
  cWelcome        = 'Welcome!     Open Project using   Open-Dialog (<F4>)   or   Drag&Drop';
  cSelectId       = 'Select Identifier to show References';
  cNoAutoParse    = 'AutoParse disabled ( see "Options" ).    Press <F5> to start ...';
  cHotKeyInfo     = 'HotKey-Function for Key <X>:     GOTO: Ctrl-<X>      SET: Ctrl-Shift-<X>      DEL(all): Ctrl-(Shift-)Delete';
  cDropIsNotIDE   = 'Drop-Point seems not to be the Delphi-IDE';
  cAlwaysDeclared = [id_Unbekannt..id_Unit, id_Init..high( tIdType )];

{ **************************************************************************************************** }

{ HINWEISE:
    OpenDialog   .InitialDir       Pfad letzte Source-Datei, sonst Exe-Pfad
    OpenDialog   .Filename         SourceDatei
    SaveDialog   .Filename         wird nur beim Speichern belegt

    actFileNew   .Enabled          true
    actFileOpen  .Enabled          keine kritische Aktion läuft, neue Datei darf geöffnet werden
    actFileSave  .Enabled          Daten sind verändert, ggf speichern
    actFileSaveAs.Enabled          true
    actFileClose .Enabled          true
    actProgExit  .Enabled          true
}

{ **************************************************************************************************** }

{$ENDREGION }

{$REGION '-------------- tUserInfo ---------------' }

type
  tUserInfo = record
                const cOpen  = '[ ';
                      cClose = ' ]';
                type  InfoType = (                             inIdAcFile, inHintUI, inAction, inWarning, inError );
                const Color    : array[InfoType] of TColor = ( clBlack,    clBlue,   clGreen,  clMaroon,  clRed );
                var   Save     : string;
                procedure Show( const s: string; Typ: InfoType = inIdAcFile );
                procedure ShowExtern( const s: string );
                procedure Restore;
              end;

var
  UserInfo  : tUserInfo;

(* ShowUserInfo *)
procedure tUserInfo.Show( const s: string; Typ: InfoType = inIdAcFile );
begin
  with frmMain.lblStatus do begin
    Font.Color := tUserInfo.Color[Typ];
    Caption := s;
    if Typ = inIdAcFile then Save := s
//    Repaint                // auskommentiert weil führt zu Absturz im ListBoxPaint ???  In ShowExtern reicht!
    end;
end;

procedure tUserInfo.ShowExtern( const s: string );
begin
  Show( s, inIdAcFile );
  frmMain.lblStatus.Repaint
end;

procedure tUserInfo.Restore;
begin
  frmMain.lblStatus.Font.Color := tUserInfo.Color[inIdAcFile];
  frmMain.lblStatus.Caption    := Save
end;

{$ENDREGION }

{$REGION '-------------- lstBox / tv - Variablen ---------------' }

const
  cListBoxIndent = 12;  // für noch fehlende Funktion

type
  tLstBoxModus   = ( lmNull, lmCnt, lmErr, lmAcc );
//  tErrBatch      = ( Save=6, Parse=7, Build=8, Compare=9 { in Listen} );

var
  CriticalWork   : boolean;
  LibraryAccess  : tAcTypeSet;

  ListBoxData    : record
                     Modus          : tLstBoxModus;
                     HoverAc        : pAcInfo;            // hierüber hovert der MausCursor gerade
                     EraseAc        : pAcInfo;            // der vorige hover, der jetzt noch gelöscht werden muss
                     EraseLine      : integer;
//                   Indent         : word;             // Einrückung der Listbox-Zeilen, nur teilweise im Code realisiert
                     AccessCount,
                     SelectedAcNr   : integer;
                     SelectedAc     : pAcInfo;
                     AcKontext,
                     AcBlockSize    : word;
                     AcCache        : record {$IFDEF TraceDx} Hit, Miss, {$ENDIF} idx: integer; pAc: pAcInfo end;
                                    // idx = AcIdx des AktPid im aktuellen AktPid-Ac; pAc = Ac von diesem Index (der idx-te in der Kette)
                     GetCache       : record idx: integer; pAc: pAcInfo end;
                     MouseDownX,
                     MouseDownY     : integer;
                   end;

{$ENDREGION }

{$REGION '-------------- Scroll-/PaintBox ---------------' }

procedure SetActiveModeCount( lm: tLstBoxModus ); forward;
procedure SelectAccess( a: integer ); forward;
procedure SetAccessLinesCount( a: integer ); forward;

const
  cLastTreeError = 'Last TreeView-Error';

type
  {$IFDEF TraceDx}
  tTV            = class end;                          // nur zur Trace-Benamung
  {$ENDIF}
  tMyTreeView    = record
                   private
                     type  tScrollPos = integer;       // Cardinal hat keinen Zweck weil TScrollBar auf integer begrenzt
                     const cNoIndex   = 0;
                     class var ItemHeight: word;       // ItemsPerPage sind in ScrollBarTv.LargeChange
                               ItemWidth : word;
                     var
                     FirstNode,
                     LastNode,
                     TopNode,
                     AktNode             : pIdInfo;
                     MaxIndex,                        // Kopie aus FirstNode^.prev^.SubCount
                     TopIndex,                        // Zeilen# TopNode, bezogen auf ALLE GERADE SICHTBAREN Nodes
                     AktIndex            : tScrollPos;           // Zeilen# AktNode,    "
                     class procedure Init;                                                       static;
                     class procedure SetClassData;                                               static;
                     class procedure OnResize;                                                   static;
                     class procedure PreParse;                                                   static;
                     class procedure PrepareTreeViewAll;                                         static;
                     class procedure CollapseSub   ( pId: pIdInfo );                             static;
                     class procedure CollapseSubAll( pId: pIdInfo );                             static;
                     class procedure ExpandSub     ( pId: pIdInfo );                             static;
                     class procedure ExpandSubAll  ( pId: pIdInfo );                             static;
                           procedure OnVisiblesChange;
                     class procedure GetNext    ( var pId: pIdInfo; var X: word );               static;
                     class procedure GetPrev    ( var pId: pIdInfo; var X: word );               static;
                           procedure SetAktAbsPid ( pId: pIdInfo; TestOldAkt: boolean );
                     class function  ChangeAbsPid( pId: pIdInfo; TestOldAkt: boolean ): boolean; static;
                           procedure SetAktRel  ( Y: tScrollPos );
                     class function  getLevel   ( pId: pIdInfo ): word;                          static;
                     class procedure SetActivePid(p: pIdInfo);                                   static;
                           procedure SetTopRel(Y: tScrollPos);
                           procedure SetTopAbsIdx( Y: tScrollPos );
                   end;

var
  AktTv : tMyTrees;
  MyTv  : array[tMyTrees] of tMyTreeView;

(* tMyTreeView.Init *)
class procedure tMyTreeView.Init;
begin
  {$IFDEF TraceDx} TraceDx.Call( tTV, 'Init' ); {$ENDIF}
  AktTv := tvAll;
  SetClassData
end;

(* tMyTreeView.SetClassData *)
class procedure tMyTreeView.SetClassData;
begin
  {$IFDEF TraceDx} TraceDx.Call( tTV, 'SetClassData' ); {$ENDIF}
  frmMain.PaintBox.Canvas.Font.Height := frmMain.PaintBox.Font.Height;
  ItemHeight := round( -frmMain.PaintBox.Font.Height * 1.2 );
  ItemWidth  := round( frmMain.PaintBox.Canvas.TextWidth( '+' ) * 1.2 );
  frmMain.ScrollBarTv.LargeChange := frmMain.PaintBox.ClientHeight div ItemHeight - 1;     // eins kleiner als sichtbare Items
  {$IFDEF TraceDx} TraceDx.Send( 'LargeChange', frmMain.ScrollBarTv.LargeChange, ItemWidth ); {$ENDIF}
  {$IFDEF TraceDx} TraceDx.Send( 'SetClassData2', ItemHeight, ItemWidth ); {$ENDIF}
//  SetMyTvData    // kommt aus FormResize noch oft genug
end;

(* tMyTreeView.OnResize *)
class procedure tMyTreeView.OnResize;
begin
  {$IFDEF TraceDx} TraceDx.Call( tTV, 'OnResize' ); {$ENDIF}
  frmMain.ScrollBarTv.LargeChange := frmMain.PaintBox.ClientHeight div tMyTreeView.ItemHeight - 1;     // eins kleiner als sichtbare Items
  {$IFDEF TraceDx} TraceDx.Send( 'LargeChange', frmMain.ScrollBarTv.LargeChange ); {$ENDIF}
  MyTv[AktTv].OnVisiblesChange
end;

(* OpenTreeDefault *)
function OpenTreeDefault: pIdInfo;
begin
  with MyTv[tvAll] do begin
    ExpandSub( @IdMainMain );
    ExpandSub( @MainBlock[mbBlock0] );
    AktNode  := MainBlock[mbBlock0].SubBlock;
    AktIndex := 1;
    if ( AktNode^.SubBlock = AktNode^.SubLast ) and     // nur ein Id vorhanden ...
       ( AktNode^.SubBlock <> nil )             and     // ... UND auch keiner darunter
       ( AktNode^.SubBlock^.SubBlock = nil ) then begin
      AktNode := AktNode^.NextId;     // nur das Program-begin unter p -> überspringen
      inc( AktIndex )
      end;
    if AktNode^.SubBlock <> nil then     // ist nil z.B. wenn Units alle nicht gefunden
      ExpandSub( AktNode );
    Result := AktNode
    end
end;

(* PreParse *)
class procedure tMyTreeView.PreParse;
begin
  {$IFDEF TraceDx} TraceDx.Call( tTV, 'PreParse' ); {$ENDIF}
  MyTv[tvAll].FirstNode := nil;
  MyTv[tvAll].LastNode  := nil;
  MyTv[_tvFil].FirstNode:= nil;
  MyTv[_tvFil].AktNode  := nil;
  MyTv[_tvFil].LastNode := nil;

  frmMain.ScrollBarTv.Position := 0;
  frmMain.PaintBoxPaint( nil );

  if AktTv = _tvFil then
    frmMain.actIdViewFilterExecute( nil );
end;

(* tMyTreeView.OnVisiblesChange *)
procedure tMyTreeView.OnVisiblesChange;

  procedure SetThumbTab( wincontrol: TWinControl );
//  var
//    TrackHeight: Integer; { The size of the scroll bar track }
//    MinHeight: Integer; { The default size of the thumb tab }
  begin
//    MinHeight := GetSystemMetrics( SM_CYVTHUMB ); { Save the default size. }
    with frmMain.ScrollBarTv do begin
      {$IFDEF TraceDx} TraceDx.Send( 'ScrollBarTv.Max'        , Max ); {$ENDIF}
      {$IFDEF TraceDx} TraceDx.Send( 'ScrollBarTv.LargeChange', LargeChange ); {$ENDIF}
//      TrackHeight := WinControl.ClientHeight - 2 * GetSystemMetrics( SM_CYVSCROLL );
//      PageSize    := TrackHeight div (( Max - Min + 1 ) * frmMain.lstBox.ItemHeight );
      if Max > 0
        then PageSize := round( Max * LargeChange / ( LargeChange + Max + 1  )) - 2 //div frmMain.lstBox.ItemHeight
        else PageSize := LargeChange;
//      if PageSize < MinHeight then
//        PageSize := MinHeight;
      {$IFDEF TraceDx} TraceDx.Send( 'PageSize', PageSize ); {$ENDIF}
      end;
  end;

begin
  if FirstNode <> nil then begin
    MaxIndex := IdMainMain.OpenCount[AktTv] - 1;
    {$IFDEF TraceDx} TraceDx.Call( tTV, 'OnVisiblesChange', MaxIndex ); {$ENDIF}
    if MaxIndex <= frmMain.ScrollBarTv.LargeChange
      then frmMain.ScrollBarTv.Max := 0
      else frmMain.ScrollBarTv.Max := MaxIndex - frmMain.ScrollBarTv.LargeChange;

    if TopIndex > frmMain.ScrollBarTv.Max then
      { Durch ein Collapse steht TopIndex hinter dem maximal erlaubten -> korrigieren: }
      SetTopRel( frmMain.ScrollBarTv.Max - TopIndex );

//    SetThumbTab( frmMain.ScrollBarTv );    ICH KRIEGS NICHT HIN !

    frmMain.PaintBox.Invalidate
    end
end;

(* DeltaToParents *)
procedure DeltaToParents( pId: pIdInfo; d: integer );
begin
  {$IFDEF TraceDx} TraceDx.Call( tTV, 'DeltaToParents', d ); {$ENDIF}
  while pId <> @IdMainMain do begin
    pId := pId^.PrevBlock;
    inc( pId^.OpenCount[AktTv], d )
    end;
  MyTv[AktTv].OnVisiblesChange
end;

(* tMyTreeView.PrepareTreeViewAll *)
class procedure tMyTreeView.PrepareTreeViewAll;
var m, Last: tMainBlock;

  procedure DelLibAcs( pId: pIdInfo );
  var pLast,
      pAc    : pAcInfo;
      pre    : ppAcInfo;
      DelAny : boolean;
      z      : tAcTypeSet;
  begin
    if not FileOptions.ProjectUsedOnly then exit;
    pAc    :=  pId^.AcList;
    pLast  := nil;
    pre    := @pId^.AcList;
    DelAny := false;
    z      := [];
    while pAc <> nil do begin
      if ( tAcFlags.AcProjectUse in pAc^.AcFlags ) or ( pAc^.ZugriffTyp = ac_Declaration )
        then begin pLast  := pAc ; pre  := @pAc^.NextAc; include( z, pAc^.ZugriffTyp ) end     // neu setzen weil NICHT entfernt wurde
        else begin DelAny := true; pre^ :=  pAc^.NextAc                                end;    // aus Verkettung entfernen
      pAc := pAc^.NextAc
      end;

  if DelAny then begin
    if z = [] then
      if pId^.Typ = id_NameSpace
        then pId^.AcSet  := [ac_Read]
        else pId^.AcSet  := z;
    pId^.LastAc := pLast
    end
  end;

  procedure PrepareDirektives( m: pIdInfo; const Liste: array of tIdInfo );
  var pre: ppIdInfo;
      i  : word;
  begin
    pre := @m^.SubBlock;
    { Verkettung der anzuzeigenden Elemente jetzt aufbauen: }
    for i := succ{weil das erste Element ist Dummy}( low( Liste )) to high( Liste ) do
      if ( Liste[i].AcList <> nil )  and
         ( not FileOptions.ProjectUsedOnly  or  ( tIdFlags2.IdProjectUse in Liste[i].IdFlags2 )) then begin
        pre^ := @Liste[i];
        pre  := @Liste[i].NextId;
        DelLibAcs( @Liste[i] )
        end
      else
        ; { dieses Element wird nicht gebraucht }
    pre^ := nil;

    if m^.SubBlock = nil
      then m^.AcSet := []
      else include( m^.IdFlagsTv[tvAll], tIdFlagsTv.hasSub )
  end;

  procedure PrepareLiterals( m: pIdInfo );
  var pre: ppIdInfo;
      pId: pIdInfo;
  begin
    if FileOptions.ProjectUsedOnly then begin
      pre := @m^.SubBlock;
      pId := m^.SubBlock;
      while pId <> nil do begin
        if tIdFlags2.IdProjectUse in pId^.IdFlags2
          then begin pre^ := pId; pre  := @pId^.NextId; DelLibAcs( pId )end
          else       pre^ := pId^.NextId;    // aus Verkettung entfernen
        pId := pId^.NextId
        end;
      pre^ := nil;
      end;
    if m^.SubBlock = nil
      then m^.AcSet := []
      else include( m^.IdFlagsTv[tvAll], tIdFlagsTv.hasSub )
  end;

  function  PrepareUnits( pId: pIdInfo ): boolean;
  var pre    : ppIdInfo;
      pLast,
      p0     : pIdInfo;
      DelAny,
      DelThis: boolean;
      s      : string;
      pIdg   : pIdInfo;
  begin
    p0     := pId^.PrevBlock;
//    {$IFDEF TraceDx} TraceDx.Call( tTV, 'Prepare unter', p0^.Name ); {$ENDIF}
    pre    := @p0^.SubBlock;
    pLast  := nil;
    DelAny := false;
    while pId <> nil do begin
      DelThis := false;
      if tIdFlags.IdVirtual in pId^.IdFlags then
        DelThis := true
      else if tIdFlags.OverloadUnresolved in pId^.IdFlags then begin
        { bei dieser Gelegenheit auch overloads für Anzeige umbenennen: }
        SetLength( pId^.Name, length( pId^.Name ) - length( cSymbolOverload ));
        pId^.Hash := GetHash( pId^.Name )
        end

      else begin
        if pId^.SubBlock = nil then begin
          if FileOptions.ProjectUsedOnly and not ( tIdFlags2.IdProjectUse in pId^.IdFlags2 ) then
            DelThis := true
          end
        else begin
          {*genShow: bei dieser Gelegenheit auch generics für Anzeige auf <T> umbenennen: }
          if ( tIdFlags.IsGenericDummy in pId^.SubBlock^.IdFlags ) then begin
            s := pId^.Name;
            if pId^.Typ = id_Type
              then s := s.Substring( 0, length(s ) - 2 )       + pId^.SubBlock^.Name + '>'       // Type
              else s := s                                + '<' + pId^.SubBlock^.Name + '>';      // Method
            pIdg := pId^.SubBlock^.NextId;
            while ( pIdg <> nil ) and ( tIdFlags.IsGenericDummy in pIdg^.IdFlags ) do begin
              s := s.Insert( length( s ) - 1, ',' + pIdg^.Name );
              pIdg := pIdg^.NextId
              end;
            pId^.Name := s;
            pId^.Hash := getHash( s )
            end;

          if PrepareUnits( pId^.SubBlock )
            then include( pId^.IdFlagsTv[tvAll], tIdFlagsTv.hasSub )
            else if FileOptions.ProjectUsedOnly and not ( tIdFlags2.IdProjectUse in pId^.IdFlags2 ) then
                   DelThis := true;
          end
        end;

      if DelThis
        then begin DelAny := true; pre^ :=  pId^.NextId                   end    // aus Verkettung entfernen
        else begin pLast  := pId ; pre  := @pId^.NextId; DelLibAcs( pId ) end;   // nur neu setzen wenn NICHT entfernt wurde

      pId := pId^.NextId
      end;

    if DelAny then
      p0^.SubLast := pLast;
    Result := p0^.SubBlock <> nil
  end;

  function  PrepareSys( pId: pIdInfo ): boolean;
  var pre    : ppIdInfo;
      pLast,
      p0     : pIdInfo;
      DelAny,
      DelThis: boolean;

    function SystemSubFncIsUsed( pId: pIdInfo ): boolean;
      begin
      { es kann z.B. Create unter TObject benutzt werden ohne Ac auf TObject. Dies hier feststellen: }
      while pId <> nil do begin
        if pId^.AcSet <> [] then begin
//          {$IFDEF TraceDx} TraceDx.Call( tTV, 'SystemSubFncIsUsed', pId^.Name ); {$ENDIF}
          exit( true )
          end;
        pId := pId^.NextId
        end;
      Result := false
      end;

  begin
    p0     := pId^.PrevBlock;
    {$IFDEF TraceDx} TraceDx.Call( tTV, 'PrepareSys unter', p0^.Name ); {$ENDIF}
    pre    := @p0^.SubBlock;
    pLast  := nil;
    DelAny := false;

    while pId <> nil do with pId^ do begin
      DelThis := false;

      if Typ in [id_NameSpace, id_Unit] then begin
          { Es wurden Einträge wie System.Win.xxx erzeugt: }
          if SubBlock <> nil then begin
              include( IdFlagsTv[tvAll], tIdFlagsTv.hasSub );
              DelThis := not PrepareUnits( pId^.SubBlock );
              end;
          end

      else
          if FileOptions.ProjectUsedOnly then
              if SubBlock = nil then
                  if AcList = nil
                      then DelThis := true
                      else if tIdFlags2.IdProjectUse in IdFlags2
                               then // okay
                               else DelThis := true
              else
                  if tIdFlags2.IdProjectUse in IdFlags2 then begin
                      if not ( tIdFlags.IsParameter in SubBlock^.IdFlags ) then begin
                          if PrepareUnits( SubBlock ) then begin
                              AcSet := [ac_Read];
                              include( IdFlagsTv[tvAll], tIdFlagsTv.hasSub )
                              end
                          end
                      end
                  else
                      {if not ( tIdFlags.IsParameter in SubBlock^.IdFlags ) and PrepareUnits( SubBlock )
                          then include( IdFlagsTv[tvAll], tIdFlagsTv.hasSub )
                          else} DelThis := true

          else
              if SubBlock = nil then
                  if AcList = nil
                      then DelThis := true
                      else // okay
              else
                  if AcList = nil
                      then if not ( tIdFlags.IsParameter in SubBlock^.IdFlags ) and SystemSubFncIsUsed( SubBlock ) and PrepareUnits( SubBlock ) then begin
                               AcSet := [ac_Read];
                               include( IdFlagsTv[tvAll], tIdFlagsTv.hasSub )
                               end
                           else
                               DelThis := true
                      else if not ( tIdFlags.IsParameter in SubBlock^.IdFlags ) then
                               include( IdFlagsTv[tvAll], tIdFlagsTv.hasSub );

      if DelThis
          then begin DelAny := true; pre^ :=  pId^.NextId end                      // aus Verkettung entfernen
          else begin pLast  := pId ; pre  := @pId^.NextId; DelLibAcs( pId ) end;   // nur neu setzen wenn NICHT entfernt wurde

      pId := pId^.NextId
      end;

    if DelAny then
        p0^.SubLast := pLast;
    Result := p0^.SubBlock <> nil
  end;

  procedure PrepareFiles;
  var pId:  pIdInfo;
      pre: ppIdInfo;
  begin
    pre := @pPathIds;
    pId :=  pPathIds;
    while pId <> nil do begin
      if ( pId^.SubBlock = nil ) or ( FileOptions.ProjectUsedOnly and not ( tIdFlags2.IdProjectUse in pId^.IdFlags2 ))
        then pre^ :=  pId^.NextId
        else pre  := @pId^.NextId;
      pId := pId^.NextId
      end;
    MainBlock[mbFilenames].SubLast^.NextId := pPathIds;
    if PrepareUnits( @MainBlock[mbFilenames] ) then
      include( MainBlock[mbFilenames].IdFlagsTv[tvAll], tIdFlagsTv.hasSub );
    // unbenutzte Paths entfernen
  end;

begin
  {$IFDEF TraceDx} TraceDx.Call( tTV, 'PrepareTreeViewAll' ); {$ENDIF}
  frmMain.ActiveControl := frmMain.ScrollBarTv;
  if ZaehlerAcs = 0 then begin
    ShowMessage( 'No identifiers in Source' )
    end
  else begin
    MyTv[tvAll].FirstNode:= @MainBlock[mbBlock0];
    MyTv[tvAll].TopNode  := MyTv[tvAll].FirstNode;
    MyTv[tvAll].TopIndex := 0;
    MyTv[tvAll].AktNode  := MyTv[tvAll].FirstNode;
    MyTv[tvAll].AktIndex := 0;

    PrepareDirektives( @MainBlock[mbPascalDirs]  , PascalDirektiveListe );   // als erstes,
    PrepareDirektives( @MainBlock[mbCompilerDirs], ControlsListe        );   // weil SubBlock von folgender Schleife gebraucht wird
    if FileOptions.RegKeywords or FileOptions.RegKeySymbols
      then PrepareDirektives( @MainBlock[mbKeyWords], KeyWordListe      )   // weil SubBlock von folgender Schleife gebraucht wird
      else MainBlock[mbKeyWords].AcSet := [];

    for m in [mbConstInt .. mbConstStrings, mbDefines, mbAttributes] do
      PrepareLiterals( @MainBlock[m] );

    if not UseClipBoard then
      PrepareFiles;

    if UnitSystem.NextId <> nil then { =nil wenn keine Unit ausser System vorhanden }
      PrepareUnits( UnitSystem.NextId ); // Unit "System" erstmal überspringen, ab erster echten Unit
    include( MainBlock[mbBlock0].IdFlagsTv[tvAll], tIdFlagsTv.hasSub );

    { System: }
    if PrepareSys( UnitSystem.SubBlock )     // Unit "System"
      then include( UnitSystem.IdFlagsTv[tvAll], tIdFlagsTv.hasSub )
      else UnitSystem.AcSet := [];
    {*genShow: TArray<1> nach TArray<T> }
    pSysId[syTArray]^.Name[7] := 'T';

    if ( MainBlock[mbUnDeclaredUnScoped].SubBlock <> nil ) and PrepareUnits( MainBlock[mbUnDeclaredUnScoped].SubBlock )
      then include( MainBlock[mbUnDeclaredUnScoped].IdFlagsTv[tvAll], tIdFlagsTv.hasSub )
      else MainBlock[mbUnDeclaredUnScoped].AcSet := [];

    if ( MainBlock[mbFilenames].SubBlock <> nil ) and PrepareUnits( MainBlock[mbFilenames].SubBlock )
      then include( MainBlock[mbFilenames].IdFlagsTv[tvAll], tIdFlagsTv.hasSub )
      else MainBlock[mbFilenames].AcSet := [];

    Last := high( tMainBlock );
    for m := mbBlock0 to high( tMainBlock ) do
      if MainBlock[m].AcSet <> [] then begin
        MainBlock[Last].NextId := @MainBlock[m];
        Last := m;
        inc( IdMainMain.OpenCount[tvAll] )
        end;
    MainBlock[Last].NextId := nil
    end
end;

(* tMyTreeView.CollapseSub     Key LEFT *)
class procedure tMyTreeView.CollapseSub( pId: pIdInfo );
begin
  {$IFDEF TraceDx} TraceDx.Call( tTV, 'CollapseSub', pId^.Name ); {$ENDIF}
  if tIdFlagsTv.SubTreeOpen in pId^.IdFlagsTv[AktTv] then begin
    exclude( pId^.IdFlagsTv[AktTv], tIdFlagsTv.SubTreeOpen );
    DeltaToParents( pId, -pId^.OpenCount[AktTv] );
    pId^.OpenCount[AktTv] := 0
    end
end;

(* TestInTree *)
function TestInTree( pId: pIdInfo ): boolean; inline;
begin
  Result := ( pId^.AcSet <> [] ) and (( AktTv = tvAll ) or ( tIdFlagsDyn.isFiltered in pId^.IdFlagsDyn ))
//  Result := (( AktTv = tvAll  ) and ( pId^.AcSet <> []                          )) or
//            (( AktTv = _tvFil ) and ( tIdFlagsDyn.isFiltered in pId^.IdFlagsDyn ))
end;

(* tMyTreeView.CollapseSubAll    --- *)
class procedure tMyTreeView.CollapseSubAll( pId: pIdInfo );

  procedure Collapse( pId: pIdInfo );
  begin
    while pId <> nil do begin
      if TestInTree( pId ) then begin
        exclude( pId^.IdFlagsTv[AktTv], tIdFlagsTv.SubTreeOpen );
        pId^.OpenCount[AktTv] := 0;
        if tIdFlagsTv.hasSub in pId^.IdFlagsTv[AktTv] then
          Collapse( pId^.SubBlock )
        end;
      pId := pId^.NextId
      end;
  end;

begin
  {$IFDEF TraceDx} TraceDx.Call( tTV, 'CollapseSubAll', pId^.Name ); {$ENDIF}
  if tIdFlagsTv.SubTreeOpen in pId^.IdFlagsTv[AktTv] then begin
    exclude( pId^.IdFlagsTv[AktTv], tIdFlagsTv.SubTreeOpen );
    Collapse( pId^.SubBlock );
    DeltaToParents( pId, -pId^.OpenCount[AktTv] );
    pId^.OpenCount[AktTv] := 0
    end
end;

(* tMyTreeView.ExpandSub      Key RIGHT,  SetAktAbsPid, insbesondere nach Init *)
class procedure tMyTreeView.ExpandSub( pId: pIdInfo );
var p: pIdInfo;
begin
  {$IFDEF TraceDx} TraceDx.Call( tTV, 'ExpandSub', pId^.Name ); {$ENDIF}
  if ( tIdFlagsTv.hasSub in pId^.IdFlagsTv[AktTv] ) and not ( tIdFlagsTv.SubTreeOpen in pId^.IdFlagsTv[AktTv] ) then begin
    assert( pId^.OpenCount[AktTv] = 0, 'OpenCount' );
    include( pId^.IdFlagsTv[AktTv], tIdFlagsTv.SubTreeOpen );
    p := pId^.SubBlock;
    while p <> nil do begin
      if TestInTree( p ) then
        inc( pId^.OpenCount[AktTv], p^.OpenCount[AktTv] + 1 );
      p := p^.NextId
      end;
    { OpenCount an Parents weiterreichen: }
    DeltaToParents( pId, pId^.OpenCount[AktTv] )
    end
end;

(* tMyTreeView.ExpandSubAll     Key RETURN,  (zZ PostParse) *)
class procedure tMyTreeView.ExpandSubAll( pId: pIdInfo );
var neu: integer;

  function Expand( pId: pIdInfo ): integer;
  begin
//    {$IFDEF TraceDx} TraceDx.Call( tTV, 'Expand', pId^.PrevBlock^.Name ); {$ENDIF}
    Result := 0;
    while pId <> nil do begin
      if TestInTree( pId ) then begin
        inc( Result );
        if tIdFlagsTv.hasSub in pId^.IdFlagsTv[AktTv] then begin
          include( pId^.IdFlagsTv[AktTv], tIdFlagsTv.SubTreeOpen );
          pId^.OpenCount[AktTv] := Expand( pId^.SubBlock );
          inc( Result, pId^.OpenCount[AktTv] )
          end
        else
          exclude( pId^.IdFlagsTv[AktTv], tIdFlagsTv.SubTreeOpen )
        end;
      pId := pId^.NextId
      end;
  end;

begin
  {$IFDEF TraceDx} TraceDx.Call( tTV, 'ExpandSubAll', pId^.Name ); {$ENDIF}
  if tIdFlagsTv.hasSub in pId^.IdFlagsTv[AktTv] then begin
    neu := Expand( pId^.SubBlock ) - pId^.OpenCount[AktTv];
    include( pId^.IdFlagsTv[AktTv], tIdFlagsTv.SubTreeOpen );
    { OpenCount an Parents weiterreichen: }
    pId^.OpenCount[AktTv] := neu;
    DeltaToParents( pId, neu )
    end
end;

(* getLevel *)
class function tMyTreeView.getLevel( pId: pIdInfo ): word;
begin
//  {$IFDEF TraceDx} TraceDx.Call( tTV, 'getLevel', pId^.Name ); {$ENDIF}
  Result := 0;
  while pId <> @IdMainMain do begin
    pId := pId^.PrevBlock;
    inc( Result )
    end;
  dec( Result )    // IdMainMain und MainBlock[] waren zuviel
end;

(* CheckViaInAcIdList *)
function CheckViaInAcIdList( pAc: pAcInfo ): boolean;
var pAcViaTmp: pAcInfo;
begin
  Result := false;
  { Ist pAcVia^.Id irgendwo in der Ac-Liste vorhanden? }
  while pAc <> nil do
    if pAc^.IdDeclare = pAcVia^.IdDeclare
      then break
      else pAc := pAc^.AcPrev;

  { Ok, wenn ab dort dann alle pAc^.Id übereinstimmen }
  if pAc <> nil then begin
    pAcViaTmp := pAcVia^.AcPrev;
    while pAcViaTmp <> nil do begin
      pAc := pAc^.AcPrev;
      if ( pAc <> nil ) and ( pAc^.IdDeclare = pAcViaTmp^.IdDeclare )
        then pAcViaTmp := pAcViaTmp^.AcPrev
        else break
      end;
    if pAcViaTmp = nil then
      Result := true
    end
end;

function CheckUnitInIdUseList( pId: pIdInfo ): boolean;
begin
  repeat if pId^.Typ in [id_Unit, id_Program, id_NameSpace, id_MainBlock]
           then exit( pId = pIdUnitOnly )
           else pId := pId^.PrevBlock
  until  pId = nil;
  Result := false
end;

(* SetActivePid *)
class procedure tMyTreeView.SetActivePid( p: pIdInfo );
const cNur1 : array[boolean] of string = ( 's', '' );
      cSepa     = '       ';
var pAc: pAcInfo;
    sel,
    a,c,f   : integer;
    changed,
    b       : boolean;
    s       : string;

  (* CheckPidAccesses *)
  procedure CheckPidAccesses;
  var a: pAcInfo;
      m: tFileIndex_;                    // minimaler FileIndex mit Access wird TreeView.TopIndex
      i: tFileIndex;
  begin
    m := high( DateiListe );
//    frmMain.tvFiles.Items.BeginUpdate;               // tvFiles-Expand/Collapse auskommentiert weil zu langsam
    for i := cFirstFile to high( DateiListe ) do DateiListe[i]^.PidAccess := [];
    LibraryAccess := [];
//    frmMain.tvFiles.FullCollapse;
    a := p^.AcList;
    f := 0;
    while a <> nil do with DateiListe[a^.Position.Datei]^ do begin
      if PidAccess = [] then inc( f );
      if a^.Position.Datei < m then m := a^.Position.Datei;
      include( PidAccess, a^.ZugriffTyp );
      if tFileFlags.LibraryPath in fiFlags
        then include( LibraryAccess, a^.ZugriffTyp );
//        else MyNode.MakeVisible;
      a := a^.NextAc
      end;
    if frmMain.ActiveControl <> frmMain.tvFiles then
      frmMain.tvFiles.TopItem := DateiListe[m].MyNode;       // die erste Datei mit Ac als Top anzeigen, alle anderen sind DARUNTER
//    frmMain.tvFiles.Items.EndUpdate;
    frmMain.tvFiles.Repaint
  end;

  function getFlags: string;
  begin
    if InterfaceSection in p^.IdFlags2
      then Result := 'I'
      else Result := '';
    if IsStrict in p^.IdFlags then
      Result := Result + 'S';
    if IsPrivate in p^.IdFlags then
      Result := Result + 'P';
    if IsProtected in p^.IdFlags then
      Result := Result + 'p';
    if Result <> '' then
      Result := ' / ' + Result
  end;

(* SetActivePid *)
begin
  {$IFDEF TraceDx} TraceDx.Call( tTV, 'SetActivePid', MyTv[AktTv].AktIndex.ToString, TListen.pIdName( p ) ); {$ENDIF}
  frmMain.PaintBox.Invalidate;
  frmMain.lstBox.Cursor := crDefault;
  if ListBoxData.Modus <> lmAcc then SetActiveModeCount( lmAcc );

  if MyTv[AktTv].AktNode <> nil then
    with MyTv[AktTv].AktNode^.lstBox do begin
      LastTop  := frmMain.lstBox.TopIndex;
      SelectNr := ListBoxData.SelectedAcNr;
      SelectAc := ListBoxData.SelectedAc
      end;

  changed := p <> MyTv[AktTv].AktNode;
  if changed then begin
    MyTv[AktTv].LastNode := MyTv[AktTv].AktNode;
    if not ( p^.Typ in [id_Impl, id_MainBlock] ) then
      frmHistory.AddItem( p );

    MyTv[AktTv].AktNode  := p;
//    frmMain.PaintBox.Tag := NativeInt( p );    // Pfui, nur für Varifikation
    frmMain.actRefDeclaration.Enabled := ac_Declaration in p^.AcSet;

    frmMain.actRefsWriteOnly .Enabled := p^.AcSet * [ac_Write, ac_ReadAdress] <> [];
    frmMain.actRefsWriteOnly .Checked := frmMain.actRefsWriteOnly .Enabled  and  ( tIdFlagsDyn.WriteOnly in p^.IdFlagsDyn );

    frmMain.actRefsViaSelect .Enabled := p^.Typ in [id_Var, id_Property, id_Proc, id_Func, id_Unbekannt];
    frmMain.actRefsViaOnly   .Enabled := frmMain.actRefsViaSelect.Enabled  and  ( pAcVia <> nil );
    frmMain.actRefsViaOnly   .Checked := tIdFlagsDyn.ViaOnly in p^.IdFlagsDyn;

    frmMain.cboBoxUnits      .Enabled := not ( p^.Typ in [id_Unbekannt..id_Program] );
    pIdUnitOnly := nil;
    frmMain.chkBoxUnitOnly   .Enabled := p^.MyUnitOnly > 0;
    frmMain.chkBoxUnitOnly   .Checked := tIdFlagsDyn.UnitOnly in p^.IdFlagsDyn;
    if MyTv[AktTv].AktNode^.MyUnitOnly <> 0 then begin
      frmMain.cboBoxUnits.ItemIndex := -1;
      frmMain.cboBoxUnitsDropDown( nil );
      frmMain.cboBoxUnits.ItemIndex := p^.MyUnitOnly - 1;
      if frmMain.chkBoxUnitOnly.Checked
        then frmMain.cboBoxUnitsClick( nil )
      end
    else
      frmMain.cboBoxUnits.Items.Clear
    end;

  ListBoxData.SelectedAcNr := -1;
  ListBoxData.SelectedAc   := nil;
  ListBoxData.AcCache.idx  := -1;
  ListBoxData.GetCache.idx := -2;    // -1 ist für getNextAc() -> Nachfolger-suchen nicht ausreichend

  CheckPidAccesses;

  frmMain.PopupItmIdSort.Enabled :=
    ( AktTv = tvAll )  and
      ( (( p^.SubBlock <> nil ) and ( p^.Typ in [id_MainBlock, id_NameSpace..id_Func{, id_CompilerDefine, id_CompilerAttribute}] ))  or
        (( p^.SubBlock =  nil ) and ( p^.Typ in [              id_NameSpace..id_Impl, id_KeyWord] )) );

  if frmMain.PopupItmIdSort.Enabled then
    frmMain.PopupItmIdSort.Caption := ifthen( p^.SubBlock = nil, 'Sort this', 'Sort Sub' ) + ' Ids (no undo)';

  frmMain.PopupItmIdRename.Enabled := ( p^.Typ in [id_Unbekannt..id_Impl, id_KeyWord] ) and
                                      ( p^.AcList <> nil )                              and
                                      ( p^.IdFlags * [tIdFlags.IsDummy{, tIdFlags.IsOverload}] = [] );

  frmMain.actIdFilterHierarchy.Enabled := p^.IdFlags * [tIdFlags.IsClassType, tIdFlags.IsInterface] <> [];

  (*if p = nil then begin              // Blöcke CONST, Standard, Dateien, ...
    frmMain.lstBox.Count  := 0;
    ListBoxData.HoverAc := nil;
    frmMain.StatusBar.SimpleText := ''
    end
  else begin*)

    { Anzahl Acs ermitteln: }
    a   := 0;
    c   := 0;  // letzter enthaltener
    sel := 0;
    pAc := p^.AcList;
    while pAc <> nil do begin
      b := ( not ( tIdFlagsDyn.WriteOnly in p^.IdFlagsDyn ) or ( pAc^.ZugriffTyp <> ac_Read ))       and
           ( not ( tIdFlagsDyn.UnitOnly  in p^.IdFlagsDyn ) or   CheckUnitInIdUseList( pAc^.IdUse )) and
           ( not ( tIdFlagsDyn.ViaOnly   in p^.IdFlagsDyn ) or   CheckViaInAcIdList( pAc )   )       ;

      if pAc = MyTv[AktTv].AktNode.lstBox.SelectAc then
        { Selected synchronisieren: }
        if b
          then sel := a
          else sel := a-1;

      inc( c );
      if b then inc( a );
      pAc := pAc^.NextAc
      end;
    {$IFDEF TraceDx} TraceDx.Send( tTV, 'SetSel', sel ); {$ENDIF}

    if p^.Typ in [id_MainBlock, id_FileLibrary] then
      UserInfo.Show( tUserInfo.cOpen + cIdShow[p^.Typ].Text + tUserInfo.cClose, tUserInfo.InfoType.inIdAcFile )
    else begin
      if p^.Typ = id_Filename
        then s := tUserInfo.cOpen + cIdShow[p^.Typ].Text +            tUserInfo.cClose + '  ' + p^.Name
        else s := tUserInfo.cOpen + cIdShow[p^.Typ].Text + getFlags + tUserInfo.cClose + '  ' + TListen.getBlockNameLong( p, dTrennView );
      {$IFDEF DEBUG} s := s + '  #' + p^.DebugNr.ToString; {$ENDIF}
      if p^.MyType <> nil then
        s := s + cSepa + 'Type = ' + p^.MyType^.Name;
      if p^.MyParent <> nil then
        s := s + cSepa + 'Parent = ' + p^.MyParent^.Name;
      UserInfo.Show( s + cSepa + ifthen( a = c, '', a.ToString + '/' ) + c.ToString + ' Reference' + cNur1[c=1] + ' [' + TListen.ShowAcSet( p^.AcSet ) + ']' + cSepa + 'in ' + f.ToString + ' File' + cNur1[f=1], tUserInfo.InfoType.inIdAcFile );
      end;

    MyTv[AktTv].AktNode.lstBox.SelectNr := -1;
    SetAccessLinesCount( a );
    if a > 0 then begin
      SelectAccess( sel );
      frmMain.lstBox.TopIndex := MyTv[AktTv].AktNode.lstBox.LastTop
      end;
end;

(* SetAktAbsPid *)
procedure tMyTreeView.SetAktAbsPid( pId: pIdInfo; TestOldAkt: boolean );
var i, X: word;

  procedure DoOpenSub( p0: pIdInfo );
  var p: pIdInfo;
  begin
    {$IFDEF TraceDx} TraceDx.Call( tTV, 'DoOpenSub', p0^.Name ); {$ENDIF}
    if p0^.PrevBlock <> @IdMainMain then begin
      DoOpenSub( p0^.PrevBlock );
      inc( AktIndex )
      end;

    if  ( tIdFlagsTv.hasSub in p0^.IdFlagsTv[AktTv] ) and not ( tIdFlagsTv.SubTreeOpen in p0^.IdFlagsTv[AktTv] ) then
      if p0 <> pId { nur die Ebenen ÜBER dem ZielAktPid öffnen} then ExpandSub( p0 );

    p := p0^.PrevBlock^.SubBlock;
    while p <> p0 do begin
      if TestInTree( p )
        then inc( AktIndex, p^.OpenCount[AktTv] + 1 );
      p := p^.NextId
      end
  end;

  procedure MakeVisible;
  var X: word;
  begin
    { in sichtbaren Bereich verschieben: }
    TopNode  := AktNode;
    TopIndex := AktIndex;
    if AktIndex = 0 then
      frmMain.ScrollBarTv.Position := 0
    else
      if TopIndex - 1 <= frmMain.ScrollBarTv.Max then begin
        X := high( X ) shr 1;     // Dummy für getNext
        dec( TopIndex );
        getprev( TopNode, X );
        frmMain.ScrollBarTv.Position := TopIndex;
        frmMain.PaintBox.Invalidate
        end
      else     //  todo:  TopIndex zu gross!?
        SetTopRel( frmMain.ScrollBarTv.Max - TopIndex )
  end;

begin
  {$IFDEF TraceDx} TraceDx.Call( tTV, 'SetAktAbsPid', pId^.Name ); {$ENDIF}
//  if pId^.Hash <> cNoHash{sonst DummyId} then      // war mal drin, wegen Absturz???
    if TestOldAkt and ( AktNode = pId ) then
      MakeVisible
    else begin
      AktIndex := 0;
      DoOpenSub( pId );
      SetActivePid( pId );
      { ist pId weiterhin unter bisherigem TopNode sichtbar? }
        X := high( X ) shr 1;     // Dummy für getNext
        i := 0;
        pId := TopNode;
        while ( pId <> AktNode ) and ( i < frmMain.ScrollBarTv.LargeChange ) do begin
          getNext( pId, X );
          inc( i )
          end;
      { ggf sichtbar machen: }
      if pId <> AktNode then
        MakeVisible
      end
end;

(* ChangeAbsPid *)
class function tMyTreeView.ChangeAbsPid( pId: pIdInfo; TestOldAkt: boolean ): boolean;
{ SetAktAbsPid vorgeschaltet um ggf aus FilterView umzuschalten: }
begin
  Result := ( tIdFlags2.IdProjectUse in pId^.IdFlags2 ) or not FileOptions.ProjectUsedOnly;
  if Result then begin
    if ( AktTv = _tvFil ) and not ( tIdFlagsDyn.isFiltered in pId^.IdFlagsDyn ) then
      frmMain.actIdViewFilterExecute( frmMain.actIdViewFilter );
    MyTv[AktTv].SetAktAbsPid( pId, TestOldAkt )
    end
  else
    MessageDlg( '"' + pId^.Name +  '" is Library-internal and therefore hidden.' + sLineBreak + sLineBreak + 'You may want to reparse after unchecking ' + sLineBreak + 'Project-Option "Hide Library-internals" (Ctrl-F11).', mtError, [mbOK], 0 )
end;

(* SetAktRel *)
procedure tMyTreeView.SetAktRel( Y: tScrollPos );
{ aus MouseDown: Click in sichtbaren Bereich   oder   KeyDown wenn AktNode visible
{ Y := relativ zum TopIndex: -1, 0..ItemsVisible-1, ItemsVisible }
var pId: pIdInfo;
    i,X: word;
begin
  {$IFDEF TraceDx} TraceDx.Call( tTV, 'SetAktRel', Y ); {$ENDIF}
  if Y < 0 then begin
    AktIndex := 0;
    pId := FirstNode
    end
  else begin
     if TopIndex + Y > MaxIndex then
       Y := MaxIndex - TopIndex;      // nicht übers Ende hinaus schiessen
     pId := TopNode;
     X := high( X ) shr 1;     // Dummy für getNext
     for i := 1 to Y do begin
       getNext( pId, X );
       {if pId = nil then begin pId := nil; exit end}
       end;
     AktIndex := TopIndex + Y
     end;
  SetActivePid( pId )
end;

(* SetTopRel *)
procedure tMyTreeView.SetTopRel( Y: tScrollPos );
{ aus ScrollBar: Verschiebung um +/- 1 oder LargeChange: }
var X: word;
    i: tScrollPos;
begin
  { nur für kleine (relative) Verschiebungen: TopIndex an Scroll.Position anpassen: }
  {$IFDEF TraceDx} TraceDx.Call( tTV, 'SetTopRel', Y ); {$ENDIF}
  X := high( X ) shr 1;     // Dummy für getNext
  with frmMain do begin
    if Y >= 0 then begin
      if TopIndex + Y > ScrollBarTv.Max then
        Y := ScrollBarTv.Max - TopIndex;    // nicht hinter das letzte
      for i := 1 to Y do getNext( TopNode, X )
      end
    else begin
      if TopIndex + Y < 0 then
        Y := -TopIndex;                      // nicht vor das erste
      for i := -1 downto Y do getPrev( TopNode, X )
      end;
    inc( TopIndex, Y );
    ScrollBarTv.Position := TopIndex;
    PaintBox.Invalidate
    end
end;

(* SetTopAbsIdx *)
procedure tMyTreeView.SetTopAbsIdx( Y: tScrollPos );
var X: word;
{ aus ScrollBar: Verschiebung auf Position Y. Y ist per Definition sichtbar, kein Expand notwendig }
begin
  if TopIndex <> Y then begin    // "=" nach ScrollBar scTrack und zum Abschluss nochmal scPosition
    {$IFDEF TraceDx} TraceDx.Call( tTV, 'SetTopAbsIdx', Y ); {$ENDIF}
    X := high( X ) shr 1;     // Dummy für getNext
    TopIndex := 0;
    TopNode  := FirstNode;
    while TopIndex <> Y do begin
      inc( TopIndex );
      if Y < TopIndex + TopNode^.OpenCount[AktTv] then
        getNext( TopNode, X )                                           // nächsten IM SUBLOCK!
      else begin
        inc( TopIndex, TopNode^.OpenCount[AktTv] );
        repeat TopNode := TopNode^.NextId until TestInTree( TopNode )   // nächsten auf gleicher Ebene
        end
      end;
    frmMain.ScrollBarTv.Position := Y
    end;
  frmMain.PaintBox.Invalidate
end;

(* GetNext *)
class procedure tMyTreeView.GetNext( var pId: pIdInfo; var X: word );
begin
//  {$IFDEF TraceDx} TraceDx.Call( tTV, 'GetNext<', pId^.Name ); {$ENDIF}
  repeat
    if ( pId = nil ) {or ( pId^.AcSet = [] )} then
//      Error( errAcSet, 'GetNext' );
       exit;
    if ( tIdFlagsTv.hasSub in pId^.IdFlagsTv[AktTv] ) and ( tIdFlagsTv.SubTreeOpen in pId^.IdFlagsTv[AktTv] ) then begin
      pId := pId^.SubBlock;
      try inc( X )
      except ShowMessage( cLastTreeError )
      end
      end
    else begin
      while pId^.NextId = nil do begin
        pId := pId^.PrevBlock;
        (*if pId = FirstNode then begin
          pId := nil;
          {$IFDEF TraceDx} TraceDx.Send( tTV, 'GetNext> nil' ); {$ENDIF}
          exit
          end;*)
        try dec( X )
        except ShowMessage( cLastTreeError )
        end
        end;
      pId := pId^.NextId                    // Vorschlag um auf   "until ( pId^.AcSet <> [] )" zu verzichten (hier und im Expand/Collapse):
      end                                   // (1) System-Original-Verkettung sichern    (2) System nur benutzte neu verketten       (0) Virtual ist ja schon raus!
  until TestInTree( pId );    // Unit System hat Ids ohne Nutzung
//  {$IFDEF TraceDx} TraceDx.Send( tTV, 'GetNext>', pId^.Name ) {$ENDIF}
end;

(* GetPrev *)
class procedure tMyTreeView.GetPrev( var pId: pIdInfo; var X: word );
var p0,pNext: pIdInfo;
begin
//  {$IFDEF TraceDx} TraceDx.Call( tTV, 'GetPrev<', pId^.Name ); {$ENDIF}
  if pId = nil then exit;
  p0  := pId;
  pId := pId^.PrevBlock;
  try dec( X )
  except ShowMessage( cLastTreeError )
  end;
  if pId^.SubBlock <> p0 then begin
    pNext := pId;
    repeat pId := pNext;
           getNext( pNext, X )
     until pNext = p0;
    end;
//  {$IFDEF TraceDx} TraceDx.Send( tTV, 'GetPrev>', pId^.Name ) {$ENDIF}
end;

(* ScrollBarTvEnterExit *)
procedure TfrmMain.ScrollBarTvEnterExit( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'ScrollBarTvEnterExit' ); {$ENDIF}
  PaintBox.Invalidate
end;

(* KeyDown *)
procedure TfrmMain.ScrollBarTvKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
var d: integer;
begin
  if ListBoxData.Modus <> lmAcc then exit;
  {$IFDEF TraceDx} if not ( ( Key = VK_MENU{=Alt} ) or ( Key = VK_SHIFT ) or ( Key = VK_CONTROL ) ) then
                TraceDx.Call( 'ScrollBarTvKeyDown', Key ); {$ENDIF}
  with MyTv[AktTv] do if FirstNode <> nil then
    case Key of
    VK_DOWN:   if ssCtrl in Shift then
                 SetTopRel( +1 )
               else
                 if ( AktIndex < TopIndex ) or ( AktIndex > TopIndex + ScrollBarTv.LargeChange ) then
                   SetAktAbsPid( AktNode, true )    // nur in sichtbaren Bereich bringen OHNE AktNode-Wechsel
                 else
                   if AktIndex < MaxIndex then begin
                     if AktIndex = TopIndex + ScrollBarTv.LargeChange then
                       SetTopRel( +1 );       // AktIndex ganz unten -> Top verschieben
                     SetAktRel( AktIndex - TopIndex + 1 )
                     end;
    VK_NEXT:   if ( AktIndex < TopIndex ) or ( AktIndex > TopIndex + ScrollBarTv.LargeChange ) then
                 SetAktAbsPid( AktNode, true )    // nur in sichtbaren Bereich bringen OHNE AktNode-Wechsel
               else
                 if AktIndex < MaxIndex then begin
                   d := AktIndex - TopIndex;  // alt
                   SetTopRel( ScrollBarTv.LargeChange );
                   SetAktRel( d )
                   end;
    VK_UP    : if ssCtrl in Shift then
                   SetTopRel( -1 )       // AktIndex ganz unten -> Top verschieben
               else
                 if ( AktIndex < TopIndex ) or ( AktIndex > TopIndex + ScrollBarTv.LargeChange ) then
                   SetAktAbsPid( AktNode, true )    // nur in sichtbaren Bereich bringen OHNE AktNode-Wechsel
                 else
                   if AktIndex > 0 then begin
                     if AktIndex = TopIndex then
                       SetTopRel( -1 );       // AktIndex ganz unten -> Top verschieben
                     SetAktRel( AktIndex - TopIndex - 1 )
                     end;
    VK_PRIOR : if ( AktIndex < TopIndex ) or ( AktIndex > TopIndex + ScrollBarTv.LargeChange ) then
                 SetAktAbsPid( AktNode, true )    // nur in sichtbaren Bereich bringen OHNE AktNode-Wechsel
               else
                 if AktIndex > 0 then
                   begin
                   d := AktIndex - TopIndex;  // alt
                   SetTopRel( -ScrollBarTv.LargeChange );
                   SetAktRel( d )
                   end;
    VK_HOME  : begin
                 SetTopAbsIdx( 0 );
                 SetAktAbsPid( TopNode, true )
               end;
    VK_END   : begin
                 SetTopAbsIdx( ScrollBarTv.Max );
                 AktIndex := TopIndex;
                 AktNode  := TopNode;
                 SetAktRel( MaxIndex - ScrollBarTv.Max )
               end;
    VK_RIGHT : if ( tIdFlagsTv.SubTreeOpen in AktNode^.IdFlagsTv[AktTv] ) or not ( tIdFlagsTv.hasSub in AktNode^.IdFlagsTv[AktTv] ) then begin
                 Key := VK_DOWN;
                 ScrollBarTvKeyDown( nil, Key, [] )
                 end
               else
                 ExpandSub( AktNode );
    VK_LEFT  : if tIdFlagsTv.SubTreeOpen in AktNode^.IdFlagsTv[AktTv]
                 then CollapseSub( AktNode )
                 else if AktNode^.PrevBlock <> @IdMainMain then SetAktAbsPid( AktNode^.PrevBlock, false );
    VK_RETURN: if tIdFlagsTv.SubTreeOpen in AktNode^.IdFlagsTv[AktTv]
                 then CollapseSubAll( AktNode )
                 else ExpandSubAll  ( AktNode )
    end;
  Key := 0
end;

(* MouseDown *)
procedure TfrmMain.PaintBoxMouseDown( Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer );
var Key: word;
begin
  if not ( ListBoxData.Modus in [lmAcc, lmCnt] ) then exit;
  {$IFDEF TraceDx} TraceDx.CallE<TMouseButton>( 'PaintBoxMouseDown', Button ); {$ENDIF}
  ActiveControl := ScrollBarTv;
  Y := Y div tMyTreeView.ItemHeight;
  if MyTv[AktTv].TopIndex + Y <= MyTv[AktTv].MaxIndex then begin   // erster Click links oder rechts: Akt setzen
//      if MyTv[AktTv].AktIndex <> MyTv[AktTv].TopIndex + Y
//        then MyTv[AktTv].SetAktRel( Y ); // AktNode verschieben falls notwendig
    if MyTv[AktTv].AktIndex <> MyTv[AktTv].TopIndex + Y
      then MyTv[AktTv].SetAktRel( Y )                          // AktNode verschieben falls notwendig
      else MyTv[AktTv].SetActivePid( MyTv[AktTv].AktNode );    // nur damit StatusBar aktualisiert wird
    if ( Button = mbLeft ) and ( X < MyTv[AktTv].getLevel( MyTv[AktTv].AktNode ) * tMyTreeView.ItemHeight + tMyTreeView.ItemHeight shr 1) then begin
      { also das Plus oder Minus links vom Node-Text: }
      if tIdFlagsTv.SubTreeOpen in MyTv[AktTv].AktNode^.IdFlagsTv[AktTv] then begin
        Key := VK_LEFT;
        ScrollBarTvKeyDown( nil, Key, [] )
        end
      else
        MyTv[AktTv].ExpandSub( MyTv[AktTv].AktNode )
      end
    end
end;

(* Scroll *)
procedure TfrmMain.ScrollBarTvScroll( Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer );
begin
  {$IFDEF TraceDx} if ScrollCode <> scEndScroll then TraceDx.CallE<TScrollCode>( 'ScrollBarTvScroll', ScrollCode ); {$ENDIF}
//    {$IFDEF TraceDx} TraceDx.Send( 'ScrollBarTvScroll ' + TRttiEnumerationType.GetName(ScrollCode), ScrollPos ); {$ENDIF}
  case ScrollCode of
  scLineUp..scPageDown:
               { Position wird automatisch angepasst, TopIndex und TopNode wird im SetTopRel angepasst, AktIndex und AktNode unverändert: }
               MyTv[AktTv].SetTopRel( ScrollPos - ScrollBarTv.Position );
  scTrack    : if abs( ScrollPos - ScrollBarTv.Position ) < 10
                 then MyTv[AktTv].SetTopRel( ScrollPos - ScrollBarTv.Position )
                 else MyTv[AktTv].SetTopAbsIdx( ScrollPos );
  scEndScroll: ; // kommt zusätzlich nach jedem anderen sc...    Ignorieren
  else         MyTv[AktTv].SetTopAbsIdx( ScrollPos )
  end
end;

(* MouseWheel *)
procedure TfrmMain.FormMouseWheel( Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean );
var Pos : tMyTreeView.tScrollPos;
begin
  if ListBoxData.Modus <> lmAcc then exit;
  if ( Mouse.CursorPos.X > Left ) and ( Mouse.CursorPos.X < Left + PanelLeft.Width ) then begin
    {$IFDEF TraceDx} TraceDx.Call( 'FormMouseWheel', WheelDelta ); {$ENDIF}
    if ( WheelDelta < 0 ) and ( MyTv[AktTv].TopIndex < ScrollBarTv.Max ) then begin
      Pos := MyTv[AktTv].TopIndex + 1;
      ScrollBarTvScroll( nil, scLineDown, Pos )
      end
    else if ( WheelDelta > 0 ) and ( MyTv[AktTv].TopIndex > 0 ) then begin
      Pos := MyTv[AktTv].TopIndex - 1;
      ScrollBarTvScroll( nil, scLineUp, Pos )
      end;
    Handled := true
    end
end;

(* PaintBoxPaint *)
procedure TfrmMain.PaintBoxPaint( Sender: TObject );
var X,Y : word;
    c   : char;
    i   : tMyTreeView.tScrollPos;
    pId : pIdInfo;

  procedure SetColor;
  begin
    with PaintBox.Canvas do begin
      if i = MyTv[AktTv].AktIndex then begin
        if ActiveControl = ScrollBarTv
          then Brush.Color := clSkyBlue
          else Brush.Color := clSilver;
        Font.Color := clBlack
        end
      else begin
        Brush.Color := clWhite;
        if pId^.Typ in [id_ConstInt..high(tIdType)] then
          Font.Color := clBlack
        else
          if ( pId^.AcSet <= [ac_Declaration] ) and not ( pId^.Typ in cAlwaysDeclared ) and not ( tIdFlags2.IsAnonym in pId^.IdFlags2 )
            then Font.Color := clGray
            else Font.Color := cIdShow[pId^.Typ].Color;
        end;
      if AktTv = _tvFil then
        if tIdFlagsDyn.isFilteredDummy in pId^.IdFlagsDyn
          then Font.Style := [fsItalic]
          else Font.Style := []
      end
  end;

begin
  {$IFDEF TraceDx} TraceDx.Call( 'PaintBoxPaint', ScrollBarTv.Position ); {$ENDIF}
  with PaintBox.Canvas, MyTv[AktTv] do begin
    Brush.Color := clWhite;
    Font.Style := [];
    FillRect( ClipRect );
    if FirstNode = nil then exit;
    assert( ScrollBarTv.Position = TopIndex, 'ScrollBarTv.Position <> TopIndex' );
    X   := getLevel( TopNode );
    Y   := 0;
    i   := TopIndex;
    pId := TopNode;
    repeat // {$IFDEF TraceDx} TraceDx.Send( 'PaintBoxPaint-Line', pId^.Name ); {$ENDIF}
           if tIdFlagsTv.hasSub in pId^.IdFlagsTv[AktTv] then begin
             Brush.Color := clWhite;
             Font.Color  := clGrayText;
             TextOut( X * ItemHeight, Y, cPlusMinus[not ( tIdFlagsTv.SubTreeOpen in pId^.IdFlagsTv[AktTv] )])
             end;
           SetColor;
           if tIdFlags.OverloadUnresolved in pId^.IdFlags then
             TextOut( X * ItemHeight + ItemWidth, Y, pId^.Name + cSymbolOverload )
           else
             if pId^.Typ = id_Filename then
               if TPath.GetExtension( pId^.Name ) = cExtensionPas
                 then TextOut( X * ItemHeight + ItemWidth, Y, TPath.GetFileNameWithoutExtension( pId^.Name ) )
                 else TextOut( X * ItemHeight + ItemWidth, Y, TPath.GetFileName                ( pId^.Name ) )
             else
               TextOut( X * ItemHeight + ItemWidth, Y, pId^.Name ); //+ ' (' + cPlusMinus[tIdFlagsTv.hasSub in pId^.IdFlagsTv[AktTv]] + pId^.OpenCount[AktTv].ToString + ')' );
           if tIdFlags2.HasHotKey in pId^.IdFlags2 then begin
             for c := low( tHotKeys ) to high( tHotKeys ) do if HotKey[c] = pId then break;
             Brush.Color := $C0C0FF;
             TextOut( PenPos.X+15, Y, '>' + c + '<' )
             end;
           if ( i >= MaxIndex ) {or ( i > ScrollBarTv.LargeChange )}
             then break
             else inc( i );
           inc( Y, ItemHeight );
           getNext( pId, X )
    until  Y >= PaintBox.ClientHeight
    end
end;

(* PopupMenuIdPopup *)
procedure TfrmMain.PopupMenuIdPopup( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'PopupMenuIdPopup' ); {$ENDIF}
  PopupItmIdGoto.Tag := 0;
  PopupItmIdGoto.Enabled := ( MyTv[AktTv].AktNode^.MyType <> nil ) and ( MyTv[AktTv].AktNode^.MyType^.TypeNr <> 0 );
  if PopupItmIdGoto.Enabled then
    PopupItmIdGoto.Caption := 'Goto Type ' + cHick + MyTv[AktTv].AktNode^.MyType^.Name + cHick
  else begin
    PopupItmIdGoto.Enabled := ( MyTv[AktTv].AktNode^.MyParent <> nil ) and ( MyTv[AktTv].AktNode^.MyParent^.TypeNr <> 0 );
    PopupItmIdGoto.Tag := 1;
    if PopupItmIdGoto.Enabled
      then PopupItmIdGoto.Caption := 'Goto Parent ' + cHick + MyTv[AktTv].AktNode^.MyParent^.Name + cHick
      else PopupItmIdGoto.Caption := 'Goto ...'
    end;
  PopupItmIdCopyLong.Enabled := MyTv[AktTv].getLevel( MyTv[AktTv].AktNode ) > 1
end;

(* PopupItmIdGotoClick *)
procedure TfrmMain.PopupItmIdGotoClick( Sender: TObject );
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'PopupItmIdGotoClick' ); {$ENDIF} {$ENDIF}
  if PopupItmIdGoto.Tag = 0
    then tMyTreeView.ChangeAbsPid( MyTv[AktTv].AktNode^.MyType  , false )
    else tMyTreeView.ChangeAbsPid( MyTv[AktTv].AktNode^.MyParent, false )
end;

(* PopupItmIdCopyClick *)
procedure TfrmMain.PopupItmIdCopyClick( Sender: TObject );
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'PopupItmIdCopyClick' ); {$ENDIF} {$ENDIF}
  Clipboard.SetTextBuf( @MyTv[AktTv].AktNode^.Name[cSpalte0] );
end;

(* PopupItmIdCopyLongClick *)
procedure TfrmMain.PopupItmIdCopyLongClick( Sender: TObject );
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'PopupItmIdCopyLongClick' ); {$ENDIF} {$ENDIF}
  Clipboard.SetTextBuf( @TListen.getBlockNameLong( MyTv[AktTv].AktNode, cTrennUse )[cSpalte0] )
end;

(* PopupItmIdSortClick *)
procedure TfrmMain.PopupItmIdSortClick( Sender: TObject );
var New, Last, tmp:  pIdInfo;
    Pre0, Pre : ppIdInfo;
    Cmp: tIdType;

  function DoStringSpecial( p: pIdInfo ): string;
  var i,v,d: integer;
      s: tStringBuilder;
      InString: boolean;
  begin
    if tIdFlags2.LiteralSpecial in p^.IdFlags2 then begin
      s := TStringBuilder.Create( p^.Name.Length );
      InString := false;
      i := 0;
      repeat
        case p^.Name[i] of
          '''': begin
                  if InString then
                    if ( i < high( p^.Name )) and ( p^.Name[i+1] = '''' )
                      then begin s.Append( '''' ); inc( i ) end
                      else InString := false
                  else
                    InString := true;
                  inc( i )
                end;
          '^' : begin
                  s.Append( char( ord( p^.Name[i+1].ToUpper ) - 64 ));
                  inc( i, 2 )
                end;
          '#' : begin
                  inc( i );
                  val( p^.Name.Substring( i ), v, d );
                  s.Append( char( v ));
                  if d = 0
                    then break   // die Zahl reicht bis zum Ende
                    else inc( i, d-1 )
                 end
          else  s.Append( p^.Name[i] ); inc( i )
          end
        until i >= high( p^.Name );
      Result := s.ToString;
      s.Free
      end
    else
      Result := p^.Name.Substring( 1, high( p^.Name ) - 1 );
//    {$IFDEF TraceDx} t := ''; for c in Result do t := t + ' ' + ord( c ).ToString; TraceDx.Send( 'Special', p^.Name, t ) {$ENDIF}
  end;

  function LowerThan: boolean;
  var U1, U2: UInt64;
      E1, E2: Extended;
      D: integer;
  begin
    case Cmp of
      id_ConstInt : try    Result := New^.Name.ToInteger < Last^.Name.ToInteger
                    except try    Result := New^.Name.ToInt64   < Last^.Name.ToInt64
                           except val( New^.Name, U1, D ); val( Last^.Name, U2, D );
                                  Result := U1 < U2
                           end
                    end;
      id_ConstReal: begin
                      TryStrToFloat( New ^.Name, E1, TFormatSettings.Create('en-US') );
                      TryStrToFloat( Last^.Name, E2, TFormatSettings.Create('en-US') );
                      Result := E1 < E2
                    end;
      id_ConstHex : Result := UINT64( New^.Name.ToInt64 )  < UINT64( Last^.Name.ToInt64 );
      id_ConstChar,
      id_ConstStr : Result := DoStringSpecial( New )           < DoStringSpecial( Last )
      else          Result := New^.Name.ToLower          < Last^.Name.ToLower
      end
  end;

  function GreaterThan: boolean;
  var U1, U2: UInt64;
      E1, E2: Extended;
      D: integer;
  begin
    case Cmp of
      id_ConstInt : try           Result := New^.Name.ToInteger > Pre^^.Name.ToInteger;
                    except try    Result := New^.Name.ToInt64   > Pre^^.Name.ToInt64
                           except val( New^.Name, U1, D ); val( Pre^^.Name, U2, D );
                                  Result := U1 > U2
                           end
                    end;
      id_ConstReal: begin
                      TryStrToFloat( New ^.Name, E1, TFormatSettings.Create('en-US') );
                      TryStrToFloat( Pre^^.Name, E2, TFormatSettings.Create('en-US') );
                      Result := E1 > E2
                    end;
      id_ConstHex : Result := UINT64( New^.Name.ToInt64 ) > UINT64( Pre^^.Name.ToInt64 );
      id_ConstChar,
      id_ConstStr : Result := DoStringSpecial( New )           > DoStringSpecial( Pre^ )
      else          Result := New^.Name.ToLower          > Pre^^.Name.ToLower
      end
  end;

begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'PopupItmIdSortClick' ); {$ENDIF} {$ENDIF}
  Cursor := crHourGlass;
  if MyTv[tvAll].AktNode^.SubBlock = nil then begin
    New  :=  MyTv[tvAll].AktNode^.prevBlock^.SubBlock^.NextId;   // das erste bleibt als "einsortiert" in der Liste, beim zweiten anfangen mit neu einsortieren
    Pre0 := @MyTv[tvAll].AktNode^.prevBlock^.SubBlock;           // Pointer auf den Pointer auf das erste Element (bleibt unverändert)
    end
  else begin
    New  :=  MyTv[tvAll].AktNode^.SubBlock^.NextId;   // das erste bleibt als "einsortiert" in der Liste, beim zweiten anfangen mit neu einsortieren
    Pre0 := @MyTv[tvAll].AktNode^.SubBlock;           // Pointer auf den Pointer auf das erste Element (bleibt unverändert)
    end;
  Cmp  := pre0^^.Typ;                               // der Typ bestimmt die spätere Vergleichs-Operation
  Last := Pre0^;                                    // das zuletzt neu einsortierte Element (Optimierung, ab hier oder ab Start wird gesucht)
//  MyTv[tvAll].AktNode^.SubBlock^.NextId := nil;
  Pre0^^.NextId := nil;                             // zu Beginn ist das erste Element das einzige, kein Nachfolger
  while New <> nil do begin
//    {$IFDEF TraceDx}
//      s := ''; tmp := pre0^;
//      while tmp <> nil do begin s := s + tmp^.Name + ' - '; tmp := tmp^.NextId end;
//      TraceDx.Send( 'List', s );
//    {$ENDIF}

    { Vor-Einteilung: vor oder hinter das zuletzt eingefügte? Idealerweise halbiert dies die Vergleichs-Anzahl. }
    { Für eine vorher schon sortierte Liste ist sogar nur je ein Vergleich (dieser hier) notwendig               }
    if LowerThan
      then Pre := Pre0
      else Pre := @Last^.NextId;

    { In dieser Teilmenge die richtige Stelle suchen. Pre zeigt auf den Pointer auf das nächst-größere Element (wo also eingefügt werden muss) }
    while ( Pre^ <> nil ) and GreaterThan do
      Pre := @Pre^^.NextId;

    { einfügen: }
    Last := New;   // für nächsten Durchlauf
    tmp  := New^.NextId;
    New^.NextId := Pre^;
    Pre^ := New;
    New  := tmp
    end;

  if MyTv[tvAll].AktNode^.SubBlock = nil
    then MyTv[AktTv].SetAktAbsPid( MyTv[tvAll].AktNode, false );   // der AktIndex hat sich geändert

  PaintBox.Repaint;
  Cursor := crDefault
end;

(* RefactorWarning *)
procedure RefactorWarning( const s: string );
begin
  {$IFDEF RELEASE}
  MessageDlg( s + slinebreak +
              'This function may change some Sourcefiles.' + sLineBreak + 'Have a backup!',
              TMsgDlgType.mtConfirmation, [mbOK], 0 )
  {$ENDIF}
end;

(* PopupItmIdRenameClick *)
procedure TfrmMain.PopupItmIdRenameClick( Sender: TObject );
const cIdTypeModule = [id_NameSpace..id_Unit];
var pAc : pAcInfo;
    ov  : boolean;
    pIdOld,
    pId : pIdInfo;
    old,
    new : string;
    sw  : TStreamWriter;
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'PopupItmIdRenameClick' ); {$ENDIF} {$ENDIF}
  pId := MyTv[AktTv].AktNode;
  old := pId^.Name;
  ov  := isOverload in pId^.IdFlags;

  { 0. Warning }
  RefactorWarning( 'Rename' );

  { 1. Checks: }
  pAc := pId^.AcList;
  while pAc <> nil do with DateiListe[pAc^.Position.Datei]^ do begin
    if pAc^.Position.Datei <> cFirstFileV then begin
      if tFileFlags.isNotLatest in fiFlags
        then begin MessageDlg( 'Not latest Version of File:' + sLineBreak + FileName, mtError, [mbOK], 0 ); exit end;

      if TFileAttribute.faReadOnly in TFile.GetAttributes( Filename )
        then begin MessageDlg( 'File ist ReadOnly:' + sLineBreak + FileName, mtError, [mbOK], 0 ); exit end;

      try    sw := TFile.AppendText( Filename );
             sw.Free
      except MessageDlg( 'Can''t write to:' + sLineBreak + FileName, mtError, [mbOK], 0 ); exit
      end
      end;
    pAc := pAc^.NextAc
    end;

  if ( pId^.Typ in cIdTypeModule ) and
     ( MessageDlg( 'For renaming Identifiers of type ' + cIdShow[pId^.Typ].Text + sLineBreak + 'you will have to change the name of the corresponding file manually',
                   mtConfirmation, mbOKCancel, 0 ) <> mrOk )
    then exit;

  { 2. get new Name: }
  new := InputBox( 'Rename Identifier ' + old, 'Enter new name:', old );
  if ( new = '' ) or ( new.ToLower = old.ToLower ) then exit;

  { 3. Check for new already existing: }
  pIdOld := pId;
  pId := TListen.SucheIdInBloecken( 0, new );
  if pId <> nil
    then begin MessageDlg( 'New Name "' + new + '" already exists as' + sLineBreak + TListen.getBlockNameLong( pId, dTrennView ), mtError, [mbOK], 0 ); exit end;

  { 4. Doit: }
  ShowMessage( 'List of renamed Files:' +
               TFncIdentifier.Rename( pIdOld, new ));
  mItmFileReParseClick( nil );

  { 5. Overload-Warning: }
  if ov then
    ShowMessage( 'Please check manually for more Overloads in other Units and  Unresolved-Block which were not renamed!' )
end;

{$ENDREGION }

{$REGION '-------------- tVerify ---------------' }

{$IFDEF RefVerify}
class procedure tVerifyRef.TraceOn( b: boolean );
begin
  if b then begin
    TraceDx .DecHide;
    VerifyDx.DecHide;                                      // erstmal keine Verify-Daten
    end
  else begin
    TraceDx .IncHide;
    VerifyDx.IncHide;                                        // erstmal keine Verify-Daten
    end;
end;

class function  tVerifyRef.getAktPid: pointer;
begin
  Result := MyTv[AktTv].AktNode
end;

class procedure tVerifyRef.setAktPid( p: pointer; HideTrace: boolean = true );
begin
  {$IFDEF TraceDx}
    if HideTrace then
      TraceOn( false );
  {$ENDIF}
  MyTv[AktTv].SetAktAbsPid( p, true );
  {$IFDEF TraceDx}
    if HideTrace then
      TraceOn( true );
  {$ENDIF}
end;

class function tVerifyRef.setAktPidbyName( const n: string; HideTrace: boolean = true ): pointer;
begin
  {$IFDEF TraceDx}
    if HideTrace then
      TraceOn( false );
  {$ENDIF}
  frmMain.cmbBoxSearch.Text := n;
  frmMain.cmbBoxSearchChange( frmMain.cmbBoxSearch );
  {$IFDEF TraceDx}
    if HideTrace then
      TraceOn( true );
  {$ENDIF}
  Result := MyTv[AktTv].AktNode
end;

class function  tVerifyRef.ParseSource( const n: string; HideTrace: boolean = true ): boolean;
begin
  {$IFDEF TraceDx}
    if HideTrace then
      TraceOn( false );
  {$ENDIF}
  frmMain.btnRunAgain.Caption := StringOfChar( ' ', cLenRunAgain ) + n;
  frmMain.btnRunAgainClick( nil );                       // Testdatei parsen
  {$IFDEF TraceDx}
    if HideTrace then
      TraceOn( true );
  {$ENDIF}
  Result := frmMain.actIdReduce.Enabled                  // false, falls Option-Dialog mit "Cancel" beendet wurde
end;
{$ENDIF}
{$ENDREGION }

{$REGION '-------------- tvLeft = Find und All ---------------' }

{ SetActiveModeCount }
procedure SetActiveModeCount( lm: tLstBoxModus );
begin
  {$IFDEF TraceDx} TraceDx.CallE<tLstBoxModus>( 'SetActiveModeCount', lm ); {$ENDIF}
  with frmMain do begin
    lstBox.Cursor           := crDefault;
    ListBoxData.Modus       := lm;
    mItmViewCounter.Checked := lm = lmCnt;
    case lm of
    lmCnt : begin
              lstBox.Count := 12 + ord( id_Func ) + ord( high( tAcType ));
              {$IFDEF TraceDx} ListBoxData.AcCache.Hit  := 0; {$ENDIF}
              {$IFDEF TraceDx} ListBoxData.AcCache.Miss := 0  {$ENDIF}
            end;
    lmErr : if pAktFile = nil then
              lstBox.Count := 0
            else begin
              lstBox.Count             := high( pAktFile^.StrList ) + 1;
              ListBoxData.SelectedAcNr := pAktFile^.li;
              lstBox.TopIndex          := pAktFile^.li - 5
              end
    else    lstBox.Count := 0
    end;
    actViewKontextPlus       .Enabled :=   lm = lmAcc;
    actViewKontextMinus      .Enabled :=   lm = lmAcc;
    actRefsWriteOnly         .Enabled :=   lm = lmAcc;
    actRefsViaOnly           .Enabled := ( lm = lmAcc ) and ( pAcVia <> nil );
    actRefsViaSelect         .Enabled :=   lm = lmAcc;
    cboBoxUnits              .Enabled :=   lm = lmAcc;
    chkBoxUnitOnly           .Enabled := ( lm = lmAcc ) and ( pIdUnitOnly <> nil );
    mItmRefUnitOnly          .Enabled := chkBoxUnitOnly.Enabled;
    actRefDeclaration        .Enabled :=   lm = lmAcc;
    cmbBoxSearch             .Enabled :=   lm = lmAcc;
    actSearch                .Enabled :=   lm = lmAcc;
    actSearchAgain           .Enabled :=   lm = lmAcc;
    actIdentifierBack        .Enabled :=   lm = lmAcc;
    actIdViewFilter          .Enabled :=   lm = lmAcc;
    actIdSetFilter           .Enabled :=   lm = lmAcc;
    pItmIdFilterName         .Enabled :=   lm = lmAcc;
    pItmIdFilterHierarchy    .Enabled :=   lm = lmAcc;
    actIdReduce              .Enabled :=   lm = lmAcc;
    mItmViewCounter          .Enabled := ( lm = lmAcc ) or (( lm = lmCnt ) and not CriticalWork );
    {$IFDEF SaveTree}
    mItmExtraExportDebug     .Enabled :=   lm = lmAcc;
    {$ENDIF}
    PopupMenuId              .AutoPopup := lm = lmAcc;
    PopupMenuAc              .AutoPopup := lm = lmAcc;
    end
end;

(* SearchQualifiedId *)
function SearchQualifiedId( const s0: string ): pIdInfo;
var p,q: integer;
    s  : string;
begin
  {$IFDEF TraceDx} TraceDx.Call( 'SearchQualifiedId', s0 ); {$ENDIF}
  p := 0;
//  Result := MainBlock[mbBlock0].SubBlock;
  Result := IdMainMain.SubBlock;
  repeat q := s0.IndexOf( cTrennUse, p );
         if q = -1
           then s := s0.Substring( p )
           else s := s0.Substring( p, q-p );
         p := q+1;
         while ( Result <> nil ) and ( Result^.Name <> s ) do
            Result := Result^.NextId;
         if Result = nil
           then exit
           else if q <> -1 then Result := Result^.SubBlock
  until q = -1
end;

{$ENDREGION }

{$REGION '-------------- HotKey ---------------' }

procedure ShowPnlFiles( b: boolean );
begin
  frmMain.pnlFiles     .Visible := b;
  frmMain.SplitterFiles.Visible := b
end;

(* ShowHotKeys *)
procedure ShowHotKeys;
begin
  {$IFDEF TraceDx} TraceDx.Call( 'ShowHotKeys' ); {$ENDIF}
  CtrlDown := true;
  UserInfo.Show( cHotKeyInfo, tUserInfo.InfoType.inHintUI );
  frmMain.lstBoxHotKey.Visible := true;
  CtrlArray[ctFiles]  .Visible := false;
  ShowPnlFiles( true )
end;

(* HideHotKeys *)
procedure HideHotKeys;
begin
  {$IFDEF TraceDx} TraceDx.Call( 'HideHotKeys' ); {$ENDIF}
  ShowPnlFiles( frmMain.mItmViewFiles.Checked );
  CtrlArray[ctFiles]  .Visible := true;
  frmMain.lstBoxHotKey.Visible := false;
//  frmMain.ActiveControl := CtrlArray[ctMyTv];
  UserInfo.Restore;
  CtrlDown := false
end;

(* HotKeyPreParse *)
procedure HotKeyPreParse;
begin
  {$IFDEF TraceDx} TraceDx.Call( 'HotKeyPreParse' ); {$ENDIF}
  frmMain.lstBoxHotKey.Count := 0;
  CtrlDown := false;
  FillChar( HotKey, sizeOf( HotKey ), 0 )
end;

(* lstBoxHotKeyDrawItem *)
procedure TfrmMain.lstBoxHotKeyDrawItem( Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState );
var i: integer;
    c: char;
begin
//  {$IFDEF TraceDx} if Index = 0 then TraceDx.Call( 'lstBoxHotKeyDrawItem', Index ); {$ENDIF}
  if State * [odSelected, odFocused] <> [] then exit;
  with lstBoxHotKey.Canvas do begin
    FillRect( Rect );
    i := 0;
    for c := low( HotKey ) to high( HotKey ) do
      if HotKey[c] <> nil then begin
        if i = Index then break;
        inc( i )
        end;
    Font.Style := Font.Style + [fsBold];
    TextOut( Rect.Left +   5, Rect.Top, c );
    Font.Style := Font.Style - [fsBold];
    Font.Color := cIdShow[HotKey[c]^.Typ].Color;
    TextOut( Rect.Left +  30, Rect.Top, HotKey[c]^.Name );
    {Font.Color := clGrayText;
    while PenPos.X > Rect.Left + 180 do Rect.Left := Rect.Left + 60;
    TextOut( Rect.Left + 180, Rect.Top, TListen.getBlockNameLongMain( HotKey[c], dTrennView ))}
    end
end;

(* SetResetHotKeys *)
procedure SetGotoHotKey( c: char; Shift: boolean );
var b: boolean;
    p: pIdInfo;
    i: integer;
begin
//  if frmMain.lstBoxHotKey.Visible then begin
    p := HotKey[c];
    b := p = nil;
    if Shift then begin
      { SET HotKey }
      if not b then
        exclude( p^.IdFlags2, tIdFlags2.HasHotKey );
      HotKey[c] := MyTv[AktTv].AktNode;
      include( HotKey[c]^.IdFlags2, tIdFlags2.HasHotKey );
      if b
        then frmMain.lstBoxHotKey.Count := frmMain.lstBoxHotKey.Count + 1
        else frmMain.lstBoxHotKey.Invalidate
      end

    else begin
      { GOTO HotKey }
      if ( p = nil ) or ( p = MyTv[AktTv].AktNode ) then begin
        //mbBlock0, mbUnDeclaredUnScoped, mbConstInt, mbConstHex, mbConstBin, mbConstReal, mbConstChars, mbConstStrings, {mbGUID,} mbPascalDirs, mbCompilerDirs, mbDefines, mbAttributes, mbKeyWords, mbFilenames );
         i := '0UIHBRHSPCDAKF'.IndexOf( c );
         if i <> -1 then begin
           p := @MainBlock[tMainBlock( i )];
           if p^.SubBlock = nil then
             begin p := nil; i := -1 end
           end
        end
      else
        i := -1;

      if p = nil then
        UserInfo.Show( 'HotKey "' + c + '" not defined!', tUserInfo.InfoType.inError )
      else begin
        frmMain.ActiveControl := CtrlArray[ctMyTv];
        if i = -1 then
          MyTv[AktTv].SetAktAbsPid( p, true )
        else begin
          MyTv[AktTv].AktNode := p;
          frmMain.actIdReduceExecute( nil );
          MyTv[AktTv].ExpandSub( p );
          end;
        end;
      end;

    frmMain.PaintBox.Repaint
end;

(* lstBoxHotKeyClick *)
procedure TfrmMain.lstBoxHotKeyClick( Sender: TObject );
var i: integer;
    c: char;
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'lstBoxHotKeyClick' ); {$ENDIF} {$ENDIF}
  if lstBoxHotKey.ItemIndex <> -1 then begin
    i := 0;
    for c := low( HotKey ) to high( HotKey ) do
      if HotKey[c] <> nil then begin
        if i = lstBoxHotKey.ItemIndex then break;
        inc( i )
        end;
  SetGotoHotKey( c, false );
//  lblStatus.Repaint;    // bringt nix: lblStatus.Caption bleibt auf HotKey-Info
  lstBoxHotKey.ItemIndex := -1
  end
end;

(* ResetHotKeys *)
procedure ResetHotKeys( Shift: boolean );
var c: char;
begin
  for c := low( HotKey ) to high( HotKey ) do if HotKey[c] <> nil then
    if ( HotKey[c] = MyTv[AktTv].AktNode )  or  Shift then begin
      exclude( HotKey[c].IdFlags2, tIdFlags2.HasHotKey );
      HotKey[c] := nil;
      frmMain.lstBoxHotKey.Count := frmMain.lstBoxHotKey.Count - 1
      end;
  if Shift then HideHotKeys;
  frmMain.PaintBox.Repaint
end;

(* SetAllHotKeys *)
procedure SetAllHotKeys;
var c: char;
begin
  for c := low( HotKey ) to high( HotKey ) do
    if FileOptions.HotKey[c] <> EmptyStr then begin
      HotKey[c] := SearchQualifiedId( FileOptions.HotKey[c] );
      if HotKey[c] <> nil then begin
        frmMain.lstBoxHotKey.Count := frmMain.lstBoxHotKey.Count + 1;
        include( HotKey[c].IdFlags2, tIdFlags2.HasHotKey )
        end
      end
end;

(* SetHotKeyStrings *)
function SetHotKeyStrings: string;
var c: char;
begin
 Result := EmptyStr;
  for c := low( HotKey ) to high( HotKey ) do
    if HotKey[c] = nil then
      FileOptions.HotKey[c] := EmptyStr
    else begin
      Result := Result + c;
      FileOptions.HotKey[c] := TListen.getBlockNameLongMain( HotKey[c], cTrennUse )
      end
end;

{$ENDREGION }

{$REGION '-------------- History ---------------' }

procedure TfrmMain.mItmIdHistoryClick(Sender: TObject);
begin
  frmHistory.Show
end;

procedure SetHistory;
var pId: pIdInfo;
    i: integer;
begin
  i := 0;
  while i < frmHistory.lstHistory.Count do begin
    pId := SearchQualifiedId( frmHistory.lstHistory.Items[i] );
    if pId = nil then
      frmHistory.lstHistory.Items.Delete( i )
    else begin
      frmHistory.lstHistory.Items.Objects[i] := TObject( pId );
      inc( i )
      end
    end
end;

{$ENDREGION }

{$REGION '-------------- tvFilter ---------------' }

{$REGION '-------------- CmpFuncs ---------------' }

var
  FilterData   : tCmpData;
  CntProjectUse: longword;

function CmpFuncText( pIdFilter: pIdInfo ): boolean;
begin
  case FilterData.CmpMode of
    cfNormal      : result := LowerCase( pIdFilter^.Name ).StartsWith( FilterData.SearchText );
    cfMiddle      : result := LowerCase( pIdFilter^.Name ).IndexOf   ( FilterData.SearchText ) <> -1;
    cfEnd         : result := ( FilterData.SearchHash = pIdFilter^.Hash ) and
                              ( LowerCase( pIdFilter^.Name ).Equals  ( FilterData.SearchText ));
    cfMiddleEnd   : result := LowerCase( pIdFilter^.Name ).EndsWith  ( FilterData.SearchText );
    else            result := false
  end
end;

function CmpFuncPerType( pIdFilter: pIdInfo ): boolean;
begin
  result := pIdFilter^.Typ = tIdType( frmFilter.cmbBoxTyp.ItemIndex + ord( id_Label ))
end;

function CmpFuncNoDeclare( pIdFilter: pIdInfo ): boolean;
begin
  result := not ( ac_Declaration         in pIdFilter^.AcSet    )   and
            not ( tIdFlags2.IsUnitSystem in pIdFilter^.IdFlags2 )   and
//            ( pIdFilter^.PrevBlock^.Typ <> id_MainBlock )           and       Nicht gefundene Units tauchen HIER auf obwohl nicht qualified. Ist aber Besser als unter unqualified
            ( pIdFilter^.Typ <> id_NameSpace )
end;

function CmpFuncDeclareOnly( pIdFilter: pIdInfo ): boolean;
begin
  result := ( pIdFilter^.AcSet = [ac_Declaration] )              and
            not ( pIdFilter^.Typ        in cAlwaysDeclared )     and
            not ( tIdFlags.IsPointer    in pIdFilter^.PrevBlock^.IdFlags ) and      // fehlende Zugriffe über den Pointer "^" ignorieren
            not ( tIdFlags.IsCopySource in pIdFilter^.IdFlags )  and
            not ( tIdFlags.IsDummy      in pIdFilter^.IdFlags )  and
            not ( tIdFlags2.IsMessage   in pIdFilter^.IdFlags2 ) and                // Message-Handler werden vom Windows aufgerufen
            not ( tIdFlags2.IsAnonym    in pIdFilter^.IdFlags2 ) and                // anonym-procs werden nie über Namen aufgerufen
            ( not frmFilter.chkBoxDeclareOnly.Checked    or
              ( pIdFilter^.Name <> 'Sender' )            or
              ( pIdFilter^.IdFlags * [tIdFlags.IsParameter, tIdFlags.IsWriteParam] <> [tIdFlags.IsParameter] ) or
              not ( tIdFlags.IsClassType in pIdFilter^.MyType^.IdFlags ))
end;

function CmpFuncNoWrite( pIdFilter: pIdInfo ): boolean;
begin
  result :=
    ( pIdFilter^.Typ   = id_Var )                                                   and
    ( pIdFilter^.AcSet * [ac_Declaration, ac_Unknown] = [ac_Declaration] )          and
    ( pIdFilter^.AcSet * [ac_Write, ac_ReadAdress] = [] )                           and
    ( ac_Read in pIdFilter^.AcSet )                                                 and  { sonst unter DeclareOnly }
    not ( tIdFlags.IsPointer in pIdFilter^.PrevBlock^.IdFlags )                     and
    not ( tIdFlags2.IsSelf in pIdFilter^.IdFlags2 )                                 and
    ( ( tIdFlags.IsParameter in pIdFilter^.IdFlags ) = ( tIdFlags.IsOutParam in pIdFilter^.IdFlags ))  { wenn Parameter dann OUT }
end;

function CmpFuncNoRead( pIdFilter: pIdInfo ): boolean;
begin    // keine die unter Declared-Only fallen
  result :=
    ( pIdFilter^.Typ in [id_Label..id_Func] )                                       and  // nur "echte"
    ( pIdFilter^.AcSet * [ac_Declaration, ac_Unknown] =  [ac_Declaration] )         and
//  not ( tidflags.IsCopySource in pIdFilter^.PrevBlock^.IdFlags )                  and  // nicht: Record-Typ.Variable
    ( pIdFilter^.AcSet * [ac_Read, ac_ReadAdress] =  [] )                           and
    ( pIdFilter^.AcSet * [ac_Write, ac_ReadAdress]             <> []            )   and  // geschrieben JA, sonst wäre sie unter DeclareOnly
    ( pIdFilter^.IdFlags  * [tIdFlags.IsResult, tidFlags.IsWriteParam] = [] )       and  // witzlos für result und var/out-Parameter
    ( pIdFilter^.IdFlags2 * [tIdFlags2.IsAnonym]                       = [] )            // ebenso für anonym
end;

function CmpFuncUncalledUnit( pIdFilter: pIdInfo ): boolean;
var d  : tFileIndex;
    pAc: pAcInfo;
    pId: pIdInfo;
begin
  Result := false;
  if ( pIdFilter^.Typ = id_Unit ) and ( ac_Declaration in pIdFilter^.AcSet ) then begin
    d := pIdFilter^.AcList^.Position.Datei;     // Dateinummer der Deklaration der Unit
    pId := pIdFilter^.SubBlock;
    while ( pId <> nil ) and ( pId^.Typ <> id_Impl ) do begin
      pAc := pId^.AcList;
      while pAc <> nil do begin
        if ( pAc^.Position.Datei <> d )  and
           (( DateiListe[pAc^.Position.Datei]^.MyUnit <> nil ) or ( DateiListe[pAc^.Position.Datei]^.prevFile <> d ))
          then exit;
        pAc := pAc^.NextAc
        end;
      pId := pId^.NextId
      end;
    Result := true
    end
end;

{ was ruft aktuelle Unit auf (als ob Ref mit aktueller Unit geöffnet würde }
function CmpFuncUnitCalls( pIdFilter: pIdInfo ): boolean;
var pId: pIdInfo;
    pAc: pAcInfo;
  function ParentUnit: pIdInfo;
  begin
    Result := pIdFilter^.PrevBlock;
    while not ( Result^.Typ in [id_NameSpace, id_Program, id_Unit] ) do
      Result := Result^.PrevBlock
  end;
begin
  Result := false;
  if ( pIdFilter^.Typ in [id_Label..id_Func] ) and
     ( ParentUnit <> MyTv[tvAll].AktNode )           // keine References in eigene Unit
//      true {( pIdInfo( n.Parent.Data )^.Typ = id_Unit )})                    // nur oberste Ebene, auskommentiert damit auch Enum-Type gefunden werden
     or
      ( pIdFilter^.Typ in [id_ConstInt..id_PascalDirective] )
     then begin
       pAc := pIdFilter^.AcList;
       while pAc <> nil do begin
         pId := pAc^.IdUse;
         while pId^.Typ in [id_Label..id_Func] do pId := pId.PrevBlock;
         if pId = MyTv[tvAll].AktNode then begin
           Result := true;
           {$IFDEF TraceDx} TraceDx.Send( 'cfUnitCalls', pId^.Name ); {$ENDIF}
           break
           end;
         pAc := pAc^.NextAc
         end
       end
end;

function CmpFuncNonANSI( pIdFilter: pIdInfo ): boolean;
var a: ansistring;
begin
  a := pIdFilter^.Name;
//  Result := pos( '?', a ) > 0
  Result := a <> pIdFilter^.Name
end;

function CmpFuncMessages( pIdFilter: pIdInfo ): boolean;
begin
  Result := tIdFlags2.IsMessage in pIdFilter^.IdFlags2
end;

function CmpFuncGenerics( pIdFilter: pIdInfo ): boolean;
begin
  Result := tIdFlags.IsGenericType in pIdFilter^.IdFlags
end;

function CmpFuncOverloads( pIdFilter: pIdInfo ): boolean;
begin
  Result := tIdFlags.IsOverload in pIdFilter^.IdFlags
end;

//    cfParaConst   : ;
//    cfRecursive   : Result := tIdFlags.IsRekursiv in pIdInfo( n.Data )^.IdFlags

{$ENDREGION }

{ DoFilter }
function DoFilter( filter: tFilters ): integer;
var   Middle,Ende: boolean;
      CmpFunc    : function( pIdFilter: pIdInfo ): boolean;
      pIdFilter,
      LastBlock  : pIdInfo;
      pAcFilter  : pAcInfo;

  function GetNextFilter: boolean;
  begin
    repeat
      if tIdFlagsTv.hasSub in pIdFilter^.IdFlagsTv[tvAll{über die All-Liste!}] then
        pIdFilter := pIdFilter^.SubBlock
      else begin
        while pIdFilter^.NextId = nil do begin
          pIdFilter := pIdFilter^.PrevBlock;
          if pIdFilter = @IdMainMain then exit( false )
          end;
        pIdFilter := pIdFilter^.NextId                    // Vorschlag um auf   "until ( pId^.AcSet <> [] )" zu verzichten (hier und im Expand/Collapse):
        end                                   // (1) System-Original-Verkettung sichern    (2) System nur benutzte neu verketten       (0) Virtual ist ja schon raus!
    until pIdFilter^.AcSet <> [];                // Unit System hat Ids ohne Nutzung
    Result := pIdFilter <> LastBlock
  end;

  procedure Found;
  var pId: pIdInfo;
  begin
    include ( pIdFilter^.IdFlagsDyn, tIdFlagsDyn.isFiltered );
    exclude ( pIdFilter^.IdFlagsDyn, tIdFlagsDyn.isFilteredDummy );
    {$IFDEF TraceDx} TraceDx.Send( 'FilterFound', TListen.getBlockNameLongMain( pIdFilter, dTrennView )); {$ENDIF}
    {$IFDEF FilterProt}
    writeLn( f, TListen.getBlockNameLongMain( pIdFilter, dTrennView ));
    {$ENDIF}
    { Vorgänger als Dummys mit aufnehmen: }
    pId := pIdFilter^.PrevBlock;
    repeat if tIdFlagsDyn.isFiltered in pId^.IdFlagsDyn then begin
             include( pId^.IdFlagsTv[_tvFil], tIdFlagsTv.hasSub );     // der direkte Vorgänger des neu gefundenen braucht noch das hasSub-Flag
             break    // ist schon echt oder dummy enthalten, bleibt dabei. Die übergeodneten sind auch schon geflagt
             end
           else begin
             include( pId^.IdFlagsTv[_tvFil], tIdFlagsTv.hasSub );
             pId^.IdFlagsDyn := pId^.IdFlagsDyn + [tIdFlagsDyn.isFiltered, tIdFlagsDyn.isFilteredDummy];
             end;
           pId := pId^.PrevBlock
    until  pId = @IdMainMain;
    inc( Result )
  end;

  procedure CheckParentList( pAc: pacInfo );
  var pId: pIdInfo;
  begin
    if ( pAc <> nil ) and ( pAc^.ZugriffTyp = ac_Declaration ) then begin   // nicht, wenn dieser Parent gar keine Deklaration hat
      if tIdFlags2.IsForward in pAc^.IdDeclare^.IdFlags2 then               // das war nur die forward-Deklaration,
        repeat pAc := pAc^.NextAc until pAc^.ZugriffTyp = ac_Declaration;   // noch etwas weitersuchen bis zur echten
      TListen.incAcPtr( pAc );
      while pAc^.IdDeclare^.Typ in [id_Type, id_KeyWord] do begin
        if tIdFlags.IsInterface in pAc^.IdDeclare^.IdFlags then begin
          pId := pIdFilter;
          pIdFilter := pAc^.IdDeclare;
          Found;
          CheckParentList( pIdFilter^.AcList );
          pIdFilter := pId
          end;
        TListen.incAcPtr( pAc )
        end
      end
  end;

begin
  {$IFDEF TraceDx} TraceDx.Call( 'DoFilter' ); {$ENDIF}
  frmMain.Cursor := crHourGlass;
  pIdFilter := MyTv[tvAll].FirstNode;
  LastBlock := @IdMainMain;
  case filter of
    fiText      : begin
                    FilterData.SearchText := LowerCase( frmFilter.cmbBoxName.Text );
                    CmpFunc := @CmpFuncText;
                    FilterData.CmpMode := cfNul;
                    Middle := FilterData.SearchText.Chars[0] = cSearchStartEnd;
                    if Middle then begin
                      FilterData.SearchText := FilterData.SearchText.Substring( 1 );
                      if FilterData.SearchText = EmptyStr then exit;
                      end;
                    Ende := FilterData.SearchText.Chars[high( FilterData.SearchText )] = cSearchStartEnd;
                    if Ende then begin
                      Ende := FilterData.SearchText.Chars[high(FilterData.SearchText)-1] <> cSearchStartEnd;                        // "p.."  -> Suche p. nicht am Ende
                      SetLength( FilterData.SearchText, FilterData.SearchText.Length-1 );
                      if not Ende and ( FilterData.SearchText.Chars[high(FilterData.SearchText)-1] = cSearchStartEnd ) then begin   // 'p...' -> Suche p. am Ende
                        SetLength( FilterData.SearchText, FilterData.SearchText.Length-1 );
                        Ende := true
                        end;
                      if FilterData.SearchText = EmptyStr then exit;
                  // . ist escape-char. Falls .. also "." ab Start suchen
                      end;
                    FilterData.SearchHash := GetHash( FilterData.SearchText );
                    FilterData.CmpMode := tCmpMode( 1 + byte(Middle) + byte(Ende) shl 1 )
                  end;
    fiPerType   : CmpFunc   := @CmpFuncPerType;
    fiUndeclared: begin
                    CmpFunc   := @CmpFuncNoDeclare;
                    LastBlock := @UnitSystem
                  end;
    fiDeclareOnly:CmpFunc := @CmpFuncDeclareOnly;
    fiNoWrites  : CmpFunc := @CmpFuncNoWrite;
    fiNoReads   : CmpFunc := @CmpFuncNoRead;
    fiUnusedUnit: begin
                  // System und undeclared nicht scannen
                  CmpFunc   := @CmpFuncUncalledUnit;
                  LastBlock := @UnitSystem
                  end;
    fiUnitCalls : CmpFunc  := @CmpFuncUnitCalls;
    fiReferencers:begin
                    CmpFunc  := nil;    // Schleife läuft anders
                    LastBlock := @UnitSystem   // Dummy, nur damit letzter Filter gelöscht wird
                  end;
    fiNonANSI   : CmpFunc  := @CmpFuncNonANSI;
    fiHierarchy :begin
                    CmpFunc  := nil;    // Schleife läuft anders
                    LastBlock := @UnitSystem   // Dummy, nur damit letzter Filter gelöscht wird
                  end;
    fiMessages  : CmpFunc  := @CmpFuncMessages;
    fiGenerics  : CmpFunc  := @CmpFuncGenerics;
    fiOverloads : CmpFunc  := @CmpFuncOverloads;
    {fiParaConst: begin
                  CmpMode  := cfParaConst;
                  LastNode := MainBlock[mbSystem].MyNode
                 end;
    fiRecursive: begin
                  CmpMode  := cfRecursive;
                  LastNode := MainBlock[mbSystem].MyNode
                 end;}
    else         Error( errInternal, '' )
    end;

  CntProjectUse := 0;
  Result        := 0;
  {$IFDEF FilterProt}
  case filter of
    fiIdName     : s := 'Id ' + frmFilter.cmbBoxFilter.Text;
    fiUnitCalls,
    fiReferencers: s := ReplaceStr( lblArray[ filter ].Caption, '"', '' )
    else           s := lblArray[ filter ].Caption
    end;
  assignFile( f, frmMain.dlgOpen.FileName + '.filter ' + s );
  ReWrite( f );
  {$ENDIF}

//  if ( pIdFilter <> nil ) and ( pIdFilter <> LastBlock ) then
  if not ( filter in [fiReferencers, fiHierarchy] ) then
    repeat with pIdFilter^ do begin
             OpenCount[_tvFil] := 0;
             IdFlagsTv[_tvFil] := IdFlagsTv[_tvFil] - [tIdFlagsTv.hasSub, tIdFlagsTv.SubTreeOpen];
             IdFlagsDyn        := IdFlagsDyn        - [tIdFlagsDyn.isFiltered, tIdFlagsDyn.isFilteredDummy];
             if ( PrevBlock <> @IdMainMain ) and CmpFunc( pIdFilter )
               then Found
             end
    until not GetNextFilter;

  if LastBlock <> @IdMainMain then begin
    { falls Filterung vorzeitig beendet: zusätzliche FilterFinds vom vorigen Search auch löschen: }
    LastBlock := @IdMainMain;
    repeat with pIdFilter^ do begin
             OpenCount[_tvFil] := 0;
             IdFlagsTv[_tvFil] := IdFlagsTv[_tvFil] - [tIdFlagsTv.hasSub, tIdFlagsTv.SubTreeOpen];
             IdFlagsDyn        := IdFlagsDyn        - [tIdFlagsDyn.isFiltered, tIdFlagsDyn.isFilteredDummy]
             end
    until not GetNextFilter
    end;

  { Spezialbehandlung weil andere (kurze) Schleife: }
  case filter of
  fiReferencers: begin
    pAcFilter := MyTv[AktTv].AktNode^.AcList;
    while pAcFilter <> nil do begin
      pIdFilter := pAcFilter^.IdUse;
      if ( pIdFilter^.Typ <> id_MainBlock ) and not ( tIdFlagsDyn.IsFiltered in pIdFilter^.IdFlagsDyn )
        then Found;
      pAcFilter := pAcFilter^.NextAc
      end;
    end;
  fiHierarchy: begin
    pIdFilter := MyTv[AktTv].AktNode;
    if [tIdFlags.IsClassType, tIdFlags.IsInterface] * pIdFilter^.IdFlags <> [] then begin
      while pIdFilter^.MyType <> nil do pIdFilter := pIdFilter^.MyType;
      repeat
        if FileOptions.ProjectUsedOnly and not ( tIdFlags2.IdProjectUse in pIdFilter^.IdFlags2 )
          then inc( CntProjectUse )    // nur hier können über die MyType-Verkettung auch tv-aussortierte auftauchen
          else Found;
        CheckParentList( pIdFilter^.AcList );    //Versuch, auch Interfaces zu finden
        pIdFilter := pIdFilter^.MyParent
      until pIdFilter = nil
      end
    end;
  end;

  {$IFDEF FilterProt}
  CloseFile( f );
  {$ENDIF}
  frmMain.Cursor := crDefault
end;

{ actIdViewFilterExecute }
procedure TfrmMain.actIdViewFilterExecute( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'actIdViewFilterExecute' ); {$ENDIF}
  { falls kein find: automatisch in Filter-Dialog, von dort dann auch Umschaltung nach tvFil }
  if ( AktTv = tvAll ) and ( Sender = actIdViewFilter ) and ( MyTv[_tvFil].FirstNode = nil ) then begin
    actIdSetFilterExecute( actIdSetFilter );
    if MyTv[_tvFil].FirstNode = nil then   // abgebrochen oder keine matches
      tBtnIdFilter.Down := false
    end
  else begin
    if AktTv = tvAll
      then AktTv := _tvFil
      else AktTv := tvAll;

    ScrollBarTv.Max         := MyTv[AktTv].MaxIndex;
    ScrollBarTv.Position    := MyTv[AktTv].TopIndex;
    PaintBox.OnPaint        := nil;                      // PaintBoxPaint muss evtl erst nach dem Aufrufer gemacht werden
    pnlLblFilter.Visible    := AktTv = _tvFil;           // löst PaintBoxPaint zu früh aus und SYNCHRON !
    MyTv[AktTv].OnResize;
    PaintBox.OnPaint        := PaintBoxPaint;
    PaintBox.Invalidate;                                 // jetzt asynchrones PaintBoxPaint starten
    actIdViewFilter.Checked := AktTv = _tvFil;
    tBtnIdFilter.Down       := AktTv = _tvFil;
    tBtnIdFilter.Hint       := 'View ' + cHint[AktTv] + '   <Ctrl-TAB>';
    if ( Sender = actIdViewFilter ) and ( MyTv[tvAll].AktNode <> MyTv[_tvFil].AktNode ) then
      MyTv[AktTv].SetActivePid( MyTv[AktTv].AktNode );
    ActiveControl           := ScrollBarTv;
//      UserInfo.Show( 'Actual view:     ' + ifthen( AktTv = tvAll, 'All', 'Filtered' ) + ' Identifiers.'
//                                        + ifthen( ( AktTv <> tvAll ) or ( MyTv[_tvFil].FirstNode <> nil ) , '     Use-Ctrl-TAB to change view', '' )
//                                        + ifthen(   AktTv = _tvFil, ' (+Shift for Id-sync)', '' ))
    end
end;

{ actIdSetFilterExecute }
procedure TfrmMain.actIdSetFilterExecute( Sender: TObject );
const cFilter    = 'Filtered  ( ';
      cNotAvail  = 'Filter not available for selected Identifier';
      cNur1      : array[boolean] of string = ( 'es', '' );
var matches: integer;
    s      : string;
    m      : tMainBlock;
    X      : word;
    f      : tFilters;
begin
  {$IFDEF TraceDx} TraceDx.Call( 'actIdSetFilterExecute' ); {$ENDIF}
  {Vorbereitungen: }
  if ( Sender <> pItmIdFilterName ) and ( AktTv = tvAll ) then begin
    if ActiveControl = cmbBoxSearch
      then frmFilter.cmbBoxName.Text := cmbBoxSearch.Text
      else frmFilter.cmbBoxName.Text := MyTv[tvAll].AktNode^.Name;
    frmFilter.radGrpFilter.ItemIndex := 0;

    if MyTv[tvAll].AktNode^.Typ in [id_Label..id_Final] then
      frmFilter.cmbBoxTyp.ItemIndex := ord( MyTv[tvAll].AktNode^.Typ ) - ord( id_Label )
    end;
//  HideHotKeys;

  if ( Sender = pItmIdFilterName{F6} ) or ( frmFilter.ShowModal = mrOk ) then begin

    f := tFilters( frmFilter.radGrpFilter.ItemIndex );
    s := frmFilter.radGrpFilter.Items[ord( f )].Replace( '&', '' );
    case f of
      fiText       : s := s + ': ' + frmFilter.cmbBoxName.Text;
      fiPerType    : s := s + ': ' + frmFilter.cmbBoxTyp.Text;
      fiUnitCalls  : if ( MyTv[AktTv].AktNode^.Typ <> id_Unit ) or ( MyTv[AktTv].AktNode^.PrevBlock = @IdMainMain )
                       then begin UserInfo.Show( cNotAvail, tUserInfo.InfoType.inError ); exit end
                       else s := s + ' by ' + MyTv[AktTv].AktNode^.Name;
      fiReferencers: if not ( MyTv[AktTv].AktNode^.Typ in [id_Unit..id_Func, id_ConstInt..id_PascalDirective] )
                       then begin UserInfo.Show( cNotAvail, tUserInfo.InfoType.inError ); exit end
                       else s := s + ' of ' + MyTv[AktTv].AktNode^.Name
    end;

      // evtl Tv löschen
    matches := DoFilter( f );

    if matches = 0 then begin
      if CntProjectUse = 0
        then UserInfo.Show( 'No matches found for this Filter-Condition'                                                , tUserInfo.InfoType.inWarning )
        else UserInfo.Show( 'All matches (' + CntProjectUse.ToString + ') hidden due to Option "Hide Library-Internals"', tUserInfo.InfoType.inWarning );
      MyTv[_tvFil].FirstNode := nil;
      if AktTv = _tvFil then
        actIdViewFilterExecute( actIdSetFilter )
      end
    else begin
      frmMain.lblFilter.Caption := cFilter + matches.ToString + ' match' + cNur1[matches=1] + ' ):' + sLineBreak + s;

      with MyTv[_tvFil] do begin

        if AktTv = tvAll then
          actIdViewFilterExecute( nil );

        IdMainMain.OpenCount[_tvFil] := 0;
        for m := mbBlock0 to high( tMainBlock ) do
          if tIdFlagsTv.hasSub in MainBlock[m].IdFlagsTv[_tvFil] then begin
            if IdMainMain.OpenCount[_tvFil] = 0 then FirstNode := @MainBlock[m];    // hier am einfachsten den ersten Ober-Parent-MainBlock merken
            inc( IdMainMain.OpenCount[_tvFil] )
            end;

        TopNode  := FirstNode;
        LastNode := nil;
        TopIndex := 0;
        frmMain.ScrollBarTv.Position := 0;

        if matches > ScrollBarTv.LargeChange
          then ExpandSubAll( FirstNode )
          else for m := mbBlock0 to high( tMainBlock ) do if tIdFlagsTv.hasSub in MainBlock[m].IdFlagsTv[_tvFil] then ExpandSubAll( @MainBlock[m] );

        if tIdFlagsDyn.isFiltered in MyTv[tvAll].AktNode^.IdFlagsDyn then
          SetAktAbsPid( MyTv[tvAll].AktNode, false )
        else begin
          if f = fiHierarchy then begin
            if MyTv[AktTv].AktNode^.MyType <> nil
              then SetAktAbsPid( MyTv[AktTv].AktNode^.MyType, false )
              else SetAktAbsPid( MyTv[AktTv].AktNode        , false )
            end
          else begin
            AktNode := FirstNode;
            X := high( X ) shr 1;     // Dummy für getNext
            repeat GetNext( AktNode, X ) until not ( tIdFlagsDyn.isFilteredDummy in AktNode^.IdFlagsDyn );
            SetAktAbsPid( AktNode, false )
            end
          end
        end;
      if CntProjectUse > 0
        then UserInfo.Show( CntProjectUse.ToString + ' more match' + cNur1[matches=1] + ' hidden due to Option "Hide Library-Internals"', tUserInfo.InfoType.inWarning );
      ActiveControl := ScrollBarTv
      end
    end
end;

{ actIdFilterNameExecute }
procedure TfrmMain.actIdFilterNameExecute( Sender: TObject );
begin
  if ( AktTv = _tvFil ) and ( MyTv[tvAll].AktNode = MyTv[_tvFil].AktNode ) then
    actIdViewFilter.Execute   // AktNode in Filter-View unverändert -> schnell zurück nach tvAll
  else
    if MyTv[AktTv].AktNode^.Typ = tIdType.id_MainBlock then
        UserInfo.Show( 'Filter not allowed', tUserInfo.InfoType.inError )
    else begin
      {$IFDEF TraceDx} TraceDx.Call( 'actIdFilterNameExecute', MyTv[AktTv].AktNode^.Name ); {$ENDIF}
      frmFilter.radGrpFilter.ItemIndex := ord( tFilters.fiText );
      frmFilter.cmbBoxName.Text := MyTv[AktTv].AktNode^.Name + cSearchStartEnd;
      actIdSetFilterExecute( pItmIdFilterName );
      UserInfo.Show( 'Filter-Ansicht.   Zurück mit F6, aktueller Identifier wird dabei mitgenommen.  Mitnahme verhindern mit Shift-F6', inHintUI )
      end
end;

{ actIdFilterHierarchyExecute }
procedure TfrmMain.actIdFilterHierarchyExecute( Sender: TObject );
begin
  HideHotKeys;
  {$IFDEF TraceDx} TraceDx.Call( 'actIdFilterHierarchyExecute', MyTv[AktTv].AktNode^.Name ); {$ENDIF}
  frmFilter.radGrpFilter.ItemIndex := ord( tFilters.fiHierarchy );
  HideHotKeys;  // evtl Ctrl-F6
  actIdSetFilterExecute( pItmIdFilterName )
end;

{ lblFilterClick }
procedure TfrmMain.lblFilterClick( Sender: TObject );
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'lblFilterClick' ); {$ENDIF} {$ENDIF}
  actIdSetFilter.Execute
end;

{$ENDREGION }

{$REGION '-------------- tvAll ---------------' }

(* TreeViewClearItems *)
procedure TreeViewClearItems;
begin
  {$IFDEF TraceDx} TraceDx.Call( 'TreeViewClearItems' ); {$ENDIF}
  frmMain.tvFiles.Items.Clear;
  frmMain.lstBox.Count := 0;
end;

{$ENDREGION }

{$REGION '-------------- tvFiles ---------------' }

(* BuildFileTree *)
procedure BuildFileTree;
const
  cNotFoundFiles = '< not found >';
var tnLib: array of tTreeNode;
    tnUnit: tTreeNode;
    f: tFileIndex;
    s: string;
begin
  {$IFDEF TraceDx} TraceDx.Call( 'BuildFileTree' ); {$ENDIF}
  { tvFiles aufbauen: }
  frmMain.tvFiles.Items.BeginUpdate;
  frmMain.tvFiles.Items.Clear;

  { Librarys vorbereiten: }
  SetLength( tnLib, high( IncludesUnitAll )+1 );
  for f := 1 to high( IncludesUnitAll ) do begin
    IncludesUnitAll[f][high( IncludesUnitAll[f] )] := ' ';
    tnLib[f] := frmMain.tvFiles.Items.Add( nil, '< ' + TPath.GetFileName( IncludesUnitAll[f] ) + '>' )
    end;

  { alle Dateien einhängen: }
  for f := cFirstFileV to high( DateiListe ) do with DateiListe[f]^ do
    if UnitName = '' then    // include-file
      if prevFile < f   // falls mehrfach includiert ist der letzte includierer evtl noch nicht im Tree. Dann unter "nil" einhängen
        then MyNode := frmMain.tvFiles.Items.AddChildObject( DateiListe[prevFile]^.MyNode, TPath.GetFileName( FileName ), DateiListe[f] )
        else MyNode := frmMain.tvFiles.Items.AddChildObject( nil                         , TPath.GetFileName( FileName ), DateiListe[f] )
    else begin
      if LibraryNr > 0
        then           frmMain.tvFiles.Items.AddChildObject( tnLib[LibraryNr], UnitName, DateiListe[f] )
        else tnUnit := frmMain.tvFiles.Items.AddObject     ( nil             , UnitName, DateiListe[f] );
      MyNode := tnUnit
      end;

  { Librarys ans Ende schieben: }
  for f := 1 to high( IncludesUnitAll ) do
    if tnLib[f].HasChildren
      then tnLib[f].MoveTo( tnUnit, naAdd )
      else tnLib[f].Delete;

  if NotFoundFiles.Count > 0 then begin
    tnLib[0] := frmMain.tvFiles.Items.Add( nil, cNotFoundFiles );
    for s in NotFoundFiles do frmMain.tvFiles.Items.AddChild( tnLib[0], s )
    end;
  frmMain.tvFiles.Items.EndUpdate
end;

(* tvFilesCustomDrawItem *)
procedure TfrmMain.tvFilesCustomDrawItem( Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean );
var z: tAcTypeSet;
begin
//  {$IFDEF TraceDx} TraceDx.Call( 'tvFilesCustomDrawItem', Node.AbsoluteIndex ); {$ENDIF}
  z := [];
  if Node.Data = nil then begin
    if Node.AbsoluteIndex = 0
      then z := LibraryAccess { Knoten "Library" }
    end
  else
    z := pFileInfo(Node.Data)^.PidAccess;

  if ac_Declaration in z then
    tvFiles.Canvas.Font.Style := [fsUnderline];
  if z = [] then
    tvFiles.Canvas.Font.Color := clGray else
  if z * [ac_Write, ac_ReadAdress, ac_Unknown] <> [] then
    tvFiles.Canvas.Font.Color := cAcShow[ac_Write].Color else
  if z = [ac_Declaration]
    then tvFiles.Canvas.Font.Color := cAcShow[ac_Declaration].Color
    else tvFiles.Canvas.Font.Color := cAcShow[ac_Read       ].Color
end;

(* tvFilesClick *)
procedure TfrmMain.tvFilesClick( Sender: TObject );
const cFileInc: array[0..2] of string = ( 'Unit', 'Include', 'Resource' );
begin
  if tvFiles.Selected <> nil then
    if tvFiles.Selected.Data = nil then
      if tvFiles.Selected.Level > 0
        then UserInfo.Show( tUserInfo.cOpen + 'Not found file' + tUserInfo.cClose + '  ' + tvFiles.Selected.Text, tUserInfo.InfoType.inIdAcFile )
        else UserInfo.Show( '', tUserInfo.InfoType.inIdAcFile )
    else with pFileInfo( tvFiles.Selected.Data )^ do begin
           if MyUnit <> nil then tMyTreeView.ChangeAbsPid( MyUnit, true );
           UserInfo.Show( tUserInfo.cOpen + cFileInc[ord( UnitName = '' ) + ord(tFileFlags.isResourceFile in fiFlags )] + '-File' + tUserInfo.cClose + '  ' + FileName, tUserInfo.InfoType.inIdAcFile )
           end
end;

(* tvFilesDblClick *)
procedure TfrmMain.tvFilesDblClick( Sender: TObject );
var Line: tLineIndex;
begin
  if ListBoxData.Modus <> lmAcc then exit;
  {$IFDEF TraceDx} TraceDx.Call( 'tvFilesDblClick' ); {$ENDIF}
  if ( tvFiles.Selected <> nil ) and ( tvFiles.Selected.Data <> nil ) and not ( tFileFlags.isResourceFile in pFileInfo( tvFiles.Selected.Data )^.fiFlags ) then begin
    if ( Sender = nil ) or
       (( ListBoxData.SelectedAc <> nil )  and
        ( pFileInfo( tvFiles.Selected.Data )^.MyIndex = ListBoxData.SelectedAc^.Position.Datei )) { aus lstBox.DblClick }
      then Line := ListBoxData.SelectedAc^.Position.Zeile
      else Line := 0;
    TViewer.LoadViewerFile( MyTv[AktTv].AktNode, pFileInfo( tvFiles.Selected.Data )^.MyIndex, Line )
    end
end;

(* tvFilesKeyDown *)
procedure TfrmMain.tvFilesKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'tvFilesKeyDown' ); {$ENDIF}
  if Key = VK_RETURN then
    tvFilesDblClick( Sender )
end;

procedure DoDragFile( f: pFileInfo );
begin
end;

(* tvFilesMouseMove *)
procedure TfrmMain.tvFilesMouseMove( Sender: TObject; Shift: TShiftState; X,Y: Integer );
var pos: tFilePos;
begin
  if ( ssLeft in Shift ) and
      (( Abs( X - ListBoxData.MouseDownX ) >= cDragThreshold ) or
       ( Abs( Y - ListBoxData.MouseDownY ) >= cDragThreshold )) then
    if ( ListBoxData.Modus = lmAcc ) and not UseClipBoard and ( tvFiles.Selected.Data <> nil ) then begin   // nach Ende DragDrop kommt beim nächsten MouseDown AUCH NOCH EIN MouseMove mit derselben Position
      { DragDrop zur IDE starten: }
      {$IFDEF TraceDx} TraceDx.Call( 'tvFilesMouseMove-DragDrop' ); {$ENDIF}
      tvFiles.Perform( WM_LBUTTONUP, 0, MakeLong( X, Y) );   // sonst wird DragDrop nie beendet
  //    TControl(Sender).ControlState := TControl(Sender).ControlState - [csLButtonDown];
      with pFileInfo( tvFiles.Selected.Data )^ do
        if fiFlags * [tFileFlags.isFormular, tFileFlags.isResourceFile] <> [] then
          UserInfo.Show( 'Resource-Files can''t be dragged', tUserInfo.InfoType.inError )
        else
          if TFile.Exists( Filename ) then begin
            DragAcceptFiles( frmMain.Handle, false );
            if tFileFlags.isNotLatest in fiFlags
              then UserInfo.Show( 'Drag file ' + FileName + '     ( latest Version not parsed! )', tUserInfo.InfoType.inWarning )
              else UserInfo.Show( 'Drag file ' + FileName , tUserInfo.InfoType.inAction );
            if DragDropToExtern( TPath.GetDirectoryName( FileName ), [FileName], TViewer.OnDrop ) then begin
              UserInfo.Show( 'Dropping file ' + FileName, tUserInfo.InfoType.inAction );
              TViewer.SendInput( 2, tFileFlags.hasFormular in fiFlags, pos )
              end
            else
              UserInfo.Show( cDropIsNotIDE, tUserInfo.InfoType.inError );
            DragAcceptFiles( frmMain.Handle, true )
            end
          else
            UserInfo.Show( 'File ' + Filename + ' not found!' )
      end
end;

(* PopupMenuFilePopup *)
procedure TfrmMain.PopupMenuFilePopup( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'PopupMenuFilePopup' ); {$ENDIF}
  PopupItmFileDefines.Enabled := pFileInfo( tvFiles.Selected.Data )^.MyUnit <> nil;
  PopupItmFileOptions.Enabled := PopupItmFileDefines.Enabled;
end;

(* PopupItmFileViewClick *)
procedure TfrmMain.PopupItmFileViewClick( Sender: TObject );
var Key: Word;
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'PopupItmFileViewClick' ); {$ENDIF} {$ENDIF}
  Key := VK_RETURN;
  tvFilesKeyDown( Sender, Key, [] )
end;

{$ENDREGION }

{$REGION '-------------- Suchen ---------------' }
var
  SearchData: tCmpData;

(* SaveCombo *)
procedure SaveCombo;
var i: integer;
begin
  with frmMain.cmbBoxSearch do if Text <> '' then begin
    {$IFDEF TraceDx} TraceDx.Call( 'SaveCombo', Text ); {$ENDIF}
    i := Items.IndexOf( Text );
    case i of
      -1 : Items.Insert( 0, Text );
       0 : ;
      else Items.Move( i, 0 );
           { RTL-Fehler: Text geht hier verloren, muss refreshed werden: }
           if Text = '' then {$IFDEF TraceDx} TraceDx.Send( 'SaveComboEmpty', i ) {$ENDIF};
           Text := Items[0]
      end
    end;
end;

(* cmbBoxSearchChange *)
procedure TfrmMain.cmbBoxSearchChange( Sender: TObject );
var pIdSuch    : pIdInfo;
    Middle,Ende: boolean;

  function GetNextSuch: boolean;
  begin
    repeat
      if tIdFlagsTv.hasSub in pIdSuch^.IdFlagsTv[AktTv] then
        pIdSuch := pIdSuch^.SubBlock
      else begin
        while pIdSuch^.NextId = nil do begin
          pIdSuch := pIdSuch^.PrevBlock;
          if pIdSuch = @IdMainMain then exit( false );
          end;
        pIdSuch := pIdSuch^.NextId                    // Vorschlag um auf   "until ( pId^.AcSet <> [] )" zu verzichten (hier und im Expand/Collapse):
        end                                   // (1) System-Original-Verkettung sichern    (2) System nur benutzte neu verketten       (0) Virtual ist ja schon raus!
    until TestInTree( pIdSuch );       // Unit System hat Ids ohne Nutzung
    Result := true
  end;

  function DoSearch: boolean;

    function f: boolean;
    begin
      case SearchData.CmpMode of
      cfNormal   : result :=   LowerCase( pIdSuch^.Name ).StartsWith( SearchData.SearchText );
      cfMiddle   : result :=   LowerCase( pIdSuch^.Name ).IndexOf   ( SearchData.SearchText ) <> -1;
      cfEnd      : result := ( SearchData.SearchHash = pIdSuch^.Hash ) and
                             ( LowerCase( pIdSuch^.Name ).Equals    ( SearchData.SearchText ));
      cfMiddleEnd: result :=   LowerCase( pIdSuch^.Name ).EndsWith  ( SearchData.SearchText )
      else         result :=   false
      end
    end;

  begin
    with MyTv[AktTv] do
      repeat if f
               then exit( true )
               else if not GetNextSuch then pIdSuch := FirstNode
      until pIdSuch = AktNode;
    Result := false
  end;

begin
  if Sender = cmbBoxSearch then begin
    SearchData.CmpMode := cfNul;
    SearchData.SearchText := LowerCase( cmbBoxSearch.Text );
    if SearchData.SearchText = EmptyStr then exit;
    Middle := SearchData.SearchText.Chars[0] = cSearchStartEnd;
    if Middle then begin
      SearchData.SearchText := SearchData.SearchText.Substring( 1 );
      if SearchData.SearchText = EmptyStr then exit;
      end;
    Ende := SearchData.SearchText.Chars[high( SearchData.SearchText )] = cSearchStartEnd;
    if Ende then begin
      Ende := SearchData.SearchText.Chars[high(SearchData.SearchText)-1] <> cSearchStartEnd;                        // "p.."  -> Suche p. nicht am Ende
      SetLength( SearchData.SearchText, SearchData.SearchText.Length-1 );
      if not Ende and ( SearchData.SearchText.Chars[high(SearchData.SearchText)-1] = cSearchStartEnd ) then begin   // 'p...' -> Suche p. am Ende
        SetLength( SearchData.SearchText, SearchData.SearchText.Length-1 );
        Ende := true
        end;
      if SearchData.SearchText = EmptyStr then exit;
// . ist escape-char. Falls .. also "." ab Start suchen
      end;
    SearchData.SearchHash := GetHash( SearchData.SearchText );
    SearchData.CmpMode    := tCmpMode( 1 + byte(Middle) + byte(Ende) shl 1 )
    end
  else begin
    if SearchData.CmpMode = cfNul then exit
    end;
  {$IFDEF TraceDx} TraceDx.Call( 'cmbBoxSearchChange', SearchData.SearchText ); {$ENDIF}
  with MyTv[AktTv] do begin
    pIdSuch := AktNode;
    if Sender <> cmbBoxSearch then
      if not GetNextSuch then
        pIdSuch := FirstNode;

    if DoSearch
      then SetAktAbsPid( pIdSuch, false )
      else UserInfo.Show( 'Identifier "' + cmbBoxSearch.Text + '" not found', tUserInfo.InfoType.inWarning );
    end
end;

(* cmbBoxSearchKeyPress *)
procedure TfrmMain.cmbBoxSearchKeyPress( Sender: TObject; var Key: Char );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'cmbBoxSearchKeyPress', Key ); {$ENDIF}
  if Key = #13 then
    cmbBoxSearchChange( cmbBoxSearch )
end;

(* actSearchExecute *)
procedure TfrmMain.actSearchExecute( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'actSearchExecute' ); {$ENDIF}
  if ActiveControl = cmbBoxSearch then
    cmbBoxSearch.SelectAll
  else
    if cmbBoxSearch.Text = '' then begin
      cmbBoxSearch.Text := MyTv[AktTv].AktNode^.Name;
      cmbBoxSearchChange( cmbBoxSearch )
      end;
    cmbBoxSearch.SetFocus
end;

(* actSearchAgainExecute *)
procedure TfrmMain.actSearchAgainExecute( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'actSearchAgainExecute' ); {$ENDIF}
  if cmbBoxSearch.Text = ''
    then actSearchExecute( nil )
    else cmbBoxSearchChange( Sender )
end;

(* actIdentifierBackExecute *)
procedure TfrmMain.actIdentifierBackExecute( Sender: TObject );
var Key: word;
begin
  Key := VK_BACK;
  if ActiveControl = cmbBoxSearch then
    ActiveControl := CtrlArray[ctMyTv];
  FormKeyDown( Sender, Key, [] )
end;

(* actIdReduceExecute *)
procedure TfrmMain.actIdReduceExecute( Sender: TObject );
var m: pIdInfo;
begin
  {$IFDEF TraceDx} TraceDx.Call( 'actIdReduceExecute' ); {$ENDIF}
  with MyTv[AktTv] do begin
    { 0.  im Gegensatz zu den anderen Collapses ist hier AktNode <> m !
          deshalb Absturz im OnVisiblesChange wenn TopIndex korrigiert werden muss.
          Massnahme dagegen: TopIndex auf 0 setzen }
    TopIndex := 0;
    TopNode  := FirstNode;
    { 1.  alle komplett zu machen }
    m := @MainBlock[mbBlock0];
    repeat CollapseSubAll( m );
           m := m^.NextId
    until  m = nil;
    { 2.  AktPid anzeigen }
    SetAktAbsPid( AktNode, false )
    end
end;

(* cmbBoxSearchDblClick *)
procedure TfrmMain.cmbBoxSearchDblClick( Sender: TObject );
begin
  cmbBoxSearchChange( cmbBoxSearch )
end;

(* cmbBoxSearchExit *)
procedure TfrmMain.cmbBoxSearchEnter( Sender: TObject );
begin
  cmbBoxSearch.Color := clInfoBk
end;

procedure TfrmMain.cmbBoxSearchExit( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'cmbBoxSearchExit' ); {$ENDIF}
  cmbBoxSearch.Color := clWindow;
  if cmbBoxSearch.Text <> '' then
    SaveCombo
end;

{$ENDREGION }

{$REGION '-------------- lstBox ---------------' }

(* DrawAccess *)
procedure DrawAccess( t: integer; pAc: pAcInfo; const s: string );
begin
//  {$IFDEF TraceDx} TraceDx.Send( 'TfrmViewer.DrawAccess', lbCharWidth ); {$ENDIF}
  frmMain.lstBox.Canvas.Font.Color := cAcShow[pAc^.ZugriffTyp].Color ;
  frmMain.lstBox.Canvas.Font.Style := [fsUnderline];
  frmMain.lstBox.Canvas.TextOut( lbCharWidth * ( pAc^.Position.Spalte), t,
                                 s.Substring(    pAc^.Position.Spalte, pAc^.Position.Laenge ))
//  Alternativ als Rechteck:
//  c.Brush.Color := cAccessColor [pAc^.ZugriffTyp];
//  c.FrameRect( System.Types.Rect( CharWidth * ( pAc^.Position.Spalte-1 ), t,
//                                  CharWidth * ( pAc^.Position.Spalte-1+pAc^.Position.Laenge ), Rect.Bottom ));
end;

{ SetAccessLinesCount }
procedure SetAccessLinesCount( a: integer );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'SetAccessLinesCount', a * ListBoxData.AcBlockSize ); {$ENDIF}
  ListBoxData.AccessCount := a;
  frmMain.lstBox.Count := a * ListBoxData.AcBlockSize;
  // Top so setzen, dass SelectedAccess sichtbar bleibt
end;

{GetNextAc }
function GetNextAc( pAc: pAcInfo ): pAcInfo;
var NoCheckWrite,
    NoCheckUnit,
    NoCheckVia   : boolean;
begin
  with pIdInfo( MyTv[AktTv].AktNode )^ do begin
    NoCheckWrite := not ( tIdFlagsDyn.WriteOnly in IdFlagsDyn );
    NoCheckVia   := not ( tIdFlagsDyn.ViaOnly   in IdFlagsDyn );
    NoCheckUnit  := not ( tIdFlagsDyn.UnitOnly  in IdFlagsDyn );
    if pAc = nil
      then Result := AcList
      else Result := pAc^.NextAc
    end;

  if NoCheckWrite and NoCheckVia then
    // ist bereits gesetzt
  else
    while Result <> nil do
      if ( NoCheckWrite or ( Result^.ZugriffTyp <> ac_Read )   )     and
         ( NoCheckUnit  or   CheckUnitInIdUseList( Result^.IdUse ))  and
         ( NoCheckVia   or   CheckViaInAcIdList( Result ))
        then break
        else Result := Result^.NextAc
end;

{GetAc }
function GetAc( Index: integer ): pAcInfo;
var i            : integer;
    NoCheckWrite,
    NoCheckUnit,
    NoCheckVia   : boolean;
begin
  if ListBoxData.GetCache.idx = Index     then
    Result := ListBoxData.GetCache.pAc    else

  if ListBoxData.GetCache.idx = Index - 1 then begin
    Result := getNextAc( ListBoxData.GetCache.pAc );
    ListBoxData.GetCache.idx := Index;
    ListBoxData.GetCache.pAc := Result
    end

  else begin
    ListBoxData.GetCache.idx := Index;
    with pIdInfo( MyTv[AktTv].AktNode )^ do begin
      Result := AcList;
      NoCheckWrite := not ( tIdFlagsDyn.WriteOnly in IdFlagsDyn );
      NoCheckVia   := not ( tIdFlagsDyn.ViaOnly   in IdFlagsDyn );
      NoCheckUnit  := not ( tIdFlagsDyn.UnitOnly  in IdFlagsDyn );
      end;

    if NoCheckWrite and NoCheckVia and NoCheckUnit then
      for i := 1 to Index do Result := Result^.NextAc
    else begin
      i := -1;
      repeat
        if ( NoCheckWrite or ( Result^.ZugriffTyp <> ac_Read )   )     and
           ( NoCheckUnit  or   CheckUnitInIdUseList( Result^.IdUse ))  and
           ( NoCheckVia   or   CheckViaInAcIdList( Result ))
          then inc( i );

        if i = Index
          then break
          else Result := Result^.NextAc
      until false
      end;

    ListBoxData.GetCache.pAc := Result
    end
end;

{SetCacheAccess }
procedure SetCacheAccess( Index: integer );
{ für Access Nr i wird der erste pAc gecachet }
begin
  if ListBoxData.AcCache.idx = Index then begin
//    {$IFDEF TraceDx} TraceDx.Send( 'Cache-Hit', Index ); {$ENDIF}
    {$IFDEF TraceDx} inc( ListBoxData.AcCache.Hit ) {$ENDIF}
    end
  else begin
//    {$IFDEF TraceDx} TraceDx.Send( 'Cache-Miss', Index ); {$ENDIF}
    {$IFDEF TraceDx} inc( ListBoxData.AcCache.Miss); {$ENDIF}
    ListBoxData.AcCache.idx := Index;
    ListBoxData.AcCache.pAc := MyTv[AktTv].AktNode^.AcList;
    if Index > -1 then
      ListBoxData.AcCache.pAc := GetAc( Index );
//    {$IFDEF TraceDx} TraceDx.Send( 'Cache-File', ListBoxData.AcCache.pAc^.Position.Datei ) {$ENDIF}
    end;
end;

{SetSelectedFile }
procedure SetSelectedFile( Index: tFileIndex_ );
begin
  if Index = -1
    then frmMain.tvFiles.Selected := nil
    else frmMain.tvFiles.Selected := DateiListe[ListBoxData.AcCache.pAc^.Position.Datei].MyNode
end;

{ SelectAccess }
procedure SelectAccess( a: integer );
begin
  if a <= ListBoxData.AccessCount then begin
    if ListBoxData.SelectedAcNr <> a then begin
      {$IFDEF TraceDx} TraceDx.Call( 'SelectAccess', a ); {$ENDIF}
      ListBoxData.SelectedAcNr := a;
      SetCacheAccess( a );
      ListBoxData.SelectedAc := ListBoxData.AcCache.pAc;
      frmMain.lstBox.Invalidate;
      end;
    if ( a <> -1 ) and ( frmMain.ActiveControl = CtrlArray[ctList] ) then with ListBoxData.SelectedAc^ do
      UserInfo.Show( tUserInfo.cOpen + cAcShow[ZugriffTyp].Text + tUserInfo.cClose + '  in  ' + DateiListe[Position.Datei]^.FileName{ + '    ' + Position.Zeile.toString + ' / ' + Position.Spalte.toString}, tUserInfo.InfoType.inIdAcFile )
    end
end;

(* lstBoxMouseMove *)
procedure TfrmMain.lstBoxMouseMove( Sender: TObject; Shift: TShiftState; X,Y: Integer );
var m: integer;

  procedure PaintLine;
  begin
    lstBox.Canvas.MoveTo( ( ListBoxData.EraseAc^.Position.Spalte-cSpalte0 {- ListBoxData.Indent} ) * lbCharWidth,
                          ( ListBoxData.EraseLine - lstBox.TopIndex + 1 ) * lstBox.ItemHeight - 2 );
    lstBox.Canvas.LineTo( lstBox.Canvas.PenPos.X + ListBoxData.EraseAc^.Position.Laenge * lbCharWidth,
                          lstBox.Canvas.PenPos.Y )
  end;

begin
//  {$IFDEF TraceDx} TraceDx.Call( 'lstBoxMouseMove' ); {$ENDIF}
  if ( csLButtonDown in lstBox.ControlState ) and
      (( Abs( X - ListBoxData.MouseDownX ) >= cDragThreshold ) or            // ohne Threshold kommt Event auch nach Click
       ( Abs( Y - ListBoxData.MouseDownY ) >= cDragThreshold )) then begin
    if ( ListBoxData.Modus = lmAcc ) and not UseClipBoard then begin   // nach Ende DragDrop kommt beim nächsten MouseDown AUCH NOCH EIN MouseMove mit derselben Position
      { DragDrop zur IDE starten: }
      {$IFDEF TraceDx} TraceDx.Send( 'lstBoxMouseMove-DragDrop' ); {$ENDIF}
      with DateiListe[ListBoxData.AcCache.pAc^.Position.Datei]^ do
        if ( FileName = cDefinesFile ) or ( tFileFlags.isFormular in fiFlags ) then
          UserInfo.Show( 'Formular-Files can''t be dragged', tUserInfo.InfoType.inError )
        else begin
          DragAcceptFiles( Handle, false );
          if tFileFlags.isNotLatest in fiFlags
            then UserInfo.Show( 'Drag file ' + Filename + '     ( latest Version not parsed! )', tUserInfo.InfoType.inWarning )
            else UserInfo.Show( 'Drag file ' + Filename, tUserInfo.InfoType.inAction );
          lstBox.Perform( WM_LBUTTONUP, 0, MakeLong( X, Y) );   // sonst wird DragDrop nie beendet
//        TControl(Sender).ControlState := TControl(Sender).ControlState - [csLButtonDown];
          if DragDropToExtern( TPath.GetDirectoryName( FileName ), [FileName], TViewer.OnDrop ) then begin
            UserInfo.Show( 'Dropping file ' + Filename, tUserInfo.InfoType.inAction );
            TViewer.SendInput( 0, tFileFlags.hasFormular in fiFlags, ListBoxData.SelectedAc^.Position )
            end
          else
            if not frmMain.BoundsRect.Contains( Mouse.CursorPos )    // keine Meldung wenn Drop noch innerhalb mir selbst
              then UserInfo.Show( cDropIsNotIDE, tUserInfo.InfoType.inError );
          DragAcceptFiles( Handle, true )
          end;
      end
    end

  else begin
//    {$IFDEF TraceDx} TraceDx.Call( 'lstBoxMouseMove-SearchId' ); {$ENDIF}
    Y := lstBox.TopIndex + Y div lstBox.ItemHeight;
    if ( Y < lstBox.Count ) and ( ListBoxData.Modus = lmAcc ) then begin
      ListBoxData.HoverAc := nil;
      m := Y mod ListBoxData.AcBlockSize;

      if ( m > 0 ) and ( m < ListBoxData.AcBlockSize-1 ) then begin
        X := X div lbCharWidth + cSpalte0 {+ ListBoxData.Indent};
        SetCacheAccess( Y div ListBoxData.AcBlockSize);
        with ListBoxData.AcCache.pAc^.Position do
          if Zeile >= ListBoxData.AcKontext+1-m then
            ListBoxData.HoverAc := TListen.SearchAc(Datei, Zeile-ListBoxData.AcKontext-1+m, X )
        end;

      if ( ListBoxData.EraseAc <> nil ) and ( ListBoxData.EraseAc <> ListBoxData.HoverAc ) then begin
        lstBox.Canvas.Pen.Color := lstBox.Color;
        PaintLine;
        lstBox.Canvas.Pen.Color := clBlack;
        ListBoxData.EraseAc := nil
        end;

      if ListBoxData.HoverAc = nil then
        lstBox.Cursor := crDefault
      else begin
        lstBox.Cursor := crHandPoint;
        ListBoxData.EraseAc := ListBoxData.HoverAc;
        lstBox.Canvas.Pen.Color := clBlack;
        ListBoxData.EraseLine := Y;
        PaintLine
        end
      end
    end
end;

(* lstBoxMouseDown *)
procedure TfrmMain.lstBoxMouseDown( Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer );
var d: integer;
begin
  {$IFDEF TraceDx} TraceDx.Call( 'lstBoxMouseDown', x, y ); {$ENDIF}
  ListBoxData.MouseDownX := X;
  ListBoxData.MouseDownY := Y;
  Y := lstBox.TopIndex + Y div lstBox.ItemHeight;
  if ListBoxData.Modus = lmAcc then
    if Y >= lstBox.Count then begin
      SelectAccess   ( -1 );
      SetSelectedFile( -1 );
      UserInfo.Show( '', tUserInfo.InfoType.inIdAcFile );
      PopupMenuAc.AutoPopup := false
      end
    else begin
      lstBox.ItemIndex := -1;    // sonst kann im OnDrawItem nicht ausgesiebt werden
      d := Y div ListBoxData.AcBlockSize;
      SelectAccess( d );
      SetSelectedFile( ListBoxData.AcCache.pAc^.Position.Datei );
      if ( Button = mbLeft ) and ( ssDouble in Shift ) then begin
        lstBox.Cursor := crDefault;
        lstBox.Perform( WM_LBUTTONUP, 0, MakeLong( X, Y) );   // VCL-Fehler, "csLButtonDown" ist sonst im MouseMove noch gesetzt
        if ListBoxData.HoverAc = nil
          then //PopupItmAcNassiClick( nil )
               PopupItmAcFileViewerClick( nil )
          else PopupItmAcGotoClick( nil );
        end;
      PopupMenuAc.AutoPopup := true
      end
end;

(* PopupMenuAcPopup *)
procedure TfrmMain.PopupMenuAcPopup( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'PopupMenuAcPopup' ); {$ENDIF}
  PopupItmAcGoto.Enabled := ListBoxData.HoverAc <> nil;
  if PopupItmAcGoto.Enabled
    then PopupItmAcGoto.Caption := 'Goto ' + cHick + ListBoxData.HoverAc^.IdDeclare^.Name + cHick
    else PopupItmAcGoto.Caption := 'Goto ...';
  PopupItmAcGotoUsingId.Enabled := ListBoxData.AcCache.pAc <> nil;
  if PopupItmAcGotoUsingId.Enabled
    then PopupItmAcGotoUsingId.Caption := 'Goto ' + cHick + ListBoxData.AcCache.pAc^.IdUse^.Name + cHick
    else PopupItmAcGotoUsingId.Caption := 'Goto ...';
  PopupItmAcFileViewer .Enabled := ListBoxData.SelectedAcNr <> -1
end;

(* PopupItmAcGotoClick *)
procedure TfrmMain.PopupItmAcGotoClick( Sender: TObject );
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'PopupItmAcGotoClick' ); {$ENDIF} {$ENDIF}
  if tMyTreeView.ChangeAbsPid( ListBoxData.HoverAc^.IdDeclare, true ) then
    ScrollBarTv.SetFocus
end;

(* PopupItmAcGotoUsingIdClick *)
procedure TfrmMain.PopupItmAcGotoUsingIdClick( Sender: TObject );
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'PopupItmAcGotoUsingIdClick' ); {$ENDIF} {$ENDIF}
  if tMyTreeView.ChangeAbsPid( ListBoxData.AcCache.pAc^.IdUse, true ) then
    ScrollBarTv.SetFocus
end;

(* PopupItmAcNassiClick *)
procedure TfrmMain.PopupItmAcNassiClick( Sender: TObject );
var pId    : pIdInfo;
    pAc,
    pAcDecl: pAcInfo;
    z      : tLineIndex;
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'PopupItmAcNassiClick' ); {$ENDIF} {$ENDIF}
  with ListBoxData.SelectedAc^ do begin
//    Abfrage ist unten im try enthalten:
//    if tFileFlags.isResourceFile in DateiListe[Position.Datei]^.fiFlags then
//      exit;
    { Proc suchen in der der Ac sich befindet: }
    pId := IdUse;
    while not ( pId^.Typ in [id_MainBlock, id_Program, id_Unit, id_Proc, id_Func] ) do
      pId := pId^.PrevBlock;

    pAcDecl := nil;
    if not ( pId^.Typ in [id_Program, id_Unit] ) then begin
      { Deklaration dieser Proc suchen (es kann zwei geben): }
      pAc := pId^.AcList;
      while pAc <> nil do begin
        if pAc^.ZugriffTyp = ac_Declaration then
          if pAcDecl = nil
            then       pAcDecl := pAc              // den ersten gefunden
            else begin pAcDecl := pAc; break end;  // den zweiten gefunden, mehr kommt nicht
        pAc := pAc^.NextAc
        end
      end;
    if ( pAcDecl = nil ) or ( pAcDecl^.Position.Zeile > Position.Zeile {das passiert wenn Func in Class-Def gesucht wird} )
      then z := 0
      else z := pAcDecl^.Position.Zeile;
    {$IFNDEF RefBatch}
    NassiFromRef( DateiListe[Position.Datei]^.Filename,
                         DateiListe[Position.Datei]^.StrList,
                         z,
                         Position.Zeile,
                         Position.Spalte,
                         IdDeclare^.Name )
    {$ENDIF}
    end
end;

(* PopupItmAcFileViewerClick *)
procedure TfrmMain.PopupItmAcFileViewerClick( Sender: TObject );
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'PopupItmAcFileViewerClick' ); {$ENDIF} {$ENDIF}
  TViewer.LoadViewerFile( MyTv[AktTv].AktNode, ListBoxData.SelectedAc^.Position.Datei, ListBoxData.SelectedAc^.Position.Zeile )
end;

(* PopupItmAcCopyClick *)
procedure TfrmMain.PopupItmAcCopyClick( Sender: TObject );
var s: string;
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'PopupItmAcCopyClick' ); {$ENDIF} {$ENDIF}
  if ListBoxData.SelectedAcNr <> -1 then begin
    s := DateiListe[ListBoxData.SelectedAc^.Position.Datei]^.StrList[ListBoxData.SelectedAc^.Position.Zeile];
    Clipboard.SetTextBuf( @s[cSpalte0] )
    end;
end;

(* PopupItmAcCopyLongClick *)
procedure TfrmMain.PopupItmAcCopyLongClick( Sender: TObject );
var s: string;
    i,j: word;
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'PopupItmAcCopyLongClick' ); {$ENDIF} {$ENDIF}
  if ListBoxData.SelectedAcNr <> -1 then begin
    s := '';
    if ListBoxData.SelectedAc^.Position.Zeile < ListBoxData.AcKontext
      then i := 0
      else i := ListBoxData.SelectedAc^.Position.Zeile - ListBoxData.AcKontext;
    j := high( DateiListe[ListBoxData.SelectedAc^.Position.Datei]^.StrList );
    if ListBoxData.SelectedAc^.Position.Zeile + ListBoxData.AcKontext < j
      then j := ListBoxData.SelectedAc^.Position.Zeile + ListBoxData.AcKontext;
    for i := i to j do
      s := s + DateiListe[ListBoxData.SelectedAc^.Position.Datei]^.StrList[i] + sLineBreak;
    SetLength( s, s.Length-2 );
    Clipboard.SetTextBuf( @s[cSpalte0] )
    end;
end;

(* lstBoxKeyDown *)
procedure TfrmMain.lstBoxKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
const cKey: array[boolean] of word = ( VK_UP, VK_DOWN );
var Key0, i: word;
begin
  {$IFDEF TraceDx} TraceDx.Call( 'lstBoxKeyDown' ); {$ENDIF}
  if ListBoxData.Modus = lmAcc then begin
    case Key of
      VK_DOWN: begin
                 if ListBoxData.SelectedAcNr < ListBoxData.AccessCount - 1 then begin
                   SelectAccess( ListBoxData.SelectedAcNr + 1 );
//                   lstBox.ItemIndex := ListBoxData.SelectedAcNr * ListBoxData.AcBlockSize + ListBoxData.AcBlockSize - 2;
                   lstBox.ItemIndex := ListBoxData.SelectedAcNr * ListBoxData.AcBlockSize
                   end;
                 Key := 0
               end;
      VK_UP  : begin
                 if ListBoxData.SelectedAcNr > 0 then begin
                   SelectAccess( ListBoxData.SelectedAcNr - 1 );
                   lstBox.ItemIndex := ListBoxData.SelectedAcNr * ListBoxData.AcBlockSize
                 end;
                 Key := 0
               end;

      VK_NEXT,
      VK_PRIOR:begin
                 Key0 := Key;
                 for i := 1 to 3 do begin Key := cKey[Key0=VK_NEXT]; lstBoxKeyDown( Sender, Key, [] ) end;
                 Key := 0
               end;

      VK_HOME: begin
                 SelectAccess( 0 );
                 lstBox.ItemIndex := ListBoxData.SelectedAcNr * ListBoxData.AcBlockSize;
                 Key := 0
               end;
      VK_END : begin
                 SelectAccess( ListBoxData.AccessCount - 1 );
                 lstBox.ItemIndex := ListBoxData.SelectedAcNr * ListBoxData.AcBlockSize + ListBoxData.AcBlockSize - 1;
                 Key := 0
               end;
      end;
    if Key = 0 then
      SetSelectedFile( ListBoxData.AcCache.pAc^.Position.Datei )
    end
end;

(* lstBoxDrawItem *)
procedure TfrmMain.lstBoxDrawItem( Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState );
const cDots = '........................';
      cAcIndex = 8 + ord( id_Func ) + ord( low( tAcType ));
var d,m  : integer;
    s,s2 : string;
    draw : ( drNix, drCount, drSum, drAccess, drLine, drEnd );
    pAc  : pAcInfo;
begin
  if State * [odSelected, odFocused] <> [] then exit;
//  {$IFDEF TraceDx} TraceDx.Call( 'lstBoxDrawItem', Index ); {$ENDIF}
  d := Index div ListBoxData.AcBlockSize;
  m := Index mod ListBoxData.AcBlockSize;
  case ListBoxData.Modus of
  lmAcc: if ( ListBoxData.SelectedAcNr = d ) and ( m < ListBoxData.AcBlockSize-1 ) then
           lstBox.Canvas.Brush.Color := clInfoBk;
//         else if actAcWriteOnly.Checked
//                then lstBox.Canvas.Brush.Color := $C0C0FF;   // hellrot als Indikator WriteOnly
  lmErr: if ListBoxData.SelectedAcNr = Index then
           lstBox.Canvas.Brush.Color := clRed
  end;
  draw := drNix;
  lstBox.Canvas.FillRect( Rect );
  case ListBoxData.Modus of
    lmNull: ;
    lmCnt : case Index of
              1: begin
                   lstBox.Canvas.Font.Style := [fsBold];
                   s := '  Identifiers:'
                 end;
            3+ord(low(tIdType))..3+ord(id_Func): begin
                 draw := drCount;
                 lstBox.Canvas.Font.Color := cIdShow[tIdType(Index-3)].Color;
                 s  := Format( '    %-16.16s%6u', [cIdShow[tIdType(Index-3)].Text+cDots, ZaehlerId[tIdType(Index-3)]]);
                 s2 := Format(     '%-24.24s%6u', [cIdShow[tIdType(Index+9)].Text+cDots, ZaehlerId[tIdType(Index+9)]])
                 end;
            3+ord(id_Func)+3 : begin
                   lstBox.Canvas.Font.Style := [fsBold];
                   s    := '  References:           ';
                   draw := drSum;
                   s2   := 'Overall-Counts:'
                 end;
            cAcIndex..cAcIndex+ord( high( tAcType )): begin
                 lstBox.Canvas.Font.Color := cAcShow[tAcType(Index-cAcIndex)].Color;
                 s := Format ('    %-16.16s%6u', [cAcShow[tAcType(Index-cAcIndex)].Text+cDots, ZaehlerAc[tAcType(Index-cAcIndex)]]);
                 case Index of
                 cAcIndex  : begin
                               draw := drSum;
                               s2 := Format( '%-22.22s%8u', ['Identifiers'+cDots, ZaehlerIds - ZaehlerId[id_Impl] - ZaehlerId[id_Virtual]] )
                             end;
                 cAcIndex+1: begin
                               draw := drSum;
                               s2 := Format( '%-22.22s%8u', ['References'+cDots, ZaehlerAcs] )
                             end;
                 cAcIndex+2: begin
                               draw := drSum;
                               s2 := Format( '%-22.22s%8u', ['Files'+cDots, high( DateiListe )+1] )
                             end;
                 cAcIndex+3: begin
                               draw := drSum;
                               s2 := Format( '%-22.22s%8u', ['Files not found'+cDots, NotFoundFiles.Count] )
                             end;
                 end
                 end;
            cAcIndex+ord( high( tAcType ))+3:
                 if MyTv[tvAll].FirstNode = nil then begin
                   lstBox.Canvas.Font.Style := [fsBold];
                   s := AbbruchMsg
                   end
                 else //Font.Style := Font.Style + [fsbold]
                   s := ''
            end;
    lmErr : s := pAktFile^.StrList[Index];
    lmAcc : begin
              pAc := GetAc( d );
              with pAc^ do
                if m mod ( ListBoxData.AcKontext+1) = 0 then
                  case m div ( ListBoxData.AcKontext+1) of
                  0:    begin   // Header-Zeile "Read in ..."
                          lstBox.Canvas.Brush.Color := tColor($00F4F4F4);
                          lstBox.Canvas.Font.Name   := 'Arial';
                          lstBox.Canvas.Font.Style  := [fsBold];
                          lstBox.Canvas.Font.Color  := cAcShow[ZugriffTyp].Color;
                          lstBox.Canvas.TextOut( Rect.Left, Rect.Top, '#' + d.ToString + ': ' + cAcShow[ZugriffTyp].Text );
                          lstBox.Canvas.Font.Color  := clBlack;
//                          s := cAtBlock + '  "' + TListen.getAcNameLong( pAc, dTrennView ) + '"';
                          s := cAtBlock + '  "' + TListen.getBlockNameLong( IdUse, dTrennView ) + '"';
                          {$IFDEF DEBUG} s := s + '  #' + DebugNr.ToString; {$ENDIF}
                          Rect.Left := frmMain.lstBox.Canvas.PenPos.X
                        end;
                  1   : begin   // zentrale farbige Zeile
                          {if ListBoxData.Indent = 0
                            then} s := DateiListe[Position.Datei]^.StrList[Position.Zeile]
                            {else s := DateiListe[Position.Datei]^.StrList[Position.Zeile].Substring( ListBoxData.Indent )};
                          draw := drAccess;
                        end;
                  2   : if Index = frmMain.lstBox.Count - 1   // Trennzeile mit Linie
                          then draw := drEnd
                          else draw := drLine
                  end
                else begin   // Kontext-Zeilen
                  d := Position.Zeile - ListBoxData.AcKontext - 1 + m;     // Zeile in der StrList
                  if ( d >= 0 ) and ( d <= high( DateiListe[Position.Datei]^.StrList )) then
                    {if ListBoxData.Indent = 0
                      then} s := DateiListe[Position.Datei]^.StrList[d]
                      {else s := DateiListe[Position.Datei]^.StrList[d].Substring( ListBoxData.Indent )}
                  else
                    s := ''
                  end
            end
    end;
  lstBox.Canvas.TextOut( Rect.Left, Rect.Top, s );
  case draw of
    drCount : if Index <= 3+ord(id_Func) then begin
                lstBox.Canvas.Font.Color := cIdShow[tIdType(Index+9)].Color;
                lstBox.Canvas.TextOut( lstBox.Canvas.PenPos.X + PixelsPerInch, Rect.Top, s2 )
              end;
    drSum   : begin
                if Index = 3+ord(id_Func)+3 then
                  lstBox.Canvas.Font.Style := [fsBold, fsUnderline];
                lstBox.Canvas.Font.Color := clBlack;
                lstBox.Canvas.TextOut( lstBox.Canvas.PenPos.X + PixelsPerInch, Rect.Top, s2 )
              end;
    drAccess: DrawAccess( Rect.Top, pAc, s );
    drLine,
    drEnd   : begin
                lstBox.Canvas.MoveTo( 0         , Rect.Top + (Rect.Bottom-Rect.Top) div 2 );
                lstBox.Canvas.LineTo( Rect.Right, Rect.Top + (Rect.Bottom-Rect.Top) div 2 );
                if draw = drEnd then begin
                  lstBox.Canvas.Brush.Color := clBtnFace;
                  Rect.Top    := Rect.Bottom - (Rect.Bottom-Rect.Top) div 2 + 1;
                  Rect.Bottom := lstBox.ClientHeight;
                  lstBox.Canvas.FillRect( Rect );
                  lstBox.Canvas.Brush.Color := clWhite;
                  end
              end;
    end
end;

(* actRefsWriteOnlyExecute *)
procedure TfrmMain.actRefsWriteOnlyExecute( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'actRefsWriteOnlyExecute', actRefsWriteOnly.Checked ); {$ENDIF}
  if actRefsWriteOnly.Checked
    then include( MyTv[AktTv].AktNode^.IdFlagsDyn, tIdFlagsDyn.WriteOnly )
    else exclude( MyTv[AktTv].AktNode^.IdFlagsDyn, tIdFlagsDyn.WriteOnly );
  tMyTreeView.SetActivePid( MyTv[AktTv].AktNode )
end;

(* actRefDeclarationClick *)
procedure TfrmMain.actRefDeclarationExecute( Sender: TObject );
var pAc  : pAcInfo;
    i, iD: integer;
begin
  {$IFDEF TraceDx} TraceDx.Call( 'actRefDeclarationClick' ); {$ENDIF}
  pAc := nil;
  i   := -1;
  iD  := -1;
  repeat pAc := getNextAc( pAc );
         if pAc = nil then
           break
         else begin
           inc( i );
           if pAc^.ZugriffTyp = ac_Declaration then
             iD := i;
           end
  until false;

  if iD <> -1 then begin
    SelectAccess( iD );
    lstBox.TopIndex := iD * ListBoxData.AcBlockSize
    end
end;

{$ENDREGION }

{$REGION '-------------- INI ---------------' }

const
  cMaxRecent = 7;    // RecentFiles 0..cMaxRecent


type
  tIni = ( SecProg, RecentFile,
           SecGui, Font, Size, Top, Left, Width, Height, Split, SplitType, SplitFile,
           SecView, VTop, VLeft, VWidth, VHeight, ViewFiles,
           Recent7, Recent6, Recent5, Recent4, Recent3, Recent2, Recent1, Recent0,
           SecOpt, PathMacro, LibPath, Namespace, FileIni, AutoStart );
const
  cIni : array[tIni] of string =
         ( cProgName, 'Recent',
           'GUI'    , 'Font', 'Size', 'MainTop', 'MainLeft', 'MainWidth', 'MainHeight', 'SplitId', 'SplitType', 'SplitFile',
           'FileViewer', 'ViewerTop', 'ViewerLeft', 'ViewerWidth', 'ViewerHeight', 'ViewFiles',
           'Recent7', 'Recent6', 'Recent5', 'Recent4', 'Recent3', 'Recent2', 'Recent1', 'Recent0',
           'Options', 'PathMacros', 'DelphiPath', 'Namespace', 'ProjectIni', 'AutoParse' );

(* ProgIniValueChanged *)
procedure ProgIniValueChanged;
{ TODO: Aufrufen, wenn ein ProgIni-relevanter Wert geändert wurde OHNE ProgIni.WriteInteger(...)
        Alternativ: Direkt ProgIni.WriteInteger( Wert ) }
  begin
  {$IFDEF TraceDx} TraceDx.Call( 'ProgIniValueChanged' ); {$ENDIF}
  ProgIni.Modified := true;
end;

(* mItmOptionsPositionClick *)
procedure TfrmMain.mItmOptionsPositionClick( Sender: TObject );
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'mItmOptionsPositionClick' ); {$ENDIF} {$ENDIF}
  UtilitiesDx.TIni.WriteForm( Self );
  UtilitiesDx.TIni.WriteForm( frmViewer );

  with ProgIni do begin
    WriteInteger( cIni[tIni.SecGui],  cIni[tIni.Split    ], PanelLeft.Width  );
    WriteInteger( cIni[tIni.SecGui],  cIni[tIni.SplitFile], pnlFiles. Width  );
    if mItmViewFiles.Checked then
    WriteBool   ( cIni[tIni.SecView], cIni[tIni.ViewFiles], mItmViewFiles.Checked )
    end;
  // ProgIniValueChanged-Modified  ist damit automatisch gesetzt
end;

(* GetSourceIniErrName *)
function GetSourceIniErrName: string;
const cErsatz = '_';
begin
  IniErrName := frmMain.dlgOpen.FileName;
//  IniErrName[0] := UpCase( IniErrName[0] );
  if ( IniErrName <> EmptyStr ) and not frmMain.mItmOptionsSourcePathIni.Checked then begin
    IniErrName[1] := cErsatz;
    IniErrName := TMyApp.DirUser + IniErrName.Replace( TPath.DirectorySeparatorChar, cErsatz )
    end;
  Result := IniErrName
end;

(* mItmOptionsGlobalClick *)
procedure TfrmMain.mItmOptionsAutoParseClick( Sender: TObject) ;
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'mItmOptionsAutoParseClick' ); {$ENDIF} {$ENDIF}
  if not mItmOptionsAutoParse.Checked then
    mItmFileReParse.Enabled := true;
  ProgIni.WriteBool( cIni[tIni.SecOpt], cIni[tIni.AutoStart], mItmOptionsAutoParse.Checked )
end;

(* mItmOptionsPathMacrosClick *)
procedure TfrmMain.mItmOptionsPathMacrosClick(Sender: TObject);
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'mItmOptionsPathMacrosClick' ); {$ENDIF} {$ENDIF}
  OptionPathMacros := InputBox( 'Delphi-Path-Macros', 'Use ";" as separator', OptionPathMacros );
  mItmOptionsPathMacros.Checked := OptionPathMacros <> EmptyStr;
  ProgIni.WriteString( cIni[tIni.SecOpt], cIni[tIni.PathMacro], OptionPathMacros )
end;

(* mItmOptionsDelphiPathClick *)
procedure TfrmMain.mItmOptionsDelphiPathClick( Sender: TObject );
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'mItmOptionsDelphiPathClick' ); {$ENDIF} {$ENDIF}
  OptionLibPaths := InputBox( 'Delphi-Source-Paths', 'Use ";" as separator', OptionLibPaths );
  mItmOptionsDelphiPath.Checked := OptionLibPaths <> EmptyStr;
  ProgIni.WriteString( cIni[tIni.SecOpt], cIni[tIni.LibPath], OptionLibPaths )
end;

(* mItmOptionsNamespaceClick *)
procedure TfrmMain.mItmOptionsNamespaceClick(Sender: TObject);
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'mItmOptionsNamespaceClick' ); {$ENDIF} {$ENDIF}
  OptionNamespace := InputBox( 'Namespace (Gültigkeitsbereiche)', 'Use ";" as separator', OptionNamespace );
  mItmOptionsNamespace.Checked := OptionNamespace <> EmptyStr;
  ProgIni.WriteString( cIni[tIni.SecOpt], cIni[tIni.Namespace], OptionNamespace )
end;

(* mItmOptionsSourcePathIniClick *)
procedure TfrmMain.mItmOptionsSourcePathIniClick( Sender: TObject );
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'mItmOptionsSourcePathIniClick' ); {$ENDIF} {$ENDIF}
  TDataIO.Rename( GetSourceIniErrName );
  ProgIni.WriteBool( cIni[tIni.SecOpt], cIni[tIni.FileIni], mItmOptionsSourcePathIni.Checked );
  if mItmOptionsProjectOptions.Enabled then
    mItmOptionsProjectOptionsClick( nil )
end;

(* mItmOptionsProjectOptionsClick *)
procedure TfrmMain.mItmOptionsProjectOptionsClick( Sender: TObject );
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'mItmOptionsProjectOptionsClick' ); {$ENDIF} {$ENDIF}
  if CtrlDown then HideHotKeys;
  if TDataIO.ShowIniDialog then
    if ListBoxData.Modus <> lmNull then
      if mItmOptionsAutoParse.Checked
        then mItmFileReParseClick( nil )
        else UserInfo.Show( cNoAutoParse, tUserInfo.InfoType.inHintUI )
end;

(* SetFontSize *)
procedure SetFontHeight( d: integer );
begin
  with frmMain do begin
    tMyTreeView.SetClassData;

    pnlAcs.  Font.Height      := pnlAcs.  Font.Height - d;    // wegen Font "Courier" ist ParentFont = false
    pnlFiles.Font.Height      := pnlFiles.Font.Height - d;
    lstBox.Canvas.Font        := lstBox.Font;
    lbCharWidth               := lstBox.Canvas.TextWidth( 'm' );

    lstBox.      ItemHeight   := round( -lstBox.      Font.Height * 1.2 );
    lstBoxHotKey.ItemHeight   := round( -lstBoxHotKey.Font.Height * 1.2 );

    lblStatus.Font.Height     := lblStatus.Font.Height  - d;         // StatusBar
    lblStatus.ClientHeight    := lblStatus.ClientHeight + d;

    lblFilter.Font.Height     := lblFilter.Font.Height     - d;                // wegen Style = [fsBold] ist ParentFont = false
    pnlLblFilter.ClientHeight := pnlLblFilter.ClientHeight + d;
    end
end;

(* SetRecent *)
procedure SetRecent( i: word; const s: string );
begin
//  {$IFDEF TraceDx} TraceDx.Call( 'SetRecent' + i.ToString, s ); {$ENDIF}
  ProgIni.WriteString ( cIni[tIni.SecProg], cIni[tIni.RecentFile]+char(i+ord('0')), s );
  with frmMain.MainMenuFile.Items[frmMain.mItmOpenRecent1.MenuIndex+i] do begin
    Caption := TPath.GetFileNameWithoutExtension( s );
    Hint    := s;
    Visible := s <> EmptyStr
    end
end;

(* ReadWriteProgIni *)
function ReadWriteProgIni( const rw: TFileAccess ): string;
var i,j: word;
    s  : string;
begin
  {$IFDEF TraceDx} TraceDx.CallE<TFileAccess>( 'ReadWriteProgIni', rw ); {$ENDIF}
  with frmMain, ProgIni do begin
    if rw = TFileAccess.faRead then begin
      try
        { Prog-bezogen: }
        //           ReadString  ( cIni[tIni.SecProg], cIni[tIni.Tmp ], TmpPath  );
        i := 1;
        for j := 0 to cMaxRecent do begin
          s := ReadString( cIni[tIni.SecProg], cIni[tIni.RecentFile]+char(j+ord('0')), EmptyStr );
          { Ins Recent-Menü eintragen falls Datei noch existiert: }
          with MainMenuFile.Items[mItmOpenRecent1.MenuIndex+i] do if TFile.Exists( s ) then begin
            SetRecent( j, s );
            if i = 1 then result := s;   // den ersten (frischesten) Recent-Eintrag als LastFile zurückliefern
            inc( i )
            end
          else
            SetRecent( j, EmptyStr )
          end;
        { Form-bezogen: }
        { TODO: Font-Dialog}

        UtilitiesDx.TIni.ReadForm( frmMain   );
        pnlAcs.Font.Height := Font.Height;
        SetFontHeight( 0 );
//          OnAfterMonitorDpiChanged := FormAfterMonitorDpiChanged;

        PanelLeft.Width          := ReadInteger ( cIni[tIni.SecGui ], cIni[tIni.Split ], PanelLeft.Width );
        if ( Top + 200 > Screen.DesktopHeight ) or ( Left + 200 > Screen.DeskTopWidth )
          then Position := poDefaultPosOnly;
        pnlFiles.Width           := ReadInteger ( cIni[tIni.SecGui ], cIni[tIni.SplitFile], pnlFiles.Width );

        mItmViewFiles.Checked    := ReadBool    ( cIni[tIni.SecView], cIni[tIni.ViewFiles], mItmViewFiles.Checked );
        if mItmViewFiles.Checked then ShowPnlFiles( true );

        OptionPathMacros                 := ReadString( cIni[tIni.SecOpt], cIni[tIni.PathMacro  ], '$BDS=c:\Program Files (x86)\Embarcadero\Studio\22.0\Source' );
        mItmOptionsPathMacros.Checked    := OptionPathMacros <> EmptyStr;

        OptionLibPaths                   := ReadString( cIni[tIni.SecOpt], cIni[tIni.LibPath  ], '$BDS\vcl\;$BDS\rtl\sys\;$BDS\rtl\common\;$BDS\rtl\win\' );
        mItmOptionsDelphiPath.Checked    := OptionLibPaths <> EmptyStr;

        OptionNamespace                  := ReadString( cIni[tIni.SecOpt], cIni[tIni.Namespace], 'Vcl;System;System.Win;WinApi' );
        mItmOptionsNamespace.Checked     := OptionNamespace <> EmptyStr;

        mItmOptionsSourcePathIni.Checked := ReadBool  ( cIni[tIni.SecOpt], cIni[tIni.FileIni  ], mItmOptionsSourcePathIni.Checked );
        mItmOptionsAutoParse    .Checked := ReadBool  ( cIni[tIni.SecOpt], cIni[tIni.AutoStart], mItmOptionsAutoParse    .Checked  );
        if not mItmOptionsAutoParse.Checked then
          mItmFileReParse.Enabled := true;
      except
        Error( tError.errProgIni, ProgIni.FileName )
      end;
      if not TFile.Exists( ProgIni.FileName ) then begin
//        Position := poDefault;                  // führt zu "Eigenschaft Visible kann im OnShow nicht verändert werden
//        ReadWriteProgIni( TFileAccess.faWrite );
        mItmOptionsPositionClick( nil );
        actHelpInfoExecute( actHelpInfo )
        end
      end
    end
end;

{$ENDREGION }

{$REGION '-------------- Parser ---------------' }

(* DataChanged *)
{ im Init oder FileLoad wird ein überflüssigerweise DataChanged aufgerufen,
  durch Parameter false wieder rückgängig machen
  Könnte auch durch setzen der ereignisbehandlung auf nil und zurück gemacht werden }
procedure DataChanged( changed: boolean );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'DoChanged', changed ); {$ENDIF}
  frmMain.actFileSave.Enabled := changed
end;

(* DoCriticalWork *)
procedure DoCriticalWork( b: boolean );
{ true : CriticalWork endet
  false: CriticalWork beginnt    }
const cCursor: array[boolean] of TCursor = ( crHourGlass, crDefault );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'DoCriticalWork', b ); {$ENDIF}
  CriticalWork := b;
  b := not b;
  with frmMain do begin
    mItmFileReParse .Enabled := b;
  //  frmMain.PaintBox.Cursor := cCursor[b];
  //  frmMain.lstBox.Cursor   := cCursor[b];
    actFileNew      .Enabled := b;
    actFileOpen     .Enabled := b;
    mItmFileOpenClip.Enabled := b;
    mItmOpenRecent1 .Enabled := b;
    mItmOpenRecent2 .Enabled := b;
    mItmOpenRecent3 .Enabled := b;
    mItmOpenRecent4 .Enabled := b;
    actFileClose    .Enabled := b;
    actFileSaveAs   .Enabled := b;
    actProgExit     .Enabled := b;
  end
end;

(* RepaintLstBox *)
procedure RepaintLstBox;
begin
  frmMain.lstBox.Repaint
end;

(* InitParse *)
procedure InitParse;
begin
  TreeViewClearItems;
  frmMain.lstBox.Clear;
  frmMain.Repaint;
  TViewer.PreParse;
  tMyTreeView.PreParse;
  HotKeyPreParse;
  frmFilter.PreParse;
  NotFoundFiles.Clear;
  frmMain.lstBoxHistory.Count := 0;
  CtrlArray[ctFiles] := frmMain.tvFiles;
  frmMain.DoRefsViaChange( false );
end;

(* DoParse *)
function DoParse: boolean;
const cTrenn = '   ';
var i: integer;
    LocalVerify: boolean;   // true, wenn ich NICHT aus VerifyDx-Fall (aus RefVerify) komme
begin
  {$IFDEF TraceDx} TraceDx.Send( 'DoParse' ); {$ENDIF}
  if ParserState.ReParse then
    InitParse;
//  ListBoxData.Indent := 0;
  DoCriticalWork( true );
  SetActiveModeCount( lmCnt );
  {$IFDEF VerifyDx}
    frmMain.Caption := frmMain.dlgOpen.Filename;   // wurde evtl vom negativen tree-Vergleichsergebnis überschrieben
  {$ENDIF}

  if RefactorEndIf then begin
    if TFile.Exists( cExtraLogYes ) then TFile.Delete( cExtraLogYes );
    if TFile.Exists( cExtraLogNo  ) then TFile.Delete( cExtraLogNo  );
    LastExtraNo  := '';
    LastExtraYes := ''
    end;

  ExitCode := 0;
//  {$IFDEF TraceDx} TraceDx.ToServer := false; {$ENDIF}
  Result := TParser.Parse( frmMain.dlgOpen.Filename, RepaintLstBox );
//  {$IFDEF TraceDx} TraceDx.ToServer := true;  {$ENDIF}

  if Result then begin
    {$IFDEF SaveTree}
      if not Abbruch { Parser wurde nicht per Escape abgebrochen } then begin
        {$IFDEF VerifyDx}
        if not VerifyDx.Running   and
           VerifyDx.CompareStart( TPath.GetFileName( frmMain.dlgOpen.Filename ), {$IFDEF CmpTrace} true {$ELSE} false {$ENDIF} ) then begin
          {$IFDEF CmpTree}
            VerifyDx.SetDataFile( frmMain.dlgOpen.Filename + cExtensionTree, true, true );
          {$ENDIF}
          LocalVerify := true
          end
        else
          LocalVerify := false;
        {$ENDIF}
        UserInfo.ShowExtern( 'Parser finished.  Save Tree ...'{, tUserInfo.InfoType.inHintUI} );
        try    TListen.SaveToFile( frmMain.dlgOpen.Filename + cExtensionTree );
        except Result := false;
               {$IFDEF VerifyDx}
               if LocalVerify then
                 VerifyDx.CompareBreak;
               {$ENDIF}
               Error( errSaveTree, '' )
        end;   // in Thread auslagern: geht, aber läuft viiiel länger
        {$IFDEF VerifyDx}
        if LocalVerify then
          frmMain.Caption := 'VerifyDx.Compare: ' + VerifyDx.cCmpResult[VerifyDx.CompareEnd];
        {$ENDIF}
        end;
    {$ENDIF}

    if Result then begin
      UserInfo.ShowExtern( 'Parser finished.  Prepare TreeViews ...'{, tUserInfo.InfoType.inHintUI} );
      try    { tvAll  : }  tMyTreeView.PrepareTreeViewAll;   // hier ist System-Unit noch vorne
      except Result := false; {$IFDEF TraceDx} {$IFDEF VerifyDx} ExitCode := ord( VerifyDx.tCmpResult.vrError );{$ENDIF} {$ENDIF} Error( errPrepareTree, '' );
      end;
      {$IFDEF SaveTree}
      { Hier NOCH EINMAL den Tree ausgeben um per Vergleich die Auswirkungen des PrepareTree zu sehen: }
//      try TListen.SaveToFile( frmMain.dlgOpen.Filename + '.tree2' ) except end
      {$ENDIF}
      end;
    if Result then begin
      if frmMain.mItmViewFiles.Checked then BuildFileTree;  { tvFiles }
      { System-Unit von erster an letzte Position verschieben: }
      if MainBlock[mbBlock0].SubBlock^.NextId = nil then
        // es sind nur System.xxx-Units vorhanden
      else begin
        MainBlock[mbBlock0].SubBlock := MainBlock[mbBlock0].SubBlock^.NextId;
        MainBlock[mbBlock0].SubLast^.NextId := @UnitSystem;
        UnitSystem.NextId := nil
        end;
      UserInfo.Show( cSelectId, tUserInfo.InfoType.inIdAcFile );
      SetAllHotKeys;
      SetHistory;

      if RefactorEndIf  and  TFile.Exists( cExtraLogYes ) then begin
        DataChanged( true );
        var s := '';
        for i := 0 to high( DateiListe ) do with DateiListe[i]^ do
          if Changed in fiFlags then s := s + sLineBreak + FileName ;
          ShowMessage( 'Changed Files (see File "' + cExtraLogYes + '"):' + s )
        end;

      end
    end
  else begin
    UserInfo.Show( 'Error  in  ' + frmMain.lblStatus.Caption, tUserInfo.InfoType.inError );
    SetActiveModeCount( lmErr )
    end;
  DoCriticalWork( false );

{$REGION '-------------- Thread ---------------' }
  (*TThread.CreateAnonymousThread(
    procedure
    var e: boolean;
        w: TStopWatch;                            lohnt sich nicht
    begin                                         und ist auch nicht fehlerfrei
      e := false;
      w := TStopWatch.StartNew;
      try TLogic.Parse
      except
        e := true
      end;
      w.stop;
      {$IFDEF TraceDx} TraceDx.Send( 'ParseTime', w.Elapsed.Milliseconds ); {$ENDIF}
      if not e then begin
        TThread.Synchronize( nil,
          procedure
          begin
            SetStatusBar( 0, 'Time: ' + w.Elapsed.Milliseconds.ToString + 'ms' );
            BuildTree( frmMain.tv.Items );
          end );
        TLogic.SaveToFile;
        end;
      TThread.Synchronize( nil,
        procedure
        begin
          DoCriticalWork( false )
        end )
    end ).Start;*)
{$ENDREGION }
end;

{$ENDREGION }

{$REGION '-------------- View ---------------' }

(* actViewKontextMinusExecute *)
procedure TfrmMain.actViewKontextMinusExecute( Sender: TObject );
var a: integer;
    d,m: integer;
begin
  {$IFDEF TraceDx} TraceDx.Call( 'actViewKontextMinusExecute' ); {$ENDIF}
  if actViewKontextMinus.Enabled and ( ListBoxData.AcKontext > 0 ) then begin
    a := lstBox.Count    div ListBoxData.AcBlockSize;
    d := lstBox.TopIndex div ListBoxData.AcBlockSize;
    m := lstBox.TopIndex mod ListBoxData.AcBlockSize;
    dec( ListBoxData.AcKontext );
    dec( ListBoxData.AcBlockSize, 2 );
    SetAccessLinesCount( a );
    if m >= 2 then
      if m < ListBoxData.AcBlockSize
        then dec( m )
        else dec( m, 2 );
    lstBox.TopIndex := d * ListBoxData.AcBlockSize + m
    end
end;

(* actViewKontextPlusExecute *)
procedure TfrmMain.actViewKontextPlusExecute( Sender: TObject );
var a: integer;
    d,m: integer;
begin
  {$IFDEF TraceDx} TraceDx.Call( 'actViewKontextPlusExecute' ); {$ENDIF}
  if actViewKontextPlus.Enabled and ( ListBoxData.AcKontext < 99 ) then begin
    a := lstBox.Count    div ListBoxData.AcBlockSize;
    d := lstBox.TopIndex div ListBoxData.AcBlockSize;
    m := lstBox.TopIndex mod ListBoxData.AcBlockSize;
    inc( ListBoxData.AcKontext );
    inc( ListBoxData.AcBlockSize, 2 );
    SetAccessLinesCount( a );
    if m >= 1 then
      if m < ListBoxData.AcBlockSize-3
        then inc( m )
        else inc( m, 2 );
    lstBox.TopIndex := d * ListBoxData.AcBlockSize + m
    end
end;

(* actViewFullScreenExecute *)
procedure TfrmMain.actViewFullScreenExecute( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'actAnsichtFullScreenExecute' ); {$ENDIF}
  Screen.ActiveForm.WindowState := TWindowState( 2 - ord( Screen.ActiveForm.WindowState ))
end;

(* mItmViewStatusBarClick *)
procedure TfrmMain.mItmViewStatusBarClick( Sender: TObject );
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'mItmAnsichtStatusBarClick' ); {$ENDIF} {$ENDIF}
  lblStatus.Visible := mItmViewStatusBar.Checked;
end;

(* mItmViewCounterClick *)
procedure TfrmMain.mItmViewCounterClick( Sender: TObject );
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'mItmViewCounterClick' ); {$ENDIF} {$ENDIF}
  if ListBoxData.Modus = lmCnt then
    MyTv[AktTv].SetAktAbsPid( MyTv[AktTv].AktNode, false )
  else begin
    if CtrlDown then HideHotKeys;
    SetActiveModeCount( lmCnt );
    UserInfo.Show( cSelectId, tUserInfo.InfoType.inIdAcFile )
    end
end;

(* mItmViewFilesClick *)
procedure TfrmMain.mItmViewFilesClick( Sender: TObject );
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'mItmViewFilesClick' ); {$ENDIF} {$ENDIF}
  if not pnlFiles.Visible and ( tvFiles.Items.Count = 0 ) then
    BuildFileTree;
  ShowPnlFiles( mItmViewFiles.Checked )
end;

(* mItmViewZoomMinusClick *)
procedure TfrmMain.mItmViewZoomMinusClick( Sender: TObject );
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'mItmAnsichtZoomMinusClick' ); {$ENDIF} {$ENDIF}
  if Font.Size > 6 then begin
    Font.Size := Font.Size - 1;
    SetFontHeight( -1 )
    end
end;

(* mItmViewZoomPlusClick *)
procedure TfrmMain.mItmViewZoomPlusClick( Sender: TObject );
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'mItmAnsichtZoomPlusClick' ); {$ENDIF} {$ENDIF}
  Font.Size := Font.Size + 1;
  SetFontHeight( +1 )
end;

{$ENDREGION }

{$REGION '-------------- Extra ---------------' }

procedure TfrmMain.mItmRefactorEndIfClick( Sender: TObject );
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'mItmExtraEndIfClick' ); {$ENDIF} {$ENDIF}
  RefactorEndIf := mItmRefactorEndIf.Checked;
  if not RefactorEndIf then
    actFileSave.Enabled := false
end;

procedure TfrmMain.mItmExtraExportDebugClick( Sender: TObject );
var s: string;
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'mItmExtraExportDebugClick' ); {$ENDIF} {$ENDIF}
  Screen.Cursor := crHourGlass;
  {$IFDEF SaveTree}
    s := dlgOpen.Filename;           // immer SourcePath
  {$ELSE}
    s := IniErrName;           // UserPath oder SourcePath
  {$ENDIF}
  s := s + '.ref.txt';
  try    TListen.SaveToFile( s );
         ShowMessage( 'Datei "' + s + '" gespeichert' );
  except Error( errSaveTree )
  end;
  Screen.Cursor := crDefault
end;

{$ENDREGION }

{$REGION '-------------- Close Save ---------------' }

(* DoFileSave *)
procedure DoFileSave;
var i: tFileIndex;
begin
  {$IFDEF TraceDx} TraceDx.Call( 'DoFileSave' ); {$ENDIF}
  if RefactorEndIf then
    for i := 0 to high( DateiListe ) do with DateiListe[i]^ do
      if Changed in fiFlags then begin
        TFile.WriteAllLines( FileName, StrList );
        exclude( fiFlags, Changed )
        end;
  DataChanged( false )
end;

(* actFileSaveExecute *)
procedure TfrmMain.actFileSaveExecute( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'actFileSaveExecute', actFileSave.Enabled ); {$ENDIF}
  if actFileSave.Enabled then
    if ( Sender = actFileSave ) { Aus new,close: Abfrage  /  aus Action,HotKey,SaveAs: unbedingtes Speichern ohne Abfrage} or
       ( MessageDlg( 'Geänderte Daten'
//                     + ifthen( dlgOpen.Filename = EmptyStr, '', ' in "' + TPath.GetFileName( dlgOpen.Filename ) + '"')
                     + ' speichern ?',    mtConfirmation, mbYesNo, 0) = mrYes ) then
          if dlgOpen.FileName = EmptyStr
            then actFileSaveAsExecute( Sender )
            else DoFileSave
end;

(* DoSourceName *)
procedure DoSourceName( const s: string );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'DoSourceName', s ); {$ENDIF}
  frmMain.dlgOpen.Filename := s;
  frmMain.Caption := cProgName + ' ' + cVersion + cDebug;
  frmMain.mItmOptionsProjectOptions.Enabled := s <> cNoSource;
  if s <> cNoSource then
    frmMain.Caption := frmMain.Caption + ' - ' + s;
  frmMain.mItmRefactorEndIf   .Checked := false;
  frmMain.actFileSave         .Enabled := false;
  frmMain.PopupItmIdSort      .Enabled := false;
  frmMain.PopupItmIdRename    .Enabled := false;
  frmMain.actIdFilterHierarchy.Enabled := false;
end;

(* DoSourceEmpty *)
procedure DoSourceEmpty;
begin
  {$IFDEF TraceDx} TraceDx.Call( 'DoSourceEmpty' ); {$ENDIF}
  TreeViewClearItems;
  frmViewer.Hide;
  DoSourceName( cNoSource );
  SetActiveModeCount( lmNull );
  DataChanged( false );
  frmMain.DoRefsViaChange( false );
end;

(* actFileSaveAsExecute *)
procedure TfrmMain.actFileSaveAsExecute( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'actFileSaveAsExecute' ); {$ENDIF}
  if dlgOpen.FileName = EmptyStr
    then dlgSave.InitialDir := TMyApp.DirExe
    else dlgSave.InitialDir := TPath.GetDirectoryName( dlgOpen.FileName );
  dlgSave.Filename := TPath.GetFileNameWithoutExtension( dlgOpen.Filename );
  if dlgSave.Execute and ( dlgSave.FileName <> EmptyStr ) then
    if not TFile.Exists( dlgSave.FileName ) or ( MessageDlg( 'Datei "' + dlgSave.FileName + '" exisitert bereits.' + sLineBreak + 'Überschreiben?', mtConfirmation, mbOKCancel, 0) = mrOK ) then begin
      DoSourceName( TPath.ChangeExtension( dlgSave.FileName, cExtensionDpr ) );
      TDataIO.Rename( GetSourceIniErrName );
      DoFileSave
      end
end;

(* actFileNewCloseExecute *)
procedure TfrmMain.actFileNewCloseExecute( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'actFileNewCloseExecute' ); {$ENDIF}
  if not UseClipBoard then begin
    actFileSaveExecute( Sender );
    {$IFNDEF RefBatch}
    if MyTv[tvAll].FirstNode <> nil
      then TDataIO.Close( TListen.getBlockNameLongMain( MyTv[AktTv].AktNode, cTrennUse ), ListBoxData.AcKontext, SetHotKeyStrings )
    {$ENDIF}
    end;
  DoSourceEmpty;
  tMyTreeView.PreParse
end;

(* FormClose *)
procedure TfrmMain.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'FormClose' ); {$ENDIF}
  if actFileOpen.Enabled then begin
    {$IFNDEF RefBatch}
    if ProgIni.Modified then begin
      ReadWriteProgIni( TFileAccess.faWrite );
      ProgIni.UpdateFile
      end;
    {$ENDIF}
    lstBox.OnDrawItem := nil;
    frmViewer.lstBoxViewer.OnDrawItem := nil;
    actFileNewCloseExecute( Sender );
    Action := caFree
    end
  else
    Action := caNone    // kritische Aktion läuft noch, jetzt nicht schliessen
end;

(* WMENDSESSION *)
procedure TfrmMain.WMENDSESSION( var Msg: TWMEndSession );
var Action: TCloseAction;
begin
  {$IFDEF TraceDx} TraceDx.Call( 'WMENDSESSION', Msg.EndSession ); {$ENDIF}
  if Msg.EndSession then begin
    Action := caFree;
    FormClose( frmMain, Action )
    end;
  inherited
end;

(* actProgExitExecute *)
procedure TfrmMain.actProgExitExecute( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'actProgExitExecute' ); {$ENDIF}
  Close
end;

(* actProgExitNoSaveExecute *)
procedure TfrmMain.actProgExitNoSaveExecute( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'actProgExitNoSaveExecute' ); {$ENDIF}
  if not actFileSave.Enabled or ( MessageDlg ( 'Daten wurden geändert!' + sLineBreak + 'Trotzdem OHNE speichern beenden?', mtConfirmation, mbOKCancel, 0) = mrOK )
    then Application.Terminate
end;

{$ENDREGION }

{$REGION '-------------- UnitOneInst ---------------' }

{$IFDEF UnitOneInst}
(* FromUnitOneInst *)
procedure FromUnitOneInst ( const s: string );
  procedure ShowMe;
  var Th1, Th2: Cardinal;
      h: HWND;
  begin
    Th1 := GetCurrentThreadId;
    h   := GetForegroundWindow;
    Th2 := GetWindowThreadProcessId( h, nil );
    AttachThreadInput( Th2, Th1, true );
    try    SetForegroundWindow( Application.Handle )
    except AttachThreadInput( Th2, Th1, false )    {Original: finally}
    end;
  end; {ShowMe, Michael Winter. Aus delphi-fundgrube.de}
begin
  {$IFDEF TraceDx} TraceDx.Send( 'FromUnitOneInst', s ); {$ENDIF}
  if frmMain.actFileOpen.Enabled then begin
    ShowMe;
    DoFileCloseLoad( s )
    end
  else
    Error( tError.errActFileOpen )
end;
{$ENDIF}

{$ENDREGION }

{$REGION '-------------- Batch ---------------' }
{$IFDEF RefBatch}
(* DoStartBatch *)
procedure DoStartBatch( s: string );
const cErsatz = '_';
begin
  {$IFDEF TraceDx}
    TraceDx.CallRet( 'DoStartBatch', s, rtInteger, ExitCode, 'ExitCode', tcGreen );
    TraceDx.ToServer := false;
  {$ENDIF}
//  aus Application.Activate:
    TListen.Init( procedure ( const s: string ) begin end );
    TParser.Init;
//  aus DoFileCloseLoad:
    UseClipBoard := false;
    s := TPath.GetFullPath( s );
    if not TFile.Exists( s ) then begin
      ExitCode := ord( VerifyDx.tCmpResult.vrError );
      exit
      end;
    ProjDir := TPath.GetDirectoryName( s );
    TDirectory.SetCurrentDirectory( ProjDir );
//  aus GetSourceIniErrName;
    IniErrName := s;      //  Projekt-Ini wird für RefBatch immer aus Source-Pfad geholt.
//      if ( IniErrName <> EmptyStr ) and not SourcePathIni then begin
//        IniErrName[1] := cErsatz;
//        IniErrName    := TMyApp.DirUser + IniErrName.Replace( TPath.DirectorySeparatorChar, cErsatz )
//        end;

    TDataIO.LoadBatch( s );
//  aus DoParse:
    if TParser.Parse( s, procedure begin end ) then begin
      {$IFDEF SaveTree}
        {$IFDEF VerifyDx}
          VerifyDx.CompareStart( TPath.GetFileName( s ), {$IFDEF CmpTrace} true {$ELSE} false {$ENDIF} );    // kein Trace-Protokoll anlegen und vergleichen
          VerifyDx.Mode := vmSilent;                                 // keine Vergleichs-Ergebnisse als Dialog anzeigen
          {$IFDEF CmpTree}
            VerifyDx.SetDataFile( s + cExtensionTree, true, true );    // DataFile ".tree" ist die relevante Verify-Datei.
          {$ENDIF}
        {$ENDIF}
        try    TListen.SaveToFile( s + cExtensionTree );
        except ExitCode := ord( VerifyDx.tCmpResult.vrError );
               {$IFDEF VerifyDx}
               VerifyDx.CompareBreak
               {$ENDIF}
        end;
        {$IFDEF VerifyDx}
        ExitCode := ord( VerifyDx.CompareEnd )
        {$ENDIF}
      {$ENDIF}
      end
    else
      ExitCode := ord( VerifyDx.tCmpResult.vrError );

  {$IFDEF TraceDx}
    TraceDx.ToServer := true    // EcitCode im Server anzeigen
  {$ENDIF}
end;
{$ENDIF}
{$ENDREGION}

{$REGION '-------------- Create Open ---------------' }

(* mItmFileReParseClick *)
procedure TfrmMain.mItmFileReParseClick( Sender: TObject );
var LastVia, LastId : tIdString;
    pId             : pIdInfo;
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Send( 'mItmFileReParseClick' ); {$ENDIF} {$ENDIF}
  if MyTv[AktTv].AktNode = nil then begin
    LastVia := EmptyStr;
    LastId  := EmptyStr     // falls AutoParse = false
    end
  else begin
    if pAcVia = nil
      then LastVia := EmptyStr
      else LastVia := TListen.getBlockNameLongMain( pAcVia^.IdDeclare,   cTrennUse );
    if MyTv[AktTv].AktNode = nil
      then LastId  := ''
      else LastId  := TListen.getBlockNameLongMain( MyTv[AktTv].AktNode, cTrennUse );
    DoRefsViaChange( false )
    end;

  SetHotKeyStrings;

  if AktTv <> tvAll then
    actIdViewFilterExecute( nil );

  if DoParse then begin

    if LastId = EmptyStr
      then pId := nil
      else pId := SearchQualifiedId( LastId );
    if pId = nil
      then pId := OpenTreeDefault
      else MyTv[tvAll].OnVisiblesChange;
    MyTv[tvAll].SetAktAbsPid( pId, false );

    if LastVia <> EmptyStr then begin
      pId := SearchQualifiedId( LastVia );
      if pId <> nil then begin
        pAcVia := pId^.LastAc;                  // das ist nicht unbedingt der gewünschte aus vorigem Parse :-(  aber besser geht's nicht
//        frmMain.DoRefsViaChange( true )       // actRefViaOnly deshalb nach neuem ViaSelect händisch wieder einschalten
        end
      end
    end
  else
    frmHistory.lstHistory.Items.Clear
end;

(* DoFileCloseLoad *)
procedure DoFileCloseLoad( s: string );
var {$IFNDEF RefBatch} n : pIdInfo; {$ENDIF}
    ok: boolean;

  { Eintrag im Menu "Datei" aktualisieren }
  procedure InMenuEintragen;
  var i,j: byte;
  begin
    { Datei schon in Recent-Liste vorhanden ? }
    j := cMaxRecent;
    for i := 1 to cMaxRecent do
      if lowercase( s ) = lowercase( frmMain.MainMenuFile.Items[frmMain.mItmOpenRecent1.MenuIndex+i].Hint ) then begin
        j := i;    // wenn ja, im folgenden FOR nur ab hier verschieben
        break
        end;

    { Datei 3 wird zu 4, 2 zu 3, 1 zu 2. Nur oberhalb evtl schon vorhandenen s }
    for i := j downto 1 do
      SetRecent( i, frmMain.MainMenuFile.Items[frmMain.mItmOpenRecent1.MenuIndex+i-1].Hint );

    { Neue Datei wird erster Recent-Eintrag: }
    SetRecent( 0, s )
  end;

begin
  {$IFDEF TraceDx} TraceDx.Call( 'DoFileCloseLoad', s ); {$ENDIF}
  if TPath.GetExtension( s ).ToLower = cExtensionDproj then begin
    s := TPath.ChangeExtension( s, cExtensionDpr );
    if not TFile.Exists( s ) then
      s := TPath.ChangeExtension( s, cExtensionDpk )
    end;
  frmMain.btnRunAgain.Visible := false;
  if AktTv = _tvFil then
    frmMain.actIdViewFilterExecute( nil );
  if not ( UseClipBoard  or ( frmMain.dlgOpen.FileName = cNoSource )) then begin
    frmMain.actFileSaveExecute( frmMain.actFileSave);
    if MyTv[tvAll].FirstNode <> nil
      then TDataIO.Close( TListen.getBlockNameLongMain( MyTv[AktTv].AktNode, cTrennUse ), ListBoxData.AcKontext, SetHotKeyStrings )
    end;

  UseClipBoard := s = cClipboardFile;
  s := TPath.GetFullPath( s );
  if not TFile.Exists( s ) and ( TPath.GetExtension( s ) = EmptyStr ) then
    s := TPath.ChangeExtension( s, cExtensionDpr );
  DoSourceName( s );
  GetSourceIniErrName;
  TreeViewClearItems;
  frmViewer.Hide;
  frmHistory.lstHistory.Items.Clear;
  DataChanged( false );
  SearchData.CmpMode := cfNul;

  if UseClipBoard then begin
    TDataIO.Load( s, procedure( i: string ) begin end);
    ListBoxData.AcKontext   := FileOptions.AcKontext;
    ListBoxData.AcBlockSize := ListBoxData.AcKontext shl 1 + 1{Header} + 1{AccessZeile} + 1{Trennlinie};
    if frmMain.mItmOptionsAutoParse.Checked then begin
      if DoParse then
        MyTv[tvAll].SetAktAbsPid( OpenTreeDefault, false )
      end
    else
      UserInfo.Show( cNoAutoParse, tUserInfo.InfoType.inHintUI )
    end
  else if TFile.Exists( s ) then begin
    if s.ToLower <> frmMain.mItmOpenRecent1.Hint.ToLower then
      { in RecentFiles merken }
      InMenuEintragen;

    ProjDir := TPath.GetDirectoryName( s );
    frmMain.dlgOpen.InitialDir := ProjDir;
    TDirectory.SetCurrentDirectory( ProjDir );

    if not TDataIO.Load( IniErrName, procedure( i: string )
      begin
        {$IFDEF TraceDx} TraceDx.Send( 'CallBack', i ); {$ENDIF}
        { TODO : Dat-Daten in GUI speichern }
      end)
      then begin
        DoSourceEmpty;
        frmMain.btnRunAgain.Visible := true;   // Abbruch aus FileOptions-Menü
        frmMain.btnRunAgain.SetFocus
        end
      else begin
        ListBoxData.AcKontext   := FileOptions.AcKontext;
        ListBoxData.AcBlockSize := ListBoxData.AcKontext shl 1 + 1{Header} + 1{AccessZeile} + 1{Trennlinie};
        if not frmMain.mItmOptionsAutoParse.Checked then begin
          UserInfo.Show( cNoAutoParse, tUserInfo.InfoType.inHintUI );
          ParserState.ReParse := false;   // (wieder) erster Parse
          InitParse
          end
        else begin
          ok := {***} DoParse; {***}
          {$IFDEF RefBatch}
            frmMain.Close
          {$ELSE}
          if ok then begin
            if FileOptions.LastItem = EmptyStr then begin
              n := OpenTreeDefault;
              frmMain.ActiveControl := frmMain.ScrollBarTv;               // sonst nil
              if ListBoxData.Modus = lmAcc
                then frmMain.lstBox.ItemIndex := 0
              end
            else begin
              n := SearchQualifiedId( FileOptions.LastItem );
              if n = nil then
                n := OpenTreeDefault
              else begin
                frmMain.ActiveControl := frmMain.ScrollBarTv;
                MyTv[tvAll].OnVisiblesChange
                end
              end;
            MyTv[tvAll].SetAktAbsPid( n, false )
            end
            {$ENDIF}
          end
        end
      end
  else begin
    DoSourceName( cNoSource );
    Error( errSourceFile, s )
    end
end;

(* WMDROPFILES *)
procedure TfrmMain.WMDROPFILES ( var Msg: TMessage );
{ Ausserdem "DragAcceptFiles" in FormCreate eintragen }
{ R014 aus Buch Borland Delphi3 für Profis: }
var size       : integer;
    Dateiname  : PChar;
begin
  {$IFDEF TraceDx} TraceDx.Call( 'WMDROPFILES' ); {$ENDIF}
  inherited;
  size := DragQueryFile( Msg.WParam, 0 , nil, 0 ) + 1;
  Dateiname := StrAlloc( size );
  DragQueryFile( Msg.WParam, 0, Dateiname, size );
  DragFinish( Msg.WParam );
//  if TPath.GetExtension( Dateiname ) = cExtensionDat then
    if actFileOpen.Enabled then begin
      Application.BringToFront;
      DoFileCloseLoad( StrPas( Dateiname ))
      end
    else
     Error( tError.errActFileOpen );
//  else
//    Error( tError.errBadExtension, Dateiname );
  StrDispose( Dateiname );
end;

(* btnRunAgainClick *)
procedure TfrmMain.btnRunAgainClick( Sender: TObject );
var s: string;
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'btnRunAgainClick' ); {$ENDIF} {$ENDIF}
  s := btnRunAgain.Caption;
  DoFileCloseLoad( s.Substring( cLenRunAgain ) );
end;

(* actFileOpenExecute *)
procedure TfrmMain.actFileOpenExecute( Sender: TObject );
var alt, neu: string;
begin
  {$IFDEF TraceDx} TraceDx.Call( 'actFileOpenExecute' ); {$ENDIF}
  UseClipBoard := false;
  alt := dlgOpen.FileName;
  if dlgOpen.Execute then begin
    neu := dlgOpen.FileName;
    dlgOpen.FileName := alt;
    DoFileCloseLoad( neu )
    end
end;

(* mItmRecentClick *)
procedure TfrmMain.mItmRecentClick( Sender: TObject );
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'mItmRecentClick' ); {$ENDIF} {$ENDIF}
  DoFileCloseLoad( tMenuItem( Sender ).Hint )
end;

(* mItmFileOpenClipClick *)
procedure TfrmMain.mItmFileOpenClipClick( Sender: TObject );
begin
  {$IFDEF TraceDx} {$IFNDEF TraceDxSub} TraceDx.Call( 'mItmFileOpenClipClick' ); {$ENDIF} {$ENDIF}
  if ClipBoard.HasFormat( CF_TEXT ) // and  ( MessageDlg( 'Open from ClipBoard ?', mtConfirmation, mbOKCancel, 0 ) = mrOK )
    then DoFileCloseLoad( cClipboardFile )
end;

{$ENDREGION }

{$REGION '-------------- frmMain ---------------' }

var FirstActivate: boolean = true;

(* ApplicationEventsActivate *)
procedure TfrmMain.ApplicationEventsActivate( Sender: TObject );
type tOpt = ( paNul, paOpt, paSrc );
var f, s: string;
    i: tFileIndex_;
    b: boolean;
    j: word;
    p: string;
    o: tOpt;
begin
  {$IFDEF TraceDx} TraceDx.Call( 'ApplicationEventsActivate', FirstActivate ); {$ENDIF}
//  if ActiveControl = nil then ActiveControl := AktTv;

  if FirstActivate then begin
    assert( ( sizeOf( tAcInfo             ) mod 4 = 0 ) and
            ( sizeOf( UnitSystem.IdFlags  )       = 4 ) and    // geht nicht im initialization-Abschnitt
            ( sizeOf( UnitSystem.IdFlags2 )       = 4 ) and    // geht nicht im initialization-Abschnitt
            ( sizeOf( tIdInfo             ) mod 4 = 0 ) and
            ( sizeOf( tFileInfo           ) mod 4 = 0 ),     'sizeOf <> 4' );
    FirstActivate := false;
    TListen.Init( UserInfo.ShowExtern );
    TParser.Init;
    p := ReadWriteProgIni( TFileAccess.faRead );

//    frmViewer.lstBoxViewer.Font := lstBox.Font;
//    frmViewer.Init( tMyTreeView.ChangeAbsPid, Font.Size );
    SplitterMainMoved( nil );

    o := tOpt( ParamCount > 0);  // Options -t
    for j := 1 to ParamCount do
      if o < paSrc then begin
        p := ParamStr( j );
        if p.Chars[0] = cOptionChar then
          case p.Chars[1] of
          'b': begin
//                 OptionBatchMode := true;     // zZ keine Parameter vorgesehen
                 mItmOptionsProjectOptions.Checked := true;
                 mItmOptionsAutoParse     .Checked := true
               end
          end
        else
          o := paSrc
        end
      else
        p := p + ' ' + ParamStr( j );

    if p <> '' then
      btnRunAgain.Caption := btnRunAgain.Caption + sLineBreak + sLineBreak + p; //btnRunAgain.Caption + sLineBreak + dlgOpen.FileName;
    if o = paSrc then begin
      ProgIni.Modified := true;     // Modified nur wenn andere Source als zuletzt geladen wurde,  sonst rückgängig machen
      DoFileCloseLoad( p )
      end
    else begin
      actFileNewCloseExecute( actFileNew );
      if p = '' then
        UserInfo.Show( cWelcome, tUserInfo.InfoType.inHintUI )
      else begin
  //      btnRunAgain.Caption := btnRunAgain.Caption + sLineBreak + sLineBreak + s; //btnRunAgain.Caption + sLineBreak + dlgOpen.FileName;
        UserInfo.Show( cWelcome + '   or   click RunAgain-Button', tUserInfo.InfoType.inHintUI );
        btnRunAgain.Visible := true;
  //      btnRunAgain.SetFocus;    geht nicht????
        ActiveControl := btnRunAgain
        end
      end;

    {für DragDrop vom Explorer, siehe TFormMain.WMDROPFILES in UnitMain: }
    DragAcceptFiles( Handle, true )    // an's Ende weil "Handle" vorher nicht stabil ist?
    end

  else begin
    { alle registrierten Dateien auf Existenz und Datum überprüfen: }
    s := EmptyStr;
    for i := cFirstFile + ord( UseClipBoard ) to high( DateiListe ) do with DateiListe[i]^ do begin
      if TFile.Exists( Filename )
        then b := ( FileDatum = 0) or ( FileDatum <> TFile.GetLastWriteTime( FileName ) )
        else b :=   FileDatum <> 0;
      if b then begin
        include( fiFlags, tfileflags.isNotLatest );
        if MyUnit = nil
          then f := TPath.GetFileName                ( FileName )
          else f := TPath.GetFileNameWithoutExtension( FileName );
        if s = EmptyStr
          then s := 'Source changed:  ' + f
          else s := s + ' / '           + f
        end;
      end;
    if s <> EmptyStr then
      UserInfo.Show( s, tUserInfo.InfoType.inWarning )
    end
end;

(* FormCreate *)
procedure TfrmMain.FormCreate( Sender: TObject );
begin
  {$IFDEF TraceDx}
    TraceDx.Call( 'FormCreate' );
    TraceDx.AddMenu( Menu );
    {$IFDEF RefVerify}
      TraceDx.AddMenu;
    {$ENDIF}
    TraceDx.Messages          .EnabledSet := [mtAppOnMessage];
    TraceDx.Messages.SelectHide( mtAppOnMessage, [WM_MOUSEMOVE, WM_MOUSELEAVE, WM_NCMOUSEMOVE, WM_NCMOUSELEAVE, $0060, WM_PAINT, WM_TIMER] );
    TraceDx.Events.Forms[Self].EnabledSet := TraceDx.Events.Frm.cStandard - [evFrmOnMouseActivate];
    {$IFDEF TraceDxSub}
//      TraceDx.Events.Forms[Self].SubCtrls.DoLog( true );
      TraceDx.Events.Forms[Self].SubCtrls.Enabled := true;
    {$ENDIF}
  {$ENDIF}
//  actFileSave.Enabled := false;                     // im Anlauf-New NICHT speichern   // ist sowieso disabled
  CtrlArray[ctFiles] := tvFiles;
  CtrlArray[ctMyTv]  := ScrollBarTv;
  CtrlArray[ctList]  := lstBox;
  PanelLeft.BringToFront;
  dlgOpen.InitialDir  := TMyApp.DirExe;
  dlgOpen.DefaultExt  := cExtensionDproj.Substring( 1 );
  dlgOpen.Filter      := 'Project(Delphi)|*' + cExtensionDproj + ';*' + cExtensionDpr + ';*.dpk|Source|*.pas|Project(Lazarus)|*.lpr|all Files|*.*';
  dlgSave.Filter      := dlgOpen.Filter;           // Save aus Open-dfm übernehmen
  {$IFDEF Release}
  MainMenuRefactor.Enabled := false;
  {$ENDIF}
  {$IFDEF SaveTree}
  mItmExtraExportDebug.Enabled := true;
  {$ELSE}
  mItmHelpMailTo.Visible  := true;
  {$ENDIF}
  tMyTreeView.Init
end;

(* OnAllCreated *)
procedure OnAllCreated;
begin
  {$IFDEF TraceDx}
    TraceDx.Call( uMain, 'OnAllCreated' );
  {$ENDIF}
  frmViewer.Init( tMyTreeView.ChangeAbsPid );
  frmHistory.RegisterAkt( tMyTreeView.ChangeAbsPid )
end;

(* FormKeyDown *)
procedure TfrmMain.FormKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
var b: boolean;
    p: pIdInfo;
begin
  if CriticalWork   or   (( ListBoxData.Modus <> lmAcc )  and  ( Key <> VK_ESCAPE )) then
     exit;

  b := true;
  case Key of
  vk0..vkZ   : if ssCtrl in Shift then begin
                 if MyTv[tvAll].FirstNode <> nil then
                   SetGotoHotKey( char( Key ), ssShift in Shift )
                 end
               else if not ( ActiveControl = cmbBoxSearch ) then begin
                 ActiveControl := cmbBoxSearch;
                 cmbBoxSearch.SelLength := 0;
                 PostMessage( cmbBoxSearch.Handle, WM_KEYDOWN, VK_END, 0 );
                 PostMessage( cmbBoxSearch.Handle, WM_KEYDOWN, Key   , 0 )
                 end;

  VK_F6      : if ssCtrl in Shift then begin
                 HideHotKeys;
                 actIdSetFilter.Execute
                 end

               else
                 if AktTv = tvAll then
                   actIdFilterName.Execute
                 else begin
                   actIdViewFilter.Execute;
                   UserInfo.Restore;
                   if not ( ssShift in Shift ) and ( MyTv[_tvFil].AktNode <> nil )
                     then MyTv[tvAll].SetAktAbsPid( MyTv[_tvFil].AktNode, true )
                   end;

  VK_RETURN  : if ActiveControl = cmbBoxSearch
                 then ActiveControl := ScrollBarTv
                 else;  // Behandlung in ScrollBarTvKeyDown
  VK_ESCAPE  : if ActiveControl = cmbBoxSearch
                 then ActiveControl := ScrollBarTv
                 else {$IFDEF DEBUG} if not Abbruch then Close {$ENDIF};

  VK_SHIFT   : if ( lstBoxHotKey.Count = 0 ) and ( ssCtrl in Shift ) then
                 ShowHotKeys;

  VK_CONTROL : if ( ListBoxData.Modus = lmAcc ) and ( MyTv[tvAll].FirstNode <> nil ) and ( AktTv = tvAll ) and not CtrlDown and
                  (( lstBoxHotKey.Count > 0 ) or ( ssShift in Shift )) then
                 ShowHotKeys;
  VK_MENU,
  VK_LWIN,
  VK_RWIN    : if CtrlDown then
                 HideHotKeys;

  VK_DELETE  : if Shift = []
                 then if ActiveControl = cmbBoxSearch
                        then b := false  // in cmbBox verarbeiten
                        else cmbBoxSearch.Text := ''
               else
                 if ( MyTv[tvAll].FirstNode <> nil ) and ( Shift >= [ssCtrl] ) and
                    ( not ( ssShift in Shift ) or ( MessageDlg( 'ALLE HotKeys löschen?', mtConfirmation, mbOKCancel, 0) = mrOK )) then
                   ResetHotKeys( ssShift in Shift );

  {$IFDEF TraceDx}
  (*VK_LEFT,
  VK_RIGHT   : if ssCtrl in Shift then
                 if (( Key = VK_LEFT ) and ( ListBoxData.Indent > 0 )) or
                    (( Key = VK_RIGHT ) and ( ListBoxData.Indent < 100 )) then begin
//                    inc( ListBoxData.Indent, cplusminus[Key = VK_LEFT] );
                    if Key = VK_LEFT
                      then dec( ListBoxData.Indent, cListBoxIndent )
                      else inc( ListBoxData.Indent, cListBoxIndent );
                    TraceDx.Send( 'Indent', ListBoxData.Indent );
                    lstBox.Repaint;
                    end;*)
  {$ENDIF}
  VK_ADD,
  VK_SUBTRACT: if Shift = [ssCtrl] then
                 if Key = VK_ADD
                   then mItmViewZoomPlusClick ( nil )
                   else mItmViewZoomMinusClick( nil )
               else
                 if Key = VK_ADD
                   then actViewKontextPlusExecute ( nil )
                   else actViewKontextMinusExecute( nil );
  VK_BACK    : if ( ActiveControl <> cmbBoxSearch ) and ( MyTv[AktTv].LastNode <> nil ) then begin
                 MyTv[AktTv].SetAktAbsPid( MyTv[AktTv].LastNode, false );
                 ActiveControl := ScrollBarTv;
                 end;
  else         b := false
  end;
  if b then Key := 0
end;

(* FormKeyUp *)
procedure TfrmMain.FormKeyUp( Sender: TObject; var Key: Word; Shift: TShiftState );
var b: boolean;
begin
  if CriticalWork or ( ListBoxData.Modus <> lmAcc ) then exit;

  b := true;
  case Key of
    VK_TAB    : begin
                  if Shift = [] then
                    if ActiveControl = cmbBoxSearch
                      then ActiveControl := CtrlArray[ctMyTv]
                      else ActiveControl := cmbBoxSearch;

                  if Shift = [ssCtrl] then begin
                    HideHotKeys;
                    actIdViewFilterExecute( actIdViewFilter );
                    end;

                  if Shift = [ssShift, ssCtrl] then
                    actIdSetFilter.Execute;
                end;
    VK_CONTROL: if CtrlDown then HideHotKeys
    else        b := false
  end;
  if b then Key := 0
end;

(* FormResize *)
procedure TfrmMain.FormResize( Sender: TObject );
begin
  actViewFullScreen.Checked := WindowState = wsMaximized;
  PanelLeft.Constraints.MaxWidth := ClientWidth - 200;
  tMyTreeView.OnResize
end;

(* SplitterMainMoved *)
procedure TfrmMain.SplitterMainMoved( Sender: TObject );
begin
//  tBtnSepaIdAcWidth.Width := SplitterMain.Left - tBtnSepaIdAcWidth.Left;
//  cmbBoxSearch.Width := PanelLeft.ClientWidth - tBtnIdBack.Width - tBtnIdFilter.Width - cmbBoxSearch.Left - tBtnSepaIdAc.Width - 2*SplitterMain.Width;
  cmbBoxSearch.Width := ToolBarId.ClientWidth - tBtnIdBack.Width - tBtnIdFilter.Width - 3 * ToolButton3.Width;
  ToolBarAcResize( nil )
end;

(* ToolBarResize *)
procedure TfrmMain.ToolBarAcResize( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'ToolBarResize' ); {$ENDIF}
  tBtnSepaHelp.Width := ( ToolBarAc.ClientWidth - tBtnHelp.Width ) - ( chkBoxUnitOnly.Left + chkBoxUnitOnly.Width )
end;

(* FormAfterMonitorDpiChanged *)
procedure TfrmMain.FormAfterMonitorDpiChanged( Sender: TObject; OldDPI, NewDPI: Integer );
begin
  SetFontHeight( 0 );
  frmMain.FormResize( nil );
  ToolBarAcResize( nil )
end;

{$ENDREGION }

{$REGION '----------Filter Via und Unit ---------------' }

(* actRefsViaChange *)
procedure TfrmMain.DoRefsViaChange( enable: boolean );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'DoRefsViaChange', enable ); {$ENDIF}
  actRefsViaOnly.Enabled := enable;
  if enable
    then       actRefsViaOnly.Caption := 'Via "' + pAcVia^.IdDeclare^.Name + '"'
    else begin actRefsViaOnly.Caption := cViaId; pAcVia := nil; AktIdVia := nil end;
  chkBoxViaIdOnly.Width := 3*chkBoxViaIdOnly.ClientHeight{für die CkeckBox selbst} + ToolBarAc.Canvas.TextWidth( actRefsViaOnly.Caption );
  ToolBarAc.Realign;
  ToolBarAcResize( nil )
end;

(* actRefsViaOnlyExecute *)
procedure TfrmMain.actRefsViaOnlyExecute( Sender: TObject );
begin
  {$IFDEF TraceDx} TraceDx.Call( 'actRefsViaOnlyExecute', actRefsViaOnly.Checked ); {$ENDIF}
  if actRefsViaOnly.Checked
    then include( MyTv[AktTv].AktNode^.IdFlagsDyn, tIdFlagsDyn.ViaOnly )
    else exclude( MyTv[AktTv].AktNode^.IdFlagsDyn, tIdFlagsDyn.ViaOnly );
  tMyTreeView.SetActivePid( MyTv[AktTv].AktNode )
end;

(* actRefsViaSelectExecute *)
procedure TfrmMain.actRefsViaSelectExecute( Sender: TObject );

  procedure BuildTreeVia();
  var pAc     : pAcInfo;
      NewNode : boolean;

    function Insert( pAc: pAcInfo; pId: pIdInfo; tn: tTreeNode ): tTreeNode;
    begin
      if pId = nil then begin
        {$IFDEF TraceDx} TraceDx.Call( 'InsertAc', pAc^.IdDeclare^.Name); {$ENDIF}
        if pAc^.AcPrev = nil
          then tn := Insert( nil,         pAc.IdDeclare^.PrevBlock, tn )    // Ac-Kette zu Ende, auf PrevBlocks übergehen
          else tn := Insert( pAc^.AcPrev, nil,                      tn );
        pId := pAc^.IdDeclare
        end
      else begin
        {$IFDEF TraceDx} TraceDx.Call( 'InsertId', pId^.Name ); {$ENDIF}
        if ( pId^.PrevBlock = @IdMainMain )  or  ( pId^.Typ = id_Type )
          then exit( tn )
          else tn := Insert( nil, pId^.PrevBlock, tn )
        end;

      if ( pId^.Typ = id_Type ) or ( pId^.Name = dPtrSymbol ) or ( pId^.Name = dArraySymbol ) then
        Result := tn      // nicht in Baum aufnehmen
      else
        if NewNode  or  ( pId^.MyIdViaNode = nil ) then begin

          {$IFDEF TraceDx} TraceDx.Send( 'AddChild', pId^.Name ); {$ENDIF}
          NewNode := true;
          if pAc = nil
            then Result := frmVia.TreeViewVia.Items.AddChildObject( tn, pId^.Name, pId )    // Data:=pId damit pId^.MyIdViaNode gelöscht werden kann
            else Result := frmVia.TreeViewVia.Items.AddChildObject( tn, pId^.Name, pAc );

          Result.Enabled := pAc <> nil;
          pId^.MyIdViaNode := Result;   // im Id merken dass ich schon im Tree bin
          if ( pAc <> nil ) and ( pAcVia <> nil ) and ( pAc^.IdDeclare = pAcVia^.IdDeclare )
            then frmVia.TreeViewVia.Selected := Result          // auch bei Id-Wechsel bleibt der Select wenn möglich erhalten
          end
        else
          Result := pId^.MyIdViaNode;     // Id ist schon enthalten, TreeNode zurückliefern und darunter weitermachen
    end;

  begin
    {$IFDEF TraceDx} TraceDx.Call( 'btnSelectFromViaClick.BuildTreeVia' ); {$ENDIF}
    if MyTv[AktTv].AktNode = nil then exit;             // unnötig ???

    { erst aus altem Baum alle Verweise löschen: }
    if frmVia.TreeViewVia.Items.Count > 0 then
      for var t in frmVia.TreeViewVia.Items do
        if t.Enabled
          then pAcInfo( t.Data )^.IdDeclare^.MyIdViaNode := nil
          else pIdInfo( t.Data )^.           MyIdViaNode := nil;

    { Baum leeren: }
    frmVia.TreeViewVia.Items.BeginUpdate;
    frmVia.TreeViewVia.Items.Clear;

    { neuen Baum bauen: }
    pAc := MyTv[AktTv].AktNode^.AcList;
    while pAc <> nil do begin
      NewNode := false;
      if ( pAc^.ZugriffTyp <> ac_Declaration ) and ( pAc^.AcPrev <> nil ) then
        Insert ( pAc^.AcPrev, nil, nil );
      pAc := pAc^.NextAc
      end;

    frmVia.TreeViewVia.SortType := stText;
    if frmVia.TreeViewVia.Items.Count <= 100 then
      if frmVia.TreeViewVia.Selected = nil
        then frmVia.TreeViewVia.FullExpand
        else frmVia.TreeViewVia.Selected.MakeVisible;

    frmVia.TreeViewVia.Items.EndUpdate
  end;

begin
  if AktIdVia <> MyTv[AktTv].AktNode then begin
    {$IFDEF TraceDx} // TraceDx.ToServer := true; TraceDx.Clear;
                     TraceDx.Call( 'btnSelectFromViaClick' ); {$ENDIF}
    Screen.Cursor := crHourGlass;
    frmVia.Caption := 'Select Access-Via for "' + TListen.getBlockNameLong( MyTv[AktTv].AktNode, dTrennView ) + '"';
    BuildTreeVia;
    AktIdVia := MyTv[AktTv].AktNode;
    Screen.Cursor := crDefault
    end;

  if (( Sender = nil{nur für RefVerify} ) or ( frmVia.ShowModal <> mrCancel ))  and  ( frmVia.TreeViewVia.Selected <> nil ) then begin
    pAcVia := frmVia.TreeViewVia.Selected.Data;
    DoRefsViaChange( true );
    if actRefsViaOnly.Checked
      then actRefsViaOnlyExecute( nil )
      else actRefsViaOnly.Execute
    end;
end;

procedure TfrmMain.mItmRefUnitOnlyClick( Sender: TObject );
begin
  chkBoxUnitOnly.Checked := not chkBoxUnitOnly.Checked
end;

procedure TfrmMain.cboBoxUnitsClick( Sender: TObject );
begin
  MyTv[AktTv].AktNode^.MyUnitOnly := cboBoxUnits.ItemIndex + 1;     // damit 0 die Bedeutung "ohne" haben kann
  pIdUnitOnly := pIdInfo( cboBoxUnits.Items.Objects[cboBoxUnits.ItemIndex] );
  tMyTreeView.SetActivePid( MyTv[AktTv].AktNode );
  chkBoxUnitOnly.Enabled := true;
  chkBoxUnitOnly.Checked := true
end;

procedure TfrmMain.cboBoxUnitsDropDown( Sender: TObject );
var pAc: pAcInfo;
    pId: pIdInfo;
    w  : integer;
begin
  if cboBoxUnits.ItemIndex >= 0 then exit;

  cboBoxUnits.Items.Clear;
  cboBoxUnits.Items.BeginUpdate;
  w := 0;
  { neue Liste bauen: }
  pAc := MyTv[AktTv].AktNode^.AcList;
  while pAc <> nil do begin
    pId := pAc^.IdUse;

    while not ( pId^.Typ in [id_Unit, id_Program, id_NameSpace, id_MainBlock] ) do
      pId := pId^.PrevBlock;

    if ( pId^.Typ <> id_MainBlock ) and ( cboBoxUnits.Items.IndexOfObject( TObject( pId )) = -1 ) then begin
      {$IFDEF TraceDx} TraceDx.Send( Sender, 'Insert', pId^.Name ); {$ENDIF}
      cboBoxUnits.Items.AddObject( pId^.Name, TObject( pId ));
      if length( pId^.Name ) > w then
        w := length( pId^.Name )
      end;

    pAc := pAc^.NextAc
    end;

  w := 3*cboBoxUnits.ClientHeight{für die CkeckBox selbst} + cboBoxUnits.Canvas.TextWidth( StringOfChar( 'e', w ));
  if cboBoxUnits.Width < w then begin
    cboBoxUnits.Width := w;
    ToolBarAc.Realign;
    ToolBarAcResize( nil )
    end;
  cboBoxUnits.Items.EndUpdate
end;

procedure TfrmMain.chkBoxUnitOnlyClick( Sender: TObject );
begin
  if chkBoxUnitOnly.Checked
    then include( MyTv[AktTv].AktNode^.IdFlagsDyn, tIdFlagsDyn.UnitOnly )
    else exclude( MyTv[AktTv].AktNode^.IdFlagsDyn, tIdFlagsDyn.UnitOnly );
  tMyTreeView.SetActivePid( MyTv[AktTv].AktNode )
end;

{$ENDREGION }

{$REGION '-------------- Help ---------------' }

(* actHelpInfoExecute *)
procedure TfrmMain.actHelpInfoExecute( Sender: TObject );
var
  s: string;
begin
  s := cProgName + ' ' + cVersion + cDebug + sLineBreak + sLineBreak + cMailTo;
  MessageDlg( s, mtInformation, [mbOK], 0 )
end;

(* actHelpHilfeExecute *)
procedure TfrmMain.actHelpHilfeExecute( Sender: TObject );
const cHlp = 'RefHelp.txt';
var s: string;
begin
  s := TMyApp.DirExe + cHlp;
  if not TFile.Exists( s ) then
    s := TMyApp.DirExe + 'Help\' + cHlp;
  if TFile.Exists( s ) then begin
    if not assigned( frmHelp ) then begin
      frmHelp := tfrmHelp.Create( Self );
      frmHelp.Caption := 'Hilfe für ' + cProgName;
      frmHelp.lstBoxHelp.Items.LoadFromFile( s );
      frmHelp.lstBoxHelp.ItemIndex := frmHelp.lstBoxHelp.Items.IndexOf( 'Anzeige und Bedienung' ) + 1;
      frmHelp.lstBoxHelp.TopIndex := frmHelp.lstBoxHelp.ItemIndex - 2
      end;
    frmHelp.Show
    end
  else
    Error( tError.errHelpFile, s )
end;

(* mItmHelpMailToClick *)
procedure TfrmMain.mItmHelpMailToClick( Sender: TObject );
begin
  ShellExecute( Application.Handle, 'open', pchar ('mailto:' + cMailTo + '?subject=' + cProgName + ' ' + cVersion + cSubVersion + ' : '), nil, nil, SW_SHOW )
end;

{$ENDREGION }

{$REGION '-------------- GUI-Aktionen ---------------' }

{$ENDREGION }

{$REGION '-------------- Init / Exit ---------------' }

initialization
  {$IFDEF TraceDx}
    TraceDx.Send( uMain, 'initialization ' );
  {$ENDIF}
  {$IFDEF UnitOneInst} uOneInstDx.TriggerProc := FromUnitOneInst; {$ENDIF}         // Benachrichtigung bei Doppelstart
//  SetErrorMode( SEM_FAILCRITICALERRORS );             // https://docs.microsoft.com/en-us/windows/win32/api/errhandlingapi/nf-errhandlingapi-seterrormode

//  BalloonHint := TBalloonHint.Create( nil );

  TMyApp.Init( cProgName, cVersion + cSubVersion, '1.4' );
  try
    ProgIni := TMemIniFile.Create( TMyApp.DirUser + '_' + cProgname + '.ini' );
    ProgIni.AutoSave := false
  except Error( errProgIni, TMyApp.DirUser + '_' + cProgname + '.ini' );
         halt
  end;

finalization
  {$IFDEF TraceDx} TraceDx.Send( uMain, 'finalization ' ); {$ENDIF}
  ProgIni.Free;
//  BalloonHint.Free

{$ENDREGION }

end.

