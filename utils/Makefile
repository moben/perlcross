TOP = ..
include $(TOP)/Makefile.config
PERL = $(TOP)/miniperl_top

plextract = c2ph config_data corelist cpan h2ph h2xs instmodsh\
	perlbug perldoc perlivp pl2pm prove ptar ptardiff cpanp-run-perl\
       	cpanp cpan2dist shasum splain dprofpp libnetcfg piconv enc2xs xsubpp

all: $(plextract) 

%: %.PL ../config.sh
	$(PERL) $<

perlbug: ../patchlevel.h

splain:	../lib/diagnostics.pm

clean:
	rm -f $(plextract)

#install:
#	for i in $(plextract); do install -m 0755 -D $$i $(scriptdir)/$$i; done
