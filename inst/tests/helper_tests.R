# Custom tests and helpers.
runs_cleanly <- function ()
{
    function(expr) {
        res <- evaluate(substitute(expr), parent.frame())
        warnings <- sapply(Filter(is.warning, res), "[[", "message")
        errors <- sapply(Filter(is.error, res), "[[", "message")

        testthat:::expectation(length(warnings) == 0 && length(errors) == 0,
          str_c("warnings or errors occurred.\n",
            ifelse(length(warnings),
              str_c("Warning Messages:\n", warnings), ''),
            ifelse(length(errors),
              str_c("Error Messages:\n", errors), '')
          )
        )
    }
}
