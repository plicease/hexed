(*============================================================================
-----BEGIN PGP SIGNED MESSAGE-----

This code (c) 1994, 1997 Graham THE Ollis

GENERAL NOTES
=============

This is 16bit DOS TURBO PASCAL source code.  It has been tested using
TURBO PASCAL 7.0.  You will need AT LEAST version 5.0 to compile this
source code.  You may need 7.0.

This is a generic pascal header for all my old pascal programs.  Most of
these programs were written before I really got excited enough about 32bit
operating systems.  In general this code dates back to 1994.  Some of it
is important enough that I still work on it.  For the most part though,
it's not the best code and it's probably the worst example of
documentation in all of computer science.  oh well, you've been warned. 

PGP NOTES
=========

This PGP signed message is provided in the hopes that it will prove useful
and informative.  My name is Graham THE Ollis <ollisg@ns.arizona.edu> and my
public PGP key can be found by fingering my university account:

finger ollisg@u.arizona.edu

LEGAL NOTES
===========

You are free to use, modify and distribute this source code provided these
headers remain in tact.  If you do make modifications to these programs,
i'd appreciate it if you documented your changes and leave some contact
information so that others can blame you and me, rather than just me.

If you maintain a anonymous ftp site or bbs feel free to archive this
stuff away.  If your pressing CDs for commercial purposes again have fun. 
It would be nice if you let me know about it though. 

HOWEVER- there is no written or implied warranty.  If you don't trust this
code then delete it NOW.  I will in no way be held responsible for any
losses incurred by your using this software. 

CONTACT INFORMATION
===================

You may contact me for just about anything relating to this code through
e-mail.  Please put something in the subject line about the program you
are working with.  The source file would be best in this case (e.g.
frag.pas, hexed.pas ... etc) 

ollisg@ns.arizona.edu
ollisg@idea-bank.com
ollisg@lanl.gov

The first address is the most likely to work.

all right.  that all said... HAVE FUN!

-----BEGIN PGP SIGNATURE-----
Version: 2.6.2

iQCVAwUBMv1UFoazF2irQff1AQFYNgQAhjiY/Dh3gSpk921FQznz4FOwqJtAIG6N
QTBdR/yQWrkwHGfPTw9v8LQHbjzl0jjYUDKR9t5KB7vzFjy9q3Y5lVHJaaUAU4Jh
e1abPhL70D/vfQU3Z0R+02zqhjfsfKkeowJvKNdlqEe1/kSCxme9mhJyaJ0CDdIA
40nefR18NrA=
=IQEZ
-----END PGP SIGNATURE-----
==============================================================================
| color.pas
|   this is the color module and allows the user to change the colors hexed
|   uses.  joy.
|
| History:
| Date       Author     Comment
| ----       ------     -------
| -- --- 94  G. Ollis	 created and developed program
============================================================================*)

{$I-}

Unit Color;

INTERFACE

Procedure ConfigureColor;

IMPLEMENTATION

Uses
  Header,CFG,ViewU,CRT,Cursor,KeyIn,View2;

Const
  MaxY=11;
  MaxX=20;

Type
  Mini_Screen=Array [1..MaxY,1..MaxX] Of
    Record
      Color:Byte;
      Text:Char;
    End;

Const
  DefaultColors:ConfigerationType=(Highlight:Blue * $10 or White;
                          Lolight:Blue * $10 or Cyan;
                          Numbers:Blue * $10 or Yellow;
                          InputColor:LightGray * $10 or Yellow;
                          HelpWindow:Blue * $10 or Yellow;
                          HelpColor:Blue * $10 or White;
                          StatusVer:Red * $10 or Yellow;
                          StatusFN:Red * $10 or White;
                          StatusSave:Red * $10 or Cyan;
                          StatusMid:Blue * $10 or Magenta;
                          Error:Red * $10 or Yellow;
                          MsgColor:Cyan * $10 or White;
                          MsgLoLight:Cyan * $10 or DarkGray;
                          MsgChoice:Red * $10 or Cyan;
                          BOF_Color:Blue * $10 or Brown;
                          EOF_Color:Blue * $10 or LightRed;
                          Block_Color:Cyan;
                          MenuLoLight:LightGray * $10;
                          MenuHiLight:LightGray * $10 or Red;
                          MenuDisab:LightGray * $10 or DarkGray);
  NightColors:ConfigerationType=(Highlight:White;
                          Lolight:LightGray;
                          Numbers:Yellow;
                          InputColor:LightGray * $10 or Yellow;
                          HelpWindow:DarkGray;
                          HelpColor:LightGray;
                          StatusVer:Cyan * $10 or Yellow;
                          StatusFN:Cyan * $10 or White;
                          StatusSave:Cyan * $10;
                          StatusMid:Brown * $10;
                          Error:Red * $10 or Yellow;
                          MsgColor:Brown * $10 or Yellow;
                          MsgLoLight:Brown * $10 or White;
                          MsgChoice:Red * $10 or Yellow;
                          BOF_Color:Brown;
                          EOF_Color:LightRed;
                          Block_Color:LightGray * $10;
                          MenuLoLight:LightGray;
                          MenuHiLight:LightRed;
                          MenuDisab:DarkGray);
  MonochromeColors:ConfigerationType=(Highlight:White;
                          Lolight:LightGray;
                          Numbers:LightGray;
                          InputColor:LightGray * $10;
                          HelpWindow:White;
                          HelpColor:LightGray;
                          StatusVer:LightGray * $10;
                          StatusFN:LightGray * $10;
                          StatusSave:LightGray * $10;
                          StatusMid:LightGray;
                          Error:LightGray * $10;
                          MsgColor:White;
                          MsgLoLight:LightGray;
                          MsgChoice:LightGray * $10;
                          BOF_Color:White;
                          EOF_Color:White;
                          Block_Color:LightGray * $10;
                          MenuLoLight:LightGray;
                          MenuHiLight:White;
                          MenuDisab:DarkGray);
  TraditionalColors:ConfigerationType=(Highlight:Brown * $10 or White;
                          Lolight:Brown * $10 or Yellow;
                          Numbers:Cyan * $10 or White;
                          InputColor:LightGray * $10 or Yellow;
                          HelpWindow:Blue * $10 or Yellow;
                          HelpColor:Blue * $10 or White;
                          StatusVer:Red * $10 or Yellow;
                          StatusFN:Red * $10 or White;
                          StatusSave:Red * $10 or Cyan;
                          StatusMid:Cyan * $10 or White;
                          Error:Red * $10 or LightRed;
                          MsgColor:Green * $10 or White;
                          MsgLolight:Green * $10 or Yellow;
                          MsgChoice:Red * $10 or Green;
                          BOF_Color:Cyan * $10 or Brown;
                          EOF_Color:Cyan * $10 or LightRed;
                          Block_Color:LightGray * $10 or Blue;
                          MenuLoLight:LightGray * $10;
                          MenuHiLight:LightGray * $10 or Red;
                          MenuDisab:LightGray * $10 or DarkGray);
  StringSize=20;
  NumChoice1=6;
  Choice1:Array[1..NumChoice1] Of String[StringSize]=('Default Colors','Night Colors','Traditonal Colors','Monochrome',
                                                      'Customize','Exit');
  StringSize2=30;
  NumChoice2=21;
  Choice2:Array[1..NumChoice2] Of String[StringSize2]=('Highlight','Lolight','Numbers','Input','Help Window','Help',
                                                      'Status Bar - Version number','Status Bar - File name',
                                                      'Status Bar - Save Stat',
                                                      'Status Bar - Middle','Error','Window','Window - Lolight',
                                                      'Window - Multiple Choice',
                                                      'Number - BOF','Number - EOF','Number - Marked',
                                                      'Menu - Lolight','Menu - Highlight','Menu - Disabled',
                                                      'Exit');
  ColorConfigFileName='COLOR.CFG';
  Stuff:Mini_Screen=(((Color:2; Text:' '),(Color:15; Text:'2'),(Color:15; Text:'5'),
                      (Color:15;Text:'5'),(Color:17; Text:'2'),(Color:17; Text:'5'),
                      (Color:17;Text:'5'),(Color:1;  Text:'2'),(Color:1;  Text:'5'),
                      (Color:1; Text:'5'),(Color:17; Text:'2'),(Color:17; Text:'5'),
                      (Color:17;Text:'5'),(Color:3;  Text:'2'),(Color:3;  Text:'5'),
                      (Color:3; Text:'5'),(Color:16; Text:'2'),(Color:16; Text:'5'),
                      (Color:16;Text:'5'),(Color:2;  Text:' ')),

                     ((Color:2; Text:' '),(Color:15; Text:'F'),(Color:15; Text:'F'),
                      (Color:15;Text:' '),(Color:17; Text:'F'),(Color:17; Text:'F'),
                      (Color:17;Text:' '),(Color:1;  Text:'F'),(Color:1;  Text:'F'),
                      (Color:1; Text:' '),(Color:17; Text:'F'),(Color:17; Text:'F'),
                      (Color:17;Text:' '),(Color:3;  Text:'F'),(Color:3;  Text:'F'),
                      (Color:3; Text:' '),(Color:16; Text:'F'),(Color:16; Text:'F'),
                      (Color:16;Text:' '),(Color:2;  Text:' ')),

                     ((Color:2; Text:' '),(Color:2;  Text:' '),(Color:2;  Text:' '),
                      (Color:2; Text:' '),(Color:2;  Text:' '),(Color:2;  Text:' '),
                      (Color:2; Text:' '),(Color:1;  Text:#$18),(Color:1;  Text:' '),
                      (Color:1; Text:' '),(Color:2;  Text:' '),(Color:2;  Text:' '),
                      (Color:2; Text:' '),(Color:2;  Text:' '),(Color:2;  Text:' '),
                      (Color:2; Text:' '),(Color:2;  Text:' '),(Color:2;  Text:' '),
                      (Color:2; Text:' '),(Color:2;  Text:' ')),

                     ((Color:10;Text:'X'),(Color:10; Text:':'),(Color:10; Text:' '),
                      (Color:10;Text:' '),(Color:10; Text:'3'),(Color:10; Text:' '),
                      (Color:10;Text:'E'),(Color:10; Text:'O'),(Color:10; Text:'F'),
                      (Color:10;Text:':'),(Color:10; Text:' '),(Color:10; Text:'6'),
                      (Color:10;Text:' '),(Color:10; Text:' '),(Color:10; Text:' '),
                      (Color:10;Text:' '),(Color:10; Text:' '),(Color:10; Text:' '),
                      (Color:10;Text:'H'),(Color:10; Text:' ')),

                     ((Color:2; Text:'I'),(Color:2;  Text:'n'),(Color:2;  Text:'t'),
                      (Color:2; Text:'e'),(Color:2;  Text:'g'),(Color:2;  Text:'e'),
                      (Color:2; Text:'r'),(Color:2;  Text:' '),(Color:3;  Text:' '),
                      (Color:3; Text:'-'),(Color:3;  Text:'1'),(Color:2;  Text:' '),
                      (Color:2; Text:' '),(Color:2;  Text:' '),(Color:2;  Text:' '),
                      (Color:2; Text:' '),(Color:2;  Text:' '),(Color:2;  Text:' '),
                      (Color:2; Text:' '),(Color:2;  Text:' ')),

                     ((Color:1; Text:'P'),(Color:1;  Text:'r'),(Color:1;  Text:'i'),
                      (Color:1; Text:'m'),(Color:1;  Text:'a'),(Color:1;  Text:'r'),
                      (Color:1; Text:'y'),(Color:1;  Text:' '),(Color:1;  Text:'V'),
                      (Color:1; Text:'i'),(Color:1;  Text:'e'),(Color:1;  Text:'w'),
                      (Color:1; Text:' '),(Color:1;  Text:'M'),(Color:1;  Text:'o'),
                      (Color:1; Text:'d'),(Color:1;  Text:'e'),(Color:1;  Text:' '),
                      (Color:1; Text:' '),(Color:1;  Text:' ')),

                     ((Color:19;Text:'F'),(Color:18; Text:'i'),(Color:18; Text:'l'),
                      (Color:18;Text:'e'),(Color:18; Text:' '),(Color:18; Text:' '),
                      (Color:19;Text:'M'),(Color:18; Text:'o'),(Color:18; Text:'d'),
                      (Color:18;Text:'i'),(Color:18; Text:'f'),(Color:18; Text:'y'),
                      (Color:18;Text:' '),(Color:20; Text:'S'),(Color:20; Text:'e'),
                      (Color:20;Text:'a'),(Color:20; Text:'r'),(Color:20; Text:'c'),
                      (Color:20;Text:'h'),(Color:18; Text:' ')),

                     ((Color:11;Text:#201),(Color:11;Text:#205),(Color:11;Text:#205),
                      (Color:11;Text:#205),(Color:11;Text:#187),(Color:5;Text:#218),
                      (Color:5;Text:#196),(Color:5;Text:#196),(Color:5;  Text:#196),
                      (Color:5;Text:#196),(Color:5;Text:#191),(Color:12;Text:#218),
                      (Color:12;Text:#196),(Color:12;Text:#196),(Color:12;Text:#196),
                      (Color:12;Text:#196),(Color:12;Text:#196),(Color:12;Text:#196),
                      (Color:12;Text:#196),(Color:12; Text:#191)),

                     ((Color:11;Text:#186),(Color:11;Text:'E'),(Color:11; Text:'r'),
                      (Color:11;Text:'r'),(Color:11; Text:#186),(Color:5; Text:#179),
                      (Color:6; Text:'H'),(Color:6;  Text:'e'),(Color:6;  Text:'l'),
                      (Color:6; Text:'p'),(Color:5;  Text:#179),(Color:12;Text:#179),
                      (Color:12;Text:'M'),(Color:13; Text:'e'),(Color:13; Text:'s'),
                      (Color:13;Text:'a'),(Color:13; Text:'g'),(Color:13; Text:'e'),
                      (Color:13;Text:' '),(Color:12; Text:#179)),

                     ((Color:11;Text:#200),(Color:11;Text:#205),(Color:11;Text:#205),
                      (Color:11;Text:#205),(Color:11;Text:#188),(Color:5;Text:#192),
                      (Color:5;Text:#196),(Color:5;Text:#196),(Color:5;  Text:#196),
                      (Color:5;Text:#196),(Color:5;Text:#217),(Color:12;Text:#192),
                      (Color:12;Text:#196),(Color:12;Text:#196),(Color:12;Text:#196),
                      (Color:12;Text:#196),(Color:12;Text:#196),(Color:12;Text:#196),
                      (Color:12;Text:#196),(Color:12; Text:#217)),

                     ((Color:7; Text:'V'),(Color:7;  Text:'e'),(Color:7;  Text:'r'),
                      (Color:7; Text:' '),(Color:8;  Text:'"'),(Color:8;  Text:'F'),
                      (Color:8; Text:'i'),(Color:8;  Text:'l'),(Color:8;  Text:'e'),
                      (Color:8; Text:'n'),(Color:8;  Text:'a'),(Color:8;  Text:'m'),
                      (Color:8; Text:'e'),(Color:8;  Text:'"'),(Color:8;  Text:' '),
                      (Color:9; Text:'('),(Color:9;  Text:'*'),(Color:9;  Text:')'),
                      (Color:7; Text:' '),(Color:7;  Text:'N'))

                      );

{---------------------------------------------------------------------------}

Procedure Write_Mini_Screen(X,Y:Integer; M:Mini_Screen; C:ConfigerationType);
Var
  X_C,Y_C:Integer;
Begin
  Window(X-1,Y-1,X+MaxX,Y+MaxY+1);
  TextAttr:=LightGray;
  Write(#201);
  For X_C:=1 To MaxX Do
    Write(#205);
  Write(#187);
  For X_C:=1 To MaxY Do
    Begin
      Write(#186);
      GotoXY(MaxX+2,WhereY);
      Write(#186);
    End;
  Write(#200);
  For X_C:=1 To MaxX Do
    Write(#205);
  Write(#188);

  Window(X,Y,X+MaxX-1,Y+MaxY+1);
  For Y_C:=1 To MaxY Do
    For X_C:=1 To MaxX Do
      Begin
        TextAttr:=C.ByteArr[M[Y_C,X_C].Color];
        Write(M[Y_C,X_C].Text);
      End;
  Window(1,1,80,25);
End;

{---------------------------------------------------------------------------}

Procedure UpDate;
Begin
  Write_Mini_Screen(40,3,Stuff,ICFG);
  GotoXY(63,3);
  TextAttr:=ICFG.InputColor;
  Writeln('INPUT          ');
  GotoXY(63,4);
  TextAttr:=ICFG.MsgChoice;
  Writeln('Multiple Choice');
End;

{---------------------------------------------------------------------------}

Procedure WriteChoice1(I:Integer);
Var
  N:Integer;
Begin
  Window(5,3,5+StringSize,4+NumChoice1);
  For N:=1 To NumChoice1 Do
    Begin
      TextAttr:=LightGray;
      If N=I Then
        TextAttr:=LightGray * $10;
      Write(Choice1[N]);
      ClrEol;
      Writeln;
    End;
  Window(1,1,80,25);
  GotoXY(1,25);
  TextAttr:=LightGray * $10;
  Case I Of
    1 : Write('The original colors for HEXED.  Why mess with a good thing?');
    2 : Write('I am the night.  Stealthy, Hidden, Secret, Evil.');
    3 : Write('The traditional colors for the secondary view mode.');
    4 : Write('Mono-creative.  Boring.');
    5 : Write('Simple and easy to use.  Make your own color scheme.');
    6 : Write('Return to where the action is: HEXED!');
  End;
  ClrEOL;
End;

{---------------------------------------------------------------------------}

Procedure WriteChoice2(I:Integer);
Var
  N:Integer;
Begin
  Window(5,3,5+StringSize2,4+NumChoice2);
  For N:=1 To NumChoice2 Do
    Begin
      TextAttr:=LightGray;
      If N=I Then
        TextAttr:=LightGray * $10;
      Write(Choice2[N]);
      ClrEol;
      Writeln;
    End;
  Window(1,1,80,25);
  GotoXY(1,25);
  TextAttr:=LightGray * $10;
  Case I Of
    1 : Write('All text that should stick out.  Usually indicates a key or current location.');
    2 : Write('Other text that isn''t a number and shouldn''t stick out.');
    3 : Write('All numbers (HEX, DEC, CHAR, etc.) except the BOF, EOF, Current and marked.');
    4 : Write('When you are prompted to input a string or number, what color?');
    5 : Write('The outside graphic for the help window.');
    6 : Write('The help text.');
    7 : Write('The version number displayed on the lower left hand corner of the screen.');
    8 : Write('The current file name displayed on the lower central part of the screen.');
    9 : Write('The save status indicator ( (*)/(  ) ) lower right hand corner of the screen.');
    10: Write('The status bar just below the primary file.');
    11: Write('All error messages and windows will be printed in this color.');
    12: Write('Most windows will use this color.');
    13: Write('When there are option windows, this color helps indicate the keys to press.');
    14: Write('For scroller option windows (F2) displays the current option.');
    15: Write('For the byte at the Beginning Of the File (BOF).');
    16: Write('For the byte at the End Of the File (EOF).');
    17: Write('For text that has been marked (^K).');
    18: Write('The color used for the menu right above the help window');
    19: Write('The key you are supose to press in the menus');
    20: Write('The color of menu items not currently available');
    21: Write('Return to internal color schemes.');
  End;
  ClrEOL;
End;

{---------------------------------------------------------------------------}

Procedure SaveColor;
Var
  F:FILE of ConfigerationType;
Begin
  Assign(F,HelpDir+ColorConfigFileName);
  Rewrite(F);
  If IOResult <> 0 Then
    Exit;

  Write(F,ICFG);

  Close(F);
End;

{---------------------------------------------------------------------------}

Procedure EraseColor;
Var
  F:FILE;
Begin
  Assign(F,HelpDir+ColorConfigFileName);
  Erase(F);
  If IOResult <> 0 Then
    ;
End;

{---------------------------------------------------------------------------}

Procedure DispCurrColor(B:Byte; Curr:Boolean);
Var
  I:Integer;
Begin
  Window(40,15,40+16,15+4);

  TextAttr:=Yellow;

  GotoXY(1,1);
  ClrEOL;
  GotoXY((B And $F)+1,1);
  If Curr Then
    Write('*')
  Else
    Write('+');

  GotoXY(1,3);
  ClrEOL;
  GotoXY(((B And $F0) shr 4)+1,3);
  If Curr Then
    Write('+')
  Else
    Write('*');

  Window(1,1,80,25);
End;

{---------------------------------------------------------------------------}

Procedure DecColor(Var B:Byte);
Begin
  B:=(B And $F0) Or (((B And $0F)-1) And $0F);
  UpDate;
End;

{---------------------------------------------------------------------------}

Procedure IncColor(Var B:Byte);
Begin
  B:=(B And $F0) Or (((B And $0F)+1) And $0F);
  UpDate;
End;

{---------------------------------------------------------------------------}

Procedure DecBk(Var B:Byte);
Begin
  B:=(B And $0F) Or (((B And $F0)-$10) And $F0);
  UpDate;
End;

{---------------------------------------------------------------------------}

Procedure IncBk(Var B:Byte);
Begin
  B:=(B And $0F) Or (((B And $F0)+$10) And $F0);
  UpDate;
End;

{---------------------------------------------------------------------------}

Procedure Customize;
Var
  N:Integer;
  C:Char;
  B:Boolean;
Begin

  GotoXY(1,24);
  TextAttr:=White;
  Write('Left');
  TextAttr:=LightGray;
  Write(' and ');
  TextAttr:=White;
  Write('Right');
  TextAttr:=LightGray;
  Write(' to modify color, ');
  TextAttr:=White;
  Write('<TAB>');
  TextAttr:=LightGray;
  Write(' to toggle forground and background.');
  ClrEOL;

  Window(40,15,40+16,15+4);
  GotoXY(1,2);
  For N:=0 To 15 Do
    Begin
      TextAttr:=N;
      Write(#219);
    End;
  GotoXY(1,4);
  For N:=0 To 15 Do
    Begin
      TextAttr:=N * $10;
      Write(' ');
    End;
  Window(1,1,80,25);

  N:=1;
  Repeat
    WriteChoice2(N);
    DispCurrColor(ICFG.ByteArr[N],B);
    C:=Readkey;

    If C=#9 Then
      B:=Not B;

    If C=#0 Then
      Case Readkey Of
        #72 : Dec(N);
        #80 : Inc(N);
        #75 :
          If B Then
            DecColor(ICFG.ByteArr[N])
          Else
            DecBk(ICFG.ByteArr[N]);
        #77 :
          If B Then
            IncColor(ICFG.ByteArr[N])
          Else
            IncBk(ICFG.ByteArr[N]);
      End;

    If N<1 Then
      N:=NumChoice2;
    If N>NumChoice2 Then
      N:=1;

  Until (C=#27) Or ((C=#13) And (N=NumChoice2));

  Window(5,3,5+StringSize2,4+NumChoice2);
  TextAttr:=LightGray;
  ClrScr;
  Window(40,15,40+16,15+4);
  ClrScr;
  Window(1,1,80,25);
End;

{---------------------------------------------------------------------------}

Procedure Printhelp;
Begin
  GotoXY(1,24);
  TextAttr:=White;
  Write('Up');
  TextAttr:=LightGray;
  Write(' and ');
  TextAttr:=White;
  Write('Down');
  TextAttr:=LightGray;
  Write(' to move up and down, ');
  TextAttr:=White;
  Write('<ENTER>');
  TextAttr:=LightGray;
  Write(' to choose or ');
  TextAttr:=White;
  Write('<ESC>');
  TextAttr:=LightGray;
  Write(' to return.');
  ClrEOL;
End;

{---------------------------------------------------------------------------}

Procedure ConfigureColor;
Var
  N:Integer;
  C:Char;
Begin
  HideCursor;

  PrintHelp;

  Window(1,1,80,25);
  TextAttr:=LightGray;
  ClrScr;

  PrintHelp;

  UpDate;

  N:=1;
  Repeat
    WriteChoice1(N);
    C:=Readkey;

    If C=#0 Then
      Case Readkey Of
        #72 : Dec(N);
        #80 : Inc(N);
      End;

    If N<1 Then
      N:=NumChoice1;
    If N>NumChoice1 Then
      N:=1;

    If (C=#13) And (N<5) Then
      Begin
        Case N Of
          1 : ICFG:=DefaultColors;
          2 : ICFG:=NightColors;
          3 : ICFG:=TraditionalColors;
          4 : ICFG:=MonochromeColors;
        End;
        UpDate;
        If N<>1 Then
          SaveColor
        Else
          EraseColor;
      End;

    If (C=#13) And (N=5) Then
      Begin
        Customize;
        SaveColor;
        PrintHelp;
      End;

  Until (C=#27) Or ((C=#13) And (N=NumChoice1));

  If AltMode=Byte4Mode Then
    Repaint2
  Else If AltMode=StdMode Then
    Repaint;
  ShowCursor;
End;

{---------------------------------------------------------------------------}

Procedure LoadColor;
Var
  F:FILE of ConfigerationType;
Begin
  Assign(F,HelpDir+'/'+ColorConfigFileName);
  Reset(F);
  If IOResult <> 0 Then
    Begin
      ICFG:=DefaultColors;
      Exit;
    End;

  Read(F,ICFG);

  Close(F);
End;

{===========================================================================}

Begin
  LoadColor;
End.