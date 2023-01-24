MERLIN=Merlin32
MERLINFLAGS=-V /opt/Merlin32_v1.0/Library
APPLECOMMANDER=ac
MICROM8=microm8

sum.dsk: sum
	cp contrib/Apple_DOS_v3.3_1980_Apple.do $@ && \
	$(APPLECOMMANDER) -p $@ $< bin 0x800 < $<

sum: sum.s
	$(MERLIN) $(MERLINFLAGS) sum.s

.PHONY:
run: sum.dsk
	$(MICROM8) -drive1 sum.dsk
