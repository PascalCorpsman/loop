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
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
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

  // Liefert den Korrekten Namen der Variable, so wie der User ihn eingegeben hat.
Function getuserVarname(Value: String): String;

Implementation

Uses Compiler, unit1, executer;

{$R *.lfm}

// Diese Function soll dann später wenn der Compiler mal Functionen kann die entsprechenden
// Korrekten Namen rausparsen aber bis dahin macht sie nix.

Function getuserVarname(Value: String): String;
Var
  f, b: String;
Begin
  If Pos('æ', Value) = 0 Then
    result := value
  Else Begin
    f := copy(value, 1, pos('æ', value) - 1);
    b := copy(value, length(f) + 2, length(value));
    //    result := 'Function(' + f + '), Value :' + b;
    If Uppercase(b) = 'RESULT' Then Begin
      result := 'Function ' + f;
    End
    Else Begin
      result := b + ' in (' + f + ')';
    End;
  End;
End;

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

