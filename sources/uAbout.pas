unit uAbout;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TfAbout = class(TForm)
    btOK: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fAbout: TfAbout;

implementation

uses uCommon;

{$R *.dfm}

procedure TfAbout.FormShow(Sender: TObject);
begin
  Label1.Caption := Application.Title;
  Label2.Caption := '����������� ��������� �������';
  Label3.Caption := Format('v. %s (C) 2017 by Apromix', [Version]);
end;

end.