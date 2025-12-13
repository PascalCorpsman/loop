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
Unit unit5;

{$MODE objfpc}{$H+}

Interface

Uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Executer;

Type

  { TForm5 }

  TForm5 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    GroupBox1: TGroupBox;
    Edit1: TEdit;
    Label1: TLabel;
    ScrollBar1: TScrollBar;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    GroupBox2: TGroupBox;
    Label6: TLabel;
    Edit6: TEdit;
    Button3: TButton;
    GroupBox3: TGroupBox;
    CheckBox1: TCheckBox;
    Procedure Button2Click(Sender: TObject);
    Procedure Button1Click(Sender: TObject);
    Procedure Edit1KeyPress(Sender: TObject; Var Key: Char);
    Procedure Edit1KeyUp(Sender: TObject; Var Key: Word;
      Shift: TShiftState);
    Procedure ScrollBar1Change(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure FormPaint(Sender: TObject);
    Procedure FormClose(Sender: TObject; Var CloseAction: TCloseAction);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  End;

Var
  Form5: TForm5;

Implementation

Uses Compiler, Unit1, unit8;

{$R *.lfm}

Procedure TForm5.Button2Click(Sender: TObject);
Var
  b: Boolean;
Begin
  //  form1.Stop1Click(Nil);
  SetUnknown;
  LoopRechner.clear; // Löschen des Stacks
  AktualDebugLine := -1; // Debugganzeige löschen
  Aktualerrorline := -1; // Löschen der zeile mit dem Aktuellen Fehler
  form1.code.readonly := false; // Schreibrechte wieder erlauben
  form1.code.Repaint; // Neuzeichnen, damit Löschen der Roten Zeilen
  setlength(CompiledCode.vars, 0); // Löschen der Überwachten Variablen damit sie in Controlled nicht mehr gezeigt werden.
  // Löschen der überwachten Ausdrücke
  If form8.CheckListBox1.Items.count <> 0 Then Begin
    b := false;
    If form8.CheckListBox1.Checked[form8.CheckListBox1.items.count - 1] Then b := true;
    form8.CheckListBox1.items.clear;
    form1.Controlled_Varables.Items.clear;
    If B Then form1.AktuallLoopcount1Click(Nil);
  End;
  // Rücksetzen der Statusanzeige
  form1.Caption := 'Loop Intergreter by Uwe Schächterle and Axel Sauer ver. ' + floattostrf(ver, FFFixed, 7, 2);
  form1.code.readonly := false;
  form1.code.Repaint;
  Checkbox1.enabled := true;
  close;
End;

Procedure TForm5.Button1Click(Sender: TObject);
Var
  x: Integer;
  b: Boolean;
Begin
  // Sperren das ein Programm Mehrfach ausgeführt werden kann
  Checkbox1.enabled := false;
  Button1.enabled := false;
  Caption := 'Is running';
  // Rücksetzen der Ausgabe
  Edit6.text := '';
  // Alle Variablen eines Loop Programmes sind zu begin mit 0 Initialisiert
  For x := 0 To high(CompiledCode.vars) Do Begin
    CompiledCode.vars[x].value := 0;
  End;
  // Zuweisen der Übergebenen Varuablen
  For x := 0 To high(CompiledCode.getvars) Do Begin
    CompiledCode.vars[GetVarindex(CompiledCode.getvars[x].name, b)].value := CompiledCode.getvars[x].value;
  End;
  // Erst müssen noch alle Variablen gesetzt werden und dann kann ausgeführt werden.
  TimeVar := Gettickcount;
  startExecute;
End;

Procedure TForm5.Edit1KeyPress(Sender: TObject; Var Key: Char);
Begin
  If Key = #13 Then button1.onclick(Nil);
  If Key = #27 Then close;
  If Not (Key In ['0'..'9', #8]) Then key := #0;
End;

Procedure TForm5.Edit1KeyUp(Sender: TObject; Var Key: Word; Shift: TShiftState);
Var
  x: Integer;
Begin
  // Auslesen des Edit Feldes
  x := strtoint(copy(Tedit(Sender).name, 5, 1)) - 1;
  // Zuweisen der Variable
  CompiledCode.getvars[Scrollbar1.position + x].value := strtointdef(Tedit(Sender).text, 0);
End;

Procedure TForm5.ScrollBar1Change(Sender: TObject);
Var
  x: integer;
Begin
  For x := 1 To 5 Do Begin
    TLabel(findcomponent('Label' + inttostr(x))).Caption :=
      CompiledCode.getvars[Scrollbar1.position + x - 1].Name;
    TEdit(findcomponent('Edit' + inttostr(x))).text := inttostr(
      CompiledCode.getvars[Scrollbar1.position + x - 1].Value);
  End;
End;

Procedure TForm5.Button3Click(Sender: TObject);
Begin
  LoopRechner.clear;
  AktualDebugLine := -1;
  form1.code.readonly := false;
  form1.code.Repaint;
  close;
End;

Procedure TForm5.FormPaint(Sender: TObject);
Begin
  If Edit1.visible Then edit1.SetFocus;
End;

Procedure TForm5.FormClose(Sender: TObject; Var CloseAction: TCloseAction);
Var
  b: Boolean;
Begin
  SetUnknown;
  AktualDebugLine := -1;
  Aktualerrorline := -1;
  setlength(CompiledCode.vars, 0); // Löschen der Überwachten Variablen damit sie in Controlled nicht mehr gezeigt werden.
  // Löschen der überwachten Ausdrücke
  If form8.CheckListBox1.Items.count <> 0 Then Begin
    b := false;
    If form8.CheckListBox1.Checked[form8.CheckListBox1.items.count - 1] Then b := true;
    form8.CheckListBox1.items.clear;
    form1.Controlled_Varables.Items.clear;
    If B Then form1.AktuallLoopcount1Click(Nil);
  End;
  // Rücksetzen der Statusanzeige
  form1.Caption := 'Loop Intergreter by Uwe Schächterle and Axel Sauer ver. ' + floattostrf(ver, FFFixed, 7, 2);
  form1.code.readonly := false;
  form1.code.Repaint;
End;

End.

