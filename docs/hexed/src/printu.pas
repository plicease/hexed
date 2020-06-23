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
| printu.pas
|     printer module for printing out bianry data.
|     NOTE: this is printer as in LINE printer.
|
| History:
| Date       Author     Comment
| ----       ------     -------
| -- --- 94  G. Ollis	 created and developed program
============================================================================*)

{$I-}

Unit PrintU;

INTERFACE

Uses
  Header;

{++PROCEDURES++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Procedure PrintPage(Var D:DataType;  Start:LongInt; Var Printer:TEXT);
Procedure Print(Var D:DataType);

{++FUNCTIONS+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Function Byte2Bin(B:Byte):BinString;

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

IMPLEMENTATION

Uses
  ViewU,OutCRT,VConvert,CFG,CRT,UModify;

{----------------------------------------------------------------------}

Function Byte2Bin(B:Byte):BinString;
Var
  Answer:BinString;
Begin
 Answer:='';
 If Boolean(Bit8 And B) Then
   Answer:=Answer+'1'
 Else
   Answer:=Answer+'0';
 If Boolean(Bit7 And B) Then
   Answer:=Answer+'1'
 Else
   Answer:=Answer+'0';
 If Boolean(Bit6 And B) Then
   Answer:=Answer+'1'
 Else
   Answer:=Answer+'0';
 If Boolean(Bit5 And B) Then
   Answer:=Answer+'1'
 Else
   Answer:=Answer+'0';
 If Boolean(Bit4 And B) Then
   Answer:=Answer+'1'
 Else
   Answer:=Answer+'0';
 If Boolean(Bit3 And B) Then
   Answer:=Answer+'1'
 Else
   Answer:=Answer+'0';
 If Boolean(Bit2 And B) Then
   Answer:=Answer+'1'
 Else
   Answer:=Answer+'0';
 If Boolean(Bit1 And B) Then
   Answer:=Answer+'1'
 Else
   Answer:=Answer+'0';
 Byte2Bin:=Answer;
End;

{------------------------------------------------------------------------}

Procedure PrintPage(Var D:DataType;  Start:LongInt; Var Printer:TEXT);
Const
  LineStart = 4;
  LineFinish = 60;
Type
  PrintBuffType = Array [LineStart..LineFinish,1..4] Of Byte;
  PrintBuffPointer = ^PrintBuffType;
Var
  PrintBuff : PrintBuffPointer;
  Count     : Word;
  Error     : Integer;
  X,Y       : Integer;
Begin
  If SizeOf(PrintBuffType)>MaxAvail Then
    Begin
      CloseWindow;
      ErrorMsg('Not enough memory for print buffer');
      Exit;
    End;
  New(PrintBuff);
  FillChar(PrintBuff^,SizeOf(PrintBuffType),0);
  Seek(D.stream,Start-1);
  BlockRead(D.stream,PrintBuff^,SizeOf(PrintBuffType),Count);

  Writeln(Printer,'print out from HEXED version ',versionnumber,' by Graham Ollis (505) 662-4544');
  Writeln(Printer,'Data File : ',Path2File(D.FN),
          ' Offset : ',Start:11,' $',Long2Str(Start));
  For X:=1 To 80 Do
    Write(Printer,#205);
  Writeln(Printer);
  For Y:=LineStart To LineFinish Do
    Begin
      For X:=1 To 4 Do
        Write(Printer,Byte2Bin(PrintBuff^[Y,X]),' ');
      For X:=1 To 4 Do
        Write(Printer,'$',Byte2Str(PrintBuff^[Y,X]),' ');
      For X:=1 To 4 Do
        Write(Printer,PrintBuff^[Y,X]:3,' ');
      For X:=1 To 4 Do
        If PrintBuff^[Y,X]>31 Then
          Write(Printer,Chr(PrintBuff^[Y,X]))
        Else
          Write(Printer,'.');
      Writeln(Printer);
      If IOResult<>0  Then
        ;
    End;
  Dispose(PrintBuff);
End;

{------------------------------------------------------------------------}

Procedure Print(Var D:DataType);
Var
  Printer:TEXT;
  S:String;
  l:LongInt;
Begin
  OpenWindow(10,10,70,11,ICFG.MsgColor);
  Writeln('Enter file to write to or PRN for printer.');
  Write('> ');
  S:=StringEdit('PRN',58,FileSet);
  CloseWindow;

  If EscExit Then
    Exit;

  Assign(Printer,S);
  Rewrite(Printer);

  OpenWindow(10,10,70,11,ICFG.MsgColor);
  Case Choice(2,'Print page only','Print all file','','','','',10,10,70) Of
    $01 : PrintPage(D,D.X+D.offset,Printer);
    $02 : For l:=0 To FileSize(D.stream) div 224 Do
            PrintPage(D,l*224+1,Printer);
  End;
  CloseWindow;

  Close(Printer);
End;

{======================================================================}

End.