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
| header.pas
|    this is the eqivalent to a .h file in C.  it contains all the global
|    definitions that are important to everything.  what a mess.
|
| History:
| Date       Author     Comment
| ----       ------     -------
| -- --- 94  G. Ollis	 created and developed program
============================================================================*)

{$I-}

Unit Header;

INTERFACE

Uses
  CRT,ChFile;

Type
  ConfigerationType=Record
    Case Boolean Of
      TRUE :
          (Highlight,Lolight,Numbers,InputColor:Byte;
          HelpWindow,HelpColor:Byte;
          StatusVer,StatusFN,StatusSave,StatusMid:Byte;
          Error:Byte;
          MsgColor,MsgLolight,MsgChoice:Byte;
          BOF_Color,EOF_Color,Block_Color:Byte;
          MenuLolight,MenuHilight,MenuDisab:Byte);
      FALSE : (ByteArr:Array [1..20] of Byte)
  End;
  MacroIndex=Record
    Num:Byte;
    Data:Array [1..$FF] of Byte;
    Name:String[20];
  End;
  MacroType=Array [0..9] of MacroIndex;

Const
  versionnumber='1.60';      {stores the version number so I only have to
                              change it in one place}

Var
  ICFG:ConfigerationType;

Type
  FormatType=String[10];

Const
  BlockColor=Cyan;

  Bookend=300;              (* number of bytes we will be sure to stay away
                               from either side of the image*)
  imagesize=$FFFF;          {maximum size of file that HEXED can edit/view}
                            (* size of the buffer used in file viewing/editing*)
  maxlong=$7FFFFFFF;        (* maximum value for a longint, maximum file size
                               for hexed (in theory)*)
  helpfile='HEXED.HLP';     {name of the help file (text format)}
  MaxHelp=84;               {maximum number of lines in the help file}
  HelpY1=12;                {location of help window}
  HelpY2=24;

  DataOffSet=11;             {format for displaying location numbers}

  NumberOfFileTypes=14;
  BinFileType:Array[1..NumberOfFileTypes] Of FormatType=
       ('NONE','PCX','PAL/COL','CMF','SBI','GIF','VOC','IMG','MOD31',
        'MOD15','IBK','FLI','FRAGMENT','EXE');

  NumberOfExeTypes=13;
  ExeFileType:Array [0..NumberofExeTypes] Of FormatType
                                         =('old','new','bor','arj','lz90',
                                           'lz91','pkl','lharc','lha',
                                           'ts','pka','bsa','larc','lh');
{
  HEXED supports the folowing files for byte determination and/or formated
     viewing

  NONE raw
  PCX graphics         byte id     formated view
  PAL/COL palette      byte id     formated view
 *CMF FM music         byte id     formated view
  SBI FM instrument    byte id     formated view
  GIF graphics         byte id     formated view
**VOC digitized sample byte id     formated view
  IMG graphics         byte id     formated view
  MOD digitized music  byte id
  IBK FM instruments   byte id     formated view
  FLI movie/flick      byte id
  Fxx fragment         byte id
  EXE executable

  *  requires SMFMDRV.COM to be loaded
  ** requires a voice driver in some place where HEXED can find it
}

Type
  ExeData=Record
    Tp:Integer;
    NumRlc:Word;
    OffRlc:Word;
    HeadSize:LongInt;
  End;

  binaryimage=Array [1..imagesize] of Byte;
                            {type for storage of the binary file}
  binaryImagePointer=^binaryImage;
                            {TP doesn't let me use a plain old static array
                             for this (It'd be to large), so I used a pointer}
  strtype=String[78];       {for file name and convinence}
  DataType=Record
    D:binaryImagePointer;   (*this record stores all important information *)
    FN:StrType;             (*about the file in memory*)
    EOF:LongInt;
    X:LongInt;
    changes:Boolean;
    stream:File;
    offset:LongInt;         (* where the in memory segment is relative to
                               the file beginning *)
    BlockStart,
    BlockFinish:LongInt;    (* for the block commands (^K) *)
    BFT:Byte;                  {formated file type (.PAL,.GIF,.CMF etc.)}
    ED:ExeData;
    FragOffset:Word;
  End;

  HelpString=String[78];
  HelpType=Record
    Y:Integer;
    S:Array [1..MaxHelp] Of HelpString;
  End;
  HelpPointer=^HelpType;     {These two types store the help file for on-line
                              access}

Var
  viewMode:Byte;             {how many rows should HEXED display?}
  Paused:Boolean;            {is the secondary file paused (not moving)}
  Secondary:^DataType;       {storage for secondary file}
  AutomaticTUse:Boolean;     {for the 'p' button}
                             {pointer to the Commands() proceure so that it
                              can be called from above it in the file}
  FilePath:MaskString;       {string containing "*.*" or what ever the last
                              load wildcard was.}
  SearchFor:String[36];      {For Text Searches}

{For Binary Array Searches}
Const
  ArrayLength=19;

Var
  FArray:Array [1..ArrayLength] Of Byte;
  NumElement:Byte;
  CurrentElement:Byte;

{For the Byte Editor (On the binary level)}
Const
  Bit1=$01;
  Bit2=$02;
  Bit3=$04;
  Bit4=$08;
  Bit5=$10;
  Bit6=$20;
  Bit7=$40;
  Bit8=$80;
  Bit:Array[1..8] Of Byte=(Bit1,Bit2,Bit3,Bit4,Bit5,Bit6,Bit7,Bit8);
  OctDigit1=$07;
  OctDigit2=$38;
  OctDigit3=$B0;

{For Multi Type Output}
Type
  MultType=Record
    Case Byte Of
      0 : (S:ShortInt);
      1 : (I:Integer);
      2 : (L:LongInt);
      3 : (R:Real);
      4 : (Si:Single);
      5 : (D:Double);
      6 : (E:Extended);
      7 : (C:Comp);
    End;

{Mouse Input}
Var
  I,N:Word;
  C1,C2:Char;

{See Byte2Bin Function}
Type
  BinString=String[9];

{Help and File Vars}
Var
  Data:DataType;
  Hp:HelpPointer;

{Default Edit Hex}
  DefVarEd:Integer;

Const
  DefHex=0;
  DefDec=1;

{StringEdit() Types/Constants}
Type
  CharacterSet=Set of Char;

Const
  FileSet:CharacterSet= ['A'..'Z',
                         'a'..'z',
                         '0'..'9',
                         '!'..'$',
                         '^'..'*',
                         '-','.',
                         '\',':'];
  NormSet:CharacterSet= [' '..'~'];
  NumSet:CharacterSet= ['0'..'9','$','A'..'F','a'..'f','-'];

{Alternate View Mode}
Var
  AltMode:Integer;

Const
  StdMode=0;
  Byte4Mode=1;
  ThirdView=2;

IMPLEMENTATION

Begin
  DefVarEd:=DefHex;
  AltMode:=StdMode;
End.
