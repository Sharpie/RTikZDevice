PKGNAME := $(shell sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGVERS := $(shell sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGSRC  := $(shell basename $(PWD))

# Specify the directory holding R binaries. To use an alternate R build (say a
# pre-prelease version) use `make RBIN=/path/to/other/R/` or `export RBIN=...`
# If no alternate bin folder is specified, the default is to use the folder
# containing the first instance of R on the PATH.
RBIN ?= $(shell dirname "`which R`")


.PHONY: help

help:
	@echo "\nExecute development tasks for $(PKGNAME)\n"
	@echo "Usage: \`make <task>\` where <task> is one of:"
	@echo ""
	@echo "Development Tasks"
	@echo "-----------------"
	@echo "  docs       Invike roxygen to generate Rd files in a seperate"
	@echo "             directory"
	@echo "  vignette   Build a copy of the package vignette"
	@echo "  build      Invoke docs and then create a package"
	@echo "  install    Invoke build and then install the result"
	@echo "  test       Install a new copy of the package and run it "
	@echo "             through the testsuite"
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
docs:
	cd ..;\
		"$(RBIN)/R" --vanilla --slave -e "library(roxygen); roxygenize('$(PKGSRC)', '$(PKGSRC).build', use.Rd2=TRUE, overwrite=TRUE, unlink.target=TRUE)"
	# Cripple the new folder so you don't get confused and start doing
	# development in there.
	cd ../$(PKGSRC).build;\
		rm Makefile


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

test: install
	cd tests;\
		"$(RBIN)/Rscript" unit_tests.R


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
