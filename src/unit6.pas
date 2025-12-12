Unit unit6;

Interface

Uses
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
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

