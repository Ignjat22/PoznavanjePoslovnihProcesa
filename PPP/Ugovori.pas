unit Ugovori;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Phys.SQLiteWrapper.Stat, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Vcl.Printers;

type
  TForm6 = class(TForm)
    FDConnection1: TFDConnection;
    FDQuery1: TFDQuery;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    Button1: TButton;
    Memo1: TMemo;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    FKreditniZahtevID: Integer;
    procedure UcitajUgovor;
    procedure DodajLiniju(const Tekst: string);
  public
    procedure SetZahtevID(AID: Integer); // za prosleđivanje ID-a iz Form4
  end;

var
  Form6: TForm6;

implementation

{$R *.dfm}

procedure TForm6.SetZahtevID(AID: Integer);
begin
  FKreditniZahtevID := AID;
end;

procedure TForm6.FormShow(Sender: TObject);
begin
  Memo1.Clear;

  if FKreditniZahtevID = 0 then
    ShowMessage('Nije prosleđen ID kreditnog zahteva.')
  else
    UcitajUgovor;
end;

// Jednostavna procedura za dodavanje linija sa razmakom
procedure TForm6.DodajLiniju(const Tekst: string);
begin
  Memo1.Lines.Add(Tekst);
end;

procedure TForm6.UcitajUgovor;
begin
  FDConnection1.Params.Clear;
  FDConnection1.Params.DriverID := 'SQLite';
  FDConnection1.Params.Database := 'C:\Users\Dell\Documents\Embarcadero\Studio\Projects\PPP\BankarskaAplikacijaDB.db';
  FDConnection1.LoginPrompt := False;
  FDConnection1.Connected := True;

  FDQuery1.Connection := FDConnection1;

  FDQuery1.Close;
  FDQuery1.SQL.Text :=
    'SELECT k.ime, k.prezime, k.jmbg, k.plata, ' +
    'z.iznos, z.tip_kredita, z.rok_otplate, z.status AS status_zahteva, ' +
    'o.status AS status_odluke, o.datum, o.komentar ' +
    'FROM klijent k ' +
    'JOIN kreditnizahtev z ON k.id = z.klijent_id ' +
    'LEFT JOIN odluka o ON z.rowid = o.kreditnizahtev_id ' +
    'WHERE z.rowid = :id ' +
    'ORDER BY o.datum DESC ' +
    'LIMIT 1';
  FDQuery1.ParamByName('id').AsInteger := FKreditniZahtevID;
  FDQuery1.Open;

  Memo1.Clear;

  if not FDQuery1.IsEmpty then
  begin
    DodajLiniju('-----------------------------------------');
    DodajLiniju('UGOVOR O KREDITU');
    DodajLiniju('');

    DodajLiniju('Podaci o korisniku:');
    DodajLiniju('Ime i Prezime: ' + FDQuery1.FieldByName('ime').AsString + ' ' +
                FDQuery1.FieldByName('prezime').AsString);
    DodajLiniju('JMBG: ' + FDQuery1.FieldByName('jmbg').AsString);
    DodajLiniju('Plata: ' + FDQuery1.FieldByName('plata').AsString);
    DodajLiniju('');

    DodajLiniju('Podaci o kreditu:');
    DodajLiniju('Iznos: ' + FDQuery1.FieldByName('iznos').AsString);
    DodajLiniju('Tip kredita: ' + FDQuery1.FieldByName('tip_kredita').AsString);
    DodajLiniju('Rok otplate: ' + FDQuery1.FieldByName('rok_otplate').AsString);
    DodajLiniju('Status zahteva: ' + FDQuery1.FieldByName('status_zahteva').AsString);
    DodajLiniju('');

    DodajLiniju('Odluka:');
    if FDQuery1.FieldByName('status_odluke').IsNull then
      DodajLiniju('Nema odluke još uvek.')
    else
    begin
      DodajLiniju('Status: ' + FDQuery1.FieldByName('status_odluke').AsString);
      DodajLiniju('Datum: ' + FDQuery1.FieldByName('datum').AsString);
      DodajLiniju('Komentar: ' + FDQuery1.FieldByName('komentar').AsString);
    end;

    DodajLiniju('');
    DodajLiniju('-----------------------------------------');
    DodajLiniju('Mesto za potpise:');
    DodajLiniju('_________________________');
    DodajLiniju('Korisnik');
    DodajLiniju('_________________________');
    DodajLiniju('Bankar');
  end
  else
    DodajLiniju('Nije pronađen zahtev sa ID ' + IntToStr(FKreditniZahtevID));
end;


procedure TForm6.Button1Click(Sender: TObject);
var
  i, Y: Integer;
begin
  Printer.BeginDoc;
  try
    Y := 0;
    for i := 0 to Memo1.Lines.Count - 1 do
    begin
      Printer.Canvas.TextOut(10, 20 + Y, Memo1.Lines[i]);
      Y := Y + 20;
    end;
  finally
    Printer.EndDoc;
  end;
end;

end.

