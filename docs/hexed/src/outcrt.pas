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
| outcrt.pas
|    output to the screen.  high level routines.
|
| History:
| Date       Author     Comment
| ----       ------     -------
| -- --- 94  G. Ollis	 created and developed program
============================================================================*)

{$I-}

Unit OutCRT;

INTERFACE

Uses
  Header;

{++PROCEDURES++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Procedure WriteScreen(Var D:DataType);
Procedure WriteCharStrip(Var D:DataType; y:Byte);
Procedure ShowDataStrip(Var D:DataType;  y:Byte);
Procedure DisplayData(Var D:DataType;  hp:HelpPointer;  x:Byte);
Procedure ErrorMsg(S:String);
Procedure InsertSpaces(Var D:DataType;  Var hp:HelpPointer);
Procedure DefaultOutPut;

{++FUNCTIONS+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Function Path2File(S:String):String;

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

IMPLEMENTATION

Uses
  CRT,CFG,DOS,VConvert,ViewU,FUTIL,WTD,Res,Cursor;

{------------------------------------------------------------------------}

Function Path2File(S:String):String;
Var Dir:DirStr;  Name:NameStr;  Ext:ExtStr;
Begin
  FSplit(S,Dir,Name,Ext);
  Path2File:=UpString(Name+Ext);
End;

{----------------------------------------------------------------------}

Procedure WriteScreen(Var D:DataType);
{This procedure writes the status bar (bottom line) and the info bar (just
 under the file lines) on to the screen }
Begin
  If AltMode=StdMode Then
    Window(1,25,80,25)
  Else
    Window(1,Resolution,80,Resolution);
  TextAttr:=ICFG.StatusVer;
  ClrScr;
  GotoXY(2,25);
  Write(' HEXED version ',versionnumber,' by Graham THE Ollis.');
  GotoXY(40,25);
  TextAttr:=ICFG.StatusFN;
  Write(' Editing file "'+Path2File(D.FN)+'"');
  TextAttr:=ICFG.StatusSave;
  If D.changes Then
    Write(' (*) ')
  Else
    Write(' ( ) ');
  TextAttr:=ICFG.StatusVer;
  Write(BinFileType[D.BFT]);
  If D.BFT=14 Then
    Write(' ',ExeFileType[D.ED.Tp]);
  GotoXY(1,1);
  Write(' ');
  Window(1,1,80,25);
  If AltMode<>StdMode Then
    Exit;
  GotoXY(1,5);
  TextAttr:=ICFG.StatusMid;
  Write('X:',(D.X+D.offset-1):DataOffSet,' $'+Long2Str((D.X+D.offset - 1))+' EOF:',D.EOF:DataOffSet,' $'+
    Long2Str(D.EOF)+ '  ');
  Write('Word:',Word(@D.D^[D.X]),6,' $'+Word2Str(Word(@D.D^[D.X])));
  ClrEol;
  GotoXY(77,WhereY);
  Case DefVarEd Of
    DefHex : Write('H');
    DefDec : Write('D');
  End;
  ClrEol;
End;

{------------------------------------------------------------------------}

Procedure WriteCharStrip(Var D:DataType; y:Byte);
Const
  StripSize1=12;
  StripSize2=14;
Var index:LongInt;  Answer:Array [-StripSize1..StripSize2] of Char;
Begin
  If (viewMode=1) Or (viewMode=2) Or (viewMode=4) Then
    Begin
      Writeln;
      Exit;
    End;
  for index:=-StripSize1 To StripSize2 Do
    If (index+D.X+D.offset>0) And (index+D.X+D.offset<=D.EOF) Then
      Answer[index]:=Chr(D.D^[index+D.X])
    Else
      Answer[index]:=' ';
  GotoXY(1,y+3);
  for index:=-StripSize1 To StripSize2 Do
    Begin
      TextAttr:=ICFG.Numbers;
      If D.X+D.offset+index=1 Then
        TextAttr:=ICFG.BOF_Color;
      If D.X+D.offset+index=D.EOF Then
        TextAttr:=ICFG.EOF_Color;
      If (D.X+D.offset+index>=D.BlockStart) And
         (D.X+D.offset+index<=D.BlockFinish) Then
        TextAttr:=ICFG.Block_Color;
      If index=0 Then
        TextAttr:=ICFG.Highlight;
      If (D.X+index+D.offset<=0) Or (D.X+index+D.offset>D.EOF) Then
        TextAttr:=ICFG.Lolight;
      If index=StripSize2 Then
        Begin
          If Byte(Answer[index])>32 Then
            Write(Answer[index],' ')
          Else
            Write('  ');
        End
      Else If Byte(Answer[index])>32 Then
        Write(Answer[index],'  ')
      Else
        Write('   ');
    End;
End;

{------------------------------------------------------------------------}

Procedure ShowDataStrip(Var D:DataType;  y:Byte);
Const
  StripSize1=12;
  StripSize2=14;
Var i,index:Longint;  X:Byte;
Begin
  X:=1;
  GotoXY(1,1);
  If (viewMode=0) Or (viewMode=1) Or (viewMode=4) Or (viewMode=5) Then
    for index:=D.X-StripSize1 To D.X+StripSize2 Do
      Begin
        TextAttr:=ICFG.Numbers;
        If index+D.offset=1 Then
          TextAttr:=ICFG.BOF_Color;
        If index+D.offset=D.EOF Then
          TextAttr:=ICFG.EOF_Color;
        If (index+D.offset>=D.BlockStart) And
           (index+D.offset<=D.BlockFinish) Then
          TextAttr:=ICFG.Block_Color;
        If index=D.X Then
          TextAttr:=ICFG.Highlight;
        GotoXY(X,Y+1);
        If (index+D.offset>0) And (index+d.offset<=D.EOF) Then
          Begin
            Write(D.D^[index]);
            If D.D^[index]<10 Then
              Write('  ')
            Else If D.D^[index]<100 Then
              Write(' ');
          End
        Else
          Begin
            TextAttr:=ICFG.LoLight;
            Write('   ');
          End;
        Inc(X,3);
      End;
  X:=1;
  If (viewMode=0) Or (viewMode=2) Or (viewMode=4) Or (viewMode=6) Then
    for index:=D.X-StripSize1 To D.X+StripSize2 Do
      Begin
        TextAttr:=ICFG.Numbers;
        If index+D.offset=1 Then
          TextAttr:=ICFG.BOF_Color;
        If index+D.offset=D.EOF Then
          TextAttr:=ICFG.EOF_Color;
        If (index+D.offset>=D.BlockStart) And
           (index+D.offset<=D.BlockFinish) Then
          TextAttr:=ICFG.Block_Color;
        If index=D.X Then
          TextAttr:=ICFG.Highlight;
        GotoXY(X,Y+2);
        If (index+D.offset>0) And (index+D.offset<=D.EOF) Then
          Write(Byte2Str(D.D^[index]),' ')
        Else
          Begin
            TextAttr:=ICFG.Lolight;
            Write('   ');
          End;
        X:=X+3;
      End;
  WriteCharStrip(D,y);
  GotoXY(37,y+4);
  TextAttr:=ICFG.Highlight;
  Write(#$18'  ');
End;

{------------------------------------------------------------------------}

Type
  WordPointer=^Word;

Procedure DisplayData(Var D:DataType;  hp:HelpPointer;  x:Byte);
Begin
  ShowDataStrip(D,x);
  If x<>0 Then
    Exit;
  GoToXY(1,5);
  TextAttr:=ICFG.StatusMid;
  GotoXY(3,WhereY);
  Write((D.X+D.offset-1):DataOffSet);
  GotoXY(WhereX+2,WhereY);
  Write(Long2Str(D.X+D.offset-1));
  GotoXY(WhereX+5,WhereY);
  Write((D.EOF-1):DataOffSet);
  GotoXY(WhereX+2,WhereY);
  Write(Long2Str(D.EOF-1));
  GotoXY(WhereX+7,WhereY);
  Write(WordPointer(@D.D^[D.X])^:6, ' $');
  Writeln(Word2Str(WordPointer(@D.D^[D.X])^));
End;

{------------------------------------------------------------------------}

Procedure ErrorMsg(S:String);
Begin
  OpenWindow(40-Length(S) div 2 -1,10,40+Length(S) div 2 +1,10,ICFG.Error);
  Write(' '+S);
  HideCursor;
  Pause;
  ShowCursor;
  CloseWindow;
End;

{------------------------------------------------------------------------}

Procedure InsertSpaces(Var D:DataType;  Var hp:HelpPointer);
Begin
  If viewMode=1 Then
    Begin
      GotoXY(1,2);
      ClrEol;
      GotoXY(1,3);
      ClrEol;
      If Secondary<>Nil Then
        Begin
          GotoXY(1,7);
          ClrEol;
          GotoXY(1,8);
          ClrEol;
        End;
    End;
  If viewMode=2 Then
    Begin
      GotoXY(1,1);
      ClrEol;
      GotoXY(1,3);
      ClrEol;
      If Secondary<>Nil Then
        Begin
          GotoXY(1,6);
          ClrEol;
          GotoXY(1,8);
          ClrEol;
        End;
    End;
  If viewMode=3 Then
    Begin
      GotoXY(1,1);
      ClrEol;
      GotoXY(1,2);
      ClrEol;
      If Secondary<>Nil Then
        Begin
          GotoXY(1,6);
          ClrEol;
          GotoXY(1,7);
          ClrEol;
        End;
    End;
  If viewMode=4 Then
    Begin
      GotoXY(1,3);
      ClrEol;
      If Secondary<>Nil Then
        Begin
          GotoXY(1,8);
          ClrEol;
        End;
    End;
  If viewMode=5 Then
    Begin
      GotoXY(1,2);
      ClrEol;
      If Secondary<>Nil Then
        Begin
          GotoXY(1,7);
          ClrEol;
        End;
    End;
  If viewMode=6 Then
    Begin
      GotoXY(1,1);
      ClrEol;
      If Secondary<>Nil Then
        Begin
          GotoXY(1,6);
          ClrEol;
        End;
    End;
  DefaultOutPut;
End;

{------------------------------------------------------------------------}

Procedure DefaultOutPut;
Begin
  Relocate(Data);
  If (Secondary<>Nil) Then
    Relocate(Secondary^);
  If (Secondary<>Nil) And Not Paused Then
    Begin
      Secondary^.X:=(Data.X+Data.offset)-Secondary^.offset;
      Relocate(Secondary^);
    End;
  DisplayData(Data,hp,0);
  If AutomaticTUse Then
    WriteTypeData(Data.D^[Data.X],Data);
  If (Secondary<>Nil) And (Secondary^.D<>Nil) Then
    DisplayData(Secondary^,hp,5);
  GotoXY(1,25);
End;

{======================================================================}

End.