# Awesome-CV build
#
# Driven by latexmk, which reads resume.bcf and runs biber itself, then reruns
# xelatex until references settle. This matters: resume/publications.tex wraps
# the bibliography in a refsection, and a bare `xelatex resume.tex` produces a
# Publications section containing the heading and nothing else -- no error, no
# warning that stops the build. latexmk also rebuilds whenever its own state is
# missing or stale, so a PDF left broken by a hand-run xelatex gets repaired
# rather than being treated as up to date.
#
# Requires LuaLaTeX (TeX Live) and FontAwesome installed system-wide; the
# bundled copy is at fonts/FontAwesome.ttf, install it with `make install-fonts`.

LATEXMK := latexmk
# -pdflua: build with lualatex. -bibtex: run biber/bibtex as needed.
#
# LuaLaTeX rather than XeLaTeX on purpose. xdvipdfmx writes a broken ToUnicode
# CMap for the Source Sans Pro subsets: every hyphen is reverse-mapped to U+2011
# NON-BREAKING HYPHEN and the small-caps capital I to lowercase 'i'. The PDF
# looks identical either way, but the extracted text an ATS reads comes out as
# "Pre‑Trained" and "APPLiED SCiENTiST", so literal keyword matching fails.
# LuaLaTeX emits correct ASCII. Keep the %!TEX TS-program lines in the .tex
# files on lualatex too, or editors and Overleaf will reintroduce the defect.
LMFLAGS := -pdflua -bibtex -interaction=nonstopmode -halt-on-error

.PHONY: all resume cv coverletter verify install-fonts clean distclean

all: resume

# Phony on purpose: latexmk decides what work is needed, and it is the only
# thing here that knows whether the bibliography is current.
resume:
	$(LATEXMK) $(LMFLAGS) resume.tex

cv:
	$(LATEXMK) $(LMFLAGS) cv.tex

coverletter:
	$(LATEXMK) $(LMFLAGS) coverletter.tex

# Fail loudly if the Publications section came out empty. Guards the exact
# silent failure described above.
verify: resume
	@n=$$(pdftotext -f 2 -l 3 resume.pdf - | grep -cE '^(Ara|State of|Multi|Dynamic)') ; \
	if [ "$$n" -lt 6 ] ; then \
		echo "ERROR: resume.pdf has $$n/6 publications -- the biber pass did not take." ; \
		exit 1 ; \
	fi ; \
	echo "OK: resume.pdf has $$n/6 publications."

# Install the bundled FontAwesome into the user font directory. Without it
# xelatex fails: fontawesome.sty requests the family with no path, so the
# copy under fonts/ is never found.
install-fonts:
	cp fonts/FontAwesome.ttf $(HOME)/Library/Fonts/

clean:
	$(LATEXMK) -c
	rm -f missfont.log

distclean:
	$(LATEXMK) -C
	rm -f missfont.log
