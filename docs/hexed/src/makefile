INSTALL_DIR=d:/bin
PC=tpc -B
PCFALGS=
RM=rm -f

all:hexed

hexed:
	$(PC) hexed

install:
	cp hexed.cfg hexed.doc hexed.hlp hexed.exe hexed.pif $(INSTALL_DIR)

prep:
	cp hexed.cfg hexed.doc hexed.hlp hexed.exe hexed.pif ..
	$(MAKE) clean

clean:
	$(RM) *.tpu *.exe *.bak
