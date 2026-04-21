unit ufVia;
{$INCLUDE _CompilerOptions.pas}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ComCtrls;

type
  TfrmVia = class(TForm)
    TreeViewVia: TTreeView;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    btnExpand: TButton;
    btnCollapse: TButton;
    btnSearch: TButton;
    btnSearchAgain: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnExpandClick(Sender: TObject);
    procedure btnCollapseClick(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure btnSearchAgainClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TreeViewViaCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  frmVia: TfrmVia;


implementation

{$R *.dfm}

uses
  System.StrUtils,
  uGlobalsParser;

var Search: string;

procedure TfrmVia.btnCollapseClick( Sender: TObject );
begin
  TreeViewVia.FullCollapse
end;

procedure TfrmVia.btnExpandClick( Sender: TObject );
begin
  TreeViewVia.FullExpand
end;

procedure TfrmVia.btnSearchClick( Sender: TObject );
var t: tTreeNode;
begin
  if ( Search = '' ) and assigned( TreeViewVia.Selected ) then
    Search := TreeViewVia.Selected.Text;
  Search := InputBox( 'Suchen', '', Search );
  for t in TreeViewVia.Items do if t.Enabled then
    if AnsiStartsText ( Search, t.Text {pIdInfo( t.Data )^.Name} ) then begin
      TreeViewVia.Selected := t; break end
end;

procedure TfrmVia.btnSearchAgainClick( Sender: TObject );
var a, i: integer;
begin
  if not assigned( TreeViewVia.Selected ) then exit;
  a := TreeViewVia.Selected.AbsoluteIndex;
  if a = -1 then exit;

  i := a + 1;
  if i = TreeViewVia.Items.Count then i := 0;

  while i <> a do begin
    if i = TreeViewVia.Items.Count then i := 0;
    if TreeViewVia.Items[i].Enabled then
      if AnsiStartsText ( Search, TreeViewVia.Items[i].Text {pIdInfo( TreeViewVia.Items[i].Data )^.Name} ) then begin
        TreeViewVia.Selected := TreeViewVia.Items[i]; break end;
    inc( i )
    end
end;

procedure TfrmVia.FormKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
begin
  case Key of
    VK_F3   : btnSearchAgainClick( nil );
    ord('F'): if ssCtrl in Shift then btnSearchClick( nil )
    end
end;

procedure TfrmVia.FormShow( Sender: TObject );
begin
  TreeViewVia.SetFocus
end;

procedure TfrmVia.TreeViewViaCustomDrawItem( Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean );
begin
  if Node.Enabled
    then TTreeView( Sender ).Canvas.Font.Style := []
    else TTreeView( Sender ).Canvas.Font.Style := [TFontStyle.fsItalic]
end;

end.
