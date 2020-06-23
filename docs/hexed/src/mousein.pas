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
| mousein.pas
|   handle the mouse input.  supposed to be like keyin is to the keyboard,
|   but last time i tested it, didn't work.  *sigh*
|
| History:
| Date       Author     Comment
| ----       ------     -------
| -- --- 94  G. Ollis	 created and developed program
============================================================================*)

{$I-}

Unit MouseIN;

INTERFACE

Uses
  Header;

{++PROCEDURES++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Procedure MInput(Var D:DataType; Var hp:HelpPointer; wb:Byte);

{++FUNCTIONS+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

IMPLEMENTATION

Uses
  Ollis,CFG,CRT,OutCRT,UModify,BinED,Help,KeyIn;

{----------------------------------------------------------------------}

Procedure MInput(Var D:DataType; Var hp:HelpPointer; wb:Byte);
Var X,Y:Integer;   First:Boolean;
Begin
  HideMC;
  X:=GetMouseX div 8+1;  Y:=GetMouseY div 8+1;
  First:=True;
  If (wb=LeftButton) And (Y>0) And (Y<4) And (X<76) Then
    Repeat
      If First Then
        Begin
          Delay(75);
          First:=False;
        End;
      X:=GetMouseX div 8+1;  Y:=GetMouseY div 8+1;
      Delay(15);
      D.X:=D.X+(X div 3)-12;
      DefaultOutPut;
    Until MouseButtonReleased(LeftButton);
    If wb=RightButton Then
      If (D.X+(X div 3)-12>=1) And (D.X+(X div 3)-12<D.EOF) And
         (Y<4) Then
        If (Y=1) Or (Y=2) Then
          HexModify(D.D^[D.X+(X div 3)-12],D.X+(X div 3)-12,D)
        Else
          CharModify(D.D^[D.X+(X div 3)-12],D.X+(X div 3)-12,D);
    If wb=CenterButton Then
      If (D.X+(X div 3)-12>=1) And (D.X+(X div 3)-12<ImageSize-1) And
         (Y<4) Then
        BinaryEditor(D.D^[D.X+(X div 3)-12],D);
    If (hp<>Nil) And (wb=LeftButton) And (Y=11) Then
      Repeat
        hp^.Y:=hp^.Y-1;
        If hp^.Y<1 Then
          hp^.Y:=1;
        WriteHelp(hp);
        Delay(25);
      Until MouseButtonReleased(LeftButton);
    If (hp<>Nil) And (wb=LeftButton) And (Y=24) Then
      Repeat
        hp^.Y:=hp^.Y+1;
        If hp^.Y>MaxHelp-12 Then
          hp^.Y:=MaxHelp-12;
        WriteHelp(hp);
        Delay(25);
      Until MouseButtonReleased(LeftButton);
    If (wb=LeftButton) And (Y=5) Then
      Begin
        C1:=' ';
        Commands(D,hp);
        C1:=#0;
      End;
    If (wb=LeftButton) And (Y>=6) And (Y<=9) Then
      Begin
        C1:='P';
        Commands(D,hp);
        C1:=#0;
      End;
    If (wb=RightButton) And (Y>=6) And (Y<=9) Then
      Begin
        C1:='D';
        Commands(D,hp);
        C1:=#0;
      End;
    If (wb=RightButton) And (Y=5) Then
      Begin
        C1:=#13;
        Commands(D,hp);
        C1:=#0;
      End;
    If (wb=CenterButton) And (Y=5) Then
      Begin
        C1:='A';
        Commands(D,hp);
        C1:=#0;
      End;
  ShowMC;
  DefaultOutPut;
End;

{======================================================================}

End.