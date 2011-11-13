# tikzDevice

---

## Description

The tikzDevice package provides a graphics device for R that enables direct
output of graphics in a LaTeX-friendly way.  Plotting commands issued by R
functions are transformed into LaTeX code blocks.  These blocks are interpreted
with the help of TikZ-- a graphics library for TeX and friends written by Till
Tantau.

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

Development builds may be obtained from R-Forge:

    install.packages( 'tikzDevice',
      repos='http://r-forge.r-project.net' )

Bleeding-edge source code is available from GitHub:

    git clone git://github.com/Sharpie/RTikZDevice.git



## Reporting Bugs and Getting Help

The tikzDevice has a dedicated mailing list courtesy of R-Forge.  The
mailing list is the easiest way to get answers for questions related
to usage:

  tikzdevice-bugs @at@ lists.r-forge.r-project.org

The mailing list may also be accessed through Google Groups:

  https://groups.google.com/forum/#!forum/tikzdevice


Primary development takes place on GitHub.  Bugs and feature requests
may be made by opening issues at the primary repository:

  https://github.com/Sharpie/RTikZDevice/issues

Adventurous users are encouraged to fork the repository and contribute
to the development of the package!


## Latest Changes
*See the [CHANGELOG][2] for changes that occurred in previous releases*

  [2]:https://github.com/Sharpie/RTikZDevice/blob/master/CHANGELOG.md


---

### Version: 0.6.2

---

#### New Features

- The annotation system has been improved. A new function `tikzNode` has been
  added that makes it easy to insert TikZ nodes with custom options and
  content. `tikzCoord` is now a wrapper for `tikzNode` that simplifies the
  function call required to get a plain coordinate.

- Annotation of Grid graphics is now supported. New functions
  `tikzAnnotateGrob`, `tikzNodeGrob` and `tikzCoordGrob` allow the creation of
  Grid grobs that execute annotiation commands when drawn to a `tikz` device.
  Wrapper functions `grid.tikzAnnotate`, `grid.tikzNode` and `grid.tikzCoord`
  are also provided. The necessary transformations between Grid coordinates,
  which are viewport-centric, to absolute device coordinates are handled by a
  new function `gridToDevice`.

- Support has been added for the `dev.capabilities` function in R 2.14.0.

#### Bug Fixes

- Fixed a bug where the outline of the background bounding box was being drawn
  with the forground color instead of the background color. This was
  unnoticible except when a non-white background was used. Thanks to Matthieu
  Stigler for reporting.

#### Behind the Scenes

- The tikzDevice is now checked with "visual regression testing" which compares
  the results of graphics tests against a set of standard images using a visual
  diff. If a change occurs that significantly affects font metrics or graphics
  primitives the effects will show up in the diff. Currently, ImageMagick's
  `compare` utility is used to calculate differences. This process was inspired
  by the work of Paul Murrell and Stephen Gardiner on the graphicsQC package.
  Future versions of the tikzDevice may use graphicsQC to perform this task.

- The tikzDevice Vignette used to employ a rather ugly hack that re-wrote the
  internals of the Sweave driver during processing in order to gain more
  control over syntax highlighting. This hack has been replaced by TeX macros
  that achieve the same result without messing with R.

