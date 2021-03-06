﻿unit uCommon;

interface

uses Forms, Dialogs, Classes, ComCtrls, Vcl.Controls;

const
  // Версия конструктора
  Version = '0.1.0';

const
  // Расширение ini-файла проекта (QCPROJ = QuestConstructPROJect)
  QCProjExt = 'qcproj';

var
  stProjectExists: string = 'Проект %s существует! Перезаписать?';
  stCheckModified: string = 'Проект изменен! Отбросить изменения и продолжить?';
  stProjFilters: string = 'Проект %s|*.%s|Все файлы (*.*)|*.*';

const
  RoomsName = 'Комнаты';
  ItemsName = 'Предметы';
  VarsName = 'Переменные';
  RoomDefaultName = 'room';
  RoomDefaultCaption = 'Комната';

type
  // Типы ресурсов
  TResType = (rtRoom, rtItem, rtVar);

var
  // Фильтр
  QCProjFilters: string = '';

const
  // Стр. комментарий в URQL
  StCom = ';';
  // Разделитель операторов URQL
  OpDiv = '&';
  //
  TkDiv = '|';
  // Запрещенные имена для комнат, предметов и переменных
  ErNames: array [0 .. 2] of string = ('settings', 'items', 'variables');
  // Запрещенные символы для комнат, предметов и переменных
  ErChars: array [0 .. 1] of Char = (OpDiv, TkDiv);

type
  TCaptionHelper = record helper for TCaption
    function Trim: string;
    function ToLower: string;
  end;

type
  Common = class(TObject)
    class function MsgDlg(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: Integer = 0): Integer;
    class procedure SetTVImages(const TreeNode: TTreeNode; const ImgIndex, SelIndex: Integer);
    class procedure SetTV(const TV: TTreeView; Title: string; ImageIndex: Integer);
    class function AddTVItem(const TV: TTreeView; const Title: string; const ImageIndex, SelectedIndex: Integer): TTreeNode;
    class procedure GetResource(var SL: TStringList; const RT: TResType; Current: string = '');
    // procedure AddResource(const RT: TResType; AName: string); AddItem, AddVar, и массив, дин. добавл. TV
    class function GetRoomIndexByName(const AName: string): Integer;
    class function IfThen(AValue: Boolean; const ATrue: string; const AFalse: string): string; overload;
    class function IfThen(AValue: Boolean; const ATrue: Char; const AFalse: Char): Char; overload;
    class function IsErName(const S: string): Boolean;
    class function IsErChar(const S: string): Boolean;
    class function IsFirstCharDigit(const S: string): Boolean;
  end;

implementation

uses SysUtils, uMain, uUtils, Vcl.Graphics, System.Character;

{ // Проверка на запрещённые символы
  function CheckSymbols(Input: string): Boolean; inline;
  var
  C: Char;
  begin
  Result := False;
  for C in Input do
  if CharInSet(C, ['/', '\', ':', '?', '|', '*', '"', '<', '>', ' '])
  then
  Exit(True);
  end;

  // Добавление в список
  procedure AddPlayer(const Login: string);
  var
  PlayersCount: LongWord;
  I: LongWord;
  begin
  PlayersCount := Length(Players);

  // Проверяем, нет ли игрока в списке:
  if PlayersCount > 0 then
  for I := 0 to PlayersCount - 1 do
  if Players[I].Name = Login then
  Exit;
  SetLength(Players, PlayersCount + 1);
  Players[PlayersCount].Name := Login;
  end;

  // Удаление из списка
  procedure RemovePlayer(const Login: string);
  var
  PlayersCount: LongWord;
  I: LongWord;
  begin
  PlayersCount := Length(Players);
  for I := 0 to PlayersCount - 1 do
  begin
  if Players[I].Name = Login then
  begin
  Players[I] := Players[PlayersCount - 1];
  SetLength(Players, PlayersCount - 1);
  Break;
  end;
  end;
  end;

  // Сущ. ли игрок в списке
  function IsPlayerInList(const Player: string): Boolean;
  var
  PlayersCount: LongWord;
  I: LongWord;
  begin
  Result := False;
  PlayersCount := Length(Players);
  if PlayersCount > 0 then
  for I := 0 to PlayersCount - 1 do
  begin
  if Players[I].Name = Player then
  begin
  Result := True;
  Exit;
  end;
  end;
  end; }

function GetColor(const Color: TColor): Integer;
var
  RGBColor: Integer;
begin
  RGBColor := ColorToRGB(Color);
  Result := (RGBColor shr 16) OR (((RGBColor AND $FFFF) shr 8) shl 8) OR ((RGBColor AND $FF) shl 16);
end;

class function Common.MsgDlg(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: Integer = 0): Integer;
begin
  Result := Utils.ShowForm(CreateMessageDialog(Msg, DlgType, Buttons));
end;

class procedure Common.SetTVImages(const TreeNode: TTreeNode; const ImgIndex, SelIndex: Integer);
begin
  TreeNode.ImageIndex := ImgIndex;
  TreeNode.SelectedIndex := SelIndex;
end;

class procedure Common.SetTV(const TV: TTreeView; Title: string; ImageIndex: Integer);
var
  TreeNode: TTreeNode;
begin
  TV.Items.Clear;
  TreeNode := TV.Items.AddFirst(nil, Title);
  SetTVImages(TreeNode, ImageIndex, ImageIndex);
end;

class function Common.AddTVItem(const TV: TTreeView; const Title: string; const ImageIndex, SelectedIndex: Integer): TTreeNode;
begin
  Result := TV.Items.AddChild(TV.Items.Item[0], Title);
  SetTVImages(Result, ImageIndex, SelectedIndex);
end;

class procedure Common.GetResource(var SL: TStringList; const RT: TResType; Current: string = '');
var
  TV: TTreeView;
  Name, S: string;
  I: Integer;

  procedure Add(ATV: TTreeView; AName: string);
  begin
    TV := ATV;
    Name := AName;
  end;

begin
  TV := nil;
  case RT of
    rtRoom: // Комната
      Add(fMain.TVR, RoomsName);
    rtItem: // Предмет
      Add(fMain.TVI, ItemsName);
    rtVar: // Переменная
      Add(fMain.TVV, VarsName);
  end;
  SL.Clear;
  for I := 0 to TV.Items.Count - 1 do
  begin
    S := TV.Items[I].Text.ToLower;
    if (S <> Name.ToLower) and (S <> Current.ToLower) then
      SL.Append(S);
  end;
end;

class function Common.GetRoomIndexByName(const AName: string): Integer;
var
  S: string;
  I: Integer;
begin
  Result := -1;
  for I := 0 to fMain.TVR.Items.Count - 1 do
  begin
    S := fMain.TVR.Items[I].Text.ToLower;
    if (S <> RoomsName) then
      if (S = AName) then
        Exit(I);
  end;
end;

class function Common.IfThen(AValue: Boolean; const ATrue: string; const AFalse: string): string;
begin
  if AValue then
    Result := ATrue
  else
    Result := AFalse;
end;

class function Common.IfThen(AValue: Boolean; const ATrue: Char; const AFalse: Char): Char;
begin
  if AValue then
    Result := ATrue
  else
    Result := AFalse;
end;

class function Common.IsErName(const S: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to High(ErNames) do
    if (S = ErNames[I]) then
      Exit(True);
end;

class function Common.IsErChar(const S: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to High(ErChars) do
    if (S.CountChar(ErChars[I]) > 0) then
      Exit(True);
end;

class function Common.IsFirstCharDigit(const S: string): Boolean;
var
  C: Char;
begin
  C := S[1];
  Result := C.IsDigit;
end;

{ TCaptionHelper }

function TCaptionHelper.ToLower: string;
begin
  Result := string(Self).ToLower;
end;

function TCaptionHelper.Trim: string;
begin
  Result := string(Self).Trim;
end;

end.
