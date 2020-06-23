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
| second.pas
|   allow viewing two files on just ONE screen.  wow.  just like windows
|   only FAST!  you know... it's too bad no one will ever actually read
|   these comments.
|
| History:
| Date       Author     Comment
| ----       ------     -------
| -- --- 94  G. Ollis	 created and developed program
============================================================================*)

{$I-}

Unit Second;

INTERFACE

Uses
  Header,CHFILE;

{++PROCEDURES++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Procedure AdditionalFile(Var D:DataType; InpFileName:MaskString; Bo:Boolean);
Procedure SwapFiles(Var D:DataType);
Procedure SearchDiff(Var D:DataType);

{++FUNCTIONS+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

IMPLEMENTATION

Uses
  CRT,UModify,ViewU,FUTIL,CFG,OutCRT,VConvert,Cursor;

{----------------------------------------------------------------------}

Procedure AdditionalFile(Var D:DataType; InpFileName:MaskString; Bo:Boolean);
Var count:Word; i:Word; Error:Integer;  b:byte;
Begin
  Window(1,6,80,9);
  TextAttr:=ICFG.Lolight;
  ClrScr;
  AutomaticTUse:=False;
  If (Secondary<>Nil) Then
    Begin
      Window(1,1,80,25);
      If Not ReallyDispose(Secondary^) Then
        Exit;
      Close(Secondary^.stream);
      Dispose(Secondary^.D);
      Dispose(Secondary);
      Secondary:=Nil;
      Exit;
    End;
  If MaxAvail<SizeOf(DataType)+SizeOf(binaryimage) Then
    Begin
      ErrorMsg('Not enough memory.');
      Exit;
    End;
  New(Secondary);
  Secondary^.BlockStart:=-1;
  Secondary^.BlockFinish:=-2;
  SvTextScreen;
  If NOT Bo Then
    Secondary^.FN:=ChooseFileName('HEXED version '+versionnumber,'Load Secondary File',InpFileName)
  Else
    Secondary^.FN:=InpFileName;
  FilePath:=Secondary^.FN;
  RsTextScreen;
  If (SizeOf(BinaryImage)>MaxAvail) Then
    Begin
      ErrorMsg('Not enough memory');
      Dispose(Secondary);
      Secondary:=Nil;
      Exit;
    End;
  If (Secondary^.FN='') Then
    With Secondary ^ Do
      Begin
        Secondary^.FN:='NONAME.DAT';
        Assign(Secondary^.stream,Secondary^.FN);
        ReWrite(Secondary^.stream,1);
        B:=$00;
        BlockWrite(Secondary^.stream,B,1);
        Close(Secondary^.stream);
      End;
  New(Secondary^.D);
  FillChar(Secondary^.D^,imagesize,0);
  Assign(Secondary^.stream,Secondary^.FN);
  Reset(Secondary^.stream,1);
  Error:=IOResult;
  If Error<>0 Then
    Begin
      ErrorMsg('Error opening file for read '+IntToStr(Error,0));
      Dispose(Secondary^.D);
      Dispose(Secondary);
      Secondary:=Nil;
      Exit;
    End;
  If FileSize(Secondary^.stream)>imagesize-1 Then
    BlockRead(Secondary^.stream,Secondary^.D^,imagesize-1,Error)
  Else
    BlockRead(Secondary^.stream,Secondary^.D^,FileSize(Secondary^.stream));
  Secondary^.offset:=0;
  Error:=IOResult;
  If Error<>0 Then
    Begin
      ErrorMsg('Error reading file '+IntToStr(Error,0));
      If Secondary^.D<>Nil Then
        Dispose(Secondary^.D);
      Dispose(Secondary);
      Secondary:=Nil;
      Exit;
    End;
  Secondary^.Changes:=False;
  Secondary^.EOF:=SizeOfFile(Secondary^.FN);
  Secondary^.X:=D.X;
  Secondary^.BlockStart:=-1;
  Secondary^.BlockStart:=-2;
  Relocate(Secondary^);
  CheckFileType(Secondary^);
End;

{------------------------------------------------------------------------}

Procedure SwapFiles(Var D:DataType);
Var tmp:DataType;  tmpImage:BinaryImagePointer;  F:File Of BinaryImage;
    Error:Integer;
Begin
  If Secondary=Nil Then
    Exit;
  tmp:=Secondary^;
  Secondary^:=D;
  D:=tmp;
  If HelpDir='' Then
    Assign(F,'VIRT.000')
  Else
    Assign(F,HelpDir+'\VIRT.000');
  Rewrite(F);
  Error:=IOResult;
  If Error<>0 Then
    Exit;
  Write(F,Secondary^.D^);
  Error:=IOResult;
  If Error<>0 Then
    Begin
      ErrorMsg('Error writing temp file');
      CloseWindow;
      Exit;
    End;
  Close(F);

  Secondary^.D^:=D.D^;

  Reset(F);
  Error:=IOResult;
  If Error<>0 Then
    Begin
      ErrorMsg('Error opeing temp file');
      Exit;
    End;
  Read(F,D.D^);
  If Error<>0 Then
    Begin
      ErrorMsg('Error reading temp file');
      Exit;
    End;
  Close(F);

  Erase(F);

  Repeat Until IOResult=0;
  tmpImage:=Secondary^.D;
  Secondary^.D:=D.D;
  D.D:=tmpImage;
  WriteScreen(D);
End;

{------------------------------------------------------------------------}

Procedure SearchDiff(Var D:DataType);
Var
  SaveX,SaveOffset:LongInt;
  I:Word;
Begin
  If Secondary=Nil Then
    Exit;
  SaveSegment(D);
  SaveX:=D.X;
  SaveOffset:=D.Offset;
  D.offset:=D.X+D.offset;
  Secondary^.offset:=D.offset;
  D.X:=1;
  Secondary^.X:=1;

  OpenWindow(10,10,70,12,ICFG.MsgColor);
  GotoXY(1,1);
  Write('Comparing ',D.FN,' to ',Secondary^.FN);

  HideCursor;
  While (D.offset+D.X<D.EOF) And NOT KeyPressed Do
    Begin

      GotoXY(1,2);
      Writeln('checking segment at offset :',D.X+D.offset,'/',D.EOF);
      Write('$',Long2Str(D.X+D.offset),'/$',Long2Str(D.EOF));

      RestoreSegment(D);
      RestoreSegment(Secondary^);
      For I:=1 To imagesize Do
        If D.D^[I]<>Secondary^.D^[I] Then
          Begin
            D.X:=I;
            CloseWindow;
            ShowCursor;
            Exit;
          End;

      D.offset:=D.offset+imagesize-100;
      Secondary^.offset:=D.offset;
      D.X:=1;
      Secondary^.X:=1;

    End;

  CloseWindow;

  D.X:=SaveX;
  D.Offset:=SaveOffset;
  RestoreSegment(D);

  If KeyPressed Then
    Readkey;

  ShowCursor;

End;

{======================================================================}

End.