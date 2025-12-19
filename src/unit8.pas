(******************************************************************************)
(*                                                                            *)
(* Author      : Uwe Schächterle (Corpsman)                                   *)
(*                                                                            *)
(* This file is part of Loop                                                  *)
(*                                                                            *)
(*  See the file license.md, located under:                                   *)
(*  https://github.com/PascalCorpsman/Software_Licenses/blob/main/license.md  *)
(*  for details about the license.                                            *)
(*                                                                            *)
(*               It is not allowed to change or remove this text from any     *)
(*               source file of the project.                                  *)
(*                                                                            *)
(******************************************************************************)
Unit unit8;

{$MODE objfpc}{$H+}

Interface

Uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CheckLst;

Type
  TForm8 = Class(TForm)
    Button1: TButton;
    CheckListBox1: TCheckListBox;
    Label1: TLabel;
    Procedure Button1Click(Sender: TObject);
    Procedure CheckListBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    Procedure FormPaint(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  End;

Var
  Form8: TForm8;

Implementation

Uses ucompiler, Executer, uloop;

{$R *.lfm}

Procedure TForm8.Button1Click(Sender: TObject);
Begin
  Checkforwantedvalues(-1);
  Close;
End;

Procedure TForm8.CheckListBox1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Begin
  CheckListBox1.ItemIndex := CheckListBox1.ItemAtPos(point(x, y), true);
End;

Procedure TForm8.FormPaint(Sender: TObject);
Var
  x: integer;
Begin
  If CheckListBox1.items.count = 0 Then Begin
    For x := 0 To high(CompiledCode.vars) Do Begin
      CheckListBox1.items.Add('Variable [' + inttostr(x + 1) + '] : ' + getuserVarname(CompiledCode.vars[x].Name));
    End;
    CheckListBox1.items.Add('Aktuall Loop count');
  End;
End;

End.

