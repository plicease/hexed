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
| cfg.pas
|   read config file for defaults.
|
| History:
| Date       Author     Comment
| ----       ------     -------
| -- --- 94  G. Ollis	 created and developed program
============================================================================*)

{$I-}

Unit CFG;

INTERFACE

Uses Crt;

Const
  {Mouse Constants}

  DefLeftButton=0;
  DefRightButton=1;
  DefCenterButton=2;
  DefMousePresent=FALSE;

Var
  LeftButton,  {Mouse setup}
  RightButton,
  CenterButton,

  SaveTextAttr:Byte;
  MousePresent:Boolean;

Const
  CFGFile='HEXED.CFG';

{++PROCEDURES++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{++FUNCTIONS+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Function HelpDir:String;
Function CheckOverflow(C:Char; P:Pointer):Boolean;

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

IMPLEMENTATION

Uses Dos,Ollis,CNT,VConvert,VOCTool,CMFTool;

Type
  Exclusive=Array [1..10] Of Byte;
  ExclusionType=Record
    D:Array [1..20] Of Exclusive;
    Num:Byte;
  End;

Var
  ExcludeReal:ExclusionType;
  ExcludeSing:ExclusionType;
  ExcludeDoub:ExclusionType;
  ExcludeExte:ExclusionType;
  ExcludeComp:ExclusionType;

{------------------------------------------------------------------------}
{FSplit}
Function HelpDir:String;
Var Path: PathStr; var Dir: DirStr; var Name: NameStr;
   var Ext: ExtStr;
Begin
  Path:=ParamStr(0);
  FSplit(Path,Dir,Name,Ext);
  If Dir[Length(Dir)]='\' Then
    Delete(Dir,Length(Dir),1);
  HelpDir:=Dir;
End;

{----------------------------------------------------------------------}

Function CheckOverflow(C:Char; P:Pointer):Boolean;
Var E2:^Exclusive;     { file fragment}
    E1:^ExclusionType; { exclude what? }
    I:Integer;
Begin
  Case UpCase(C) Of
    'R' : E1:=@ExcludeReal;
    'S' : E1:=@ExcludeSing;
    'D' : E1:=@ExcludeDoub;
    'X' : E1:=@ExcludeExte;
    'C' : E1:=@ExcludeComp;
  End;
  CheckOverflow:=False;
  E2:=P;
  For I:=1 To E1^.Num Do
    If ((E1^.D[I,1]=E2^[1]) Or (E1^.D[I,1]=0)) And
       ((E1^.D[I,2]=E2^[2]) Or (E1^.D[I,2]=0)) And
       ((E1^.D[I,3]=E2^[3]) Or (E1^.D[I,3]=0)) And
       ((E1^.D[I,4]=E2^[4]) Or (E1^.D[I,4]=0)) And
       ((E1^.D[I,5]=E2^[5]) Or (E1^.D[I,5]=0)) And
       ((E1^.D[I,6]=E2^[6]) Or (E1^.D[I,6]=0)) And
       ((E1^.D[I,7]=E2^[7]) Or (E1^.D[I,7]=0)) And
       ((E1^.D[I,8]=E2^[8]) Or (E1^.D[I,8]=0)) And
       ((E1^.D[I,9]=E2^[9]) Or (E1^.D[I,9]=0)) And
       ((E1^.D[I,10]=E2^[10]) Or (E1^.D[I,10]=0)) Then
      Begin
        CheckOverflow:=True;
        Exit;
      End;
End;

{----------------------------------------------------------------------}

Var
  Buff:^String;

Function GetString(Var F:Text):String;
Var
  S:String;
  I:Integer;
Begin
  If Buff^='' Then
    Readln(F,Buff^);

  I:=1;
  S:='';
  While (Buff^[I]<>' ') And (I<=Length(Buff^)) Do
    Begin
      S:=S+Buff^[I];
      Inc(I);
    End;

  Delete(Buff^,1,I);

  GetString:=S;
End;

{----------------------------------------------------------------------}

Function GetByte(Var F:TEXT):Byte;
Begin
  GetByte:=StrToInt(GetString(F));
End;

{----------------------------------------------------------------------}

Function UpString(S:String):String;
Var I:Integer;
Begin
  For I:=1 To Length(S) Do
    S[I]:=UpCase(S[I]);
  UpString:=S;
End;

{----------------------------------------------------------------------}

Procedure StOverflow(Var F:Text);
Var S:String; I:Integer;
Begin
  S:=UpString(GetString(F));
  If S='REAL' Then
    If ExcludeReal.Num<19 Then
      Begin
        Inc(ExcludeReal.Num);
        For I:=1 To 10 Do
          ExcludeReal.D[ExcludeReal.Num,I]:=GetByte(F);
      End
    Else
      Begin
        Write('Too many real exclusions');
        Repeat Until Readkey=#13;
        Writeln('.');
      End;

  If S='SING' Then
    If ExcludeSing.Num<19 Then
      Begin
        Inc(ExcludeSing.Num);
        For I:=1 To 10 Do
          ExcludeSing.D[ExcludeSing.Num,I]:=GetByte(F);
      End
    Else
      Begin
        Write('Too many single exclusions');
        Repeat Until Readkey=#13;
        Writeln('.');
      End;

  If S='DOUB' Then
    If ExcludeDoub.Num<19 Then
      Begin
        Inc(ExcludeDoub.Num);
        For I:=1 To 10 Do
          ExcludeDoub.D[ExcludeDoub.Num,I]:=GetByte(F);
      End
    Else
      Begin
        Write('Too many Double exclusions');
        Repeat Until Readkey=#13;
        Writeln('.');
      End;

  If S='EXTE' Then
    If ExcludeExte.Num<19 Then
      Begin
        Inc(ExcludeExte.Num);
        For I:=1 To 10 Do
          ExcludeExte.D[ExcludeExte.Num,I]:=GetByte(F);
      End
    Else
      Begin
        Write('Too many extended exclusions');
        Repeat Until Readkey=#13;
        Writeln('.');
      End;

  If S='COMP' Then
    If ExcludeComp.Num<19 Then
      Begin
        Inc(ExcludeComp.Num);
        For I:=1 To 10 Do
          ExcludeComp.D[ExcludeComp.Num,I]:=GetByte(F);
      End
    Else
      Begin
        Write('Too many comp exclusions');
        Repeat Until Readkey=#13;
        Writeln('.');
      End;

  Buff^:='';
End;

{----------------------------------------------------------------------}

Procedure ReadCFGFile(FileName:String);
Var F:Text; S:String;  Line:Integer;
Begin
  LeftButton:=DefLeftButton;
  RightButton:=DefRightButton;
  CenterButton:=DefCenterButton;
  MousePresent:=DefMousePresent;

  ExcludeReal.Num:=0;
  ExcludeSing.Num:=0;
  ExcludeDoub.Num:=0;
  ExcludeExte.Num:=0;
  ExcludeComp.Num:=0;
  Line:=1;
  If HelpDir='' Then
    Assign(F,FileName)
  Else
    Assign(F,HelpDir+'\'+FileName);
  Reset(F);
  If IOResult<>0 Then
    Exit;
  While Not EOF(F) Do
    Begin
      Repeat
        S:=UpString(GetString(F));
      Until (S<>'') Or (EOF(F));
      If (S[1]=';') Then
        Buff^:=''
      Else If S='SET' Then
        Begin
          S:=UpString(GetString(F));
          If S='OVERFLOW' Then
            StOverflow(F)
          Else If S='LFTBTN' Then
            Begin
              LeftButton:=GetByte(F);
              Buff^:='';
            End
          Else If S='CNTBTN' Then
            Begin
              CenterButton:=GetByte(F);
              Buff^:='';
            End
          Else If S='RTBTN' Then
            Begin
              RightButton:=GetByte(F);
              Buff^:='';
            End
          Else
            Begin
              WriteContactMsg;
              TextAttr:=LightGray;
              Writeln('Set command not known line #',line);
              Writeln('SET ',S);
              Halt;
            End;
        End
      Else If S='INIT' Then
        Begin
          S:=UpString(GetString(F));
          If S='MOUSE' Then
            Begin
              If InitMC Then
                Begin
                  MousePresent:=True;
                  ShowMC;
                End;
            End
          Else If S='SB' Then
            Begin
              S:=UpString(GetString(F));
              If S='DIGITAL' Then
                InitVocSB
              Else IF S='FM' Then
                InitCMFSB
              Else
                Begin
                  WriteContactMsg;
                  TextAttr:=LightGray;
                  Writeln('sound blaster initalization unknown.');
                  Writeln('INIT SB ',S);
                End;
            End
          Else
            Begin
              WriteContactMsg;
              TextAttr:=LightGray;
              Writeln('hardware initalization unknown.');
              Writeln('INIT ',S);
              Halt;
            End;
          Buff^:='';
        End
      Else
        Begin
          WriteContactMsg;
          TextAttr:=LightGray;
          Writeln('Configuration File error line #',line);
          Writeln(S);
          Halt;
        End;
      Line:=Line+1;
    End;
  Close(F);
End;

{======================================================================}

Begin
  New(Buff);
  Buff^:='';
  ReadCFGFile(CFGFile);
  Dispose(Buff);
End.
