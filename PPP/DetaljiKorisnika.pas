unit DetaljiKorisnika;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Imaging.jpeg,
  Vcl.ExtCtrls, Data.DB, Vcl.Grids, Vcl.DBGrids, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,System.UITypes, KreditniZahtev;

type
  TForm7 = class(TForm)
    Label1: TLabel;
    Image1: TImage;
    Label2: TLabel;
    ImeEdit: TEdit;
    PrezimeEdit: TEdit;
    Label3: TLabel;
    JMBGEdit: TEdit;
    Label4: TLabel;
    PlataEdit: TEdit;
    Label5: TLabel;
    DBGrid1: TDBGrid;
    Shape1: TShape;
    FDConnection1: TFDConnection;
    FDQuery1: TFDQuery;  // Informacije o korisniku
    FDQuery2: TFDQuery;  // Zahtevi korisnika
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    DataSource1: TDataSource;
    Label6: TLabel;
    DodajZahtevButton: TButton;
    Label7: TLabel;
    IznosEdit: TEdit;
    TipKreditaName: TEdit;
    Label8: TLabel;
    ObrisiKorisnikaButton: TButton;
    RokOtplateEdit: TEdit;
    Label9: TLabel;
    procedure DodajZahtevButtonClick(Sender: TObject);
    procedure ObrisiKorisnikaButtonClick(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
  private
    FKorisnikID: Integer;
  public
    procedure LoadKorisnik(AKorisnikID: Integer);
  end;

var
  Form7: TForm7;

implementation

{$R *.dfm}

procedure TForm7.LoadKorisnik(AKorisnikID: Integer);
begin
  FKorisnikID := AKorisnikID;

  FDConnection1.Params.Clear;
  FDConnection1.Params.DriverID := 'SQLite';
  FDConnection1.Params.Database := 'C:\Users\Dell\Documents\Embarcadero\Studio\Projects\PPP\BankarskaAplikacijaDB.db';
  FDConnection1.LoginPrompt := False;
  FDConnection1.Connected := True;

  // Informacije o korisniku
  FDQuery1.Connection := FDConnection1;
  FDQuery1.Close;
  FDQuery1.SQL.Text := 'SELECT ime, prezime, jmbg, plata FROM klijent WHERE rowid = :jid';
  FDQuery1.ParamByName('jid').AsInteger := AKorisnikID;
  FDQuery1.Open;

  if not FDQuery1.IsEmpty then
  begin
    ImeEdit.Text := FDQuery1.FieldByName('ime').AsString;
    PrezimeEdit.Text := FDQuery1.FieldByName('prezime').AsString;
    JMBGEdit.Text := FDQuery1.FieldByName('jmbg').AsString;
    PlataEdit.Text := FDQuery1.FieldByName('plata').AsString;
  end;

  // Prikaz kreditnih zahteva
  FDQuery2.Connection := FDConnection1;
  FDQuery2.Close;
FDQuery2.SQL.Text :=
  'SELECT id, CAST(iznos AS TEXT) AS iznos, ' +
  '       CAST(tip_kredita AS TEXT) AS tip_kredita, ' +
  '       CAST(rok_otplate AS TEXT) AS rok_otplate, ' +
  '       CAST(status AS TEXT) AS status ' +
  'FROM kreditnizahtev ' +
  'WHERE klijent_id = :kid';

  FDQuery2.ParamByName('kid').AsInteger := AKorisnikID;
  FDQuery2.Open;

  DBGrid1.DataSource := DataSource1;
  DataSource1.DataSet := FDQuery2;
end;

procedure TForm7.ObrisiKorisnikaButtonClick(Sender: TObject);
begin
  if FKorisnikID = 0 then
  begin
    ShowMessage('Nije pronađen ID korisnika.');
    Exit;
  end;

  if MessageDlg('Da li ste sigurni da želite da obrišete ovog korisnika?',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
  FDConnection1.ExecSQL('DELETE FROM kreditnizahtev WHERE klijent_id = :id', [FKorisnikID]);
  FDConnection1.ExecSQL('DELETE FROM klijent WHERE rowid = :id', [FKorisnikID]);


    ShowMessage('Korisnik je uspešno obrisan.');
    Close;
  end;
end;


procedure TForm7.DBGrid1DblClick(Sender: TObject);
var
  ZahtevID: Integer;
begin
  if FDQuery2.IsEmpty then Exit;

  // uzimamo rowid iz upita
  ZahtevID := FDQuery2.FieldByName('id').AsInteger;

  Form4 := TForm4.Create(Self);
  try
    Form4.LoadZahtev(ZahtevID);
    Form4.ShowModal;
  finally
    Form4.Free;
    LoadKorisnik(FKorisnikID);
  end;
end;


procedure TForm7.DodajZahtevButtonClick(Sender: TObject);
begin
  if (IznosEdit.Text = '') or (TipKreditaName.Text = '') then
  begin
    ShowMessage('Popunite sva polja za novi zahtev!');
    Exit;
  end;

  try
    FDQuery2.Close;
    FDQuery2.SQL.Text :=
      'INSERT INTO kreditnizahtev (klijent_id, iznos, tip_kredita, rok_otplate, status) ' +
      'VALUES (:kid, :iznos, :tip, :rok, :status)';

    FDQuery2.ParamByName('kid').AsInteger := FKorisnikID;
    FDQuery2.ParamByName('iznos').AsString := IznosEdit.Text;
    FDQuery2.ParamByName('tip').AsString := TipKreditaName.Text;
    FDQuery2.ParamByName('rok').AsString := RokOtplateEdit.Text;
    FDQuery2.ParamByName('status').AsString := 'cekanje';

    FDQuery2.ExecSQL;

    // Ponovo učitaj zahteve korisnika
    LoadKorisnik(FKorisnikID);

    ShowMessage('Zahtev uspešno dodat!');

    IznosEdit.Text := '';
    TipKreditaName.Text := '';

  except
    on E: Exception do
      ShowMessage('Greška prilikom dodavanja zahteva: ' + E.Message);
  end;
end;





end.
