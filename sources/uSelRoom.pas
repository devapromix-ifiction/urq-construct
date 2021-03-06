﻿unit uSelRoom;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TfSelRoom = class(TForm)
    RoomList: TListBox;
    btOK: TBitBtn;
    btCancel: TBitBtn;
    Label1: TLabel;
    btNew: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure btNewClick(Sender: TObject);
  private
    { Private declarations }
    FIndex: Integer;
  public
    { Public declarations }
    function GetRoom(const CurrentRoom: string; SelRoom: string = ''): string;
  end;

var
  fSelRoom: TfSelRoom;

implementation

uses uMain, uAddRoom, uCommon, uUtils;

{$R *.dfm}
{ TfSelRoom }

function TfSelRoom.GetRoom(const CurrentRoom: string; SelRoom: string = ''): string;
var
  I: Integer;
  SL: TStringList;
begin
  FIndex := 0;
  Result := '';
  SL := TStringList.Create;
  try
    Common.GetResource(SL, rtRoom, CurrentRoom);
    RoomList.Items.Assign(SL);
  finally
    FreeAndNil(SL);
  end;
  I := RoomList.Items.IndexOf('common');
  if (I >= 0) then
    RoomList.Items.Delete(I);
  SelRoom := SelRoom.Trim;
  if (SelRoom <> '') then
    FIndex := RoomList.Items.IndexOf(SelRoom);
  if (FIndex < 0) then
    FIndex := 0;
  if (Utils.ShowForm(Self) = mrCancel) or (RoomList.ItemIndex < 0) then
    Exit;
  Result := RoomList.Items.Strings[RoomList.ItemIndex].Trim;
end;

procedure TfSelRoom.FormShow(Sender: TObject);
begin
  Self.RoomList.ItemIndex := FIndex;
  Self.RoomList.SetFocus;
end;

procedure TfSelRoom.btNewClick(Sender: TObject);
begin
  // Добавить новую комнату
  Self.RoomList.ItemIndex := Self.RoomList.Items.Add(fAddRoom.NewRoom);
  Self.btOK.SetFocus();
end;

end.
