# Custom expectations for tests.

runs_cleanly <- function ()
# This expecatation is an inversion and combination of the throws_error and
# gives_warning expectations. That is, the code run under this expectation
# should not throw any errors or generate any warnings.
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
