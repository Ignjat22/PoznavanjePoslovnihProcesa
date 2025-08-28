unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.jpeg,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.VCLUI.Wait,
  FireDAC.Phys.SQLiteWrapper.Stat, Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls, Vcl.ComCtrls,
  KreditniZahtev, DetaljiKorisnika, FireDAC.Comp.DataSet;

type
  TForm2 = class(TForm)
    Image1: TImage;
    FDConnection1: TFDConnection;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    FDQuery1: TFDQuery;
    FDQuery2: TFDQuery;
    DataSource1: TDataSource;
    Shape1: TShape;
    OdjaviSeButton: TButton;
    KlijentiLabel: TLabel;
    DBGrid1: TDBGrid;
    DodajKlijentaLabel: TLabel;
    ImeEdit: TEdit;
    PrezimeEdit: TEdit;
    JMBGEdit: TEdit;
    DodajKlijentaButton: TButton;
    PlataEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure KreditniZahtevButtonClick(Sender: TObject);
    procedure DodajKlijentaButtonClick(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
  private
    procedure LoadKlijenti;
  public
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.FormCreate(Sender: TObject);
begin
  FDConnection1.Params.Clear;
  FDConnection1.Params.DriverID := 'SQLite';
  FDConnection1.Params.Database := 'C:\Users\Dell\Documents\Embarcadero\Studio\Projects\PPP\BankarskaAplikacijaDB.db';
  FDConnection1.LoginPrompt := False;
  FDConnection1.Connected := True;

  FDQuery1.Connection := FDConnection1;
  FDQuery2.Connection := FDConnection1;

  LoadKlijenti;
end;

procedure TForm2.LoadKlijenti;
begin
  FDQuery1.Close;
  FDQuery1.SQL.Text :=
    'SELECT rowid AS klijent_id, CAST(ime AS TEXT) AS ime, ' +
    'CAST(prezime AS TEXT) AS prezime, jmbg, CAST(plata AS TEXT) AS plata ' +
    'FROM klijent';
  FDQuery1.Open;
  DBGrid1.DataSource := DataSource1;
  DataSource1.DataSet := FDQuery1;
end;

procedure TForm2.DodajKlijentaButtonClick(Sender: TObject);
begin
  if (ImeEdit.Text = '') or (PrezimeEdit.Text = '') or
     (JMBGEdit.Text = '') or (PlataEdit.Text = '') then
  begin
    ShowMessage('Popunite sva polja!');
    Exit;
  end;

  try
    FDQuery2.Close;
    FDQuery2.SQL.Text :=
      'INSERT INTO klijent (ime, prezime, jmbg, plata) ' +
      'VALUES (:ime, :prezime, :jmbg, :plata)';

    FDQuery2.ParamByName('ime').AsString := ImeEdit.Text;
    FDQuery2.ParamByName('prezime').AsString := PrezimeEdit.Text;
    FDQuery2.ParamByName('jmbg').AsString := JMBGEdit.Text;
    FDQuery2.ParamByName('plata').AsString := PlataEdit.Text;

    FDQuery2.ExecSQL;

    LoadKlijenti;

    ShowMessage('Klijent uspešno dodat!');

    ImeEdit.Text := '';
    PrezimeEdit.Text := '';
    JMBGEdit.Text := '';
    PlataEdit.Text := '';

  except
    on E: Exception do
      ShowMessage('Greška prilikom dodavanja klijenta: ' + E.Message);
  end;
end;

procedure TForm2.KreditniZahtevButtonClick(Sender: TObject);
begin
  Form4 := TForm4.Create(Self);
  try
    Self.Hide;
    Form4.ShowModal;
  finally
    Form4.Free;
    Self.Show;
  end;
end;

procedure TForm2.DBGrid1DblClick(Sender: TObject);
var
  KorisnikID: Integer;
begin
  if FDQuery1.IsEmpty then Exit;

  KorisnikID := FDQuery1.FieldByName('klijent_id').AsInteger;

  Form7 := TForm7.Create(Self);
  try
    Form7.LoadKorisnik(KorisnikID);
    Self.Hide;
    Form7.ShowModal;
  finally
    Form7.Free;
    Self.Show;

    LoadKlijenti;
  end;
end;


end.

