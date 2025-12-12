Unit PrePrescanner;

Interface

Uses classes, sysutils;

Function PrePrescan(Lines: Tstrings): Boolean;

Implementation

Uses unit1, compiler;

Function PrePrescan(Lines: Tstrings): Boolean;
Var
  erg: boolean;
Begin
  erg := false;
  //  form1.Warnings_Error.items.add('Found Error in Line [' + inttostr(getline(Value)) + '] : ' + ' Missing "Then".');

  result := erg;
End;

End.

