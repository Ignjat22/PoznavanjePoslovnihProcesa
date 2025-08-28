unit Login;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async,
  FireDAC.DApt, FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite,
  FireDAC.Comp.DataSet, Vcl.Imaging.jpeg;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Image1: TImage;
    Shape1: TShape;
    FDQuery1: TFDQuery;
    FDConnection1: TFDConnection;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
  public
  end;

var
  Form1: TForm1;

implementation

uses MainForm;

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  FDConnection1.Params.Clear;
  FDConnection1.Params.DriverID := 'SQLite';
  FDConnection1.Params.Database := 'C:\Users\Dell\Documents\Embarcadero\Studio\Projects\PPP\BankarskaAplikacijaDB.db';
  FDConnection1.LoginPrompt := False;
  FDConnection1.Connected := True;

  FDQuery1.Connection := FDConnection1;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if (Edit1.Text = '') or (Edit2.Text = '') then
  begin
    ShowMessage('Unesite korisničko ime i lozinku!');
    Exit;
  end;

  FDQuery1.Close;
  FDQuery1.SQL.Text := 'SELECT * FROM bankar WHERE korisnicko_ime = :u AND lozinka = :p';
  FDQuery1.ParamByName('u').AsString := Edit1.Text;
  FDQuery1.ParamByName('p').AsString := Edit2.Text;
  FDQuery1.Open;

  if not FDQuery1.IsEmpty then
  begin
    Self.Hide;
    Form2 := TForm2.Create(Self);
    try
      Form2.ShowModal;
    finally
      Form2.Free;
      Show;
    end;
  end
  else
    ShowMessage('Pogrešno korisničko ime ili lozinka!');
end;

end.

