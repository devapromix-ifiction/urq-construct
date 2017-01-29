unit uRoom;

interface

uses Windows, Classes, Dialogs, Graphics, Forms, Controls, StdCtrls, CheckLst,
  ComCtrls, ToolWin, ImgList, Menus, ActnList;

type
  TfRoom = class(TForm)
    Memo1: TMemo;
    CLB: TCheckListBox;
    ToolBar1: TToolBar;
    btGoto: TToolButton;
    btProc: TToolButton;
    btCLS: TToolButton;
    btClose: TToolButton;
    ToolButton4: TToolButton;
    btCLSB: TToolButton;
    ToolButton1: TToolButton;
    ToolButton6: TToolButton;
    btPrint: TToolButton;
    btPrintLine: TToolButton;
    ToolButton9: TToolButton;
    btButton: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ButsImages: TImageList;
    PM: TPopupMenu;
    ActionList1: TActionList;
    acDelete: TAction;
    N1: TMenuItem;
    btInvKill: TToolButton;
    btPerKill: TToolButton;
    acGoto: TAction;
    acProc: TAction;
    acCLS: TAction;
    acCLSB: TAction;
    acInvKill: TAction;
    acPerKill: TAction;
    acBtn: TAction;
    acPrint: TAction;
    acPrintLn: TAction;
    acClear: TAction;
    N2: TMenuItem;
    N3: TMenuItem;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    acExpression: TAction;
    acStartBlock: TAction;
    acFinishBlock: TAction;
    ToolButton5: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btCloseClick(Sender: TObject);
    procedure ToolButton12Click(Sender: TObject);
    procedure ToolButton14Click(Sender: TObject);
    procedure acDeleteUpdate(Sender: TObject);
    procedure acDeleteExecute(Sender: TObject);
    procedure CLBDblClick(Sender: TObject);
    procedure acOpGrAExecute(Sender: TObject);
    procedure acOpGrBExecute(Sender: TObject);
    procedure acOpGrCExecute(Sender: TObject);
    procedure acOpGrDExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CLBClickCheck(Sender: TObject);
    procedure acClearExecute(Sender: TObject);
    procedure acClearUpdate(Sender: TObject);
    procedure acOpGrEExecute(Sender: TObject);
  private
    { Private declarations }
    SL: TStringList;
    FCurrent: Integer;
    procedure AddOpGrA(const N: Integer);
    procedure AddOpGrB(const N: Integer; I: Integer = -1; P: string = '');
    procedure AddOpGrC(const N: Integer; I: Integer = -1; P: string = ''; E: string = '');
    procedure AddOpGrD(const N: Integer; I: Integer = -1; P: string = '');
    procedure AddOpGrE(const N: Integer; I: Integer = -1; P: string = '');
    procedure AddVar(I: Integer = -1);
    procedure AddItem(I: Integer = -1);
  public
    { Public declarations }
    procedure LoadCLB(const Index: Integer);
    procedure SaveCLB(const Index: Integer);
    property Current: Integer read FCurrent write FCurrent;
  end;

const
  // ��������� �� �������
  OpGrA: array [0..5] of string = ('cls', 'clsb', 'invkill', 'perkill', 'startblock', 'finishblock');
  OpGrB: array [0..1] of string = ('goto', 'proc');
  OpGrC: array [0..0] of string = ('btn');
  OpGrD: array [0..1] of string = ('pln', 'p');
  OpGrE: array [0..0] of string = ('if');

implementation

uses SysUtils, Math, uMain, uSelRoom, uSelText, uSelVar, uSelItem, uCommon;

{$R *.dfm}  

procedure TfRoom.LoadCLB(const Index: Integer);
var
  I: Integer;
  S: string;
  B: Char;
begin
  SL.Clear;
  SL := ExplodeString('|', fMain.QL[Index]);
  CLB.Clear;
  for I := 0 to SL.Count - 1 do
  begin
    S := Trim(SL[I]);
    B := S[1];
    Delete(S, 1, 1);
    CLB.Items.Append(S);
    CLB.Checked[I] := (B = '1');
  end;
end;

procedure TfRoom.SaveCLB(const Index: Integer);
var
  S, D: string;
  I: Integer;
  C: Char;
begin
  S := '';
  for I := 0 to CLB.Count - 1 do
  begin
    D := IfThen((I <> CLB.Count - 1), '|', '');
    C := IfThen(CLB.Checked[I], '1', '0');
    S := S + C + CLB.Items.Strings[I] + D;
  end;
  with fMain do
  begin
    QL[Index] := S;
    Modified := True;
  end;  
end;

procedure TfRoom.AddOpGrA(const N: Integer);
begin
  // ��������� ��� ����������
  CLB.Checked[CLB.Items.Add(OpGrA[N])] := True; 
  SaveCLB(Current);
end;

procedure TfRoom.AddOpGrB(const N: Integer; I: Integer = -1; P: string = '');
var
  S, Op: string;
begin
  // ���������, � ������� �������� - ����� �������
  Op := OpGrB[N];
  S := fSelRoom.GetRoom(Self.Caption, P);
  if (S = '') then Exit;
  S := Format('%s %s', [Op, S]);
  if (I >= 0) then CLB.Items[I] := S
    else I := CLB.Items.Add(S);
  CLB.Checked[I] := True;
  SaveCLB(Current);
end;

procedure TfRoom.AddOpGrC(const N: Integer; I: Integer = -1; P: string = ''; E: string = '');
var
  S, T, Op: string;
begin
  // ���������, �������������� ������� � ������� �� �������
  Op := OpGrC[N];
  S := fSelRoom.GetRoom(Self.Caption, P);
  if (S = '') then Exit;
  T := fSelText.GetText(E);
  if (T = '') then Exit;
  S := Format('%s %s, %s', [Op, S, T]);
  if (I >= 0) then CLB.Items[I] := S
    else I := CLB.Items.Add(S);
  CLB.Checked[I] := True;
  SaveCLB(Current);
end;

procedure TfRoom.AddOpGrD(const N: Integer; I: Integer = -1; P: string = '');
var
  S, Op: string;
begin
  // ��������� ������ ������
  Op := OpGrD[N];
  S := fSelText.GetText(P);
  if (S = '') then Exit;
  S := Format('%s %s', [Op, S]);
  if (I >= 0) then CLB.Items[I] := S
    else I := CLB.Items.Add(S);
  CLB.Checked[I] := True;
  SaveCLB(Current);
end;

procedure TfRoom.AddOpGrE(const N: Integer; I: Integer; P: string);
var
  S, Op: string;
begin
  Op := OpGrE[N];
  S := fSelText.GetText(P);
  if (S = '') then Exit;
  S := Format('%s %s', [Op, S]);
  if (I >= 0) then CLB.Items[I] := S
    else I := CLB.Items.Add(S);
  CLB.Checked[I] := True;
  SaveCLB(Current);
  // �������. �������� ������ �����
  if (Op = 'if') then AddOpGrA(4);
end;

procedure TfRoom.AddVar(I: Integer = -1);
var
  VarName, Value, S: string;
begin
  // �������� ����������
  fSelVar.GetVar(VarName, Value);
  if (VarName = '') then Exit;
  if (fSelVar.VarType.ItemIndex = 0) then
    S := Format('%s = %s', [VarName, Value])
      else S := Format('%s = "%s"', [VarName, Value]);
  if (I >= 0) then CLB.Items[I] := S
    else I := CLB.Items.Add(S);
  CLB.Checked[I] := True;
  SaveCLB(Current);
end;

procedure TfRoom.AddItem(I: Integer = -1);
var
  ItemName, SAmount, S: string;
  Amount: Integer;
begin
  // �������� ��� ������� �������
  SAmount := '';
  fSelItem.GetItem(ItemName, Amount);
  if (ItemName = '') then Exit;
  if (Amount <= 0) then Amount := 1;
  if (Amount > 1) then SAmount := Format('%d, ', [Amount]);
  if (fSelItem.Switch.ItemIndex = 0) then
    S := Format('inv+ %s%s', [SAmount, ItemName])
      else S := Format('inv- %s%s', [SAmount, ItemName]);
  if (I >= 0) then CLB.Items[I] := S
    else I := CLB.Items.Add(S);
  CLB.Checked[I] := True;
  SaveCLB(Current);
end;

procedure TfRoom.acDeleteExecute(Sender: TObject);
begin
  // ������� ������� ������� �� ������
  if (CLB.ItemIndex >= 0)
    and (MsgDlg('�������?', mtConfirmation, [mbOk, mbCancel]) = mrOk) then
    begin
      CLB.Items.Delete(CLB.ItemIndex);
      SaveCLB(Current);
    end;
end;

procedure TfRoom.acClearExecute(Sender: TObject);
begin
  // ��������
  if (MsgDlg('������� ���?', mtConfirmation, [mbOk, mbCancel]) = mrOk) then
  begin
    CLB.Clear;
    SaveCLB(Current);
  end;
end;

procedure TfRoom.CLBClickCheck(Sender: TObject);
begin
  Self.SaveCLB(Current);
end;

procedure TfRoom.CLBDblClick(Sender: TObject);
var
  I, J, K, Index: Integer;
  S, T: string;
begin
  Index := CLB.ItemIndex;
  if (Index < 0) then Exit;
  S := Trim(CLB.Items[Index]);
  // ������ B
  for I := 0 to High(OpGrB) do
    if (Copy(S, 1, Length(OpGrB[I])) = OpGrB[I]) then
    begin
      J := Length(OpGrB[I]) + 1;
      AddOpGrB(I, Index, Trim(Copy(S, J, Length(S))));
      Exit;
    end;
  // ������ C
  for I := 0 to High(OpGrC) do
    if (Copy(S, 1, Length(OpGrC[I])) = OpGrC[I]) then
    begin
      J := Length(OpGrC[I]) + 1;
      K := Pos(',', S);
      AddOpGrC(I, Index,
      Trim(Copy(S, J, K - J)),
      Trim(Copy(S, K + 1, Length(S))));
      Exit;
    end;
  // ������ D
  for I := 0 to High(OpGrD) do
    if (Copy(S, 1, Length(OpGrD[I])) = OpGrD[I]) then
    begin
      J := Length(OpGrD[I]) + 1;
      AddOpGrD(I, Index, Trim(Copy(S, J, Length(S))));
      Exit;
    end;
  // ������ E
  for I := 0 to High(OpGrE) do
    if (Copy(S, 1, Length(OpGrE[I])) = OpGrE[I]) then
    begin
      J := Length(OpGrE[I]) + 1;
      AddOpGrE(I, Index, Trim(Copy(S, J, Length(S))));
      Exit;
    end;
  // �������
  T := Copy(S, 1, 4);
  if (T = 'inv+') or (T = 'inv-') then
  begin
    case T[4] of
      '+': fSelItem.Switch.ItemIndex := 0;
      '-': fSelItem.Switch.ItemIndex := 1;
    end;
    K := 1;
    if (Pos(',', S) > 0) then
    begin
      SL.Clear;
      SL := ExplodeString(',', Trim(Copy(S, 5, Length(S))));
      T := Trim(SL[1]);
      K := StrToIntDef(SL[0], 1);
    end else T := Trim(Copy(S, 5, Length(S)));
    //
    fSelItem.edItem.Text := T;
    fSelItem.UpDn.Position := K;
    AddItem(Index);
    Exit;
  end;
  // ����������
  begin
    SL.Clear;
    SL := ExplodeString('=', S);
    fSelVar.VarType.ItemIndex := IfThen((Pos('"', S) > 0), 1, 0);
    S := '';
    if (SL.Count > 1) then
      S := StringReplace(Trim(SL[1]), '"', '', [rfReplaceAll]);
    fSelVar.edVar.Text := Trim(SL[0]);
    fSelVar.edValue.Text := S;
    AddVar(Index);
    Exit;
  end;
end;

procedure TfRoom.FormCreate(Sender: TObject);
begin
  SL := TStringList.Create;
  Current := 0;
end;

procedure TfRoom.FormDestroy(Sender: TObject);
begin
  SL.Free;
end;

procedure TfRoom.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfRoom.acDeleteUpdate(Sender: TObject);
begin
  acDelete.Enabled := (CLB.Count > 0) and (CLB.ItemIndex >= 0);
end;

procedure TfRoom.acOpGrAExecute(Sender: TObject);
begin
  //
  AddOpGrA((Sender as TAction).Tag);
end;

procedure TfRoom.acOpGrBExecute(Sender: TObject);
begin
  //
  AddOpGrB((Sender as TAction).Tag);
end;

procedure TfRoom.acOpGrCExecute(Sender: TObject);
begin
  //
  AddOpGrC((Sender as TAction).Tag);
end;

procedure TfRoom.acOpGrDExecute(Sender: TObject);
begin
  //
  AddOpGrD((Sender as TAction).Tag);
end;

procedure TfRoom.acOpGrEExecute(Sender: TObject);
begin
  //
  AddOpGrE((Sender as TAction).Tag);
end;

procedure TfRoom.btCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfRoom.ToolButton12Click(Sender: TObject);
begin
  AddVar();
end;

procedure TfRoom.ToolButton14Click(Sender: TObject);
begin
  AddItem();
end;

procedure TfRoom.acClearUpdate(Sender: TObject);
begin
  acClear.Enabled := (CLB.Count > 0);
end;

end.
