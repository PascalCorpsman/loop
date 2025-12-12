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
Unit unit9;

{$MODE objfpc}{$H+}

Interface

Uses
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, SynEditMiscClasses, SynEditSearch;

Type
  TForm9 = Class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    GroupBox1: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    GroupBox2: TGroupBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    GroupBox3: TGroupBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    GroupBox4: TGroupBox;
    CheckBox9: TCheckBox;
    CheckBox10: TCheckBox;
    Procedure Button3Click(Sender: TObject);
    Procedure FormPaint(Sender: TObject);
    Procedure ComboBox2KeyPress(Sender: TObject; Var Key: Char);
    Procedure Button2Click(Sender: TObject);
    Procedure Button1Click(Sender: TObject);
    Procedure CheckBox8Click(Sender: TObject);
    Procedure CheckBox7Click(Sender: TObject);
    Procedure CheckBox9Click(Sender: TObject);
    Procedure CheckBox10Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  End;

Var
  Form9: TForm9;

Implementation

{$R *.lfm}

Uses Unit1, SynEditTypes;

// prüft ob das wort Text bereits in den Items enthalten ist , wenn Ja dann True

Function isdoubletext(Text: String; Items: Tstrings): Boolean;
Var
  erg: Boolean;
  x: Integer;
Begin
  erg := false;
  For x := 0 To items.count - 1 Do
    If comparestr(text, items[x]) = 0 Then erg := true;
  result := erg;
End;

Procedure TForm9.Button3Click(Sender: TObject);
Begin
  close;
End;

Procedure TForm9.FormPaint(Sender: TObject);
Begin
  Combobox1.SetFocus;
End;

Procedure TForm9.ComboBox2KeyPress(Sender: TObject; Var Key: Char);
Begin
  If Key = #13 Then Button1.onclick(Nil);
  If Key = #27 Then close;
  If Key = #8 Then exit;
  // Es dürfen natürlich nur alle erlaubten Zeichen eingegeben werden.
  If Not (key In allowedchars) Then key := #0;
End;

Procedure TForm9.Button2Click(Sender: TObject);
Var
  options: TSynSearchOptions;
Begin
  // ist eines der Suchwörter Leer dann Abbruch
  If (Length(ComboBox1.text) = 0) Or (Length(ComboBox2.text) = 0) Then close;
  // Wenn wir uns die Suchen ersetzen Wörter noch nicht gemerkt haben dann tun wir es jetzt
  If Not isdoubletext(ComboBox1.Text, ComboBox1.Items) Then
    ComboBox1.Items.add(ComboBox1.text);
  If Not isdoubletext(ComboBox2.Text, ComboBox2.Items) Then
    ComboBox2.Items.add(ComboBox2.text);
  options := [];
  Include(Options, ssoReplaceAll); // Alle Vorkommen ersetzen
  If CheckBox10.checked Then Begin // der Unterschied zwischen ExCursor und From beginning
    If checkbox7.checked Then Begin
      If form1.code.Selstart <> form1.code.selend Then
        form1.code.CaretY := form1.code.SelStart
      Else
        form1.code.CaretY := 0;
    End
    Else Begin
      If form1.code.Selstart <> form1.code.selend Then
        form1.code.CaretY := form1.code.SelEnd
      Else
        form1.code.CaretY := form1.Code.lines.count - 1;
    End;
  End;
  If checkbox2.checked Then Include(Options, ssoSelectedOnly); // Nur das Selectierte !!
  If checkbox3.checked Then Include(Options, ssoMatchCase); // Groß Kleinschreibung
  If checkbox4.checked Then Include(Options, ssoWholeWord); // nur ganze wörter ,was auch immer das ist ?
  If Checkbox8.checked Then Include(Options, ssoBackwards); // Das es auch Rückwärts geht
  Form1.Code.SearchReplace(combobox1.text, combobox2.text, options);
  close;
End;

Procedure TForm9.Button1Click(Sender: TObject);
Var
  options: TSynSearchOptions;
Begin
  // ist eines der Suchwörter Leer dann Abbruch
  If (Length(ComboBox1.text) = 0) Or (Length(ComboBox2.text) = 0) Then Close;
  // Wenn wir uns die Suchen ersetzen Wörter noch nicht gemerkt haben dann tun wir es jetzt
  If Not isdoubletext(ComboBox1.Text, ComboBox1.Items) Then
    ComboBox1.Items.add(ComboBox1.text);
  If Not isdoubletext(ComboBox2.Text, ComboBox2.Items) Then
    ComboBox2.Items.add(ComboBox2.text);
  options := [];
  Include(Options, ssoReplace); // Nur ein mal ersetzen
  If CheckBox10.checked Then Begin // der Unterschied zwischen ExCursor und From beginning
    If checkbox7.checked Then Begin
      If form1.code.Selstart <> form1.code.selend Then
        form1.code.CaretY := form1.code.SelStart
      Else
        form1.code.CaretY := 0;
    End
    Else Begin
      If form1.code.Selstart <> form1.code.selend Then
        form1.code.CaretY := form1.code.SelEnd
      Else
        form1.code.CaretY := form1.Code.lines.count - 1;
    End;
  End;
  //   Übernehmen der Texte in die Liste der Combobox , aber nicht doppelt !!
  If checkbox2.checked Then Include(Options, ssoSelectedOnly); // Nur das Selectierte !!
  If checkbox3.checked Then Include(Options, ssoMatchCase); // Groß Kleinschreibung
  If checkbox4.checked Then Include(Options, ssoWholeWord); // nur ganze wörter ,was auch immer das ist ?
  If Checkbox8.checked Then Include(Options, ssoBackwards); // Das es auch Rückwärts geht
  form1.code.SearchReplace(combobox1.text, combobox2.text, options);
  Close;
End;

Procedure TForm9.CheckBox8Click(Sender: TObject);
Begin
  checkbox7.checked := Not Checkbox8.checked;
End;

Procedure TForm9.CheckBox7Click(Sender: TObject);
Begin
  checkbox8.checked := Not Checkbox7.checked;
End;

Procedure TForm9.CheckBox9Click(Sender: TObject);
Begin
  checkbox10.checked := Not Checkbox9.checked;
End;

Procedure TForm9.CheckBox10Click(Sender: TObject);
Begin
  checkbox9.checked := Not Checkbox10.checked;
End;

End.

