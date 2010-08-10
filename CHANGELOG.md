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

# Version 0.4.0 Beta

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

# Version <= 0.3.0 Alpha/Pre-Alpha

---

- Internal Alpha/Pre-Alpha
