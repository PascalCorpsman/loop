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
Unit ucompiler;

{$MODE objfpc}{$H+}

Interface

Uses
  Sysutils
  , Classes
  , RechenBaum
  , PrePrescanner
  , {Debuggen} Dialogs {Debuggen Ende}
  ;

Type

  // Der Tüp der Alle Informationen einer Variablen beinhaltet
  TVars = Record
    Value: int64; // Wert der Variablen
    Name: String; // Name der Variablen
    Line: Int64; // Zeile in der Die Variable deklariert wurde
    Used: Boolean; // Wenn True dann wurde die Variable benutzt
  End;

  // diesen zwischentyp brauchen wir damit wir mehrere Untypisierte Pointer zusammenfassen können.
  Pbefehl = ^TBefehl;

  TBefehl = Record
    ID: int64; // Typ des Befehll's
    Code: Pointer; //Pointer auf den Code des Befehl's
  End;

  Tpara = Array Of String; // Man mus das so Typisieren sonst kann man das Array nicht als Parameter übergeben

  // zum zwischenspeichern einer Function damit der Parser nachher weis von
  // wo er den Code für die Function her hohlen kann.
  Tfunc = Record
    Name: String;
    beg: int64; // Gibt die zeile an in der Das Begin der Funciton steht
    uebergabeparameter: Tpara; // Gibt die Übergabeparameter an
    Used: Boolean; // Wenn True dann wurde die Function verwendet
    RealLine: int64; // Gibt die zeile an in der Die Funciton wirklich steht
  End;

  // Der Typ unseres Hauptprogrammes
  TProc = Record
    vars: Array Of Tvars; // Alle Variablen die es Gibt
    GETVars: Array Of Tvars; // Gibt alle Variablen an die via Get eingelesen werden müssen
    Code: PBefehl; // Einsprungpointer in den Code
    Func: Array Of TFunc;
  End;

  // ID = 1
  PAnweisung = ^TAnweisung;

  TAnweisung = Record // Bedeutung
    Rechnung: Prechentree; // Ergebniss := Rechnung ;
    Ergebniss: int64; // Der Indexwert der Ergebniss Variable im Globalen Variablen Array
    Line: int64; // Die Zeile in der die Anweisung im Quellcode steht
    Next: PBefehl; // Der Code der Nach der Anweisung ausgeführt werden soll
  End;

  // ID = 2
  PLoop = ^Tloop;

  TLoop = Record
    Wiederhohlungen: int64; // die Anzahl wie oft der Code in Code noch durchgeführt werden mus
    WiederhohlungenVar: int64; // Die Variable aus der zu begin der Loop Schleife ausgelesen wird wieviele Wiederhohlungen es sind.
    Code: Pbefehl; // Der Code der in der Loop schleife ausgeführt werden soll
    Next: Pbefehl; // Der Code der nach der Loop schleife ausgeführt werden soll
    Line: int64; // Die Zeile in der die Anweisung im Quellcode steht
  End;

  // ID = 3
  Pif = ^TIf;

  TIF = Record
    Bedingung: Prechentree; // Der Code der Anweisung
    BedNext: PBefehl; // Der Code der im Bedingung = True Fall ausgeführt werden soll
    ElseNext: PBefehl; // Der Code der im ELSE Zweig ausgeführt werden soll
    Next: PBefehl; // Der Code der Nach der If ausgeführt werden soll
    Line: int64; // Die Zeile in der die Anweisung im Quellcode steht
  End;

  // ID = 4
  PFunction = ^Tfunction;

  Tfunction = Record
    Initialisation: Pbefehl; // dieser Code initialisiert alle Variablen der Function
    code: Pbefehl;
    Next: Pbefehl;
    Aftercode: Pbefehl; // Dieser Teil Beehndet dann die Funciton durch das setzen der Ergebnis Variable
    line: int64;
  End;

Var
  CompiledCode: TProc;

  // Gibt 0 Zurück wenn der Code Compilierbar ist, und erstellt gleichzeitig die entsprechende Tokenstruktur
Function Compile(Lines: Tstrings; Const WarningsLogger: TStrings): boolean;
// Löscht den Speicher der Compilierbaren Zeilen ( Visueller Effect)
Procedure ClearCompilableLines;
// Gibt die Variable CompiledCode frei
Procedure FreeCompiledcode;
// Gibt True zurück wenn die Variable Existiert sonst False, ist allerdings Value ne Konstante wird Auch True zurückgegeben
Function VarExist(Value: String; CodeLine: integer; Const WarningsLogger: TStrings): Boolean;
// Gibt die Variable zurück die dann entweder die Globale übergeordnete ist oder eben die Lokale wie zuvor
Function GetLokalGlobalName(Varvalue: String): String;
// Prüft ob die Variable überhauot von Line aus Sichtbar ist , wenn Ja -> True
Function CheckVarVisible(Varindex, Line: int64): Boolean;
// Function extrahiert die Echte Zeile aus der Aktuellen Zeile
Function getline(Value: String): integer;

Implementation

Uses
  Parser
  , Executer
  , uloop
  ;

// Prüft ob die Variable überhauot von Line aus Sichtbar ist , wenn Ja -> True

Function CheckVarVisible(Varindex, Line: int64): Boolean;
Begin
  If Varindex < 0 Then
    Result := true
  Else Begin
    result := CompiledCode.vars[varindex].Line < line;
  End;
End;

// Fügt der Liste der Compilierbaren Zeilen eine Hinzu

Procedure AddCompilableLine(Value: integer);
Begin
  //  If Not Is IsCompilableLine Then Begin // Es bleibt zu Prüfen ob diese If Abfrage notwendig ist !!
  setlength(CompilableLines, high(CompilableLines) + 2);
  CompilableLines[High(CompilableLines)] := Value;
  //  End;
End;

// Gibt allen Code Frei.

Procedure FreeCompiledcode;
// Das eigentliche Freigeben , mus ne Extra unterprocedur sein damit wir Rekursiv freigeben können ;)
  Procedure Frei(Value: PBefehl);
  Begin
    If Value <> Nil Then Begin
      Case value^.ID Of
        0: Begin
            { Dieser Fall Tritt auf wenn der Code ungültig war
              der Case macht gar nichts , da ich aber unten die Nachricht anzeige wenn ein Fall Auftritt
              in dem Pointer nicht Freigegeben werden mus ich es hier so rausnehmen. }
          End;
        1: Begin
            // Freigeben der Berechnung in der Anweisung;
            Freerechentree(panweisung(value^.Code)^.rechnung);
            // Freigeben des Codes der Anweisung
            frei(panweisung(value^.Code)^.Next);
            // Freigebend er Anweisung.
            Dispose(panweisung(value^.Code));
          End;
        2: Begin // Freigeben eines Loop Konstruktes
            Frei(PLoop(value^.Code)^.Code);
            Frei(PLoop(value^.Code)^.Next);
            Dispose(PLoop(value^.Code));
          End;
        3: Begin // Freigeben eines If Konstruktes
            Freerechentree(Pif(value^.Code)^.Bedingung);
            Frei(Pif(value^.Code)^.BedNext);
            Frei(Pif(value^.Code)^.ElseNext);
            Frei(Pif(value^.Code)^.Next);
            Dispose(Pif(value^.Code));
          End;
        4: Begin // Freigeben deines Functionsaufrufes
            Frei(pfunction(Value^.Code)^.Initialisation);
            Frei(pfunction(Value^.Code)^.code);
            Frei(pfunction(Value^.Code)^.Next);
            Frei(pfunction(Value^.Code)^.Aftercode);
            Dispose(pfunction(Value^.Code));
          End;
      Else
        // nur für Debugg zwecke taucht hoffentlich nie auf
        showmessage('Error in FreeCompiledcode der Case ' + inttostr(value^.ID) + ' wird nicht Freigegeben.');
      End;
      // Freigabe des Pointers auf PBefehl
      dispose(value);
    End;
  End;
Var
  x: integer;
Begin
  // Löschen aller Variablen
  setlength(CompiledCode.vars, 0);
  // Löschen aller Get Variablen
  setlength(CompiledCode.getvars, 0);
  // Löschen aller Functionen
  For x := 0 To high(CompiledCode.Func) Do
    setlength(CompiledCode.Func[x].uebergabeparameter, 0);
  setlength(CompiledCode.Func, 0);
  // Freigeben des Codes
  Frei(CompiledCode.Code);
  CompiledCode.Code := Nil;
End;

// Löscht das Array der Kompilierbaren Linien

Procedure ClearCompilableLines;
Begin
  setlength(CompilableLines, 0);
End;

// Gibt die Orginal Quellcde Zeile zurück

Function getline(Value: String): integer;
Begin
  result := strtointdef(copy(value, pos(LineSeparator, value) + 1, length(Value)), 0) + 1;
End;

// Diese function löst hoffentlich alle noch offenen CompilerProbleme

Function IsCompilableLine(Value: String; Const WarningsLogger: TStrings): Boolean;
Var
  Erg: Boolean;
  Token: integer;
  tstring, v1, arbeitsvar: String;

  Procedure Test(OP: String);
  Var
    j: integer;
  Begin
    If LineContainsToken(OP, Tstring) <> 0 Then Begin
      v1 := copy(tstring, 1, LineContainsToken(OP, Tstring) - 1);
      // Löschen der 1. Variable und dem OP
      delete(Tstring, 1, length(v1) + length(OP));
      Tstring := DelFrontspace(DelEndspace(Tstring));
      v1 := DelEndspace(DelEndspace(v1));
      // Die Erste Variable einer Summe mus immer ein Identifer = Variable sein !!
      If Not checkIdentifier(V1) Then Begin
        erg := false;
        WarningsLogger.add('Found Error in Line [' + inttostr(getline(Value)) + '] : ' + ' "' + v1 + '" Invalid identifier.');
      End;
      If allow2varnotconst Then Begin
        // eigentlich sollte man hier ne andere Variable wie j nehmen, aber die Braucht nu eh keiner Mehr
        v1 := Tstring;
        For j := 0 To 9 Do Begin
          While pos(inttostr(j), Tstring) <> 0 Do
            delete(Tstring, pos(inttostr(j), Tstring), 1);
        End;
        If length(Tstring) <> 0 Then Begin
          Tstring := v1;
          If Not checkIdentifier(Tstring) Then Begin
            erg := false;
            WarningsLogger.add('Found Error in Line [' + inttostr(getline(Value)) + '] : ' + ' "' + v1 + '" Invalid identifier.');
          End;
        End;
      End
      Else Begin
        // eigentlich sollte man hier ne andere Variable wie j nehmen, aber die Braucht nu eh keiner Mehr
        v1 := Tstring;
        For j := 0 To 9 Do Begin
          While pos(inttostr(j), Tstring) <> 0 Do
            delete(Tstring, pos(inttostr(j), Tstring), 1);
        End;
        If length(Tstring) <> 0 Then Begin
          erg := false;
          WarningsLogger.add('Found Error in Line [' + inttostr(getline(Value)) + '] : ' + ' "' + V1 + '" is not a const, go to extended Options to allow this.');
        End;
      End;
    End;
  End;

Begin
  // WEgschneiden der Zeilen information
  arbeitsvar := copy(Value, 1, pos(LineSeparator, value) - 1);
  erg := True;
  // Ermitteln des Types der Zeile
  If Length(arbeitsvar) <> 0 Then Begin
    Token := -1; // Beruhigt den Kompiler
    // Da es egal ist wie Die zeile genau aussieht können wir die Zeile auch Vorher Formatieren
    arbeitsvar := GetclearedString(arbeitsvar, true); // Ohne diese zeile ist alles daunter sinnlos !!!
    // damit wir den End Token Finden müssen wir ein wenig Tricksen
    If Pos(';', arbeitsvar) <> 0 Then Begin
      insert(' ', arbeitsvar, Pos(';', arbeitsvar));
      // Wir Prüfen ob nach dem ; noch was steht was da net hingehört
      Tstring := copy(arbeitsvar, Pos(';', arbeitsvar) + 1, length(arbeitsvar));
      Tstring := DelFrontspace(tstring);
      If LEngth(Tstring) <> 0 Then Begin
        erg := false;
        WarningsLogger.add('Found Error in Line [' + inttostr(getline(Value)) + '] : ' + 'Unknown "' + Tstring + '".');
      End;
    End;
    // Schaun welches Token wir haben
    // Der Zuweisungstoken
    If LineContainsToken(':=', arbeitsvar) <> 0 Then Token := 1;
    // Das ELSE Token ist ganz einfach es mus allein in einer Zeile stehn
    If LineContainsToken('Else', arbeitsvar) <> 0 Then Token := 4;
    If LineContainsToken('End', arbeitsvar) <> 0 Then Token := 5;
    If LineContainsToken('If', arbeitsvar) <> 0 Then Token := 6;
    // Überprüfen der Tokens
    Case Token Of
      1: Begin // Der AnweisungsToken
          // löschen der Rand Leerzeichen
          tstring := DelFrontspace(DelEndspace(arbeitsvar));
          If Pos(';', Tstring) = 0 Then Begin
            erg := false;
            WarningsLogger.add('Found Error in Line [' + inttostr(getline(Value)) + '] : ' + 'Missing ";".');
          End;
          delete(Tstring, pos(';', Tstring), 1); // Löschen des ; Zeichens
          tstring := DelEndspace(tstring);
          v1 := Copy(tstring, 1, pos(':', Tstring) - 1);
          // Löschen des zuweisungsteiles
          Delete(tstring, 1, length(V1) + 2);
          Tstring := DelFrontspace(Tstring);
          If Length(tstring) = 0 Then Begin
            erg := false;
            WarningsLogger.add('Found Error in Line [' + inttostr(getline(Value)) + '] : ' + 'Missing argument.');
          End;
          v1 := DelEndspace(v1);
          If Not checkIdentifier(V1) Then Begin
            erg := false;
            WarningsLogger.add('Found Error in Line [' + inttostr(getline(Value)) + '] : ' + ' "' + v1 + '" Invalid identifier.');
          End;
          // Es Gibt 2 möglichkeiten der Zuweisung
          If LineContainsToken('Get', Tstring) <> 0 Then Begin
            delete(Tstring, 1, 3); // Löschen des Wortes Get
            tstring := DelFrontspace(Tstring);
            If length(tstring) <> 0 Then Begin
              erg := false;
              WarningsLogger.add('Found Error in Line [' + inttostr(getline(Value)) + '] : ' + 'Unknown Command "' + Tstring + '" identifier.');
            End;
          End
          Else Begin
            // Eine Anweisung besteht immer aus Variable := Variable + Konstante
            If Not allowklammern Then Begin
              // Testen bei ungültig
              v1 := uppercase(Tstring);
              If Not ((Pos('+', Tstring) <> 0) Or (Pos('*', Tstring) <> 0) Or (Pos('-', Tstring) <> 0) Or (Pos('^-', Tstring) <> 0) Or (Pos(' DIV ', V1) <> 0) Or (Pos(' MOD ', V1) <> 0)) Then Begin
                // Da wir Zuweisungen der ART X0:= 1 erlauben wollen müssen wir hier den Parser Verarschen.
                For Token := 0 To 9 Do Begin
                  While pos(inttostr(Token), v1) <> 0 Do
                    delete(v1, pos(inttostr(Token), v1), 1);
                End;
                If Length(V1) <> 0 Then
                  If Not checkIdentifier(Tstring) Then Begin
                    erg := false;
                    WarningsLogger.add('Found Error in Line [' + inttostr(getline(Value)) + '] : ' + ' "' + Tstring + '" Invalid Argument.');
                  End;
              End;
              // Ermitteln des Operators der zur Verfügung steht
              // Da hätten wir : + , - , ^- DIV , MOD
              Test('+');
              Test('-');
              Test('*');
              Test('^-');
              Test('Mod');
              Test('Div');
            End
            Else Begin
              // Der Fall das Mehrfach zuweisungen Erlaubt sind, der Kommt irgendwann auch noch rein
              // Mus nicht berücksichtigt werden da der TRechenTree das zum Glück macht ;)
            End;
          End;
        End;
      2: Begin // Der Deklarationsteil einer Loop Bedingung
        End;
      3: Begin // Der Deklarationsteil einer If Bedingung
        End;
      4: Begin // Das Else Token
          // löschen der Rand Leerzeichen
          tstring := DelFrontspace(DelEndspace(arbeitsvar));
          Delete(tstring, LineContainsToken('Else', Tstring), 4);
          If Pos(';', Tstring) <> 0 Then Begin
            erg := false;
            WarningsLogger.add('Found Error in Line [' + inttostr(getline(Value)) + '] : ' + '";" not allowed.');
          End;
          Tstring := DelFrontspace(Tstring);
          If Length(Tstring) <> 0 Then Begin
            erg := false;
            WarningsLogger.add('Found Error in Line [' + inttostr(getline(Value)) + '] : ' + ' Unknown value "' + Tstring + '" .');
          End;
        End;
      5: Begin // Das End Token
          // löschen der Rand Leerzeichen
          tstring := DelFrontspace(DelEndspace(arbeitsvar));
          Delete(tstring, LineContainsToken('End', Tstring), 3);
          If Pos(';', Tstring) <> 0 Then Begin
            Delete(Tstring, Pos(';', Tstring), 1);
          End
          Else Begin
            erg := false;
            WarningsLogger.add('Found Error in Line [' + inttostr(getline(Value)) + '] : ' + ' Missing ";".');
          End;
          Tstring := DelFrontspace(Tstring);
          If Length(Tstring) <> 0 Then Begin
            erg := false;
            WarningsLogger.add('Found Error in Line [' + inttostr(getline(Value)) + '] : ' + ' Unknown value "' + Tstring + '" .');
          End;
        End;
      6: Begin
          If LineContainsToken('Then', Arbeitsvar) = 0 Then Begin
            erg := false;
            WarningsLogger.add('Found Error in Line [' + inttostr(getline(Value)) + '] : ' + ' Missing "Then".');
          End;
        End;
    End;
  End;
  result := erg;
End;

Function Prescan(Lines: Tstrings; Const WarningsLogger: TStrings): Boolean;
Var
  y: Integer;
  tline, aline: String;
  Procfound: Boolean;
  tiefe: Integer;
  erg: Boolean;
  allowget: Boolean;
  noemptyline: Boolean;
  infuncbeg: Boolean;
  infunc: Boolean;
  firstbegin: Boolean;
  x0found: Boolean;
Begin

  {

  Der If then Else Block mus geprüft werden.

  Fehler wie
  If then
  else
  else
  end;

  müssen erkannt werden !!!
  ES Fehlt noch das rausgefunden wird ob Funcitonsnamen Doppelt sind !!

  Gültiger Code der aber nicht in einem Begin Block steht mus erkannt werden !!
  }
  noemptyline := false;
  infuncbeg := false;
  infunc := false;
  erg := false;
  x0found := false;
  y := 0;
  Procfound := false;
  Tiefe := 0;
  firstbegin := false;
  allowget := false;
  While y < Lines.Count Do Begin
    aline := uppercase(GetclearedString(Lines[y], true));
    tline := aline;
    // Wir Erlauben keine 2 Befehle in einer Zeile
    If Pos(';', Aline) <> 0 Then Begin
      Delete(aline, Pos(';', Aline), 1);
      If Pos(';', Aline) <> 0 Then Begin
        erg := true;
        WarningsLogger.Add('Found Error in Line [' + inttostr(getline(Aline)) + '] : ' + 'Only one Statement per Line Allowed');
      End;
    End;
    aline := tline;
    // Wenn die Zeile schon gar nicht Kompilierbar ist
    If Not IsCompilableLine(Lines[y], WarningsLogger) Then Begin
      erg := true;
    End;
    // Löschen der Leerzeichen vor dem ;
    While pos(' ;', aline) <> 0 Do
      delete(aline, pos(' ;', aline), 1);
    // Wieder 1 wegrücken des ; damit wir die Tokens besser erkennen können
    If Pos(';', aline) <> 0 Then
      insert(' ', aline, Pos(';', aline));
    // Rannrücken des :=
    While pos(' :=', aline) <> 0 Do
      delete(aline, pos(' :=', aline), 1);
    // prüfen ob X0 überhaupt benutzt wurde.
    If (pos('X0:=', aline) <> 0) Then x0found := true;
    // überprüfen ob auch wirklich nur ein Procedur Name Vergeben ist.
    If (Pos(' PROCEDURE ', Aline) <> 0) Or (Pos('PROCEDURE ', Aline) = 1) Then Begin
      If Procfound Then Begin
        erg := true;
        WarningsLogger.Add('Found Error in Line [' + inttostr(getline(Aline)) + '] : ' + 'Only one Procedure Allowed.');
      End
      Else Begin
        Procfound := true;
        inc(Tiefe); // Tiefe erhöht sich um eins.
      End;
    End;
    If (Pos(' FUNCTION ', Aline) <> 0) Or (Pos(' FUNCTION(', Aline) <> 0) Or (Pos('FUNCTION ', Aline) = 1) Then Begin
      inc(Tiefe); // Tiefe erhöht sich um eins.
      If Infunc Then Begin
        erg := true;
        WarningsLogger.Add('Found Error in Line [' + inttostr(getline(Aline)) + '] : ' + 'You cannot declare Functions in Functions.');
      End;
      If Not allowfunction Then Begin
        erg := true;
        WarningsLogger.Add('Found Error in Line [' + inttostr(getline(Aline)) + '] : ' + 'Functions are not allowed, go to Options to allow it.');
      End;
      infunc := true;
    End;
    // prüfen auf Gültige Begin End Blöcke
    If LineContainsToken('End', aline) <> 0 {(Pos(' END;', aline) <> 0) Or (Pos('END;', aline) = 1) } Then Begin
      dec(tiefe);
      If Tiefe = 1 Then Begin
        infunc := false;
        infuncbeg := false;
      End;
    End;
    If Pos(' DO ', aline) <> 0 Then inc(tiefe);
    If Pos(' THEN ', aline) <> 0 Then inc(tiefe);
    { Verstehe Ich Net !!!

        If (Pos(' BEGIN ', aline) <> 0) Or (Pos('BEGIN ', aline) = 1) Then Begin
          inc(tiefe);
        End;
    }
        // Prüfen auf die Ganzen Einstellungen die Optional sind
        {^-                     = Fertig
        *                       = Fertig
        Multiple Operand
        If Then Else not =      = Fertig
        > < <= >=               = Fertig
        MOD                     = Fertig
        DIV                     = Fertig
        FUNCTION                = Fertig
        Other Var Names         = Fertig
        }
    If Not allowminus And (pos('^-', aline) <> 0) Then Begin
      erg := true;
      WarningsLogger.Add('Found Error in Line [' + inttostr(getline(Aline)) + '] : ' + 'Modified "^-" is not allowed, go to Options to allow it.');
    End;
    If Not allowMulti And (pos('*', aline) <> 0) Then Begin
      erg := true;
      WarningsLogger.Add('Found Error in Line [' + inttostr(getline(Aline)) + '] : ' + 'Multiplication "*" is not allowed, go to Options to allow it.');
    End;
    If Not allowdiv And (pos(' DIV ', aline) <> 0) Then Begin
      erg := true;
      WarningsLogger.Add('Found Error in Line [' + inttostr(getline(Aline)) + '] : ' + 'Div operator is not allowed, go to Options to allow it.');
    End;
    If Not allowif And ((pos('IF ', aline) = 1) Or (pos(' IF ', aline) <> 0)) Then Begin
      erg := true;
      WarningsLogger.Add('Found Error in Line [' + inttostr(getline(Aline)) + '] : ' + 'IF operator is not allowed, go to Options to allow it.');
    End;
    If Not allowif And ((pos('THEN ', aline) = 1) Or (pos(' THEN ', aline) <> 0)) Then Begin
      erg := true;
      WarningsLogger.Add('Found Error in Line [' + inttostr(getline(Aline)) + '] : ' + 'IF operator is not allowed, go to Options to allow it.');
    End;
    If Not allowif And ((pos('ELSE ', aline) = 1) Or (pos(' ELSE ', aline) <> 0)) Then Begin
      erg := true;
      WarningsLogger.Add('Found Error in Line [' + inttostr(getline(Aline)) + '] : ' + 'IF operator is not allowed, go to Options to allow it.');
    End;
    If Not allowMod And (pos(' MOD ', aline) <> 0) Then Begin
      erg := true;
      WarningsLogger.Add('Found Error in Line [' + inttostr(getline(Aline)) + '] : ' + 'Mod operator is not allowed, go to Options to allow it.');
    End;
    If Not allowgroeserKleiner And ((pos(' > ', aline) <> 0) Or
      (pos(' < ', aline) <> 0) Or (pos(' >= ', aline) <> 0) Or (pos(' <= ', aline) <> 0)) Then Begin
      erg := true;
      WarningsLogger.Add('Found Error in Line [' + inttostr(getline(Aline)) + '] : ' + 'Mod operator is not allowed, go to Options to allow it.');
    End;
    If (pos(' NOT ', aline) <> 0) Or (pos(' NOT(', aline) <> 0) Then Begin
      erg := true;
      WarningsLogger.Add('Found Error in Line [' + inttostr(getline(Aline)) + '] : ' + '"Not" not allowed use "<>" or other equivalent.');
    End;
    // Findet Functionen die Fälschlicherweise im Quellcode Teil vom Hauptprogramm geschrieben sind
    If (firstbegin) And ((Pos(' FUNCTION ', aline) <> 0) Or (Pos('FUNCTION ', aline) = 1)) Then Begin
      erg := true;
      WarningsLogger.Add('Found Error in Line [' + inttostr(getline(Aline)) + '] : ' + 'Functions only in var deklarations part from the main Procedure allowed.');
    End;
    // Findet Var variablen die im Quelltext stehen und da net Rein gehören
    If ((Firstbegin) Or (infuncbeg)) And (((Pos(' VAR ', aline) <> 0) Or (Pos('VAR ', aline) = 1))) Then Begin
      erg := true;
      WarningsLogger.Add('Found Error in Line [' + inttostr(getline(Aline)) + '] : ' + 'Variables can be defined only before the "Begin" block.');
    End;
    // Findet Functionen die im Hauotprogramm stehen
    If (Firstbegin) And (((Pos(' FUNCTION ', aline) <> 0) Or (Pos('FUNCTION ', aline) = 1))) Then Begin
      erg := true;
      WarningsLogger.Add('Found Error in Line [' + inttostr(getline(Aline)) + '] : ' + 'Functions can be defined only before the "Begin" block.');
    End;
    If LineContainsToken('Get', aline) <> 0 Then Begin
      If Not allowget Then Begin
        erg := true;
        WarningsLogger.Add('Found Error in Line [' + inttostr(getline(Aline)) + '] : ' + '"Get" operand is only at the begin of Procedure allowed.');
      End;
    End
    Else Begin
      If Length(delfrontspace(copy(aline, 1, pos(LineSeparator, aline) - 1))) <> 0 Then Begin
        allowget := false;
      End;
    End;
    If (pos('BEGIN ', aline) = 1) Or (pos(' BEGIN ', aline) <> 0) Then Begin
      noemptyline := True;
      If infunc Then infuncbeg := true;
      // Ermittelt das Begin das zur Hauptfunction gehört
      If tiefe = 1 Then Begin
        firstbegin := true;
        allowget := true;
      End;
    End;
    inc(y);
  End;
  If Not x0found Then Begin
    WarningsLogger.Add('Errorcode [0] : Warning X0 never assigned a value.');
  End;
  // wenn Anzahl End <> Anzahl Begin
  If tiefe < 0 Then Begin
    erg := true;
    WarningsLogger.Add('Found Error in Line [' + inttostr(getline(Aline)) + '] : ' + 'More "End" than "Begin, Or, Procedure, Function, Then " found.');
  End;
  If tiefe > 0 Then Begin
    erg := true;
    WarningsLogger.Add('Found Error in Line [' + inttostr(getline(Aline)) + '] : ' + 'Less "End" than "Begin, Or, Procedure, Function, Then " found.');
  End;
  // Wenn gar keine Procedur gefunden Wurde.
  If Not Procfound Then Begin
    erg := true;
    WarningsLogger.Add('Found Error in Line [' + inttostr(getline(Aline)) + '] : ' + 'No name for Main Procedure found.');
  End;
  If Not noemptyline Then Begin
    erg := true;
    WarningsLogger.Add('Found Error in Line [1] : ' + 'Could not find any compilable code.');
  End;
  result := erg;
End;

// Gibt True zurück wenn die Variable Existiert sonst False, ist allerdings Value ne Konstante wird Auch True zurückgegeben

Function VarExist(Value: String; CodeLine: integer; Const WarningsLogger: TStrings): Boolean;
Var
  erg: Boolean;
  x: integer;
  s: String;
Begin
  If checkIdentifier(value) Then Begin
    s := uppercase(Value);
    erg := false;
    For x := 0 To high(CompiledCode.vars) Do
      If CompareStr(s, CompiledCode.vars[x].Name) = 0 Then erg := true;
    If Not erg Then
      WarningsLogger.Add('Found Error in Line [' + inttostr(CodeLine) + '] : ' + 'Unknown value "' + Value + '" .');
    result := erg;
  End
  Else Begin
    // Löschend er evtlen information das diese Konstante in einer Funciton steht
    If Pos(LineSeparator, value) <> 0 Then
      delete(Value, 1, Pos(LineSeparator, value));
    If isnum(Value) Then
      result := true
    Else
      result := false;
  End;
End;

// gibt True zurück wenn die Variable existiert.

Function VarExist2(Value: String; CodeLine: integer): Boolean;
Var
  erg: Boolean;
  x: integer;
  s: String;
Begin
  If checkIdentifier(value) Then Begin
    s := uppercase(Value);
    erg := false;
    For x := 0 To high(CompiledCode.vars) Do
      If CompareStr(s, CompiledCode.vars[x].Name) = 0 Then erg := true;
    result := erg;
  End
  Else Begin
    result := false;
  End;
End;

// Gibt die Variable zurück die dann entweder die Globale übergeordnete ist oder eben die Lokale wie zuvor

Function GetLokalGlobalName(Varvalue: String): String;
Begin
  If Pos(LineSeparator, Varvalue) = 0 Then
    result := Varvalue
  Else Begin
    If Varexist2(Varvalue, 0) Then
      result := Varvalue
    Else Begin // Wir haben genau den Fall erwischt das wir ne Globale Variable suchen.
      result := copy(Varvalue, pos(LineSeparator, Varvalue) + 1, length(Varvalue));
    End;
  End;
End;

// Gibt true Zurück wenn der Code Compilierbar ist, und erstellt gleichzeitig die entsprechende Tokenstruktur

Function Compile(Lines: Tstrings; Const WarningsLogger: TStrings): boolean;
// Gibt True zurück wenn ein Fehler war.
  Function getprocvars(Value: Integer): Boolean;
  Var
    b, erg: Boolean;
    d, r, s: String;
    x, line: Integer;
  Begin
    erg := false;
    b := true;
    While b Do Begin
      s := GetclearedString(lines[value], true);
      line := getline(s);
      d := copy(S, 1, pos(LineSeparator, s) - 1);
      // löschendes Evtlenen Schlüsselwortes Var
      If LineContainsToken('Var', d) <> 0 Then Begin
        delete(d, LineContainsToken('Var', d), 3);
      End;
      If Pos(';', d) <> 0 Then d[Pos(';', d)] := ',';
      If Length(d) <> 0 Then Begin
        d := d + LineSeparator + ',';
        While Length(d) <> 0 Do Begin
          r := copy(d, 1, pos(',', d));
          delete(d, 1, length(r));
          delete(r, length(r), 1);
          r := uppercase(DelFrontspace(DelEndspace(r)));
          If r <> LineSeparator Then
            If Length(r) <> 0 Then Begin
              If r = 'X0' Then
                WarningsLogger.Add('Errorcode [' + inttostr(line) + '] : Warning X0 need not to be specifieed in var')
              Else Begin
                If VarExist2(uppercase(r), line) Then Begin
                  WarningsLogger.Add('Found Error in Line [' + inttostr(line) + '] : ' + 'double existing var name.');
                  erg := true;
                End
                Else Begin
                  If Pos(LineSeparator, r) <> 0 Then Begin
                    delete(r, Pos(LineSeparator, r), length(r));
                    r := DelEndspace(r);
                  End;
                  If (Uppercase(r) = 'RESULT') Or (Uppercase(r) = 'DO') Or (Uppercase(r) = 'LOOP') Or
                    (Uppercase(r) = 'FUNCTION') Or (Uppercase(r) = 'PROCEDURE') Or (Uppercase(r) = 'THEN') Or
                    (Uppercase(r) = 'ELSE') Or (Uppercase(r) = 'END') Or (Uppercase(r) = 'BEGIN') Or
                    (Uppercase(r) = 'VAR') Or (Uppercase(r) = 'GET') Or (Uppercase(r) = 'IF') Or
                    (Uppercase(r) = 'THEN') Or (Uppercase(r) = 'OR') Or (Uppercase(r) = 'AND') Or
                    (Uppercase(r) = 'MOD') Or (Uppercase(r) = 'DIV') Then Begin
                    WarningsLogger.Add('Found Error in Line [' + inttostr(line) + '] : ' + '"' + r + '" is a reserved word it cannont be used as a var name.');
                    erg := true;
                  End
                  Else Begin
                    // Hinzufügen der Variable in das Globale Array
                    setlength(CompiledCode.vars, high(CompiledCode.vars) + 2);
                    CompiledCode.vars[high(CompiledCode.vars)].Value := 0;
                    CompiledCode.vars[high(CompiledCode.vars)].Name := uppercase(r);
                    CompiledCode.vars[high(CompiledCode.vars)].Line := line;
                    // Überprüfen ob wir auch lauter gültige Variablennamen haben
                    For x := 0 To high(CompiledCode.vars) Do Begin
                      If Not allowothernames Then
                        If Not CheckVarName(CompiledCode.vars[x].Name) Then Begin
                          erg := true;
                          WarningsLogger.Add('Found Error in Line [' + inttostr(line) + '] : ' + 'Other var names not allowed, go to Options to allow it.');
                        End;
                      If Not checkIdentifier(CompiledCode.vars[x].Name) Then Begin
                        erg := true;
                        WarningsLogger.Add('Found Error in Line [' + inttostr(Line) + '] : ' + 'Invalid Var name.');
                      End;
                    End;
                  End;
                End;
              End;
            End
            Else Begin
              // Falls die Variable ein Leerzring ist
              erg := true;
              WarningsLogger.Add('Found Error in Line [' + inttostr(line) + '] : ' + 'Invalid Var name.');
            End;
        End;
      End;
      If Pos(';', s) <> 0 Then b := false;
      inc(value);
    End;
    result := erg;
  End;

Label
  Abbruch;
Var
  erg: boolean;
  tiefe, y: Integer;
  line: String;
  Error: Boolean;

  // Liest aus dem String die Variable aus und fügt sie in Getvar ein
  Function extractgetvar(Value: String): Boolean;
  Var
    erg, b: Boolean;
    s: String;
    x: integer;
  Begin
    erg := false;
    s := copy(value, 1, pos(':=', value) - 1);
    s := uppercase(delFrontspace(DelEndspace(s)));
    b := false;
    // Prüfen ob die Variable überhaupt deklariert wurde
    For x := 0 To high(CompiledCode.vars) Do
      If CompareStr(s, CompiledCode.vars[x].name) = 0 Then b := true;
    If Not b Then Begin
      erg := true;
      WarningsLogger.Add('Found Error in Line [' + inttostr(getline(Value)) + '] : ' + 'Unknown value "' + s + '" .');
    End;
    // Prüfen ob die Variable bereits aufgenommen wurde
    b := false;
    For x := 0 To high(CompiledCode.getvars) Do
      If CompareStr(s, CompiledCode.getvars[x].name) = 0 Then b := true;
    If B Then Begin
      erg := true;
      WarningsLogger.Add('Found Error in Line [' + inttostr(getline(Value)) + '] : ' + 'You could use the "get" instruction only one times per variable.');
    End
    Else Begin
      setlength(CompiledCode.getvars, high(CompiledCode.getvars) + 2);
      CompiledCode.getvars[high(CompiledCode.getvars)].Name := s;
      CompiledCode.getvars[high(CompiledCode.getvars)].Value := 0;
    End;
    result := erg;
  End;

  Function getLoopVar(Value: String): String;
  Var
    erg: String;
  Begin
    erg := DelFrontspace(Value);
    Delete(erg, pos(LineSeparator, erg), length(erg)); // Löschen der zeileninformation
    Delete(erg, 1, 4); // Löschen des Wortes LOOP
    erg := DelEndspace(erg);
    Delete(erg, Length(erg) - 1, 2); // Löschen des Wortes do
    result := uppercase(DelFrontspace(DelEndspace(erg))); //Zuweisen der Variable
  End;

  // Liest aus einer Anweisung den Operator aus
  Function GetOP(Value: String): String;
  Var
    erg: String;
  Begin
    erg := '';
    If LineContainsToken('+', value) <> 0 Then erg := '+';
    If LineContainsToken('-', value) <> 0 Then erg := '-';
    If LineContainsToken('^-', value) <> 0 Then erg := '^-';
    If LineContainsToken('*', value) <> 0 Then erg := '*';
    If LineContainsToken('MOD', value) <> 0 Then erg := 'MOD';
    If LineContainsToken('DIV', value) <> 0 Then erg := 'DIV';
    result := erg;
  End;

  Function getopint(Value: String): Integer;
  Var
    erg: integer;
  Begin
    erg := 0;
    // 1 = +, 2 = - , 3 = ^- , 4 = * , 5 = Mod ,6 = Div
    If LineContainsToken('+', value) <> 0 Then erg := 1;
    If LineContainsToken('-', value) <> 0 Then erg := 2;
    If LineContainsToken('^-', value) <> 0 Then erg := 3;
    If LineContainsToken('*', value) <> 0 Then erg := 4;
    If LineContainsToken('MOD', value) <> 0 Then erg := 5;
    If LineContainsToken('DIV', value) <> 0 Then erg := 6;
    result := erg;
  End;

  // Extrahiert den Bedingungsstring aus der I then anweisung
  Function getbedingung(Value: String): String;
  Var
    erg: String;
  Begin
    delete(value, pos(LineSeparator, value), length(Value)); // Löschen des Steuerzeichens
    erg := uppercase(DelFrontspace(DelEndspace(value)));
    delete(erg, 1, 2); // Löschen des If
    delete(erg, length(erg) - 3, 4); // Löschen des Then
    result := DelFrontspace(DelEndspace(erg));
  End;

  Function CheckIfKlausel(Value: String): Boolean;
  Var
    erg: Boolean;
  Begin
    Erg := true;

    result := erg;
  End;

  Function getparas(Data: String; Var Mistake: Boolean): TPAra;
  Var
    Erg: Tpara;
    line: Integer;
    s: String;
  Begin
    erg := Nil;
    setlength(erg, 0);
    line := getline(data);
    Data := Uppercase(copy(data, pos('(', data) + 1, length(data)));
    Data := copy(data, 1, pos(')', data) - 1);
    If Length(data) <> 0 Then Begin
      data := data + ',' + LineSeparator + ',';
      While length(data) <> 0 Do Begin
        s := uppercase(copy(data, 1, pos(',', data) - 1));
        delete(data, 1, length(s) + 1);
        s := DelFrontspace(DelEndspace(s));
        If s <> LineSeparator Then
          If Length(s) = 0 Then Begin
            Mistake := true;
            WarningsLogger.Add('Found Error in Line [' + inttostr(line) + '] : ' + 'Missing Argument');
          End
          Else Begin
            If (Not VarExist2(s, line)) And (Not isnum(s)) Then Begin // Variable gibt es nicht -> Error
              Mistake := true;
              WarningsLogger.Add('Found Error in Line [' + inttostr(line) + '] : ' + 'Unknown value "' + s + '".');
            End
            Else Begin // Die Variable ist Gültig wir können sie übernehmen
              setlength(erg, high(erg) + 2);
              erg[high(erg)] := s;
            End;
          End;
      End;
    End;
    result := erg;
  End;

  Function Getfuninitialisiation(Von, Nach: Tpara; Name: String; Line: integer; Var Mistake: Boolean): Pbefehl;
  Var
    erg: Pbefehl;
    aw: Panweisung;
    z, t: Pbefehl;
    x: integer;
    b: Boolean;
  Begin
    erg := Nil;
    b := false;
    // Falls es überhaupt parameter gibt
    If high(von) <> -1 Then Begin
      new(erg); // neuesrtelen des Ergebnisses
      erg^.ID := 0; // Setzen der ID
      erg^.Code := Nil; // Verweis auf das erste Glied der Kette
      z := erg;
      For x := 0 To high(Von) Do Begin
        new(aw); // Neuerstellen der 1. zuweisung für die Variablen
        aw^.Ergebniss := GetVarindex(nach[x], b);
        // Speichern das die Variable benutzt wird
        If aw^.Ergebniss >= 0 Then
          compiledcode.vars[aw^.Ergebniss].used := true;
        aw^.Rechnung := MakeRechentree(von[x], line, mistake, '', [], WarningsLogger);
        aw^.Line := line;
        z^.ID := 1;
        z^.code := aw;
        new(t); // Pointer auf das 2. Gleid
        t^.ID := 0; // Der Schlepppointer
        t^.Code := Nil;
        aw^.Next := t;
        z := t;
      End;
    End;
    result := erg;
  End;

  Function makeResult(nach, von: String; Var Mistake: boolean; Line: Integer): Pbefehl;
  Var
    t, erg: Pbefehl;
    aw: PAnweisung;
    b: Boolean;
  Begin
    new(erg);
    new(aw);
    new(t);
    t^.ID := 0;
    t^.Code := Nil;
    erg^.ID := 1;
    erg^.Code := aw;
    b := false;
    aw^.Ergebniss := getvarindex(Nach, b);
    // Speichern das die Variable benutzt wird
    If aw^.Ergebniss >= 0 Then
      compiledcode.vars[aw^.Ergebniss].used := true;
    aw^.Rechnung := MakeRechentree(von, line, Mistake, '', [], WarningsLogger);
    // prüfen ob unsere Loop Variable auch wirklich eine ist sichtbare Variable ist
    If Not CheckVarVisible(aw^.Ergebniss, line) Then Begin
      WarningsLogger.Add('Found Error in Line [' + inttostr(Line) + '] : ' + 'Unknown value "' + Nach + '" .');
      Mistake := True;
    End;
    aw^.Line := line;
    aw^.next := t; // zuweisen eines Leerpointers
    result := erg;
  End;

  // Parst einen Code zusammen
  // Die Variable Ebene gibt an ob ir eine UNterfunction haben oder nicht

  Function GetCode(Var From: integer; Var Fehler: Boolean; Ebene: String): Pbefehl;
  Label
    raus;
  Var
    ifthen: Pif;
    lp: PLoop;
    aw: PAnweisung;
    func: PFunction;
    erg, z, ne: PBefehl;
    tmpfuncindex, tmpfrom, x, depth: Integer;
    checker, aline, v1, tstring, Varstring: String;
    b, c, d: Boolean;
    para: Tpara;
  Begin
    depth := 0;
    new(erg);
    erg^.ID := 0;
    erg^.Code := Nil;
    z := erg;
    If From < Lines.count Then Begin
      // Auslesen der Altuellen Zeile
      aLine := GetclearedString(lines[From], true);
      // Braucht man damit die Endtokens erkannt werden
      If Pos(';', aLine) <> 0 Then
        insert(' ', line, Pos(';', aLine));
      If LineContainsToken('Begin', aline) <> 0 Then inc(depth);
      If LineContainsToken('do', aline) <> 0 Then inc(depth);
      // Für Die If Bedingungen..
      If LineContainsToken('Then', aline) <> 0 Then inc(depth);
      If LineContainsToken('else', aline) <> 0 Then inc(depth);
      While depth <> 0 Do Begin
        inc(From);
        If From >= Lines.count Then Begin
          WarningsLogger.Add('Found Error in Line [' + inttostr(from - 1) + '] : ' + 'Parsing error please contact the programmer.');
          Fehler := True;
          Goto raus; // Abbruch des weiteren Aufbau's des Quellcode's
        End;
        // Auslesen der Altuellen Zeile
        aLine := GetclearedString(lines[From], true);
        // Braucht man damit die Endtokens erkannt werden
        If Pos(';', aLine) <> 0 Then
          insert(' ', aline, Pos(';', aLine));
        // Wir haben eine Variable die eingelesen wird also ab damit in GetVArs
        If LineContainsToken('Get', Aline) <> 0 Then Begin
          If Length(Ebene) = 0 Then Begin
            If extractgetvar(Aline) Then Begin // Es Gab Einen Fehler
              Fehler := True;
              Goto raus; // Abbruch des weiteren Aufbau's des Quellcode's
            End;
            Aline := ''; // Mus so gemacht werden sonst denkt der Compiler X0:= get sei eine Anweisung !!
          End
          Else Begin
            WarningsLogger.Add('Found Error in Line [' + inttostr(getline(aline)) + '] : ' + ' "Get" not allowed in Functions.');
            Fehler := True;
            Goto raus; // Abbruch des weiteren Aufbau's des Quellcode's
          End;
        End;
        // Wir haben eine Loop schleife gefunden
        If LineContainsToken('Loop', Aline) <> 0 Then Begin
          new(ne); // Instanz für nächsten Befehl
          ne^.ID := 0; // null Befehl
          ne^.Code := Nil; // null Befehl
          new(lp); // Loop Code
          lp^.Wiederhohlungen := -1; // Initialisierung für den Stack
          Varstring := getLoopVar(Aline);
          d := false;
          lp^.WiederhohlungenVar := GetVarindex(GetLokalGlobalName(Ebene + Varstring), d); // Die Zählvariable
          // Speichern das die Variable benutzt wird
          If lp^.WiederhohlungenVar >= 0 Then
            compiledcode.vars[lp^.WiederhohlungenVar].used := true;
          lp^.Line := getline(lines[From]); // Die Zeile in der der Loop Teil steht soll hier für die Zeile im Code stehen
          AddCompilableLine(lp^.Line);
          lp^.Code := GetCode(from, Fehler, ebene); // Zuweisen des Auszuführenden Code's
          lp^.Next := ne; // Der Code nach der Loop schleife
          z^.ID := 2; // eifügen in den bisher erstelleten Code
          z^.Code := lp; // eifügen in den bisher erstelleten Code
          z := ne; // Sprung des Aktuell Pointers auf den Nächsten Befehl
          // prüfen ob unsere Loop Variable auch wirklich eine ist sichtbare Variable ist
          If Not CheckVarVisible(lp^.WiederhohlungenVar, lp^.line) Then Begin
            WarningsLogger.Add('Found Error in Line [' + inttostr(lp^.Line) + '] : ' + 'Unknown or illegal value ' + Varstring + '.');
            Fehler := True;
          End;
          If Not checkIdentifier(GetLokalGlobalName(Ebene + Varstring)) Then
            If Not isnum(GetLokalGlobalName(Ebene + Varstring)) Then Begin
              WarningsLogger.Add('Found Error in Line [' + inttostr(lp^.Line) + '] : ' + 'Unknown or illegal value ' + Varstring + '.');
              Fehler := True;
              Goto raus; // Abbruch des weiteren Aufbau's des Quellcode's
            End;
          If Not VarExist(GetLokalGlobalName(ebene + Varstring), lp^.Line, WarningsLogger) Then Begin
            Fehler := True;
            Goto raus; // Abbruch des weiteren Aufbau's des Quellcode's
          End;
        End;
        // Wir haben eine Anweisung gefunden
        If LineContainsToken(':=', aline) <> 0 Then Begin
          // Wir schauen ob wir eine Function auffrufen, wenn Ja dann ist C = False
          v1 := ''; // Beruhigt den Compiler
          tmpfuncindex := -1; // Beruhigt den Compiler
          c := true;
          tstring := Preclear(aline);
          For x := 0 To high(CompiledCode.Func) Do Begin
            If LineContainsToken(CompiledCode.Func[x].Name, tstring) <> 0 Then Begin
              // Wenn wir wissen das wir eine Unterfunction aufrufen können wir auch gleich ihren Namen speichern
              v1 := CompiledCode.Func[x].Name;
              tmpfuncindex := x;
              c := false;
            End;
          End;
          // Verhindern das wir in einer Funktion noch mal eine Funktion aufrufen
          If length(ebene) <> 0 Then c := true;
          If c Then Begin
            tstring := aline;
            Delete(tstring, pos(';', tstring), length(Tstring)); // Löschen der zeileninformation
            v1 := DelFrontspace(DelEndspace(uppercase(copy(tstring, 1, pos(':=', tstring) - 1)))); // Auslesen der Zuweisungsvariable
            new(ne); // Instanz für nächsten Befehl
            ne^.ID := 0; // null Befehl
            ne^.Code := Nil; // null Befehl
            new(aw); // Anweisungscode
            aw^.Line := getline(lines[From]); // Extrahieren der Code Zeile
            If Not VarExist(GetLokalGlobalName(ebene + v1), aw^.Line, WarningsLogger) Then Begin
              Fehler := True;
              Dispose(ne);
              WarningsLogger.Add('Found Error in Line [' + inttostr(aw^.Line) + '] : ' + 'Unknown or illegal value ' + V1 + '.');
              Dispose(aw);
              Fehler := True;
              Goto raus;
            End;
            // Speichern das die Variable benutzt wird
            aw^.Ergebniss := GetVarindex(GetLokalGlobalName(Ebene + v1), d); // Auslesen der Variable die den Wert bekommt
            If aw^.Ergebniss >= 0 Then
              compiledcode.vars[aw^.Ergebniss].used := true;
            // prüfen ob unsere Loop Variable auch wirklich eine ist sichtbare Variable ist
            If Not CheckVarVisible(aw^.Ergebniss, aw^.line) Then Begin
              WarningsLogger.Add('Found Error in Line [' + inttostr(aw^.Line) + '] : ' + 'Unknown or illegal value ' + V1 + '.');
              Fehler := True;
            End;
            b := false;
            aw^.Rechnung := MakeRechentree(uppercase(copy(Tstring, pos(':=', tstring) + 2, length(Tstring))), aw^.line, b, ebene, [], WarningsLogger); // Ausrechnen des Ausdruckes
            aw^.Next := ne;
            AddCompilableLine(aw^.line);
            z^.ID := 1; // enifügen in den bisher erstelleten Code
            z^.Code := aw; // eifügen in den bisher erstelleten Code
            z := ne;
            If B Then Fehler := true;
            // Wenn ein Fehler bei den Variablen Gefunden wurde wird Rausgesprungen
            If Fehler Then Goto raus;
          End
          Else Begin // Hier ist eine Function aufgerufen worden das mus nun extra behandelt werden !
            //  v1,varstring
            b := false;
            tmpfrom := from;
            AddCompilableLine(getline(aline));
            from := CompiledCode.Func[tmpfuncindex].beg;
            CompiledCode.Func[tmpfuncindex].Used := true; // Merken das Die Function mindestens 1 mal aufgerufen wurde
            // Ermitteln der Übergebenen Variablen
            para := getparas(aline, b);
            If Not b Then Begin
              If High(para) < high(CompiledCode.Func[tmpfuncindex].uebergabeparameter) Then Begin
                b := true;
                WarningsLogger.Add('Found Error in Line [' + inttostr(getline(aline)) + '] : ' + 'To few arguments.');
              End;
              If High(para) > high(CompiledCode.Func[tmpfuncindex].uebergabeparameter) Then Begin
                b := true;
                WarningsLogger.Add('Found Error in Line [' + inttostr(getline(aline)) + '] : ' + 'To many arguments.');
              End;
            End;
            (*
             * Funktionsaufrufe sind nur erlaubt in der Form
             *  <Variable> := <Funktionsname>(<Paramaterliste>);
             * ggf, sollte diese Prüfung irgendwo anders gemacht werden ?
             *)
            v1 := LineWithoutLineInfo(v1);
            checker := lowercase(aline);
            delete(checker, 1, pos(':=', checker) + 1);
            checker := trim(checker);
            // Vor der Funktion darf nichts stehen
            If pos(LowerCase(v1), checker) <> 1 Then Begin
              b := true;
              WarningsLogger.Add('Found Error in Line [' + inttostr(getline(aline)) + '] : ' + ' function call only allowed as assignment to a variable, not in formulas.');
            End;
            // Nach der Funktion darf nichts stehen
            delete(checker, 1, pos(')', checker));
            checker := trim(checker);
            If pos(';', checker) <> 1 Then Begin
              b := true;
              WarningsLogger.Add('Found Error in Line [' + inttostr(getline(aline)) + '] : ' + ' function call only allowed as assignment to a variable, not in formulas.');
            End;
            // Wir haben wohl Passend viele Variablen also können wir die Funktion aufrufen
            If Not b Then Begin
              new(func);
              new(ne); // Instanz für nächsten Befehl
              ne^.ID := 0; // null Befehl
              ne^.Code := Nil; // null Befehl
              func^.Next := ne;
              func^.line := getline(aline);
              // dann müssen wir die Initialisierungskette Ausprogrammieren
              func^.Initialisation := Getfuninitialisiation(para, CompiledCode.Func[tmpfuncindex].uebergabeparameter, CompiledCode.Func[tmpfuncindex].Name, getline(aline), b);
              If b Then Begin // Wenn es noch irgendwelche Fehler gab
              End
              Else Begin // Falls keine Fehler aufgetreten sind
                func^.code := GetCode(from, fehler, CompiledCode.Func[tmpfuncindex].Name); // Diese Zeile Führt dann das Eigentliche Parsing der Functin durch
                // Berechnen der Ergebnis Variable
                Tstring := uppercase(copy(aline, 1, pos(':', aline) - 1));
                Tstring := DelFrontspace(DelEndspace(Tstring));
                If Not VarExist(Tstring, getline(aline), WarningsLogger) Then Begin
                  b := true;
                End
                Else Begin
                  func^.Aftercode := makeResult(Tstring, CompiledCode.Func[tmpfuncindex].Name + 'RESULT', b, getline(aline));
                End;
                z^.ID := 4; // Einfügen der Function ni den Code
                z^.Code := func; // Einfügen des Erstellten Codes
                z := ne;
              End;
            End;
            from := tmpfrom;
            If B Then Fehler := true;
            // Wenn ein Fehler bei den Variablen Gefunden wurde wird Rausgesprungen
            If Fehler Then Goto raus;
          End;
        End;
        // Die If - Bedingung
        If LineContainsToken('Then', aline) <> 0 Then Begin
          new(ifthen); // Instanz für das Ifthen
          new(ne); // Instanz für nächsten Befehl
          ne^.ID := 0; // null Befehl
          ne^.Code := Nil; // null Befehl
          ifthen^.Next := ne;
          Ifthen^.Line := getline(lines[From]); // Die Zeile in der die If anweisung steht
          AddCompilableLine(Ifthen^.line);
          ifthen^.Bedingung := makerechentree(getbedingung(aline), ifthen^.line, b, ebene, [], WarningsLogger);
          If b Then Begin
            Dispose(ne);
            Dispose(ifthen);
            Fehler := True;
            Goto raus; // Abbruch des weiteren Aufbau's des Quellcode's
          End;
          If Length(DelFrontspace(getbedingung(aline))) = 0 Then Begin
            WarningsLogger.Add('Found Error in Line [' + inttostr(Ifthen^.Line) + '] : ' + 'Missing Argument in "If" ');
            Dispose(ne);
            Dispose(ifthen);
            Freerechentree(ifthen^.Bedingung);
            Fehler := True;
            Goto raus; // Abbruch des weiteren Aufbau's des Quellcode's
          End;
          If Not CheckIfKlausel(getbedingung(aline)) Then Begin
            Fehler := true;
            Dispose(ne);
            Dispose(ifthen);
            Freerechentree(ifthen^.Bedingung);
            Goto raus; // Abbruch des weiteren Aufbau's des Quellcode's
          End;
          ifthen^.BedNext := GetCode(from, Fehler, ebene); // Zuweisen des Auszuführenden Code's
          ifthen^.ElseNext := Nil;
          If LineContainsToken('Else', lines[From]) <> 0 Then Begin
            ifthen^.ElseNext := GetCode(from, Fehler, ebene); // Zuweisen des Auszuführenden Code's
          End;
          z^.ID := 3; // einfügen in den bisher erstelleten Code
          z^.Code := Ifthen; // einfügen in den bisher erstelleten Code
          z := ne;
        End;
        // Der Abbruch des Parsen ist wenn die Tiefe wieder = der Tiefe des Eingangsparsen's ist
        If LineContainsToken('End', aline) <> 0 Then dec(depth); // Abbruch Normal
        If LineContainsToken('Else', aline) <> 0 Then dec(depth); // Abbruch in einer If Bedingung
      End;
    End;
    // Der Schnelle Abbruch und damit bei Fehler = true das Ende des Kompilierens
    raus:
    result := erg;
  End;

  Function getfunctdata(Data: Tstrings; Startindex: Integer; Var Fehler: Boolean): Tfunc;
  Var
    erg: Tfunc;
    x, y: integer;
    s: String;
  Begin
    x := -1;
    s := copy(data[Startindex], LineContainsToken('Function', data[Startindex]) + 8, length(data[Startindex]));
    y := pos(';', s);
    If y = 0 Then Begin
      WarningsLogger.Add('Found Error in Line [' + inttostr(Startindex) + '] : ' + 'Missing ";" ');
      Fehler := true;
    End;
    delete(s, y, length(s));
    y := pos('(', s);
    If y <> 0 Then
      delete(s, y, length(s));
    s := DelFrontspace(DelEndspace(s));
    If length(s) = 0 Then Begin
      WarningsLogger.Add('Found Error in Line [' + inttostr(Startindex) + '] : ' + 'Invalid Function name.');
      Fehler := true;
    End;
    erg.Name := s;
    y := Startindex;
    While y < lines.count - 1 Do Begin
      If LineContainsToken('Begin', GetclearedString(lines[y], true)) <> 0 Then Begin
        x := y;
        y := high(integer) - 2;
      End;
      inc(y);
    End;
    If X = -1 Then Begin
      WarningsLogger.Add('Found Error in Line [' + inttostr(Startindex) + '] : ' + 'Parsing Error no Begin for " ' + s + ' " found.');
      Fehler := true;
    End;
    erg.beg := x;
    erg.name := uppercase(erg.name) + LineSeparator;
    erg.Used := false;
    result := erg;
  End;

  // Parst die ÜbergabeParameter aus der Kopfzeile der Function und fügt sie dem Globalen array zu

  Function makefunvars(Name, Data: String): boolean;
  Var
    v, s: String;
    line, x: Integer;
    erg: boolean;
  Begin
    erg := false;
    name := uppercase(name);
    s := copy(data, pos('(', data) + 1, length(data));
    line := getline(data);
    delete(s, pos(')', s), length(s));
    // Rausparsen der einzelnen Variablen
    While length(s) <> 0 Do Begin
      While pos(',', s) <> 0 Do Begin
        v := copy(s, 1, pos(',', s) - 1);
        delete(s, 1, length(v) + 1);
        v := DelFrontspace(DelEndspace(v));
        If Length(v) <> 0 Then Begin
          If VarExist2(name + LineSeparator + uppercase(v), line) Then Begin
            WarningsLogger.Add('Found Error in Line [' + inttostr(line) + '] : ' + 'double existing var name.');
            erg := true;
          End
          Else Begin
            If (Uppercase(v) = 'RESULT') Or (Uppercase(v) = 'DO') Or (Uppercase(v) = 'LOOP') Or
              (Uppercase(v) = 'FUNCTION') Or (Uppercase(v) = 'PROCEDURE') Or (Uppercase(v) = 'THEN') Or
              (Uppercase(v) = 'ELSE') Or (Uppercase(v) = 'END') Or (Uppercase(v) = 'BEGIN') Or
              (Uppercase(v) = 'VAR') Or (Uppercase(v) = 'GET') Or (Uppercase(v) = 'IF') Or
              (Uppercase(v) = 'THEN') Or (Uppercase(v) = 'OR') Or (Uppercase(v) = 'AND') Or
              (Uppercase(v) = 'MOD') Or (Uppercase(v) = 'DIV') Then Begin
              WarningsLogger.Add('Found Error in Line [' + inttostr(line) + '] : ' + '"' + v + '" is a reserved word it cannont be used as a var name.');
              erg := true;
            End
            Else Begin
              setlength(CompiledCode.vars, high(CompiledCode.vars) + 2);
              CompiledCode.vars[high(CompiledCode.vars)].Value := 0;
              CompiledCode.vars[high(CompiledCode.vars)].Name := name + uppercase(v);
              CompiledCode.vars[high(CompiledCode.vars)].Line := line;
              // Speichern als Übergabe Parameter für die Function
              setlength(CompiledCode.Func[high(CompiledCode.Func)].uebergabeparameter, high(CompiledCode.Func[high(CompiledCode.Func)].uebergabeparameter) + 2);
              CompiledCode.Func[high(CompiledCode.Func)].uebergabeparameter[high(CompiledCode.Func[high(CompiledCode.Func)].uebergabeparameter)] := name + uppercase(v);
            End;
          End;
        End
        Else Begin
          erg := true;
          WarningsLogger.Add('Found Error in Line [' + inttostr(line) + '] : ' + 'Invalid Function parameter');
        End;
      End;
      v := s;
      delete(s, 1, length(v) + 1);
      v := DelFrontspace(DelEndspace(v));
      If Length(v) <> 0 Then Begin
        If VarExist2(name + LineSeparator + uppercase(v), line) Then Begin
          WarningsLogger.Add('Found Error in Line [' + inttostr(line) + '] : ' + 'double existing var name.');
          erg := true;
        End
        Else Begin
          If (Uppercase(v) = 'RESULT') Or (Uppercase(v) = 'DO') Or (Uppercase(v) = 'LOOP') Or
            (Uppercase(v) = 'FUNCTION') Or (Uppercase(v) = 'PROCEDURE') Or (Uppercase(v) = 'THEN') Or
            (Uppercase(v) = 'ELSE') Or (Uppercase(v) = 'END') Or (Uppercase(v) = 'BEGIN') Or
            (Uppercase(v) = 'VAR') Or (Uppercase(v) = 'GET') Or (Uppercase(v) = 'IF') Or
            (Uppercase(v) = 'THEN') Or (Uppercase(v) = 'OR') Or (Uppercase(v) = 'AND') Or
            (Uppercase(v) = 'MOD') Or (Uppercase(v) = 'DIV') Then Begin
            WarningsLogger.Add('Found Error in Line [' + inttostr(line) + '] : ' + '"' + v + '" is a reserved word it cannont be used as a var name.');
            erg := true;
          End
          Else Begin
            setlength(CompiledCode.vars, high(CompiledCode.vars) + 2);
            CompiledCode.vars[high(CompiledCode.vars)].Value := 0;
            CompiledCode.vars[high(CompiledCode.vars)].Name := name + uppercase(v);
            CompiledCode.vars[high(CompiledCode.vars)].Line := line;
            // Speichern als Übergabe Parameter für die Function
            setlength(CompiledCode.Func[high(CompiledCode.Func)].uebergabeparameter, high(CompiledCode.Func[high(CompiledCode.Func)].uebergabeparameter) + 2);
            CompiledCode.Func[high(CompiledCode.Func)].uebergabeparameter[high(CompiledCode.Func[high(CompiledCode.Func)].uebergabeparameter)] := name + uppercase(v);
          End;
        End;
      End
      Else Begin
        erg := true;
        WarningsLogger.Add('Found Error in Line [' + inttostr(line) + '] : ' + 'Invalid Function parameter');
      End;
    End;
    // Prüfen auf Gültige Variablennamen
    For x := 0 To high(CompiledCode.vars) Do Begin
      If Not allowothernames Then
        If Not CheckVarName(CompiledCode.vars[x].Name) Then Begin
          erg := true;
          WarningsLogger.Add('Found Error in Line [' + inttostr(line) + '] : ' + 'Other var names not allowed, go to Options to allow it.');
        End;
      If Not checkIdentifier(CompiledCode.vars[x].Name) Then Begin
        erg := true;
        WarningsLogger.Add('Found Error in Line [' + inttostr(line) + '] : ' + 'Invalid Var name.');
      End;
    End;
    result := erg;
  End;

  // Sucht im Bereich zwischen von und bis nach deklarierten Variablen und fügt diese dem Globalen Array zu

  Function GetLokalfuncvars(Von, Bis: integer; Functionsname: String): boolean;
  Var
    b, erg: Boolean;
    line, x: Integer;
    r, d, s: String;
  Begin
    Functionsname := uppercase(Functionsname);
    erg := false;
    b := false;
    For x := von To bis Do Begin
      s := GetclearedString(lines[x], true);
      line := getline(s);
      delete(s, pos(LineSeparator, s), length(s));
      If LineContainsToken('Var', s) <> 0 Then b := true;
      If B Then Begin
        d := S;
        // löschendes Evtlenen Schlüsselwortes Var
        If LineContainsToken('Var', d) <> 0 Then Begin
          delete(d, LineContainsToken('Var', d), 3);
        End;
        If Pos(';', d) <> 0 Then d[Pos(';', d)] := ',';
        If Length(d) <> 0 Then Begin
          d := d + LineSeparator + ',';
          While Length(d) <> 0 Do Begin
            r := copy(d, 1, pos(',', d));
            delete(d, 1, length(r));
            delete(r, length(r), 1);
            r := DelFrontspace(DelEndspace(r));
            If r <> LineSeparator Then
              If Length(r) <> 0 Then Begin
                If VarExist2(Functionsname + LineSeparator + uppercase(r), line) Then Begin
                  WarningsLogger.Add('Found Error in Line [' + inttostr(line) + '] : ' + 'double existing var name.');
                  erg := true;
                End
                Else Begin
                  If (Uppercase(r) = 'RESULT') Or (Uppercase(r) = 'DO') Or (Uppercase(r) = 'LOOP') Or
                    (Uppercase(r) = 'FUNCTION') Or (Uppercase(r) = 'PROCEDURE') Or (Uppercase(r) = 'THEN') Or
                    (Uppercase(r) = 'ELSE') Or (Uppercase(r) = 'END') Or (Uppercase(r) = 'BEGIN') Or
                    (Uppercase(r) = 'VAR') Or (Uppercase(r) = 'GET') Or (Uppercase(r) = 'IF') Or
                    (Uppercase(r) = 'THEN') Or (Uppercase(r) = 'OR') Or (Uppercase(r) = 'AND') Or
                    (Uppercase(r) = 'MOD') Or (Uppercase(r) = 'DIV') Then Begin
                    WarningsLogger.Add('Found Error in Line [' + inttostr(line) + '] : ' + '"' + r + '" is a reserved word it cannont be used as a var name.');
                    erg := true;
                  End
                  Else Begin
                    setlength(CompiledCode.vars, high(CompiledCode.vars) + 2);
                    CompiledCode.vars[high(CompiledCode.vars)].Value := 0;
                    CompiledCode.vars[high(CompiledCode.vars)].Name := functionsname + uppercase(r);
                    CompiledCode.vars[high(CompiledCode.vars)].Line := line;
                  End;
                End;
              End
              Else Begin
                erg := true;
                WarningsLogger.Add('Found Error in Line [' + inttostr(line) + '] : ' + 'Invalid Function parameter');
              End;
          End;
        End;
      End;
      // Abschalten des Scannens
      If Pos(';', s) <> 0 Then b := false;
    End;
    result := erg;
  End;
Var
  s: String;
Begin
  erg := true;
  lines := DeleteComments(lines);
  // Löschen altern Warnungen , Fehler
  WarningsLogger.clear;
  // Löschen der Bisher gefundenen Compilierbaren Zeilen
  ClearCompilableLines;
  // Löschen eines bisher Compilierten Code's
  FreeCompiledcode;
  // Einfügen unserer Standart Variable X0
  setlength(CompiledCode.vars, 1);
  CompiledCode.vars[0].Name := 'X0';
  CompiledCode.vars[0].Value := 0;
  // Löschen der functionen die es Vielleicht so gibt
  // Durchführen eines Kleinen Prescan's damit schon mal viele Fehler vor dem eigentlichen Compilieren gefunden werden können.
  If Prescan(Lines, WarningsLogger) Then Begin
    erg := false;
    Goto Abbruch;
  End;
  // Hier ist ein Verbesserter Versuch des Prescanners
  If PrePrescan(lines, WarningsLogger) Then Begin
    erg := false;
    Goto Abbruch;
  End;
  y := 0;
  // Erzeugen der Struktur für das Hauptprogramm
  (*       Vorgehensweise :
                            1. Wegparsen Aller Funktionen vor dem ersten BEGIN    beim Parsen Von Funktionen prüfen ob diese nndere Funktionen aufrufen, das soll nicht erlaubt sein !!
                            2. Rausparsen der Variablen für das Hauptprogramm
                            3. Parsen Schrittweise durch das Hauptprogramm durch

  *)
  tiefe := 0;
  Error := false;
  While y < lines.count Do Begin
    Line := GetclearedString(lines[y], true);
    // Braucht man damit die Endtokens erkannt werden
    If Pos(';', Line) <> 0 Then
      insert(' ', line, Pos(';', Line));
    // Wir haben unseren Anfang gefunden
    If LineContainsToken('Procedure', Line) <> 0 Then inc(tiefe);
    If LineContainsToken('Function', Line) <> 0 Then inc(tiefe);
    If LineContainsToken('then', Line) <> 0 Then inc(tiefe);
    If LineContainsToken('do', Line) <> 0 Then inc(tiefe);
    If LineContainsToken('end', Line) <> 0 Then dec(tiefe);
    If (tiefe = 1) And (LineContainsToken('Var', line) <> 0) Then Begin
      // Fügt der Hauptprocedure die Variablen aus Line zu, ohne die Vorherigen zu löschen
      If getprocvars(y) Then Begin
        erg := false;
        Goto abbruch;
      End;
    End;
    // Wir schaun ob wir Fucntionen haben die es zu Parsen gibt
    If (Tiefe <> 1) Then
      If LineContainsToken('Function', Line) <> 0 Then Begin
        // Erst mal die Schlüsseldaten der Funciton ausparsen
        setlength(Compiledcode.Func, high(Compiledcode.Func) + 2);
        Compiledcode.Func[high(Compiledcode.Func)] := getfunctdata(lines, y, Error);
        Compiledcode.Func[high(Compiledcode.Func)].realline := getline(line);
        If Error Then Begin
          erg := false;
          Goto abbruch;
        End;
        // Sind diese Gültig dann Schaun wir was wir mit den ÜbergabeParametern und den Lokalen Variablen machen.
        // Erzeugen der Variablen im Array
        // zuerst die Übergabeparameter
        If pos(')', line) <> 0 Then Begin
          If makefunvars(Compiledcode.Func[high(Compiledcode.Func)].Name, line) Then Begin
            erg := false;
            Goto abbruch;
          End;
        End;
        // nun alle Lokalen Variablen der Funcitonen
        If GetLokalfuncvars(y + 1, Compiledcode.Func[high(Compiledcode.Func)].beg - 1, Compiledcode.Func[high(Compiledcode.Func)].Name) Then Begin
          erg := false;
          Goto abbruch;
        End;
        // Hinzügen der Result Variable der Funciton in das Globale Array
        setlength(compiledcode.vars, high(compiledcode.vars) + 2);
        compiledcode.vars[high(compiledcode.vars)].Value := 0;
        compiledcode.vars[high(compiledcode.vars)].Name := Compiledcode.Func[high(Compiledcode.Func)].Name + 'RESULT';
        CompiledCode.vars[high(CompiledCode.vars)].Line := getline(line);
      End;
    // Wenn Die Warnung zwecks XO Kam das es net Benutzt wird dann sollten wir den Code ein wenig optimieren ?
    // Das Rausparsen des Quellcodes der hauptprocedur
    If (Tiefe = 1) And (LineContainsToken('Begin', line) <> 0) Then Begin
      CompiledCode.Code := GetCode(y, Error, '');
      If Error Then erg := false;
      y := lines.count; // Danach Fertig
    End;
    inc(y);
  End;
  // Der Folgende Code mus auf alle Fälle ausgeführt werden, egal ob wir einen Compilierbaren Code haben oder nicht
  abbruch:
  // Es macht nur Sinn das aus zu geben wenn der Code ansich Kompilierbar ist.
  If Erg Then Begin
    For y := 0 To high(Compiledcode.Func) Do
      // Nachschaun ob auch alle Functionen aufgerufen wurden
      If Not Compiledcode.Func[y].used Then Begin
        s := Compiledcode.Func[y].name;
        s := copy(s, 1, length(s) - 1);
        WarningsLogger.Add('Errorcode [' + inttostr(Compiledcode.Func[y].realline) + '] : Warning "' + s + '" is never used -> "' + s + '" will not be checked."')
      End;
    // Nachschaun ob auch alle Variablen benutzt wurden
    For y := 1 To high(compiledcode.vars) Do
      If Not compiledcode.vars[y].Used Then Begin
        s := compiledcode.vars[y].Name;
        s := getuserVarname(s);
        WarningsLogger.Add('Errorcode [' + inttostr(compiledcode.vars[y].line) + '] : ' + 'Warning ' + s + ' never assigned a value');
      End;
  End;
  // Wenn wir nicht Compilieren Konnten löschen wir hier den bisher erstellten Code
  If Not erg Then Begin
    FreeCompiledcode;
    ClearCompilableLines;
  End;
  lines.free;
  result := erg;
End;

End.

