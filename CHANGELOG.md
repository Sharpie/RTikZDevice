---

### Version: 0.6.1
Released: 4-14-2011

---

#### Bug Fixes

- Fixed a bug where `tikz` was not applying background color to the plot
  canvas.

- Fixed a Vignette bug caused by an incorrect merge that was breaking the CRAN
  build.


---

### Version: 0.6.0
Released: 4-13-2011

---

#### New Features

- Unicode Support!!!! XeLaTeX may now be used calculate metrics and widths for
  Unicode characters. PdfLaTeX remains the default LaTeX compiler, but this may
  be changed by setting the global option `tikzDefaultEngine` to `xetex`.

- New global option `tikzXelatexPackages` which contains packages necessary to
  use unicode characters with xelatex.  Specifically, the fontspec and the
  xunicode packages as well as the xetex option to the preview package.

- New global option `tikzUnicodeMetricPackages` which contains the packages
  necessary to calculate metrics for multibyte unicode characters with xelatex.

- New function anyMultibyteUTF8Characters() which will check if the given
  string contains any multibyte unicode characters.  Exposed in the package
  namespace since it is general and may be useful in other applications.

- The TikZ device now fully supports the `Raster` graphics primitive that was
  added in R 2.11.0 and no longer throws "not implemented" warnings when this
  functionality is used. This is accompilshed by writing raster images to PNG
  files, `Rplots_ras#.png`, which are then included in the main TeX file
  `Rplots.tex`.

- The TikZ device now fully supports the `polypath` graphics primitive that was
  added in R 2.12.0 and no longer throws "not implemented" warnings when this
  functionality is used.


#### Bug Fixes

- Fixed a bug where the `lwd` parameter used to control line widths was
  declared by tikzDevice to be of type `int` when it is actually a `double`.
  This was causing line widths to be ignored or miscalculated. Many thanks to
  Baptiste Auguie for reporting this issue.


#### Depreciation Notices

- Versions of R < 2.11.0 are no longer supported due to lack of required
  functions for handling Unicode strings.


#### Behind the Scenes

- New Makefile for executing common development tasks.

- Package documentation now handled by `roxygen`.  Many thanks to Hadley
  Wickham and Yihui Xie for the `Rd2roxygen` package which facilitated this
  switch.

- Package test suite completely overhauled and now based on Hadley Wickham's
  `test_that` unit testing framework.


---

### Version: 0.5.3

---

#### Bug Fixes

- R 2.12.x now throws a warning message when shell commands run via `system()`
  have non-zero exit conditions.  The metric calculation runs LaTeX on a file
  containing an \@@end command.  This causes a non zero exit condition.  The end
  result was that users were getting spammed by warning messages.  These
  messages have been gagged for now and a better way to run LaTeX such that a
  non-zero condition can meaningfully indicate an error is being investigated.

- The range of characters the default sanitizer looks for has been extended.  It
  should now process all characters that are special to TeX with the exception
  of backslashes.  Documentation has been improved.

- Detection of failed string metric calculations has been strengthened and the
  resulting error message has been improved.


---

### Version: 0.5.2

---

#### Contributors
The following people contributed to this release of the tikzDevice:

- mlt for reporting problems with the Sanitize function that led to the
  discovery of two situations where buffer overflows were occurring.


#### Bug Fixes

- Fixed buffer overflows and memory leaks related to string pointers in
  tikzDevice.c.

- Fixed compilation of the tikzDevice vignette under R 2.12.0.

- Reduced the verbosity of the package startup message.


---

### Version: 0.5.1

---

#### Bug Fixes

- A stub function has been added so that the `polypath()` function
  introduced in R 2.12.0 won't crash the device.

- Fixed bug where no string output was shown when the sanitize=TRUE option was
  used.

- The path to a LaTeX compiler returned by `Sys.which()` is now checked by
  `file.access()` to check that it is actually an executable and not an error
  message.  This fixes issues arising from `Sys.which()` on Solaris.

- On UNIX platforms, `/usr/texbin/pdflatex` is added to the end of the list of
  places to search for a LaTeX compiler.  This should help people using R.app on
  OS X find a LaTeX compiler without having to manually specify it.

- `tikz()` produces a better error message when it cannot open a file for output.

- In the event that LaTeX crashes during a metric calculation, the LaTeX log
  output is echoed using `message()` instead of `cat()`.  This makes it show up
  during operations that supperss `cat()` output such as `R CMD build` and 
  `R CMD Sweave`. 


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

---

### Version 0.4.0 Beta

---

- Initial Beta Release
- Support for all essential graphical parameters: colors, line types, 
  line weights, semi-transparency, line endings and line joining.
- String width and character metrics are calculated by direct calls to a LaTeX
  compiler. This is an inefficient but robust method. Some of the inefficiency 
  of this method is compensated for by storing calculated string widths in a 
  database managed by the filehash package. This way if we pay a computational 
  price to compute the width of a string, we 
  hopefully only pay it once.

---

### Version <= 0.3.0 Alpha/Pre-Alpha

---

- Internal Alpha/Pre-Alpha
