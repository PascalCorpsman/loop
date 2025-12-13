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
Unit unit6;

{$MODE objfpc}{$H+}

Interface

Uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin;

Type
  TForm6 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    Label1: TLabel;
    SpinEdit1: TSpinEdit;
    Procedure Button2Click(Sender: TObject);
    Procedure Button1Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  End;

Var
  Form6: TForm6;

Implementation

{$R *.lfm}

Uses Unit1;

Procedure TForm6.Button2Click(Sender: TObject);
Begin
  close;
End;

Procedure TForm6.Button1Click(Sender: TObject);
Begin
  blankPerIdent := form6.SpinEdit1.value;
  RemoveDoubleBlank := form6.CheckBox1.checked;
  Close;
End;

End.

