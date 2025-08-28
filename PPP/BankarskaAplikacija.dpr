program BankarskaAplikacija;

uses
  Vcl.Forms,
  Login in 'Login.pas' {Form1},
  MainForm in 'MainForm.pas' {Form2},
  Vcl.Themes,
  Vcl.Styles,
  Klijent in 'Klijent.pas' {Form3},
  KreditniZahtev in 'KreditniZahtev.pas' {Form4},
  Odluka in 'Odluka.pas' {Form5},
  Ugovori in 'Ugovori.pas' {Form6};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TForm4, Form4);
  Application.CreateForm(TForm5, Form5);
  Application.CreateForm(TForm6, Form6);
  Application.Run;
end.
