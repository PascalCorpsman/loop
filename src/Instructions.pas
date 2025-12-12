Unit Instructions;

Interface

Uses
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

Type
  TForm7 = Class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Procedure Button1Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  End;

Var
  Form7: TForm7;

Implementation

{$R *.lfm}

Procedure TForm7.Button1Click(Sender: TObject);
Begin
  close;
End;

End.

