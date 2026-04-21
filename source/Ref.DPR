program Ref;

{$INCLUDE _CompilerOptions.pas}

uses
  Vcl.Forms,
  ufReferenz in 'ufReferenz.pas' {frmMain},
  ufHelp in 'ufHelp.pas' {frmHelp},
  uDataIO in 'uDataIO.pas',
  uGlobals in 'uGlobals.pas',
  ufFileOptions in 'ufFileOptions.pas' {frmFileOptions},
  uGlobalsParser in 'uGlobalsParser.pas',
  ufViewer in 'ufViewer.pas' {frmViewer},
  ufError in 'ufError.pas' {frmError},
  uHeapCheck in 'uHeapCheck.pas',
  uSystem in 'uSystem.pas',
  ufFilter in 'ufFilter.pas' {frmFilter},
  SendInputHelper in 'SendInputHelper.pas',
  ufHistory in 'ufHistory.pas' {frmHistory},
  ufVia in 'ufVia.pas' {frmVia},
  u_Nassi in 'u_Nassi.pas';

{$R *.RES}

begin
//  {$IFDEF DEBUG}
    ReportMemoryLeaksOnShutdown := true;
//  {$ENDIF}
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmFileOptions, frmFileOptions);
  Application.CreateForm(TfrmViewer, frmViewer);
  Application.CreateForm(TfrmError, frmError);
  Application.CreateForm(TfrmFilter, frmFilter);
  Application.CreateForm(TfrmHistory, frmHistory);
  Application.CreateForm(TfrmVia, frmVia);
  OnAllCreated;
  Application.Run;
end.

