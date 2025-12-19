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
Unit uloop;

{$MODE ObjFPC}{$H+}

Interface

Uses
  Classes, SysUtils, Graphics;

Type
  TUserHiglighter = Record
    VG: Integer;
    HG: Integer;
    Bold: Boolean;
    Italic: Boolean;
    Underline: Boolean;
  End;

  TUserFont = Record
    Name: Tfontname;
    Size: Integer;
    Style: Tfontstyles;
  End;

Const
  // Consts for indexing into TUserScheme
  usWhiteSpace = 0;
  usComment = 1;
  usKeyword = 2;
  usIdentifier = 3;
  usSymbols = 4;
  usNumbers = 5;
  usMarkedBlock = 6;
  usRightEdge = 7;

Type
  TUserScheme = Array[0..7] Of TUserHiglighter;
  //  Hier mus das Attribut Right Edge noch eingefügt Werden !! Sowohl die Angabe wo als auch die Farbe

Const

  LoopVer = 0.13;

  allowedchars = [// Auflistung aller Erlaubten Zeichen
  'a'..'z', 'A'..'Z', '_', // Namen
  '0'..'9', // Zahlen
  '+', '-', '*', '^', '<', '>', // Operatoren
  ';', ':', '=', ' ', ',', // Steuerzeichen
  '/', '{', '}', '(', ')' // Kommentarzeichen
  ];
  (******************************************************************************)
  (*                                                                            *)
  (*                                 ACHTUNG                                    *)
  (*                                                                            *)
  (* Die Klasse Trechentree nutzt folgende Zeichen :                            *)
  (*                                                                            *)
  (*                  ] , § , $ , ! , ? , ~ , # , % , [ , «                     *)
  (*                                                                            *)
  (* Diese Zeichen dürfen in "allowedchars" nicht enthalten sein !!!!!!!!!!!    *)
  (*                                                                            *)
  (******************************************************************************)

Var
  defcaption: String; // wird in Form1.Create Initialisiert

  CompilableLines, // Jede int64 Zahl die hier aufgelistet ist steht für eine Compilierbare Zeile
  Brakepoints, // Jede int64 Zahl die Hier aufgelistet ist steht für einen Brakepoint
  Watched_vars // Der Index der Überwachten Variablen im Array
  : Array Of int64;

  blankPerIdent, // gibt die Anzahl der Einrückungen an die In einer Procedur gemacht werden
  Colorsheme, // Gibt an welches Farbschema gerade benutzt wird
  AktualDebugLine, // Gibt die zeile an in der sich der Debugger Aktuell befindet
  Aktualerrorline // ist die Zeile in die der Compiler als erstes Springt wenn er einen Fehler Findet
  : int64;

  RemoveDoubleBlank, // Gibt an op Doppelt vorkommende Leerzeilen gelöscht werden dürfen
  allow2varnotconst, // Wenn Tru dann darf die 2. Variable eines Operandes auch eine Variable sein.
  allowminus, // Wenn True dann kann das Modifizierte Minus benutzt werden
  allowMulti, // Wenn True dann ist die Multiplikatin erlaubt
  allowklammern, // Wenn True dann dürfen mehere Ausdrücke in eine Zeile
  allowothernames, // Wenn True dann dürfen Variablen auch anders heisen als X1.. XN
  allowfunction, // Erlaubt das Deklarieren von Functionen
  allowdiv, // Erlaubt den Div Operator
  allowif, // Erlaubt IF then Else
  allowgroeserKleiner, // Wenn If Then Else Erlaubt ist kann man Auch > < erlauben
  allowMod, // Erlaubt den Mod OPerator
  first, // Ist zum Laden einer Datei die Via Drag and Drop auf die Exe geschoben wird
  Projektchanged, // Speichert ob der Code verändert wurde
  Havetosave // Wenn True mus die Datei gespeichert werden bevor compiliert wird
  : Boolean;

  AktualFilename // Hier wird die Aktuell geladene Filename gespeichert
  : String;

  Usercheme // Hier werden die Highlighter optionnen für User definiert eingestellt, ist mit schema Standart vorbelegt.
  : TUserScheme;

  UserFont // Hier wird die Schriftart und Größe des Users gespeichert
  : TUserFont;


  // Liefert den Korrekten Namen der Variable, so wie der User ihn eingegeben hat.
Function getuserVarname(Value: String): String;

Function FontstyletoString(data: Tfontstyles): String;
Function getFontstylefromstring(Data: String): Tfontstyles;

Implementation

// Diese Function soll dann später wenn der Compiler mal Functionen kann die entsprechenden
// Korrekten Namen rausparsen aber bis dahin macht sie nix.

Function getuserVarname(Value: String): String;
Var
  f, b: String;
Begin
  If Pos('æ', Value) = 0 Then
    result := value
  Else Begin
    f := copy(value, 1, pos('æ', value) - 1);
    b := copy(value, length(f) + 2, length(value));
    //    result := 'Function(' + f + '), Value :' + b;
    If Uppercase(b) = 'RESULT' Then Begin
      result := 'Function ' + f;
    End
    Else Begin
      result := b + ' in (' + f + ')';
    End;
  End;
End;

Function FontstyletoString(data: Tfontstyles): String;
Var
  erg: String;
Begin
  erg := '';
  If fsBold In data Then erg := 'Bold';
  If fsItalic In data Then Begin
    If Length(Erg) = 0 Then
      erg := 'Italic'
    Else
      erg := erg + ', Italic';
  End;
  If fsUnderline In data Then Begin
    If Length(Erg) = 0 Then
      erg := 'Underline'
    Else
      erg := erg + ', Underline';
  End;
  If fsStrikeout In data Then Begin
    If Length(Erg) = 0 Then
      erg := 'Strikeout'
    Else
      erg := erg + ', Strikeout';
  End;
  If length(erg) = 0 Then
    erg := 'Standard';
  result := erg;
End;

Function getFontstylefromstring(Data: String): Tfontstyles;
Var
  erg: Tfontstyles;
Begin
  erg := [];
  If Pos('Bold', data) <> 0 Then include(erg, fsbold);
  If Pos('Italic', data) <> 0 Then include(erg, fsItalic);
  If Pos('Underline', data) <> 0 Then include(erg, fsUnderline);
  If Pos('Strikeout', data) <> 0 Then include(erg, fsStrikeout);
  result := Erg;
End;

End.

