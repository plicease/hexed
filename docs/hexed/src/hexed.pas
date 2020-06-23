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
============================================================================*)

(*============================================================================
 |  HexEd -- Hexadecimal Editor version 1.60
 |  (c) Graham Ollis 1994, 1997
 |
 | This program was designed to view/edit binary files in hex, char and
 | decimal format all at the same time.  All the commands are documented in
 | a short text file HEXED.HLP which should be included in the same directory
 | as HEXED.EXE.  The help file can be viewed online using the up and down
 | keys to scroll.
 |
 | New feature as of v1.22: can edit/view files > one segment
 |
 | History:
 | Date       Author     Comment
 | ----       ------     -------
 | -- --- 94  G. Ollis	 created and developed program
 | 08 feb 97  G. Ollis   1.60
 |                       took out nast "incourage to register" mode thing
 |                       added support to the new unix style fragment (3.x)
 ===========================================================================*)

{$N+,E+,I-,R-,G+,M 16384,0,350360}
(*============================================================================
 |  N+,E+ uses 80x87 co-processor (N+) if available for real type operations
 |        if 80x87 is not present then HEXED will emulate one internaly (E+)
 |  I-    turn off Turbo Pascal's checking of IO.  This lets me do my own,
 |        more friendly (although often produces fatal error in the same
 |        problems) IO checking
 |  R-    turns off range checking.
 |  G+    forces 80286 instructions.
 |  M     memory sizes, 16384 for stack size, 0 heap min 655360 heap max
 |        these are the defaults.  I have set heap max to 480360 so that
 |        I can load the digital voice driver.
 ===========================================================================*)

Program HexEdit;

Uses
     CFG,        {Read CFG file/check CFG settings}
     Crt,        {do color/text/widows.  Basically this makes HEXED look nice}
     Dos,        {look for files}
     Ollis,      {Graphics Lib}
     GIF,        {Graphics Interchange Format and IMG file reproduction}
     ChFile,     {Function to choose a file from a list, or by typing the name}
     ViewU,      {view file Lib}
     Header,     {Constants, Types, Globals}
     FUtil,      {File Utilities}
     CNT,        {Contact Procedure}
     OUTCRT,     {Output functions/procedures for the CRT}
     UModify,    {Routines to allow the user to modify words, bytes, etc.}
     LowInt,     {Low level functions accessed by user functions}
     VConvert,   {Convert Variable types (str --> int, etc.)}
     Help,       {Help Window}
     WTD,        {Write Type Data procedure}
     Second,     {Secondary File functions}
     Search,     {Search Functions}
     BinEd,      {Binary Editor}
     MouseIn,    {Mouse Interface}
     KeyIn,      {Keyboard Interface}
     Block,      {Block Commands}
     PrintU,     {Printer Functions}
     Center;     {Main Function}

Begin
  Main;
End.