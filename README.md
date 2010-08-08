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
    cropped to the size of the figure using the preview package.

  - Console output: TikZ code is returned directly to the R console
    as a character vector for further manipulation.

## Beta Notice

The tikzDevice is currently flagged as a beta work.  The package is
reasonably stable and has been used by the authors to produce graphics
for academic publications for over a year.  The reason for beta status
is that there are several open design issues- two of which are:

  - Providing support for UTF8 text.

  - Supporting TeX variants other than LaTeX.

Resolving these issues may require changes to the tikzDevice that
break backwards compatibility with previous versions.  The beta flag
is a reminder that such changes may occur- although we will strive to
avoid them if possible.

The beta flag will be removed upon release of version 1.0. At this
time maintaining backwards compatibility will become a primary concern.

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

### Version 0.5.0 Beta

---

#### Contributors
The following people contributed to this release of the tikzDevice:

- Lorenzo Isella contributed bug reports and examples that led to the
  discovery of a bug in fontsize calculations that appeared when
  certain LaTeX commands were used to change the active font.

- Vivianne Vilar for spotting spelling and grammar errors in the
  vignette.

- Gabor Grothendieck for the idea for sending output to the screen 
  for use with sink() (i.e. the "console" option)

#### New Features

- "console" option for directing tikz() output back into the R console
  instead of to a file.

- Preliminary support for a "sanitize" option which allows automatic
  escaping of characters that have special meaning to TeX like "$" and
  "%".

- tikzAnnotate() and tikzCoord() functions.  tikzAnnotate() allows
  arbitrary LaTeX code to be injected into the output stream of an
  active tikz() graphics device.  tikzCoord() is a wrapper for
  tikzAnnotate() that inserts named locations into the graphics code.
  These locations may be referenced by other TikZ drawing commands.


#### Bug Fixes

- Removed bad colon in the DESCRIPTION file.

- Proper fontsize calculations now include ps from par() and fontsize
  from gpar().  This fixes issues with lattice-based graphics such as
  ggplot2.

- Metrics are now calculated properly when commands like
  \renewcommand\rmdefault are used to adjust the active font.

- Sanitization of % signs in labels.

- The package no longer overwrites user customizations set in places like
  .Rprofile with default values when loaded.

- Attempting to use new graphics functions such as rasterImage() now
  produces error messages instead of fatal crashes in R 2.11.0 and
  above.
