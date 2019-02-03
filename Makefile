# Check that language is set.  Do NOT set 'LANG', as that would override the platform's LANG setting.
ifndef lang
$(warning Please set 'lang' with 'lang=en' or similar.)
lang=en
endif

# Project stem.
STEM=still-magic

# Tools.
JEKYLL=jekyll
PANDOC=pandoc
LATEX=pdflatex
BIBTEX=bibtex
PYTHON=python

# Language-dependent settings.
DIR_MD=_${lang}
PAGES_MD=$(wildcard ${DIR_MD}/*.md)
BIB_MD=${DIR_MD}/bib.md
TOC_JSON=_data/toc.json
DIR_HTML=_site/${lang}
PAGES_HTML=${DIR_HTML}/index.html $(patsubst ${DIR_MD}/%.md,${DIR_HTML}/%/index.html,$(filter-out ${DIR_MD}/index.md,${PAGES_MD}))
DIR_TEX=tex/${lang}
BIB_TEX=${DIR_TEX}/book.bib
ALL_TEX=${DIR_TEX}/all.tex
BOOK_PDF=${DIR_TEX}/${STEM}.pdf

# Controls
all : commands

## commands    : show all commands.
commands :
	@grep -h -E '^##' ${MAKEFILE_LIST} | sed -e 's/## //g'

## serve       : run a local server.
serve : ${TOC_JSON}
	${JEKYLL} serve -I

## site        : build files but do not run a server.
site : ${TOC_JSON}
	${JEKYLL} build

## pdf         : generate PDF from LaTeX source.
pdf : ${BOOK_PDF}

## bib         : regenerate the Markdown bibliography from the BibTeX file.
bib : ${BIB_MD}

## toc         : regenerate the table of contents JSON file.
toc : ${TOC_JSON}

# ----------------------------------------

# Regenerate PDF once 'all.tex' has been created.
${BOOK_PDF} : ${ALL_TEX}
	cd ${DIR_TEX} \
	&& ${LATEX} -jobname=${STEM} book \
	&& ${BIBTEX} ${STEM} \
	&& ${LATEX} -jobname=${STEM} book \
	&& ${LATEX} -jobname=${STEM} book

# Create the unified LaTeX file (separate target to simplify testing).
${ALL_TEX} : ${PAGES_HTML} bin/transform.py
	${PYTHON} bin/transform.py --pre _config.yml ${DIR_HTML} _includes \
	| ${PANDOC} --wrap=preserve -f html -t latex -o - \
	| ${PYTHON} bin/transform.py --post _includes \
	> ${ALL_TEX}

# Create all the HTML pages once the Markdown files are up to date.
${PAGES_HTML} : ${PAGES_MD} ${BIB_MD} ${TOC_JSON}
	${JEKYLL} build

# Create the bibliography Markdown file from the BibTeX file.
${BIB_MD} : ${BIB_TEX} bin/bib2md.py
	bin/bib2md.py ${lang} < ${DIR_TEX}/book.bib > ${DIR_MD}/bib.md

# Create the JSON table of contents.
${TOC_JSON} : ${PAGES_MD} bin/make_toc.py
	bin/make_toc.py _config.yml ${DIR_MD} > ${TOC_JSON}

# Dependencies with HTML file inclusions.
${DIR_HTML}/%/index.html : $(wildcard _includes/%/*.*)

## ----------------------------------------

## check       : check everything.
check : ${BIB_MD}
	@make lang=${lang} check_anchors
	@make lang=${lang} check_cites
	@make lang=${lang} check_figs
	@make lang=${lang} check_gloss
	@make lang=${lang} check_links
	@make lang=${lang} check_src
	@make lang=${lang} check_toc

## check_anchors : list all incorrectly-formatted H2 anchors.
check_anchors :
	@bin/check_anchors.py _config.yml ${DIR_MD}

## check_cites : list all missing or unused bibliography entries.
check_cites : ${BIB_MD}
	@bin/check_cites.py ${DIR_MD}/bib.md ${PAGES_MD}

## check_figs  : list all missing or unused figures.
check_figs :
	@bin/check_figs.py figures ${PAGES_MD}

## check_gloss : check that all glossary entries are defined and used.
check_gloss :
	@bin/check_gloss.py ${PAGES_MD}

## check_links : check that all external links are defined and used.
check_links :
	@bin/check_links.py _config.yml _includes/links.md ${PAGES_MD} _includes/contributing.md

## check_src   : check source file inclusion references.
check_src :
	@bin/check_src.py src ${PAGES_MD}

## check_toc   : check consistency of tables of contents.
check_toc :
	@bin/check_toc.py _config.yml ${PAGES_MD}

## ----------------------------------------

## spelling    : compare words against saved list.
spelling :
	@cat ${PAGES_MD} | bin/uncode.py | aspell list | sort | uniq | comm -2 -3 - .words

## undone      : which files have not yet been done?
undone :
	@grep -l 'undone: true' _en/*.md

## words       : count words in finished files.
words :
	@for filename in $$(fgrep -L 'undone: true' ${PAGES_MD}); do printf '%6d %s\n' $$(cat $$filename | bin/uncode.py | wc -w) $$filename; done | sort -n -r
	@printf '%6d %s\n' $$(cat ${PAGES_MD} | bin/uncode.py | wc -w) 'total'

## ----------------------------------------

## clean       : clean up junk files.
clean :
	@rm -r -f _site dist
	@find . -name '*~' -delete
	@find . -name __pycache__ -prune -exec rm -r "{}" \;
	@rm -r -f tex/*/all.tex tex/*/*.aux tex/*/*.bbl tex/*/*.blg tex/*/*.log tex/*/*.out tex/*/*.toc
	@find . -name .DS_Store -prune -exec rm -r "{}" \;

## settings    : show macro values.
settings :
	@echo "JEKYLL=${JEKYLL}"
	@echo "DIR_MD=${DIR_MD}"
	@echo "PAGES_MD=${PAGES_MD}"
	@echo "BIB_MD=${BIB_MD}"
	@echo "DIR_HTML=${DIR_HTML}"
	@echo "PAGES_HTML=${PAGES_HTML}"
	@echo "DIR_TEX=${DIR_TEX}"
	@echo "BIB_TEX=${BIB_TEX}"
	@echo "ALL_TEX=${ALL_TEX}"
	@echo "BOOK_PDF=${BOOK_PDF}"
