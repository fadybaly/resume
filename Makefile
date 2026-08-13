# Awesome-CV build
#
# The biber pass is not optional: resume/publications.tex wraps the
# bibliography in a refsection, so a bare `xelatex resume.tex` silently drops
# the whole Publications section. xelatex then runs twice more so the
# bibliography and page references settle.
#
# Requires XeLaTeX (TeX Live) and FontAwesome installed system-wide; the
# bundled copy is at fonts/FontAwesome.ttf, install it with `make install-fonts`.

LATEX  := xelatex
BIBER  := biber
LFLAGS := -interaction=nonstopmode -halt-on-error

RESUME_DEPS := resume.tex references.bib awesome-cv.cls $(wildcard resume/*.tex)
CV_DEPS     := cv.tex awesome-cv.cls $(wildcard cv/*.tex)

.PHONY: all resume cv coverletter install-fonts clean distclean

all: resume

resume: resume.pdf
cv: cv.pdf
coverletter: coverletter.pdf

resume.pdf: $(RESUME_DEPS)
	$(LATEX) $(LFLAGS) resume.tex
	$(BIBER) resume
	$(LATEX) $(LFLAGS) resume.tex
	$(LATEX) $(LFLAGS) resume.tex

cv.pdf: $(CV_DEPS)
	$(LATEX) $(LFLAGS) cv.tex

coverletter.pdf: coverletter.tex awesome-cv.cls
	$(LATEX) $(LFLAGS) coverletter.tex

# Install the bundled FontAwesome into the user font directory. Without it
# xelatex fails: fontawesome.sty requests the family with no path, so the
# copy under fonts/ is never found.
install-fonts:
	cp fonts/FontAwesome.ttf $(HOME)/Library/Fonts/

clean:
	rm -f *.aux *.bbl *.bcf *.blg *.log *.out *.run.xml *.synctex.gz missfont.log

distclean: clean
	rm -f resume.pdf cv.pdf coverletter.pdf
