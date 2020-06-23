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
| help.pas
|    display the helpful help window.
|
| History:
| Date       Author     Comment
| ----       ------     -------
| -- --- 94  G. Ollis	 created and developed program
============================================================================*)

{$I-}

Unit Help;

INTERFACE

Uses
  Header;

{++PROCEDURES++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Procedure WriteHelp(Var hp:HelpPointer);
Procedure WriteHelpWindow;

{++FUNCTIONS+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Function LoadHelp(Var hp:HelpPointer):Boolean;

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

IMPLEMENTATION

Uses
  CFG,CRT,OUTCRT;

{----------------------------------------------------------------------}

Procedure WriteHelpWindow;
Var index,index2:Integer;
Begin
  TextAttr:=ICFG.HelpWindow;
  Window(1,HelpY1-1,80,HelpY2+1);
  Write(#201);
  For index:=2 To 79 Do
    Write(#205);
  Write(#187);
  For index:=HelpY1 To HelpY2-1 Do
    Begin
      Write(#186);
      For index2:=2 To 79 Do
        Write(' ');
      Write(#186);
    End;
  Write(#200);
  For index:=2 To 79 Do
    Write(#205);
  Write(#188);
  Window(1,1,80,25);
End;

{----------------------------------------------------------------------}

Function LoadHelp(Var hp:HelpPointer):Boolean;
Var F:Text; index:Integer;
Begin
  LoadHelp:=False;
  If MaxAvail<SizeOf(HelpType) Then
    Exit;
  New(hp);
  If HelpDir='' Then
    Assign(F,HelpFile)
  Else
    Assign(F,HelpDir+'\'+HelpFile);
  Reset(F);
  If IOResult<>0 Then
    Begin
      GoToXY(1,HelpY1-1);
      If HelpDir='' Then
        Writeln('Could not find help file ',HelpFile)
      Else
        Writeln('Could not find help file ',HelpDir+'\'+HelpFile);
      Exit;
    End;
  For index:=1 To MaxHelp-1 Do
    hp^.S[index]:=' ~';
  hp^.S[MaxHelp]:=' END OF HELP';
  index:=1;
  While (Not EOF(F)) And (index<=MaxHelp) Do
    Begin
      Readln(F,hp^.S[index]);
      index:=index+1;
    End;
  Close(F);

  WriteHelpWindow;

  LoadHelp:=True;
  Hp^.Y:=1;
End;

{------------------------------------------------------------------------}

Procedure WriteHelp(Var hp:HelpPointer);
Var index:Integer;  I:Integer;
Begin
  If hp=Nil Then
    If Not LoadHelp(hp) Then
      Exit;
  Window(2,HelpY1,79,HelpY2-1);
  TextAttr:=ICFG.HelpColor;
  Window(2,HelpY1,79,HelpY2);
  I:=0;
  For index:=hp^.Y To hp^.Y+HelpY2-HelpY1-1 Do
    If index<MaxHelp+1 Then
      Begin
        Write(hp^.S[index]);
        ClrEol;
        Writeln;
        I:=I+1;
      End;
  Window(1,1,80,25);
End;

{======================================================================}

End.