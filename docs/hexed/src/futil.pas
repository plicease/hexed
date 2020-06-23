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
| futil.pas
|   file functions for hexed.
|
| History:
| Date       Author     Comment
| ----       ------     -------
| -- --- 94  G. Ollis	 created and developed program
============================================================================*)

{$I-}

Unit FUtil;

INTERFACE

Uses
  Header;

{++PROCEDURES++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Procedure RestoreTemp(Var B:BinaryImage; index:Integer);
Procedure SaveSegment(Var D:DataType);
Procedure RestoreSegment(Var D:DataType);
Procedure Relocate(Var D:DataType);
Procedure LoadFile(Var D:DataType);
Procedure LoadFile2(Var D:DataType);
Procedure ToggleChanges(Var D:DataType);
Procedure CheckIOError(S:String; exc:Integer);
Procedure CheckFileType(Var D:DataType);

{++FUNCTIONS+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Function SaveTemp(Var B:BinaryImage; index:Integer):Boolean;
Function GetFileByte(Var F:File; index:LongInt):Byte;
Function GetFileWord(Var F:File; index:LongInt):Word;
Function GetFileLong(Var F:File; index:LongInt):LongInt;
Function SizeOfFile(S:String):LongInt;

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

IMPLEMENTATION

Uses
  DOS,CNT,OutCRT,CRT,ViewU,VConvert,CFG,Center;

{------------------------------------------------------------------------}

Procedure CheckIOError(S:String; exc:Integer);
Var Error:Integer; X,Y:Byte;
Begin
  Error:=IOResult;
  If (Error<>0) And (Error<>exc) Then
    Begin
      X:=WhereX;  Y:=WhereY;
      ErrorMsg('IOError on '+S+' err#'+IntToStr(Error,0));
      GotoXY(X,Y);
      TextAttr:=ICFG.LoLight;
    End;
End;

{-----------------------------------------------------------------}

Function SizeOfFile(S:String):LongInt;
{This function just finds the size of a file}
Var
  DirInfo:SearchRec;
Begin
  FindFirst(S,AnyFile,DirInfo);
  SizeOfFile:=DirInfo.Size;
End;

{------------------------------------------------------------------------}

Function RemoveBS(S:String):String;
Begin
  If S[Length(S)]='\' Then
    Delete(S,Length(S),1);
  RemoveBS:=S;
End;

{------------------------------------------------------------------------}

Function GetFileByte(Var F:File; index:LongInt):Byte;
{Get the byte at the specified index in the file pointed to by F}
Var B:Byte;
Begin
  B:=0;
  Seek(F,index);
  BlockRead(F,B,1);
  GetFileByte:=B;
End;

{------------------------------------------------------------------------}

Function GetFileWord(Var F:File; index:LongInt):Word;
{Get the byte at the specified index in the file pointed to by F}
Var B:Word;
Begin
  B:=0;
  Seek(F,index);
  BlockRead(F,B,2);
  GetFileWord:=B;
End;

{------------------------------------------------------------------------}

Function GetFileLong(Var F:File; index:LongInt):LongInt;
{Get the byte at the specified index in the file pointed to by F}
Var B:LongInt;
Begin
  B:=0;
  Seek(F,index);
  BlockRead(F,B,4);
  GetFileLong:=B;
End;

{------------------------------------------------------------------------}

Procedure SaveSegment(Var D:DataType);
Var error:Word;
Begin
  If Not D.changes Then
    Exit;
  D.Changes:=False;
  If (D.FN<>Secondary^.FN) Then
    WriteScreen(D);
  Seek(D.stream,D.offset);
  If D.offset+imagesize-1<=D.EOF Then
    BlockWrite(D.stream,D.D^,imagesize-1)
  Else
    BlockWrite(D.stream,D.D^,D.EOF-D.offset);
  error:=IOResult;
  If error<>0 Then
    Begin
      WriteContactMsg;
      Writeln('error #',error,' writing a segment to file ',D.FN);
      Halt;
    End;
  If FileSize(D.stream)>D.EOF Then
    Begin
      Seek(D.stream,D.EOF);
      Truncate(D.stream);
    End;
End;

{------------------------------------------------------------------------}

Procedure RestoreSegment(Var D:DataType);
Var br,error:Word;
Begin
  FillChar(D.D^,imagesize,0);
  Seek(D.stream,D.offset);
  If D.offset+imagesize-1<=FileSize(D.stream) Then
    BlockRead(D.stream,D.D^,imagesize-1)
  Else
    Begin
      br:=FileSize(D.stream)-D.offset;
      BlockRead(D.stream,D.D^,br,error);
    End;
  error:=IOResult;
  If (Error<>0) And (Error<>100) Then
    Begin
      WriteContactMsg;
      Writeln('error #',error,' reading a segment from file ',D.FN);
      Halt;
    End;
End;

{------------------------------------------------------------------------}

Procedure Relocate(Var D:DataType);
Var x:LongInt;
Begin
  If (D.EOF<imagesize-1) And (D.offset<>0) Then
    Begin
      SaveSegment(D);
      D.offset:=0;
      D.X:=D.X+D.offset;
      RestoreSegment(D);
      Exit;
    End;
  If (D.X+D.offset<=1) Then
    D.X:=1-D.offset;
  If (D.X+D.offset>D.EOF) Then
    D.X:=D.EOF-D.offset;
  If (D.EOF<imagesize-1) Or ((D.X<imagesize-Bookend) And
     (D.X>Bookend)) Or ((D.offset=0) And (D.X<imagesize-Bookend)) Then
    exit;
  x:=D.X+D.offset;
  SaveSegment(D);
  D.X:=imagesize div 2;
  D.offset:=x-imagesize div 2;
  If x<imagesize Then
    Begin
      D.offset:=0;
      D.X:=x;
    End;
  RestoreSegment(D);
End;

{------------------------------------------------------------------------}

Function SaveTemp(Var B:BinaryImage; index:Integer):Boolean;
Var  F:File of BinaryImage;
Begin
  SaveTemp:=FALSE;
  If GetEnv('TEMP')='' Then
    Assign(F,'HEXED'+IntToStr(index,0)+'.TMP')
  Else
    Assign(F,RemoveBS(GetEnv('TEMP'))+'\HEXED'+IntToStr(index,0)+'.TMP');
  Rewrite(F);
  If IOResult <> 0 Then
    Exit;
  Write(F,B);
  If IOResult <> 0 Then
    Begin
      Close(F);
      If IOResult <> 0 Then
        ;
      Erase(F);
      If IOResult <> 0 Then
        ;
    End;
  Close(F);
  SaveTemp:=TRUE;
End;

{------------------------------------------------------------------------}

Procedure RestoreTemp(Var B:BinaryImage; index:Integer);
Var F:File of BinaryImage;
Begin
  If GetEnv('TEMP')='' Then
    Assign(F,'HEXED'+IntToStr(index,0)+'.TMP')
  Else
    Assign(F,RemoveBS(GetEnv('TEMP'))+'\HEXED'+IntToStr(index,0)+'.TMP');
  Reset(F);
  Read(F,B);
  Close(F);
  Erase(F);
End;

{------------------------------------------------------------------------}

Procedure LoadFile(Var D:DataType);
Var I:Word;     Error:Word;
Begin
  If MemAvail<SizeOf(binaryImage) Then
    Begin
      TextAttr:=ICFG.Error;
      Writeln('Error: Not enough memory for binary image.');
      TextAttr:=SaveTextAttr;
      Halt;
    End;
  New(D.D);
  FillChar(D.D^,SizeOf(D.D^),0);
  TextAttr:=ICFG.Highlight;
  Write('Loading file...');
  Assign(D.stream,D.FN);
  Reset(D.stream,1);
  Error:=IOResult;
  If Error<>0 Then
    Begin
      TextAttr:=ICFG.Error;
      Writeln('Error: could not open file for reading Error number ',Error);
      TextAttr:=SaveTextAttr;
      Halt;
    End;
  D.EOF:=SizeOfFile(D.FN);
  D.offset:=Seek_To;
  Seek(D.stream,D.offset);
  BlockRead(D.stream,D.D^,$FFFE,Error);
  If ((Error<D.EOF) And (D.EOF<$FFFE)) Or ((Error<$FFFE) And (D.EOF>$FFFE)) Then
    Begin
      ErrorMsg('did not read entire file '+IntToStr(Error,0)+'/'+IntToStr(D.EOF,0));
      Halt;
    End;
  Writeln('file loaded');
  D.X:=1;
End;

{------------------------------------------------------------------------}

Procedure LoadFile2(Var D:DataType);
Var I:Word;     Error:Word;
Begin
  D.changes:=FALSE;
  D.BlockStart:=0;
  D.BlockFinish:=0;

  FillChar(D.D^,SizeOf(D.D^),0);

  Assign(D.stream,D.FN);
  Reset(D.stream,1);
  Error:=IOResult;
  If Error<>0 Then
    Begin
      Window(1,1,80,25);
      TextAttr:=ICFG.Error;
      ClrScr;
      Writeln('Error: could not open file for reading Error number ',Error);
      TextAttr:=SaveTextAttr;
      Halt;
    End;
  D.EOF:=SizeOfFile(D.FN);
  Seek(D.stream,D.offset);
  If Seek_To<>0 Then
    Begin
      D.offset:=Seek_To;
      Seek(D.stream,D.offset);
    End;
  BlockRead(D.stream,D.D^,$FFFE,Error);
End;

{------------------------------------------------------------------------}

Procedure ToggleChanges(Var D:DataType);
{This procedure changes the changes field the true so that HEXED can tell if
 the user has made changes when he tries to quit.  This way HEXED can say
 "You have unsaved changes (if he/she does).  Do you want to quit?"}
Begin
  If Not D.changes Then
    Begin
      D.changes:=True;
      WriteScreen(D);
    End;
End;

{------------------------------------------------------------------------}

Procedure DetectEXE;
Var
  Sig:Byte;
  Sig2:LongInt;
  W:Word;
Begin
  With Data.ED Do
    Begin
      NumRlc:=0;
      Seek(Data.stream,$06);
      If IOResult=0 Then
        BlockRead(Data.stream,NumRlc,2);

      Seek(Data.stream,$18);
      If IOResult=0 Then
        BlockRead(Data.stream,OffRlc,2);

      Seek(Data.stream,$08);
      If IOResult=0 Then
        Begin
          HeadSize:=512;
          BlockRead(Data.stream,W,2);
          If IOResult<>0 Then
            HeadSize:=W*16;
        End;

      Tp:=0;
      Seek(Data.stream,$1E);
      If IOResult=0 Then
        Begin
          BlockRead(Data.stream,Sig,1);
          If (IOResult=0) And (Sig=$FB) Then
            Tp:=2;
        End;

      Seek(Data.stream,$1C);
      If IOResult=0 Then
        Begin
          BlockRead(Data.stream,Sig2,4);
          If IOResult=0 Then
            If Sig2=$58534A52 Then
              Tp:=3
            Else If Sig2=$39305A4C Then
              Tp:=4
            Else If Sig2=$31395A4C Then
              Tp:=5
            Else If Sig2=$018A0001 Then
              Tp:=9
            Else If Sig2=$00020001 Then
              Tp:=10
            Else If Word(Sig2)=$000F Then
              Tp:=11;
        End;

    End;
End;

{------------------------------------------------------------------------}

Procedure CheckFileType(Var D:DataType);
Var
  Dir:DirStr;
  Name:NameStr;
  Ext:ExtStr;
  tmp:Byte;
  ID:Array [1..4] of Char;
Begin
  D.BlockStart:=-1;
  D.BlockFinish:=-2;
  FSplit(D.FN,Dir,Name,Ext);
  For tmp:=1 To 4 Do
    Ext[tmp]:=UpCase(Ext[tmp]);
  D.BFT:=1;
  If (Ext='.PCX') Then
    D.BFT:=2;
  If ((Ext='.PAL') Or (Ext='.COL')) Then
    D.BFT:=3;
  If (Ext='.CMF') Then
    D.BFT:=4;
  If (Ext='.SBI') Then
    D.BFT:=5;
  If (Ext='.GIF') Then
    D.BFT:=6;
  If (Ext='.VOC') Then
    D.BFT:=7;
  If (Ext='.IMG') Then
    D.BFT:=8;
  If (Ext='.MOD') Then
    Begin
      Seek(D.Stream,1080);
      If IOResult <> 0 Then
        Exit;
      BlockRead(D.Stream,ID,4);
      If IOResult <> 0 Then
        Exit;
      If (ID='M.K.') Or (ID='FLT4') Then
        D.BFT:=9
      Else
        D.BFT:=10;
    End;
  If (Ext='.IBK') Then
    D.BFT:=11;
  If (Ext='.FLI') Then
    D.BFT:=12;
  If (Ext[1]='.') And (Ext[2]='F') And (Ext[3]>='0') And (Ext[3]<='9') And
     (Ext[4]>='0') And (Ext[4]<='9') Then
    Begin
      Seek(D.stream,0);
      If IOResult <>0 Then
        Exit;
      ID[4]:='1';
      BlockRead(D.stream,ID,3);
      If (ID='FRG1') Then
        Begin
          D.BFT:=13;
          Seek(D.stream, 30);
          BlockRead(D.stream, D.FragOffset, 2);
        End;
    End;
  If (Ext='.EXE') Or (Ext='.COM') Then
    Begin
      D.BFT:=14;
      DetectEXE;
    End;
End;

{======================================================================}

End.