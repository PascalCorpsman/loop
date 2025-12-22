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
Unit Executer;

{$MODE objfpc}{$H+}

Interface

Uses forms, sysutils, uCompiler, RechenBaum, LoopStack, {Debuggen} Dialogs {Debuggen Ende};

Var
  LoopRechner: TLoopStack;
  TimeVar: QWord;

  // Startet eine Berechnung
Procedure StartExecute;
//
Procedure Execute(Onestep, Ignorefirst: Boolean);
// Prüft ob es gerade irgendwelche Variablen gibt die in Form1 angezeigt werden sollen
Procedure Checkforwantedvalues(data: int64);
// Gibt die Array Position einer in Value enthaltenen Variable zurück
Function GetVarindex(Value: String; Var Fehler: Boolean): int64;
// Setzt alle Variablen die überwacht werden auf den Wert Unknown
Procedure SetUnknown;
// Gibt True zurück wenn der String in Value eine int64 Zahl ist , komischerweise geht es mit einem Try Block nicht
Function isnum(Value: String): Boolean;
// Gibt zum Pointer die Echte Variable an
Function PointerVar_To_RealVar(Value: int64): int64;

Implementation

Uses
  uloop
  , unit1
  , unit5 // Programm_Simulation
  , unit8 // Controlled_Vars
  ;

Procedure SetUnknown;
  Function getun(Value: String): String;
  Begin
    result := copy(value, 1, pos('=', value)) + ' Not available';
  End;

Var
  x: integer;
Begin
  For x := 0 To form1.Controlled_Varables.items.count - 1 Do Begin
    // Umschreiben des Textes auf Nicht Verfügbar
    form1.Controlled_Varables.items[x] := getun(form1.Controlled_Varables.items[x]);
  End;
End;

// Prüft ob es gerade irgendwelche Variablen gibt die in Form1 angezeigt werden sollen

Procedure Checkforwantedvalues(data: int64);
Var
  x: integer;
Begin
  If Form1.Controlled_Varables.Visible Then Begin
    Form1.Controlled_Varables.Items.clear;
    For x := 0 To high(compiledcode.vars) Do
      If x < form8.CheckListBox1.Items.Count Then
        If form8.CheckListBox1.Checked[x] Then
          Form1.Controlled_Varables.Items.Add('Variable [' + inttostr(x + 1) + '] : ' + getuserVarname(CompiledCode.vars[x].Name) + ' = ' + inttostr(compiledcode.vars[x].value));
    If form8.CheckListBox1.Items.Count <> 0 Then
      If form8.CheckListBox1.Checked[form8.CheckListBox1.Items.Count - 1] Then
        If Data <> -1 Then
          Form1.Controlled_Varables.Items.Add('Aktuall Loop value = ' + inttostr(data))
        Else
          Form1.Controlled_Varables.Items.Add('Aktuall Loop value = Not available');
  End;
End;

// Rechnet eine Variable entweder in den entsprechenden Variablenwert um, oder wenn es eine Konstante war in den
// Korrekten Konstantenwert. da bei uns Ja alle Zahlen negativ sind damit wir die Positiven zum Addressieren im Array haben ;)

Function PointerVar_To_RealVar(Value: int64): int64;
Begin
  If Value >= 0 Then
    If Value > High(CompiledCode.vars) Then
      result := -1
    Else
      result := CompiledCode.vars[value].value // Es handelt sich um eine Variable die ausgelesen werden mus
  Else
    result := ((Value + 1) * -1); // Es handelt sich um eine Konstante
End;

// Gibt True zurück wenn der String in Value eine int64 Zahl ist , komischerweise geht es mit einem Try Block nicht

Function isnum(Value: String): Boolean;
Var
  x: integer;
Begin
  // Wegschneiden der Evtlen Ebene
  If pos(LineSeparator, Value) <> 0 Then
    delete(value, 1, pos(LineSeparator, Value));
  For x := 0 To 9 Do
    While pos(inttostr(x), Value) <> 0 Do
      delete(value, pos(inttostr(x), Value), 1);
  result := length(Value) = 0;
End;

// Gibt die Array Position einer in Value enthaltenen Variable zurück,
// Oder wenn der String eine Konstante ist dessen Wert in unserem Zahlensystem

Function GetVarindex(Value: String; Var Fehler: Boolean): int64;
Var
  x: integer;
  erg: int64;
  f: String;
Begin
  f := '';
  If Pos(LineSeparator, Value) <> 0 Then Begin
    f := copy(value, 1, Pos(LineSeparator, Value));
    delete(value, 1, length(f));
  End;
  If isnum(Value) Then Begin
    Try
      erg := strtoint64(Value);
      erg := erg * -1;
      erg := erg - 1;
    Except
      Fehler := True;
      erg := -1; // Im Fehler mus ja irgendwas gemacht werden
    End;
  End
  Else Begin
    erg := High(int64); // Sorgt dafür das bei nicht gefunden eine Exception geworfen wird
    For x := 0 To high(CompiledCode.vars) Do
      If CompiledCode.vars[x].Name = (f + Value) Then erg := x;
  End;
  result := erg;
End;

// Führt eine Anweisung Durch !!

Function DoAnweisung(Ergebnis: int64; Rechnung: Prechentree): boolean;
Var
  zerg: int64;
  erg: boolean;
Begin
  zerg := RechneTree(rechnung); // Wir müssen zwischenspeichern damit wir den Fehlerfall Abfangen können.
  If zerg >= 0 Then Begin
    erg := False;
    If Ergebnis <= high(CompiledCode.vars) Then
      CompiledCode.vars[Ergebnis].value := zerg;
  End
  Else Begin
    If Ergebnis <= high(CompiledCode.vars) Then Begin
      CompiledCode.vars[Ergebnis].value := 0;
      erg := True;
    End
    Else
      erg := true;
  End;
  result := erg;
End;

// Diese Procedure initialisiert auf einen Schlag alle Variablen die die eine Funciton so Braucht

Procedure SpezialDo(Befehl: PBefehl);
Var
  t: Pbefehl;
Begin
  t := Befehl;
  While t <> Nil Do Begin
    If t^.Code <> Nil Then Begin
      Doanweisung(PAnweisung(t^.code)^.Ergebniss, PAnweisung(t^.code)^.rechnung);
      t := panweisung(t^.Code)^.Next;
    End
    Else
      t := Nil;
  End;
End;

// Führt den Code aus

Procedure Execute(Onestep, Ignorefirst: Boolean);
Label
  FHaltepunkt;
Var
  PAktBefehl: PBefehl;
  onedone, Braked: Boolean;
  alp, BLine: int64;
  v2: QWord;
Begin
  alp := -1;
  onedone := false;
  Braked := false;
  bline := -1;
  // Einbau der HAltepunkte ist nun gefragt !!
  With LoopRechner Do Begin
    While Not isempty Do Begin
      PAktBefehl := POP;
      application.ProcessMessages;
      If PAktBefehl <> Nil Then Begin
        // Wir haben die F8 Taste Gedrückt
        If Onestep And onedone Then Begin
          // Wir lassen den Rechner evtlen overhad durch leere Pointer abbauen
          If PAktBefehl^.ID <> 0 Then Begin
            Case PAktBefehl^.ID Of
              1: bline := panweisung(PAktBefehl^.Code)^.Line;
              2: Begin
                  bline := ploop(PAktBefehl^.Code)^.Line;
                  If PLoop(PAktBefehl^.Code)^.Wiederhohlungen = -1 Then Begin
                    alp := PointerVar_To_RealVar(PLoop(PAktBefehl^.Code)^.WiederhohlungenVar);
                  End
                  Else
                    alp := ploop(PAktBefehl^.Code)^.Wiederhohlungen - 1;
                End;
              3: bline := pif(PAktBefehl^.Code)^.Line;
              4: bline := pfunction(Paktbefehl^.code)^.line;
            End;
            // Da wir den Befehl ansich nicht ausgeführt haben müssen wir ihn auch wieder in den Stack einfügen !!
            push(PAktBefehl);
            Braked := true;
            Goto Fhaltepunkt;
          End;
        End;
        Case PAktBefehl^.ID Of
          1: Begin // ausführen einer Anweisung
              If isBrakepoint(PAnweisung(PAktBefehl^.code)^.Line) And (Not onestep) And (Not Ignorefirst) Then Begin
                Bline := PAnweisung(PAktBefehl^.code)^.Line;
                Braked := true;
                push(PAktBefehl);
                Goto Fhaltepunkt;
              End
              Else Begin
                // wenn wir einen Brakepoint gefunden haben dann müssen wir aufhören mit ausführen und in den Code Springen
                If Doanweisung(PAnweisung(PAktBefehl^.code)^.Ergebniss, PAnweisung(PAktBefehl^.code)^.rechnung) Then Begin
                  // Wenn es einen Fehler gab mus die Exception hier Geworfen werden
                  Looprechner.clear;
                  CompiledCode.vars[0].Value := -1;
                End
                Else Begin
                  onedone := true; // Merken das wir mindestens eine Anweisung gemacht haben.
                  Ignorefirst := false; // Merken das wir die Erste Anweisung gemacht haben
                  // Ausführen des Nächsten Code's
                  Push(PAnweisung(PAktBefehl^.code)^.Next);
                End;
              End;
            End;
          2: Begin // ausführen einer Loop Anweisung
              If isBrakepoint(PLoop(PAktBefehl^.code)^.Line) And (Not onestep) And (Not Ignorefirst) Then Begin
                Bline := PLoop(PAktBefehl^.code)^.Line;
                Braked := true;
                // Zum Rausdebuggen wieviel Schleifendurchläufe noch gemacht werden müssen
                If PLoop(PAktBefehl^.Code)^.Wiederhohlungen = -1 Then Begin
                  alp := PointerVar_To_RealVar(PLoop(PAktBefehl^.Code)^.WiederhohlungenVar);
                End
                Else
                  alp := ploop(PAktBefehl^.Code)^.Wiederhohlungen - 1;
                push(PAktBefehl);
                Goto Fhaltepunkt;
              End
              Else Begin
                onedone := true;
                ignorefirst := false;
              End;
              // wir starten die Loop Schleife zum ersten mal
              If PLoop(PAktBefehl^.Code)^.Wiederhohlungen = -1 Then Begin
                // Wir müssen die Wiederhohlungen Auslesen , die If Bedingung ist nötig damit so Therme wie "Loop 10 do" auch gehn
                PLoop(PAktBefehl^.Code)^.Wiederhohlungen := PointerVar_To_RealVar(PLoop(PAktBefehl^.Code)^.WiederhohlungenVar);
                {// Ohne Diese Zeile würden alle Loop Schleifen mindestens 1 mal ausgeführt.}
                If PLoop(PAktBefehl^.Code)^.Wiederhohlungen > 0 Then Begin
                  push(PAktBefehl); // Neu reinpuschen der Schleife
                  push(PLoop(PAktBefehl^.Code)^.Code); // Puschen des Codes in der Loop Anweisung
                End
                Else Begin
                  PLoop(PAktBefehl^.Code)^.Wiederhohlungen := -1; // Schreiben der Neuinitialisierung für's nächste mal ;)
                  push(PLoop(PAktBefehl^.Code)^.Next); // Puschen des Codes nach der Loop Anweisung
                End;
              End
              Else Begin // Wir sind mitten in der Loop schleife
                // Runterzählen der Schleife
                PLoop(PAktBefehl^.Code)^.Wiederhohlungen := PLoop(PAktBefehl^.Code)^.Wiederhohlungen - 1;
                // Die Abbruchbedingung der Schleifen
                If PLoop(PAktBefehl^.Code)^.Wiederhohlungen <= 0 Then Begin
                  // Das ende der Loop Schleife
                  PLoop(PAktBefehl^.Code)^.Wiederhohlungen := -1; // Schreiben der Neuinitialisierung für's nächste mal ;)
                  push(PLoop(PAktBefehl^.Code)^.Next); // Puschen des Codes nach der Loop Anweisung
                End
                Else Begin
                  // Mitten drin in der Loop schleife
                  push(PAktBefehl); // Neu reinpuschen der Schleife
                  push(PLoop(PAktBefehl^.Code)^.Code); // Puschen des Codes in der Loop Anweisung
                End;
              End;
            End;
          3: Begin // ausführen einer If Anweisung
              If isBrakepoint(Pif(PAktBefehl^.code)^.Line) And (Not onestep) And (Not Ignorefirst) Then Begin
                Bline := Pif(PAktBefehl^.code)^.Line;
                Braked := true;
                push(PAktBefehl);
                Goto Fhaltepunkt;
              End
              Else Begin
                onedone := true;
                ignorefirst := false;
              End;
              If RechneTree(Pif(Paktbefehl^.code)^.Bedingung) > 0 Then Begin
                push(Pif(Paktbefehl^.code)^.Next);
                push(Pif(Paktbefehl^.code)^.BedNext);
              End
              Else Begin
                push(Pif(Paktbefehl^.code)^.Next);
                push(Pif(Paktbefehl^.code)^.ElseNext);
              End;
            End;
          4: Begin // Ausführen von Functionsaufrufen
              If isBrakepoint(Pfunction(PAktBefehl^.code)^.Line) And (Not onestep) And (Not Ignorefirst) Then Begin
                Bline := Pfunction(PAktBefehl^.code)^.Line;
                Braked := true;
                push(PAktBefehl);
                Goto Fhaltepunkt;
              End
              Else Begin
                // Da wir nen Stack haben müssen wir die befehle Rückwärts Puschen ;)
                push(Pfunction(PAktBefehl^.code)^.Next); // Der Befehl nach der Function
                push(Pfunction(PAktBefehl^.code)^.Aftercode); // Das zurüsckschreiben der Variablen
                push(Pfunction(PAktBefehl^.code)^.code); // Der Code der Function
                // Wir müssen nun alle Variablen entsprechend initialisieren.
                SpezialDo(Pfunction(PAktBefehl^.code)^.Initialisation);
                onedone := true; // Merken das wir mindestens eine Anweisung gemacht haben.
                Ignorefirst := false; // Merken das wir die Erste Anweisung gemacht haben
              End;
            End;
        End;
      End;
    End;
  End;
  Fhaltepunkt:
  // Wenn ein Haltepunkt erreicht wurde dann müssen wir hier ein wenig tricksen
  If Braked Then Begin
    If looprechner.Isempty Then Begin
      If High(CompiledCode.vars) <> -1 Then
        Form5.edit6.Text := inttostr(CompiledCode.vars[0].value)
      Else
        Form5.edit6.Text := '';
      // Wieder Freischalten des Run Button
      form5.Button1.enabled := true;
      form5.Caption := 'Programm simulation';
      SetUnknown;
      Form5.BringToFront;
      If form5.Checkbox1.Checked Then Begin
        form5.Checkbox1.enabled := true;
        v2 := GetTickCount64;
        If High(compiledcode.vars) <> -1 Then
          showmessage('It took ' + FloattostrF((v2 - TimeVar) / 1000, FFFixed, 7, 3) + ' sec. to execute Programm.');
      End;
      AktualDebugLine := -1;
      form1.code.Invalidate;
    End
    Else Begin
      Form1.BringToFront;
      AktualDebugLine := Bline;
      form1.SpringezuZeile(Bline);
      form1.code.Invalidate;
      Checkforwantedvalues(alp);
    End;
  End
  Else Begin
    AktualDebugLine := -1;
    form1.code.Invalidate;
    // Wieder Freischalten des Run Button
    SetUnknown;
    form5.Button1.enabled := true;
    form5.Caption := 'Programm simulation';
    If High(CompiledCode.vars) <> -1 Then
      Form5.edit6.Text := inttostr(CompiledCode.vars[0].value)
    Else
      Form5.edit6.Text := '';
    Form5.BringToFront;
    form5.Checkbox1.enabled := true;
    If form5.Checkbox1.Checked Then Begin
      v2 := GetTickCount64;
      If High(compiledcode.vars) <> -1 Then
        showmessage('It took ' + FloattostrF((v2 - TimeVar) / 1000, FFFixed, 7, 3) + ' sec. to execute Programm.');
    End;
  End;
End;

Procedure StartExecute;
Begin
  LoopRechner.Clear;
  With LoopRechner Do Begin
    Push(CompiledCode.code); // Starten des ganzen Spasses
  End;
  execute(false, false);
End;

End.

