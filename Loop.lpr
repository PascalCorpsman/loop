Program Loop;

//{$R 'Loopicon.res' 'Loopicon.rc'} // Für das Tolle Loop Icon

//{$R 'Icon.res' 'Icon.rc'} // Das Icon für die Anwendung

Uses
  Interfaces,
  Forms,
  dialogs,
  sysutils,
  Main,
  Color_Sheme,
  Extended_Options,
  Parser,
  Compiler,
  New_Projekt,
  Programm_Simulation,
  Code_Formater,
  Instructions,
  Executer,
  LoopStack,
  Controled_Vars,
  RechenBaum,
  Replacer,
  Extended_Color_Options,
  PrePrescanner,
  Printdialog;

//{$R *.res}

//Var
//  mhandle: Thandle;
  //  Sender: TInterAppSender;
  //  ActiveReceivers: THandleArray;
//  Icon: TIcon; // benötigt fürs laden des Icons
//  s: String;

Begin
  //  ActiveReceivers := Nil; // Beruhigt den Kompiler
    // Verhindern das das Programm 2 Mal gleichzeitig gestartet werden kann.
  //  mhandle := Createmutex(Nil, true, 'Loop');
  //  If getlasterror = Error_Already_Exists Then Begin
  //    s := Paramstr(1);
  //    If (s <> '/i') And (Length(s) <> 0) Then Begin
  //      Sender := TInterAppSender.Create(Nil);
  //      ActiveReceivers := Sender.Call(true);
  //      Sender.SendString(ActiveReceivers[0], PAramstr(1));
  //      halt;
  //    End;
  //    Messagebox(0, 'There can be only one loop instance at a time.', 'Error', MB_ICONWARNING Or MB_OK);
  //    halt;
  //  End;
  //  Icon := TIcon.Create; // benötigt fürs laden des Icons
  //  Try // benötigt fürs laden des Icons
  //    Icon.Handle := ExtractIcon(hinstance, pchar(paramstr(0)), 0); // benötigt fürs laden des Icons
  //    Application.Icon.Assign(Icon); // benötigt fürs laden des Icons
  //  Finally // benötigt fürs laden des Icons
  //    Icon.Free; // benötigt fürs laden des Icons
  //  End; // benötigt fürs laden des Icons
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TForm4, Form4);
  Application.CreateForm(TForm5, Form5);
  Application.CreateForm(TForm6, Form6);
  Application.CreateForm(TForm7, Form7);
  Application.CreateForm(TForm8, Form8);
  Application.CreateForm(TForm9, Form9);
  Application.CreateForm(TForm10, Form10);
  Application.CreateForm(TForm11, Form11);
  If Paramstr(1) = '/i' Then Begin
    Application.ShowMainForm := false;
  End;
  Application.Run;
End.

