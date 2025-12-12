Unit Extended_Options;

Interface

Uses
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

Type
  TForm3 = Class(TForm)
    GroupBox1: TGroupBox;
    CheckBox1: TCheckBox;
    Button1: TButton;
    Button2: TButton;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    CheckBox10: TCheckBox;
    Procedure Button2Click(Sender: TObject);
    Procedure Button1Click(Sender: TObject);
    Procedure CheckBox1Click(Sender: TObject);
    Procedure CheckBox10Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  End;

Var
  Form3: TForm3;

Implementation

{$R *.lfm}

Uses Main;

Procedure TForm3.Button2Click(Sender: TObject);
Begin
  close;
End;

Procedure TForm3.Button1Click(Sender: TObject);
Begin
  Allowif := Checkbox1.checked;
  If Not Allowif Then
    allowgroeserKleiner := false
  Else
    allowgroeserKleiner := checkbox9.checked;
  allowfunction := Checkbox2.checked;
  allowdiv := Checkbox4.checked;
  allowMod := Checkbox3.checked;
  allowminus := Checkbox6.checked;
  allowMulti := Checkbox5.checked;
  allowklammern := Checkbox7.checked;
  allowothernames := Checkbox8.checked;
  allow2varnotconst := Checkbox10.checked;
  SetKeywords; // Aktualisieren der Schlüsselworte
  form1.CodeChange(Nil); // Aktualisieren des Code Explorer's
  close;
End;

Procedure TForm3.CheckBox1Click(Sender: TObject);
Begin
  checkbox9.Enabled := checkbox1.checked;
  If Not checkbox9.Enabled Then
    checkbox9.Checked := false;
End;

Procedure TForm3.CheckBox10Click(Sender: TObject);
Begin
  checkbox7.Enabled := checkbox10.checked;
  If Not checkbox7.Enabled Then
    checkbox7.Checked := false;
End;

End.

