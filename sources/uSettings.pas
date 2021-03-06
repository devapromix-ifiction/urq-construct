﻿unit uSettings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls, Vcl.Grids, Vcl.ValEdit;

type
  VLEEnum = (veNone, veName, veDescr, veVersion, veDateTime, veAuthor, veEmail, veSite);

type
  TfSettings = class(TForm)
    btOK: TBitBtn;
    btCancel: TBitBtn;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Label4: TLabel;
    btSelURQ: TSpeedButton;
    edSelURQ: TEdit;
    OpenDialog: TOpenDialog;
    TabSheet2: TTabSheet;
    SettingsValueListEditor: TValueListEditor;
    Label1: TLabel;
    procedure btSelURQClick(Sender: TObject);
    procedure btOKClick(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadConfig;
    procedure SaveConfig;
  end;

var
  fSettings: TfSettings;

implementation

{$R *.dfm}

uses uUtils, IniFiles, uCommon, uMain;

const
  stURQIntFilters: string = 'Интерпретатор URQ|*.exe';

procedure TfSettings.btCancelClick(Sender: TObject);
begin
  LoadConfig;
end;

procedure TfSettings.btOKClick(Sender: TObject);
begin
  SaveConfig;
  fMain.Modified := True;
end;

procedure TfSettings.btSelURQClick(Sender: TObject);
begin
  // Выбор интерпретатора для запуска квестов
  OpenDialog.Filter := stURQIntFilters;
  if OpenDialog.Execute then
    edSelURQ.Text := Trim(OpenDialog.FileName);
end;

procedure TfSettings.FormCreate(Sender: TObject);
begin
  LoadConfig;
  PageControl1.ActivePageIndex := 0;
end;

procedure TfSettings.LoadConfig;
var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.Create(Utils.GetPath('') + 'config.ini');
  try
    // Интерпретатор
    edSelURQ.Text := IniFile.ReadString('Main', 'URQInt', '').Trim;
  finally
    FreeAndNil(IniFile);
  end;
end;

procedure TfSettings.SaveConfig;
var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.Create(Utils.GetPath('') + 'config.ini');
  try
    // Интерпретатор
    IniFile.WriteString('Main', 'URQInt', edSelURQ.Text.Trim);
  finally
    FreeAndNil(IniFile);
  end;
end;

end.
