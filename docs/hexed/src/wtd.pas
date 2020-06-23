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
| wtd.pas
|    "write type data" or byte identification unit.  handy for finding
|    that magic cookie your looking for!
|
| History:
| Date       Author     Comment
| ----       ------     -------
| -- --- 94  G. Ollis	 created and developed program
============================================================================*)

{$I-,N+,E+}

Unit WTD;

INTERFACE

Uses
  Header;

{++PROCEDURES++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Procedure WriteTypeData(Var B:Byte;  D:DataType);

{++FUNCTIONS+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

IMPLEMENTATION

Uses
  ViewU,CRT,CFG,FUTIL,VConvert,Res,Dos;

Type
  WordPointer=^Word;

{------------------------------------------------------------------------}

Function GetVOCBlock(Var D:DataType; Var blkLen:LongInt):LongInt;
Var X:LongInt; L:LongInt;  FN:String;
Begin
  D.X:=D.X+1;
  If D.X+D.offset>D.EOF Then
    Begin
      GetVOCBlock:=-1;
      Exit;
    End;
  X:=GetFileWord(D.stream,20)+1;
  CheckIOError('getting data .voc offset',100);
  While X<=ImageSize Do
    Begin
      If X<D.EOF Then
        L:=GetFileLong(D.stream,X);
      CheckIOError(' getting blklen from .voc file',100);
      L:=(L And $FFFFFF)+4;
      If X<=D.X+D.offset Then
        Begin
          GetVOCBlock:=X;
          blkLen:=L-4;
        End;
      If X>D.X+D.offset Then
        Exit;
      X:=X+L;
    End;
  GetVOCBlock:=-1;
End;

{------------------------------------------------------------------------}

Function GetMaxPattern(Var D:DataType):LongInt;
Var I:Word;  Max:Byte;  B:Byte;
Begin
  Max:=0;
  If D.BFT=9 Then
    B:=GetFileByte(D.stream,$3B6)
  Else If D.BFT=10 Then
    B:=GetFileByte(D.stream,$1D6);
  If B=0 Then
    Begin
      GetMaxPattern:=0;
      Exit;
    End;
  If D.BFT=9 Then
    Begin
      For I:=0 To B-1 Do
        If GetFileByte(D.stream,$3B8+I)>Max Then
          Max:=GetFileByte(D.stream,$3B8+I)
    End
  Else
    For I:=0 To B-1 Do
      If GetFileByte(D.stream,$1D8+I)>Max Then
        Max:=GetFileByte(D.stream,$1D8+I);
  GetMaxPattern:=Max;
End;

{----------------------------------------------------------------------}

Function GetTime(L:LongInt):String;
Var
  DT:DateTime;
  Answer:String;
Begin
  UnPackTime(L,DT);
  Answer:=IntToStr(DT.Hour,0)+':'+IntToStr(DT.Min,2)+':'+IntToStr(DT.Sec,2)+'  ';
  Answer:=Answer+IntToStr(DT.Day,0)+' ';
  Case DT.Month Of
    1 : Answer:=Answer+'Jan ';
    2 : Answer:=Answer+'Feb ';
    3 : Answer:=Answer+'Mar ';
    4 : Answer:=Answer+'Apr ';
    5 : Answer:=Answer+'May ';
    6 : Answer:=Answer+'Jun ';
    7 : Answer:=Answer+'Jul ';
    8 : Answer:=Answer+'Aug ';
    9 : Answer:=Answer+'Sep ';
    10: Answer:=Answer+'Oct ';
    11: Answer:=Answer+'Nov ';
    12: Answer:=Answer+'Dec ';
  End;
  Answer:=Answer+IntToStr(DT.Year,0);

  GetTime:=Answer;
End;

{----------------------------------------------------------------------}

Procedure WriteTypeData(Var B:Byte;  D:DataType);
Var
  P:^MultType;
  CmfHead:CMFHeadType;
  CMFPoint:^CMFHeadType;
  L,blkLen:LongInt;
  BT:Byte;
Begin
  If AltMode=StdMode Then
    Begin
      P:=@B;
      If (D.X>=$FFFF-20) Then
        P:=@D.D^[$FFFF-20];
      GotoXY(1,6);
      TextAttr:=ICFG.Lolight;
      Write('Shortint ');
      TextAttr:=ICFG.Numbers;
      Write(P^.S:12);
      TextAttr:=ICFG.Lolight;
      Write(' Integer ');
      TextAttr:=ICFG.Numbers;
      Write(P^.I:10);
      TextAttr:=ICFG.Lolight;
      Write(' LongInteger ');
      TextAttr:=ICFG.Numbers;
      Writeln(P^.L:16);
      TextAttr:=ICFG.Lolight;
      Write('Real     ');
      TextAttr:=ICFG.Numbers;
      If CheckOverflow('R',@D.D^[D.X]) Then
        Write('Overflow':12)
      Else
        Write(P^.R:12);
      TextAttr:=ICFG.Lolight;
      Write(' Single  ');
      TextAttr:=ICFG.Numbers;
      If CheckOverflow('S',@D.D^[D.X]) Then
        Write('Overflow':10)
      Else
        Write(P^.R:9);
      TextAttr:=ICFG.Lolight;
      Write(' Double      ');
      TextAttr:=ICFG.Numbers;
      If CheckOverflow('D',@D.D^[D.X]) Then
        Writeln('Overflow':16)
      Else
        Writeln(P^.D:16);
      TextAttr:=ICFG.Lolight;
      Write('Extended ');
      TextAttr:=ICFG.Numbers;
      If CheckOverflow('X',@D.D^[D.X]) Then
        Write('Overflow':20)
      Else
        Write(P^.E:20);
      TextAttr:=ICFG.Lolight;
      Write('            Comp    ');
      TextAttr:=ICFG.Numbers;
      IF CheckOverflow('C',@D.D^[D.X]) Then
        Writeln('Overflow':20)
      Else
        Writeln(P^.C:20);
    End;
  If (AltMode=Byte4Mode) Or (AltMode=ThirdView) Then
    Begin
      Window(1,Resolution-1,80,Resolution-1); {24} {24}
      TextAttr:=Blue * $10 or White;
    End;

  TextAttr:=ICFG.Highlight;
  ClrEol;
  If (D.BFT=1) Then
    Case AltMode Of
      0 : Write('Primary View Mode');
      1 : Write('Secondary View Mode             Press Ctrl and Shift for more commands');
      2 : Write('Third View Mode');
    Else
      Write('Unknown View Mode');
    End
  Else If (D.BFT=3) Then
    Begin
      If (D.X mod 3)=0 Then
        Write('BLUE  ');
      If (D.X mod 3)=1 Then
        Write('RED   ');
      If (D.X mod 3)=2 Then
        Write('GREEN ');
      Write(((D.X-1) div 3):4);
      Write('  (BYTE)');
    End
  Else If D.BFT=2 Then
    Begin
      Case D.X+D.offset Of
        1 :     Write('MANUFACTURER should be $A0   (BYTE)            ');
        2 :     Write('VERSION (0=2.5,2=2.8,3=2.8,5=3.0+)  (BYTE)     ');
        3 :     Write('ENCODING should be $01  (BYTE)                 ');
        4 :     Write('BITS_PER_PIXEL size of pixels  (BYTE)          ');
        5,6 :   Write('XMIN image origin  (INTEGER)                   ');
        7,8 :   Write('YMIN image origin  (INTEGER)                   ');
        9,10 :  Write('XMAX image dimensions  (INTEGER)               ');
        11,12 : Write('YMAX image dimensions  (INTEGER)               ');
        13,14 : Write('HRES resolution valuse  (INTEGER)              ');
        15,16 : Write('VRES resolution valuse  (INTEGER)              ');
        65    : Write('RESERVED  (BYTE)                               ');
        66    : Write('COLOR_PLAINS  (BYTE)                           ');
        67,68 : Write('BYTES_PER_LINE  (INTEGER)                      ');
        69,70 : Write('PALETTE_TYPE (1=Greay scale, 2=color) (INTEGER)');
      End;
      If (D.X+D.offset>16) And (D.X+D.offset<=16+48) Then
        Write('EGA_PALETTE  (ARRAY [1..48] OF BYTE)           ')
      Else If (D.X+D.offset>70) And (D.X+D.offset<70+58) Then
        Write('FILLER space for future expansion (BYTE)       ')
      Else If (D.X+D.offset>=D.EOF-256*3+1) Then
        Begin
          If (D.D^[D.EOF-D.offset-256*3]=$0C) Then
            Write('VGA_PALETTE  (ARRAY [1..255*3] OF BYTE)        ')
          Else
            Write('IMAGE_DATA ... (...)                           ');
        End
      Else If  (D.X+D.offset=D.EOF-256*3) And (D.D^[D.X]=$0C) Then
        Write('BEGINNING_OF_PALETTE should be $0C (BYTE)        ')
      Else If (D.X+D.offset>70+58) And (D.X+D.offset<D.EOF-256*3) Then
        Write('IMAGE_DATA ... (...)                           ');
    End
  Else If (D.BFT=4) Then
    Begin
      Case D.X+D.offset-1 Of
        0,1,2,3 : Write('FILE_ID should be ''CTMF'' (ARRAY [0..3] OF CHAR)              ');
        4,5     : Write('VERSION we support 1.10 (2 BYTES)                              ');
        6,7     : Write('INSTRUMENT_OFFSET where are the instruments (WORD)             ');
        8,9     : Write('MUSIC_OFFSET where is the music block (WORD)                   ');
        $A,$B   : Write('TICKS_PER_QUARTER_NOTE one beat (WORD)                         ');
        $C,$D   : Write('CLOCK_TICKS_PER_SECOND Timmer 0 frequency in Hz (WORD)         ');
        $E,$F   : Write('OFFSET_MUSIC_TITLE offset of title in bytes (0 no title) (WORD)');
        $10,$11 : Write('OFFSET_COMPOSER_NAME 0 if no composer name (WORD)              ');
        $12,$13 : Write('OFFSET_REMARKS 0 if no remarks (WORD)                          ');
        $24,$25 : Write('NUMBER_INSTRUMENTS given to fm driver (WORD)                   ');
        $26,$27 : Write('BASIC_TEMPO main tempo used in the music (WORD)                ');
      End;
      D.X:=D.X-1;
      If (D.X+D.offset>=$14) And (D.X+D.offset<=$23) Then
        Write('CHANNEL_IN_USE_TABLE which of 16 channels is used (16 BYTE)    ');
      If (D.X+D.offset>$27) Then
        Begin
          If D.offset<>0 Then
            Begin
              Seek(D.stream,0);
              BlockRead(D.stream,CMFHead,SizeOf(CMFHead));
            End
          Else
            Begin
              CmfPoint:=@D.D^;
              CMFHead:=CMFPoint^;
            End;
          If (D.X+D.offset>CMFHead.InstrumentOffset-1) And
             (D.X+D.offset<(CMFHead.InstrumentOffset+CMFHead.NumInstruments*16)) Then
            Begin
              Write('INSTRUMENT_BLOCK sbi fields (ARRAY [1..x,1..16] OF BYTE)');
              Write((D.X+D.offset-CMFHead.InstrumentOffset) div 16,',',(D.X+D.offset-CMFHead.InstrumentOffset) mod 16,
                    '    ');
            End
          Else If (D.X+D.offset>CMFHead.MusicOffset) Then
            Write('MUSIC_BLOCK smf format (bunch of bytes)                 ')
          Else
            Write('UNIDENTIFIED BYTE                                              ');
        End;
    End
  Else If D.BFT=5 Then
    Begin
      D.X:=D.X-1;
      Case D.X+D.offset Of
        0,1,2,3  : Write('FILE_ID should be ''SBI''#26 (ARRAY [0..3] OF CHAR)       ');
        $24      : Write('MODULATOR_SOUND_CHARACTERISTIC (BYTE)                     ');
        $25      : Write('CARRIER_SOUND_CHARACTERISTIC (BYTE)                       ');
        $26      : Write('MODULATOR_SCALING/OUTPUT_LEVEL (BYTE)                     ');
        $27      : Write('CARRIER_SCALING/OUTPUT_LEVEL (BYTE)                       ');
        $28      : Write('MODULATOR_ATTACK/DECAY (BYTE)                             ');
        $29      : Write('CARRIER ATTACK/DECAY (BYTE)                               ');
        $2A      : Write('MODULATOR_SUSTAIN_LEVEL/RELESE_RATE (BYTE)                ');
        $2B      : Write('CARRIER_SUSTAIN_LEVEL/RELEASE_RATE (BYTE)                 ');
        $2C      : Write('MODULATOR_WAVE_SELECT (BYTE)                              ');
        $2D      : Write('CARRIER_WAVE_SELECT (BYTE)                                ');
        $2E      : Write('FEEDBACK/CONNECTION (BYTE)                                ');
      End;
      If (D.X+D.offset>=4) And (D.X+D.offset<=$23) Then
        Write('INSTRUMENT NAME all zero if none ($4-$23 null term string)')
      Else If (D.X+D.offset>=$2F) And (D.X+D.offset<=$33) Then
        Write('RESERVED FOR FUTURE USE empty filler                      ')
      Else If (D.X+D.offset>$2E) Then
        Write('UNIDENTIFIED BYTE                                         ');
    End
  Else If D.BFT=6 Then
    Begin
      ClrEol;
      D.X:=D.X-1;
      If D.X+D.offset<6 Then
        Write('GIF signature string.  should be "GIF87a" or "GIF89a"');
      Case D.X+D.offset Of
        $6,$7   : Write('SCREEN_WIDTH size of x (WORD)');
        $8,$9   : Write('SCREEN_DEPTH size of y (WORD)');
        $A      : Begin
                    Write('FLAGS ',(1 shl ((D.D^[11] And 7)+1)),' colors ');
                    If (D.D^[11] And $80)=$80 Then
                      Write('global palette ')
                    Else
                      Write('no global palette ');
                    Write('(BYTE)');
                  End;
        $B      : Write('BACKGROUND pal[BACKGROUND]=bk color (BYTE)');
        $C      : Write('ASPECT safe to ignore (89a only) (BYTE)');
      End;
      If (D.X+D.offset<781) And (D.X+D.offset>$C) And ((GetFileByte(D.stream,13) And $80)=$80) Then
        Write('global palette table')
      Else If (D.X+D.offset>$C) And (D.X+D.offset<D.EOF) Then
        Write('image data')
      Else If (D.X+D.offset>$C) Then
        Write('unidentified byte');
    End
  Else If D.BFT=7 Then
    Begin
      D.X:=D.X-1;
      ClrEol;
      If (D.X+D.offset<=$13) Then
        Write('FILE_TYPE_DESCRIPTION should be ''Creative Voice File''#$1A (ARRAY [$13] OF CHAR)');
      Case D.X+D.offset Of
        $14,$15 : Write('OFFSET_OF_DATA_BLOCK position in file (WORD)');
        $16,$17 : Write('FORMAT_VERSION current version 1.10 (WORD)');
        $18,$19 : Write('FILE_ID_CODE should be $1129 (WORD)');
      End;
       If D.X+D.offset>GetFileWord(D.stream,20)-1 Then
        Begin
          L:=GetVOCBlock(D,blkLen);
          BT:=GetFileByte(D.stream,L-1);
          If IOResult<>0 Then
            BT:=0;
          Case BT Of
            0 : Write('Terminator EOF blk ');
            1 : Write('Voice data blk ');
            2 : Write('Voice continuation blk ');
            3 : Write('Silence blk ');
            4 : Write('Marker blk ');
            5 : Write('ASCII text blk ');
            6 : Write('Repeat loop blk ');
            7 : Write('End repeat loop blk ');
            8 : Write('Extended blk ');
            9 : Write('New voice data blk ');
          End;
          If BT>9 Then
            Write('Unknown blk ');
          If BT=D.X+D.offset Then
            Write('block determiner');
          If (BT<>0) And (D.X+D.offset>L) And (D.X+D.offset<L+4) Then
            Write('24-bit BLKLEN ',blkLen);
          If (D.X+D.offset=L+4) And (BT=1) Then
            Write('TC - time constant (BYTE)');
          If (D.X+D.offset=L+5) And (BT=1) Then
            Write('PACK - packing methoud for sub blk (BYTE)');
          If ((D.X+D.offset>L+5) And (BT=1)) Or
             ((D.X+D.offset>L+3) And (BT=2)) Or
             ((D.X+D.offset>L+15) And (BT=9)) Then
            Write('VOICE DATA');
          If ((D.X+D.offset=L+4) Or (D.X+D.offset=L+5)) And (BT=3) Then
            Write('PERIOD - length of silence (WORD)');
          If (D.X+D.offset=L+6) And (BT=3) Then
            Write('TC - time constant (BYTE)');
          If ((D.X+D.offset=L+4) Or (D.X+D.offset=L+5)) And (BT=4) Then
            Write('MARKER - marker number (WORD)');
          If (D.X+D.offset>L+4) And (BT=5) Then
            Write('ASCII_DATA - null terminated');
          If ((D.X+D.offset=L+4) Or (D.X+D.offset=L+5)) And (BT=6) Then
            Write('COUNT - number of loops $FFFF endless loop (WORD)');
          If ((D.X+D.offset=L+4) Or (D.X+D.offset=L+5)) And (BT=8) Then
            Write('TC - time constant (WORD)');
          If (D.X+D.offset=L+6) And (BT=8) Then
            Write('PACK - packing methoud for sub blk (BYTE)');
          If (D.X+D.offset=L+7) And (BT=8) Then
            Write('MODE - mono or stero (0m,1s) (BYTE)');
          If (D.X+D.offset>=L+4) And (D.X+D.offset<=L+7) And (BT=9) Then
            Write('SAMPLES_PER_SEC - sampling freq (LONGWORD)');
          If (D.X+D.offset=L+8) And  (BT=9) Then
            Write('BITS_PER_SAMPLE - bps after compressiong (BYTE)');
          If (D.X+D.offset=L+9) And (BT=9) Then
            Write('CHANNELS - 1=mono 2=stereo (BYTE)');
          If ((D.X+D.offset=L+10) Or (D.X+D.offset=L+11)) And (BT=9) Then
            Write('FORMAT_TAG - see other source (WORD)');
          IF (D.X+D.offset>=L+12) And (D.X+D.offset<=L+15) And (BT=9) Then
            Write('RESERVED - for future use (ARRAY [0..3] OF BYTE)');
          If L=-1 Then
            Begin
              GotoXY(1,WhereY);
              ClrEol;
              Write('blk not found ');
            End;
        End;
    End
  Else If D.BFT=8 Then
    Begin
      ClrEol;
      Case (D.X+D.offset) Of
        $1,$2  : Write('ID should be $0001 for IMG (rvWORD)');
        $3,$4  : Write('HEADER_WORDS number of words in header, should be 8 or 9 (rvWORD)');
        $5,$6  : Write('IMAGE_PLANES number of grey level plains, shoult be 1 for monochrome (rvWORD)');
        $7,$8  : Write('PATTERN_LENGTH usually 1 (rvWORD)');
        $9,$A  : Write('PIXEL_WIDTH (rvWORD)');
        $B,$C  : Write('PIXEL_DEPTH (rvWORD)');
        $D,$E  : Write('LINE_WIDTH (rvWORD)');
        $F,$10 : Write('IMAGE_DEPTH (rvWORD)');
      End;
      If ((D.X+D.offset=$11) Or (D.X+D.offset=$12)) Then
        Begin
          If (D.D^[$4]=$9) Then
            Write('EXTRA (OPTIONAL) (rvWORD)')
          Else
            Write('IMAGE_DATA (...)');
        End
      Else If D.X+D.offset>$12 Then
        Write('IMAGE_DATA (...)');
    End
  Else If D.BFT=9 Then
    Begin
      Dec(D.X);
      If (D.offset+D.X<$14) Then
        Write('SONG_NAME null terminated string')
      Else If (D.offset+D.X<$3B6) Then
        Begin
          Write('INSTRUMENT');
          Write((D.offset+D.X-$14) div 30);
          L:=D.offset+D.X-$14-((D.offset+D.X-$14) div 30)*30;
          If L<22 Then
            Write('_NAME null terminated string')
          Else If L<23 Then
            Write('_LENGTH ',Swap(D.D^[D.X+1]):6,' $',
                    Word2Str(Swap(D.D^[D.X+1])),'(rvWORD)')
          Else If L<24 Then
            Write('_LENGTH ',Swap(D.D^[D.X]):6,' $',
                    Word2Str(Swap(D.D^[D.X])),'(rvWORD)')
          Else If L<25 Then
            Write('_FINETUNE')
          Else If L<26 Then
            Write('_LOUDNESS 0-64 (BYTE)')
          Else If L<27 Then
            Write('_REPEATLOOP ',Swap(D.D^[D.X+1]):6,' $',
                    Word2Str(Swap(D.D^[D.X+1])),' (rvWORD)')
          Else If L<28 Then
            Write('_REPEATLOOP ',Swap(D.D^[D.X]):6,' $',
                    Word2Str(Swap(D.D^[D.X])),' (rvWORD)')
          Else If L<29 Then
            Write('_REPEATLENGTH ',Swap(D.D^[D.X+1]):6,' $',
                    Word2Str(Swap(D.D^[D.X+1])),' (rvWORD)')
          Else If L<30 Then
            Write('_REPEATLENGTH ',Swap(D.D^[D.X]):6,' $',
                    Word2Str(Swap(D.D^[D.X])),' (rvWORD)')
          Else
            Write('_unidentified');
        End
      Else If (D.offset+D.X<$3B7) Then
        Write('SONG_LENGTH #patterns played (BYTE)')
      Else If (D.offset+D.X<$3B8) Then
        Write('SONG_CIAASPEED important for Amiga. usually 127 $7F (BYTE)')
      Else If (D.offset+D.X<$438) Then
        Write('SONG_ARRANGEMENT max:',GetMaxPattern(D):4,' $',Byte2Str(GetMaxPattern(D)),
              ' playback order (ARRAY [0..127] OF BYTE)')
      Else If (D.offset+D.X<$43C) Then
        Write('SONG_ID "M.K." or "FLT4" for MOD31 (ARRAY [0..3] OF CHAR)')
      Else If (D.offset+D.X<$43C+(GetMaxPattern(D)+1)*1024) Then
        Begin
          Write('PATTERN',((D.offset+D.X)-$43C) div 1024,'_NOTE',
                ((D.offset+D.X)-($43C+(((D.offset+D.X)-$43C) div 1024)*1024)) div 4,' ');
          Case (((D.offset+D.X)-($43C+(((D.offset+D.X)-$43C) div 1024)*1024)) mod 4) Of
            0 : Write('high bits of instrument numbers (LONGWORD)');
            1 : Write('12bit pitch (LONGWORD)');
            2 : Write('low bits of instrument number (LONGWORD)');
            3 : Write('12bit effect argument (LONGWORD)');
          End;
        End
      Else
        Write('INSTRUMENT_DATA (...)');
      For L:=WhereX To 79 Do
        Write(' ');
      Inc(D.X);
    End

(* MOD15 *)

  Else If D.BFT=10 Then
    Begin
      Dec(D.X);
      If (D.X+D.offset<$14) Then
        Write('SONG_NAME null terminated string')
      Else If (D.X+D.offset<$1D6) Then
        Begin
          Write('INSTRUMENT');
          Write((D.offset+D.X-$14) div 30);
          L:=D.offset+D.X-$14-((D.offset+D.X-$14) div 30)*30;
          If L<22 Then
            Write('_NAME null terminated string')
          Else If L<23 Then
            Write('_LENGTH ',Swap(D.D^[D.X+1]):6,' $',
                    Word2Str(Swap(D.D^[D.X+1])),'(rvWORD)')
          Else If L<24 Then
            Write('_LENGTH ',Swap(D.D^[D.X]):6,' $',
                    Word2Str(Swap(D.D^[D.X])),'(rvWORD)')
          Else If L<25 Then
            Write('_FINETUNE')
          Else If L<26 Then
            Write('_LOUDNESS 0-64 (BYTE)')
          Else If L<27 Then
            Write('_REPEATLOOP ',Swap(D.D^[D.X+1]):6,' $',
                    Word2Str(Swap(D.D^[D.X+1])),' (rvWORD)')
          Else If L<28 Then
            Write('_REPEATLOOP ',Swap(D.D^[D.X]):6,' $',
                    Word2Str(Swap(D.D^[D.X])),' (rvWORD)')
          Else If L<29 Then
            Write('_REPEATLENGTH ',Swap(D.D^[D.X+1]):6,' $',
                    Word2Str(Swap(D.D^[D.X+1])),' (rvWORD)')
          Else If L<30 Then
            Write('_REPEATLENGTH ',Swap(D.D^[D.X]):6,' $',
                    Word2Str(Swap(D.D^[D.X])),' (rvWORD)')
          Else
            Write('_unidentified');
        End
      Else If (D.X+D.offset<$1D7) Then
        Write('SONG_LENGTH #patterns played (BYTE)')
      Else If (D.X+D.offset<$1D8) Then
        Write('SONG_CIAASPEED important for Amiga. usually 127 $7F (BYTE)')
      Else If (D.X+D.offset<$258) Then
        Write('SONG_ARRANGEMENT max:',GetMaxPattern(D):4,' $',
              Byte2Str(GetMaxPattern(D)),' playback order (ARRAY [0..127] OF BYTE)')
      Else If (D.X+D.offset<$258+(GetMaxPattern(D)+1)*1024) Then
        Begin
          Write('PATTERN',((D.offset+D.X)-$258) div 1024,'_NOTE',
                ((D.offset+D.X)-($258+(((D.offset+D.X)-$258) div 1024)*1024)) div 4,' ');
          Case (((D.offset+D.X)-($258+(((D.offset+D.X)-$258) div 1024)*1024)) mod 4) Of
            0 : Write('high bits of instrument numbers (LONGWORD)');
            1 : Write('12bit pitch (LONGWORD)');
            2 : Write('low bits of instrument number (LONGWORD)');
            3 : Write('12bit effect argument (LONGWORD)');
          End;
        End
      Else
        Write('INSTRUMENT_DATA (...)');
      Inc(D.X);
    End

(* IBK *)

  Else If D.BFT=11 Then
    Begin
      If D.X+D.offset<$5 Then
        Write('FILEID ASCII string "IBK"#$1A (ARRAY [0..3] OF CHAR)')
      Else IF D.X+D.offset<$805 Then
        Begin
          Write('INSTRUMENT',(D.X+D.offset-5) div $10);
          Case (D.X+D.offset-5) mod $10 Of
            $0  : Write('_MODULATORE_SOUND_CHARACTERISTIC (BYTE)');
            $1  : Write('_CARRIER_SOUND_CHARACTERISTIC (BYTE)');
            $2  : Write('_MODULATOR_SCALING/OUTPUT_LEVEL (BYTE)');
            $3  : Write('_CARRIOR_SCALING/OUTPUT_LEVEL (BYTE)');
            $4  : Write('_MODULATOR_ATTACK/DELAY (BYTE)');
            $5  : Write('_CARRIOR_ATTACK/DELAY (BYTE)');
            $6  : Write('_MODULATOR_SUSTAIN_LEVEL/RELEASE_RATE (BYTE)');
            $7  : Write('_CARRIER_SUSTAIN_LEVEL/RELEASE_RATE (BYTE)');
            $8  : Write('_MODULATOR_WAVE_SELECT (BYTE)');
            $9  : Write('_CARRIER_WAVE_SELECT (BYTE)');
            $A  : Write('_FEEDBACK/CONNECTION (BYTE)');
            $B,$C,$D,$E,$F :
                  Write('_RESERVED for future update (ARRAY [0..4] OF BYTE)');
          End;
        End
      Else If D.X+D.offset<$C85 Then
        Write('NAME',(D.X+D.offset-$805) div 9,
              ' null terminated string (ARRAY [0..8] OF CHAR)')
      Else
        Write('unidentified byte');
    End
  Else If D.BFT=12 Then
    Begin
      Dec(D.X);
      Case D.X Of
        0,1,2,3 : Write('LENGTH of file in bytes (LONGINT)');
        4,5     : Write('MAGIC identifier should by $AF11 (WORD)');
        6,7     : Write('FRAMES # of frames in FLI (WORD)');
        8,9     : Write('WIDTH number of pixels per row should be 320 (WORD)');
        10,11   : Write('HEIGHT number of pixels per colum should be 200 (WORD)');
        12,13   : Write('DEPTH number of bits per pixel should be 8 (WORD)');
        14,15   : Write('FLAGS must be 0 (WORD)');
        16,17   : Write('SPEED number of video ticks between frames (WORD)');
        18,19,20,21,22,23,24,25
                : Write('NEXT/FRIT set to 0 (2*LONGINT)');
      End;
      If (D.X>25) And (D.X<26+102) Then
        Write('EXPAND all zeros -- for future enhancement');
      If (D.X>26+102) Then
        Write('unidentified byte');
      Inc(D.X);
    End
  Else If D.BFT=13 Then
    Begin
      If D.X+D.offset> (D.FragOffset + 1) Then
        Writeln('DATA (...)')
      Else
        Begin
          Case D.X+D.offset Of
            1,2,3 : Write('FileID should be ''FRG'' (ARRAY [1..3] OF CHAR)');
            5 : Write('INDEX (WORD) ',D.D^[D.X]);
            6,7,8,9 : Write('TIME Packed Time of Compression (LONGWORD) ',GetTime(LongInt((@D.D^[6])^)));
            10,11,12,13 : Write('OFFSET where the file should be put in the destination file (LONGWORD) ',
                                LongInt((@D.D^[10])^));
            14,15,16,17 : Write('TOTAL_SIZE size of original file (LONGWORD) ',LongInt((@D.D^[14])^));
          End;
          If D.X+D.offset=4 Then
            Begin
              If D.D^[D.X]=0 Then
                Write('VERSION_NUMBER corresponds with UN/FRAG v2.04 (BYTE)')
              Else If D.D^[D.X]=1 Then
                Write('VERSION_NUMBER corresponds with UN/FRAG v2.05 (BYTE)')
              Else If D.D^[D.X]=2 Then
                Write('VERSION_NUMBER corresponds with UN/FRAG v3.00 (BYTE)')
              Else
                Write('VERSION_NUMBER unknown version              (BYTE)');
            End
          Else If (D.X+D.offset>17) And (D.X+D.offset<31) Then
            Write('SOURCE_FILE_NAME (STRING[12])')
          Else If (D.X+D.offset>30) And (D.X+D.offset<33) Then
            Write('HEADER_SIZE (WORD)')
          Else If (D.X+D.offset=33) Then
            Write('FRAG_MODE 0=specific size 1=variable size (BYTE)')
          Else If (D.X+D.offset>33) And (D.X+D.offset<38) Then
            Write('FRAG_SIZE estimated size of each fragment (LONG)')
          Else If (D.X+D.offset=37) And (D.X+D.offset=38) Then
            Write('UNIX_MODE octal permission ', Octal2Permission(D.D^[37]), ' (WORD)')
          Else If (D.X+D.offset>38) And (D.X+D.offset<43) Then
            Write('UNIX_UID user ID on unix                  (LONG)')
          Else If (D.X+D.offset>42) And (D.X+D.offset<47) Then
            Write('UNIX_GID group ID on unix                 (LONG)')
          Else If (D.X+D.offset>46) And (D.X+D.offset<51) Then
            Write('FILE_NAME pointer to a perl scaler filename (LONG)')
          Else If (D.X+D.offset>50) And (D.X+D.offset<55) Then
            Write('FILE_NAME length of string                (LONG)')
          Else If D.X+D.offset>37 Then
            Write('perl scaler representing file name');
        End;
    End
  Else If D.BFT=14 Then
    Begin
      Dec(D.X);
      If D.X+D.offset<2 Then
        Case Word(WordPointer(D.D)^) Of
          $5A4D : Write('SIGNATURE .exe file (2 BYTEs)');
          $4D5A : Write('SIGNATURE .com file (2 BYTEs)');
        Else
          Write('SINGNATURE .??? file (2 BYTEs)');
        End
      Else If D.X+D.offset<$1C Then
        Case D.X+D.offset Of
          $02,$03 : Write('number of bytes in last 512-byte page of executable (WORD)');
          $04,$05 : Write('total number of 512-byte pages in executable (WORD)');
          $06,$07 : Write('number of relocation entries (WORD)');
          $08,$09 : Write('header size in paragraphs (WORD)');
          $0A,$0B : Write('minimum paragraphs to allocate in addition to exe''s size (WORD)');
          $0C,$0D : Write('maximum paragraphs to allocate in addition to exe''s size (WORD)');
          $0E,$0F : Write('initial SS relative to start of executable (WORD)');
          $10,$11 : Write('initial SP (WORD)');
          $12,$13 : Write('checksum (WORD)');
          $14,$15,
          $16,$17 : Write('initial CS:IP relative to start of executable (DWORD)');
          $18,$19 : Write('offset within header of relocation table (WORD)');
          $1A,$1B : Write('overlay number (WORD)');
        End
      Else If (D.X+D.offset>=D.ED.OffRlc) And
              (D.X+D.offset<D.ED.OffRlc+D.ED.NumRlc*4) Then
        Write('relocation table #',(D.X+D.offset-D.ED.OffRlc) div 4,' (DWORD)')
      Else If D.X+D.offset<D.ED.HeadSize Then
        Begin
          If D.ED.Tp=0 Then
          Else If D.ED.Tp=1 Then
            Begin
              Write('[new exe] ');
              If D.X+D.offset<$40 Then
                Case D.X+D.offset Of
                  $1C,$1D,$1E,$1F : Write('???? (4 BYTEs)');
                  $20,$21         : Write('behavior bits (WORD)');  {*}
                  $3C,$3D,$3E,$3F : Write('offset of new executable (DWORD)');
                Else
                  Write('reserved for additional behavior info (26 BYTEs)');
                End;
            End
          Else If D.ED.Tp=2 Then
            Begin
              Write('[Borland TLINK] ');
              Case D.X+D.offset Of
                $1C : Write('apparently always $01 (BYTE)');
                $1D : Write('apparently always $00 (BYTE)');
                $1E : Write('SIGNATURE2 should be $FB (BYTE)');
                $1F : Write('VERSION ',((D.D^[D.X+1] And $F0) shr 4)+1,'.',(D.D^[D.X+1] And $F),' (BYTE)');
                $20 : Write('apparently always $72 (v2.0) or $6A (v3.0+)');
                $21 : Write('apparently always $6A (v2.0) or $72 (v3.0+)');
              End;
            End
          Else If D.ED.Tp=3 Then
            Begin
              Write('[ARJ Self-extracting archive] ');
              If (D.X+D.offset>=$1C) And (D.X+D.offset<=$1F) Then
                Write('SIGNATURE2 should be "RJSX" (ARRAY [1..4] OF CHAR)');
            End
          Else If D.ED.Tp=4 Then
            Begin
              Write('[LZEXE 0.90 compressed exe] ');
              If (D.X+D.offset>=$1C) And (D.X+D.offset<=$1F) Then
                Write('SIGNATURE2 should be "LZ09" (ARRAY [1..4] OF CHAR)');
            End
          Else If D.ED.Tp=5 Then
            Begin
              Write('[LZEXE 0.91 compressed exe] ');
              If (D.X+D.offset>=$1C) And (D.X+D.offset<=$1F) Then
                Write('SIGNATURE2 should be "LZ91" (ARRAY [1..4] OF CHAR)');
            End
          Else If D.ED.Tp=9 Then
            Begin
              Write('[TopSpeed C 3.0 CRUNCH compressed file] ');
              If (D.X+D.offset>=$1C) And (D.X+D.offset<=$1F) Then
                Write('$01A0001 (DWORD)');
              If (D.X+D.offset>=$20) And (D.X+D.offset<=$21) Then
                Write('$1565 (WORD)');
            End
          Else If D.ED.Tp=10 Then
            Begin
              Write('[PKARCK 3.5 SFA] ');
              If (D.X+D.offset>=$1C) And (D.X+D.offset<=$1F) Then
                Write('$00020001 (DWORD)');
              If (D.X+D.offset>=$20) And (D.X+D.offset<=$21) Then
                Write('$0700 (WORD)');
            End
          Else If D.ED.Tp=11 Then
            Begin
              Write('[BSA (Soviet archiver) SFA] ');
              Case D.X+D.offset Of
                $1C,$1D : Write('$000F (WORD)');
                $1E     : Write('$A7 (BYTE)');
              End;
            End;
        End;
      Inc(D.X);
    End
  Else
    Write('                                                                 ');
End;

{======================================================================}

End.