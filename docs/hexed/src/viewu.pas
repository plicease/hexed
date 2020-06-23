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
| viewu.pas
|  formated view unit.  this is what happens when you press the V or ^V keys.
|
| History:
| Date       Author     Comment
| ----       ------     -------
| -- --- 94  G. Ollis	 created and developed program
============================================================================*)

{$I-}

Unit VIEWU;

INTERFACE

Uses
  CMFTool;

Type
  ScreenBufferType=Array [1..25*80*2] of Byte;
  ScreenBufferPointer=^ScreenBufferType;

  FileIDType=Array [0..3] Of Char;
  CMFHeadType=Record
    FileID:FileIDType;
    Version,
    InstrumentOffset,
    MusicOffset,
    TicksPerQuarterNote,
    ClockTicksPerSecond,
    TitleOffset,
    ComposerOffset,
    RemarksOffset:Word;
    ChannelInUse:Array [0..$F] Of Byte;
    NumInstruments,
    BasicTempo:Word;
  End;
  SBIFileType=Record
    FileID:FileIDType;
    Name:Array [$4..$23] Of Char;
    SoundData:Array [$24..$33] Of Byte;
  End;
  FileDescriptorType=Array [0..$13] Of Char;
  VOCHeadType=Record
    FID:FileDescriptorType;
    DataOffSet,
    Version,
    FIDCode:Word;
  End;

Var
  tmptxtscreen:ScreenBufferPointer;
  screen:ScreenBufferPointer;
  SaveScreen:Boolean;

{++PROCEDURES++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Procedure VIEW(Var F:File; FN:String; ft:Byte; B:Boolean);
Procedure SvTextScreen;
Procedure RsTextScreen;
Procedure DrawWindow(x1,y1,x2,y2,c:Byte);
Procedure OpenWindow(x1,y1,x2,y2,c:Byte);
Procedure CloseWindow;
Procedure Pause;

{++FUNCTIONS+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Function Choice(Num:Integer; C1,C2,C3,C4,C5,C6:String; X1,Y1,X2:Byte):Integer;

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

IMPLEMENTATION

Uses
  Ollis,Crt,PCX,GIF,CFG,VOCTool,Dos,IBK,Header,OutCrt,Cursor;

{----------------------------------------------------------------------}

(* BIOS function calls *)

Function BIOSGetMode:Byte;
Var
  B:Byte;
Begin
  asm
    mov ah,0fh
    int 10h
    mov B,al
  End;
  BIOSGetMode:=B;
End;

{----------------------------------------------------------------------}

Procedure BIOSSetMode(B:Byte);
Begin
  asm
    mov ah,00h
    mov al,B
    int 10h
  End;
End;

{----------------------------------------------------------------------}

Function ViewPCX(Var F:File):String;
Type
  SegmentType=Array [1..$FFFF] Of Byte;
Var
  pl:Pal;
  errstr:String;
  Tmp:^SegmentType;
  P:Pointer;
Begin
  If MemAvail<SizeOf(SegmentType) Then
    Begin
      ViewPCX:='Not enough memory for read buffer';
      Exit;
    End;
  New(Tmp);
  P:=Tmp;

  Seek(F,$0);
  BlockRead(F,Tmp^,SizeOf(SegmentType));

  InitGraph(stdVGA);
  errstr:=DrawPCXMem(P,pl);
  SetPal(pl);
  If errstr='' Then
    Pause;
  UnInitGraph;
  ViewPCX:=errstr;
  Dispose(Tmp);
End;

{----------------------------------------------------------------------}


Function ViewGIF(Var F:File; B:Boolean):String;
Var pl:Pal;   errstr:String;  SaveMode:Byte;
Begin
  SaveMode:=BIOSGetMode;
  errstr:=DrawGIFDsk(F,pl);
  SetPal(pl);
  If errstr='' Then
    Begin
      Write(^G);
      Pause;
    End;
  BIOSSetMode(SaveMode);
  ViewGIF:=errstr;
End;

{----------------------------------------------------------------------}

Function ViewIMG(Var F:File; B:Boolean):String;
Var errstr:String;  SaveMode:Word;  p:Pal;
Begin
  SaveMode:=BIOSGetMode;
  errstr:=DrawIMGMem(F);
  BIOSSetMode(SaveMode);
  ViewIMG:=errstr;
End;

{----------------------------------------------------------------------}

Procedure ViewPAL(Var F:File);
Var pl:Pal;  x,y:Integer;
Begin
  Seek(F,$0);
  BlockRead(F,pl,SizeOf(pl));
  InitGraph(stdVGA);
  For x:=0 To 255 Do
    For y:=0 To MaxY Do
      GraphAcc1^[y,x]:=x;
  SetPal(pl);
  Pause;
  UnInitGraph;
End;

{----------------------------------------------------------------------}

Procedure ViewCMF(Var F:File; FN:String);
Var
  CMFHead:CMFHeadType;
  I:Integer;
  SP:Boolean;
  P:Pointer;
Const
  FID:FileIDType='CTMF';
Begin
  SP:=False;
  If CMFDriverInstalled Then
    Begin
      SP:=CMFGetSongBuffer(P,FN);
      If SP Then
        SP:=CMFPlaySong(P);
    End;
  Seek(F,$00);
  BlockRead(F,CMFHead,SizeOf(CMFHeadType));
  OpenWindow(10,7,70,17,ICFG.MsgColor);
  With CMFHead Do
    Begin
      Write('           ');
      If (FileID=FID) Then
        Writeln('CMF file detect TRUE (File ID=''CTMF'')')
      Else
        Writeln('CMF file detect FALSE (File ID!=''CTMF'')');
      Writeln('CMF file format version ',Hi(Version),'.',Lo(Version));
      Writeln('Ticks per quarter note (one beat)    : ',TicksPerQuarterNote);
      Writeln('Clock ticks per second               : ',ClockTicksPerSecond);
      Write('Music title                          : ');
      If TitleOffset=0 Then
        Writeln('NONE')
      Else
        Writeln('PRESENT');
      Write('Composer                             : ');
      If ComposerOffset=0 Then
        Writeln('NONE')
      Else
        Writeln('PRESENT');
      Write('Remarks                              : ');
      If RemarksOffset=0 Then
        Writeln('NONE')
      Else
        Writeln('PRESENT');
      Writeln('Number of instruments                : ',NumInstruments);
      Writeln('Basic Tempo                          : ',BasicTempo);
      Write('Channel in use table (');
      For I:=0 To $E Do
        Write(ChannelInUse[I],',');
      Writeln(ChannelInUse[$F],')');
      PrintCMFErrMessage;
      HideCursor;
    End;
  Pause;
  ShowCursor;
  CloseWindow;
  If SP Then
    Begin
      CMFStopSong;
      CMFFreeSongBuffer(P);
    End;
End;

{----------------------------------------------------------------------}

Procedure WriteIName(I:Integer;  N:IBKInstrumentName);
Var J:Integer;
Begin
  Write(I:3);
  For J:=0 To $8 Do
    If N[J] <> #0 Then
      Write(N[J])
    Else
      Write(' ');
End;

{----------------------------------------------------------------------}

Procedure ViewIBK(FN:String);
Var
  IBK:IBKType;
  F:IBKFile;
  I:Integer;
Begin
  Assign(F,FN);
  Reset(F);
  Read(F,IBK);
  Close(F);
  OpenWindow(3,3,78,23,ICFG.MsgColor);
  With IBK Do
    Begin
      For I:=1 To 126 Do
        Begin
          WriteIName(I,Name[I]);
          If (I mod 6=0) And (I <> 126) Then
            Writeln;
        End;
      HideCursor;
      Pause;
      ShowCursor;
      TextAttr:=ICFG.MsgColor;
      Writeln;
      WriteIName(127,Name[127]);
      WriteIName(128,Name[128]);
      HideCursor;
    End;
  Pause;
  ShowCursor;
  CloseWindow;
End;

{----------------------------------------------------------------------}

Procedure ViewSBI(Var F:File);
Var
  h:SBIFileType;
  I:Integer;
Const
  FID='SBI'#26;
Begin
  Seek(F,$00);
  BlockRead(F,h,SizeOf(SBIFileType));
  OpenWindow(13,9,67,10,ICFG.MsgColor);
  With h Do
    Begin
      Write('       ');
      If FileID=FID Then
        Writeln('SBI file detect TRUE (File ID = ''SBI''#26)')
      Else
        Writeln('SBI file detect FALSE (File ID != ''SBI''#26)');
      Write(' Instrument name : "');
      I:=$4;
      While (Name[I]<>#0) And (I<=$23) Do
        Begin
          Write(Name[I]);
          I:=I+1;
        End;
      Write('"');
      HideCursor;
    End;
  Pause;
  ShowCursor;
  CloseWindow;
End;

{----------------------------------------------------------------------}

Procedure ViewVOC(Var F:File; FN:String);
Var
  h:VOCHeadType;
  I:Integer;
  P:Pointer;
  SP:Boolean;
Const
  CVFFID='Creative Voice File'#$1A;
Begin
  SP:=False;
  If VOCDriverInstalled Then
    Begin
      SP:=VOCGetBuffer(P,FN);
      If SP Then
        VOCOutput(P);
    End;
  Seek(F,$00);
  BlockRead(F,h,SizeOf(VOCHeadType));
  OpenWindow(10,9,70,13,ICFG.MsgColor);
  With h Do
    Begin
      If FID=CVFFID Then
        Writeln('VOC file detect TRUE (File ID = ''Creative Voice File''#1A)')
      Else
        Writeln('VOC file detect FALSE (File ID != ''Creative Voice File''#1A)');
      Writeln('Data Offset    : ',DataOffSet);
      Writeln('Version        : ',Hi(Version),'.',Lo(Version));
      Writeln('File ID Code   : ',FIDCode);
      PrintVOCErrMessage;
    End;
  HideCursor;
  Pause;
  ShowCursor;
  CloseWindow;
  If SP Then
    Begin
      VOCStop;
      VOCFreeBuffer(P);
    End;
End;

{----------------------------------------------------------------------}

Procedure VIEW(Var F:File; FN:String; ft:Byte; B:Boolean);
Var errstr:String;
Begin
  If (ft=2) Then
    Begin
      errstr:=ViewPCX(F);
      If (errstr<>'') Then
        ErrorMsg(ErrStr);
    End;
  If (ft=3) Then
    ViewPal(F);
  If (ft=4) Then
    ViewCMF(F,FN);
  If (ft=5) Then
    ViewSBI(F);
  If (ft=6) Then
    Begin
      errstr:=ViewGIF(F,B);
      If (errstr<>'') Then
        ErrorMsg(ErrStr);
    End;
  If (ft=7) Then
    ViewVOC(F,FN);
  If (ft=8) Then
    Begin
      errstr:=ViewIMG(F,B);
      If (errstr<>'') Then
        ErrorMsg(ErrStr);
    End;
  If (ft=11) Then
    ViewIBK(FN);
End;

{----------------------------------------------------------------------}
Procedure SvTextScreen;
Begin
  If tmptxtscreen<>Nil Then
    tmptxtscreen^:=screen^;
End;

{----------------------------------------------------------------------}

Procedure RsTextScreen;
Begin
  If tmptxtscreen<>Nil Then
    screen^:=tmptxtscreen^;
End;

{----------------------------------------------------------------------}

Procedure DrawWindow(x1,y1,x2,y2,c:Byte);
Var x,y:Byte;
Begin
  For x:=x1-1+1 To x2+1+1 Do
    For y:=y1-1 To y2+1 Do
      If x < 80 Then
        mem[$B800:(y*80+x)*2+1]:=DarkGray;
  Window(x1-1,y1-1,x2+1,y2+1);
  TextAttr:=c; ClrScr;
  Window(x1-1,y1-1,x2+1,y2+2);
  Write(#$DA);
  For x:=x1 To x2 Do
    Write(#$C4);
  Write(#$BF);
  For y:=y1 To y2 Do
    Begin
      Write(#$B3);
      For x:=x1 To x2 Do
        Write(' ');
      Write(#$B3);
    End;
  Write(#$C0);
  For x:=x1 To x2 Do
    Write(#$C4);
  Write(#$D9);
  Window(x1,y1,x2,y2);
End;

{----------------------------------------------------------------------}

Procedure OpenWindow(x1,y1,x2,y2,c:Byte);
Begin
  If SaveScreen Then
    svTextScreen;
  DrawWindow(x1,y1,x2,y2,c);
End;

{----------------------------------------------------------------------}

Procedure CloseWindow;
Begin
  rsTextScreen;
  Window(1,1,80,25);
End;

{----------------------------------------------------------------------}

Procedure Pause;
Begin
  Repeat Until (KeyPressed And (Readkey=#13)) Or (MousePresent And (
    (MouseButtonPressed(LeftButton)) Or
    (MouseButtonPressed(RightButton)) Or
    (MouseButtonPressed(CenterButton))));
End;

{----------------------------------------------------------------------}

Procedure SetPointer2TextScreen(Var S:ScreenBufferPointer);
Var
  Reg:Registers;
Begin
  Reg.AH:=$F;
  Intr($10,Reg);
  If Reg.AL=$3 Then
    S:=@mem[$B800:$0000]
  Else If Reg.AL=$7 Then
    S:=@mem[$B000:$0000]
  Else
    S:=NIL;
End;

{----------------------------------------------------------------------}

Function Choice(Num:Integer;  C1,C2,C3,C4,C5,C6:String;  X1,Y1,X2:Byte):Integer;
Var C:Char; I:Integer;  CI:Integer;
Begin
  Window(X1,Y1,X2,Y1+Num);
  TextAttr:=ICFG.MsgColor;
  CI:=1;
  Repeat
    GotoXY(1,1);
    For I:=1 To Num Do
      Begin
        If CI=I Then
          Begin
            TextAttr:=ICFG.MsgChoice;
          End;
        ClrEol;
        Case I Of
          1 : Write(C1);
          2 : Write(C2);
          3 : Write(C3);
          4 : Write(C4);
          5 : Write(C5);
          6 : Write(C6);
        End;
        If I<>Num Then
          Writeln;
        If I=Num Then
          Begin
            If CI=I Then
              TextAttr:=ICFG.MsgChoice
            Else
              TextAttr:=ICFG.MsgColor;
            HideCursor;
          End;
        If CI=I Then
          Begin
            TextAttr:=ICFG.MsgColor;
          End;
      End;
    C:=Readkey;
    ShowCursor;
    If C=#72 Then
      CI:=CI-1;
    If C=#80 Then
      CI:=CI+1;
    If CI<1 Then
      CI:=1;
    If CI>Num Then
      CI:=Num;
  Until (C=#13) Or (C=#27);
  If C=#13 Then
    Choice:=CI
  Else
    Choice:=7;
End;

{======================================================================}

Begin
  tmptxtscreen:=Nil;
  If MaxAvail>SizeOf(ScreenBufferType) Then
    New(tmptxtscreen);
  SetPointer2TextScreen(screen);
  SaveScreen:=TRUE;
  LastMode:=$00;
End.