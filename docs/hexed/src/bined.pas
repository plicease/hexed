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
| bined.pas
|   * allow the user to modify the current byte of the bit level
|
| History:
| Date       Author     Comment
| ----       ------     -------
| -- --- 94  G. Ollis	 created and developed program
============================================================================*)

{$I-}

Unit BinEd;

INTERFACE

Uses
  Header;

{++PROCEDURES++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Procedure BinaryEditor(Var B:Byte; Var D:DataType);

{++FUNCTIONS+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

IMPLEMENTATION

Uses
  CRT,VConvert,FUTIL,Cursor;

Var
  LastB:Byte;

{------------------------------------------------------------------------}

Procedure Display(B:Byte; CE:Integer; Y:Integer);
Var I,X:Integer;
Begin
  GotoXY(1,Y);
  For I:=8 DownTo 1 Do
    Begin
      If (I=CE) Then
        TextAttr:=ICFG.Highlight;
      If Boolean(B And Bit[I]) Then
        Write('1')
      Else
        Write('0');
      If (I=CE) Then
        TextAttr:=ICFG.Numbers;
    End;
  Write('  ');
  ClrEol;
  Write(Byte2Str(B),B:4,' ');
  If B<>Byte(^G) Then
    Write(Chr(B))
  Else
    Write(' ');
End;

{------------------------------------------------------------------------}

Procedure WriteCmdline(S:String;  X,Y:Byte);
Var Index:Integer;
Begin
  GotoXY(X,Y);
  TextAttr:=ICFG.Lolight;
  For Index:=1 To Length(S) Do
    Begin
      If ((S[Index]>='A') And (S[Index]<='Z')) Or (S[Index]='<')
        Or (S[Index]='>') Then
        TextAttr:=ICFG.Highlight;
      Write(S[Index]);
      If ((S[Index]>='A') And (S[Index]<='Z')) Or (S[Index]='<')
        Or (S[Index]='>') Then
        TextAttr:=ICFG.LoLight;
    End;
End;

{------------------------------------------------------------------------}

Procedure BinaryEditor(Var B:Byte; Var D:DataType);
Var
  CE:Integer;
  Temp:Byte;
  C:Char;
Begin
  HideCursor;
  Temp:=B;
  CE:=8;
  GotoXY(1,8);
  TextAttr:=ICFG.Lolight;
  ClrEOL;
  Window(1,6,80,7);
  ClrScr;
  WriteCMDLine('  <ENTER> save byte <ESC> exit ''<'' shift left ''>'' shift right',19,1);
  WriteCMDLine('  <SPACE> toggle Not And Or Xor Increment Decrement Swap',19,2);
  Window(1,6,19,7);
  Repeat
    Display(B,CE,1);
    Display(LastB,CE,2);
    C:=UpCase(Readkey);
    If (C='S') Then
      Begin
        B:=B XOr LastB;
        LastB:=B XOr LastB;
        B:=B XOr LastB;
      End;
    If (C='I') Then
      Inc(B);
    If (C='D') Then
      Dec(B);
    If (C='N') Then
      B:=NOT B;
    If (C='A') Then
      B:=B And LastB;
    If (C='O') Then
      B:=B Or LastB;
    If (C='X') Then
      B:=B XOr LastB;
    If (C=' ') Then
      If Boolean(B And Bit[CE]) Then
        B:=B And Not Bit[CE]
      Else
        B:=B XOR Bit[CE];
    If (C='<') Or (C=',') Then
      B:=B Shl 1;
    If (C='>') Or (C='.') Then
      B:=B Shr 1;
    If C=#0 Then
      Begin
        C:=Readkey;
        If (C=#75) Then
          CE:=CE+1;
        If (C=#77) Then
          CE:=CE-1;
        IF CE>8 Then
          CE:=8;
        If CE<1 Then
          CE:=1;
      End;
  Until (C=#13) Or (C=#27);
  If (C=#13) Then
    Begin
      LastB:=B;
      ToggleChanges(D);
    End
  Else
    B:=Temp;
  Window(1,6,80,7);
  ClrScr;
  TextAttr:=ICFG.LoLight;
  ClrScr;
  Window(1,1,80,25);
  ShowCursor;
End;

{======================================================================}

Begin
  LastB:=0;
End.