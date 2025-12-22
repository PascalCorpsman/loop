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
Unit Parser;

{$MODE objfpc}{$H+}

Interface

Uses Sysutils, Classes, Forms, comctrls, {Debuggen} Dialogs {Debuggen Ende};

// Ermittelt alle Funcitonen und Proceduren die so im Text in Lines drin stehen und schreibt sie in TV als Baum Nieder
Procedure GetFunnames(Lines: Tstrings; Var TV: TTreeview);
// Formatiert den Quelcode ein Wenig
Function FormatCode(Lines: Tstrings; RemoveDoubleBlank: Boolean; blankPerIdent: Integer): Tstrings;
// Löscht Kommentare
Function DeleteComments(Lines: Tstrings): Tstrings;
// prüft ob Value ein GGültiger Identivier ist wenn nein - > false
Function checkIdentifier(Value: String): Boolean;
// Löscht alle Leerzeichen die Hinter einem Ausdruck stehen
Function DelEndspace(Value: String): String;
// Löscht Führende Leerzeichen
Function DelFrontspace(Value: String): String;
// Prüft auf gültige " Standart " Variablen namen wenn nein - > False
Function CheckVarName(Value: String): boolean;
// Formatiert genau 1 Zeile ist Global da die Function  LineContainsToken das Braucht
Function GetclearedString(Value: String; ClearDoublespace: Boolean): String;

// Prüft ob ein Token in einem String enthalten ist, wenn ja wird der INdex des 1. Zeichens des Token zurückgegeben.
Function LineContainsToken(Token, Line: String): integer;

Implementation

Uses uLoop;

// Löscht Führende Leerzeichen

Function DelFrontspace(Value: String): String;
Var
  erg: String;
Begin
  erg := value;
  While pos(' ', erg) = 1 Do
    delete(erg, 1, 1);
  result := erg;
End;

// Löscht alle Leerzeichen die Hinter einem Ausdruck stehen

Function DelEndspace(Value: String): String;
Var
  erg: String;
  x: Integer;
Begin
  erg := value;
  x := length(erg);
  While x >= 1 Do Begin
    If erg[x] <> ' ' Then x := 0;
    If X >= 1 Then
      delete(erg, x, 1);
    dec(x);
  End;
  result := erg;
End;

// Gültiger Var name  = X Gefolgt von einer Zahl

Function CheckVarName(Value: String): boolean;
Var
  erg: Boolean;
  z: Integer;
Begin
  erg := Length(value) <> 0;
  // Wenn wir lokale Functionsvariablen haben müssen wir den Verweis auf die Function erst abschneiden
  If Pos(LineSeparator, value) <> 0 Then
    delete(value, 1, Pos(LineSeparator, value));
  If Erg Then
    erg := Uppercase(Value)[1] = 'X';
  If Erg Then Begin
    Delete(value, 1, 1); // Löschen des X
    If Length(Value) = 0 Then erg := false;
    // löschen aller Ziffern
    For z := 0 To 9 Do
      While (pos(inttostr(z), Value)) <> 0 Do
        Delete(Value, pos(inttostr(z), Value), 1);
    If Erg Then
      erg := Length(value) = 0;
  End;
  result := erg;
End;

// prüft ob Value ein Gültiger Identivier ist wenn nein - > false

Function checkIdentifier(Value: String): Boolean;
Var
  erg: Boolean;
  z: Integer;
Begin
  // Wenn wir lokale Functionsvariablen haben müssen wir den Verweis auf die Function erst abschneiden
  If Pos(LineSeparator, value) <> 0 Then
    delete(value, 1, Pos(LineSeparator, value));
  erg := Length(value) <> 0;
  // Ein Identifier darf nur mit Buchstaben oder underline anfangen
  If Erg Then
    erg := Value[1] In ['A'..'Z', 'a'..'z', '_'];
  If Erg Then Begin
    // Löschen aller Buchstaben
    For z := 65 To 90 Do
      While (pos(chr(z), uppercase(Value))) <> 0 Do
        Delete(Value, pos(chr(z), uppercase(Value)), 1);
    // löschen aller Ziffern
    For z := 0 To 9 Do
      While (pos(inttostr(z), Value)) <> 0 Do
        Delete(Value, pos(inttostr(z), Value), 1);
    // Löschen des einzigst erlaubten Zeichen zusatzzeichen für Procedur Namen
    While Pos('_', Value) <> 0 Do
      delete(Value, pos('_', Value), 1);
    erg := Length(value) = 0;
  End;
  result := erg;
End;

// Löscht führende Leerzeichen in einem String, Führt um Aritmetische Zeicehn Leerzeichen ein und schreibt Schlüsselworte Groß

Function GetclearedString(Value: String; ClearDoublespace: Boolean): String;
Var
  y, x: integer;
  s: String;
  b: Boolean;
Begin
  // löscht Führende Leerzeichen
  Value := DelFrontspace(value);
  // Cool wäre wenn die Leerzeichen aus Kommentaren nicht entfernt würden , aber das ist nicht so einfach
  // Enfernt lange Lücken zwischen worten
  If ClearDoublespace Then Begin
    While (pos('  ', Value) <> 0) Do
      delete(Value, pos('  ', Value), 1);
  End;
  // Löschen der Leerzeichen für dem ;
  While pos(' ;', Value) <> 0 Do
    delete(Value, pos(' ;', Value), 1);
  // Erzeugen der Leerstellen vor gewissen schlüsselzeichen
  x := 2;
  While x <= length(Value) Do Begin
    // Die Auflistung aller Zeichen die Ganz Gewiss ein Führendes Leerzeichen haben sollen
    If (Value[x] In ['+', '^', ':', '<', '>']) And (Value[x - 1] <> ' ') Then Begin
      If (Value[x] = '>') And (Value[x - 1] <> '<') Then // das <> Zeichen darf nicht "getrennt" werden ;)
        insert(' ', value, x);
    End;
    // Die Zeichen die nicht unbedingt ein Leerzeichen vor sich haben.
    If (Value[x] = '-') And (Value[x - 1] <> '^') And (Value[x - 1] <> ' ') Then
      insert(' ', value, x);
    If (Value[x] = '=') And (Value[x - 1] <> '<') And (Value[x - 1] <> '>') And (Value[x - 1] <> ':') And (Value[x - 1] <> ' ') Then
      insert(' ', value, x);
    If (Value[x] = '*') And (Value[x - 1] <> '*') And (Value[x - 1] <> '(') And (Value[x - 1] <> ' ') Then
      insert(' ', value, x);
    // Wegrücken bestimmter Schlüsselworte z.b. 2mod -> 2 Mod
    s := 'Then';
    If comparestr(Lowercase(s), lowercase(copy(value, x, length(s)))) = 0 Then
      If (Value[x - 1] = ')') Then
        insert(' ', value, x);
    s := 'mod';
    // Schaun ob das Schlüsselwort hier zufällig im String steht
    If comparestr(Lowercase(s), lowercase(copy(value, x, length(s)))) = 0 Then
      If Value[x - 1] In ['0'..'9', ')'] Then Begin
        b := true;
        y := x - 1;
        While y > 0 Do Begin
          // Wir haben das erste Blank gefunden
          If (Value[y] = ' ') Or (Value[y] = ')') Then y := -1;
          If (Y > 0) And (Not (Value[y] In ['0'..'9', ')'])) Then Begin
            b := false;
            y := -1;
          End;
          dec(y);
        End;
        // Wenn for dem String wirklich nur eine Zahl stand und kein identifier dann kann der string 1 weggeschoben werden
        If b Then Begin
          insert(' ', value, x);
        End;
      End;
    s := 'Div';
    // Schaun ob das Schlüsselwort hier zufällig im String steht
    If comparestr(Lowercase(s), lowercase(copy(value, x, length(s)))) = 0 Then
      If Value[x - 1] In ['0'..'9', ')'] Then Begin
        b := true;
        y := x - 1;
        While y > 0 Do Begin
          // Wir haben das erste Blank gefunden
          If (Value[y] = ' ') Or (Value[y] = ')') Then y := -1;
          If (Y > 0) And (Not (Value[y] In ['0'..'9', ')'])) Then Begin
            b := false;
            y := -1;
          End;
          dec(y);
        End;
        // Wenn for dem String wirklich nur eine Zahl stand und kein identifier dann kann der string 1 weggeschoben werden
        If b Then Begin
          insert(' ', value, x);
        End;
      End;
    s := 'And';
    // Schaun ob das Schlüsselwort hier zufällig im String steht
    If comparestr(Lowercase(s), lowercase(copy(value, x, length(s)))) = 0 Then
      If Value[x - 1] In ['0'..'9', ')'] Then Begin
        b := true;
        y := x - 1;
        While y > 0 Do Begin
          // Wir haben das erste Blank gefunden
          If (Value[y] = ' ') Or (Value[y] = ')') Then y := -1;
          If (Y > 0) And (Not (Value[y] In ['0'..'9', ')'])) Then Begin
            b := false;
            y := -1;
          End;
          dec(y);
        End;
        // Wenn for dem String wirklich nur eine Zahl stand und kein identifier dann kann der string 1 weggeschoben werden
        If b Then Begin
          insert(' ', value, x);
        End;
      End;
    s := 'Or';
    // Schaun ob das Schlüsselwort hier zufällig im String steht
    If comparestr(Lowercase(s), lowercase(copy(value, x, length(s)))) = 0 Then
      If Value[x - 1] In ['0'..'9', ')'] Then Begin
        b := true;
        y := x - 1;
        While y > 0 Do Begin
          // Wir haben das erste Blank gefunden
          If (Value[y] = ' ') Or (Value[y] = ')') Then y := -1;
          If (Y > 0) And (Not (Value[y] In ['0'..'9', ')'])) Then Begin
            b := false;
            y := -1;
          End;
          dec(y);
        End;
        // Wenn for dem String wirklich nur eine Zahl stand und kein identifier dann kann der string 1 weggeschoben werden
        If b Then Begin
          insert(' ', value, x);
        End;
      End;
    inc(x);
  End;
  // Erzeugen der Leerstellen nach gewissen Schlüsselzeichen
  x := 1;
  While x < length(Value) Do Begin
    // Die Auflistung aller zeichen die Ganz Gewiss ein folgendes Leerzeichen haben sollen
    If (Value[x] In ['+', ',', '-', '=']) And (Value[x + 1] <> ' ') Then
      insert(' ', value, x + 1);
    // Die Zeicehn die nicht unbedingt ein Leerzeichen hinter sich haben.
    If (Value[x] = '*') And (Value[x + 1] <> '*') And (Value[x + 1] <> ')') And (Value[x + 1] <> ' ') Then
      insert(' ', value, x + 1);
    If (Value[x] = '<') And (Value[x + 1] <> '=') And (Value[x + 1] <> ' ') And (Value[x + 1] <> '>') Then
      insert(' ', value, x + 1);
    If (Value[x] = '>') And (Value[x + 1] <> '=') And (Value[x + 1] <> ' ') Then
      insert(' ', value, x + 1);
    // nach so Manchen Schlüsselworten wird auch weggerückt
    s := 'If';
    // Schaun ob das Schlüsselwort hier zufällig im String steht
    If comparestr(Lowercase(s), lowercase(copy(value, x, length(s)))) = 0 Then
      If Value[x + length(s)] = '(' Then Begin
        insert(' ', value, x + length(S));
      End;
    s := 'And';
    // Schaun ob das Schlüsselwort hier zufällig im String steht
    If comparestr(Lowercase(s), lowercase(copy(value, x, length(s)))) = 0 Then
      If Value[x + length(s)] = '(' Then Begin
        insert(' ', value, x + length(S));
      End;
    s := 'or';
    // Schaun ob das Schlüsselwort hier zufällig im String steht
    If comparestr(Lowercase(s), lowercase(copy(value, x, length(s)))) = 0 Then
      If Value[x + length(s)] = '(' Then Begin
        insert(' ', value, x + length(S));
      End;
    s := 'not';
    // Schaun ob das Schlüsselwort hier zufällig im String steht
    If comparestr(Lowercase(s), lowercase(copy(value, x, length(s)))) = 0 Then
      If Value[x + length(s)] = '(' Then Begin
        insert(' ', value, x + length(S));
      End;
    s := 'Mod';
    // Schaun ob das Schlüsselwort hier zufällig im String steht
    If comparestr(Lowercase(s), lowercase(copy(value, x, length(s)))) = 0 Then
      If Value[x + length(s)] = '(' Then Begin
        insert(' ', value, x + length(S));
      End;
    s := 'div';
    // Schaun ob das Schlüsselwort hier zufällig im String steht
    If comparestr(Lowercase(s), lowercase(copy(value, x, length(s)))) = 0 Then
      If Value[x + length(s)] = '(' Then Begin
        insert(' ', value, x + length(S));
      End;
    inc(x);
  End;
  // Großschreiben der Schlüsselworte
  x := 1;
  While x <= Length(Value) Do Begin
    // Großschreiben von Loop
    s := 'Loop';
    // Schaun ob das Schlüsselwort hier zufällig im String steht
    If comparestr(Lowercase(s), lowercase(copy(value, x, length(s)))) = 0 Then
      // Überschrieben des Textteiles mit dem Formatierten String aus s
      For y := 1 To length(s) Do
        Value[x + y - 1] := s[y];
    // Großschreiben von Do
    s := 'Do';
    // Schaun ob das Schlüsselwort hier zufällig im String steht
    If comparestr(Lowercase(s), lowercase(copy(value, x, length(s)))) = 0 Then
      // Überschrieben des Textteiles mit dem Formatierten String aus s
      For y := 1 To length(s) Do
        Value[x + y - 1] := s[y];
    // Großschreiben von End
    s := 'End';
    // Schaun ob das Schlüsselwort hier zufällig im String steht
    If comparestr(Lowercase(s), lowercase(copy(value, x, length(s)))) = 0 Then
      // Überschrieben des Textteiles mit dem Formatierten String aus s
      For y := 1 To length(s) Do
        Value[x + y - 1] := s[y];
    // Großschreiben von Begin
    s := 'Begin';
    // Schaun ob das Schlüsselwort hier zufällig im String steht
    If comparestr(Lowercase(s), lowercase(copy(value, x, length(s)))) = 0 Then
      // Überschrieben des Textteiles mit dem Formatierten String aus s
      For y := 1 To length(s) Do
        Value[x + y - 1] := s[y];
    // Großschreiben von Procedure
    s := 'Procedure';
    // Schaun ob das Schlüsselwort hier zufällig im String steht
    If comparestr(Lowercase(s), lowercase(copy(value, x, length(s)))) = 0 Then
      // Überschrieben des Textteiles mit dem Formatierten String aus s
      For y := 1 To length(s) Do
        Value[x + y - 1] := s[y];
    // Großschreiben von Var
    s := 'Var';
    // Schaun ob das Schlüsselwort hier zufällig im String steht
    If comparestr(Lowercase(s), lowercase(copy(value, x, length(s)))) = 0 Then
      // Überschrieben des Textteiles mit dem Formatierten String aus s
      For y := 1 To length(s) Do
        Value[x + y - 1] := s[y];
    // Großschreiben von Get
    s := 'Get';
    // Schaun ob das Schlüsselwort hier zufällig im String steht
    If comparestr(Lowercase(s), lowercase(copy(value, x, length(s)))) = 0 Then
      // Überschrieben des Textteiles mit dem Formatierten String aus s
      For y := 1 To length(s) Do
        Value[x + y - 1] := s[y];
    // Großschreiben von Function
    s := 'Function';
    // Schaun ob das Schlüsselwort hier zufällig im String steht
    If comparestr(Lowercase(s), lowercase(copy(value, x, length(s)))) = 0 Then
      // Überschrieben des Textteiles mit dem Formatierten String aus s
      For y := 1 To length(s) Do
        Value[x + y - 1] := s[y];
    // Großschreiben von If
    s := 'If';
    // Schaun ob das Schlüsselwort hier zufällig im String steht
    If comparestr(Lowercase(s), lowercase(copy(value, x, length(s)))) = 0 Then
      // Überschrieben des Textteiles mit dem Formatierten String aus s
      If X = 1 Then Begin
        For y := 1 To length(s) Do
          Value[x + y - 1] := s[y];
      End
      Else Begin
        If Not (Value[x - 1] In ['a'..'z', 'A'..'Z', '_']) Then
          For y := 1 To length(s) Do
            Value[x + y - 1] := s[y];
      End;
    // Großschreiben von Then
    s := 'Then';
    // Schaun ob das Schlüsselwort hier zufällig im String steht
    If comparestr(Lowercase(s), lowercase(copy(value, x, length(s)))) = 0 Then
      // Überschrieben des Textteiles mit dem Formatierten String aus s
      For y := 1 To length(s) Do
        Value[x + y - 1] := s[y];
    // Großschreiben von Else
    s := 'Else';
    // Schaun ob das Schlüsselwort hier zufällig im String steht
    If comparestr(Lowercase(s), lowercase(copy(value, x, length(s)))) = 0 Then
      // Überschrieben des Textteiles mit dem Formatierten String aus s
      For y := 1 To length(s) Do
        Value[x + y - 1] := s[y];
    // Großschreiben von Or
    s := 'Or';
    // Schaun ob das Schlüsselwort hier zufällig im String steht
    If comparestr(Lowercase(s), lowercase(copy(value, x, length(s)))) = 0 Then
      // Überschrieben des Textteiles mit dem Formatierten String aus s
      For y := 1 To length(s) Do
        Value[x + y - 1] := s[y];
    // Großschreiben von And
    s := 'And';
    // Schaun ob das Schlüsselwort hier zufällig im String steht
    If comparestr(Lowercase(s), lowercase(copy(value, x, length(s)))) = 0 Then
      // Überschrieben des Textteiles mit dem Formatierten String aus s
      For y := 1 To length(s) Do
        Value[x + y - 1] := s[y];
    // Großschreiben von Mod
    s := 'Mod';
    // Schaun ob das Schlüsselwort hier zufällig im String steht
    If comparestr(Lowercase(s), lowercase(copy(value, x, length(s)))) = 0 Then
      // Überschrieben des Textteiles mit dem Formatierten String aus s
      For y := 1 To length(s) Do
        Value[x + y - 1] := s[y];
    // Großschreiben von Div
    s := 'Div';
    // Schaun ob das Schlüsselwort hier zufällig im String steht
    If comparestr(Lowercase(s), lowercase(copy(value, x, length(s)))) = 0 Then
      // Überschrieben des Textteiles mit dem Formatierten String aus s
      For y := 1 To length(s) Do
        Value[x + y - 1] := s[y];
    inc(x);
  End;
  result := value;
End;

// Entfernt Doppelte Leerzeilen , und Rückt entsprechend der Syntax ein

Function FormatCode(Lines: Tstrings; RemoveDoubleBlank: Boolean; blankPerIdent: Integer): Tstrings;
// Fügt die im Parameter angegebnene Anzahl an Leerzeicen vorne an
  Function Getblank(Value: String; Count: integer): String;
  Var
    x: Integer;
  Begin
    result := '';
    For x := 1 To count Do
      result := result + ' ';
    result := result + value;
  End;

Var
  erg: Tstringlist;
  spacecount, Leercount, CommentType, x, y, blcount: integer;
  erg_line, line, lineup: String;
  singleback: Boolean;
Begin
  erg := tstringlist.create;
  erg.clear;
  blcount := 0; // Zählt um wieviele Ebenen eingerückt werden mus
  CommentType := 0; // Zeigt an in welchem Commentar Token wir sind
  Leercount := 0; // Zählt die aufeinanderfolgenden Leerzeilen
  spacecount := 0; // Zählt die Aufeinanderfolgenden Leerzeichen
  y := 0;
  While y < lines.count Do Begin
    // Auslesen der Aktuellen Zeile
    line := GetclearedString(Lines[y], false);
    lineup := uppercase(Line);
    // Zählen der Leerzeilen
    If Length(Line) = 0 Then
      inc(Leercount)
    Else
      Leercount := 0;
    If (Not RemoveDoubleBlank) Then Leercount := 0;
    // Einzeiliger Kommentar wieder Rückgängig machen
    If Commenttype = 1 Then commenttype := 0;
    singleback := false;
    // Suchen nach einrückParametern
    x := 1;
    erg_line := '';
    While x <= length(line) Do Begin
      // Betrachten der 2 Stelligen Kommentartypen
      If X < Length(Line) Then Begin
        // Schleisen des  *) Tokens
        If (line[x] = '*') And (line[x + 1] = ')') And (commenttype = 3) Then Begin
          Commenttype := 0;
          Erg_line := Erg_line + Line[x];
          Erg_line := Erg_line + Line[x + 1];
          x := x + 2;
        End;
        // öffnen des Comment Token für //
        If (line[x] = '/') And (line[x + 1] = '/') And (commenttype = 0) Then Begin
          Commenttype := 1;
          Erg_line := Erg_line + Line[x];
          Erg_line := Erg_line + Line[x + 1];
          x := x + 2;
        End;
        // Öffnen des (* Tokens
        If (line[x] = '(') And (line[x + 1] = '*') And (commenttype = 0) Then Begin
          Commenttype := 3;
          Erg_line := Erg_line + Line[x];
          Erg_line := Erg_line + Line[x + 1];
          x := x + 2;
        End;
      End;
      // Schliesen des  } Tokens
      If (line[x] = '}') And (Commenttype = 2) Then Begin
        Commenttype := 0;
        Erg_line := Erg_line + Line[x];
        x := x + 1;
      End;
      // Öffnen des  { Tokens
      If (line[x] = '{') And (Commenttype = 0) Then Begin
        Commenttype := 2;
        Erg_line := Erg_line + Line[x];
        x := x + 1;
      End;
      // Wir befinden uns nicht in einem Kommentar , also können wir nach einrückbefehlen suchen
      If Commenttype = 0 Then Begin
        If Lineup[x] = ' ' Then
          inc(spacecount)
        Else
          spacecount := 0;
        {
        Öffnende :

        THEN
        BEGIN
        DO
        FUNCTION
        PROCEDURE

        Schliesende : END

        WORTE DIE 1 zurückgerückt werden müssen:

        ELSE
        VAR
        LOOP
        }
        (*

        Eigentlich gehört da bei allen noch ein Prüfen auf das Zeichen dafor und danach rein, aber ich bin Faul

        *)
        If x < length(Lineup) Then Begin
          If (Lineup[x] = 'D') And (Lineup[x + 1] = 'O') Then inc(blcount);
          If (Lineup[x] = 'I') And (Lineup[x + 1] = 'F') Then singleback := true;
        End;
        If x < (length(Lineup) - 1) Then Begin
          If (Lineup[x] = 'E') And (Lineup[x + 1] = 'N') And (Lineup[x + 2] = 'D') Then dec(blcount);
          If LineContainsToken('var', lineup) <> 0 Then singleback := true;
          //          If (Lineup[x] = 'V') And (Lineup[x + 1] = 'A') And (Lineup[x + 2] = 'R') Then singleback := true;
        End;
        If x < (length(Lineup) - 2) Then Begin
          If (Lineup[x] = 'T') And (Lineup[x + 1] = 'H') And (Lineup[x + 2] = 'E') And (Lineup[x + 3] = 'N') Then Begin
            If x = (length(Lineup) - 3) Then
              inc(blcount)
            Else Begin
              If Lineup[x + 4] = ' ' Then inc(blcount);
            End;
          End;
          If (Lineup[x] = 'L') And (Lineup[x + 1] = 'O') And (Lineup[x + 2] = 'O') And (Lineup[x + 3] = 'P') Then singleback := true;
          If (Lineup[x] = 'E') And (Lineup[x + 1] = 'L') And (Lineup[x + 2] = 'S') And (Lineup[x + 3] = 'E') Then singleback := true;
        End;
        If x < (length(Lineup) - 3) Then
          If (Lineup[x] = 'B') And (Lineup[x + 1] = 'E') And (Lineup[x + 2] = 'G') And (Lineup[x + 3] = 'I') And (Lineup[x + 4] = 'N') Then Begin
            singleback := true;
          End;
        If x < (length(Lineup) - 6) Then
          If (Lineup[x] = 'F') And (Lineup[x + 1] = 'U') And (Lineup[x + 2] = 'N') And (Lineup[x + 3] = 'C') And
            (Lineup[x + 4] = 'T') And (Lineup[x + 5] = 'I') And (Lineup[x + 6] = 'O') And (Lineup[x + 7] = 'N') Then Begin
            singleback := true;
            inc(blcount);
          End;
        If x < (length(Lineup) - 7) Then
          If (Lineup[x] = 'P') And (Lineup[x + 1] = 'R') And (Lineup[x + 2] = 'O') And (Lineup[x + 3] = 'C') And
            (Lineup[x + 4] = 'E') And (Lineup[x + 5] = 'D') And (Lineup[x + 6] = 'U') And (Lineup[x + 7] = 'R') And (Lineup[x + 8] = 'E') Then Begin
            singleback := true;
            inc(blcount);
          End;
      End;
      If CommentType = 0 Then Begin
        If Spacecount <= 1 Then
          Erg_line := Erg_line + Line[x];
      End
      Else Begin
        Erg_line := Erg_line + Line[x];
      End;
      inc(x); // Weiterzählen der Schleife
    End;
    // Kann auftreten wenn jemand einen Falschen Code Formatieren lässt
    If blcount < 0 Then blcount := 0;
    If Leercount < 2 Then Begin
      If Not singleback Then
        erg.add(Getblank(Erg_line, blcount * blankperident))
      Else
        erg.add(Getblank(Erg_line, (blcount - 1) * blankperident));
    End;
    inc(y); // Weiterzählen der Schleife
  End;
  result := erg;
End;

// Löscht alle Kommentare aus einem Gegebensn Source Code und fügt hinter jede Zeile LineSeparator Orginal Zeilennummer

(* Kommentare sind

Einzeilige Kommentare : //

Mehrzeilige Kommentare  : { } , ( * * )
*)

Function DeleteComments(Lines: Tstrings): Tstrings;
Var
  y, x: Integer;
  CommentType: Integer;
  rLine, Line: String;
  erg: Tstringlist;
Begin
  // Erzeugen des Ergebnis Pointer's
  erg := tstringlist.create;
  // Löschen des Ergebnisses
  erg.clear;
  x := 0;
  CommentType := 0;
  // Auslesen des Quellcodes unter beachtung Kommentare
  While x < lines.count Do Begin
    Application.ProcessMessages;
    line := Lines[x];
    rLine := '';
    y := 1;
    While y < Length(line) Do Begin
      // Der Kommentar schliest sich
      If ((Line[y] = '}') Or ((line[y] = '*') And (line[y + 1] = ')'))) Then Begin
        If (line[y] = '}') And (CommentType = 2) Then Begin
          CommentType := 0;
          y := y + 1;
        End;
        If (line[y] = '*') And (CommentType = 3) Then Begin
          CommentType := 0;
          y := y + 2;
        End;
      End;
      // Ein Kommentar öffnet sich
      If ((Line[y] = '{') Or ((Line[y] = '(') And (Line[y + 1] = '*')) Or
        ((Line[y] = '/') And (Line[y + 1] = '/'))) And (CommentType = 0) Then Begin
        If line[y] = '/' Then CommentType := 1;
        If line[y] = '{' Then CommentType := 2;
        If line[y] = '(' Then Begin
          CommentType := 3;
          y := y + 2;
        End;
      End;
      // Zu Parsender String, das Letze Zeichen einer Zeile wir weiter unten im Sonderfall erst gelesen
      If (CommentType = 0) And (y < length(line)) Then
        rline := rline + Line[y];
      If y < Length(line) Then
        inc(y);
    End;
    // Sonderfall Kommentar Öffnet
    If (Length(Line) <> 0) And (CommentType <> 1) And (y <= length(line)) Then
      If (Line[Length(line)] = '{') Or (Line[Length(line)] = '}') Then Begin
        If (Line[Length(line)] = '{') Then CommentType := 2;
        If (Line[Length(line)] = '}') Then CommentType := 0;
      End
      Else Begin
        If CommentType = 0 Then
          Rline := rline + Line[Length(line)];
      End;
    // Die zeile ist Fertig Bearbeitet, d.h. der Commentartyp 1 kann wieder zurückgesetzt werden.
    If CommentType = 1 Then CommentType := 0;
    // So der Hier landende Quellcode ist ohne Kommentare und steht in Rline, Im Orginaltext an Zeile X
    If (Length(Rline) <> 0) Then Begin
      erg.add(Rline + ' ' + LineSeparator + inttostr(x));
    End;
    inc(x);
  End;
  result := erg;
End;

Procedure GetFunnames(Lines: Tstrings; Var TV: TTreeview);
Var
  Code: Tstrings;
  y, x, z: Integer;
  line, Procname: String;
  ProcFound: Boolean;
  knoten, knoten2: TTreenode;
Begin
  knoten := Nil; // hat keinen Sinn beruhigt nur den Kompiler
  // Rausstreichen der Kommentare aus dem Quellcode
  Code := DeleteComments(Lines);
  TV.items.clear; // Löschen der Bisher eingetragenen werte
  x := 0;
  ProcFound := false;
  // Nachdem wir nun Reinen Quelltcode haben können wir anfangen und nach den Schlüssel worten Suchen.
  While x < code.count Do Begin
    y := Pos('PROCEDURE', uppercase(Code[x]));
    // Wir Suchen nur das erste Procedure Wort Heraus alle anderen werden Ignoriert
    If (y <> 0) And Not ProcFound Then Begin
      line := (Code[x]);
      // Löschen der Steuerzeichen dei der Kommententferner einfügt
      delete(line, pos(LineSeparator, line), length(line));
      Procname := '';
      z := length(Line);
      If z >= 10 Then
        If (y = 1) And (line[y + 9] = ' ') Then Begin
          Procname := copy(line, y + 10, length(line));
        End;
      If z >= 10 + y Then
        If (y > 1) And (line[y - 1] = ' ') And (line[y + 9] = ' ') Then Begin
          Procname := copy(line, y + 10, length(line));
        End;
      // Löschen der Unwichtigen sachen hinter dem Procedur namen
      delete(procname, pos(';', procname), length(procname));
      // Löschen Führender und Nachfolgender Leerzeichen
      procname := DelFrontspace(DelEndspace(procname));
      // Wir haben einen Gültigen Namen gefunden
      If checkIdentifier(Procname) Then Begin
        // Merken das wir die eine Erlaubte Procedur gefunden haben
        ProcFound := true;
        // anfügen des Programmnamens
        knoten := tv.items.add(Nil, Procname);
        // Zuweisen des BildchenIndes
        knoten.ImageIndex := 0;
        knoten.SelectedIndex := 0;
      End;
    End;
    // Auslesen diverser Functionen
    y := Pos('FUNCTION', uppercase(Code[x]));
    If Not allowfunction Then y := 0;
    // Wir Suchen nun nach evtl eingetragenen Functionen
    If (y <> 0) And Allowfunction And ProcFound Then Begin
      line := (Code[x]);
      // Löschen der Steuerzeichen die der Kommententferner einfügt
      delete(line, pos(LineSeparator, line), length(line));
      Procname := '';
      z := length(Line);
      If z >= 9 Then
        If (y = 1) And ((line[y + 8] = ' ')) Then Begin
          Procname := copy(line, y + 9, length(line));
        End;
      If z >= 9 + y Then
        If (y > 1) And (line[y - 1] = ' ') And ((line[y + 8] = ' ')) Then Begin
          Procname := copy(line, y + 9, length(line));
        End;
      // Löschen der Unwichtigen sachen hinter dem Procedur namen
      delete(procname, pos(';', procname), length(procname));
      // Löschen evtler Übergabe Parameter
      If Pos('(', procname) <> 0 Then
        delete(procname, Pos('(', procname), length(procname));
      // Löschen Führender und Nachfolgender Leerzeichen
      procname := DelFrontspace(DelEndspace(procname));
      // Wir haben einen Gültigen Namen gefunden
      If checkIdentifier(Procname) Then Begin
        // anfügen des Programmnamens
        knoten2 := tv.items.AddChild(knoten, Procname);
        // Zuweisen des BildchenIndes
        knoten2.ImageIndex := 1;
        knoten2.SelectedIndex := 1;
      End;
    End;
    inc(x);
  End;
  tv.AlphaSort; // Alphabetisches Sortieren !!
  If Assigned(knoten) Then Knoten.expand(true); // Aufklappen des Baumes
  // Freigeben der Variablen
  code.free;
End;

// Prüft ob ein Token in einem String enthalten ist, wenn ja wird der INdex des 1. Zeichens des Token zurückgegeben.

Function LineContainsToken(Token, Line: String): integer;
Var
  Erg: integer;
  ttoken, tline: String;
Begin
  // Löschen eines steuerzeichens in Functionsnamen
  If pos(LineSeparator, token) <> 0 Then
    delete(Token, pos(LineSeparator, token), 1);
  erg := 0;
  // Die Tausend Möglichkeiten auf eine Beschränken
  TToken := Uppercase(Token);
  TLine := Uppercase(Line);
  // Fall 1 Wort steht links
  If pos(TToken + ' ', Tline) = 1 Then erg := 1;
  // Fall 2 Token steht in der Mitte , getestet
  If erg = 0 Then
    If pos(' ' + TToken + ' ', Tline) <> 0 Then Begin
      erg := pos(' ' + TToken + ' ', Tline) + 1;
    End;
  //  Fall 3 der Token steht genau Rechts
  If Erg = 0 Then
    If Pos(' ' + TTOken, Tline) = Length(Tline) - Length(TTOken) Then
      If Length(Tline) - Length(TTOken) <> 0 Then
        erg := Pos(' ' + TTOken, Tline) + 1;
  // Fall 4 Die Zeile ist genau der Token , getestet
  If erg = 0 Then
    If Line = Token Then erg := 1;
  result := erg;
End;

End.

