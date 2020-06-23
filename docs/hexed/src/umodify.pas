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
| umodify.pas
|     user modification unit.  allows mr. user to change the data he sees
|     on the screen.  makes windows and cute looking shadows and everything.
|     reminds me of the smurfs.
|
| History:
| Date       Author     Comment
| ----       ------     -------
| -- --- 94  G. Ollis	 created and developed program
============================================================================*)

{$I-}

Unit UModify;

INTERFACE

Uses Header;

Var
  EscExit:Boolean;

{++PROCEDURES++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Procedure HexModify(Var D:Byte; i:longint;  Var Data:DataType);
Procedure CharModify(Var D:Byte; i:longint; Var Data:DataType);
Procedure NameChange(Var D:DataType);
Procedure SetX(Var X:Longint;  Var D:DataType);
Procedure WhatInsert(Var D:DataType);
Procedure DelByte(Var D:DataType);
Procedure WordModify(Var D:DataType);
Procedure LongModify(Var D:DataType);
Procedure SearchStr(Var D:DataType; B:Boolean);
Procedure InsertString(I:Integer; Var D:DataType);
Procedure SaveAs(Var D:DataType);

{++FUNCTIONS+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Function ReallyQuit(Var D:DataType):Boolean;
Function ReallyDispose(Var D:DataType):Boolean;
Function AskSlash:Word;
Function StringEdit(S:String; Places:Integer; Valid:CharacterSet):String;

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

IMPLEMENTATION

Uses
  ViewU,CFG,CRT,FUTIL,LowInt,VConvert,Ollis,DOS,OutCRT,Block,GShift,Cursor;

{----------------------------------------------------------------------}

Function ItoA(L:LongInt):String;
Var
  I:Integer;
  S:String;
Begin
  If DefVarEd=DefHex Then
    Begin
      If L=0 Then
        Begin
          ItoA:='$0';
          Exit;
        End;
      S:=Long2Str(L);
      I:=1;
      While S[I]='0' Do
        Delete(S,1,1);
      If S='' Then
        ItoA:='$0'
      Else
        ItoA:='$'+S;
    End
  Else
    ItoA:=IntToStr(L);
End;

{----------------------------------------------------------------------}

Function StringEdit(S:String; Places:Integer; Valid:CharacterSet):String;
Var
  SaveAttrib:Byte;
  C:Char;
  I:Integer;
  Save:String;
  WMn,WMx:Word;
  X1,Y1,X2:Byte;
Begin
  WMn:=WindMin;  WMx:=WindMax;
  Save:=S;

  X1:=Lo(WMn)+WhereX;
  Y1:=Hi(WMn)+WhereY;
  X2:=Lo(WMn)+WhereX+Places;
  Window(X1,Y1,X2+1,Y1);

  SaveAttrib:=TextAttr;

  I:=1;
  TextAttr:=ICFG.InputColor;
  Repeat
    Window(X1,Y1,X2-1,Y1);
    ClrScr;
    Window(X1,Y1,X2+1,Y1);
    Write(S);
    GotoXY(I,1);
    Repeat
      If Boolean(GetShiftByte And KBInsert) Then
        BigCursor
      Else
        ShowCursor;
    Until KeyPressed;
    C:=Readkey;
    If (C In Valid)  Then
      If NOT Boolean(GetShiftByte And KBInsert) Then
        Begin
          If Length(S)>=Places Then
            Delete(S,Length(S),1);
          Insert(C,S,I);
          Inc(I);
        End
      Else
        Begin
          S[I]:=C;
          Inc(I);
          If (I>Length(S)) And (Length(S)<Places) Then
            Inc(S[0]);
        End;
    If (C=#8) And (I>1) Then
      Begin
        Delete(S,I-1,1);
        Dec(I);
      End;
    If C=#0 Then
      Case Readkey Of
        #75 : Dec(I);
        #77 : Inc(I);
        #83 : Delete(S,I,1);
      End;
    If I>Length(S)+1 Then
      I:=Length(S)+1;
    If I<1 Then
      I:=1;
  Until (C=#13) Or (C=#27);

  If C=#13 Then
    Begin
      StringEdit:=S;
      EscExit:=FALSE;
    End
  Else
    Begin
      StringEdit:=Save;
      EscExit:=TRUE;
    End;
  TextAttr:=SaveAttrib;
  WindMin:=WMn;
  WindMax:=WMx;
  ShowCursor;
End;

{----------------------------------------------------------------------}

Procedure HexModify(Var D:Byte; i:longint;  Var Data:DataType);
Var S:String; Temp:Byte;
Begin
  OpenWindow(20,10,60,11,ICFG.MsgColor);
  Writeln('Enter new value for D.D[',i-1,']=',D);
  Write('> ');
  Temp:=StrToInt(StringEdit(ItoA(D),4,NumSet));
  CloseWindow;
  If Temp<>D Then
    Begin
      D:=Temp;
      ToggleChanges(Data);
    End;
End;

{------------------------------------------------------------------------}

Procedure CharModify(Var D:Byte; i:longint; Var Data:DataType);
Var C:Char;
Begin
  OpenWindow(20,10,60,11,ICFG.MsgColor);
  Writeln('Enter new value for D.D[',i-1,']=',D);
  Write('> ');
  C:=Readkey;
  D:=Ord(C);
  CloseWindow;
  ToggleChanges(Data);
End;

{------------------------------------------------------------------------}

Procedure NameChange(Var D:DataType);
Var S:StrType;
Begin
  S:=D.FN;
  OpenWindow(10,10,70,11,ICFG.MsgColor);
  Writeln('Enter new name from ',S,' to');
  Write('> ');
  S:=StringEdit(D.FN,58,FileSet);
  CloseWindow;

  If EscExit Then
    Exit;

  Rename(D.stream,S);
  If IOResult<>0 Then
    ErrorMsg('unable to reaname file.')
  Else
    D.FN:=S;
End;

{------------------------------------------------------------------------}

Procedure SetX(Var X:Longint;  Var D:DataType);
Var
  l:LongInt;
Begin
  OpenWindow(20,10,60,11,ICFG.MsgColor);
  Writeln('Enter position to change to.');
  Write('> ');
  L:=StrToInt(StringEdit(ItoA(X-1),11,NumSet));
  CloseWindow;
  X:=(l-D.offset+1);
  Relocate(D);
End;

{------------------------------------------------------------------------}

Procedure WhatInsert(Var D:DataType);
Var
  ni:LongInt;  {Number to insert}
  bi:Byte;  {Byte to insert}
Begin
  OpenWindow(20,10,60,11,ICFG.MsgColor);
  Writeln('Enter number of bytes to insert.');
  Write('> ');
  ni:=StrToInt(StringEdit('',12,NumSet));

  Window(20,10,60,11);
  If ni=0 Then
    Begin
      CloseWindow;
      Exit;
    End;
  ClrScr;
  Writeln('Enter the byte to insert ',ni,' time(s).');
  Write('> ');
  bi:=StrToInt(StringEdit('',4,NumSet));
  CloseWindow;
  DoInsert(D,ni,bi);
End;

{------------------------------------------------------------------------}

Function ReallyQuit(Var D:DataType):Boolean;
Var C:Char;
Begin
  If Not D.changes Then
    Begin
      ReallyQuit:=True;
      Exit;
    End;
  OpenWindow(15,10,65,13,ICFG.MsgColor);
  TextAttr:=ICFG.MsgLolight;
  Writeln('You have unsaved changes.  Do you want to quit?');
  TextAttr:=ICFG.MsgColor;
  Write('    S');
  TextAttr:=ICFG.MsgLolight;
  Writeln('ave file then quit');
  TextAttr:=ICFG.MsgColor;
  Write('    Y');
  TextAttr:=ICFG.MsgLolight;
  Writeln('es quit without saving');
  TextAttr:=ICFG.MsgColor;
  Write('    N');
  TextAttr:=ICFG.MsgLolight;
  Write('o continue with HEXED');
  HideCursor;
  Repeat
    C:=UpCase(Readkey);
  Until C in ['S','Y','N'];
  ShowCursor;
  Case C Of
    'S' : Begin
            SaveSegment(D);
            ReallyQuit:=True;
          End;
    'Y' : ReallyQuit:=True;
    'N' : ReallyQuit:=False;
  End;
  CloseWindow;
End;

{------------------------------------------------------------------------}

Procedure DelByte(Var D:DataType);
Var index:LongInt;   Error:Integer;
Begin
  If (D.EOF<imagesize-4) Then
    Begin
      For index:=D.X+D.offset To D.EOF Do
        D.D^[index]:=D.D^[index+1];
      Dec(D.EOF);
      ToggleChanges(D);
    End
  Else
    DeleteBlock(D,D.X+D.offset,1);
End;

{------------------------------------------------------------------------}

Procedure WordModify(Var D:DataType);
Var
  W:^Word;
  Temp:Word;
Begin
  W:=@mem[Seg(D.D^[D.X]):Ofs(D.D^[D.X])];
  OpenWindow(16,10,61,11,ICFG.MsgColor);
  Writeln('Enter in new value for ',D.X+D.offset-1,'.');
  Write('> ');
  Temp:=StrToInt(StringEdit(ItoA(W^),6,NumSet));
  CloseWindow;
  If Temp<>W^ Then
    Begin
      W^:=Temp;
      ToggleChanges(D);
    End;
End;

{------------------------------------------------------------------------}

Procedure LongModify(Var D:DataType);
Var
  W:^LongInt;
  Temp:LongInt;
Begin
  W:=@mem[Seg(D.D^[D.X]):Ofs(D.D^[D.X])];
  OpenWindow(10,10,70,11,ICFG.MsgColor);
  Writeln('Enter in new value for ',D.X+D.offset-1,'; old value is ',D.D^[D.X],'.');
  Write('> ');
  Temp:=StrToInt(StringEdit(ItoA(W^),11,NumSet));
  CloseWindow;
  If Temp<>W^ Then
    Begin
      W^:=Temp;
      ToggleChanges(D);
    End;
End;

{------------------------------------------------------------------------}

Type
  StringPointer=^String;

Procedure FastSearch(Var D:DataType);
Var
  Buff:binaryImagePointer;
  I:LongInt;
  Count,N,Sz,J:Word;
  B:Boolean;
Begin

  If MaxAvail<700 Then
    Exit;

  Sz:=MaxAvail;
  GetMem(Buff,Sz);

  Seek(D.Stream,D.X+D.Offset);
  I:=D.X+D.Offset;

  OpenWindow(10,10,70,10,ICFG.MsgColor);
  Write(D.EOF:30,' $',Long2Str(D.EOF),' NEW');

  HideCursor;
  While NOT EOF(D.stream) And NOT KeyPressed DO
    Begin
      BlockRead(D.Stream,Buff^,Sz,Count);
      GotoXY(1,1);
      Write(I:11,' $',Long2Str(I));
      GotoXY(50,1);
      Write(((I*100) div D.EOF):3,'%');

      For N:=1 To Count Do
        If Buff^[N]=Byte(SearchFor[1]) Then
          Begin
            B:=True;
            For J:=1 To Byte(SearchFor[0]) Do
              If Buff^[N+J]<>Byte(SearchFor[J+1]) Then
                B:=False;
            If B Then
              Begin
                D.X:=(I+N)-D.offset;
                FreeMem(Buff,Sz);
                ShowCursor;
                CloseWindow;
                Exit;
              End;
          End;

      Inc(I,count);
    End;
  ShowCursor;

  CloseWindow;

  FreeMem(Buff,Sz);
End;

{------------------------------------------------------------------------}

Procedure SearchStr(Var D:DataType; B:Boolean);
Var index:LongInt;
Begin
  If B Then
    Begin
      OpenWindow(20,10,60,11,ICFG.MsgColor);
      Writeln('Enter search string.');
      Write('> ');
      SearchFor:=StringEdit(SearchFor,37,NormSet);
      CloseWindow;
    End;
  If D.EOF<imagesize-80 Then
    Begin
      For index:=D.X+1 To imagesize-80 Do
        If (D.D^[index]=Ord(SearchFor[1])) And  IfStrThere(D,index,SearchFor) Then
          Begin
            D.X:=index-D.offset;
            Exit;
          End;
    End
  Else
    FastSearch(D);
End;

{------------------------------------------------------------------------}

Function ReallyDispose(Var D:DataType):Boolean;
Var C:Char;
Begin
  If Not D.changes Then
    Begin
      ReallyDispose:=True;
      Exit;
    End;
  OpenWindow(9,10,71,13,ICFG.MsgColor);
  Writeln('You have unsaved changes.  Do you want to dispose of the file?');
  TextAttr:=ICFG.MsgColor;
  Write('    S');
  TextAttr:=ICFG.MsgLoLight;
  Writeln('ave file then dispose');
  TextAttr:=ICFG.MsgColor;
  Write('    Y');
  TextAttr:=ICFG.MsgLoLight;
  Writeln('es dispose without saving');
  TextAttr:=ICFG.MsgColor;
  Write('    N');
  TextAttr:=ICFG.MsgLoLight;
  Write('o continue with disposing');
  HideCursor;
  Repeat
    C:=UpCase(Readkey);
  Until C in ['S','Y','N'];
  ShowCursor;
  Case C Of
    'S' : Begin
            SaveSegment(D);
            ReallyDispose:=True;
          End;
    'Y' : ReallyDispose:=True;
    'N' : ReallyDispose:=False;
  End;
  CloseWindow;
End;

{------------------------------------------------------------------------}

Function AskSlash:Word;
Begin
  OpenWindow(20,10,60,11,ICFG.MsgColor);
  Writeln('Enter Number of commands to repeat.');
  Write('> ');
  AskSlash:=StrToInt(StringEdit('',6,NumSet));
  CloseWindow;
End;

{------------------------------------------------------------------------}

Procedure InsertString(I:Integer; Var D:DataType);
Var S:String;  counter:Word;
Begin
  OpenWindow(10,10,70,11,ICFG.MsgColor);
  Writeln('Enter String to insert.');
  Write('> ');
  S:=StringEdit('',57,NormSet);
  If (I=1) And (S<>'') Then
    Begin
      For counter:=1 To Length(S) Do
        D.D^[D.X+counter-1]:=Ord(S[counter]);
      D.D^[D.X+counter]:=0;
    End;
  If (I=2) And (S<>'') Then
    Begin
      For counter:=1 To Length(S) Do
        D.D^[D.X+counter-1]:=Ord(S[counter]);
    End;
  If (I=3) And (S<>'') Then
    Begin
      For counter:=0 To Length(S) Do
        D.D^[D.X+counter]:=Ord(S[counter]);
    End;
  CloseWindow;
End;

{------------------------------------------------------------------------}

Procedure SaveAs(Var D:DataType);
Var S:String;  F:FILE;  Error:Integer;  count,wtn:Word;
Begin
  OpenWindow(10,10,70,11,ICFG.MsgColor);
  Writeln('Enter new file name. (enter to quit)');
  Write('> ');
  S:=StringEdit(D.FN,57,FileSet);
  Window(10,10,70,11);

  If EscExit Then
    Exit;

  TextAttr:=ICFG.MsgColor;
  ClrScr;
  Assign(F,S);
  Reset(F,1);
  If IOResult=0 Then
    Begin
      Writeln('Do you wish to overwrite that file? [Y|N]');
      If UpCase(Readkey)='N' Then
        Begin
          CloseWindow;
          Exit;
        End;
      ClrScr;
    End;
  CloseWindow;
  ReWrite(F,1);
  Error:=IOResult;
  If Error<>0 Then
    Begin
      ErrorMsg('Error opening new file for read');
      Exit;
    End;
  If NOT SaveTemp(D.D^,0) Then
    Begin
      ErrorMsg('Error opening temp file "HEXED.TMP"');
      Close(F);
      Erase(F);
      Exit;
    End;
  Seek(D.stream,0);
  While Not EOF(D.stream) Do
    Begin
      BlockRead(D.stream,D.D^,imagesize,count);
      BlockWrite(F,D.D^,count,wtn);
      If count<>wtn Then
        Begin
           ErrorMsg('Error bytes read<>bytes written');
           Close(F);
           Erase(F);
           RestoreTemp(D.D^,0);
           Exit;
        End;
    End;
  RestoreTemp(D.D^,0);
  Close(F);
  Close(D.stream);
  D.FN:=S;
  Assign(D.stream,S);
  Reset(D.stream,1);
  SaveSegment(D);
  WriteScreen(D);
End;

{======================================================================}

End.