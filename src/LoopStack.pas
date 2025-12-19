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
Unit LoopStack;

{$MODE objfpc}{$H+}

Interface

Uses ucompiler;

Type

  // Die Pointerdefinition für unseren Stack
  pstack = ^Tstack;

  // Das jeweils gespeicherte Element mit Verweis auf das nächste
  Tstack = Record
    Data: PBefehl;
    next: Pstack;
  End;

  // Ein Auf unser Problem zugeschnittener STACK
  TLoopStack = Class
  private
    FStack: pstack; // Der Anker
  public
    Function POP: PBefehl;
    Procedure Push(Value: Pbefehl);
    Function isempty: Boolean;
    Procedure Clear;
    Constructor Create;
    Destructor destroy; override;
  End;

Implementation

Constructor TLoopStack.Create;
Begin
  Inherited create;
  FStack := Nil;
End;

Destructor TLoopStack.destroy;
Begin
  If FStack <> Nil Then clear;
  // Wer weis, vielleicht erklärt mir mal jemand wieso man das nicht machen darf,
  // Inherited Destroy;
End;

Function TLoopStack.POP: PBefehl;
Var
  t: pstack;
Begin
  {
   Es Braucht hier keine Function zum Testen ob der Stack Leer ist.
   Da das die Datenstruktur ansich regelt.
   D.h. ein Pop auf Leerem Stack liefert genau den NIL Pointer , aber ohne Exception
   Die würde eh nie Kommen, da der einzige Pop Befehl den es gibt in
   Executer.pas "Procedure Execute(Onestep, Ignorefirst: Boolean);" ist
   und hier wird direkt in der Zeile drüber erst mal geschaut ob der Stack auch ja nicht leer ist !!
  }
  result := Fstack^.Data;
  t := Fstack;
  Fstack := Fstack^.next;
  dispose(T);
End;

Procedure TLoopStack.Push(Value: Pbefehl);
Var
  t: Pstack;
Begin
  new(t);
  t^.Data := value;
  t^.next := Nil;
  If FStack = Nil Then Begin
    Fstack := t;
  End
  Else Begin
    t^.next := Fstack;
    Fstack := t;
  End;
End;

Procedure TLoopStack.Clear;
Var
  f, t: Pstack;
Begin
  // Löschen des Gesamten Stack's
  f := Fstack;
  While f <> Nil Do Begin
    t := f;
    f := f^.next;
    dispose(t);
  End;
  Fstack := Nil;
End;

Function TLoopStack.isempty: Boolean;
Begin
  result := Fstack = Nil;
End;

End.

