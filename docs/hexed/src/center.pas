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
| center.pas
|   main function.  this is the center of hexed and everything is called
|   from here.
|
| History:
| Date       Author     Comment
| ----       ------     -------
| -- --- 94  G. Ollis	 created and developed program
============================================================================*)

{$I-}
Unit Center;

INTERFACE

{++PROCEDURES++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Procedure Main;

{++FUNCTIONS+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Function GetFLINFileName(I:Integer):String;
Function IsFLIN(S:String):Word;

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Var
  Seek_To:LongInt;

IMPLEMENTATION

Uses
  Ollis,Dos,ChFile,ViewU,Header,FUtil,CNT,OUTCRT,UModify,LowInt,VConvert,
  Help,WTD,Second,Search,BinEd,MouseIn,KeyIn,Block,PrintU,CFG,CRT,Color;

Var
  Stdin:TEXT;

{----------------------------------------------------------------------}

Function GetFLINFileName(I:Integer):String;
Var
  S:String;
  C:Char;
Begin
  Seek_To:=0;
  S:='';
  If I=1 Then
    Readln(Stdin,S)
  Else If I=2 Then
    Begin
      Repeat
        Read(Stdin,C);
        If Not (C In [' ',#9,#13,#10]) Then
          S:=S+C;
      Until C In [' ',#9,#13,#10];
      Readln(Stdin,Seek_To);
    End;

  GetFLINFileName:=S;
End;

{----------------------------------------------------------------------}

{
 0 = no  FLIN
 1 = std FLIN
 2 = ext FLIN
}
Function IsFLIN(S:String):Word;
Begin
  If (S[1]='-') And (UpCase(S[2])='I') Then
    IsFLIN:=1
  Else If (S[1]='-') And (UpCase(S[2])='O') Then
    IsFLIN:=2
  Else
    IsFlin:=0;
End;

{----------------------------------------------------------------------}

Function FileFound(Str:String):Boolean;
Var S:SearchRec;
Begin
  FindFirst(Str,AnyFile,S);
  If DosError=0 Then
    FileFound:=True
  Else
    FileFound:=False;
End;

{------------------------------------------------------------------------}

Function OneFile(Var Mask:String; Var S:SearchRec):Boolean;
Begin
  FindFirst(Mask,AnyFile,S);
  If DosError<>0 Then
    Begin
      OneFile:=False;
      Exit;
    End;
  FindNext(S);
  If DosError=0 Then
    OneFile:=False
  Else
    OneFile:=True;
End;

{------------------------------------------------------------------------}

Function IsOneFile(Mask:String; Var FName:StrType):Boolean;
Var
  S:SearchRec;
  Dir:DirStr;
  Name:NameStr;
  Ext:ExtStr;
Begin
  IsOneFile:=OneFile(Mask,S);
  FSplit(Mask,Dir,Name,Ext);
  FName:=Dir+S.Name;
End;

{------------------------------------------------------------------------}

Procedure CheckParam;
Var I:Integer;
Begin
  AutomaticTUse:=FALSE;
  For I:=1 To ArrayLength Do
    FArray[I]:=0;
  NumElement:=1;
  CurrentElement:=1;
  If (ParamStr(1)='-h') Or (ParamStr(1)='-H') Or (ParamStr(1)='-?') Then
    Begin
      HideMC;
      Write(' GUTIL ');
      Writeln('program HEXED by Graham Ollis.');
      Writeln(' version ',versionnumber);
      Writeln;
      Write('  HEXED ');
      Write('<first file name | -i | -o>');
      Writeln(' <secondary file name | -i | -o>');
      Writeln('  HEXED -c');
      Writeln;
      Writeln('HEXED (HEXadecimal EDitor) view/edit one or two binary files.');
      Writeln;
      Writeln('options available:');
      Writeln('-I   Read FLIN files.');
      Writeln('-O   Read Extended FLIN files.');
      WRiteln('-C   Color configeration');
      Halt;
    End;
End;

{------------------------------------------------------------------------}

Procedure CheckSecondary;
Var
  FN:StrType;
Begin
  If ParamStr(2)<>'' Then
    If IsFLIN(ParamStr(2))<>0 Then
      AdditionalFile(Data,GetFLINFileName(IsFLIN(ParamStr(2))),True)
    Else
      AdditionalFile(Data,ParamStr(2),IsOneFile(ParamStr(2),FN));
End;

{========================================================================}

Procedure Main;
Begin
  SaveTextAttr:=TextAttr;
  C1:=#0;  C2:=#0;
  If tmptxtScreen=Nil Then
    Begin
      Writeln('Error, not enough memory for temporary text screen.');
      Halt;
    End;
  If screen=NIL Then
    Begin
      Writeln('Error, not in a text made HEXED can use');
      Halt;
    End;
  CheckParam;
  Paused:=False;
  Hp:=Nil;
  Secondary:=Nil;

  If (ParamStr(1)='-C') Or (ParamStr(1)='-c') Then
    Begin
      AltMode:=$FF;
      ConfigureColor;
      WriteContactMsg;
      Halt;
    End;

  With Data Do
    Begin
      If IsFLIN(ParamStr(1))=1 Then
        Begin
          FN:=GetFLINFileName(IsFLIN(ParamStr(1)));
          FilePath:='*.*';
        End
      Else If IsFLIN(ParamStr(1))=2 Then
        Begin
          FN:=GetFLINFileName(IsFLIN(ParamStr(1)));
          FilePath:='*.*';
        End
      Else If (ParamStr(1)<>'') And (IsOneFile(ParamStr(1),FN)) Then
        FilePath:=FN
      Else
        Begin
          If ParamStr(1)<>'' Then
            FilePath:=ParamStr(1)
          Else
            FilePath:='*.*';
          FN:=ChooseFileName('HEXED version '+versionnumber,'Load File',FilePath);
          If FN = '' Then
            Begin
              WriteContactMsg;
              Halt;
            End;
        End;
      CheckSecondary;
      TextAttr:=Blue *$10 or (TextAttr and $0F);
      D:=Nil;
      changes:=False;
      BlockStart:=-1;
      BlockFinish:=-2;
    End;
  LoadFile(Data);
  TextAttr:=ICFG.LoLight;
  ClrScr;
  DrawMenu;
  WriteHelp(hp);
  CheckFileType(Data);
  WriteScreen(Data);
  TextAttr:=ICFG.LoLight;
  Writeln;
  Writeln('Press F6 to change the view mode.  Press ^C to change colors.');
  Repeat
    DefaultOutPut;
    Commands(Data,hp);
  Until 5=6;
End;

{======================================================================}

Begin
  Assign(Stdin,'');
  Reset(Stdin);
End.