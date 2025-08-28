object Form6: TForm6
  Left = 0
  Top = 0
  Caption = 'Form6'
  ClientHeight = 600
  ClientWidth = 800
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 15
  object Button1: TButton
    Left = 112
    Top = 455
    Width = 97
    Height = 33
    Caption = 'Generisi ugovor'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 112
    Top = 40
    Width = 505
    Height = 409
    Lines.Strings = (
      'Memo1')
    ReadOnly = True
    TabOrder = 1
  end
  object FDConnection1: TFDConnection
    Params.Strings = (
      
        'Database=C:\Users\Dell\Documents\Embarcadero\Studio\Projects\PPP' +
        '\BankarskaAplikacijaDB.db'
      'DriverID=sQLite')
    Left = 696
    Top = 544
  end
  object FDQuery1: TFDQuery
    Connection = FDConnection1
    Left = 600
    Top = 552
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 512
    Top = 552
  end
end
