BINDIR = bin
TARGET = helium
OCAMLCFLAGS = -w,+6+9-23
SOURCES = $(shell find src -regex ".*\\.ml\\([ily]\\|pack\\)?")
.PHONY: all debug test clean $(BINDIR)/$(TARGET)

all: $(BINDIR) $(BINDIR)/$(TARGET) $(SOURCES)

debug: $(BINDIR) $(BINDIR)/$(TARGET).byte $(SOURCES)

$(BINDIR):
	mkdir $(BINDIR)

$(BINDIR)/$(TARGET): $(SOURCES)
	ocamlbuild -j 8 -use-ocamlfind -cflags $(OCAMLCFLAGS) -pkgs str,unix -Is src $(TARGET).native
	cp -L $(TARGET).native $@
	rm $(TARGET).native

$(BINDIR)/$(TARGET).byte: $(SOURCES)
	ocamlbuild -j 8 -ocamlc "ocamlc -g" -cflags $(OCAMLCFLAGS) -use-ocamlfind -pkgs str,unix -Is src $(TARGET).byte
	cp -L $(TARGET).byte $@
	rm $(TARGET).byte

test: $(BINDIR)/$(TARGET)
	export HELIUM_LIB=$(shell pwd)/lib ; \
	./test.sh $< test/test_suite

clean:
	ocamlbuild -clean
	rm -f $(BINDIR)/$(TARGET)
	rm -f $(BINDIR)/$(TARGET).byte
