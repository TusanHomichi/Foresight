BINDIR = /usr/bin
DESTDIR = /usr/share/sgml/docbook/dsssl-stylesheets-1.74b

all: install

install: install-bin install-dtd install-dsl install-img install-misc

install-bin:
	mkdir -p $(BINDIR)
	install bin/collateindex.pl $(BINDIR)

install-dtd:
	mkdir -p $(DESTDIR)/dtds/{decls,dbdsssl,html,imagelib,olink}
	cp dtds/decls/docbook.dcl $(DESTDIR)/dtds/decls
	cp dtds/decls/xml.dcl $(DESTDIR)/dtds/decls
	cp dtds/dbdsssl/dbdsssl.dtd $(DESTDIR)/dtds/dbdsssl
	cp dtds/html/dbhtml.dtd $(DESTDIR)/dtds/html
	cp dtds/html/ISOlat1.gml $(DESTDIR)/dtds/html
	cp dtds/imagelib/imagelib.dtd $(DESTDIR)/dtds/imagelib
	cp dtds/olink/olinksum.dtd $(DESTDIR)/dtds/olink

install-dsl:
	mkdir -p $(DESTDIR)/{lib,common,html,print,olink}
	cp lib/dblib.dsl $(DESTDIR)/lib
	cp common/*.dsl $(DESTDIR)/common
	cp common/*.ent $(DESTDIR)/common
	cp html/*.dsl $(DESTDIR)/html
	cp lib/dblib.dsl $(DESTDIR)/lib
	cp print/*.dsl $(DESTDIR)/print

install-img:
	mkdir -p $(DESTDIR)/images/callouts
	cp images/*.gif $(DESTDIR)/images
	cp images/callouts/*.gif $(DESTDIR)/images/callouts

#install-test:
#	mkdir -p $(DESTDIR)/test/{cases,imagelib,xml}
#	cp test/*.* $(DESTDIR)/test
#	cp test/cases/*.* $(DESTDIR)/test/cases
#	cp test/imagelib/*.* $(DESTDIR)/test/imagelib
#	cp test/xml/*.* $(DESTDIR)/test/xml

install-misc:
	cp catalog $(DESTDIR)
	cp VERSION $(DESTDIR)
