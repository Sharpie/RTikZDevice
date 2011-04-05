test_graphs <- list(
  list(
    short_name = 'hello_TeX',
    description = 'Draw a circle and some simple text',
    graph_code = quote({
      plot(1, axes=F, xlab='', ylab='')
      text(1, 1.1, 'Hello TeX')
    })
  ),

  list(
    short_name = 'graph_box',
    description = 'Draw a box around a graph',
    graph_code = quote({
      plot(1, type='n', axes=F)
      box()
    })
  ),

  list(
    short_name = 'text_color',
    description  = 'Draw colorized text',
    graph_code = quote({
      plot(1, type='n')
      text(0.8,0.8,'red',col='red')
      text(1.2,1.2,'blue',col='blue',cex=2)
    })
  ),

  list(
    short_name = 'plot_legend',
    description = 'Draw a legend box',
    graph_code = quote({
      plot(1,1, xlim=c(0,10), ylim=c(0,10))

      legend( x='top', title='Legend Test', legend=c('Hello, world!'), inset=0.05 )

      legend( 6, 4, title='Another Legend Test', legend=c('Test 1','Test 2'), pch=c(1,16))
    })
  ),

  list(
    short_name = 'pch_caracters',
    description = 'Draw common plotting characters',
    graph_code = quote({
      # Magic stuff taken from example(points)
      n <- floor(sqrt(26))
      npchIndex <- 0:(25)

      ix <- npchIndex %/% n
      iy <- 3 + (n-1) - npchIndex %% n

      rx <- c(-1,1)/2 + range(ix)
      ry <- c(-1,1)/2 + range(iy)

      # Set up plot area
      plot(rx, ry, type="n", axes=F, xlab='', ylab='', sub="Standard R plotting characters")

      # Plot characters.
      for( i in 1:26 ){

        points(ix[i], iy[i], pch=i-1)
        # Place text label so we know which character is being plotted.
        text(ix[i]-0.3, iy[i], i-1 )

      }
    })
  ),

  list(
    short_name = 'draw_circles',
    description = 'Draw circles',
    graph_code = quote({
      plot(-2:2, -2:2, type = "n", axes=F, xlab='', ylab='')
      points(rnorm(10), rnorm(10), col = "red")
      points(rnorm(10)/2, rnorm(10)/2, col = "blue")
    })
  ),

  list(
    short_name = 'draw_filled_circles',
    description = 'Draw filled circles',
    graph_code = quote({
       plot(-2:2, -2:2, type = "n", axes=F, xlab='', ylab='')
       points(rnorm(10), rnorm(10), pch=21, col='blue', bg='forestgreen')
    })
  ),

  list(
    short_name = 'line_color',
    description = 'Draw colored lines',
    graph_code = quote({
      plot(c(0,1), c(0,1), type = "l", axes=F,
              xlab='', ylab='', col='red3')
    })
  ),

  list(
    short_name = "character_expansion",
    description = "Test character expansion",
    graph_code = quote({
       plot(1, axes=F, xlab='', ylab='', cex=10)
       points(1, cex=.5)
    })
  ),

  list(
    short_name = 'filled_rectangle',
    description = 'Test filled rectangles',
    graph_code = quote({
      plot(-2:2, -2:2, type = "n", axes=F, xlab='', ylab='')
      points(rnorm(10), rnorm(10), pch=22, col='red', bg='gold')
    })
  ),

  list(
    short_name = 'line_types',
    description = 'Test line types',
    graph_code = quote({
      plot(0, type='n', xlim=c(0,1), ylim=c(0,6),
              axes=F, xlab='', ylab='')
      for(i in 0:6)
        lines(c(0, 1), c(i, i), lty=i)
    })
  ),

  list(
    short_name = 'line_weights',
    description = 'Test line weights',
    graph_code = quote({
      plot(0, type='n', xlim=c(0,1), ylim=c(0,6),
              axes=F, xlab='', ylab='')
      for(i in 0:6)
        lines(c(0,1), c(i,i), lwd=i)
    })
  ),

  list(
    short_name = 'transparency',
    description = 'Test transparency',
    graph_code = quote({
      plot(-2:2, -2:2, type = "n", axes=F, xlab='', ylab='')
      points(rnorm(50), rnorm(50), pch=21, bg=rainbow(50,alpha=.5), cex=10)
    })
  ),

  list(
    short_name = 'lots_of_elements',
    description = 'Test of many points for file size',
    graph_code = quote({
      plot(-2:2, -2:2, type = "n", axes=F, xlab='', ylab='')
      points(rnorm(500), rnorm(500), pch=21, bg=rainbow(50,alpha=.5), cex=10)
    })
  ),

  list(
    short_name = 'contour_lines',
    description = 'Test contour lines and associated text',
    graph_code = quote({
      x <- -6:16
      op <- par(mfrow = c(2, 2))
      contour(outer(x, x), method = "edge")
      z <- outer(x, sqrt(abs(x)), FUN = "/")
      image(x, x, z)
      contour(x, x, z, col = "pink", add = TRUE, method = "edge")
      contour(x, x, z, ylim = c(1, 6), method = "simple", labcex = 1)
      contour(x, x, z, ylim = c(-6, 6), nlev = 20, lty = 2, method = "simple")
      par(op)
    })
  ),

  list(
    short_name = 'string_placement',
    description = 'Test string placement and TeX symbol generation',
    graph_code = quote({
      syms <-c('alpha','theta','tau','beta','vartheta','pi','upsilon',
            'gamma','gamma','varpi','phi','delta','kappa','rho','varphi',
            'epsilon','lambda','varrho','chi','varepsilon','mu','sigma',
            'psi','zeta','nu','varsigma','omega','eta','xi','Gamma',
            'Lambda','Sigma','Psi','Delta','Xi','Upsilon','Omega',
            'Theta','Pi','Phi')
      x <- rnorm(length(syms))
      y <- rnorm(length(syms))
      plot(-2:2, -2:2, type = "n", axes=F, xlab='', ylab='')
      points(x, y, pch=21,  bg='black', cex=.5)
      text(x,y,paste('\\Large$\\',syms,'$',sep=''))
    })
  ),

  list(
    short_name = 'text_alignment',
    description = 'Test text alignment',
    graph_code = quote({
      plot(1,1,type='n',xlab='',ylab='',axes=F)
      abline(v=1)

      #left justified
      par(adj = 0)
      text(1,1.1,'Left')

      #Center Justified
      par(adj = 0.5)
      text(1,1,'Center')

      #Right Justified
      par(adj = 1)
      text(1,0.9,'Right')
    })
  ),

  list(
    short_name = 'persp_3D',
    description = 'Test of 3D graphs with persp',
    graph_code = quote({
      x <- seq( -1.95, 1.95, length=30 )
      y <- seq( -1.95, 1.95, length=35 )

      z <- outer( x, y, function(a,b){ a*b^2 } )

      nrz <- nrow(z)
      ncz <- ncol(z)

      jet.colors <- colorRampPalette( c("blue", "green") )

      nbcol <- 100

      color <- jet.colors(nbcol)

      zfacet <- z[-1,-1] + z[-1,-ncz] + z[-nrz, -1] + z[-nrz, -ncz]
      facetcol <- cut(zfacet, nbcol)

      persp(x, y, z, col=color[facetcol], phi=30, theta=-30, ticktype='detailed')
    })
  ),

  list(
    short_name = 'ggplot2_test',
    description = 'Test of ggplot2 graphics',
    graph_code = quote({
      sink(tempfile())
      suppressPackageStartupMessages(require(mgcv))
      suppressPackageStartupMessages(require(ggplot2))
      sink()
      print(qplot(carat, price, data = diamonds, geom = "smooth",
      colour = color))
    })
  ),

  list(
    short_name = 'ggplot2_superscripts',
    description = 'Test of grid text alignment with ggplot2',
    graph_code =  quote({
      sink(tempfile())
      suppressPackageStartupMessages(require(ggplot2))
      sink()

      soilSample <- structure(list(`Grain Diameter` = c(8, 5.6, 4, 2.8, 2, 1, 0.5, 0.355, 0.25),
        `Percent Finer` = c(0.951603145795523, 0.945553539019964,
           0.907239362774753, 0.86771526517443, 0.812865497076023, 0.642064932446058,
           0.460375075620085, 0.227465214761041, 0.0389191369227667)),
        .Names = c("Grain Diameter", "Percent Finer"), row.names = c(NA, 9L),
        class = "data.frame")

      testPlot <- qplot( `Grain Diameter`, `Percent Finer`, data = soilSample) +
        scale_x_log10() + scale_y_probit() + theme_bw()

      print( testPlot )
    })
  ),


  ### XeLaTeX Tests
  list(
    short_name = 'utf8_characters',
    description = 'Test of UTF8 characters',
    uses_xetex = TRUE,
    graph_code =  quote({
      n <- 10
      chars <- matrix(intToUtf8(seq(161,,1,10*n),multiple=T),n)

      plot(1:n,type='n',xlab='',ylab='',axes=FALSE, main="UTF-8 Characters")
        for(i in 1:n)
          for(j in 1:n)
            text(i,j,chars[i,j])
    })
  )


  # New tests go here
  #list(
  #  short_name = 'something_suitable_as_a_filename',
  #  description = 'Longer description of what the test does',
  #  graph_code = quote({
  #
  #  })
  #)

)

lapply(test_graphs, do.call, what = do_graphics_test)

context('Graph test cleanup')

test_that('All graphics devices closed',{

  expect_that(length(dev.list()), equals(0))

})

message('\n\nFinished generating TikZ test graphs.')
message('PDF files are in:\n\t', test_output_dir)
message('\nTeX sources and log files are in:\n\t', test_work_dir)

