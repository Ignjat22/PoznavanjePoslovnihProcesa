unit KreditniZahtev;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.VCLUI.Wait,
  FireDAC.Phys.SQLiteWrapper.Stat, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Vcl.StdCtrls, Vcl.ExtCtrls, FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  Vcl.Imaging.jpeg, System.UITypes, Ugovori;

type
  TForm4 = class(TForm)
    Image1: TImage;
    Shape1: TShape;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ImeEdit: TEdit;
    Label4: TLabel;
    PrezimeEdit: TEdit;
    IznosEdit: TEdit;
    Label5: TLabel;
    TipKreditaEdit: TEdit;
    Label6: TLabel;
    StatusEdit: TEdit;
    Label7: TLabel;
    RokOtplateEdit: TEdit;
    Label8: TLabel;
    Label9: TLabel;
    ObrisiZahtevButton: TButton;
    FDQuery1: TFDQuery;
    FDConnection1: TFDConnection;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    OdlukaStatusEdit: TEdit;
    Label10: TLabel;
    OdlukaDatumEdit: TEdit;
    Label11: TLabel;
    OdlukaKomentarEdit: TEdit;
    Label12: TLabel;
    FDQuery2: TFDQuery;
    PotvrdiOdlukuButton: TButton;
    UgovorButton: TButton;
    PlataEdit: TEdit;
    Label15: TLabel;
    JMBGEdit: TEdit;
    Label16: TLabel;
    procedure ObrisiZahtevButtonClick(Sender: TObject);
    procedure PotvrdiOdlukuButtonClick(Sender: TObject);
    procedure UgovorButtonClick(Sender: TObject);
  private
    FKreditniZahtevID: Integer;
  public
    procedure LoadZahtev(AZahtevID: Integer);
  end;

var
  Form4: TForm4;

implementation

{$R *.dfm}


procedure TForm4.LoadZahtev(AZahtevID: Integer);
begin
  FKreditniZahtevID := AZahtevID;

  FDConnection1.Params.Clear;
  FDConnection1.Params.DriverID := 'SQLite';
  FDConnection1.Params.Database := 'C:\Users\Dell\Documents\Embarcadero\Studio\Projects\PPP\BankarskaAplikacijaDB.db';
  FDConnection1.LoginPrompt := False;
  FDConnection1.Connected := True;

  FDQuery1.Connection := FDConnection1;
  FDQuery1.Close;
  FDQuery1.SQL.Text :=
    'SELECT k.ime, k.prezime, k.jmbg, k.plata, z.iznos, z.tip_kredita, z.rok_otplate, z.status ' +
    'FROM kreditnizahtev z ' +
    'JOIN klijent k ON z.klijent_id = k.id ' +
    'WHERE z.rowid = :id';
  FDQuery1.ParamByName('id').AsInteger := AZahtevID;
  FDQuery1.Open;

  if not FDQuery1.IsEmpty then
  begin
    ImeEdit.Text        := FDQuery1.FieldByName('ime').AsString;
    PrezimeEdit.Text    := FDQuery1.FieldByName('prezime').AsString;
    JMBGEdit.Text       := FDQuery1.FieldByName('jmbg').AsString;
    PlataEdit.Text      := FDQuery1.FieldByName('plata').AsString;
    IznosEdit.Text      := FDQuery1.FieldByName('iznos').AsString;
    TipKreditaEdit.Text := FDQuery1.FieldByName('tip_kredita').AsString;
    RokOtplateEdit.Text := FDQuery1.FieldByName('rok_otplate').AsString;
    StatusEdit.Text     := FDQuery1.FieldByName('status').AsString;

    // Sakrij dugme za ugovor ako je status "odbijeno"
    if LowerCase(FDQuery1.FieldByName('status').AsString) = 'odbijeno' then
      UgovorButton.Visible := False
    else
      UgovorButton.Visible := True;
    if LowerCase(FDQuery1.FieldByName('status').AsString) = 'cekanje' then
      UgovorButton.Visible := False
    else
      UgovorButton.Visible := True;
  end;
end;





procedure TForm4.ObrisiZahtevButtonClick(Sender: TObject);
begin
  if FKreditniZahtevID = 0 then
  begin
    ShowMessage('Nije pronađen ID kreditnog zahteva.');
    Exit;
  end;

  if MessageDlg('Da li ste sigurni da želite da obrišete ovaj kreditni zahtev?',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      FDConnection1.ExecSQL('DELETE FROM kreditnizahtev WHERE rowid = :id', [FKreditniZahtevID]);
      ShowMessage('Kreditni zahtev je uspešno obrisan.');
      Close; // zatvori formu nakon brisanja
    except
      on E: Exception do
        ShowMessage('Greška prilikom brisanja: ' + E.Message);
    end;
  end;
end;

procedure TForm4.PotvrdiOdlukuButtonClick(Sender: TObject);
var
  NoviStatus: string;
  DatumOdluke: string;
  Komentar: string;
  Plata, Iznos: Double;
  PlataStr, IznosStr: string;
begin
  if FKreditniZahtevID = 0 then
  begin
    ShowMessage('Nije pronađen ID kreditnog zahteva.');
    Exit;
  end;

  NoviStatus := Trim(LowerCase(OdlukaStatusEdit.Text));

  if (NoviStatus <> 'odobreno') and (NoviStatus <> 'odbijeno') then
  begin
    ShowMessage('Status mora biti "odobreno" ili "odbijeno".');
    Exit;
  end;

  // Ukloni ' RSD' sa kraja i zameniti '.' za konverziju u broj
  PlataStr := StringReplace(Copy(PlataEdit.Text, 1, Length(PlataEdit.Text)-4), '.', '', [rfReplaceAll]);
  IznosStr := StringReplace(Copy(IznosEdit.Text, 1, Length(IznosEdit.Text)-4), '.', '', [rfReplaceAll]);

  Plata := StrToFloatDef(PlataStr, 0);
  Iznos := StrToFloatDef(IznosStr, 0);

  // Provera da li kredit može biti odobren
  if (NoviStatus = 'odobreno') and (Iznos > Plata * 10) then
  begin
    ShowMessage('Kredit ne može biti odobren jer je iznos previsok u odnosu na platu.');
    Exit;
  end;

  DatumOdluke := Trim(OdlukaDatumEdit.Text);
  Komentar := Trim(OdlukaKomentarEdit.Text);

  try
    // 1. Ažuriraj status i datum u kreditnizahtev
    FDConnection1.ExecSQL(
      'UPDATE kreditnizahtev SET status = :status WHERE rowid = :id',
      [NoviStatus, FKreditniZahtevID]
    );

    // 2. Ubaci novi zapis u tabelu odluka
    FDConnection1.ExecSQL(
      'INSERT INTO odluka (kreditnizahtev_id, status, komentar, datum) ' +
      'VALUES (:kid, :status, :komentar, :datum)',
      [FKreditniZahtevID, NoviStatus, Komentar, DatumOdluke]
    );

    ShowMessage('Odluka uspešno sačuvana.');
    Close; // zatvori formu

  except
    on E: Exception do
      ShowMessage('Greška prilikom čuvanja odluke: ' + E.Message);
  end;
end;



procedure TForm4.UgovorButtonClick(Sender: TObject);
begin
  Form6 := TForm6.Create(Self);
  try
    Form6.SetZahtevID(FKreditniZahtevID); // prosledi izabrani zahtev
    Form6.ShowModal;
  finally
    Form6.Free;
  end;
end;



end.
