# Fady Baly — Résumé

LaTeX sources for my résumé. Built with LuaLaTeX on a modified
[Awesome-CV](https://github.com/posquit0/Awesome-CV) class.

```sh
make          # build resume.pdf
make verify   # build, then assert the Publications section is intact
make clean    # remove build artifacts
```

`make verify` is the one to run before sending the PDF anywhere.

## Layout

| Path | Contents |
| --- | --- |
| `resume.tex` | Document root: header, hyperref metadata, section order |
| `resume/*.tex` | One file per section |
| `references.bib` | Publications, each title hyperlinked to arXiv/ACL/DOI |
| `awesome-cv.cls` | The class, locally modified — do not replace with upstream |
| `cv.tex`, `coverletter.tex` | Unused, still carrying template defaults |

## Things that will bite you

**Build with LuaLaTeX, never XeLaTeX.** The Makefile passes `-pdflua` on
purpose. `xdvipdfmx` writes a broken ToUnicode CMap for the Source Sans Pro
subsets: every hyphen reverse-maps to U+2011 and small-caps capital I to
lowercase `i`, so extracted text reads `Pre‑Trained` and `APPLiED SCiENTiST`
and literal keyword matching fails. The rendered page looks identical either
way — the damage is invisible until you extract the text. Keep the
`%!TEX TS-program` lines pointed at lualatex, or editors and Overleaf will
reintroduce it.

**Do not touch the `\AddToHook{selectfont}` line in `resume.tex`.** It sets
`\spaceskip` with an absolute floor, and it is the only reason this PDF
contains word breaks an ATS can read. The subtleties, each found the hard way:

- `\spaceskip=0.34em` alone resolves *once*, at 11pt. The 32pt name then gets
  a gap 47% of the font's natural space width, and pypdf extracts the first
  line — the field every ATS reads as the candidate's name — as `FadyBaly`.
- ragged2e's `\justifying` re-zeroes `\spaceskip` on every `\selectfont`, so
  without the hook every `\textbf` label collapses (`MachineLearning:`).
- The floor is not optional: em-relative glue alone drops below pdfplumber's
  3.0pt tolerance at small-caps sizes and loses every job title.
- Do not typeset the space glyph in the body font to force the issue. That
  pulls its real width into the subset, halves pypdf's inference threshold,
  and words start splitting at their own kerns — `NL TK`, `ASP .NET`.

After any change touching fonts or spacing:

```sh
python3 -c "import pypdf; t=''.join(p.extract_text() for p in pypdf.PdfReader('resume.pdf').pages); print(repr(t.split(chr(10))[0]))"
```

Must print `'Fady Baly'`. Checking one extractor is not enough — poppler,
pdfminer, pdfplumber and pypdf each fail differently here.

**Two pages is a hard budget, and it is full.** Adding ~5 rendered lines
anywhere spills to page 3. Bullets wrapping to a second line are the usual
culprit; check with `pdftotext -layout resume.pdf -` rather than counting
characters. The footer prints a bare page number on purpose — `\today` and a
repeated name were landing in the middle of the extracted reading order.

**Commented-out content is deliberate, not abandoned.** The Projects section,
two 2019 outreach entries, the Music Teacher role and the template's header
quote are commented rather than deleted, each with a note saying why. They are
the reserve to draw on if a version needs different emphasis. Note that
removing Projects leaves the Computer Vision claim in Skills without
supporting evidence — a known, accepted trade.

**Claims are sourced.** Every figure traces to something real: citation counts
and download figures to `resume/publications.tex`, team sizes and scale to my
own recollection. Several bullets carry comments recording why a
stronger-sounding phrasing was rejected as unsupportable. Keep that bar — a
line you cannot defend for two minutes in an interview is worse than a plain
one.

## Open items

- No percentage on the Accrete retrieval-latency and token-usage reduction —
  the highest-value number still missing.
- Siren's table-OCR proof of concept: if it was greenlit after I left,
  "Won the build for…" beats "Proved… viable".
- `cv.tex` and `coverletter.tex` still contain the upstream template author's
  name and address. Fix or delete them before ever running those targets.

## Credit

Built on [Awesome-CV](https://github.com/posquit0/Awesome-CV) by Claud D. Park.
The class here carries local modifications; upstream ships its own license.
