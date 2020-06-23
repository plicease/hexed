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
| gif.pas
|    gif functions for displaying the graphics interchange format.
|
| History:
| Date       Author     Comment
| ----       ------     -------
| -- --- 94  G. Ollis	 created and developed program
============================================================================*)

{$I-}

Unit GIF;

INTERFACE

Uses Ollis;


{++PROCEDURES++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{++FUNCTIONS+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Function DrawGIFDsk(Var F:FILE; Var p:Pal):String;
Function DrawIMGMem(Var fp:FILE):String;

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

IMPLEMENTATION

Uses Crt,Header;

{----------------------------------------------------------------------}

Type
  LineType=Array [0..1280] Of Byte;
  IDType=Array [0..5] Of Char;
  GIFHeader=Record
    Sig:IDType;
    ScreenWidth,
    ScreenDepth:Word;
    Flags,
    BackGround,
    Aspect:Byte;
  End;
  BlockHeader=Record
    X1,Y1,X2,Y2:Word;
    flags:Byte;
  End;
  ByteCodeStackType=Array [0..4095] Of Byte;
  ByteCodeStackPointer=^ByteCodeStackType;
  IntCodeStackType=Array [0..4095] Of Integer;
  IntCodeStackPointer=^IntCodeStackType;
  PalettePointer=^Pal;

Const
  OldGif:IDType='GIF87a';
  NewGif:IDType='GIF89a';

{----------------------------------------------------------------------}

Function ReadHeader(H:GIFHeader; Var NC:Word; Var GP:Boolean):String;
Begin
  ReadHeader:='';
  If (H.Sig<>OldGif) And (H.Sig<>NewGif) Then
    Begin
      ReadHeader:='ID string incorrect';
    End;
  NC:=1 shl ((H.Flags And 7)+1);
  If NC<>256 Then
    Begin
      REadHeader:='not enough colors.  I need a 256 color GIF';
    End;
  If (H.Flags And $80)=$80 Then
    GP:=True
  Else
    GP:=False;
End;

{----------------------------------------------------------------------}

Const
  SEEK_SET=0;
  SEEK_CUR=1;

Procedure FSeek(Var stream:FILE; offset:LongInt);
Begin
  Seek(stream,offset);
End;

{----------------------------------------------------------------------}

Function fgetc(Var stream:File):Byte;
{This function simulates buff as if it were a file}
Var
  B:Byte;
Begin
  BlockRead(stream,B,$1);
  fgetc:=b;
End;

{----------------------------------------------------------------------}

Function fread(Var ptr; size,n:Word; Var streem:FILE):Word;
Var BytesWritten:Word;
Begin
{  Move(streem^,ptr,size*n);
  streem:=@mem[Seg(streem^):Ofs(streem^)+size*n];
  fread:=size*n;}
  BlockRead(streem,ptr,size*n,BytesWritten);
  fread:=BytesWritten;
End;

{----------------------------------------------------------------------}

Function IncR(Var l:Integer):Integer;
{replacement for ++i}
Begin
  l:=l+1;
  IncR:=l;
End;

{----------------------------------------------------------------------}

Function DecR(Var l:Integer):Integer;
{replacement for --i}
Begin
  l:=l-1;
  DecR:=l;
End;

{----------------------------------------------------------------------}

Function RDec(Var l:Integer):Integer;
{replacement for i--}
Begin
  RDec:=l;
  l:=l-1;
End;

{----------------------------------------------------------------------}
function IntToStr(I: Longint): String;
{ Convert any integer type to a string }
var
 S: string[11];
begin
 Str(I, S);
 IntToStr := S;
end;
{----------------------------------------------------------------------}

Function RInc(Var l:Integer):Integer;
{replacement for i++}
Begin
  RInc:=l;
  l:=l+1;
End;

{----------------------------------------------------------------------}

Const
  No_Code=-1;

Type
  ScreenBufferType=Array [0..$FFFE] Of Byte;
  WordMaskTableType=Array [0..$F] Of Word;
  WordMaskPointer=^WordMaskTableType;
  Table=Array [0..4] Of Integer;

Var
  FirstCodeStack,                           { Stack for first codes }
  LastCodeStack:ByteCodeStackPointer;       { Stack for previous code }
  CodeStack:IntCodeStackPointer;            { Stack for links }
  WordMaskTable:WordMaskPointer;            { see DWMT below }

Const
  DefaultWordMaskTable:WordMaskTableType=($0000,$0001,$0003,$0007,
                                          $000F,$001F,$003F,$007F,
                                          $00FF,$01FF,$03FF,$07FF,
                                          $0FFF,$1FFF,$3FFF,$7FFF);
  IncTable:Table=(8,8,4,2,0);    { interlace increments }
  StarTable:Table=(0,4,2,1,0);   { interlace starts }

Function LZHDecompress(Var fp:FILE; Var pp:PAL):String;
{In theory this function should LZH decompress a GIF image block.  It was
 roughly translated from a C source "BIT-MAPPED GRAPHICS 2nd EDITION" by
 Steve Rimmer}
Var
  H:BlockHeader;
  Bits:Byte;
  Width,Depth:Integer;
{  Flags:Integer;}
  ScreenBuffer:ScreenBufferType Absolute $A000:$0000;
  Break,           {simulate flow control statments form C}
  RepeatBreak,
  Continue:Boolean;
  I,l:LongInt;

  BitsLeft,  {Number of bits left in *p}
  Bits2,     {bits plus one}
  NextCode,  {Next available table entry}
  CodeSize2, {next code size}
  OldToken,  {last symbol decoded}
  OldCode,   {Code read before this one}
  ThisCode,  {code being expanded}
  CurrentCode,
  Line,      {next line to write = 0}
  BlockSize:Integer; {bytes in next block}
  LineBuffer:LineType;  {place to store current line}
  p,        {Pointer to current byte in read buffer}
  q,        {Pointer to last byte in read buffer}
  ByteB,     {next byte to write = 0} (* I had to change byte to ByteB for Pascal compatability *)
  Pass,      {pass number for interlaced pictures = 0}
  CodeSize,  {Current code size in bits}
  u:Integer;{Stack pointer into first codestack}
  RealLine:LongInt;
  b:Array [0..254] Of Byte;
Begin
  FillChar(LineBuffer,SizeOf(LineType),$00);
  RealLine:=0;
  ByteB:=0;
  Pass:=0;
  Line:=0;
  BlockRead(fp,H,SizeOf(BlockHeader));
  If (H.Flags And $80)=$80 Then
    BlockRead(fp,pp,SizeOf(Pal));
  Bits:=fgetc(fp);
  Width:=H.X2;
  Depth:=H.Y2;

  q:=0;  p:=0;
  BitsLeft:=8;
  If (Bits<2) Or (Bits>8) Then
    Begin
      LZHDecompress:='Bad symbol size';
      Exit;
    End;
  Bits2:=1 shl bits;
  NextCode:=bits2 + 2;
  CodeSize:=Bits + 1;  (* single c line code = 2 Pascal*)
  CodeSize2:=1 Shl CodeSize;
  OldToken:=No_Code;
  OldCode:=No_Code;
  (* We skip the allocation of memory because linebuffer has been made
     a static variable rather than a pointer.  This is because linebuffer
     will always be the same size at anyway (when we use mode $13 which we
     are).  *)
  Break:=False;
  {loop until something breaks}   (* for(;;) loop *)
  While (Not KeyPressed) And (Not Break) Do
    Begin
      If bitsleft=8 Then
        Begin

            If (IncR(p)>=q) Then
              Begin
                blockSize:=fgetc(fp);
                p:=0;
                q:=fread(b,1,blocksize,fp);
              End;

          bitsleft:=0;
        End;
      thiscode:=b[p];
      CurrentCode:=(codesize+bitsleft);
      If CurrentCode<=8 Then
        Begin
          (* I am trying something a little risky.  The way SR wrote his
             function, he modified his read buffer.  I shouldn't do this
             but I will as I am writing this for the first time.  When
             I get it working (I hope) I will use something a little less
             premitive.  This is ok now because the read buffer isn't the
             HEXED edit buffer. *)

          b[p]:=b[p] shr CodeSize;
          bitsleft:=CurrentCode;
        End
      Else
        Begin

            If (IncR(p)>=q) Then
              Begin
                blockSize:=fgetc(fp);
                p:=0;
                q:=fread(b,1,blocksize,fp);
              End;

          thiscode:=thiscode Or (b[p] shl (8-bitsleft));
          If CurrentCode <= 16 Then
            Begin
              bitsleft:=currentcode-8;
              b[p]:=b[p] shr bitsleft;
            End
          Else
            Begin

              If (IncR(p)>=q) Then
                Begin
                  blockSize:=fgetc(fp);
                  p:=0;
                  q:=fread(b,1,blocksize,fp);
                End;

              thiscode:=thiscode Or (b[p] shl (16 - bitsleft));
              bitsleft:=currentcode-16;
              b[p]:=b[p] shr bitsleft;
            End;
        End;
      thiscode:=thiscode And WordMaskTable^[CodeSize];
      CurrentCode:=ThisCode;

      If ThisCode = (bits2+1) Then
        Break:=True
      Else  (* This is to impliment a simulated break *)
        Begin
          If ThisCode>NextCode Then
            Begin
              LZHDecompress:='Bad code';
              Exit;
            End;
          Continue:=False;
          If ThisCode=bits2 Then
            Begin
              NextCode:=bits2+2;
              CodeSize:=Bits+1;
              CodeSize2:=1 shl (CodeSize);
              oldcode:=No_Code;
              oldtoken:=oldcode;
              Continue:=True;
            End;
          If Not Continue Then (* This is to impliment a simulated continue *)
            Begin
              U:=0;
              If ThisCode=NextCode Then
                Begin
                  If OldCode=No_Code Then
                    Begin
                      LZHDecompress:='Bad first code';
                      Exit;
                    End;
                  FirstCodeStack^[RInc(u)]:=OldToken;
                  ThisCode:=OldCode;
                End;
              While ThisCode>=bits2 Do
                Begin
                  FirstCodeStack^[RInc(u)]:=LastCodeStack^[thiscode];
                  ThisCode:=CodeStack^[ThisCode];
                End;
              OldToken:=ThisCode;
              RepeatBreak:=False; (* simulate another break *)
              Repeat
                LineBuffer[RInc(ByteB)]:=ThisCode;
                If (ByteB>=Width) Then
                  Begin
                    If Line<MaxY Then
                      If h.x2-h.x1<=MaxX Then
                        Move(LineBuffer,GraphAcc1^[line],h.x2-h.x1)
                      Else
                        Move(LineBuffer,GraphAcc1^[line],SizeOf(StdLineType));
                    ByteB:=0;
                    {Check for interlaced image}
                    If (H.Flags And $40)=$40 Then
                      Begin
                        line:=line+inctable[Pass];
                        If line >= Depth Then
                          Begin
                            Line:=StarTable[IncR(pass)];
                          End;
                      End
                    Else
                      Inc(line);
                  End;
                If (u<=0) Then
                  RepeatBreak:=True
                Else
                  ThisCode:= FirstCodeStack^[DecR(u)];
              Until RepeatBreak;
              If (NextCode < 4096) And (OldCode <> No_Code) Then
                Begin
                  CodeStack^[NextCode]:=OldCode;
                  LastCodeStack^[NextCode]:=OldToken;
                  NextCode:=NextCode+1;
                  If (NextCode >= CodeSize2) And (CodeSize < 12) Then
                    CodeSize2:=1 shl IncR(CodeSize);
                End;
              OldCode:=CurrentCode;
            End;
        End;
    End;
  If KeyPressed Then
    Begin
      LZHDecompress:='User interrupt.  Possible infinate loop in LZHDecompress().';
      Readkey;
    End;
  fgetc(fp);
End;

{----------------------------------------------------------------------}

Function GetStacks:Boolean;
Begin
  If (MaxAvail<SizeOf(ByteCodeStackType)) Then
    Begin
      GetStacks:=False;
    End;
  New(FirstCodeStack);

  If (MaxAvail<SizeOf(ByteCodeStackType)) Then
    Begin
      GetStacks:=False;
      Dispose(FirstCodeStack);
    End;
  New(LastCodeStack);

  If (MaxAvail<SizeOf(IntCodeStackType)) Then
    Begin
      GetStacks:=False;
      Dispose(FirstCodeStack);
      Dispose(LastCodeStack);
    End;
  New(CodeStack);

  If (MaxAvail<SizeOf(WordMaskTableType)) Then
    Begin
      GetStacks:=False;
      Dispose(FirstCodeStack);
      Dispose(LastCodeStack);
      Dispose(CodeStack);
    End;
  New(WordMaskTable);
  WordMaskTable^:=DefaultWordMaskTable;
End;

{----------------------------------------------------------------------}

Procedure LooseStacks;
Begin
  Dispose(FirstCodeStack);
  Dispose(LastCodeStack);
  Dispose(CodeStack);
End;

{----------------------------------------------------------------------}

Function DrawGIFDSK(Var F:File; Var p:Pal):String;
Var
  ErrorStr:String;
  NumberOfColors:Word;
  GlobalColorMap:Boolean;
  I:Byte;
  N:Integer;
  pp:PAL;
  buff:Pointer;
  H:GifHeader;
Begin
  If Not GetStacks Then
    Begin
      DrawGIFDSK:='Not enough memory for LZH decompression';
      Exit;
    End;
  GetPal(pp);
  DrawGIFDSK:='Unidentified error.';
  Seek(F,$00);
  BlockRead(F,H,SizeOf(GifHeader));
  ErrorStr:=ReadHeader(H,NumberOfColors,GlobalColorMap);
  If (ErrorStr<>'') Then
    Begin
      DrawGIFDSK:=ErrorStr;
      LooseStacks;
      Exit;
    End;
  If (GlobalColorMap) Then
    Begin
      BlockRead(F,pp,SizeOf(PAL));
      If IOResult<>0 Then
        Begin
          DrawGIFDsk:='error reading global palette';
          LooseStacks;
          Exit;
        End;
      p:=pp;
      For I:=0 To 255 Do
        Begin
          p[I].Red   :=p[I].Red   div 4;
          p[I].Green :=p[I].Green div 4;
          p[I].Blue  :=p[I].Blue  div 4;
        End;
      SetPal(p);
    End;
  Repeat
    I:=fgetc(F);
    If I=$2C Then
      errorstr:=LZHDecompress(F,pp);
    If errorstr<>'' Then
      Begin
        DrawGIFDSK:=errorstr;
        LooseStacks;
        Exit;
      End;
  Until (I=Ord(';')) Or (I=Ord('!')) Or (I<>Ord(','));
  If I=Ord('!') Then
    Begin
      DrawGIFDSK:='There is an extension in the GIF.';
      LooseStacks;
      Exit;
    End;
  If (I<>Ord(',')) And (I<>Ord(';')) Then
    Begin
      DrawGIFDSK:='Format error. "'+Chr(I)+'" X:'+IntToStr(FilePos(F));
      LooseStacks;
      Exit;
    End;
  DrawGIFDSK:='';
  LooseStacks;
End;

{----------------------------------------------------------------------}

Function Pixels2Bytes(n:Word):Word;
Begin
  Pixels2Bytes:=((n+7) div 8);
End;

{----------------------------------------------------------------------}

Function DrawIMGMem(Var fp:FILE):String;
Var
  Header:Array[0..17] Of Byte;
  LineBuffer:LineType;
  Width,Depth,
  PatternSize,
  Bytes,RepCount:Word;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}

Function ReadIMGLine(Var P:LineType; Var fp:FILE):Integer;
Var
  j,k,n,c,i:Integer;
  pr:Word;
Begin
  n:=0;

  FillChar(P,bytes,0);

  {set the default replication count}
  repcount:=1;

  {loop 'tl the line's all decoded}
  Repeat
    c:=fgetc(fp) And $FF;

    If (c=0) Then
      Begin
        {It's a pattern or a rep}
        c:=fgetc(fp) And $FF;
        If (c=0) Then
          Begin
            {it's a rep count change}
            fgetc(fp);
            {throw away the FF}
            repcount:=fgetc(fp) And $FF;
          End
        Else
          Begin
            i:=c And $FF;
            pr:=n;

            j:=patternsize;
            While (RDec(j)>0) Do
              p[RInc(n)]:= Not fgetc(fp);

            k:=i-1;
            While (RDec(j)>0) Do
              Begin
                Move(p[n],p[pr],patternsize);
                Inc(n,patternsize);
              End;
          End;
        End
      Else If (c=$80) Then
        Begin
          {It's a string of bytes}
          i:=fgetc(fp) And $FF;
          pr:=n;
          j:=i;
          while (RDec(j)>0) Do
            p[RInc(n)]:= Not fgetc(fp);
        End
      Else If (c And $80)=80 Then
        Begin
          {It's a solid white run - note that
           it's artificially inverted here}
          i:=C And $7F;
          pr:=n;
          j:=i;
          While (RDec(j)>0) Do
            p[RInc(j)]:= $00;
        End
      Else
        Begin
          {It's a solid black run}
          i:=c And $7F;
          pr:=n;
          j:=i;
          While(RDec(j)>0) Do
            P[RInc(n)]:= $FF;
        End;
  Until n>=Bytes;
  {This should be equal to bytes - it might not be if the line was corrupted}
  ReadIMGLine:=n;
End;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}

Procedure BitDraw(Var LineBuffer:LineType; i,bytes:Word);
Var l,n:Word;
Begin
  n:=0;
  For l:=0 To Bytes Do
    Begin
      If Boolean(LineBuffer[l] And Bit8) Then
        GraphAcc1^[i,n]:=White
      Else
        GraphAcc1^[i,n]:=Black;
      Inc(n);
      If Boolean(LineBuffer[l] And Bit7) Then
        GraphAcc1^[i,n]:=White
      Else
        GraphAcc1^[i,n]:=Black;
      Inc(n);
      If Boolean(LineBuffer[l] And Bit6) Then
        GraphAcc1^[i,n]:=White
      Else
        GraphAcc1^[i,n]:=Black;
      Inc(n);
      If Boolean(LineBuffer[l] And Bit5) Then
        GraphAcc1^[i,n]:=White
      Else
        GraphAcc1^[i,n]:=Black;
      Inc(n);
      If Boolean(LineBuffer[l] And Bit4) Then
        GraphAcc1^[i,n]:=White
      Else
        GraphAcc1^[i,n]:=Black;
      Inc(n);
      If Boolean(LineBuffer[l] And Bit3) Then
        GraphAcc1^[i,n]:=White
      Else
        GraphAcc1^[i,n]:=Black;
      Inc(n);
      If Boolean(LineBuffer[l] And Bit2) Then
        GraphAcc1^[i,n]:=White
      Else
        GraphAcc1^[i,n]:=Black;
      Inc(n);
      If Boolean(LineBuffer[l] And Bit1) Then
        GraphAcc1^[i,n]:=White
      Else
        GraphAcc1^[i,n]:=Black;
      Inc(n);
    End;
End;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}

Function UnpackIMGFile(P:Pointer;  Var fp:FILE):Integer;
Var
  i,n:Integer;
  Break:Boolean;
Begin
  i:=0;
  Break:=False;
  While (i<Depth) And (Not Break) Do
    Begin
      FillChar(linebuffer,SizeOf(LineType),$00);
      n:=ReadIMGLine(linebuffer,fp);
      If i<MaxY Then
        BitDraw(LineBuffer,i,bytes);
      If n<>Bytes Then
        Break:=True
      Else
        While Boolean(RDec(Integer(RepCount))) Do
          Begin
            Move(p,linebuffer,bytes);  {memcpy()}
            IncR(i);
            p:=@mem[Seg(p^):Ofs(p^)+bytes];
          End;
    End;
  UnpackIMGFile:=n;
End;

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}

Var
  n:Integer;
  p:Pointer;
Begin
  PatternSize:=1;
  DrawIMGMem:='Unidentified error in decoding';
  Seek(fp,$00);
  fread(Header,1,18,fp);
  If (Header[0]<>0) And (Header[1]<>1) Then
    Begin
      DrawIMGMem:='signature incorrect for IMG file';
      Exit;
    End;
  If ((Header[5] And $FF)+((Header[4] And $FF) shl 8)) <> 1 Then
    Begin
      DrawIMGMem:='This isn''t a monochrome file';
      Exit;
    End;

  {Seek past the header}
  n:=((Header[3] And $FF) + ((Header[2] And $FF) shl 8)) * 2;
  fseek(fp,n);

  {allocate a big buffer}
  PatternSize:=(Header[7] And $FF) + ((Header[6] And $FF) shl 8);
  width:=(Header[13] And $FF) + ((Header[12] And $FF) shl 8);
  depth:=(Header[15] And $FF) + ((Header[14] And $FF) shl 8);
  bytes:=Pixels2Bytes(Width);

  If MaxAvail<4+Bytes*Depth Then
    Begin
      DrawIMGMem:='Not enough memory for dynamic variable';
      Exit;
    End;
  GetMem(P,4+Bytes*Depth);

  { unpack the file }
  If (UnpackIMGFile(@mem[Seg(p^):Ofs(p^)+4],fp)<>Bytes) Then
    Begin
      DrawIMGMem:='Error reading the image';
      Exit;
    End;

  FreeMem(P,4+Bytes*Depth);
  DrawIMGMem:='';
End;

{======================================================================}

End.