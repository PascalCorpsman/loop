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
Unit unit4;

{$MODE objfpc}{$H+}

Interface

Uses
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

Type
  TForm4 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Edit1: TEdit;
    Procedure Button1Click(Sender: TObject);
    Procedure Button2Click(Sender: TObject);
    Procedure Edit1KeyPress(Sender: TObject; Var Key: Char);
    Procedure FormPaint(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  End;

Var
  Form4: TForm4;

Implementation

Uses Unit1;

{$R *.lfm}

Procedure TForm4.Button1Click(Sender: TObject);
Var
  Canclose: boolean;
Begin
  Canclose := true;
  // Es mus einen Namen geben
  If Length(edit1.text) = 0 Then Canclose := false;
  // Das Erste Zeichen des Procedur namens des Programmes darf keine Zahl sein !!
  If canclose Then
    If Edit1.text[1] In ['0'..'9'] Then canclose := false;
  If canclose Then Begin
    AktualFilename := '';
    // Erzeugen eines Vcorgefertigten Anfang Quelltextes
    form1.code.clear;
    form1.code.lines.add('Procedure ' + edit1.text + ';');
    form1.code.lines.add('Begin');
    form1.code.lines.add('End;');
    form1.StatusBar1.Panels[2].Text := '';
    Close;
  End
  Else
    showmessage('You entered a invalid projekt name');
End;

Procedure TForm4.Button2Click(Sender: TObject);
Begin
  close;
End;

Procedure TForm4.Edit1KeyPress(Sender: TObject; Var Key: Char);
Begin
  If Key = #13 Then Begin
    button1.onclick(Nil);
    key := #0;
  End;
  If Not (Key In ['a'..'z', 'A'..'Z', '0'..'9', '_', #8]) Then key := #0;
End;

Procedure TForm4.FormPaint(Sender: TObject);
Begin
  edit1.setfocus;
End;

End.

