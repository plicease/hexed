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
| pcx.pas
|    module for viewing pcx files.  pcx is a horrible format, but really
|    easy to parse.  this module is independant of the rest of hexed.
|
| History:
| Date       Author     Comment
| ----       ------     -------
| -- --- 94  G. Ollis	 created and developed program
============================================================================*)

{$I-,O+,F+}

Unit PCX;

INTERFACE

Uses Ollis;

{++PROCEDURES++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{++FUNCTIONS+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Function DrawPCXMem(Var buff:Pointer; Var p:Pal):String;

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

IMPLEMENTATION

Uses Crt;

Type
  pcxHeader=Record
    Manufacturer,          (* should be set to $A0 *)
    version,               (* version number.  We suport 5 only *)
    encoding,              (* defines compression mode.  1 is the only known *)
    bits_per_pixel:Byte;   (* # of bits per pixel.  should be 8 *)
    X1,Y1,X2,Y2,           (* defines location an size of image *)
    hres,vres:Integer;     (* resolution of screen saved on.  useless *)
    EGAPalette:Array [1..48] of Byte;  (*EGA palette.  ignore *)
    reserved,
    color_planes:Byte;
    bytes_per_line,
    palette_type:Integer;
    filler:Array [1..58] of Byte;
  End;

{--------------------------------------------------------------------}

Function InBox(x,y,X1,Y1,X2,Y2:Integer):Boolean;
Begin
  If (x>=X1) And (x<=X2) And (y>=Y1) And (y<=Y2) Then
    InBox:=True
  Else
    InBox:=False;
End;

{--------------------------------------------------------------------}

Procedure CheckPCXHeader(S:String;  Var errstr:String; h:pcxHeader;  szc:Boolean);
Begin
  errstr:='';
  With h Do
    Begin
      If (manufacturer<>10) Then
        errstr:='manufacturer byte != 10 $0A';
      If (encoding<>1) Then
        errstr:='encoding byte != 1';
      If bits_per_pixel<>8 Then
        errstr:='is not a 256 color PCX file.';
      If szc Then
        If Not (InBox(X1,Y1,0,0,MaxX,MaxY)) Or
           Not (InBox(X2,Y2,0,0,MaxX,MaxY)) Then
          errstr:='does not fit in a '+IntToStr(MaxX+1)+
                       'x'+IntToStr(MaxY+1)+' res screen';
     End;
End;

{--------------------------------------------------------------------}

Type
  BytePointer=^Byte;

Procedure IncPtr(Var ofst:BytePointer;  Var b:Byte);
Begin
  ofst:=@mem[Seg(ofst^):Ofs(ofst^)+1];
  b:=ofst^;
End;

{--------------------------------------------------------------------}

Function DrawPCXMem(Var buff:Pointer; Var p:Pal):String;
Var h:^PCXHeader;  ofst:BytePointer;  b:Byte;  x,y:Word;  I:Integer;
    errstr:String;
Begin
  DrawPCXMem:='Unknown error.';
  h:=buff;
  CheckPCXHeader('MEMORY PCX FILE',errstr,h^,TRUE);
  If (errstr<>'') Then
    Begin
      DrawPCXMem:=errstr;
      Exit;
    End;
  ofst:=@h^.filler[58];
  x:=h^.X1;  y:=h^.Y1;
  Repeat
    Repeat
      IncPtr(ofst,b);
      If (b And $C0)=$C0 Then
        Begin
          I:=b And $3F;
          IncPtr(ofst,b);
          For I:=I DownTo 1 Do
            Begin
              GraphAcc1^[y,x]:=b;
              Inc(x);
            End;
        End
      Else
        Begin
          GraphAcc1^[y,x]:=b;
          Inc(x);
        End;
    Until x>h^.X2;
    y:=y+1;
    x:=h^.X1;
    If KeyPressed Then
      Begin
        DrawPCXMem:='';
        Exit;
      End;
  Until y>h^.Y2;
  IncPtr(ofst,b);
  If b=$0C Then
    For I:=0 To $FF Do
      With p[I] Do
        Begin
          IncPtr(ofst,b);
          Red:=b shr 2;
          IncPtr(ofst,b);
          Green:=b shr 2;
          IncPtr(ofst,b);
          Blue:=b shr 2;
        End;
  DrawPCXMem:='';
End;

{======================================================================}

End.