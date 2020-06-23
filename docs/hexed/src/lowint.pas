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
| lowint.pas
|    low interface accessed by user functions.
|    sorry, i'm confused.
|
| History:
| Date       Author     Comment
| ----       ------     -------
| -- --- 94  G. Ollis	 created and developed program
============================================================================*)

{$I-}

Unit LowInt; {Low Interface (accessed by user functions)}

INTERFACE

Uses
  Header;

{++PROCEDURES++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Procedure FastInsert(Var D:DataType; X,size:LongInt;  bi:Byte);
Procedure DoInsert(Var D:DataType;  am:LongInt;  bi:Byte);

{++FUNCTIONS+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Function IfStrThere(Var D:DataType; Var i:LongInt; S:String):Boolean;

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

IMPLEMENTATION

Uses
  FUTIL,OUTCRT,ViewU,CFG,CRT,VConvert;

{----------------------------------------------------------------------}

Procedure FastInsert(Var D:DataType; X,size:LongInt;  bi:Byte);
Var l:LongInt; count,wtn:Word;
Begin
  Dec(X);
  SaveSegment(D);

  l:=0;
  While (l+1)*$FFFF+X<FileSize(D.stream) Do
    Inc(l);

  For l:=l DownTo 0 Do
    Begin
      Seek(D.stream,l*$FFFF+X);
      BlockRead(D.stream,D.D^,imagesize,count);
      Seek(D.stream,l*$FFFF+X+size);
      BlockWrite(D.stream,D.D^,count,wtn);
      If count<>wtn Then
        Begin
          ErrorMsg('error moving writing segments');
          Exit;
        End;
    End;

  FillChar(D.D^,imagesize,bi);
  Seek(D.stream,X);
  While size>0 Do
    If size>$FFFF Then
      Begin
        BlockWrite(D.stream,D.D^,$FFFF);
        If IOResult=0 Then
          ;
        size:=size-$FFFF;
      End
    Else
      Begin
        BlockWrite(D.stream,D.D^,size);
        If IOResult=0 Then
          ;
        size:=size-size;
      End;

  RestoreSegment(D);
  D.EOF:=FileSize(D.stream);
End;

{------------------------------------------------------------------------}

Procedure DoInsert(Var D:DataType;  am:LongInt;  bi:Byte);
Var index:LongInt; Filler:Array [0..10] Of Byte;  error:Word;
    X,Y:Byte;
Begin
  If D.EOF<imagesize-1 Then
    Begin
      For index:=D.EOF DownTo D.X+D.offset Do
        D.D^[index+am]:=D.D^[index];
      For index:=D.X+D.offset To D.X+D.offset+am-1 Do
        D.D^[index]:=bi;
      D.EOF:=D.EOF+am;
      ToggleChanges(D);
    End
  Else
    FastInsert(D,D.X+D.offset,am,bi);
End;

{------------------------------------------------------------------------}

Function IfStrThere(Var D:DataType; Var i:LongInt; S:String):Boolean;
Var index:LongInt;
Begin
  IfStrThere:=False;
  For index:=1 To Length(S) Do
    If D.D^[i+index-1]<>Ord(S[index]) Then
      Exit;
  IfStrThere:=True;
End;

{======================================================================}

End.