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
Unit unit2;

{$MODE objfpc}{$H+}

Interface

Uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

Type

  { TForm2 }

  TForm2 = Class(TForm)
    Button1: TButton;
    Button2: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    ComboBox1: TComboBox;
    CheckBox1: TCheckBox;
    GroupBox2: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Button3: TButton;
    FontDialog1: TFontDialog;
    Label5: TLabel;
    Edit4: TEdit;
    Procedure ComboBox1Change(Sender: TObject);
    Procedure FormPaint(Sender: TObject);
    Procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; Var Handled: Boolean);
    Procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; Var Handled: Boolean);
    Procedure ComboBox1KeyPress(Sender: TObject; Var Key: Char);
    Procedure Button3Click(Sender: TObject);
    Procedure Edit4KeyPress(Sender: TObject; Var Key: Char);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  End;

Var
  Form2: TForm2;

Implementation

{$R *.lfm}

Uses
  uloop
  , unit1
  , unit10
  ;

Procedure TForm2.FormPaint(Sender: TObject);
Begin
  Combobox1.SetFocus;
End;

Procedure TForm2.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; Var Handled: Boolean);
Var
  c: integer;
Begin
  c := combobox1.itemindex;
  inc(c);
  If c > combobox1.items.count - 1 Then c := 0;
  combobox1.itemindex := c;
End;

Procedure TForm2.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; Var Handled: Boolean);
Var
  c: integer;
Begin
  c := combobox1.itemindex;
  dec(c);
  If c = -1 Then c := combobox1.items.count - 1;
  combobox1.itemindex := c;
End;

Procedure TForm2.ComboBox1KeyPress(Sender: TObject; Var Key: Char);
Begin
  If Key = #13 Then Begin
    If ComboBox1.text = 'User Definied' Then Begin
      form10.SynGeneralSyn1.KeyWords.AddStrings(Form1.Loop_Highlither1.KeyWords);
      form10.listbox1.itemindex := 0;
      form10.LoadScheme;
      loadall;
      form10.showmodal;
    End
    Else
      button1.onclick(Nil);
  End;
  If Not (key In [#28, #26]) Then Key := #0;
End;

Procedure TForm2.ComboBox1Change(Sender: TObject);
Begin
  If ComboBox1.text = 'User Definied' Then Begin
    form10.SynGeneralSyn1.KeyWords.Clear;
    form10.SynGeneralSyn1.KeyWords.AddStrings(Form1.Loop_Highlither1.KeyWords);
    form10.listbox1.itemindex := 0;
    form10.LoadScheme;
    loadall;
    form10.showmodal;
  End;
End;

Procedure TForm2.Button3Click(Sender: TObject);
Begin
  Fontdialog1.Font.size := userfont.size;
  Fontdialog1.Font.name := userfont.name;
  Fontdialog1.Font.style := userfont.style;
  If Fontdialog1.execute Then Begin
    userfont.size := Fontdialog1.Font.size;
    userfont.name := Fontdialog1.Font.name;
    userfont.style := Fontdialog1.Font.Style;
    edit2.text := inttostr(userfont.Size);
    edit1.text := userfont.Name;
    edit3.text := FontstyletoString(userfont.Style);
  End;
End;

Procedure TForm2.Edit4KeyPress(Sender: TObject; Var Key: Char);
Begin
  If Not (key In ['0'..'9', #8]) Then key := #0;
End;

End.


