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
| keyin.pas
|    parse user input.
|
| History:
| Date       Author     Comment
| ----       ------     -------
| -- --- 94  G. Ollis	 created and developed program
============================================================================*)

{$I-}

Unit KeyIn;

INTERFACE

Uses
  Header;

{++PROCEDURES++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Procedure Commands(Var D:DataType; Var Hp:HelpPointer);
Procedure DosShell(Var D:DataType);
Procedure HEXEDInfo;
Procedure DrawMenu;
Procedure Repaint;

{++FUNCTIONS+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

IMPLEMENTATION


Uses
  CRT,ViewU,Ollis,CFG,MouseIn,UModify,OutCRT,Block,FUTIL,CNT,PrintU,WTD,
  Second,BinEd,Search,DOS,VConvert,Help,View2,Cursor,VOCTool,CMFTool,
  Center,ChFile,LowInt,Color;


{------------------------------------------------------------------------}

Procedure HEXEDInfo;
Begin
  OpenWindow(10,5,70,15,ICFG.MsgColor);
  Writeln('                H E X E D  -  version ',VERSIONNUMBER);
  Writeln;
  Writeln('            Copyright (c) 1994 by Graham Ollis');
  Writeln;
  Writeln('Programed by Graham Ollis      Beta Testing David Wingate');
  Writeln;
  Writeln('compiler: Turbo Pascal 7.0 by BORLAND INTERNATIONAL, INC.');
  Writeln('sound formats: "The Developer Kit For Sound Blaster Series"');
  Writeln('   from CREATIVE LABS, INC.');
  Writeln('graphics formats: "Bit-Mapped Graphics 2nd Edition" by Steve');
  Write('   Rimmer');
  HideCursor;
  Pause;
  ShowCursor;
  CloseWindow;
End;

{------------------------------------------------------------------------}

Procedure DosShell(Var D:DataType);
Begin
  SaveTemp(D.D^,0);
  Dispose(D.D);
  If Secondary<>NIL Then
    Begin
      SaveTemp(Secondary^.D^,1);
      Dispose(Secondary^.D);
    End;
  SvTextScreen;
  TextAttr:=SaveTextAttr;
  ClrScr;
  Writeln('Type EXIT to return to HEXED...');
  SwapVectors;
  Exec(GetEnv('COMSPEC'), '');
  SwapVectors;
  SaveTextAttr:=TextAttr;
  RsTextScreen;
  If DOSERROR<>0 Then
      Case DOSERROR Of
        2 : ErrorMsg('Couldn''t find '+GetEnv('COMSPEC')+'.');
        3 : ErrorMsg('Couldn''t find '+GetEnv('COMSPEC')+' path.');
        5 : ErrorMsg('Access denied.');
        6 : ErrorMsg('Invalid handle.');
        8 : ErrorMsg('Not enough memory.');
        10: ErrorMsg('Invalid environment.');
        11: ErrorMsg('Invalid format.');
        18: ErrorMsg('No more files.');
      End;
  New(D.D);
  RestoreTemp(D.D^,0);
  If Secondary<>NIL Then
    Begin
      SaveTemp(Secondary^.D^,1);
      Dispose(Secondary^.D);
    End;
End;

{----------------------------------------------------------------------}

Procedure DrawMenu;
Begin
  Window(1,10,80,10);
  TextAttr:=ICFG.MenuLoLight;
  ClrScr;
  Window(1,10,80,11);
  TextAttr:=ICFG.MenuHilight;
  Write(' F');
  TextAttr:=ICFG.MenuLoLight;
  Write('ile  ');
  TextAttr:=ICFG.MenuHilight;
  Write('M');
  TextAttr:=ICFG.MenuLoLight;
  Write('odify  ');
  TextAttr:=ICFG.MenuHiLight;
  Write('S');
  TextAttr:=ICFG.MenuLoLight;
  Write('earch  S');
  TextAttr:=ICFG.MenuHiLight;
  Write('e');
  TextAttr:=ICFG.MenuLoLight;
  Write('condary  ');
  TextAttr:=ICFG.MenuHiLight;
  Write('Vi');
  TextAttr:=ICFG.MenuLoLight;
  Write('ew');
  GotoXY(70,1);
  TextAttr:=ICFG.MenuHiLight;
  Write('H');
  TextAttr:=ICFG.MenuLolight;
  Write('elp');
  Window(1,1,80,25);
End;

{----------------------------------------------------------------------}

Procedure Menu1;
Begin
  OpenWindow(2,12,13,17,ICFG.MenuLoLight);
  Window(2,12,13,18);
  TextAttr:=ICFG.MenuHilight;
  Write('L');
  TextAttr:=ICFG.MenuLoLight;
  Write('oad       '#$10);
  TextAttr:=ICFG.MenuHilight;
  Write('S');
  TextAttr:=ICFG.MenuLoLight;
  Write('ave      F5');
  TextAttr:=ICFG.MenuHilight;
  Write('U');
  TextAttr:=ICFG.MenuLoLight;
  Write('ndo      F7');
  TextAttr:=ICFG.MenuHilight;
  Write('R');
  TextAttr:=ICFG.MenuLoLight;
  Write('ename     RS');
  TextAttr:=ICFG.MenuHilight;
  Write('h');
  TextAttr:=ICFG.MenuLoLight;
  Write('ell    ^F2');
  TextAttr:=ICFG.MenuHilight;
  Write('Q');
  TextAttr:=ICFG.MenuLoLight;
  Write('uit       Q');
End;

{----------------------------------------------------------------------}

Procedure Menu2;
Begin
  OpenWindow(8,12,16,16,ICFG.MenuLoLight);
  Window(8,12,16,17);
  TextAttr:=ICFG.MenuHilight;
  Write('D');
  TextAttr:=ICFG.MenuLoLight;
  Write('ata    '#$10);
  TextAttr:=ICFG.MenuHilight;
  Write('E');
  TextAttr:=ICFG.MenuLoLight;
  Write('OF     '#$10);
  TextAttr:=ICFG.MenuHilight;
  Write('I');
  TextAttr:=ICFG.MenuLoLight;
  Write('nsert  I');
  TextAttr:=ICFG.MenuHilight;
  Write('D');
  TextAttr:=ICFG.MenuLoLight;
  Writeln('elete');
  TextAttr:=ICFG.MenuHilight;
  Write('M');
  TextAttr:=ICFG.MenuLoLight;
  Write('ode  ');

  Case DefVarEd Of
    DefHex : Write('HEX');
    DefDec : Write('DEC');
  End;
End;

{----------------------------------------------------------------------}

Procedure Menu3;
Begin
  OpenWindow(16,12,25,15,ICFG.MenuLoLight);
  Window(16,12,25,16);
  TextAttr:=ICFG.MenuHilight;
  Write('T');
  TextAttr:=ICFG.MenuLoLight;
  Write('ext     S');
  TextAttr:=ICFG.MenuHilight;
  Write('A');
  TextAttr:=ICFG.MenuLoLight;
  Write('gain   ^S');
  TextAttr:=ICFG.MenuHilight;
  Write('B');
  TextAttr:=ICFG.MenuLoLight;
  Write('inary   FA');
  TextAttr:=ICFG.MenuHilight;
  Write('g');
  TextAttr:=ICFG.MenuLoLight;
  Write('ain   ^F');
End;

{----------------------------------------------------------------------}

Procedure Menu4;
Begin
  OpenWindow(24,12,34,16,ICFG.MenuLoLight);
  Window(24,12,34,17);
  TextAttr:=ICFG.MenuHilight;
  Write('T');
  TextAttr:=ICFG.MenuLoLight;
  Write('oggle    A');
  TextAttr:=ICFG.MenuHilight;
  If Secondary=NIL Then
    TextAttr:=ICFG.MenuDisab;
  Write('P');
  If Secondary<>NIL Then
    TextAttr:=ICFG.MenuLoLight;
  Write('ause     P');
  If Secondary<>NIL Then
    TextAttr:=ICFG.MenuHilight;
  Write('D');
  If Secondary<>NIL Then
    TextAttr:=ICFG.MenuLoLight;
  Write('iference De');
  If Secondary<>NIL Then
    TextAttr:=ICFG.MenuHilight;
  Write('X');
  If Secondary<>NIL Then
    TextAttr:=ICFG.MenuLoLight;
  Write('tract   X');

  TextAttr:=ICFG.MenuHilight;
  If Secondary=NIL Then
    TextAttr:=ICFG.MenuDisab;
  Write('S');
  If Secondary<>NIL Then
    TextAttr:=ICFG.MenuLoLight;
  Write('wap  <ENT>');
End;

{----------------------------------------------------------------------}

Function IsDisab:Boolean;
Begin
  IsDisab:=(Data.BFT=1) Or (Data.BFT=9) Or (Data.BFT>10);
End;

{----------------------------------------------------------------------}

Procedure Menu5;
Begin
  OpenWindow(35,12,50,18,ICFG.MenuLoLight);
  Window(35,12,50,19);
  TextAttr:=ICFG.MenuHilight;
  Write('2');
  TextAttr:=ICFG.MenuLoLight;
  Write('nd           F6');
  TextAttr:=ICFG.MenuHilight;
  If Secondary<>NIL Then
    TextAttr:=ICFG.MenuDisab;
  Write('D');
  TextAttr:=ICFG.MenuLoLight;
  If Secondary<>NIL Then
    TextAttr:=ICFG.MenuDisab;
  Write('isplay        T');
  TextAttr:=ICFG.MenuHiLight;
  If Secondary<>NIL Then
    TextAttr:=ICFG.MenuDisab;
  Write('T');
  TextAttr:=ICFG.MenuLoLight;
  If Secondary<>NIL Then
    TextAttr:=ICFG.MenuDisab;
  Write('oggle         P');
  TextAttr:=ICFG.MenuHiLight;
  If IsDisab Then
    TextAttr:=ICFG.MenuDisab;
  Write('F');
  TextAttr:=ICFG.MenuLoLight;
  If IsDisab Then
    TextAttr:=ICFG.MenuDisab;
  Write('ormated view  V');
  TextAttr:=ICFG.MenuHiLight;
  If IsDisab Then
    TextAttr:=ICFG.MenuDisab;
  Write('A');
  TextAttr:=ICFG.MenuLoLight;
  If IsDisab Then
    TextAttr:=ICFG.MenuDisab;
  Write('gain         ^V');
  TextAttr:=ICFG.MenuLoLight;
  Write('T');
  TextAttr:=ICFG.MenuHiLight;
  Write('y');
  TextAttr:=ICFG.MenuLoLight;
  Write('pe           '#$10);
  TextAttr:=ICFG.MenuHiLight;
  Write('R');
  TextAttr:=ICFG.MenuLoLight;
  Write('epaint       ^L');
End;

{----------------------------------------------------------------------}

Procedure MenuH;
Begin
  OpenWindow(70,12,79,15,ICFG.MenuLoLight);
  Window(70,12,79,16);
  TextAttr:=ICFG.MenuHilight;
  Write('C');
  TextAttr:=ICFG.MenuLoLight;
  Write('olor   ^C');
  TextAttr:=ICFG.MenuHilight;
  Write('M');
  TextAttr:=ICFG.MenuLoLight;
  Write('emory   O');
  TextAttr:=ICFG.MenuHilight;
  Write('R');
  TextAttr:=ICFG.MenuLoLight;
  Write('eg?      ');
  TextAttr:=ICFG.MenuHilight;
  Write('A');
  TextAttr:=ICFG.MenuLoLight;
  Write('bout   F1');
End;

{----------------------------------------------------------------------}

Function GetLoad:Word;
Var
  Back:ScreenBufferType;
  Mode:Byte;
Begin
  Back:=Screen^;

  DrawWindow(15,12,25,13,ICFG.MenuLoLight);
  Window(15,12,25,14);
  TextAttr:=ICFG.MenuHilight;
  Write('P');
  TextAttr:=ICFG.MenuLoLight;
  Write('rimary   '#$10);
  TextAttr:=ICFG.MenuHilight;
  Write('S');
  TextAttr:=ICFG.MenuLoLight;
  Write('econdary '#$10);
  Mode:=0;
  Case UpCase(Readkey) Of
    'P' : Mode:=1;
    'S' : Mode:=2;
    #0 : Readkey;
  End;

  GetLoad:=$FFFF;

  If Mode<>0 Then
    Begin
      DrawWindow(27,11+Mode,38,12+Mode,ICFG.MenuLoLight);
      TextAttr:=ICFG.MenuHilight;
      Write('U');
      TextAttr:=ICFG.MenuLoLight;
      Writeln('ser input');
      TextAttr:=ICFG.MenuHilight;
      Write('F');
      TextAttr:=ICFG.MenuLoLight;
      Write  ('lin input');
      Case UpCase(Readkey) Of
        'U' : If Mode=1 Then
                GetLoad:=$0143
              Else
                GetLoad:=$0144;
        'F' : If Mode=1 Then
                GetLoad:=$0166
              Else
                GetLoad:=$0167;
        #0 : Readkey;
      End;
    End;

  Screen^:=Back;
End;

{----------------------------------------------------------------------}

Function GetData:Word;
Var
  Back:ScreenBufferType;
Begin
  Back:=Screen^;
  GetData:=$FFFF;

  DrawWindow(18,12,27,17,ICFG.MenuLoLight);
  Window(18,12,27,18);

  TextAttr:=ICFG.MenuHiLight;
  Write('B');
  TextAttr:=ICFG.MenuLoLight;
  Write('yte     H');
  TextAttr:=ICFG.MenuHiLight;
  Write('C');
  TextAttr:=ICFG.MenuLoLight;
  Write('har     G');
  TextAttr:=ICFG.MenuHiLight;
  Write('W');
  TextAttr:=ICFG.MenuLoLight;
  Write('ord     W');
  TextAttr:=ICFG.MenuHiLight;
  Write('L');
  TextAttr:=ICFG.MenuLoLight;
  Write('ong     LB');
  TextAttr:=ICFG.MenuHiLight;
  Write('i');
  TextAttr:=ICFG.MenuLoLight;
  Write('t      B');
  TextAttr:=ICFG.MenuHiLight;
  Write('S');
  TextAttr:=ICFG.MenuLoLight;
  Write('tring  F2');

  Case UpCase(Readkey) Of
    'B' : GetData:=$4800;
    'C' : GetData:=$4700;
    'W' : GetData:=$5700;
    'L' : GetData:=$4C00;
    'I' : GetData:=$4200;
    'S' : GetData:=$013C;
    #0  : Readkey;
  End;

  Screen^:=Back;
End;

{----------------------------------------------------------------------}

Function GetEOF:Word;
Var
  Back:ScreenBufferType;
Begin
  Back:=Screen^;
  GetEOF:=$FFFF;

  DrawWindow(18,13,25,15,ICFG.MenuLoLight);
  Window(18,13,25,16);

  TextAttr:=ICFG.MenuHiLight;
  Write('S');
  TextAttr:=ICFG.MenuLoLight;
  Write('et    =');
  TextAttr:=ICFG.MenuHiLight;
  Write('I');
  TextAttr:=ICFG.MenuLoLight;
  Write('nc    +');
  TextAttr:=ICFG.MenuHiLight;
  Write('D');
  TextAttr:=ICFG.MenuLoLight;
  Write('ec    -');

  Case UpCase(Readkey) Of
    'S' : GetEOF:=$3D00;
    'I' : GetEOF:=$2B00;
    'D' : GetEOF:=$2D00;
    #0  : Readkey;
  End;

  Screen^:=Back;
End;

{----------------------------------------------------------------------}

Procedure GetEXEType;
Var
  Back:ScreenBufferType;
Begin
  Back:=Screen^;

  DrawWindow(60,4,66,17,ICFG.MenuLoLight);
  Window(60,4,66,18);

  TextAttr:=ICFG.MenuHiLight;
  Write('o');
  TextAttr:=ICFG.MenuLoLight;
  Write('ld    ');
  TextAttr:=ICFG.MenuHiLight;
  Write('n');
  TextAttr:=ICFG.MenuLoLight;
  Write('ew    ');
  TextAttr:=ICFG.MenuHiLight;
  Write('b');
  TextAttr:=ICFG.MenuLoLight;
  Write('or    ');
  TextAttr:=ICFG.MenuHiLight;
  Write('a');
  TextAttr:=ICFG.MenuLoLight;
  Write('rj    ');
  TextAttr:=ICFG.MenuHiLight;
  Write('l');
  TextAttr:=ICFG.MenuLoLight;
  Write('z90   l');
  TextAttr:=ICFG.MenuHiLight;
  Write('z');
  TextAttr:=ICFG.MenuLoLight;
  Write('91   ');
  TextAttr:=ICFG.MenuHiLight;
  Write('p');
  TextAttr:=ICFG.MenuLoLight;
  Write('kl    lha');
  TextAttr:=ICFG.MenuHiLight;
  Write('r');
  TextAttr:=ICFG.MenuLoLight;
  Write('c  l');
  TextAttr:=ICFG.MenuHiLight;
  Write('h');
  TextAttr:=ICFG.MenuLoLight;
  Write('a    ');
  TextAttr:=ICFG.MenuHiLight;
  Write('t');
  TextAttr:=ICFG.MenuLoLight;
  Write('s     pka(');
  TextAttr:=ICFG.MenuHiLight;
  Write('1');
  TextAttr:=ICFG.MenuLoLight;
  Write(') b');
  TextAttr:=ICFG.MenuHiLight;
  Write('s');
  TextAttr:=ICFG.MenuLoLight;
  Write('a    lar');
  TextAttr:=ICFG.MenuHiLight;
  Write('c');
  TextAttr:=ICFG.MenuLoLight;
  Write('   lh(');
  TextAttr:=ICFG.MenuHilight;
  Write('2');
  TextAttr:=ICFG.MenuLoLight;
  Write(')');

  Case UpCase(Readkey) Of
    'O' : Data.ED.Tp:=0;
    'N' : Data.ED.Tp:=1;
    'B' : Data.ED.Tp:=2;
    'A' : Data.ED.Tp:=3;
    'L' : Data.ED.Tp:=4;
    'Z' : Data.ED.Tp:=5;
    'P' : Data.ED.Tp:=6;
    'R' : Data.ED.Tp:=7;
    'H' : Data.ED.Tp:=8;
    'T' : Data.ED.Tp:=9;
    '1' : Data.ED.Tp:=10;
    'S' : Data.ED.Tp:=11;
    'C' : Data.ED.Tp:=12;
    '2' : Data.ED.Tp:=13;
    #0  : Readkey;
  End;

  Screen^:=Back;
End;

{----------------------------------------------------------------------}

Function GetType:Word;
Var
  Back:ScreenBufferType;
Begin
  Back:=Screen^;
  GetType:=$0000;

  DrawWindow(52,4,58,17,ICFG.MenuLoLight);
  Window(52,4,58,18);

  TextAttr:=ICFG.MenuHiLight;
  Write('N');
  TextAttr:=ICFG.MenuLoLight;
  Write('one   ');
  TextAttr:=ICFG.MenuHiLight;
  Write('P');
  TextAttr:=ICFG.MenuLoLight;
  Write('CX    P');
  TextAttr:=ICFG.MenuHiLight;
  Write('A');
  TextAttr:=ICFG.MenuLoLight;
  Write('L/COL');
  TextAttr:=ICFG.MenuHiLight;
  Write('C');
  TextAttr:=ICFG.MenuLoLight;
  Write('MF    ');
  TextAttr:=ICFG.MenuHiLight;
  Write('S');
  TextAttr:=ICFG.MenuLoLight;
  Write('BI    ');
  TextAttr:=ICFG.MenuHiLight;
  Write('G');
  TextAttr:=ICFG.MenuLoLight;
  Write('IF    ');
  TextAttr:=ICFG.MenuHiLight;
  Write('V');
  TextAttr:=ICFG.MenuLoLight;
  Write('OC    ');
  TextAttr:=ICFG.MenuHiLight;
  Write('I');
  TextAttr:=ICFG.MenuLoLight;
  Write('MG    ');
  TextAttr:=ICFG.MenuHiLight;
  Write('M');
  TextAttr:=ICFG.MenuLoLight;
  Write('OD31  M');
  TextAttr:=ICFG.MenuHiLight;
  Write('O');
  TextAttr:=ICFG.MenuLoLight;
  Write('D15  I');
  TextAttr:=ICFG.MenuHiLight;
  Write('B');
  TextAttr:=ICFG.MenuLoLight;
  Write('K    F');
  TextAttr:=ICFG.MenuHiLight;
  Write('L');
  TextAttr:=ICFG.MenuLoLight;
  Write('I    ');
  TextAttr:=ICFG.MenuHiLight;
  Write('F');
  TextAttr:=ICFG.MenuLoLight;
  Write('xx    E');
  TextAttr:=ICFG.MenuHilight;
  Write('X');
  TextAttr:=ICFG.MenuLoLight;
  Write('E   '#$10);

  Case UpCase(Readkey) Of
    'N' : Data.BFT:=1;
    'P' : Data.BFT:=2;
    'A' : Data.BFT:=3;
    'C' : Data.BFT:=4;
    'S' : Data.BFT:=5;
    'G' : Data.BFT:=6;
    'V' : Data.BFT:=7;
    'I' : Data.BFT:=8;
    'M' : Data.BFT:=9;
    'O' : Data.BFT:=10;
    'B' : Data.BFT:=11;
    'L' : Data.BFT:=12;
    'F' : Data.BFT:=13;
    'X' : Begin Data.BFT:=14; GetEXEType; End;
    #0 : Begin Readkey; GetType:=$FFFF; Exit; Screen^:=Back; End;
  Else
    GetType:=$FFFF;
    Screen^:=Back;
    Exit;
  End;

  Screen^:=Back;
  RsTextScreen;
  WriteScreen(Data);
  SvTextScreen;
End;

{----------------------------------------------------------------------}

Var
  MnX:Word;

Function GetMenu(N:Word):Word;
Var
  C:Char;
  Answer:Word;
Begin
  Answer:=$FFFF;

  If N<>0 Then
    MnX:=N;
  Repeat
    Case MnX Of
      1 : Menu1;
      2 : Menu2;
      3 : Menu3;
      4 : Menu4;
      5 : Menu5;
      6 : MenuH;
    End;

    HideCursor;
    N:=MnX;
    Repeat

      C:=Readkey;
      If C=#27 Then
        Answer:=$0000;

      If C=#0 Then
        Case Readkey Of
          #75 : Dec(MnX);
          #77 : Inc(MnX);
          #33 : MnX:=1;
          #50 : MnX:=2;
          #31 : MnX:=3;
          #18 : MnX:=4;
          #133,#23: MnX:=5;
          #35 : MnX:=6;
        End;
      If MnX>6 Then
        MnX:=1;
      If MnX<1 Then
        MnX:=6;

      If MnX=1 Then
        Case UpCase(C) Of
          'R' : Answer:=$5200;
          'Q' : Answer:=$5100;
          'H' : Answer:=$015F;
          'S' : Answer:=$013F;
          'U' : Answer:=$0141;
          'L' : Answer:=GetLoad;
        End;

      If MnX=2 Then
        Case UpCase(C) Of
          'D' : Answer:=GetData;
          'E' : Answer:=GetEOF;
          'M' : Answer:=$4500;
          'I' : Answer:=$4900;
          'L' : Answer:=$0153;
        End;

      If MnX=3 Then
        Case UpCase(C) Of
          'T' : Answer:=$5300;
          'A' : Answer:=$1300;
          'B' : Answer:=$4600;
          'G' : Answer:=$0600;
        End;

      If MnX=4 Then
        Begin
          If (Secondary=NIL) Then
            Begin
              If UpCase(C)='T' Then
                Answer:=$4100;
            End
          Else
            Case UpCase(C) Of
              'T' : Answer:=$4100;
              'P' : Answer:=$5000;
              'D' : Answer:=$4400;
              'X' : Answer:=$5800;
              'S' : Answer:=$0D00;
            End;
        End;

      If MnX=5 Then
        Begin
          Case UpCase(C) Of
            '2' : Answer:=$0140;
            'Y' : Answer:=GetType;
            'R' : Answer:=$0C00;
          End;

          If Secondary=NIL Then
            Case UpCase(C) Of
              'D' : Answer:=$5400;
              'T' : Answer:=$5000;
            End;

          If Not IsDisab Then
            Case UpCase(C) Of
              'F' : Answer:=$5600;
              'A' : Answer:=$1600;
            End;
        End;

      If MnX=6 Then
        Case UpCase(C) Of
          'C' : Answer:=$0300;
          'M' : Answer:=$4F00;
          'A' : Answer:=$013B;
          'R' : Answer:=$1200;
        End;
    Until (MnX<>N) Or (Answer<>$FFFF) Or (C=#27);
    ShowCursor;
    CloseWindow;

  Until (Answer<>$FFFF) Or (C=#27);
  Window(1,1,80,25);
  GetMenu:=Answer;
End;

{----------------------------------------------------------------------}

Procedure Repaint;
Begin
  Window(1,1,80,25);
  TextAttr:=ICFG.Lolight;
  ClrScr;
  DrawMenu;
  WriteHelpWindow;
  WriteHelp(hp);
  WriteScreen(Data);
End;

{----------------------------------------------------------------------}

Procedure Commands(Var D:DataType; Var Hp:HelpPointer);
Var C:Char;  I:Integer; W:Word;
Begin
  Window(1,1,80,25);
  GotoXY(1,25);
  HideCursor;
  If C1<>#0 Then
    C:=C1
  Else If MousePresent Then
    Begin
      ShowMC;
      Repeat
        C:=#$FF;
        If KeyPressed Then
          C:=UpCase(Readkey);
        If MouseButtonPressed(LeftButton) Then
          MInput(D,hp,LeftButton);
        If MouseButtonPressed(RightButton) Then
          MInput(D,hp,RightButton);
        If MouseButtonPressed(CenterButton) Then
          MInput(D,hp,CenterButton);
      Until C<>#$FF;
      HideMC;
    End
  Else
    C:=UpCase(Readkey);
  ShowCursor;
  If (C=^R) Then
    Begin
      OpenWindow(10,5,70,19,White or Magenta * $10);
      Writeln('  H E X E D   version ',VERSIONNUMBER);
      Writeln;
      Writeln('binary/hex/decimal/char file viewer/editor by Graham Ollis');
      Writeln('beta testing by David Wingate');
      Writeln;
      Writeln('This is shareware and should be registered.  See the');
      Writeln('README.DOC file for more information.');
      Writeln('You can E-MAIL, call or SNAIL-MAIL me');
      Writeln;
      Writeln('INTERNET:ollisg@lahs.losalamos.k12.nm.us');
      Writeln('PHONE:(505) 662-4544');
      Writeln('SNAIL-MAIL:Graham Ollis');
      Writeln('           1417 Big Rock Loop');
      Writeln('           Los Alamos NM 87544-2875');
      Write('           USA');
      HideCursor;
      Pause;
      ShowCursor;

      CloseWindow;
    End;
  If (C='/') Then
    Begin
      N:=AskSlash;
      C1:=UpCase(Readkey);
      If C1=#0 Then
        Begin
          C1:=#1;
          C2:=ReadKey;
        End;
      For W:=1 To N Do
        Begin
          DefaultOutPut;
          Commands(D,hp);
          If KeyPressed Then
            Begin
              C1:=#0;  C2:=#0;
              Exit;
            End;
        End;
      C1:=#0;  C2:=#0;
    End;
  If C='<' Then
    If D.BFT=14 Then
      Begin
        Dec(D.ED.Tp);
        If D.ED.Tp<0 Then
          D.ED.Tp:=NumberofExeTypes;
        WriteScreen(D);
      End
    Else
      C:=',';
  If C=',' Then
    Begin
      D.BFT:=D.BFT-1;
      If D.BFT<1 Then
        D.BFT:=NumberOfFileTypes;
      WriteScreen(D);
    End;
  If C='>' Then
    If D.BFT=14 Then
      Begin
        Inc(D.ED.Tp);
        If D.ED.Tp>NumberOfExeTypes Then
          D.ED.Tp:=0;
        WriteScreen(D);
      End
    Else
      C:='.';
  If C='.' Then
    Begin
      D.BFT:=D.BFT+1;
      If D.BFT>NumberOfFileTypes Then
        D.BFT:=1;
      WriteScreen(D);
    End;
  If (C='X') Then
    XTract(D);
  If (C='O') Then
    Begin
      OpenWindow(20,7,60,12,ICFG.MsgColor);
      Writeln('  Memory available      : ',MemAvail:6);
      Writeln('  Largest chunk         : ',MaxAvail:6);
      If MousePresent Then
        Writeln('  Mouse Coords (Rl-Sc)  : ',GetMouseX,',',GetMouseY,'-',GetMouseX div 8+1,',',GetMouseY div 8+1)
      Else
        Writeln('  No mouse detected');
      Writeln('  D.X/D.offset          : ',D.X,'/',D.offset);
      If VOCDriverInstalled Then
        Write('  digital/')
      Else
        Write('  x/');
      If CMFDriverInstalled Then
        Writeln('FM sound')
      Else
        Writeln('x sound');
      HideCursor;
      Pause;
      ShowCursor;
      CloseWindow;
    End;
  If (C='V') And (tmptxtscreen<>Nil) Then
    Begin
      SvTextScreen;
      View(D.stream,D.FN,D.BFT,FALSE);
      RsTextScreen;
    End;
  If (C=^V) And (tmptxtscreen<>Nil) Then
    Begin
      SvTextScreen;
      View(D.stream,D.FN,D.BFT,TRUE);
      RsTextScreen;
    End;
  If (C=^L) Or (C=^P) Then
    Repaint;
  If (C=^K) Then
    Begin
      OpenWindow(32,7,48,19,ICFG.MsgColor);
      Writeln(' A Save as');
      Writeln(' B Begin Block');
      Writeln(' C Copy Block');
      Writeln(' D Save and Quit');
      Writeln(' H Hide Block');
      Writeln(' K End Block');
      Writeln(' P Print');
      Writeln(' Q Fast Quit');
      Writeln(' R Read Block');
      Writeln(' S Save File');
      Writeln(' V Move Block');
      Writeln(' W Write Block');
      Write(' Y Delete');
      Window(1,1,80,25);
      GotoXY(1,25);
      Repeat Until KeyPressed;
      CloseWindow;
      Case UpCase(Readkey) Of
        #0  : Readkey;
        'A' : SaveAs(D);
        'B' : D.BlockStart:=D.X+D.offset;
        'C' : CopyBlock(D);
        'D' :
          Begin
            SaveSegment(D);
            WriteContactMsg;
            Halt;
          End;
        'H' :
          Begin
            D.BlockStart:=-1;
            D.BlockFinish:=-2;
          End;
        'K' : D.BlockFinish:=D.X+D.offset;
        'P' : Print(D);
        'Q' :
          Begin
            WriteContactMsg;
            Halt;
          End;
        'R' : ReadBlock(D);
        'S' : SaveSegment(D);
        'V' : MoveBlock(D);
        'W' : WriteBlock(D);
        'Y' :
          If (D.BlockStart>0) And (D.BlockFinish>0) Then
            Begin
              DeleteBlock(D,D.BlockStart,D.BlockFinish-D.BlockStart+1);
              D.BlockStart:=-1;
              D.BlockFinish:=-1;
            End;
      End;
    End;
  If C=' ' Then
    Begin
      viewMode:=viewMode+1;
      If viewMode=7 Then
        viewMode:=0;
      InsertSpaces(D,hp);
    End;
  If (C='T') And (Secondary=Nil) Then
    WriteTypeData(D.D^[D.X],D);
  If (C='P') And (Secondary=Nil) Then
    AutomaticTUse:=Not AutomaticTUse;
  Case C Of
    #13 : SwapFiles(D);
    'B' : BinaryEditor(D.D^[D.X],D);
    'F' : FindArray(D);
    ^F  : DoFindSearch(D);
    'A' : AdditionalFile(D,FilePath,FALSE);
    'P' : Paused:=Not Paused;
    'D' : SearchDiff(D);
    'S' : SearchStr(D,True);
    ^S  : SearchStr(D,False);
    '1' : DoInsert(D,1,0);
    '2' : DoInsert(D,2,0);
    '3' : DoInsert(D,3,0);
    '4' : DoInsert(D,4,0);
    '5' : DoInsert(D,5,0);
    '6' : DoInsert(D,6,0);
    '7' : DoInsert(D,7,0);
    '8' : DoInsert(D,8,0);
    '9' : DoInsert(D,9,0);
    'I' : WhatInsert(D);
    'H' : HexModify(D.D^[D.X],D.X,D);
    'G' : CharModify(D.D^[D.X],D.X,D);
    'W' : WordModify(D);
    'L' : LongModify(D);
    '*' : SetX(D.X,D);
    ^C  : ConfigureColor;
  End;
  If C='R' Then
    Begin
      NameChange(D);
      WriteScreen(D);
    End;
  If ((C='Q') Or (C=#27)) And (ReallyQuit(D)) Then
    Begin
      WriteContactMsg;
      Halt;
    End;
  If C='+' Then
    If D.EOF+1<maxlong-1 Then
      Begin
        I:=0;
        Seek(D.stream,D.EOF);
        D.EOF:=D.EOF+1;
        BlockWrite(D.stream,I,1);
        ToggleChanges(D);
        Relocate(D);
        If (Secondary<>Nil) Then
          Relocate(Secondary^);
      End;
  If C='-' Then
    If D.EOF-1>0 Then
      Begin
        D.EOF:=D.EOF-1;
        ToggleChanges(D);
        Seek(D.stream,D.EOF-1);
        Truncate(D.stream);
        Relocate(D);
        If (Secondary<>Nil) Then
          Relocate(Secondary^);
      End;
  If C='=' Then
    If D.X<>D.EOF Then
      Begin
        D.EOF:=D.X+D.offset;
        ToggleChanges(D);
        Seek(D.stream,D.EOF-1);
        Truncate(D.Stream);
        Relocate(D);
        If (Secondary<>Nil) Then
          Relocate(Secondary^);
      End;
  If (C='E') Then
    Begin
      If DefVarEd=DefHex Then
        DefVarEd:=DefDec
      Else
        DefVarEd:=DefHex;
      WriteScreen(D);
    End;
  If (C=#0) Or (C=#1) Then
    Begin
      If C2<>#0 Then
        C:=C2
      Else
        C:=Readkey;

      If C In [#33,#50,#31,#18,#133,#23,#35] Then
        Begin
          Case C Of
            #33 : W:=GetMenu(1);
            #50 : W:=GetMenu(2);
            #31 : W:=GetMenu(3);
            #18 : W:=GetMenu(4);
            #133,#23: W:=GetMenu(5);
            #35 : W:=GetMenu(6);
          End;

          If W<>$0000 Then
            Begin
              C1:=Char(Hi(W));
              C2:=Char(Lo(W));
              Commands(D,hp);
              C1:=#0;  C2:=#0;
            End;

        End;

      If (C=#98) Then
        SaveAs(D);
      If (C=#82) Then
        DoInsert(D,1,0);
      If (C=#83) Or (C=#8) Then
        DelByte(D);
      If C=#75 Then
        D.X:=D.X-1;
      If C=#77 Then
        D.X:=D.X+1;
      If C=#95 Then
        DosShell(D);
      If C=#71 Then
        If D.Offset=0 Then
          D.X:=1
        Else
          Begin
            SaveSegment(D);
            D.X:=1;
            D.offset:=0;
            RestoreSegment(D);
          End;
      If C=#79 Then
        Begin
          If D.offset=0 Then
            D.X:=D.EOF
          Else
            Begin
              SaveSegment(D);
              D.X:=imagesize-1;
              D.offset:=D.EOF-imagesize+1;
              RestoreSegment(D);
            End;
        End;
      If (C=#80) Then
        If DefVarEd=DefHex Then
          DefVarEd:=DefDec
        Else
          DefVarEd:=DefHex;
      If (C=#73) Then
        D.X:=D.X-24;
      If (C=#81) Then
        D.X:=D.X+24;
      If C=#59 Then
        HEXEDInfo;
      If C=#60 Then
        Begin
          OpenWindow(20,10,60,12,ICFG.MsgColor);
          I:=Choice(3,'  Null terminated string','  No termination','  Pascal type','','','',20,10,60);
          CloseWindow;
          If I<>7 Then
            Begin
              InsertString(I,D);
              ToggleChanges(D);
            End;
        End;
      If (C=#63) Then
        SaveSegment(D);
      If (C=#64) Then
        Begin
          SecondOutput(D);
          Repaint;
          ShowCursor;
        End;
      If (C=#65) Then
        Begin
          RestoreSegment(D);
          D.Changes:=False;
          WriteScreen(D);
        End;
      If (C=#72) Or (C=#80) Then
        Begin
          Case Ord(C) Of
            72 : hp^.Y:=hp^.Y-1;
            80 : hp^.Y:=hp^.Y+1;
          End;
          If hp^.Y<1 Then
            hp^.Y:=1;
          If hp^.Y>MaxHelp-(HelpY2-HelpY1-1) Then
            hp^.Y:=MaxHelp-(HelpY2-HelpY1-1);
          WriteHelp(hp);
        End;
      If (C=#67) Then
        Begin
          If ReallyDispose(D) Then
            Begin
              SvTextScreen;
              D.FN:=ChooseFileName('HEXED version '+versionnumber,'Load new primary file',FilePath);
              RsTextScreen;
              Close(D.stream);
              LoadFile2(D);
              CheckFileType(D);
            End;
          WriteScreen(D);
        End;
      If (C=#68) Then
        Begin
          If ((Secondary=NIL) Or (ReallyDispose(Secondary^))) Then
            Begin
              If Secondary=NIL Then
                Begin
                  If MemAvail>SizeOf(Secondary^) Then
                    Begin
                      New(Secondary);
                      If MemAvail>SizeOf(Secondary^.D^) Then
                        Begin
                          New(Secondary^.D);
                          SvTextScreen;
                          Secondary^.FN:=ChooseFileName('HEXED version '+versionnumber,'Load new secondary file',FilePath);
                          RsTextScreen;
                          LoadFile2(Secondary^);
                          CheckFileType(Secondary^);
                        End;
                    End;
                End
              Else
                Begin
                  Close(Secondary^.Stream);
                  Secondary^.FN:=GetFLINFileName(IsFLIN(ParamStr(2)));
                  LoadFile2(Secondary^);
                End;
            End;
        End;
      If (C=#102) Then
        Begin
          If ReallyDispose(D) Then
            Begin
              D.FN:=GetFLINFileName(IsFLIN(ParamStr(1)));
              Close(D.stream);
              LoadFile2(D);
            End;
          WriteScreen(D);
        End;
      If (C=#103) Then
        Begin
          If ((Secondary=NIL) Or (ReallyDispose(Secondary^))) Then
            Begin
              If Secondary=NIL Then
                Begin
                  If MemAvail>SizeOf(Secondary^) Then
                    Begin
                      New(Secondary);
                      If MemAvail>SizeOf(Secondary^.D^) Then
                        Begin
                          New(Secondary^.D);
                          Secondary^.FN:=GetFLINFileName(IsFLIN(ParamStr(2)));
                          LoadFile2(Secondary^);
                        End;
                    End;
                End
              Else
                Begin
                  Secondary^.FN:=GetFLINFileName(IsFLIN(ParamStr(2)));
                  Close(Secondary^.stream);
                  LoadFile2(Secondary^);
                End;
            End;
        End;
      C:=#0;
    End;
End;

{======================================================================}

Begin
  MnX:=1;
End.
