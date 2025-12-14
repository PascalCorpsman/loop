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
Unit unit10;

{$MODE objfpc}{$H+}

Interface

Uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, SynEdit,
  SynEditHighlighter, SynHighlighterAny, ImgList;

Type

  { TForm10 }

  TForm10 = Class(TForm)
    //    ColorGrid1: TColorGrid;
    Button1: TButton;
    ListBox1: TListBox;
    Label1: TLabel;
    GroupBox1: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    SynAnySyn1: TSynAnySyn;
    //    SynGeneralSyn1: TSynGeneralSyn;
    Synedit1: TSynEdit;
    DebugMarks: TImageList;
    BookMarks: TImageList;
    Procedure Button1Click(Sender: TObject);
    Procedure ListBox1Click(Sender: TObject);
    Procedure ListBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    Procedure ColorGrid1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    Procedure FormPaint(Sender: TObject);
    Procedure CheckBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    Procedure Synedit1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    Procedure Synedit1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    Procedure Synedit1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  End;

Var
  Form10: TForm10;

Procedure loadchme;
Procedure loadall;

Implementation

Uses Unit1;

{$R *.lfm}
{
object ColorGrid1: TColorGrid
 Left = 144
 Top = 32
 Width = 96
 Height = 96
 BackgroundIndex = 1
 TabOrder = 0
 OnMouseUp = ColorGrid1MouseUp
end

object SynGeneralSyn1: TSynGeneralSyn
  Comments = [csAnsiStyle, csPasStyle, csCPPStyle]
  DetectPreprocessor = False
  IdentifierChars =
  Left = 16
  Top = 144
end
}

Procedure loadall;
Var
  x: integer;
  s: TFontStyles;
Begin
  With form10 Do Begin
    For x := 0 To high(usercheme) Do Begin
      s := [];
      If usercheme[x].Bold Then include(s, fsbold);
      If usercheme[x].Italic Then include(s, fsitalic);
      If usercheme[x].Underline Then include(s, fsunderline);
      Case x Of
        0: Begin
            Synedit1.Color := usercheme[x].HG;
            //            SynGeneralSyn1.SpaceAttri.Style := s;
          End;
        1: Begin
            //            SynGeneralSyn1.CommentAttri.Background := usercheme[x].HG;
            //            SynGeneralSyn1.CommentAttri.Foreground := usercheme[x].VG;
            //            SynGeneralSyn1.CommentAttri.Style := s;
          End;
        2: Begin
            //            SynGeneralSyn1.KeyAttri.Background := usercheme[x].HG;
            //            SynGeneralSyn1.KeyAttri.Foreground := usercheme[x].VG;
            //            SynGeneralSyn1.KeyAttri.Style := s;
          End;
        3: Begin
            //            SynGeneralSyn1.IdentifierAttri.Background := usercheme[x].HG;
            //            SynGeneralSyn1.IdentifierAttri.Foreground := usercheme[x].VG;
            //            SynGeneralSyn1.IdentifierAttri.Style := s;
            //            SynGeneralSyn1.StringAttri.Background := usercheme[x].HG;
            //            SynGeneralSyn1.StringAttri.Foreground := usercheme[x].VG;
            //            SynGeneralSyn1.StringAttri.Style := s;
            //            SynGeneralSyn1.PreprocessorAttri.Background := usercheme[x].HG;
            //            SynGeneralSyn1.PreprocessorAttri.Foreground := usercheme[x].VG;
            //            SynGeneralSyn1.PreprocessorAttri.Style := s;
          End;
        4: Begin
            //            SynGeneralSyn1.SymbolAttri.Background := usercheme[x].HG;
            //            SynGeneralSyn1.SymbolAttri.Foreground := usercheme[x].VG;
            //            SynGeneralSyn1.SymbolAttri.Style := s;
          End;
        5: Begin
            //            SynGeneralSyn1.NumberAttri.Background := usercheme[x].HG;
            //            SynGeneralSyn1.NumberAttri.Foreground := usercheme[x].VG;
            //            SynGeneralSyn1.NumberAttri.Style := s;
          End;
        6: Begin
            synedit1.SelectedColor.Background := usercheme[x].HG;
            synedit1.SelectedColor.Foreground := usercheme[x].VG;
          End;
        7: Begin
            synedit1.RightEdgeColor := usercheme[x].vg;
          End;
      End;
    End;
  End;
End;

Procedure loadchme;
Begin
  With form10 Do Begin
    checkbox1.Checked := Usercheme[listbox1.ItemIndex].Bold;
    checkbox2.Checked := Usercheme[listbox1.ItemIndex].Italic;
    checkbox3.Checked := Usercheme[listbox1.ItemIndex].Underline;
    //    ColorGrid1.ForegroundIndex := ColorGrid1.ColorToIndex(Usercheme[listbox1.ItemIndex].VG);
    //    ColorGrid1.backgroundindex := ColorGrid1.ColorToIndex(Usercheme[listbox1.ItemIndex].HG);
  End;
End;

Procedure TForm10.Button1Click(Sender: TObject);
Begin
  close;
End;

Procedure TForm10.ListBox1Click(Sender: TObject);
Begin
  loadchme;
End;

Procedure TForm10.ListBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
Begin
  listbox1.ItemIndex := listbox1.ItemAtPos(point(x, y), true);
End;

Procedure TForm10.ColorGrid1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
Var
  s: TFontStyles;
Begin
  s := [];
  If checkbox1.checked Then include(s, fsbold);
  If checkbox2.checked Then include(s, fsitalic);
  If checkbox3.checked Then include(s, fsunderline);
  usercheme[listbox1.itemindex].Bold := checkbox1.checked;
  usercheme[listbox1.itemindex].Italic := checkbox2.checked;
  usercheme[listbox1.itemindex].Underline := checkbox3.checked;
  //  usercheme[listbox1.itemindex].HG := ColorGrid1.BackgroundColor;
  //  usercheme[listbox1.itemindex].VG := ColorGrid1.ForegroundColor;
  Case listbox1.itemindex Of
    0: Begin // Whitespace
        //        Synedit1.Color := ColorGrid1.BackgroundColor;
        //        SynGeneralSyn1.WhitespaceAttribute.Style := s;
      End;
    1: Begin
        //        SynGeneralSyn1.CommentAttri.Background := ColorGrid1.BackgroundColor;
        //        SynGeneralSyn1.CommentAttri.Foreground := ColorGrid1.ForegroundColor;
        //        SynGeneralSyn1.CommentAttri.Style := s;
      End;
    2: Begin
        //        SynGeneralSyn1.KeyAttri.Background := ColorGrid1.BackgroundColor;
        //        SynGeneralSyn1.KeyAttri.Foreground := ColorGrid1.ForegroundColor;
        //        SynGeneralSyn1.KeyAttri.Style := s;
      End;
    3: Begin
        //        SynGeneralSyn1.IdentifierAttri.Background := ColorGrid1.BackgroundColor;
        //        SynGeneralSyn1.IdentifierAttri.Foreground := ColorGrid1.ForegroundColor;
        //        SynGeneralSyn1.IdentifierAttri.Style := s;
        //        SynGeneralSyn1.StringAttri.Background := ColorGrid1.BackgroundColor;
        //        SynGeneralSyn1.StringAttri.Foreground := ColorGrid1.ForegroundColor;
        //        SynGeneralSyn1.StringAttri.Style := s;
        //        SynGeneralSyn1.PreprocessorAttri.Background := ColorGrid1.BackgroundColor;
        //        SynGeneralSyn1.PreprocessorAttri.Foreground := ColorGrid1.ForegroundColor;
        //        SynGeneralSyn1.PreprocessorAttri.Style := s;
      End;
    4: Begin
        //        SynGeneralSyn1.SymbolAttri.Background := ColorGrid1.BackgroundColor;
        //        SynGeneralSyn1.SymbolAttri.Foreground := ColorGrid1.ForegroundColor;
        //        SynGeneralSyn1.SymbolAttri.Style := s;
      End;
    5: Begin
        //        SynGeneralSyn1.NumberAttri.Background := ColorGrid1.BackgroundColor;
        //        SynGeneralSyn1.NumberAttri.Foreground := ColorGrid1.ForegroundColor;
        //        SynGeneralSyn1.NumberAttri.Style := s;
      End;
    6: Begin
        //        synedit1.SelectedColor.Background := ColorGrid1.BackgroundColor;
        //        synedit1.SelectedColor.Foreground := ColorGrid1.ForegroundColor;
      End;
    7: Begin
        //        Synedit1.RightEdgeColor := ColorGrid1.ForegroundColor;
      End;
  End;
End;

Procedure TForm10.FormPaint(Sender: TObject);
Begin
  // Anzeigen des Selectierten Textes
  synedit1.SelStart := 185;
  synedit1.SelEnd := 204;
End;

Procedure TForm10.CheckBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
Begin
  ColorGrid1MouseUp(Nil, mbleft, [], 0, 0);
End;

Procedure TForm10.Synedit1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
Begin
  synedit1.SelStart := 185;
  synedit1.SelEnd := 204;
End;

Procedure TForm10.Synedit1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
Begin
  synedit1.SelStart := 185;
  synedit1.SelEnd := 204;
End;

Procedure TForm10.Synedit1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Begin
  If ssleft In shift Then Begin
    synedit1.SelStart := 185;
    synedit1.SelEnd := 204;
  End;
End;

End.

