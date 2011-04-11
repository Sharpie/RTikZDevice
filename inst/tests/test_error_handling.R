context('Test tikzDevice error and warning messages')

test_that('Null device is not a tikzDevice',{

    expect_that(
      isTikzDevice(),
      is_false()
    )

})

test_that('Device produces an error for unescaped characters',{

  expect_that(
    getLatexStrWidth('_'),
    throws_error('TeX was unable to calculate metrics')
  )

})

test_that('Device warns about the lower bound of the ASCII table if XeTeX disabled',{
  xelatex <- getOption('tikzXelatex')
  options(tikzXelatex = NULL)
  on.exit(options(tikzXelatex = xelatex))

  expect_that(
    getLatexCharMetrics(31),
    gives_warning('xelatex is not available')
  )

})

test_that('Device warns about the upper bound of the ASCII table if XeTeX disabled',{
  xelatex <- getOption('tikzXelatex')
  options(tikzXelatex = NULL)
  on.exit(options(tikzXelatex = xelatex))

  expect_that(
    getLatexCharMetrics(127),
    gives_warning('xelatex is not available')
  )

})

test_that("Device won't accept non-numeric ASCII codes",{

  expect_that(
    getLatexCharMetrics('a'),
    gives_warning('only accepts numbers')
  )

})

test_that('Device throws error when a path cannot be opened',{

  expect_that(
    tikz('/why/would/you/have/a/path/like/this.tex'),
    throws_error('directory does not exist or is not writable')
  )

})

test_that('tikzAnnotate refuses to work with a non-tikzDevice',{

  expect_that(
    tikzAnnotate('test'),
    throws_error('The active device is not a tikz device')
  )

})

test_that('UTF8 calculation fails when XeTeX cannot find a character in the current font.',{

  expect_that(
    getLatexStrWidth('α'),
    throws_error('TeX was unable to calculate metrics')
  )

})
