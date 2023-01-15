MERLIN=Merlin32
MERLINFLAGS=-V /opt/Merlin32_v1.0/Library
APPLECOMMANDER=ac
MICROM8=microm8

adder.dsk: adder
	$(APPLECOMMANDER) -dos140 $@ && \
	$(APPLECOMMANDER) -p $@ $< bin 0x800 < $<

adder: adder.s
	$(MERLIN) $(MERLINFLAGS) adder.s

.PHONY:
run: adder.dsk
	$(MICROM8) -drive1 contrib/Apple_DOS_v3.3_1980_Apple.do -drive2 adder.dsk