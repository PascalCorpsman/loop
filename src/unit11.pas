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
Unit unit11;

{$MODE objfpc}{$H+}

Interface

Uses
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Printers;

Type
  TForm11 = Class(TForm)
    CheckBox1: TCheckBox;
    Label1: TLabel;
    ComboBox1: TComboBox;
    Button1: TButton;
    Button2: TButton;
    FontDialog1: TFontDialog;
    GroupBox1: TGroupBox;
    Button3: TButton;
    Edit1: TEdit;
    Label3: TLabel;
    Label2: TLabel;
    Edit2: TEdit;
    Label4: TLabel;
    Edit3: TEdit;
    Procedure Button2Click(Sender: TObject);
    Procedure Button1Click(Sender: TObject);
    Procedure ComboBox1KeyPress(Sender: TObject; Var Key: Char);
    Procedure Edit1KeyPress(Sender: TObject; Var Key: Char);
    Procedure Button3Click(Sender: TObject);
    Procedure Edit1Change(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  End;

Var
  Form11: TForm11;
  PrintFont: Tfont;

Function FontstyletoString(data: Tfontstyles): String;
Function getFontstylefromstring(Data: String): Tfontstyles;

Implementation

{$R *.lfm}

Uses unit1;

Function FontstyletoString(data: Tfontstyles): String;
Var
  erg: String;
Begin
  erg := '';
  If fsBold In data Then erg := 'Bold';
  If fsItalic In data Then Begin
    If Length(Erg) = 0 Then
      erg := 'Italic'
    Else
      erg := erg + ', Italic';
  End;
  If fsUnderline In data Then Begin
    If Length(Erg) = 0 Then
      erg := 'Underline'
    Else
      erg := erg + ', Underline';
  End;
  If fsStrikeout In data Then Begin
    If Length(Erg) = 0 Then
      erg := 'Strikeout'
    Else
      erg := erg + ', Strikeout';
  End;
  If length(erg) = 0 Then
    erg := 'Standard';
  result := erg;
End;

Function getFontstylefromstring(Data: String): Tfontstyles;
Var
  erg: Tfontstyles;
Begin
  erg := [];
  If Pos('Bold', data) <> 0 Then include(erg, fsbold);
  If Pos('Italic', data) <> 0 Then include(erg, fsItalic);
  If Pos('Underline', data) <> 0 Then include(erg, fsUnderline);
  If Pos('Strikeout', data) <> 0 Then include(erg, fsStrikeout);
  result := Erg;
End;

Procedure TForm11.Button2Click(Sender: TObject);
Begin
  close;
End;

Procedure TForm11.Button1Click(Sender: TObject);
  Function Checkstring(Value: String): String;
  Var
    erg: String;
    x: integer;
  Begin
    erg := '';
    For x := 1 To length(value) Do
      If Value[x] In allowedchars Then erg := erg + Value[x];
    result := erg;
  End;
Var
  P: TPrinter;
  s: Tstringlist;
  cmh, cmw, x, t, h: Integer;
  l, lt: String;
Begin
  s := Tstringlist.create;
  s.clear;
  If checkbox1.Checked Then Begin
    If Length(form1.code.seltext) <> 0 Then
      s.add(form1.code.seltext);
  End
  Else
    s.AddStrings(form1.code.Lines);
  If s.count <> 0 Then Begin
    p := TPrinter.create;
    p.PrinterIndex := form11.combobox1.ItemIndex;
    // Einstellen Hochformat
    p.Orientation := poPortrait;
    cmh := round(p.PageHeight / 29.7); // Die Anzahl der Pixel bestimmen die einer Höhe von 1 cm entspricht !!
    cmw := round(p.PageHeight / 21); // Die Anzahl der Pixel bestimmen die einer Breite von 1 cm entsprechen !!
    // Name des Druckauftrages
    p.Title := 'Loopcompiler ver. : ' + floattostrf(ver, FFFixed, 7, 2);
    P.BeginDoc;
    p.canvas.Font.size := Printfont.size;
    p.canvas.Font.Name := Printfont.name;
    p.canvas.Font.Style := Printfont.Style;
    h := p.canvas.TextHeight('Loop Compiler');
    t := cmh;
    For x := 0 To s.count - 1 Do Begin
      l := Checkstring(s[x]);
      // Ist der Text Breiter als die Seite mus er umgebrichen werden.
      If p.canvas.TextWidth(l) > p.PageWidth - (cmw) Then Begin
        While length(l) <> 0 Do Begin
          lt := '';
          While (p.canvas.TextWidth(lt) < p.PageWidth - (2 * cmw)) And (length(l) <> 0) Do Begin
            lt := lt + l[1];
            delete(l, 1, 1);
          End;
          If (p.canvas.TextWidth(lt) >= p.PageWidth - (2 * cmw)) Then Begin
            l := lt[length(lt)] + l;
            delete(lt, length(lt), 1);
          End;
          p.canvas.TextOut(cmh, t, lt);
          inc(t, h);
          If T > p.PageHeight - (2 * cmh) Then Begin
            t := cmh;
            p.NewPage;
          End;
        End;
      End
      Else Begin
        p.canvas.TextOut(cmw, t, l);
        inc(t, h);
        If T > p.PageHeight - (2 * cmh) Then Begin
          t := cmh;
          p.NewPage;
        End;
      End;
    End;
    // Druckauftrag beenden
    p.EndDoc;
    close;
  End
  Else
    showmessage('Nothing to Print');
End;

Procedure TForm11.ComboBox1KeyPress(Sender: TObject; Var Key: Char);
Begin
  // Realisieren eines ReadOnly = True;
  key := #0;
End;

Procedure TForm11.Edit1KeyPress(Sender: TObject; Var Key: Char);
Begin
  // Sperren aller Tasten auser der Zahlen
  If Not (Key In ['0'..'9', #8]) Then Key := #0;
End;

Procedure TForm11.Button3Click(Sender: TObject);
Begin
  Fontdialog1.Font.size := printfont.size;
  Fontdialog1.Font.name := printfont.name;
  Fontdialog1.Font.style := printfont.style;
  If Fontdialog1.execute Then Begin
    printfont.size := Fontdialog1.Font.size;
    printfont.name := Fontdialog1.Font.name;
    printfont.style := Fontdialog1.Font.Style;
    form11.edit1.text := inttostr(Printfont.Size);
    form11.edit2.text := Printfont.Name;
    form11.edit3.text := FontstyletoString(Printfont.Style);
  End;
End;

Procedure TForm11.Edit1Change(Sender: TObject);
Begin
  Printfont.Size := strtointdef(edit1.text, Printfont.Size);
End;

End.

