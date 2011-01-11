PKGNAME := $(shell sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGVERS := $(shell sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGSRC  := $(shell basename $(PWD))


.PHONY: help

help:
	@echo "\nExecute development tasks for $(PKGNAME)\n"
	@echo "Usage: \`make <task>\` where <task> is one of:"
	@echo "  docs       Invike roxygen to generate Rd files in a seperate directory"
	@echo "  build      Invoke docs and then create a package"
	@echo "  install    Invoke build and then install the result"
	@echo "  release    Populate a release branch"
	@echo ""


#------------------------------------------------------------------------------
# Tasks
#------------------------------------------------------------------------------
docs:
	cd ..;\
		R --vanilla --slave -e "library(roxygen); roxygenize('$(PKGSRC)', use.Rd2=TRUE, overwrite=TRUE)"
	# Cripple the new folder so you don't get confused and start doing
	# development in there.
	cd ../$(PKGSRC).roxygen;\
		rm Makefile
	# Copy over the NAMESPACE as ROxygen wipes it out and does not replace it.
	#
	# TODO: Fix this by migrating package documentation to ROxygen.
	cd ../$(PKGSRC).roxygen;\
		cp ../$(PKGSRC)/NAMESPACE .


build: docs
	cd ..;\
		R CMD build --no-vignettes $(PKGSRC).roxygen


install: build
	cd ..;\
		R CMD INSTALL $(PKGNAME)_$(PKGVERS).tar.gz


release:
	# See note in docs as to why this is needed for now.
	mv NAMESPACE ..
	cd ..;\
		R --vanilla --slave -e "library(roxygen); roxygenize('$(PKGSRC)','$(PKGSRC)', copy.package=FALSE, use.Rd2=TRUE, overwrite=TRUE)"
	mv ../NAMESPACE .
	./updateVersion.sh
	cd inst/doc;\
		R CMD Sweave $(PKGNAME).Rnw;\
	  texi2dvi --pdf $(PKGNAME).tex

