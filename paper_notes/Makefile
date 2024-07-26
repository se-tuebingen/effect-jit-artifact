.PHONY: artifact

# make by default uses /bin/sh as the shell.
# This can cause issues like brace expansion not working, so we use Bash.
SHELL=/bin/bash

basename := effekt
lettername := cover-letter

papers-repo := ..

bib-file := $(papers-repo)/_bib/tsr.bib
styles := $(papers-repo)/_styles

# Folder to store temporary build artifacts
build := build

# The temporary folder to store the published sources in
sources := sources

check-weasels       := sh ../scripts/weasels.sh
check-passive-voice := sh ../scripts/passiveVoice.sh
check-duplicates    := perl ../scripts/duplicates.pl


latexmk := latexmk -shell-escape --pdf -pdflatex='pdflatex -halt-on-error -file-line-error'

madoko := @madoko -v

all: pdf

buildfolder:
	@mkdir -p $(build)/figures

watch:
	@fswatch -i "\.mdk" -e "build/" -e "styles/" . | xargs -n1 -I{} time make


# this updates the styles and bibliography from the central repository, if present
update:
	@if [ -d "$(papers-repo)/_styles" ]; then cp $(styles)/{plaintex,common,math}.{sty,mdk} styles | true; fi
	@if [ -d "$(papers-repo)/_bib" ]; then cp $(bib-file) bibliography.bib | true; fi

copy: buildfolder update
	@cp styles/*.{fmt,bst,png,csl,sty,cls} $(build) | true
	@cp *.{fmt,bst,png,csl,sty,cls,bib} $(build) | true

clean:
	@if [ -d "$(build)" ]; then rm -r $(build); fi
	@if [ -d "$(sources)" ]; then rm -r $(sources); fi
	@mkdir -p $(build)/figures
	@mkdir -p $(sources)

proof: madoko copy
	$(check-weasels) $(build)/$(basename).tex
	$(check-passive-voice) $(build)/$(basename).tex
	$(check-duplicates) $(build)/$(basename).tex

pdf: header madoko copy
	@cd $(build); $(latexmk) $(basename).tex -f && mv $(basename).pdf ..

debug: header madoko copy
	@cd $(build); $(latexmk) $(basename).tex -f && mv $(basename).pdf ..

madoko: copy
	$(madoko) --odir=$(build) --stylesdir=styles $(basename).mdk

madokoletter:
	madoko --odir=$(build) --stylesdir=styles $(lettername).mdk

letter: madokoletter
	cd $(build); $(latexmk) $(lettername).tex -f; mv $(lettername).pdf ../$(lettername).pdf

# The parameters passed to latexdiff help us to ignore certain environments, which is necessary
# to build the PDF
diff: madoko
	pushd $(build); latexdiff ../$(basename)-original.tex --config MATHENV="(?:mdmathpre|displaymath|equation|figureintext|figure)" --math-markup=0 $(basename).tex > diff.tex; $(latexmk) --pdf diff.tex; mv diff.pdf ../diff.pdf


header:
	@echo "\n==========================================================="
	@echo "Building document: $(basename) ($(shell date))"
	@echo "==========================================================="

artifact:
	@echo "\n==========================================================="
	@echo "Building artifact"
	@echo "==========================================================="
	@echo "Cleaning up old artifact"
	@rm -rf supplementary-material/demonstration
	@rm -rf supplementary-material/coq
	@rm -rf supplementary-material/coqhtml
	@echo "Building the demonstration"
	@cd artifact; bundle exec jekyll build
	@mv artifact/_site supplementary-material/demonstration
	@cp scripts/* supplementary-material/demonstration | true
	@echo "Copying Coq files"
	@mkdir -p supplementary-material/coq
	@cp -r coq/*.v supplementary-material/coq | true
	@cp -r coq/*.md supplementary-material/coq | true
	@cp -r coq/Makefile* supplementary-material/coq | true
	@cp -r coq/_CoqProject supplementary-material/coq | true
	@cp -r coq/.coqdeps.d supplementary-material/coq | true
	@echo "Building proof and proof docs"
	@cd coq; make; make html
	@mv coq/html supplementary-material/coqhtml
	@rm supplementary-material/.DS_Store

supplementary.zip: artifact
	rm -f supplementary.zip
	zip -r supplementary.zip supplementary-material

sources: clean pdf
	@cp $(build)/*.{tex,cls,sty,eps,bst,bbl} $(sources) | true
	@cd $(build); ../../scripts/bibexport.sh -o extracted.bib $(basename).aux
	@cp $(build)/extracted.bib $(sources)/bibliography.bib
	@cd $(sources); zip -r ../sources.zip *
