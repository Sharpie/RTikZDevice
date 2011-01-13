PKGNAME := $(shell sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGVERS := $(shell sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGSRC  := $(shell basename $(PWD))


.PHONY: help

help:
	@echo "\nExecute development tasks for $(PKGNAME)\n"
	@echo "Usage: \`make <task>\` where <task> is one of:"
	@echo ""
	@echo "Development Tasks"
	@echo "-----------------"
	@echo "  docs       Invike roxygen to generate Rd files in a seperate"
	@echo "             directory"
	@echo "  build      Invoke docs and then create a package"
	@echo "  install    Invoke build and then install the result"
	@echo "  test       Install a new copy of the package and run it "
	@echo "             through the testsuite"
	@echo ""
	@echo "Packaging Tasks"
	@echo "---------------"
	@echo "  release    Populate a release branch"
	@echo ""


#------------------------------------------------------------------------------
# Development Tasks
#------------------------------------------------------------------------------
docs:
	cd ..;\
		R --vanilla --slave -e "library(roxygen); roxygenize('$(PKGSRC)', '$(PKGSRC).build', use.Rd2=TRUE, overwrite=TRUE, unlink.target=TRUE)"
	# Cripple the new folder so you don't get confused and start doing
	# development in there.
	cd ../$(PKGSRC).build;\
		rm Makefile


build: docs
	cd ..;\
		R CMD build --no-vignettes $(PKGSRC).build


install: build
	cd ..;\
		R CMD INSTALL $(PKGNAME)_$(PKGVERS).tar.gz

test: install
	@echo "TODO: Refactor testsuite"


#------------------------------------------------------------------------------
# Packaging Tasks
#------------------------------------------------------------------------------
release:
	cd ..;\
		R --vanilla --slave -e "library(roxygen); roxygenize('$(PKGSRC)','$(PKGSRC)', copy.package=FALSE, use.Rd2=TRUE, overwrite=TRUE)"
	./updateVersion.sh
	cd inst/doc;\
		R CMD Sweave $(PKGNAME).Rnw;\
		texi2dvi --pdf $(PKGNAME).tex
