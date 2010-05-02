# tikzDevice NEWS #

### VERSION 0.5.0 Beta ###

#### New Features ####

- "console" option
- "sanitize" option (and new options)
- tikzCoord


#### Bug Fixes ####

- Colon in the DESCRIPTION file 
- Proper calculation of fontsize taking into account ps from par() and fontsize from gpar()
- % signs in labels
- Loading the package no longer overwrites options set in places like .Rprofile
- Attempting to use new graphics functions such as rasterImage() produces error messages instead of fatal crashes in R 2.11.0 and above.

### VERSION 0.4.0 Beta ###

- Initial Beta Release
- Support for all essential graphical parameters: colors, line types, 
  line weights, semi-transparency, line endings and line joining.
- String width and character metrics are calculated by direct calls to a LaTeX
  compiler. This is an inefficient but robust method. Some of the inefficiency 
  of this method is compensated for by storing calculated string widths in a 
  database managed by the filehash package. This way if we pay a computational 
  price to compute the width of a string, we 
  hopefully only pay it once.

### VERSION <= 0.3.0 Alpha/Pre-Alpha ###

- Internal Alpha/Pre-Alpha
