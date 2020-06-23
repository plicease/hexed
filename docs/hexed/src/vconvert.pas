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
| vconvert.pas
|    convert various data formats.  usually involving strings on one end or
|    the other (sometimes even the other).
|
| History:
| Date       Author     Comment
| ----       ------     -------
| -- --- 94  G. Ollis	 created and developed program
============================================================================*)

{$I-}

Unit VConvert;

INTERFACE

{++PROCEDURES++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{++FUNCTIONS+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Function StrToInt(S:String):LongInt;
Function UpString(S:String):String;
Function IntToStr(I: Longint; fm:Byte): String;
Function Byte2Str(w: word):String;
Function Long2Str(w:LongInt):String;
Function Word2Str(w:LongInt):String;
Function Octal2Permission(W:Word):String;

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

IMPLEMENTATION

{----------------------------------------------------------------------}

Function StrToInt(S:String):LongInt;
Var
  Temp:LongInt;
  Error:Integer;
Begin
  Val(S,Temp,Error);
  If Error <> 0 Then
    StrToInt:=0
  Else
    StrToInt:=Temp;
End;

{----------------------------------------------------------------------}

Function UpString(S:String):String;
Var i:Integer;
Begin
  For i:=1 To Length(S) Do
    S[i]:=UpCase(S[i]);
  UpString:=S;
End;

{------------------------------------------------------------------------}
function IntToStr(I: Longint; fm:Byte): String;
{ Convert any integer type to a string }
var
 S: string[11];
begin
 Str(I:fm, S);
 IntToStr := S;
end;
{------------------------------------------------------------------------}

Function Byte2Str(w: word):String;
{pre:word
 post:string containing the low order byte's value in string format}
const
  hexChars: array [0..$F] of Char =
   '0123456789ABCDEF';
begin
 Byte2Str:=hexChars[w shr 4]+hexChars[w and $F];
end;

{-----------------------------------------------------------------}

Function Long2Str(w:LongInt):String;
{pre:LongInt
 Post:two loest order bytes on the LongInt in String format}
Type ByteArray=Array [1..4] Of Byte;
Var
  B:^ByteArray;
  index:Integer;
  ans:String;
Begin
  ans:='';
  B:=@w;
  For index:=4 DownTo 1 Do
    ans:=ans+Byte2Str(B^[index]);
  Long2Str:=ans;
End;

{-----------------------------------------------------------------}

Function Word2Str(w:LongInt):String;
Type ByteArray=Array [1..4] Of Byte;
Var B:^ByteArray;
  index:Integer;
  ans:String;
Begin
  ans:='';
  B:=@w;
  For index:=2 DownTo 1 Do
    ans:=ans+Byte2Str(B^[index]);
  Word2Str:=ans;
End;

{-----------------------------------------------------------------}

Const
  WRL_X = $1;           { o001 }
  WRL_W = $2;           { o002 }
  WRL_R = $4;           { o004 }
  GRP_X = $8;           { o010 }
  GRP_W = $10;          { o020 }
  GRP_R = $20;          { o040 }
  OWN_X = $40;          { o100 }
  OWN_W = $80;          { o200 }
  OWN_R = $100;         { o400 }

Function Octal2Permission(W:Word):String;
Var
  Answer:String;
Begin
  {OWNER}
  Answer := 'own:';
  If boolean(W And OWN_R) Then
    Answer := Answer + 'r'
  Else
    Answer := Answer + '-';
  If boolean(W And OWN_W) Then
    Answer := Answer + 'w'
  Else
    Answer := Answer + '-';
  If boolean(W And OWN_X) Then
    Answer := Answer + 'x'
  Else
    Answer := Answer + '-';

  {GROUP}
  Answer := ' grp:';
  If boolean(W And GRP_R) Then
    Answer := Answer + 'r'
  Else
    Answer := Answer + '-';
  If boolean(W And GRP_W) Then
    Answer := Answer + 'w'
  Else
    Answer := Answer + '-';
  If boolean(W And GRP_X) Then
    Answer := Answer + 'x'
  Else
    Answer := Answer + '-';

  {GROUP}
  Answer := ' wrl:';
  If boolean(W And WRL_R) Then
    Answer := Answer + 'r'
  Else
    Answer := Answer + '-';
  If boolean(W And WRL_W) Then
    Answer := Answer + 'w'
  Else
    Answer := Answer + '-';
  If boolean(W And WRL_X) Then
    Answer := Answer + 'x'
  Else
    Answer := Answer + '-';
End;
{======================================================================}

End.