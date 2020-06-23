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
| view2.pas
|    secondary view mode.  full screen columns and no help file.  was a good
|    idea, but who want's to see everything in BINARY!??!??!
|
| History:
| Date       Author     Comment
| ----       ------     -------
| -- --- 94  G. Ollis	 created and developed program
============================================================================*)

Unit View2;

INTERFACE

Uses
  Header;

{++PROCEDURES++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Procedure SecondOutput(Var D:DataType);
Procedure Repaint2;

{++FUNCTIONS+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

IMPLEMENTATION

Uses
  CRT,Viewu,VConvert,PrintU,FUTIL,OutCrt,Block,UModify,CNT,WTD,CFG,Ollis,
  Search,DOS,KeyIn,GShift,Cursor,Res,LowInt,Color;

Type
  Byte4Array=Array [1..4] Of Byte;
  Byte4Pointer=^Byte4Array;

Const
  DefNumDataLines=21;
  NullSp:Set Of Byte=[9,18,27,36,39,42,45,48,52,56,60,64];
  NumSt:Set Of Char=['0'..'9','A'..'F'];
  BitF:Array [1..8] Of Byte=(Bit8,Bit7,Bit6,Bit5,Bit4,Bit3,Bit2,Bit1);
  ScrollBarX=79;
  ScrollObj=#17;
  NoLast=0;
  CtrlLast=1;
  DefLast=2;
  ModifyAt=64;

Var
  X,Y:Integer;
  Old:Integer;
  LastHelp:Integer;
  NumDataLines:Integer;

{----------------------------------------------------------------------}

Function ConvertX2Real(L:LongInt):LongInt;
Begin
  L:=L+(Y-1)*4;
  If (X<9) Or (X=65) Then
  Else If (X<18) Or (X=66) Then
    L:=L+1
  Else If (X<26) Or (X=67) Then
    L:=L+2
  Else If (X<35) Or (X=68) Then
    L:=L+3
  Else If (X<39) Then
  Else If (X<42) Then
    L:=L+1
  Else If (X<45) Then
    L:=L+2
  Else If (X<47) Then
    L:=L+3
  Else If (X<52) Then
  Else If (X<55) Then
    L:=L+1
  Else If (X<60) Then
    L:=L+2
  Else If (X<64) Then
    L:=L+3;
  ConvertX2Real:=L;
End;

{----------------------------------------------------------------------}

Procedure HighlightWrite(S:String);
Var I:Integer;
Begin
  TextAttr:=ICFG.Lolight;
  For I:=1 To Length(S) Do
    Begin
      If S[I]='(' Then
        TextAttr:=ICFG.Highlight
      Else If S[I]=')' Then
        TextAttr:=ICFG.Lolight
      Else
        Write(S[I]);
    End;
End;

{----------------------------------------------------------------------}

Procedure CtrlHelp;
Begin
  If LastHelp=CtrlLast Then
    Exit;
  LastHelp:=CtrlLast;
  Window(1,NumDataLines+1,80,Resolution-2); {23}
  TextAttr:=ICFG.Lolight;
  ClrScr;
  HighLightWrite('bloc(K) (L)ook again (S)earch again (F2)dos shell re(P)aint (C)olors');
  Window(1,1,80,Resolution);
  GotoXY(X,Y+1);
End;

{----------------------------------------------------------------------}

Procedure DefHelp;
Begin
  If LastHelp=DefLast Then
    Exit;
  LastHelp:=DefLast;
  Window(1,NumDataLines+1,80,Resolution-2); {23}
  TextAttr:=ICFG.LoLight;
  ClrScr;
  HighLightWrite('('#27#24#25#26'),(TAB) move (Q)uit ');
  HighLightWrite('(<>)change file type (L)ook mem(O)ry ');
  HighLightWrite('(V)iew (S)earch (I)nsert (*)move to'#13#10);
  HighLightWrite('(INS)ert (DEL)ete (F1)info (F2)string (F5)save (F6)return (F7)undo (Ctrl) more');
  Window(1,1,80,Resolution);
  GotoXY(ModifyAt,Resolution-2); {23}
  If X<36 Then
    HighlightWrite('(01) to modify')
  Else If X<48 Then
    HighLightWrite('(0..9,A..F) to mod')
  Else If X<64 Then
    HighLightWrite('(0..9) to modify')
  Else
    HighLightWrite('CHAR');
  ClrEOL;
  Window(1,1,80,Resolution);
  GotoXY(X,Y+1);
End;

{----------------------------------------------------------------------}

Procedure BlockHelp;
Begin
  LastHelp:=NoLast;
  Window(1,NumDataLines+1,80,Resolution-2); {23}
  TextAttr:=ICFG.Lolight;
  ClrScr;

  HighlightWrite('save (A)s  (B)egin block  (C)opy Block  (D)save quit  (H)ide block  bloc(K) end ');
  HighlightWrite('(P)rint  '#10#13'fast (Q)uit  (R)ead block  (S)ave file  mo(V)e block  (W)rite block  (Y)delete');

  ClrEOL;
  Window(1,1,80,Resolution);
  GotoXY(X,Y+1);
End;

{----------------------------------------------------------------------}

Procedure ShiftHelp;
Begin
  LastHelp:=NoLast;
  Window(1,NumDataLines+1,80,Resolution-2); {23}
  TextAttr:=ICFG.Lolight;
  ClrScr;

  HighlightWrite('('#27#24#25#26') fast move (TAB) move back');
  HighlightWrite('');

  ClrEOL;
  Window(1,1,80,Resolution);
  GotoXY(X,Y+1);
End;

{----------------------------------------------------------------------}

Procedure SetUpScr;
Var
  I:Integer;
Begin

  Window(1,1,80,NumDataLines);
  TextAttr:=ICFG.Lolight;
  ClrScr;

  TextAttr:=ICFG.Highlight;
  Window(ScrollBarX,1,ScrollBarX,NumDataLines+1);
  Write(#30);
  For I:=2 To NumDataLines-1 Do
    Write(#176);
  Write(#31);

  Window(1,Resolution-1,80,Resolution-1); {24} {24}
  TextAttr:=ICFG.Highlight;
  ClrScr;

  DefHelp;

  Window(1,1,80,Resolution);

  WriteScreen(Data);
End;

{----------------------------------------------------------------------}

Procedure SaveTextScreen;
Var
  F:FILE;
Begin
  Assign(F,'TEMP2.TMP');
  Rewrite(F,1);
  BlockWrite(F,Screen^,SizeOf(ScreenBufferType));
  Close(F);
End;

{----------------------------------------------------------------------}

Procedure RestoreTextScreen;
Var
  F:FILE;
Begin
  Assign(F,'TEMP2.TMP');
  Reset(F,1);
  BlockRead(F,Screen^,SizeOf(ScreenBufferType));
  Close(F);
  Erase(F);
End;

{----------------------------------------------------------------------}

Procedure Write4(P:Pointer; X:LongInt);
Type
  BAType=Array [1..4] Of Byte;
Var
  I:Integer;
  BA:BAType;

Begin
  BA:=BAType(P^);
  For I:=1 To 4 Do
    Begin
      If (X+I>=Data.BlockStart) And (X+I<=Data.BlockFinish) Then
        TextAttr:=ICFG.Block_Color
      Else
        TextAttr:=ICFG.Numbers;
      If X+I<=Data.EOF Then
        Write(Byte2Bin(BA[I]),' ')
      Else
        ClrEOL;
    End;
  GotoXY(37,WhereY);
  TextAttr:=ICFG.Numbers;
  For I:=1 To 4 Do
    Begin
      If (X+I>=Data.BlockStart) And (X+I<=Data.BlockFinish) Then
        TextAttr:=ICFG.Block_Color
      Else
        TextAttr:=ICFG.Numbers;
      If X+I<=Data.EOF Then
        Write(Byte2Str(BA[I]),' ')
      Else
        ClrEOL;
    End;
  GotoXY(49,WhereY);
  TextAttr:=ICFG.Numbers;
  For I:=1 To 4 Do
    Begin
      If (X+I>=Data.BlockStart) And (X+I<=Data.BlockFinish) Then
        TextAttr:=ICFG.Block_Color
      Else
        TextAttr:=ICFG.Numbers;
      If X+I<=Data.EOF Then
        Write(BA[I]:3,' ')
      Else
        ClrEOL;
    End;
  GotoXY(65,WhereY);
  TextAttr:=ICFG.Numbers;
  For I:=1 To 4 Do
    Begin
      If (X+I>=Data.BlockStart) And (X+I<=Data.BlockFinish) Then
        TextAttr:=ICFG.Block_Color
      Else
        TextAttr:=ICFG.Numbers;
      If X+I<=Data.EOF Then
        If Char(BA[I]) In NormSet Then
          Write(Char(BA[I]))
        Else
          Write('.')
      Else
        ClrEOL;
    End;
  TextAttr:=ICFG.Numbers;
End;

{----------------------------------------------------------------------}

Procedure UpDateScroll(X,Max:LongInt);
Begin
  If MaxX=0 Then
    MaxX:=1;
  Window(ScrollBarX,2,ScrollBarX,Resolution);
  TextAttr:=ICFG.Highlight;
  If Old <> -1 Then
    Begin
      GotoXY(1,Old);
      Write(#176);
    End;
  Old:=(X*(NumDataLines-2)) div Max;
  GotoXY(1,Old);
  Write(ScrollObj);
  Window(1,1,80,Resolution);
End;

{----------------------------------------------------------------------}

Procedure WriteNumbers(Var D:DataType);
Var
  I:Integer;
Begin
  GotoXY(1,1);
  TextAttr:=ICFG.StatusMid;
  Window(1,1,68,1);
  Write('X: ',ConvertX2Real(D.X+D.offset-1):11,' $',Long2Str(ConvertX2Real(D.X+D.offset-1)),' EOF: ');
  Write(D.EOF,' $',Long2Str(D.EOF),' (X,Y)=(',X,',',Y,')');
  ClrEOL;
  Window(1,2,68,Resolution);
  For I:=0 To NumDataLines-2 Do
    Write4(@D.D^[D.X+I*4],D.X+D.Offset+(I-1)*4+3);
  Window(1,1,80,Resolution);
  GotoXY(ModifyAt,Resolution-2); {23}
  If X<36 Then
    HighlightWrite('(01) to modify')
  Else If X<48 Then
    HighLightWrite('(0..9,A..F) to mod')
  Else If X<64 Then
    HighLightWrite('(0..9) to modify')
  Else
    HighLightWrite('CHAR');
  ClrEOL;
  GotoXY(X,Y+1);
End;

{----------------------------------------------------------------------}

Procedure WritePageData(Var D:DataType);
Begin
  GotoXY(1,1);
  TextAttr:=ICFG.StatusMid;
  Write('X: ',ConvertX2Real(D.X+D.offset):11,' $',Long2Str(ConvertX2Real(D.X+D.offset)),' EOF: ');
  Writeln(D.EOF,' $',Long2Str(D.EOF),' (X,Y)=(',X,',',Y,')');
  GotoXY(ModifyAt,Resolution-2); {23}
  If X<36 Then
    HighlightWrite('(01) to modify')
  Else If X<48 Then
    HighLightWrite('(0..9,A..F) to mod')
  Else If X<64 Then
    HighLightWrite('(0..9) to modify')
  Else
    HighLightWrite('CHAR');
  ClrEOL;
End;

{----------------------------------------------------------------------}

Procedure VarChange(P:Byte4Pointer; C:Char;  X:Integer);
Var
  I,D:Integer;
  B,Old:Byte;
  S:String[4];
Begin
  If X<36 Then
    Begin
      If Not (C In ['0','1']) Then
        Exit;
      If X<36 Then
        I:=4;
      If X<27 Then
        I:=3;
      If X<18 Then
        I:=2;
      If X<9 Then
        I:=1;
      X:=X-(I-1)*9;
      Case C Of
        '0' : P^[I]:=P^[I] and (Not BitF[X]);
        '1' : P^[I]:=P^[I] or BitF[X];
      End;
      Exit;
    End;
  If X<49 Then
    Begin
      If X<39 Then
        Begin
          I:=1;
        End
      Else If X<42 Then
        Begin
          I:=2;
          Dec(X);
        End
      Else If X<45 Then
        Begin
          I:=3;
        End
      Else If X<48 Then
        Begin
          I:=4;
          Dec(X);
        End;
      B:=StrToInt('$'+C);
      If (X mod 2=0) Then
        P^[I]:=(P^[I] and $F0) or B
      Else
        P^[I]:=(P^[I] and $0F) or B*$10;
      Exit;
    End;
  If X<64 Then
    Begin
      If X<52 Then
        I:=1
      Else If X<56 Then
        I:=2
      Else If X<60 Then
        I:=3
      Else
        I:=4;
      Case X Of
        49 : D:=100;
        50 : D:=10;
        51 : D:=1;
        53 : D:=100;
        54 : D:=10;
        55 : D:=1;
        57 : D:=100;
        58 : D:=10;
        59 : D:=1;
        61 : D:=100;
        62 : D:=10;
        63 : D:=1;
      End;
      If (D=100) And (C>='3') Then
        Exit;
      Str(P^[I]:3,S);
      Case D Of
        1  : Old:=StrToInt(S[3]);
        10 : Old:=StrToInt(S[2]);
        100: Old:=StrToInt(S[1]);
      End;
      P^[I]:=P^[I]-Old*D;
      P^[I]:=P^[I]+StrToInt(C)*D;
    End;
End;

{----------------------------------------------------------------------}

Const
  Norm=0;
  ExitSecond=1;
  ExitProgram=2;

Function MInput(Var D:DataType; Button:Integer):Integer;
Var
  Xm,Ym:Integer;
  Save:LongInt;
  Mark1,Mark2:LongInt;
Begin
  HideCursor;
  Xm:=GetMouseX div 8+1;  Ym:=GetMouseY div 8+1;
  If (Button=LeftButton) And (Xm<=68) And (Ym=1) Then
    Begin
      Repeat Until MouseButtonReleased(LeftButton);
      MInput:=ExitSecond;
      Exit;
    End;
  If (Button=RightButton) And (Xm<=68) And (Ym=1) Then
    Begin
      Repeat Until MouseButtonReleased(RightButton);
      MInput:=ExitProgram;
      Exit;
    End;
  If (Button=LeftButton) And (Xm<=68) And (Ym>1) And (Ym<=NumDataLines) Then
    Begin
      Repeat
        If (Xm<=68) And (Ym>1) And (Ym<=NumDataLines) Then
          Begin
            X:=Xm;
            Y:=Ym-1;
            If X In NullSp Then
              Dec(X);
            WritePageData(D);
            GotoXY(X,Y+1);
          End;
        Xm:=GetMouseX div 8+1;
        Ym:=GetMouseY div 8+1;
      Until MouseButtonReleased(LeftButton);
      Exit;
    End;
  If (Button=RightButton) And (Xm<68) And (Ym>1) And (Ym<=NumDataLines) Then
    Begin
      X:=Xm;
      Y:=Ym-1;
      If X In NullSp Then
        Dec(X);
      Mark1:=ConvertX2Real(D.X);
      Repeat
        Xm:=GetMouseX div 8+1;
        Ym:=GetMouseY div 8;
        If Ym=0 Then
          Begin
            Dec(D.X,4);
            If D.X+D.offset<1 Then
              D.X:=1;
            Relocate(D);
          End;
        If Ym>=20 Then
          Begin
            Inc(D.X,4);
            Relocate(D);
          End;
        If Xm<=68 Then
          X:=Xm;
        If (Ym>0) And (Ym<NumDataLines) Then
          Y:=Ym;
        If X In NullSp Then
          Dec(X);
        WritePageData(D);
        GotoXY(X,Y+1);
        Mark2:=ConvertX2Real(D.X);
        If Mark1>Mark2 Then
          Begin
            D.BlockStart:=Mark2;
            D.BlockFinish:=Mark1;
          End
        Else
          Begin
            D.BlockStart:=Mark1;
            D.BlockFinish:=Mark2;
          End;
        WriteNumbers(D);
        Save:=D.X;
        D.X:=ConvertX2Real(D.X);
        WriteTypeData(D.D^[D.X],D);
        UpdateScroll(D.X+D.offset,D.EOF);
        D.X:=Save;
        GotoXY(X,Y+1);
      Until MouseButtonReleased(RightButton);
      Exit;
    End;
  If (Button=LeftButton) And (Xm=ScrollBarX) And (Ym=1) Then
    Begin
      Repeat
        Dec(D.X,4);
        If D.X+D.offset<0 Then
          D.X:=1;
        Relocate(D);

        WriteNumbers(D);
        Save:=D.X;
        D.X:=ConvertX2Real(D.X);
        WriteTypeData(D.D^[D.X],D);
        UpdateScroll(D.X+D.offset,D.EOF);
        D.X:=Save;
        GotoXY(X,Y+1);
      Until MouseButtonReleased(LeftButton);
      Exit;
    End;
  If (Button=LeftButton) And (Xm=ScrollBarX) And (Ym=NumDataLines) Then
    Begin
      Repeat
        Inc(D.X,4);
        Relocate(D);

        WriteNumbers(D);
        Save:=D.X;
        D.X:=ConvertX2Real(D.X);
        WriteTypeData(D.D^[D.X],D);
        UpdateScroll(D.X+D.offset,D.EOF);
        D.X:=Save;
        GotoXY(X,Y+1);
      Until MouseButtonReleased(LeftButton);
      Exit;
    End;
  If (Button=RightButton) And (Xm=ScrollBarX) And (Ym=1) Then
    Begin
      Repeat
        Dec(D.X,4*NumDataLines);
        If D.X+D.offset<0 Then
          D.X:=1;
        Relocate(D);

        WriteNumbers(D);
        Save:=D.X;
        D.X:=ConvertX2Real(D.X);
        WriteTypeData(D.D^[D.X],D);
        UpdateScroll(D.X+D.offset,D.EOF);
        D.X:=Save;
        GotoXY(X,Y+1);
      Until MouseButtonReleased(RightButton);
      Exit;
    End;
  If (Button=RightButton) And (Xm=ScrollBarX) And (Ym=NumDataLines) Then
    Begin
      Repeat
        Inc(D.X,4*NumDataLines);
        Relocate(D);

        WriteNumbers(D);
        Save:=D.X;
        D.X:=ConvertX2Real(D.X);
        WriteTypeData(D.D^[D.X],D);
        UpdateScroll(D.X+D.offset,D.EOF);
        D.X:=Save;
        GotoXY(X,Y+1);
      Until MouseButtonReleased(RightButton);
      Exit;
    End;
  If (Button=LeftButton) And (Xm=ScrollBarX) And (Ym>1) And (Ym<NumDataLines) Then
    Begin
      Repeat
        If (Ym>1) And (Ym<NumDataLines) Then
          Begin
            D.X:=(((Ym) * D.EOF) div (NumDataLines-2) )-D.offset;
            Relocate(D);

            WriteNumbers(D);
            Save:=D.X;
            D.X:=ConvertX2Real(D.X);
            WriteTypeData(D.D^[D.X],D);
            UpdateScroll(D.X+D.offset,D.EOF);
            D.X:=Save;
            GotoXY(X,Y+1);
          End;
        Ym:=GetMouseY div 8+1;
      Until MouseButtonReleased(LeftButton);
      Exit;
    End;
  If Button=LeftButton Then
    While NOT MouseButtonReleased(LeftButton) Do
      ;
  If Button=RightButton Then
    While NOT MouseButtonReleased(RightButton) Do
      ;
  If Button=CenterButton Then
    While NOT MouseButtonReleased(CenterButton) Do
      ;
  ShowCursor;
End;

{----------------------------------------------------------------------}

Procedure Repaint2;
Begin
  Window(1,1,80,Resolution);
  ClrScr;
  SetUpScr;
  UpdateScroll(Data.X+Data.offset,Data.EOF);
End;

{----------------------------------------------------------------------}

Procedure SecondOutput(Var D:DataType);
Var
  C:Char;
  Save:LongInt;
  I:Integer;
  Last:Byte;
Begin
  Old:=-1;
  Y:=1;
  SaveTextScreen;
  AltMode:=Byte4Mode;
  LastHelp:=NoLast;

  SetUpScr;
  UpdateScroll(D.X+D.offset,D.EOF);
  Repeat
    WriteNumbers(D);
    Save:=D.X;
    D.X:=ConvertX2Real(D.X);
    WriteTypeData(D.D^[D.X],D);
    Window(1,1,80,Resolution);
    D.X:=Save;
    GotoXY(X,Y+1);

    Last:=$FF;

    If MousePresent Then
      Begin
        ShowMC;
        ShowCursor;
        Repeat
          C:=#$FF;
          I:=0;
          If KeyPressed Then
            C:=Readkey;
          If MouseButtonPressed(LeftButton) Then
            I:=MInput(D,LeftButton);
          If MouseButtonPressed(RightButton) Then
            I:=MInput(D,RightButton);
          If MouseButtonPressed(CenterButton) Then
            I:=MInput(D,CenterButton);
          ShowCursor;
          If I=ExitSecond Then
            C:=#64;
          If I=ExitProgram Then
            C:='q';
          If GetShiftByte<>Last Then
            Begin
              Last:=GetShiftByte;
              If Boolean(Last And $03) Then
                ShiftHelp
              Else If Boolean(Last And KBCtrl) Then
                CtrlHelp
              Else
                DefHelp;
            End;
        Until C<>#$FF;
        HideCursor;
        HideMC;
      End
    Else
      Begin
        ShowCursor;
        Repeat
          If GetShiftByte<>Last Then
            Begin
              Last:=GetShiftByte;
              If Boolean(Last And $03) Then
                ShiftHelp
              Else If Boolean(Last And KBCtrl) Then
                CtrlHelp
              Else
                DefHelp;
            End;
        Until KeyPressed;
        C:=Readkey;
        HideCursor;
      End;
    If NOT Boolean(Last And $03) Then
      Begin
        If (C In NumSt) And Not Boolean(Last And $03) Then
          Begin
            VarChange(@D.D^[D.X+(y-1)*4],C,X);
            Inc(X);
            If X>=69 Then
              Begin
                X:=1;
                Inc(Y);
              End;
            If X In NullSp Then
              Inc(X);
            ToggleChanges(D);
          End;
        End
      Else
        Begin
          If (C=#56) Then
            Dec(Y,10);
          If (C=#50) Then
            Inc(Y,10);
          If (C=#54) Then
            X:=68;
          If (C=#52) Then
            X:=1;
        End;
    If (C='<') Or (C=',') Then
      Begin
        D.BFT:=D.BFT-1;
        If D.BFT<1 Then
          D.BFT:=NumberOfFileTypes;
        WriteScreen(D);
      End;
    If (C='>') Or (C='.') Then
      Begin
        D.BFT:=D.BFT+1;
        If D.BFT>NumberOfFileTypes Then
          D.BFT:=1;
        WriteScreen(D);
      End;
    If (C='o') Then
      Begin
        OpenWindow(20,7,60,11,ICFG.MsgColor);
        Writeln('  Memory available      : ',MemAvail:6);
        Writeln('  Largest chunk         : ',MaxAvail:6);
        If MousePresent Then
          Writeln('  Mouse Coords (Rl-Sc)  : ',GetMouseX,',',GetMouseY,'-',GetMouseX div 8+1,',',GetMouseY div 8+1)
        Else
          Writeln('  No mouse detected');
        Writeln('  D.X/D.offset          : ',D.X,'/',D.offset);
        Write('  ',ParamStr(0));
        HideCursor;
        Pause;
        ShowCursor;
        CloseWindow;
      End;
    If (C='v') And (tmptxtscreen<>Nil) Then
      Begin
        SvTextScreen;
        View(D.stream,D.FN,D.BFT,FALSE);
        RsTextScreen;
      End;
    If C='l' Then
      Begin
        FindArray(D);
        UpdateScroll(D.X+D.offset,D.EOF);
      End;
    If C=^L Then
      Begin
        DoFindSearch(D);
        UpdateScroll(D.X+D.offset,D.EOF);
      End;
    If C=^C Then
      ConfigureColor;
    If C='s' Then
      Begin
        SearchStr(D,True);
        UpdateScroll(D.X+D.offset,D.EOF);
      End;
    If C=^P Then
      Repaint2;
    If C=^S Then
      Begin
        SearchStr(D,False);
        UpdateScroll(D.X+D.offset,D.EOF);
      End;
    If C='i' Then
      Begin
        WhatInsert(D);
        UpdateScroll(D.X+D.offset,D.EOF);
      End;
    If C='*' Then
      Begin
        SetX(D.X,D);
        UpdateScroll(D.X+D.offset,D.EOF);
      End;
    If (C=^K) Then
      Begin
        Save:=D.X;
        D.X:=ConvertX2Real(D.X);
        BlockHelp;
        Repeat Until KeyPressed;
        DefHelp;
        Case UpCase(Readkey) Of
          #0  : Readkey;
          'A' : SaveAs(D);
          'B' : D.BlockStart:=D.X+D.offset;
          'C' : CopyBlock(D);
          'D' :
            Begin
              SaveSegment(D);
              WriteContactMsg;
              Halt;
            End;
          'H' :
            Begin
              D.BlockStart:=-1;
              D.BlockFinish:=-1;
            End;
          'K' : D.BlockFinish:=D.X+D.offset;
          'P' : Print(D);
          'Q',#27 :
            Begin
              WriteContactMsg;
              If Resolution>25 Then
                Begin
                  Window(1,26,80,Resolution);
                  TextAttr:=Black * $10 or lightgray;
                  ClrScr;
                End;
              Halt;
            End;
          'R' : ReadBlock(D);
          'S' : SaveSegment(D);
          'V' : MoveBlock(D);
          'W' : WriteBlock(D);
          'Y' :
            If (D.BlockStart>0) And (D.BlockFinish>0) Then
              Begin
                DeleteBlock(D,D.BlockStart,D.BlockFinish-D.BlockStart+1);
                D.BlockStart:=-1;
                D.BlockFinish:=-1;
              End;
        End;
        D.X:=Save;
        UpdateScroll(D.X+D.offset,D.EOF);
      End;
    If ((C='q') Or (C=#27)) And (ReallyQuit(D)) Then
      Begin
        WriteContactMsg;
        If Resolution>25 Then
          Begin
            Window(1,26,80,Resolution);
            TextAttr:=Black * $10 or lightgray;
            ClrScr;
          End;
        Halt;
      End;
    If (C=#9) Then
      If X<36 Then
        X:=37
      Else If X<48 Then
        X:=49
      Else If X<64 Then
        X:=65
      Else
        Begin
          X:=1;
          Inc(Y);
        End;
    If (C=#0) Then
      Case Readkey Of
        #15 :
          If X<36 Then
            Begin
              Dec(Y);
              X:=65;
            End
          Else If X<48 Then
            X:=1
          Else If X<64 Then
            X:=37
          Else
            X:=49;
        #72 : Dec(Y);
        #75 :
          Begin
            Dec(X);
            If X In NullSp Then
              Dec(X);
          End;
        #77 :
          Begin
            Inc(X);
            If X In NullSp Then
              Inc(X);
          End;
{        #73 :}
        #80 : Inc(Y);
        #98 :
          SaveAs(D);
        #82 :
          Begin
            DoInsert(D,1,0);
            UpdateScroll(D.X+D.offset,D.EOF);
          End;
        #83,#8 :
          Begin
            DelByte(D);
            UpdateScroll(D.X+D.offset,D.EOF);
          End;
        #95 :
          DosShell(D);
        #59 :
          HEXEDInfo;
        #60 :
          Begin
            OpenWindow(20,10,60,12,ICFG.MsgColor);
            I:=Choice(3,'  Null terminated string','  No termination','  Pascal type','','','',20,10,60);
            CloseWindow;
            If I<>7 Then
              Begin
                InsertString(I,D);
                ToggleChanges(D);
              End;
          End;
        #63 :
          SaveSegment(D);
        #64 :
          C:=#255;
        #65 :
          Begin
            RestoreSegment(D);
            D.Changes:=False;
            WriteScreen(D);
          End;
      End;
    If Y<1 Then
      Begin
        Dec(D.X,4);
        If D.X+D.offset<1 Then
          D.X:=1;
        Y:=1;
        Relocate(D);
        UpdateScroll(D.X+D.offset,D.EOF);
      End;
    If Y>NumDataLines-1 Then
      Begin
        Inc(D.X,4);
        Y:=NumDataLines-1;
        Relocate(D);
        UpDateScroll(D.X+D.offset,D.EOF);
      End;
    While ConvertX2Real(D.X+D.offset)>D.EOF Do
      Begin
        Dec(X);
        If X<1 Then
          Begin
            X:=68;
            Dec(Y);
          End;
      End;
    If X>68 Then
      X:=68;
    If X<1 Then
      X:=1;
  Until (C=#255);

  AltMode:=StdMode;
  RestoreTextScreen;
  D.X:=ConvertX2Real(D.X);

  If(Resolution>25) Then
    Begin
      Window(1,26,80,Resolution);
      TextAttr:=Black * $10 or LightGray;
      ClrScr;
    End;

  WriteScreen(D);
End;

{======================================================================}

Begin
  X:=1;
  Y:=1;
  NumDataLines:=Resolution-4;
End.