(******************************************************************************)
(* Loop                                                            ??.??.2006 *)
(*                                                                            *)
(* Version     : 0.13                                                         *)
(*                                                                            *)
(* Author      : Uwe Schächterle (Corpsman)                                   *)
(*                                                                            *)
(* Support     : www.Corpsman.de                                              *)
(*                                                                            *)
(* Description : Loop interpreter                                             *)
(*                                                                            *)
(* License     : See the file license.md, located under:                      *)
(*  https://github.com/PascalCorpsman/Software_Licenses/blob/main/license.md  *)
(*  for details about the license.                                            *)
(*                                                                            *)
(*               It is not allowed to change or remove this text from any     *)
(*               source file of the project.                                  *)
(*                                                                            *)
(* Warranty    : There is no warranty, neither in correctness of the          *)
(*               implementation, nor anything other that could happen         *)
(*               or go wrong, use at your own risk.                           *)
(*                                                                            *)
(* Known Issues: none                                                         *)
(*                                                                            *)
(* History     : 0.01 : o Grundprogramm                                       *)
(*                        - Code Formater                                     *)
(*                        - Highlighter                                       *)
(*                        - Explorer ( zum anzeigen evtler Functionsnamen)    *)
(*                        - Laden / Speichern                                 *)
(*                        - Compiler zum ausführen der Loop Programme         *)
(*                      o Zulassen erweiterter Variablennamen                 *)
(*               0.02 : o Erweiterung der Sprache auf If - Then - Else        *)
(*                         Strukturen.                                        *)
(*                      o Zulassen von Variablen als zweiten Parameter von    *)
(*                         +, - ,^- ..                                        *)
(*               0.03 : o Einbau eines Schritt für Schritt Debugger's         *)
(*                        - Zeigt alle Variablen sowie den Aktuellen Loop     *)
(*                           Zähler                                           *)
(*               0.04 : o Umschreiben der Compilerstruktur, dadruch           *)
(*                         erheblicher Geschwindigkeitsgewinn.                *)
(*               0.05 : o Umschreiben der Datenstruktur für anweisungen und   *)
(*                         If abfragen                                        *)
(*                        - Ermöglichen von Mehrfachbedingungen und Mehrfach  *)
(*                           zuweisungen ( z.B. : X0:= X1 +X2 +X3; )          *)
(*                      o Erweitern der Operatoren für If bedingungn auf      *)
(*                         beliebige schachtelungen und "<", ">", ">=", "<="  *)
(*                      o Hinzufügen eines Suchen Ersetzen Dialoges für den   *)
(*                         Editor                                             *)
(*               0.06 : o Einbau der "Functionen" in den Compiler             *)
(*                        - inklusive entsprechendem bindungsbereich der      *)
(*                          Variablen                                         *)
(*                      o Einrichtung der Unterstützung für die Dateiendung   *)
(*                         .Loop                                              *)
(*                      o Einbau einer Schnellspeichern Function              *)
(*                      o Umschreiben des Ausdruckparsers Fehler der Art      *)
(*                        X0:= -X1; weden nun erkannt.                        *)
(*                      o Einbau eines Suchen Dialoges                        *)
(*                      o Anzeigen unbenutzter Functionen / Variablen         *)
(*               0.07 : o schreiben eines Uninstallers                        *)
(*                      o Automatisches Speichern vor Compilieren (Optional)  *)
(*               0.08 : o Umbau des Codeformaters Leerzeichen in Kommentaren  *)
(*                         werden nun nicht mehr Gelöscht !!                  *)
(*                      o Einbau eines Statusbar der aktuelle Zeile, Geladene *)
(*                         Datei .. Anzeigt                                   *)
(*                      o Hinzufügen einiger Sample Programme zur             *)
(*                         Demonstration der Loop Sprache                     *)
(*                      o Einbau einer Zeitanzeige wie Lange es dauert ein    *)
(*                         Programm aus zu führen.                            *)
(*                      o Umschreiben des Gesammten Programmes auf 64 Bit     *)
(*                         Variablen damit sind größere Zahlenbereiche        *)
(*                         möglich.                                           *)
(*                        - Zahlen gehen nun von 0 bis 9223372036854775807    *)
(*               0.09 : o Einbau einer Überwachung der Grenzen des            *)
(*                         Variablentypes, damit erkennen von Overflow,       *)
(*                         Underflow, Division by Zero                        *)
(*                      o Letzte Korrekturen Am Farbschema                    *)
(*               0.10 : o Teilweise umgestalltung der Menuleiste und damit    *)
(*                         beheben des Copy Past Bug's                        *)
(*               0.11 : o Erweitern des Colorshems auf User Definierte        *)
(*                         Einstellungen.                                     *)
(*               0.12 : o Einbau eines Features zum Automatischen             *)
(*                         Auskommentieren von Source Code                    *)
(*                      o Ermöglichen des Ausdruckens des Codes               *)
(*                      o Einrichten einer Schriftart einstellung für den     *)
(*                         Editor                                             *)
(*               0.13 : o Port nach Lazarus / FreePascal                      *)
(*                                                                            *)
(* Bisher Behobene Bugs :                                                     *)
(*                                                                            *)
(*  - Erlauben von Konstanten bei Functionsaufrufen ( 0.06 )                  *)
(*  - Einstellige Functionsaufrufe wurden nicht geparst. ( 0.06 )             *)
(*  - Falsch geklammerte Ausdrücke werden nun erkanne. ( 0.07 )               *)
(*  - Das Autospeichern hat die Aktion das Speichern nicht gespeichert.       *)
(*     ( 0.08 )                                                               *)
(*  - Der Codeformater und damit auch Der Kompiler haben Anweisungen der Art  *)
(*     <= und >= nicht erkennen können. ( 0.08 )                              *)
(*  - >= und <= wurden nur erkannt wenn ein Leerzeichen davor stand. ( 0.08 ) *)
(*  - Bei Drücken von STRG + F2 wenn das Programm ganz Normal Lief ist alles  *)
(*     Abgeraucht. ( 0.08 )                                                   *)
(*  - Fehlerhafte If Blöcke solten nun erkannt werden. ( 0.08 )               *)
(*  - Das Programm stürzt nicht mehr ab wenn hinter Var ein Deklarationsteil  *)
(*     vergessen wird ( 0.08 )                                                *)
(*  - Zeitmessung wurde nach dem Ersten Runn deaktiviert und konnte nicht mehr*)
(*     aktiviert werden. ( 0.10 )                                             *)
(*  - Codeformater hat schlüsselwort Var falsch behandelt und eingerückt.     *)
(*     ( 0.10 )                                                               *)
(*  - Beim Neustart des Betriebssystemes ist das Programm manchmal kurz       *)
(*     sichtbar gewesen. ( 0.12 )                                             *)
(*  - x * 0 hat Division durch 0 Fehler gegeben. ( 0.12 )                     *)
(*
Bisher noch nicht Behobene Bugs :

Sind der Codeviewer und der Loop Kompiler Gleichzeitig geöffnet functioniert das
automatische öffnen von dateien nicht mehr, Fehlerhaft.

Das Copy und Paste tut mal gar nicht !!

Proceduren Und Functionen dürfen keine Schlüsselworte Sein !!!

Wenn ALT + F4 Gedrückt wird in der Programmsimulation dann wird der Komplette Compiler Beendet

Es können irgendwo Begin wörter stehen obwohl sie überhaupt keinen Sinn machen die sollten erkannt werden

Procedure Project1;
  Function Test(a, b);
  Begin
    result := a + b;
  End;
Begin
  x0 := 4 + test(5, 6);
End;

Hat das Ergebnis 11 und nicht 15 !!!

-------------------------------------------------------------------------

Noch nicht drin :
- Make Exe File
- Convert to Real Loop Programm
*)
(*                                                                            *)
(******************************************************************************)
Unit unit1;

{$MODE objfpc}{$H+}

Interface

Uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, SynEdit, SynEditHighlighter, SynHighlighterPas, StdCtrls,
  ComCtrls, ExtCtrls, ImgList, Parser, ucompiler, Executer,
  SynEditMiscClasses, Registry, SynEditTypes,
  Printers, UniqueInstance, SynEditMarks, SynHighlighterAny, uloop;

Type

  { TForm1 }

  TForm1 = Class(TForm)
    MainMenu1: TMainMenu;
    Datei1: TMenuItem;
    Close1: TMenuItem;
    Code: TSynEdit;
    Color1: TMenuItem;
    Colorsheme1: TMenuItem;
    Explorer: TTreeView;
    Splitter1: TSplitter;
    UniqueInstance1: TUniqueInstance;
    Warnings_Error: TListBox;
    CodeFormater1: TMenuItem;
    Controlled_Varables: TListBox;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    ShowExplorer1: TMenuItem;
    Debug1: TMenuItem;
    ShowcontrolledValues1: TMenuItem;
    Loop_Highlither1: TSynAnySyn;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    New1: TMenuItem;
    Load1: TMenuItem;
    Save1: TMenuItem;
    Extendedoptions1: TMenuItem;
    Help1: TMenuItem;
    Info1: TMenuItem;
    Start1: TMenuItem;
    Run1: TMenuItem;
    Compile1: TMenuItem;
    ConverttorealLoopprogram1: TMenuItem;
    BookMarks: TImageList;
    DebugMarks: TImageList;
    ExplorerSymbols: TImageList;
    CodeFormater2: TMenuItem;
    Instruction1: TMenuItem;
    PopupMenu1: TPopupMenu;
    Add1: TMenuItem;
    Deleteall1: TMenuItem;
    Createexefile1: TMenuItem;
    Stop1: TMenuItem;
    asd1: TMenuItem;
    AktuallLoopcount1: TMenuItem;
    SearchReplace1: TMenuItem;
    //    SynEditSearch1: TSynEditSearch;
    SaveAs1: TMenuItem;
    FindDialog1: TFindDialog;
    Find1: TMenuItem;
    hidemenue1: TMenuItem;
    PopupMenu2: TPopupMenu;
    close2: TMenuItem;
    StatusBar1: TStatusBar;
    Edit1: TMenuItem;
    Copy1: TMenuItem;
    Selectall1: TMenuItem;
    N1: TMenuItem;
    Step1: TMenuItem;
    ToggleBrakePoint1: TMenuItem;
    N2: TMenuItem;
    CommentSelectedBlock1: TMenuItem;
    UncommentSelectedBlock1: TMenuItem;
    Print1: TMenuItem;
    Procedure Close1Click(Sender: TObject);
    Procedure CodeGutterClick(Sender: TObject; X, Y, Line: integer;
      mark: TSynEditMark);
    Procedure FormCreate(Sender: TObject);
    Procedure Colorsheme1Click(Sender: TObject);
    Procedure CodeKeyPress(Sender: TObject; Var Key: Char);
    Procedure ShowExplorer1Click(Sender: TObject);
    Procedure ShowcontrolledValues1Click(Sender: TObject);
    Procedure CodeSpecialLineColors(Sender: TObject; Line: integer;
      Var Special: Boolean; Var FG, BG: TColor);
    Procedure FormClose(Sender: TObject; Var CloseAction: TCloseAction);
    Procedure CodeKeyDown(Sender: TObject; Var Key: Word;
      Shift: TShiftState);
    Procedure Load1Click(Sender: TObject);
    Procedure Save1Click(Sender: TObject);
    Procedure Info1Click(Sender: TObject);
    Procedure Extendedoptions1Click(Sender: TObject);
    Procedure CodeGutterPaint(Sender: TObject; aLine, X, Y: integer);
    Procedure CodeChange(Sender: TObject);
    Procedure FormShow(Sender: TObject);
    Procedure New1Click(Sender: TObject);
    Procedure Compile1Click(Sender: TObject);
    Procedure Run1Click(Sender: TObject);
    Procedure CodeFormater1Click(Sender: TObject);
    Procedure CodeFormater2Click(Sender: TObject);
    Procedure Instruction1Click(Sender: TObject);
    Procedure ConverttorealLoopprogram1Click(Sender: TObject);
    Procedure Controlled_VarablesMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    Procedure UniqueInstance1OtherInstance(Sender: TObject;
      ParamCount: Integer; Const Parameters: Array Of String);
    Procedure Warnings_ErrorMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    Procedure Deleteall1Click(Sender: TObject);
    Procedure Warnings_ErrorDblClick(Sender: TObject);
    Procedure CodeClick(Sender: TObject);
    Procedure Createexefile1Click(Sender: TObject);
    Procedure Add1Click(Sender: TObject);
    Procedure Stop1Click(Sender: TObject);
    Procedure asd1Click(Sender: TObject);
    Procedure AktuallLoopcount1Click(Sender: TObject);
    Procedure SearchReplace1Click(Sender: TObject);
    Procedure SaveAs1Click(Sender: TObject);
    Procedure Find1Click(Sender: TObject);
    Procedure FindDialog1Find(Sender: TObject);
    Procedure hidemenue1Click(Sender: TObject);
    Procedure close2Click(Sender: TObject);
    Procedure CodeStatusChange(Sender: TObject;
      Changes: TSynStatusChanges);
    Procedure Copy1Click(Sender: TObject);
    Procedure Selectall1Click(Sender: TObject);
    Procedure Step1Click(Sender: TObject);
    Procedure ToggleBrakePoint1Click(Sender: TObject);
    Procedure CommentSelectedBlock1Click(Sender: TObject);
    Procedure UncommentSelectedBlock1Click(Sender: TObject);
    Procedure Print1Click(Sender: TObject);
  private
    { Private-Deklarationen }
    Procedure CheckShowHideWarnings;
  public
    { Public-Deklarationen }
  End;


Var
  Form1: TForm1;

  // Setzt die zu Highlightenden Schlüsselworte
Procedure SetKeywords;
// Setzt den Higlighter auf das Actuelle Farbschema
Procedure SETColorSheme;
// Gibt True zurück wenn die in Value stehende int64 Zahl in brakepoints enthalten ist
Function isBrakepoint(value: int64): Boolean;
// Springt an die Zeile Value:
Procedure SpringezuZeile(value: int64);

Implementation

Uses
  LCLType,
  unit2, // Color_Sheme
  unit3, // Extended_Options
  unit4, // New_Projekt
  unit5, // Programm_Simulation
  unit6, // Code_Formater
  unit7, //Instructions
  LoopStack,
  unit8, // Controlled_Vars
  unit9, // Replacer
  // unit10, Extended_Color_Options
  unit11 // Printdialog
  ;

{$R *.lfm}

// Wird ein Index im Text überge ben so Ermittelt die Function die Zeile in der der Index steht

Function IndextoLine(Const Data: Tstrings; Index: Integer): integer;
Var
  erg: Integer;
  x: integer;
Begin
  erg := 0;
  x := 0;
  While x < index Do Begin
    If data.Text[x] = #13 Then inc(erg);
    inc(x);
  End;
  result := erg;
End;

Procedure LoadProject(Filename: String);
Begin
  If (length(AktualFilename) <> 0) And Projektchanged Then Begin
    Case Application.Messagebox(pchar(extractfilename(AktualFilename) + ' is not saved yet do you want to save it now ?'), 'Info', MB_YESNO + MB_ICONQUESTION) Of
      ID_YES: Begin
          form1.SaveAs1Click(Nil);
          AktualFilename := '';
          LoadProject(filename);
        End;
      ID_NO: Begin
          AktualFilename := '';
          LoadProject(filename);
        End;
    End;
  End
  Else Begin
    Projektchanged := false;
    AktualFilename := filename;
    form1.StatusBar1.Panels[2].Text := extractfilename(filename);
    form1.StatusBar1.Panels[1].Text := '';
    form1.StatusBar1.Panels[0].Text := ' 1: 1';
    form1.Code.Lines.LoadFromFile(filename);
    form1.opendialog1.InitialDir := extractfilepath(form1.Opendialog1.FileName);
    form1.savedialog1.InitialDir := extractfilepath(form1.Opendialog1.FileName);
    If form1.Explorer.visible Then GetFunnames(form1.Code.Lines, form1.explorer);
  End;
End;

Function geterrorline(value: int64): int64;
Var
  lin: String;
Begin
  lin := Form1.Warnings_Error.items[value];
  result := strtoint(copy(lin, pos('[', lin) + 1, pos(']', lin) - pos('[', lin) - 1));
End;

// Gibt True zurück wenn die in Value stehende int64 Zahl in CompilableLines enthalten ist

Function IsCompilableLine(value: int64): boolean;
Var
  erg: Boolean;
  x: Integer;
Begin
  erg := false;
  For x := 0 To high(CompilableLines) Do
    If CompilableLines[x] = Value Then Begin
      erg := true;
      break;
    End;
  result := erg;
End;

// Gibt True zurück wenn die in Value stehende int64 Zahl in brakepoints enthalten ist

Function isBrakepoint(value: int64): Boolean;
Var
  erg: Boolean;
  x: Integer;
Begin
  erg := false;
  For x := 0 To high(brakepoints) Do
    If brakepoints[x] = Value Then Begin
      erg := true;
      break;
    End;
  result := erg;
End;

Function getProjectname: String;
Begin
  GetFunnames(form1.Code.Lines, form1.explorer);
  If form1.explorer.Items.count <> 0 Then Begin
    result := form1.explorer.Items[0].Text;
  End
  Else
    result := '';
End;

Procedure SetKeywords;
Var
  l: Tstringlist;
Begin
  l := Tstringlist.create;
  l.clear;
  l.add('Loop');
  l.add('Do');
  l.add('End');
  l.add('Begin');
  l.add('Procedure');
  l.add('Var');
  l.add('get');
  If Allowfunction Then l.add('Function');
  If Allowif Then Begin
    l.add('If');
    l.add('Then');
    l.add('Else');
    l.add('or');
    l.add('and');
  End;
  If allowmod Then l.add('mod');
  If Allowdiv Then l.add('div');
  form1.Loop_Highlither1.KeyWords := l;
  l.free;
End;

Procedure Readini;
  Procedure setstdsheme;
  Begin
    // Whitespace
    Usercheme[0].VG := clwhite;
    Usercheme[0].HG := clSilver;
    Usercheme[0].Bold := false;
    Usercheme[0].Italic := false;
    Usercheme[0].Underline := false;
    // Comment
    Usercheme[1].VG := clnavy;
    Usercheme[1].HG := clSilver;
    Usercheme[1].Bold := false;
    Usercheme[1].Italic := True;
    Usercheme[1].Underline := false;
    // Keyword
    Usercheme[2].VG := clblack;
    Usercheme[2].HG := clSilver;
    Usercheme[2].Bold := true;
    Usercheme[2].Italic := false;
    Usercheme[2].Underline := false;
    // Identifier
    Usercheme[3].VG := clblack;
    Usercheme[3].HG := clSilver;
    Usercheme[3].Bold := false;
    Usercheme[3].Italic := false;
    Usercheme[3].Underline := false;
    // Symbols
    Usercheme[4].VG := clblack;
    Usercheme[4].HG := clSilver;
    Usercheme[4].Bold := false;
    Usercheme[4].Italic := false;
    Usercheme[4].Underline := false;
    // Numbers
    Usercheme[5].VG := clblack;
    Usercheme[5].HG := clSilver;
    Usercheme[5].Bold := false;
    Usercheme[5].Italic := false;
    Usercheme[5].Underline := false;
    // Markiert
    Usercheme[6].VG := clblack;
    Usercheme[6].HG := clGray;
    Usercheme[6].Bold := false;
    Usercheme[6].Italic := false;
    Usercheme[6].Underline := false;
    // Strich Rechts bei 80 Zeichen
    Usercheme[7].VG := clGray;
    Usercheme[7].HG := clSilver;
    Usercheme[7].Bold := false;
    Usercheme[7].Italic := false;
    Usercheme[7].Underline := false;
  End;

  Function stringtosheme(data: String): TUserHiglighter;
  Var
    s: String;
    erg: TUserHiglighter;
  Begin
    s := copy(data, 1, pos(',', data) - 1);
    delete(data, 1, pos(',', data));
    erg.VG := stringtocolor(s);
    s := copy(data, 1, pos(',', data) - 1);
    delete(data, 1, pos(',', data));
    erg.HG := stringtocolor(s);
    s := copy(data, 1, pos(',', data) - 1);
    delete(data, 1, pos(',', data));
    erg.Bold := odd(strtoint(s));
    s := copy(data, 1, pos(',', data) - 1);
    delete(data, 1, pos(',', data));
    erg.Italic := odd(strtoint(s));
    erg.Underline := odd(strtoint(data));
    result := erg;
  End;

  Procedure SetDefaultSettings();
  Begin
    // Die Default einstellungen
    allowMod := false;
    allowif := false;
    allowdiv := false;
    allowfunction := False;
    allowminus := False;
    allowMulti := False;
    allowklammern := False;
    allowothernames := False;
    allowgroeserKleiner := false;
    allow2varnotconst := false;
    Colorsheme := 0;
    RemoveDoubleBlank := true;
    blankPerIdent := 2;
    Havetosave := true;
    setstdsheme;
    UserFont.Size := 10;
    UserFont.Name := 'Courier New';
    UserFont.Style := [];
  End;

Var
  sl: TStringList;
  s: String;
  x: integer;
  fs: TFormatSettings;
Begin
  If Fileexists(extractfilepath(application.exename) + PathDelim + 'User.ini') Then Begin
    fs := DefaultFormatSettings;
    fs.DecimalSeparator := '.'; // ENG
    sl := TStringList.Create;
    sl.LoadFromFile(extractfilepath(application.exename) + PathDelim + 'User.ini');
    s := sl[0];
    If Strtofloat(s, fs) = LoopVer Then Begin
      s := sl[1];
      allowMod := odd(strtoint(s));
      s := sl[2];
      allowif := odd(strtoint(s));
      s := sl[3];
      allowdiv := odd(strtoint(s));
      s := sl[4];
      allowfunction := odd(strtoint(s));
      s := sl[5];
      allowminus := odd(strtoint(s));
      s := sl[6];
      allowMulti := odd(strtoint(s));
      s := sl[7];
      allowklammern := odd(strtoint(s));
      s := sl[8];
      allowothernames := odd(strtoint(s));
      s := sl[9];
      allowgroeserKleiner := odd(strtoint(s));
      s := sl[10];
      allow2varnotconst := odd(strtoint(s));
      s := sl[11];
      Colorsheme := strtoint(s);
      s := sl[12];
      RemoveDoubleBlank := odd(strtoint(s));
      s := sl[13];
      blankPerIdent := strtoint(s);
      s := sl[14];
      Havetosave := odd(strtoint(s));
      For x := 0 To high(usercheme) Do Begin
        s := sl[15 + x];
        usercheme[x] := stringtosheme(s);
      End;
      s := sl[15 + high(usercheme) + 1];
      userfont.size := strtoint(s);
      s := sl[15 + high(usercheme) + 2];
      userfont.name := s;
      s := sl[15 + high(usercheme) + 3];
      userfont.Style := getFontstylefromstring(s);
      s := sl[15 + high(usercheme) + 4];
      form1.code.RightEdge := strtoint(s);

      // weiter

    End
    Else Begin
      SetDefaultSettings();
    End;
    sl.free;
  End
  Else Begin
    SetDefaultSettings();
  End;
End;

Procedure Writeini;
  Function shtostring(sh: TUserHiglighter): String;
  Var
    erg: String;
  Begin
    erg := colortostring(sh.VG) + ',' + colortostring(sh.HG);
    erg := erg + ',' + inttostr(ord(sh.Bold));
    erg := erg + ',' + inttostr(ord(sh.Italic));
    erg := erg + ',' + inttostr(ord(sh.Underline));
    result := Erg;
  End;
Var
  sl: TStringList;
  x: integer;
  fs: TFormatSettings;
Begin
  fs := DefaultFormatSettings;
  fs.DecimalSeparator := '.'; // ENG
  sl := TStringList.Create;
  sl.add(floattostr(LoopVer, fs));
  sl.add(inttostr(ord(allowMod)));
  sl.add(inttostr(ord(allowif)));
  sl.add(inttostr(ord(allowdiv)));
  sl.add(inttostr(ord(allowfunction)));
  sl.add(inttostr(ord(allowminus)));
  sl.add(inttostr(ord(allowMulti)));
  sl.add(inttostr(ord(allowklammern)));
  sl.add(inttostr(ord(allowothernames)));
  sl.add(inttostr(ord(allowgroeserKleiner)));
  sl.add(inttostr(ord(allow2varnotconst)));
  sl.add(inttostr(Colorsheme));
  sl.add(inttostr(ord(RemoveDoubleBlank)));
  sl.add(inttostr(blankPerIdent));
  sl.add(inttostr(ord(Havetosave)));
  For x := 0 To high(usercheme) Do Begin
    sl.add(shtostring(usercheme[x]));
  End;
  sl.add(inttostr(userfont.size));
  sl.add(userfont.name);
  sl.add(FontstyletoString(userfont.style));
  sl.add(inttostr(form1.code.RightEdge));

  // weiter

  sl.SaveToFile(extractfilepath(application.exename) + PathDelim + 'User.ini');
  sl.free;
End;

Procedure ToggleBrakepoint(Line: int64);
Var
  x, vi, j: integer;
  m: TSynEditMark;
Begin
  //Es sollte noch der Rote Punkt Links rein
  If Not isBrakepoint(line) Then Begin // Hinzufügen eines Brakepoints
    setlength(Brakepoints, high(Brakepoints) + 2);
    Brakepoints[high(Brakepoints)] := line;
    m := TSynEditMark.Create(form1.code);
    m.Line := line;
    m.Visible := true;
    m.ImageList := form1.DebugMarks;
    m.ImageIndex := 0;
    form1.code.Marks.Add(m);
  End
  Else Begin // Löschen des Brakepoints
    vi := -1;
    For x := 0 To high(Brakepoints) Do
      If Brakepoints[x] = Line Then vi := x;
    If vi < high(Brakepoints) Then Begin
      For x := vi To high(Brakepoints) - 1 Do
        Brakepoints[x] := Brakepoints[x + 1];
    End;
    setlength(Brakepoints, high(Brakepoints));
    For j := 0 To form1.Code.Marks.Count - 1 Do Begin
      If form1.Code.Marks[j].Line = line Then Begin
        form1.Code.Marks.Delete(j);
        break;
      End;
    End;
  End;
  form1.code.Invalidate;
End;

Procedure SpringezuZeile(value: int64);
Begin
  With form1.code Do Begin
    CaretX := 1;
    CaretY := value;
    SetFocus;
  End;
End;

Procedure SETColorSheme;

  Function makefont(sh: TUserHiglighter): TFontStyles;
  Var
    erg: TFontStyles;
  Begin
    erg := [];
    If sh.Bold Then Include(erg, fsbold);
    If sh.Italic Then include(erg, fsItalic);
    If sh.Underline Then include(erg, fsUnderline);
    result := erg;
  End;
  // Colorsheme = 0 = Standard
  // Colorsheme = 1 = Classic
  // Colorsheme = 2 = Dawn
  // Colorsheme = 3 = Ozean
  // Colorsheme = 4 = User Definied
Begin
  With Form1 Do Begin
    Case Colorsheme Of
      0: Begin
          // Hintergrundfarbe des Feldes
          code.Color := clwindow;
          Loop_Highlither1.WhitespaceAttribute.Style := [];
          // Farbe für die Kommentare
          Loop_Highlither1.CommentAttribute.Foreground := CLnavy;
          Loop_Highlither1.CommentAttribute.Background := Code.color;
          Loop_Highlither1.CommentAttribute.Style := [fsitalic];
          // Schlüsselworte Hervorheben
          Loop_Highlither1.KeywordAttribute.Foreground := clblack;
          Loop_Highlither1.KeywordAttribute.Style := [FSbold];
          Loop_Highlither1.KeywordAttribute.Background := Code.color;
          // Alle anderen Zeichen
          Loop_Highlither1.IdentifierAttribute.foreground := clblack;
          Loop_Highlither1.IdentifierAttribute.Background := Code.color;
          Loop_Highlither1.IdentifierAttribute.Style := [];
          // Farbe für Symbole
          Loop_Highlither1.SymbolAttri.Foreground := clblack;
          Loop_Highlither1.SymbolAttri.Background := code.color;
          Loop_Highlither1.SymbolAttri.Style := [];
          // Zahlen werden Lila
          Loop_Highlither1.NumberAttri.Foreground := clblack;
          Loop_Highlither1.NumberAttri.Style := [];
          Loop_Highlither1.NumberAttri.Background := code.color;
          // Markierter Block
          Code.SelectedColor.Background := $00800000;
          Code.SelectedColor.Foreground := clwhite;
          // Alle unbenutzen sachen müssen auch eingestellt werden
          // Strings werden gleich angezeigt wie Identifier
          Loop_Highlither1.StringAttribute.Foreground := clblack;
          Loop_Highlither1.StringAttribute.Background := Code.color;
          Loop_Highlither1.StringAttribute.style := [];
          // Deaktivieren des Preprocessorattr
          Loop_Highlither1.PreprocessorAttri.Foreground := clblack;
          Loop_Highlither1.PreprocessorAttri.Background := code.color;
          Loop_Highlither1.PreprocessorAttri.style := [];
          // Einfärben des Striches Rechts
          code.RightEdgeColor := clgray;
        End;
      1: Begin
          // Hintergrundfarbe des Feldes
          code.Color := clnavy;
          Loop_Highlither1.WhitespaceAttribute.Style := [];
          // Farbe für die Kommentare
          Loop_Highlither1.CommentAttribute.Foreground := CLsilver;
          Loop_Highlither1.CommentAttribute.Background := Code.color;
          Loop_Highlither1.CommentAttribute.Style := [fsitalic];
          // Schlüsselworte Hervorheben
          Loop_Highlither1.KeywordAttribute.Foreground := clwhite;
          Loop_Highlither1.KeywordAttribute.Style := [];
          Loop_Highlither1.KeywordAttribute.Background := Code.color;
          // Alle anderen Zeichen
          Loop_Highlither1.IdentifierAttribute.foreground := clyellow;
          Loop_Highlither1.IdentifierAttribute.Background := Code.color;
          Loop_Highlither1.IdentifierAttribute.Style := [];
          // Farbe für Symbole
          Loop_Highlither1.SymbolAttri.Foreground := clyellow;
          Loop_Highlither1.SymbolAttri.Background := code.color;
          Loop_Highlither1.SymbolAttri.Style := [];
          // Zahlen werden Lila
          Loop_Highlither1.NumberAttri.Foreground := clyellow;
          Loop_Highlither1.NumberAttri.Style := [];
          Loop_Highlither1.NumberAttri.Background := code.color;
          // Markierter Block
          Code.SelectedColor.Background := $00C0C0C0;
          Code.SelectedColor.Foreground := $00800000;
          // Alle unbenutzen sachen müssen auch eingestellt werden
          // Strings werden gleich angezeigt wie Identifier
          Loop_Highlither1.StringAttribute.Foreground := clyellow;
          Loop_Highlither1.StringAttribute.Background := Code.color;
          Loop_Highlither1.StringAttribute.style := [];
          // Deaktivieren des Preprocessorattr
          Loop_Highlither1.PreprocessorAttri.Foreground := clblue;
          Loop_Highlither1.PreprocessorAttri.Background := code.color;
          Loop_Highlither1.PreprocessorAttri.style := [];
          // Einfärben des Striches Rechts
          code.RightEdgeColor := clSilver;
        End;
      2: Begin
          // Hintergrundfarbe des Feldes
          code.Color := clblack;
          Loop_Highlither1.WhitespaceAttribute.Style := [];
          // Farbe für die Kommentare
          Loop_Highlither1.CommentAttribute.Foreground := CLsilver;
          Loop_Highlither1.CommentAttribute.Background := Code.color;
          Loop_Highlither1.CommentAttribute.Style := [fsitalic];
          // Schlüsselworte Hervorheben
          Loop_Highlither1.KeywordAttribute.Foreground := claqua;
          Loop_Highlither1.KeywordAttribute.Style := [FSbold];
          Loop_Highlither1.KeywordAttribute.Background := Code.color;
          // Alle anderen Zeichen
          Loop_Highlither1.IdentifierAttribute.foreground := clwhite;
          Loop_Highlither1.IdentifierAttribute.Background := Code.color;
          Loop_Highlither1.IdentifierAttribute.Style := [];
          // Farbe für Symbole
          Loop_Highlither1.SymbolAttri.Foreground := claqua;
          Loop_Highlither1.SymbolAttri.Background := code.color;
          Loop_Highlither1.SymbolAttri.Style := [];
          // Zahlen werden Lila
          Loop_Highlither1.NumberAttri.Foreground := clFuchsia;
          Loop_Highlither1.NumberAttri.Style := [];
          Loop_Highlither1.NumberAttri.Background := code.color;
          // Markierter Block
          Code.SelectedColor.Background := clwhite;
          Code.SelectedColor.Foreground := clblack;
          // Alle unbenutzen sachen müssen auch eingestellt werden
          // Strings werden gleich angezeigt wie Identifier
          Loop_Highlither1.StringAttribute.Foreground := clwhite;
          Loop_Highlither1.StringAttribute.Background := Code.color;
          Loop_Highlither1.StringAttribute.style := [];
          // Deaktivieren des Preprocessorattr
          Loop_Highlither1.PreprocessorAttri.Foreground := clwhite;
          Loop_Highlither1.PreprocessorAttri.Background := code.color;
          Loop_Highlither1.PreprocessorAttri.style := [];
          // Einfärben des Striches Rechts
          code.RightEdgeColor := clSilver;
        End;
      3: Begin
          // Hintergrundfarbe des Feldes
          code.Color := claqua;
          Loop_Highlither1.WhitespaceAttribute.Style := [];
          // Farbe für die Kommentare
          Loop_Highlither1.CommentAttribute.Foreground := $00808000;
          Loop_Highlither1.CommentAttribute.Background := Code.color;
          Loop_Highlither1.CommentAttribute.Style := [fsitalic];
          // Schlüsselworte Hervorheben
          Loop_Highlither1.KeywordAttribute.Foreground := clblack;
          Loop_Highlither1.KeywordAttribute.Style := [FSbold];
          Loop_Highlither1.KeywordAttribute.Background := Code.color;
          // Alle anderen Zeichen
          Loop_Highlither1.IdentifierAttribute.foreground := clblue;
          Loop_Highlither1.IdentifierAttribute.Background := Code.color;
          Loop_Highlither1.IdentifierAttribute.Style := [];
          // Farbe für Symbole
          Loop_Highlither1.SymbolAttri.Foreground := clblack;
          Loop_Highlither1.SymbolAttri.Background := code.color;
          Loop_Highlither1.SymbolAttri.Style := [];
          // Zahlen werden Lila
          Loop_Highlither1.NumberAttri.Foreground := clolive;
          Loop_Highlither1.NumberAttri.Style := [];
          Loop_Highlither1.NumberAttri.Background := code.color;
          //Markierter Block
          Code.SelectedColor.Background := $00FF0000;
          Code.SelectedColor.Foreground := $00FFFF00;
          // Alle unbenutzen sachen müssen auch eingestellt werden
          // Strings werden gleich angezeigt wie Identifier
          Loop_Highlither1.StringAttribute.Foreground := clblue;
          Loop_Highlither1.StringAttribute.Background := Code.color;
          Loop_Highlither1.StringAttribute.style := [];
          // Deaktivieren des Preprocessorattr
          Loop_Highlither1.PreprocessorAttri.Foreground := clblue;
          Loop_Highlither1.PreprocessorAttri.Background := code.color;
          Loop_Highlither1.PreprocessorAttri.style := [];
          // Einfärben des Striches Rechts
          code.RightEdgeColor := clSilver;
        End;
      4: Begin
          // Whitespace
          code.color := usercheme[0].HG;
          Loop_Highlither1.WhitespaceAttribute.Style := makefont(usercheme[0]);
          // Komemntare
          Loop_Highlither1.CommentAttri.Foreground := usercheme[1].VG;
          Loop_Highlither1.CommentAttri.Background := usercheme[1].HG;
          Loop_Highlither1.CommentAttri.Style := makefont(usercheme[1]);
          // Schlüsselworte Hervorheben
          Loop_Highlither1.KeywordAttribute.Foreground := usercheme[2].VG;
          Loop_Highlither1.KeywordAttribute.Background := usercheme[2].HG;
          Loop_Highlither1.KeywordAttribute.Style := makefont(usercheme[2]);
          // Identifier
          Loop_Highlither1.IdentifierAttri.Foreground := usercheme[3].VG;
          Loop_Highlither1.IdentifierAttri.Background := usercheme[3].HG;
          Loop_Highlither1.IdentifierAttri.Style := makefont(usercheme[3]);
          // Symbole
          Loop_Highlither1.SymbolAttri.Foreground := usercheme[4].VG;
          Loop_Highlither1.SymbolAttri.Background := usercheme[4].HG;
          Loop_Highlither1.SymbolAttri.Style := makefont(usercheme[4]);
          // Number
          Loop_Highlither1.NumberAttri.Style := makefont(usercheme[5]);
          Loop_Highlither1.NumberAttri.Background := usercheme[5].HG;
          Loop_Highlither1.NumberAttri.Foreground := usercheme[5].VG;
          // Markeirter Block
          code.SelectedColor.Foreground := usercheme[6].VG;
          code.SelectedColor.Background := usercheme[6].hG;
          // Alle unbenutzen sachen müssen auch eingestellt werden
          // Strings werden gleich angezeigt wie Identifier
          Loop_Highlither1.StringAttribute.Foreground := usercheme[3].VG;
          Loop_Highlither1.StringAttribute.Background := usercheme[3].HG;
          Loop_Highlither1.StringAttribute.style := makefont(usercheme[3]);
          // Deaktivieren des Preprocessorattr
          Loop_Highlither1.PreprocessorAttri.Foreground := usercheme[3].VG;
          Loop_Highlither1.PreprocessorAttri.Background := usercheme[3].HG;
          Loop_Highlither1.PreprocessorAttri.style := makefont(usercheme[3]);
          // Einfärben des Striches Rechts
          code.RightEdgeColor := usercheme[7].VG;
        End;
    End;
  End;
End;

Procedure TForm1.UniqueInstance1OtherInstance(Sender: TObject;
  ParamCount: Integer; Const Parameters: Array Of String);
Begin
  If ParamCount >= 1 Then Begin
    LoadProject(Parameters[0]);
    Form1.BringToFront;
  End;
End;

Procedure TForm1.Close1Click(Sender: TObject);
Begin
  close;
End;

Procedure TForm1.CodeGutterClick(Sender: TObject; X, Y, Line: integer;
  mark: TSynEditMark);
Begin
  // Für alle Maus user *würg*
  ToggleBrakepoint(Line);
End;

Procedure TForm1.FormCreate(Sender: TObject);
Begin
  // Initialisierne der Liste für die Compilierten Codes
  AktualFilename := '';
  Projektchanged := false;
  setlength(CompiledCode.vars, 0);
  setlength(CompiledCode.getvars, 0);
  CompiledCode.Code := Nil;
  LoopRechner := TLoopStack.create;
  Aktualerrorline := -1;
  defcaption := 'Loop Interpreter ver. ' + floattostrf(LoopVer, FFFixed, 7, 2);
  form1.Caption := defcaption;
  opendialog1.InitialDir := extractfilepath(application.exename);
  savedialog1.InitialDir := extractfilepath(application.exename);
  AktualDebugLine := -1;
  Readini;
  code.Font.size := userfont.size;
  code.Font.Name := userfont.name;
  code.Font.Style := userfont.Style;
  SetKeywords;
  setlength(Brakepoints, 0);
  ClearCompilableLines;
  Warnings_Error.Align := albottom;
  Splitter2.Align := albottom;
  Controlled_Varables.align := albottom;
  Splitter3.align := albottom;
  Explorer.align := alleft;
  splitter1.align := alleft;
  code.align := alclient;
  SETColorSheme;
  first := true;
  application.title := 'Loop Compiler';
End;

Procedure TForm1.FormClose(Sender: TObject; Var CloseAction: TCloseAction);
Begin
  writeini;
  setlength(Brakepoints, 0);
  ClearCompilableLines;
  // Freigeben aller Code Variablen
  LoopRechner.free;
  FreeCompiledcode;
  If assigned(PrintFont) Then Begin
    PrintFont.free;
    PrintFont := Nil;
  End;
End;

Procedure TForm1.Colorsheme1Click(Sender: TObject);
Begin
  form2.checkbox1.checked := Havetosave;
  form2.Combobox1.itemindex := Colorsheme;
  form2.Combobox1.text := form2.combobox1.items[form2.Combobox1.itemindex]; // Diese Zeile müsste doch eigentlich gar nicht sein ?
  form2.Edit1.text := userfont.name;
  form2.Edit2.text := inttostr(userfont.Size);
  form2.Edit3.text := FontstyletoString(userfont.style);
  form2.Edit4.text := inttostr(code.RightEdge);
  If form2.showmodal = mrOK Then Begin
    Havetosave := form2.checkbox1.checked;
    ColorSheme := form2.Combobox1.itemindex;
    Userfont.Name := form2.edit1.text;
    userfont.Size := strtointdef(form2.edit2.text, userfont.Size);
    userfont.style := getFontstylefromstring(form2.edit3.text);
    code.font.size := userfont.Size;
    code.font.Name := userfont.Name;
    code.font.Style := userfont.Style;
    code.RightEdge := strtointdef(form2.edit4.text, 80);
  End;
  SETColorSheme;
End;

Procedure TForm1.CodeKeyPress(Sender: TObject; Var Key: Char);
Begin
  If Code.readonly Then showmessage('You cannot edit the source code while running.');
  // Falls der Copmpiler Gemekert hat wird das hier abgeschaltet
  If Aktualerrorline <> -1 Then Begin
    Aktualerrorline := -1;
    code.Invalidate;
  End;
  // Würden wir dieses Zeichen erlauben dann bekäme unser Parser so manches Problem
  If Not (key In allowedchars) Then key := #0;
End;

Procedure TForm1.ShowExplorer1Click(Sender: TObject);
Begin
  Explorer.visible := Not Explorer.visible;
  Splitter1.visible := Not Splitter1.visible;
  ShowExplorer1.checked := Not ShowExplorer1.checked;
  If Explorer.visible Then GetFunnames(Code.Lines, explorer);
End;

Procedure TForm1.ShowcontrolledValues1Click(Sender: TObject);
Begin
  Controlled_Varables.visible := Not Controlled_Varables.visible;
  Splitter3.visible := Not Splitter3.visible;
  ShowcontrolledValues1.checked := Not ShowcontrolledValues1.checked;
  If AktualDebugLine <> -1 Then
    Checkforwantedvalues(-1);
End;

Procedure TForm1.CodeSpecialLineColors(Sender: TObject; Line: integer;
  Var Special: Boolean; Var FG, BG: TColor);
Var
  ln: Boolean;
Begin
  ln := isBrakepoint(line);
  // Zeichen des Roten Hintergrundes für die Haltepunktlinie
  If ln Then Begin
    If High(CompilableLines) <> -1 Then Begin
      If IsCompilableLine(line) Then Begin
        Special := true;
        FG := clwhite;
        BG := clred;
      End
      Else Begin
        Special := true;
        FG := cllime;
        BG := $00008080;
      End;
    End
    Else Begin
      Special := true;
      FG := clwhite;
      BG := clred;
    End;
  End;
  // Zeichnet die Aktuelle Zeile des Debuggers der Gerade läuft, allerdings nur wenn diese Keine Haltepunktzeile ist !!
  If (AktualDebugLine = Line) And Not (ln) Then Begin
    Special := true;
    Case Colorsheme Of
      0: Begin
          FG := clwhite;
          BG := clnavy;
        End;
      1: Begin
          FG := clblack;
          BG := claqua;
        End;
      2: Begin
          FG := clwhite;
          BG := clblue;
        End;
      3: Begin
          FG := clwhite;
          BG := clblue;
        End;
    End;
  End;
  // ist die LinienFarbe wenn Der Compiler einen Fehler Bringt und der Rechenr da hinspringt
  If Aktualerrorline = Line Then Begin
    Special := true;
    FG := clwhite;
    BG := $00000080;
  End;
End;

Procedure TForm1.CodeKeyDown(Sender: TObject; Var Key: Word; Shift: TShiftState
  );
Begin
  If Aktualerrorline <> -1 Then Begin
    Aktualerrorline := -1;
    code.Invalidate;
  End;
End;

Procedure TForm1.Load1Click(Sender: TObject);
Begin
  If Opendialog1.execute Then Begin
    ClearCompilableLines; // Löschen der Compilable Lines
    Stop1Click(Nil); // Abbrechen aller Aktionen
    LoadProject(Opendialog1.FileName); // Neu Laden des Codes aus der Datei
  End;
End;

Procedure TForm1.Save1Click(Sender: TObject);
Begin
  // Optional Schnellspeichern, bzw normal
  If Length(AktualFilename) = 0 Then Begin
    Savedialog1.FileName := getProjectname;
    If Savedialog1.execute Then Begin
      If FileExists(savedialog1.FileName) Then Begin
        If ID_YES = Application.Messagebox('File already exists. Override it ?', 'Question', MB_YESNO + MB_ICONQUESTION) Then Begin
          Code.Lines.savetoFile(savedialog1.FileName);
          AktualFilename := savedialog1.FileName;
          opendialog1.InitialDir := extractfilepath(savedialog1.FileName);
          savedialog1.InitialDir := extractfilepath(savedialog1.FileName);
          Projektchanged := false;
          StatusBar1.Panels[1].Text := '';
          StatusBar1.Panels[2].Text := extractfilename(Savedialog1.filename);
        End;
      End
      Else Begin
        Code.Lines.savetoFile(savedialog1.FileName);
        opendialog1.InitialDir := extractfilepath(savedialog1.FileName);
        savedialog1.InitialDir := extractfilepath(savedialog1.FileName);
        AktualFilename := savedialog1.FileName;
        Projektchanged := false;
        StatusBar1.Panels[1].Text := '';
        StatusBar1.Panels[2].Text := extractfilename(Savedialog1.filename);
      End;
    End;
  End
  Else Begin
    Code.Lines.savetoFile(AktualFilename);
    StatusBar1.Panels[1].Text := '';
    Projektchanged := false;
  End;
End;

Procedure TForm1.Info1Click(Sender: TObject);
Begin
  Showmessage('Support : www.Corpsman.de');
End;

Procedure TForm1.Extendedoptions1Click(Sender: TObject);
Begin
  Form3.Checkbox1.checked := Allowif;
  Form3.Checkbox2.checked := allowfunction;
  Form3.Checkbox4.checked := allowdiv;
  Form3.Checkbox3.checked := allowMod;
  Form3.Checkbox6.checked := allowminus;
  Form3.Checkbox5.checked := allowMulti;
  Form3.Checkbox7.checked := allowklammern;
  Form3.Checkbox8.checked := allowothernames;
  Form3.Checkbox9.checked := allowgroeserKleiner;
  Form3.Checkbox10.checked := allow2varnotconst;
  Form3.showmodal;
End;

Procedure TForm1.CodeChange(Sender: TObject);
Begin
  // Aktualisieren der ExplorerView, bei Veränderungen des Code's
  If Explorer.visible Then GetFunnames(Code.Lines, explorer);
  If ClearCompilableLines Then code.Invalidate;
  Projektchanged := true;
  StatusBar1.Panels[1].Text := 'Changed';
End;

Procedure TForm1.FormShow(Sender: TObject);
Begin
  // Mus so gemacht werden da es bei OnCreate noch nicht machbar ist
  If First Then Begin
    If (length(Paramstr(1)) <> 0) Then Begin
      If FileExists(Paramstr(1)) Then Begin
        // Laden eines EVTL als Parameter übergebenen Quellcodes
        LoadProject(Paramstr(1));
      End
      Else Begin
        code.clear;
        code.lines.add('Procedure Project1;');
        code.lines.add('Begin');
        code.lines.add('End;');
      End;
    End
    Else Begin
      code.clear;
      code.lines.add('Procedure Project1;');
      code.lines.add('Begin');
      code.lines.add('End;');
    End;
  End;
  first := false;
End;

Procedure TForm1.New1Click(Sender: TObject);
Begin
  If Projektchanged Then Begin
    Save1Click(Nil);
  End;
  Form4.edit1.text := 'Project1';
  Form4.showmodal;
End;

Procedure TForm1.Compile1Click(Sender: TObject);
Begin
  Aktualerrorline := -1;
  If Havetosave Then Begin
    Save1Click(Nil);
    If Length(AktualFilename) = 0 Then exit;
  End;
  If Compile(code.lines, Warnings_Error.Items) Then Begin
    code.Invalidate;
    showmessage('Ready.');
  End
  Else Begin
    SpringezuZeile(geterrorline(warnings_Error.items.count - 1));
    Aktualerrorline := geterrorline(warnings_Error.items.count - 1);
    Code.Invalidate;
    showmessage('Error detected.')
  End;
  CheckShowHideWarnings();
End;

Procedure TForm1.Run1Click(Sender: TObject);
Var
  b: Boolean;
  x: integer;
Begin
  // Wenn wir gerade debuggt haben und wieder F9 gedrückt haben
  If AktualDebugLine <> -1 Then Begin
    AktualDebugLine := -1;
    code.Invalidate;
    form5.BringToFront;
    execute(false, true);
  End
  Else Begin
    // wenn wir wirklich neu Compilieren
    If Havetosave Then Begin // Erst Speichern !!
      Save1Click(Nil);
      If Length(AktualFilename) = 0 Then exit;
    End;
    // Dann Kompilieren
    If Compile(code.lines, warnings_Error.items) Then Begin
      code.Invalidate;
      form5.edit6.text := '';
      // zuweisen des Scrollbars
      form5.scrollbar1.visible := high(CompiledCode.GETVars) > 4;
      form5.scrollbar1.Position := 0;
      If form5.Scrollbar1.Visible Then Begin
        form5.scrollbar1.Max := high(CompiledCode.GETVars) - 4;
        form5.scrollbar1.min := 0;
      End;
      For x := 0 To high(CompiledCode.GETVars) Do Begin
        CompiledCode.GETVars[x].Value := 0;
      End;
      // Schreiben der LAbel's und des Wertes
      For x := 0 To 4 Do Begin
        If X <= high(CompiledCode.GETVars) Then Begin
          // Die Felder Sichtbar machen.
          TLAbel(form5.FindComponent('Label' + inttostr(x + 1))).Visible := true;
          TEDIT(form5.FindComponent('Edit' + inttostr(x + 1))).Visible := true;
          // Schreiben der Werte
          TLAbel(form5.FindComponent('Label' + inttostr(x + 1))).Caption := CompiledCode.GETVars[x].Name + ' =';
          // Eigentlich müste man das alles auslesen, aber da die Variablen 5 Zeilen Drüber alle auf 0 gesetzt werden kann das gespart werden ;)
          TEDIT(form5.FindComponent('Edit' + inttostr(x + 1))).text := '0';
        End
        Else Begin // Gibt es die Variablen nicht dann werden die Felder auf Invisible gesetzt
          TLAbel(form5.FindComponent('Label' + inttostr(x + 1))).Visible := false;
          TEDIT(form5.FindComponent('Edit' + inttostr(x + 1))).Visible := false;
        End;
      End;
      If Not Form5.label1.Visible Then Begin
        Form5.label1.Visible := true;
        Form5.label1.caption := 'No input value''s found.';
      End;
      // Wieder Freischalten des Run Button
      form5.Button1.enabled := true;
      form5.Caption := 'Programm simulation';
      // Dann ausführen
      code.ReadOnly := true;
      // Löschen der Bisher als Controlled Vars gefundenen Werte
      // Wenn der User aber von Vornherin sagt das er die Schleifen variablen überwacht haben will
      // dann soll diese information nicht verloren gehn.
      b := false;
      If form8.CheckListBox1.items.count <> 0 Then
        b := form8.CheckListBox1.checked[form8.CheckListBox1.items.count - 1];
      form8.CheckListBox1.items.Clear;
      If b Then
        AktuallLoopcount1Click(Nil);
      form1.caption := form1.caption + ' is running.';
      form5.Checkbox1.enabled := true;
      // Anzeige des Ausführen Fensters
      form5.show;
    End
    Else Begin
      SpringezuZeile(geterrorline(warnings_Error.items.count - 1));
      Aktualerrorline := geterrorline(warnings_Error.items.count - 1);
      Code.Invalidate;
      showmessage('Error detected.')
    End;
    CheckShowHideWarnings();
  End;
End;

Procedure TForm1.CodeFormater1Click(Sender: TObject);
Begin
  form6.SpinEdit1.value := blankPerIdent;
  form6.CheckBox1.checked := RemoveDoubleBlank;
  form6.showmodal;
End;

Procedure TForm1.CodeFormater2Click(Sender: TObject);
Var
  x: int64;
Begin
  x := Code.CaretY;
  code.lines := FormatCode(code.lines, RemoveDoubleBlank, blankPerIdent);
  Projektchanged := true;
  StatusBar1.Panels[1].Text := 'Changed';
  code.CaretY := x;
End;

Procedure TForm1.Instruction1Click(Sender: TObject);
Begin
  form7.showmodal;
End;

Procedure TForm1.ConverttorealLoopprogram1Click(Sender: TObject);
Begin
  showmessage('Not Implemented yet');
End;

Procedure TForm1.Controlled_VarablesMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
Begin
  Controlled_Varables.ItemIndex := Controlled_Varables.ItemAtPos(point(x, y), true);
End;

Procedure TForm1.Warnings_ErrorMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
Begin
  Warnings_Error.ItemIndex := Warnings_Error.ItemAtPos(point(x, y), true);
End;

Procedure TForm1.Deleteall1Click(Sender: TObject);
Var
  x: integer;
Begin
  For x := 0 To form8.CheckListBox1.items.count - 1 Do
    form8.CheckListBox1.Checked[x] := false;
  Form8.Button1Click(Nil);
End;

Procedure TForm1.Warnings_ErrorDblClick(Sender: TObject);
Begin
  If Aktualerrorline <> -1 Then Begin
    Aktualerrorline := -1;
    code.Invalidate;
  End;
  SpringezuZeile(geterrorline(Warnings_Error.itemindex));
End;

Procedure TForm1.CodeClick(Sender: TObject);
Begin
  If Aktualerrorline <> -1 Then Begin
    Aktualerrorline := -1;
    code.Invalidate;
  End;
End;

Procedure TForm1.Createexefile1Click(Sender: TObject);
Begin
  showmessage('Not Implemented yet');
End;

Procedure TForm1.Add1Click(Sender: TObject);
Begin
  Form8.showmodal;
End;

Procedure TForm1.Stop1Click(Sender: TObject);
Var
  b: Boolean;
Begin
  form5.Checkbox1.enabled := true;
  SetUnknown;
  form5.close; // Schliesen des Ausführen Fensters
  LoopRechner.clear; // Löschen des Stacks
  AktualDebugLine := -1; // Debugganzeige löschen
  Aktualerrorline := -1; // Löschen der zeile mit dem Aktuellen Fehler
  code.readonly := false; // Schreibrechte wieder erlauben
  code.Invalidate; // Neuzeichnen, damit Löschen der Roten Zeilen
  setlength(CompiledCode.vars, 0); // Löschen der Überwachten Variablen damit sie in Controlled nicht mehr gezeigt werden.
  // Löschen der überwachten Ausdrücke
  If form8.CheckListBox1.Items.count <> 0 Then Begin
    b := false;
    If form8.CheckListBox1.Checked[form8.CheckListBox1.items.count - 1] Then b := true;
    form8.CheckListBox1.items.clear;
    form1.Controlled_Varables.Items.clear;
    If B Then form1.AktuallLoopcount1Click(Nil);
  End;
  // Rücksetzen der Statusanzeige
  form1.Caption := defcaption;
End;

Procedure TForm1.asd1Click(Sender: TObject);
Begin
  If Form5.visible Then
    Form5.BringToFront;
End;

Procedure TForm1.AktuallLoopcount1Click(Sender: TObject);
Begin
  form8.FormPaint(Nil);
  form8.CheckListBox1.Checked[form8.CheckListBox1.Items.count - 1] := true;
  form8.button1.onclick(Nil);
End;

Procedure TForm1.SearchReplace1Click(Sender: TObject);
Begin
  form9.CheckBox2.Checked := code.SelStart <> Code.Selend;
  If form9.CheckBox2.checked Then
    form9.ComboBox1.text := code.SelText;
  form9.CheckBox1.Checked := Not form9.CheckBox2.Checked;
  form9.showmodal;
End;

Procedure TForm1.SaveAs1Click(Sender: TObject);
Begin
  If Length(AktualFilename) = 0 Then
    Savedialog1.FileName := getProjectname
  Else
    Savedialog1.FileName := AktualFilename;
  If Savedialog1.execute Then Begin
    If FileExists(savedialog1.FileName) Then Begin
      If ID_YES = Application.Messagebox('File already exists. Override it ?', 'Question', MB_YESNO + MB_ICONQUESTION) Then Begin
        Code.Lines.savetoFile(savedialog1.FileName);
        opendialog1.InitialDir := extractfilepath(savedialog1.FileName);
        savedialog1.InitialDir := extractfilepath(savedialog1.FileName);
        AktualFilename := savedialog1.FileName;
        Projektchanged := false;
        StatusBar1.Panels[1].Text := '';
        StatusBar1.Panels[2].Text := extractfilename(Savedialog1.filename);
      End;
    End
    Else Begin
      Code.Lines.savetoFile(savedialog1.FileName);
      opendialog1.InitialDir := extractfilepath(savedialog1.FileName);
      savedialog1.InitialDir := extractfilepath(savedialog1.FileName);
      AktualFilename := savedialog1.FileName;
      Projektchanged := false;
      StatusBar1.Panels[1].Text := '';
      StatusBar1.Panels[2].Text := extractfilename(Savedialog1.filename);
    End;
  End;
End;

Procedure TForm1.Find1Click(Sender: TObject);
Begin
  If Length(code.SelText) > 0 Then FindDialog1.FindText := code.SelText;
  FindDialog1.Execute;
  FindDialog1.Options := FindDialog1.Options - [frFindNext];
End;

Procedure TForm1.FindDialog1Find(Sender: TObject);
Var
  S: TSynSearchOptions;
  l: int64;
  aword: String;
Begin
  S := [];
  If Not (frDown In FindDialog1.Options) Then
    S := S + [ssoBackwards];
  If (frWholeWord In FindDialog1.Options) Then
    S := S + [ssoWholeWord];
  If (frMatchCase In FindDialog1.Options) Then
    S := S + [ssoMatchCase];

  l := Code.SearchReplace(FindDialog1.FindText, '', S);

  If l = 0 Then Begin
    If ssoBackwards In s Then
      aword := 'end'
    Else
      aword := 'beginning';

    If MessageDlg(Format('Text not found. Start from the %s?', [aword]), mterror, [mbyes, mbno], 0) = mrno Then
      FindDialog1.CloseDialog
    Else Begin
      code.CaretX := 1;
      If ssoBackwards In s Then
        code.CaretY := code.Lines.Count
      Else
        code.CaretY := 1;
      FindDialog1Find(Sender);
    End;
  End;
End;

Procedure TForm1.hidemenue1Click(Sender: TObject);
Begin
  splitter3.visible := false;
  Controlled_Varables.visible := false;
End;

Procedure TForm1.close2Click(Sender: TObject);
Begin
  splitter2.visible := false;
  Warnings_Error.visible := false;
End;

Procedure TForm1.CodeStatusChange(Sender: TObject; Changes: TSynStatusChanges);
Begin
  StatusBar1.Panels[0].text := ' ' + inttostr(code.carety) + ': ' + inttostr(code.caretx);
  StatusBar1.Panels[0].Width := StatusBar1.Canvas.TextWidth(StatusBar1.Panels[0].text) + 20;
End;

Procedure TForm1.Copy1Click(Sender: TObject);
Begin
  Code.CopyToClipboard;
End;

Procedure TForm1.Selectall1Click(Sender: TObject);
Begin
  Code.SelectAll;
End;

Procedure TForm1.Step1Click(Sender: TObject);
Begin
  // Schrittweises Debuggen
  If AktualDebugLine <> -1 Then
    execute(True, False);
End;

Procedure TForm1.ToggleBrakePoint1Click(Sender: TObject);
Begin
  // Setzen von Brakepoints
  ToggleBrakepoint(Code.CaretY);
End;

Procedure TForm1.CommentSelectedBlock1Click(Sender: TObject);
Var
  sa, se, x: Integer;
  s: String;
Begin
  sa := IndextoLine(Code.Lines, code.selstart);
  se := IndextoLine(Code.Lines, code.selEnd);
  If Se <> sa Then dec(se);
  For x := sa To se Do Begin
    s := DelFrontspace(code.lines[x]);
    If Length(s) <> 0 Then Begin
      If s[1] <> '/' Then Code.lines[x] := '//' + Code.lines[x];
    End;
  End;
End;

Procedure TForm1.UncommentSelectedBlock1Click(Sender: TObject);
Var
  sa, se, x: Integer;
  s: String;
Begin
  sa := IndextoLine(Code.Lines, code.selstart);
  se := IndextoLine(Code.Lines, code.selEnd);
  If Se <> sa Then dec(se);
  For x := sa To se Do Begin
    s := DelFrontspace(code.lines[x]);
    If Length(s) > 1 Then Begin
      If (s[1] = '/') And (s[2] = '/') Then Begin
        s := code.lines[x];
        delete(s, pos('//', s), 2);
        code.Lines[x] := s;
      End;
    End;
  End;
End;

Procedure TForm1.Print1Click(Sender: TObject);
Begin
  printer.PrinterIndex := -1;
  form11.ComboBox1.Items := printer.Printers;
  form11.CheckBox1.checked := code.SelStart <> code.selend;
  If form11.Combobox1.items.count <> 0 Then Begin
    form11.ComboBox1.Text := form11.ComboBox1.items[printer.PrinterIndex];
    If Not Assigned(Printfont) Then Begin
      Printfont := Tfont.create;
    End;
    Printfont.Name := code.Font.name;
    Printfont.Size := code.font.size;
    Printfont.Style := code.Font.style;
    form11.edit1.text := inttostr(Printfont.Size);
    form11.edit2.text := Printfont.Name;
    form11.edit3.text := FontstyletoString(Printfont.Style);
    form11.showmodal;
  End
  Else
    showmessage('No Printer found.');
End;

Procedure TForm1.CheckShowHideWarnings;
Begin
  // Falls es Warnunen, Fehler Gibt werden diese Hier Angezeigt
  Warnings_Error.visible := Warnings_Error.Items.count <> 0;
  splitter2.visible := Warnings_Error.visible;
End;

(*
 * Inaktive Methoden, welche auf andere Weißen noch implementiert werden müssen !
 *)

Procedure TForm1.CodeGutterPaint(Sender: TObject; aLine, X, Y: integer);
Begin
  // TODO: Das hier muss gemäß  https://forum.lazarus.freepascal.org/index.php?topic=13105.0
  //       Umgeschrieben werden in TSynEditMarks
  // Der Anfang ist in ToggleBrakepoint() gemacht und die Breakpoints
  // sind da nun "Sichtbar", das umschalten auf Index3 anhand der IsCompilableLine fehlt aber noch..
  // Zeichnet zu den Haltepunkt Linien den Roten Punkt Links
  If isBrakepoint(aline) Then Begin
    If High(CompilableLines) <> -1 Then Begin
      If IsCompilableLine(Aline) Then
        DebugMarks.draw(code.Canvas, x + 4, y, 0)
      Else
        DebugMarks.draw(code.Canvas, x + 4, y, 3)
    End
    Else
      DebugMarks.draw(code.Canvas, x + 4, y, 0);
  End;
  // Anzeigen aller Zeilen die der Rechner als Kompilierbar ansieht
  If IsCompilableLine(Aline) Then Begin
    DebugMarks.draw(code.Canvas, x + 4, y, 1);
  End;
  // Im Debugg Modus die Aktuelle Zeile Anzeigen
  If ALine = AktualDebugLine Then Begin
    DebugMarks.draw(code.Canvas, x + 4 + 14, y, 2);
  End;
End;

End.

