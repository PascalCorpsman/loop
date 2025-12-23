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
Unit RechenBaum;

{$MODE objfpc}{$H+}

Interface

Uses Sysutils, dialogs, Classes;

Type
  // Zeiger auf unsere Bäumchen
  Prechentree = ^Trechentree;

  TRechenTree = Record
    IsValue: Boolean; // Wenn True dann ist Value eine Zahl , Wenn False ist Value ein Operand.
    Value: int64; // s.o.
    Left: Prechentree; // Linker Unterbaum
    Right: Prechentree; // Rechter Unterbaum
  End;

Procedure Freerechentree(Var Value: PRechenTree);
Function RechneTree(Value: PRechenTree): int64;
Function MakeRechentree(Value: String; Line: int64; Var Error: Boolean; Ebene: String; AlreadyFound: Array Of Prechentree; Const WarningsLogger: TStrings): Prechentree;
// Rückt die Zeichen ( ) ebenfalls weg
Function Preclear(Value: String): String;

Implementation

Uses
  Executer
  , Parser
  , uloop
  , ucompiler
  ;

// Gibt einen Trechentree Frei und setzt ihn auf NIL

Procedure Freerechentree(Var Value: PRechenTree);
// Die Eigentliche Freigabe der Variablen
  Procedure SubFreerechentree(DeletData: PRechenTree);
  Begin
    If deletData <> Nil Then Begin
      // Wenn wir keinen Knoten sondern einen Operator haben
      // Müssen wir dessen Variablen auch Freigeben
      If Not deletData^.IsValue Then Begin
        // Die Reihenfolge der Traversierung ist dabei völlig egal
        SubFreerechentree(deletData^.Left);
        SubFreerechentree(deletData^.Right);
      End;
      Dispose(deletData); // Freigabe des Knotens
    End;
  End;
Begin
  // Das Freigeben des Speicher's
  SubFreerechentree(value);
  // Zu Nil Setzen
  Value := Nil;
End;

// Da ich mich entscheiden habe Klammern normalerweise nicht weg zu Rücken mus dies hier nachträglich gemacht werden. !!

Function Preclear(Value: String): String;
Var
  x: int64;
Begin
  x := 2;
  While x <= length(Value) Do Begin
    // Die Auflistung aller zeichen die Ganz Gewiss ein Führendes Leerzeichen haben sollen
    If (Value[x] In ['(', ')']) And (Value[x - 1] <> ' ') Then
      insert(' ', value, x);
    inc(x);
  End;
  // Erzeugen der Leerstellen nach gewissen Schlüsselzeichen
  x := 1;
  While x < length(Value) Do Begin
    // Die Auflistung aller zeichen die Ganz Gewiss ein folgendes Leerzeichen haben sollen
    If (Value[x] In ['(', ')']) And (Value[x + 1] <> ' ') Then
      insert(' ', value, x + 1);
    inc(x);
  End;
  result := value;
End;

// Berechnet einen Ausdruck der durch einen Trechentree gegeben ist
// Operatoren sind + , - , ^- , * , Mod , Div , And , Or , Not
// Wobei X >= 1 -> True, X = 0 -> False gilt.
// Ist result < 0 -> Fehler

Function RechneTree(Value: PRechenTree): int64;
Var
  v1, v2, erg: int64;
Begin
  If Value <> Nil Then Begin
    If value^.IsValue Then Begin
      erg := PointerVar_To_RealVar(value^.Value);
    End
    Else Begin
      erg := 0; // Beruhigt den Compiler
      Case value^.Value Of
        1: Begin // +
            v1 := RechneTree(value^.Left);
            v2 := RechneTree(value^.Right);
            If (V1 >= 0) And (v2 >= 0) Then Begin
              If (high(int64) - v2 >= v1) Then
                erg := v1 + v2
              Else Begin
                erg := -1;
                Showmessage('Error Overflow, your number is more than ' + inttostr(high(int64)));
              End;
            End
            Else
              erg := -1; // Merken das ein Fehler War, ist egal welche Negative Zahl hauptsach negativ
          End;
        2: Begin // -
            v1 := RechneTree(value^.Left);
            v2 := RechneTree(value^.Right);
            If (V1 >= 0) And (v2 >= 0) Then Begin
              erg := v1 - v2;
              If Erg < 0 Then
                Showmessage('Error Underflow, your number is less than 0');
            End
            Else
              erg := -1; // Merken das ein Fehler War, ist egal welche Negative Zahl hauptsach negativ
          End;
        3: Begin // ^-
            v1 := RechneTree(value^.Left);
            v2 := RechneTree(value^.Right);
            If (V1 >= 0) And (v2 >= 0) Then Begin
              erg := v1 - v2;
              If Erg < 0 Then Erg := 0; // Da wir das Modifizierte Minus haben müssen wir es auch so behandeln
            End
            Else
              erg := -1; // Merken das ein Fehler War, ist egal welche Negative Zahl hauptsach negativ
          End;
        4: Begin // *
            v1 := RechneTree(value^.Left);
            v2 := RechneTree(value^.Right);
            If (V1 >= 0) And (v2 >= 0) Then Begin
              If v2 <> 0 Then Begin
                If high(int64) Div v2 >= v1 Then
                  erg := v1 * v2
                Else Begin
                  erg := -1;
                  Showmessage('Error Overflow, your number is more than ' + inttostr(high(int64)));
                End;
              End
              Else Begin
                erg := 0;
              End;
            End
            Else
              erg := -1; // Merken das ein Fehler War, ist egal welche Negative Zahl hauptsach negativ
          End;
        5: Begin // Mod
            v1 := RechneTree(value^.Left);
            v2 := RechneTree(value^.Right);
            If (V1 >= 0) And (v2 > 0) Then Begin
              erg := v1 Mod v2;
            End
            Else Begin
              erg := -1; // Merken das ein Fehler War, ist egal welche Negative Zahl hauptsach negativ
              If V2 = 0 Then
                Showmessage('Error Division by zero');
            End;
          End;
        6: Begin // Div
            v1 := RechneTree(value^.Left);
            v2 := RechneTree(value^.Right);
            If (V1 >= 0) And (v2 > 0) Then Begin
              erg := v1 Div v2;
            End
            Else Begin
              erg := -1; // Merken das ein Fehler War, ist egal welche Negative Zahl hauptsach negativ
              If V2 = 0 Then
                Showmessage('Error Division by zero');
            End;
          End;
        7: Begin // Logisch AND
            v1 := RechneTree(value^.Left);
            v2 := RechneTree(value^.Right);
            If (V1 >= 0) And (v2 >= 0) Then Begin
              erg := ord((v1 >= 1) And (v2 >= 1));
            End
            Else
              erg := -1; // Merken das ein Fehler War, ist egal welche Negative Zahl hauptsach negativ
          End;
        8: Begin // Logisch OR
            v1 := RechneTree(value^.Left);
            v2 := RechneTree(value^.Right);
            If (V1 >= 0) And (v2 >= 0) Then Begin
              erg := ord((v1 >= 1) Or (v2 >= 1));
            End
            Else
              erg := -1; // Merken das ein Fehler War, ist egal welche Negative Zahl hauptsach negativ
          End;
        9: Begin // Logisch Not
            v1 := RechneTree(value^.right);
            If (V1 >= 0) Then Begin
              erg := ord(V1 = 0);
            End
            Else
              erg := -1; // Merken das ein Fehler War, ist egal welche Negative Zahl hauptsach negativ
          End;
        10: Begin // =
            v1 := RechneTree(value^.Left);
            v2 := RechneTree(value^.Right);
            If (V1 >= 0) And (v2 >= 0) Then Begin
              erg := ord(v1 = v2);
            End
            Else
              erg := -1; // Merken das ein Fehler War, ist egal welche Negative Zahl hauptsach negativ
          End;
        11: Begin // <>
            v1 := RechneTree(value^.Left);
            v2 := RechneTree(value^.Right);
            If (V1 >= 0) And (v2 >= 0) Then Begin
              erg := ord(v1 <> v2);
            End
            Else
              erg := -1; // Merken das ein Fehler War, ist egal welche Negative Zahl hauptsach negativ
          End;
        12: Begin // >
            v1 := RechneTree(value^.Left);
            v2 := RechneTree(value^.Right);
            If (V1 >= 0) And (v2 >= 0) Then Begin
              erg := ord(v1 > v2);
            End
            Else
              erg := -1; // Merken das ein Fehler War, ist egal welche Negative Zahl hauptsach negativ
          End;
        13: Begin // >=
            v1 := RechneTree(value^.Left);
            v2 := RechneTree(value^.Right);
            If (V1 >= 0) And (v2 >= 0) Then Begin
              erg := ord(v1 >= v2);
            End
            Else
              erg := -1; // Merken das ein Fehler War, ist egal welche Negative Zahl hauptsach negativ
          End;
        14: Begin // <
            v1 := RechneTree(value^.Left);
            v2 := RechneTree(value^.Right);
            If (V1 >= 0) And (v2 >= 0) Then Begin
              erg := ord(v1 < v2);
            End
            Else
              erg := -1; // Merken das ein Fehler War, ist egal welche Negative Zahl hauptsach negativ
          End;
        15: Begin // <=
            v1 := RechneTree(value^.Left);
            v2 := RechneTree(value^.Right);
            If (V1 >= 0) And (v2 >= 0) Then Begin
              erg := ord(v1 <= v2);
            End
            Else
              erg := -1; // Merken das ein Fehler War, ist egal welche Negative Zahl hauptsach negativ
          End;
      End;
    End;
    // Da nur ganze Positive Zahlen rauskommen dürfen wissen wir bei Rückgabe einer Negativen Zahl das ein Fehler ist
    result := erg;
  End
  Else
    Result := -1; // Kommt eigentlich nie vor beruhigt sozusagen nur den Compiler
End;

// Diese Function Parst einen String aus und baut daraus einen TRechenTree, Die Wurzel wird dann zurückgegeben.
(*
Es werden Folgende Bindungen Berücksichtigt
von stark nach schwach :

Index   | Operand | Schlüsselzeichen | Bindung

  9         Not             ]          Bindet Am Stärksten
  4          *              *
  5         Mod             &
  6         Div             $
  2          -              -
  3         ^-              !
  1          +              +
 10          =              =
 11         <>              ?
 12         >               >
 13         >=              ~
 14         <               <
 15         <=              #
  7         And             %
  8          Or             [          Bindet am Schwächsten

Ermittelt ist diese Reihenfolge aus der Genauen Analyse des Delphi Kompilers sowie aus Uwe Schönings Buch Logik für Informatiker

*)

Function MakeRechentree(Value: String; Line: int64; Var Error: Boolean; Ebene: String; AlreadyFound: Array Of Prechentree; Const WarningsLogger: TStrings): Prechentree;
Var
  Klammern: Array Of Prechentree; // Dient zum zwischenspeichern aller Klammern

  // Erzeugt einen Pointer der dann entweder eine Variable oder eine Konstante beinhaltet
  Function MakeVar(Data: String): Prechentree;
  Var
    erg: Prechentree;
    b: Boolean;
  Begin
    If Pos(Trennzeichen, Data) <> 0 Then Begin
      error := true;
      WarningsLogger.Add('Found Error in Line [' + inttostr(Line) + '] : ' + 'Invalid Operation.');
      result := Nil;
    End
    Else Begin
      new(erg);
      erg^.IsValue := true;
      // Wir Prüfen auch gleich ob's die Variable überhaubt gibt
      If VarExist(GetLokalGlobalName(ebene + data), Line, WarningsLogger) Then Begin
        b := false;
        erg^.Value := GetVarindex(GetLokalGlobalName(ebene + Data), b);
        If b Then Begin
          error := true;
          WarningsLogger.Add('Found Error in Line [' + inttostr(Line) + '] : ' + 'Value out of range.');
        End;
        // Merken das die Variable benutzt wird
        If Erg^.value >= 0 Then
          compiledcode.vars[Erg^.value].used := true;
      End
      Else Begin
        error := true;
        WarningsLogger.Add('Found Error in Line [' + inttostr(Line) + '] : ' + 'Unknown value "' + Data + '" .');
        erg^.Value := -1; // Zuweisen der 0
      End;
      If Not CheckVarVisible(erg^.Value, line) Then Begin
        WarningsLogger.Add('Found Error in Line [' + inttostr(Line) + '] : ' + 'Unknown value "' + data + '" .');
        Error := True;
        erg^.Value := -1; // Zuweisen der 0
      End;
      erg^.Left := Nil;
      erg^.Right := Nil;
      result := erg;
    End;
  End;

  (*
   * Ersetzt mehrzeichen Operanden durch Einchar Platzhalter
   * -> Dadurch muss der LR-Parser nur ein Lookahead von 1 haben ;)
   *)
  Function Swapop(Data: String): String;
    Procedure SwapSupOP(aFrom: String; aTo: Char);
    Var
      x: int64;
    Begin
      x := LineContainsToken(aFrom, Data);
      While x <> 0 Do Begin
        Delete(data, x, length(aFrom) - 1);
        data[x] := aTo;
        x := LineContainsToken(aFrom, Data);
      End;
    End;

  Begin
    SwapSupOP('^-', '!');
    SwapSupOP('Mod', '&');
    SwapSupOP('Div', '$');
    SwapSupOP('And', '%');
    SwapSupOP('Or', '[');
    SwapSupOP('Not', ']');
    SwapSupOP('<>', '?');
    SwapSupOP('>=', '~');
    SwapSupOP('<=', '#');
    result := data;
  End;

  // Ermittelt die Arrey position der nächsten variable die vor position Count Kommt
  Function getBefore(Data: String; Count: int64): int64;
  Var
    y: int64;
    b: boolean;
    s: String;
  Begin
    s := '-1';
    y := Count - 1;
    b := true;
    While b Do Begin
      dec(Y);
      If Value[Y] = Trennzeichen Then Begin
        s := copy(data, y + 1, count - y - 2);
        b := false;
      End;
    End;
    If Isnum(s) Then
      result := strtoint(s)
    Else
      result := -1;
  End;

  // Ermittelt die Arrey position der nächsten variable die nach position Count Kommt
  Function getafter(Data: String; Count: int64): int64;
  Var
    y: int64;
    b: boolean;
    s: String;
  Begin
    s := '-1';
    y := Count + 1;
    b := true;
    While b Do Begin
      inc(Y);
      If Value[Y] = Trennzeichen Then Begin
        s := copy(data, count + 2, y - count - 2);
        b := false;
      End;
    End;
    If Isnum(s) Then
      result := strtoint(s)
    Else
      result := -1;
  End;

  // Gibt True zurück wenn in Data noch irgendwelche Rechnungszeichen enthalten sind
  Function IsRechnung(Data: String): Boolean;
  Var
    erg: Boolean;
  Begin
    erg := false;
    If Pos('$', data) <> 0 Then erg := true;
    If Pos('&', data) <> 0 Then erg := true;
    If Pos('*', data) <> 0 Then erg := true;
    If Pos('-', data) <> 0 Then erg := true;
    If Pos('!', data) <> 0 Then erg := true;
    If Pos('+', data) <> 0 Then erg := true;
    If Pos('=', data) <> 0 Then erg := true;
    If Pos('?', data) <> 0 Then erg := true;
    If Pos('%', data) <> 0 Then erg := true;
    If Pos('[', data) <> 0 Then erg := true;
    If Pos(']', data) <> 0 Then erg := true;
    If Pos('<', data) <> 0 Then erg := true;
    If Pos('>', data) <> 0 Then erg := true;
    If Pos('~', data) <> 0 Then erg := true;
    If Pos('#', data) <> 0 Then erg := true;
    result := erg;
  End;

  // Prüft ob theoretisch alle Klammern Richtig sind.
  Function Korrektklammern(Value: String): Boolean;
  Var
    erg: Boolean;
    x, i: Integer;
  Begin
    erg := true;
    i := 0;
    For x := 1 To length(Value) Do Begin
      If Value[x] = '(' Then inc(i);
      If Value[x] = ')' Then dec(i);
      If i < 0 Then erg := false;
    End;
    If i <> 0 Then
      erg := false;
    result := erg;
  End;

Const
  Steuerzeichen = ['$', '&', '*', '-', '!', '+', '=', '?', '%', '[', '>', '<', '~', '#'];
Label
  Fehler;
Var
  front, back, y, i: int64;
  x: Integer;
  an: Prechentree;
  s: String;
  b: Boolean;

  // Parst alle vorkommen von OP und ersetzt sie durch einen Knoten mit passender Kennung
  // False im Falle eines Fehlers
  Function HandleOP(op: String; Key: integer): boolean;
  Begin
    result := false;
    While Pos(op, Value) <> 0 Do Begin // Wir müssen von hinten nach Forne gehen
      x := length(Value);
      While x >= 1 Do Begin
        If Value[x] = op Then Begin
          // Wir haben unser Div gefunen nun müssen wir ein Blatt daraus machen.
          front := getBefore(Value, x);
          back := getafter(Value, x);
          If (Front = -1) Or (Back = -1) Then Begin
            Error := true;
            WarningsLogger.Add('Found Error in Line [' + inttostr(line) + '] : ' + 'Missing Value.');
            exit;
          End
          Else Begin
            new(an);
            an^.Left := klammern[front];
            an^.Right := klammern[back];
            an^.IsValue := false;
            an^.Value := Key;
            Setlength(klammern, high(Klammern) + 2);
            klammern[high(Klammern)] := an; // Merken des Pointer's
            i := x + 1;
            b := true;
            While b Do Begin
              inc(i);
              If Value[i] = Trennzeichen Then Begin
                b := false;
              End;
            End;
            y := x - 1;
            b := true;
            While b Do Begin
              dec(Y);
              If Value[Y] = Trennzeichen Then Begin
                b := false;
              End;
            End;
            Delete(Value, y, i - y + 1);
            insert(Trennzeichen + inttostr(high(Klammern)) + Trennzeichen, value, y);
            x := 0; // Dafür sorgen das die While Schleife Abbricht
          End;
        End;
        dec(x);
      End;
    End;
    result := true;
  End;

Begin
  result := Nil;
  // Wenn ein Leerstring übergeben wird
  If Length(Value) = 0 Then Begin
    error := true;
    WarningsLogger.Add('Found Error in Line [' + inttostr(line) + '] : ' + 'Missing Argument .');
    exit;
  End;
  If Not Korrektklammern(Value) Then Begin
    error := true;
    WarningsLogger.Add('Found Error in Line [' + inttostr(line) + '] : ' + 'Missing parenthesis .');
    exit;
  End;
  Klammern := Nil; // initialisieren unseres Merkers für die verscheidenen Wurzel der unterbäume
  // Wenn wir in verschachtelten Ausdrücken sind brauchen wir ein paar Tricks zum Parsen der inneren Variablen
  // So können wir ermitteln welche Pointer es noch in Offenen Klammern gibt
  If high(Alreadyfound) <> -1 Then Begin
    setlength(klammern, high(Alreadyfound) + 1);
    For x := 0 To high(Alreadyfound) Do
      Klammern[x] := Alreadyfound[x];
  End;
  Error := false; // wenn ein Fehler Gefunen wird dann mus das an die Aufrufende Procedure weitergegebn werden können.
  Value := Swapop(Preclear(GetclearedString(Value, true))); // Erst mal unserer String ordentlich Formatieren das wir auch damit Arbeiten können.
  While pos(' ', value) <> 0 Do // Die Leerzeichen können wir nun nicht mehr gebrauchen !!
    delete(Value, pos(' ', value), 1); // Also raus damit
  // zuerst lösen wir mal alle ineren Klammern auf
  While Pos(')', Value) <> 0 Do Begin
    // Suchen der "(" klammer passend zur gefundenen ")"
    x := Pos(')', Value);
    y := -1;
    While x >= 0 Do Begin
      If x = 0 Then Begin // Wenn keine "(" Gefunden wurde
        error := True;
        WarningsLogger.Add('Found Error in Line [' + inttostr(line) + '] : ' + 'Missing "(" .');
        Goto Fehler;
      End
      Else Begin
        // Der Index der "(" Klammer wird gemekrt
        If value[x] = '(' Then Begin
          y := x;
          x := -1;
        End;
      End;
      dec(x);
    End;
    If Not error Then Begin // Wenn eine Gültige Klammer gefunden wurde dann schneiden wir sie Raus
      // Zuerst mus geprüft werden ob in der Klammer überhaupt ein Arithmetischen ausdruck steht
      // Wenn nein können die Klammern einfach entfernt werden.
      x := Pos(')', Value); // Rausschneiden der Inneren Klammer
      s := copy(value, y + 1, x - y - 1); // Die INnere Klammer
      If IsRechnung(s) Then Begin
        Delete(value, y, x - y + 1); // Rauschneiden des Klammerausdruckes und
        Setlength(klammern, high(Klammern) + 2); // Merken welche Wurzel auf die Klammer verweist
        insert(Trennzeichen + inttostr(high(Klammern)) + Trennzeichen, Value, Y); // Einfügen des Verweises auf die Stelle im Globalen Klammer Array
        klammern[high(Klammern)] := MakeRechentree(s, line, error, ebene, Klammern, WarningsLogger); // Berechnen der Klammer
        // Wenn ein Fehler in einer Klammer gefunden wurde und wir hier nicht wegspringen würden
        // Kämen wir in eine Endlosschleife !!
        If Error Then Begin
          Goto Fehler;
        End;
      End
      Else Begin
        // In den Klammern stand nur eine Konstante dann können wir die Klammern einfach entfernen
        delete(value, x, 1);
        delete(Value, y, 1);
      End;
    End;
  End;
  // So nun haben wir definitiv nur noch einen Ausdruck ohne Klammern
  // Als erstes müssen wir alle Variablen in ein Blatt Packen
  Value := value + '+'; // das Brauchen wir damit der Parser die Letzte Variable auch Parst
  b := true;
  While b Do Begin
    b := false;
    x := 2;
    While x <= length(Value) Do Begin
      If Value[x] In Steuerzeichen Then Begin
        If Value[x - 1] <> Trennzeichen Then Begin {// Das zeichen ist schon in einen Knoten Geparst}
          b := true;
          y := x - 1;
          // Wir suchen den Anfang der Variablen
          While b Do Begin
            dec(y);
            If y >= 1 Then Begin
              // Wenn man den Or Block rein macht gibt der Compiler einen Internen Feher aus
              // Warum weis wohl nur Borland, also machen wir halt 2 If Bedingungen Draus
              If (value[y] In (Steuerzeichen)) { Or (value[y] = ']')  } Then Begin
                y := y + 1;
                b := false;
              End;
              If (value[y] = ']') Then Begin
                y := y + 1;
                b := false;
              End;
            End
            Else Begin
              y := 1;
              b := false;
            End;
          End;
          b := true;
          an := MakeVar(uppercase(copy(Value, y, x - y))); // Erstellen eines Blattes mit dem Verweis auf die Variable
          If Not Error Then Begin
            Setlength(klammern, high(Klammern) + 2);
            klammern[high(Klammern)] := an; // Merken des Pointer's
            Delete(value, y, x - y); // Rauschneiden des Klammerausdruckes und
            insert(Trennzeichen + inttostr(high(Klammern)) + Trennzeichen, Value, Y); // Einfügen des Verweises auf die Stelle im Globalen Klammer Array
            x := Length(value);
          End
          Else Begin
            Freerechentree(an);
            an := Nil;
            Goto Fehler;
          End;
        End;
      End;
      inc(x);
    End;
  End;
  Delete(Value, length(Value), 1); // Das Hinten Angefügte + Mus nun wieder Gelöscht werden
  // So da wir nun alle Variablen in Blättern haben können wir die Blätter zusammenbauen
  // Das not ist besonders, da es nur Linksseitig ist, deswegen musste HandleOp hier ausgerollt werden.
  While Pos(']', Value) <> 0 Do Begin // Wir müssen von hinten nach Forne gehen
    x := length(Value);
    While x >= 1 Do Begin
      If Value[x] = ']' Then Begin
        // Wir haben unser Div gefunen nun müssen wir ein Blatt daraus machen.
        back := getafter(Value, x);
        If (Back = -1) Then Begin
          Error := true;
          WarningsLogger.Add('Found Error in Line [' + inttostr(line) + '] : ' + 'Missing Value.');
          Goto Fehler;
        End
        Else Begin
          new(an);
          an^.left := Nil; // Das not ist einstellig da braucht es keinen Linken zweig
          an^.Right := klammern[back];
          an^.IsValue := false;
          an^.Value := 9; // Ist die Schlüsselnummer für Not
          Setlength(klammern, high(Klammern) + 2);
          klammern[high(Klammern)] := an; // Merken des Pointer's
          i := x + 1;
          b := true;
          While b Do Begin
            inc(i);
            If Value[i] = Trennzeichen Then Begin
              b := false;
            End;
          End;
          y := x;
          Delete(Value, y, i - y + 1);
          insert(Trennzeichen + inttostr(high(Klammern)) + Trennzeichen, value, y);
          x := 0; // Dafür sorgen das die While Schleife Abbricht
        End;
      End;
      dec(x);
    End;
  End;
  // Das *
  If Not HandleOP('*', 4) Then Goto Fehler;
  // Das Mod
  If Not HandleOP('&', 5) Then Goto Fehler;
  // Das Div
  If Not HandleOP('$', 6) Then Goto Fehler;
  // Das -
  If Not HandleOP('-', 2) Then Goto Fehler;
  // Das ^-
  If Not HandleOP('!', 3) Then Goto Fehler;
  // Das +
  If Not HandleOP('+', 1) Then Goto Fehler;
  // Das =
  If Not HandleOP('=', 10) Then Goto Fehler;
  // Das <>
  If Not HandleOP('?', 11) Then Goto Fehler;
  // Das >
  If Not HandleOP('>', 12) Then Goto Fehler;
  // Das >=
  If Not HandleOP('~', 13) Then Goto Fehler;
  // Das <
  If Not HandleOP('<', 14) Then Goto Fehler;
  // Das <=
  If Not HandleOP('#', 15) Then Goto Fehler;
  // Das And
  If Not HandleOP('%', 7) Then Goto Fehler;
  // Das or
  If Not HandleOP('[', 8) Then Goto Fehler;
  // Wir sind Fertig das was nun in Value steht ist der Einsprungpointer in unsere Rechnung.
  s := Value;
  // Entfernen der "Trennzeichen"
  delete(s, 1, 1);
  Delete(s, length(s), 1);
  result := klammern[strtoint(s)];
  Fehler:
  // wenn ein Fehler War dann müssen wir die Pointer wieder Frei geben
  If Error Then Begin
    For x := 0 To high(Klammern) Do Begin
      Freerechentree(klammern[x]);
    End;
  End;
  setlength(Klammern, 0);
End;

End.

