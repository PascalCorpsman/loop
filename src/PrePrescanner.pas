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
Unit PrePrescanner;

{$MODE objfpc}{$H+}

Interface

Uses classes, sysutils;

Function PrePrescan(Lines: Tstrings; Const WarningsLogger: TStrings): Boolean;

Implementation

Function PrePrescan(Lines: Tstrings; Const WarningsLogger: TStrings): Boolean;
Var
  erg: boolean;
Begin
  erg := false;
  //  WarningsLogger.add('Found Error in Line [' + inttostr(getline(Value)) + '] : ' + ' Missing "Then".');

  result := erg;
End;

End.


