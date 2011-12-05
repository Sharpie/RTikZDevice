PKGNAME := $(shell sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGVERS := $(shell sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGSRC  := $(shell basename $(PWD))

# Specify the directory holding R binaries. To use an alternate R build (say a
# pre-prelease version) use `make RBIN=/path/to/other/R/` or `export RBIN=...`
# If no alternate bin folder is specified, the default is to use the folder
# containing the first instance of R on the PATH.
RBIN ?= $(shell dirname "`which R`")

# Check for environment variables that contain arguments to pass to testing
# scripts.
ifneq ($(R_GCT),)
gc_torture:=--use-gctorture
else
gc_torture:=
endif

# Controls which tests to run. Use thusly:
#
#     make test TESTS=list,of,comma,seperated,tags
#
# Tags must be single words
ifneq ($(TESTS),)
test_tags:=--run-tests=$(TESTS)
else
test_tags:=
endif


.PHONY: help news

help:
	@echo "\nExecute development tasks for $(PKGNAME)\n"
	@echo "Usage: \`make <task>\` where <task> is one of:"
	@echo ""
	@echo "Development Tasks"
	@echo "-----------------"
	@echo "  deps       Install dependencies for package development"
	@echo "  docs       Invoke roxygen to generate Rd files in a seperate"
	@echo "             directory"
	@echo "  news       Create NEWS.Rd and NEWS.pdf from NEWS.md. Requires"
	@echo "             GHC and Pandoc to be installed."
	@echo "  vignette   Build a copy of the package vignette"
	@echo "  build      Invoke docs and then create a package"
	@echo "  check      Invoke build and then check the package"
	@echo "  install    Invoke build and then install the result"
	@echo "  test       Install a new copy of the package and run it "
	@echo "             through the testsuite"
	@echo "  valgrind   Run package testsuite through the Valgrind debugger"
	@echo "             to check for memory leaks"
	@echo ""
	@echo "Packaging Tasks"
	@echo "---------------"
	@echo "  release    Populate a release branch"
	@echo ""
	@echo "Using R in: $(RBIN)"
	@echo "Set the RBIN environment variable to change this."
	@echo ""


#------------------------------------------------------------------------------
# Development Tasks
#------------------------------------------------------------------------------
deps:
	"$(RBIN)/R" --slave -e "install.packages(c('filehash','roxygen','testthat','ggplot2', 'maps'))"


docs:
	cd ..;\
		"$(RBIN)/R" --vanilla --slave -e "library(roxygen); roxygenize('$(PKGSRC)', '$(PKGSRC).build', use.Rd2=TRUE, overwrite=TRUE, unlink.target=TRUE)"
	# Cripple the new folder so you don't get confused and start doing
	# development in there.
	cd ../$(PKGSRC).build;\
		rm Makefile

news:
	rm -f NEWS.pdf
	./md2news.hs NEWS.md
	# Use this instead of Rd2txt. Rd2txt *does not* produce plaintext. The output
	# has a bunch of formatting junk for underlines and such.
	"$(RBIN)/R" --vanilla --slave -e "require(tools);Rd2txt('NEWS.Rd', 'NEWS', options=list(underline_titles=FALSE))"
	R CMD Rd2pdf NEWS.Rd
	# Move news into the inst directory so that it will be available to users
	# after installing the package.
	mv NEWS.Rd inst

vignette:
	cd inst/doc;\
		"$(RBIN)/R" CMD Sweave $(PKGNAME).Rnw;\
		texi2dvi --pdf $(PKGNAME).tex


build: docs
	cd ..;\
		"$(RBIN)/R" CMD build --no-vignettes $(PKGSRC).build


install: build
	cd ..;\
		"$(RBIN)/R" CMD INSTALL $(PKGNAME)_$(PKGVERS).tar.gz

check: build
	cd ..;\
		"$(RBIN)/R" CMD check --no-tests $(PKGNAME)_$(PKGVERS).tar.gz

test: install
	cd tests;\
		"$(RBIN)/Rscript" unit_tests.R $(gc_torture) $(test_tags)

valgrind: install
	cd tests;\
		"$(RBIN)/R" -d "valgrind --tool=memcheck --leak-check=full --dsymutil=yes" --vanilla < unit_tests.R --args $(gc_torture) $(test_tags)

#------------------------------------------------------------------------------
# Packaging Tasks
#------------------------------------------------------------------------------
release:
	cd ..;\
		"$(RBIN)/R" --vanilla --slave -e "library(roxygen); roxygenize('$(PKGSRC)','$(PKGSRC)', copy.package=FALSE, use.Rd2=TRUE, overwrite=TRUE)"
	./updateVersion.sh
	cd inst/doc;\
		"$(RBIN)/R" CMD Sweave $(PKGNAME).Rnw;\
		texi2dvi --pdf $(PKGNAME).tex
