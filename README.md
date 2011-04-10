# tikzDevice

---

## Description

The tikzDevice package new graphics device for R which enables direct
output of graphics in a LaTeX-friendly way.  Plotting commands issued
by R functions are transformed into LaTeX code blocks.  These blocks
are interpreted with the help of TikZ-- a graphics library for TeX and
friends written by Till Tantau.

The tikzDevice supports three main modes of output:

  - Figure chunks: placed in .tex files and suitable for inclusion in
    LaTeX documents via the \input{} command.

  - Stand alone figures: Complete LaTeX documents containing figure
    code that can be compiled into stand-alone images.  Pages are
    cropped to the size of the figure using the LaTeX preview package.

  - Console output: TikZ code is returned directly to the R console
    as a character vector for further manipulation.


## Beta Notice

The tikzDevice is currently flagged as a beta work.  The package is
reasonably stable and has been used by the authors to produce graphics
for academic publications for over a year.  The reason for beta status
is that there are several open design issues- two of which are:

  - Providing support for UTF8 text.

  - Supporting TeX variants other than LaTeX.

Resolving these issues may require changes to the tikzDevice that break
backwards compatibility with previous versions.  The beta flag is a reminder
that such changes may occur- although we will strive to avoid them if possible.

The beta flag will be removed upon release of version 1.0. At this time the
tikzDevice will switch to [semantic versioning][1] and changes that
break backwards compatibility will happen rarely and will incur a major release.

  [1]: http://www.semver.org


## Obtaining the Package

Stable versions of the tikzDevice may be downloaded from CRAN:

    install.packages( 'tikzDevice' )

Development versions may be obtained from R-Forge:

    install.packages( 'tikzDevice', 
      repos='http://r-forge.r-project.net' )


## Reporting Bugs and Getting Help

The tikzDevice has a dedicated mailing list courtesy of R-Forge.  The
mailing list is the easiest way to get answers for questions related
to usage:

  tikzdevice-bugs @at@ lists.r-forge.r-project.org 

Primary development takes place on GitHub.  Bugs and feature requests
may be made by opening issues at the primary repository:

  http://github.com/Sharpie/RTikZDevice/issues

Adventurous users are encouraged to fork the repository and contribute
to the development of the device!


## Latest Changes
*See the CHANGELOG for changes that occurred in previous releases*

---

### Version: 0.5.4
*Under development, will most likely become 0.6.0*

---

#### New Features

- Unicode Support!!!! XeLaTeX will be used automatically (if available) to
  calculate metrics and widths of unicode characters.

- New global option `tikzXelatexPackages` which contains packages necessary to
  use unicode characters with xelatex.  Specifically, the fontspec and the
  xunicode packages as well as the xetex option to the preview package.

- New global option `tikzUnicodeMetricPackages` which contains the packages
  necessary to calculate metrics for multibyte unicode characters with xelatex.

- New function anyMultibyteUTF8Characters() which will check if the given
  string contains any multibyte unicode characters.  Exposed in the package
  namespace since it is general and may be useful in other applications.

- Added "_" to the list of default sanitize characters

- The TikZ device now fully supports the `Raster` graphics primitive that was
  added in R 2.11.0 and no longer throws "not implemented" warnings when this
  functionality is used. This is accompilshed by writing raster images to PNG
  files, `Rplots_ras#.png`, which are then included in the main TeX file
  `Rplots.tex`.


#### Bug Fixes


#### Depreciation Notices

- Versions of R < 2.11.0 are no longer supported due to lack of required
  functions for handling Unicode strings. From now on, the tikzDevice will only
  be tested and supported against the version of R distributed in Debian-stable
  or newer. This is necessary to manage the burden of maintaining
  version-specific code.


#### Behind the Scenes

- New Makefile for executing common development tasks.

- Package documentation now handled by `roxygen`.  Thanks to Hadley Wickham and
  Yihui Xie for the `Rd2roxygen` package which facilitated this switch.

- Package test suite completely overhauled and now based on Hadley Wickham's
  `test_that` package.

