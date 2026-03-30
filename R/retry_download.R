#' @title Retry expression on failure
#'
#' @description
#'
#' `retry()` retries, upon failure, the evaluation of an expression `exp` for
#' `ntimes` times waiting an increasing amount of time
#' between tries, i.e., waiting for `Sys.sleep(i * sleep_mult)` seconds between
#' each try `i`. If `expr` fails for `ntimes` times an error will be thrown.
#'
#' @param expr Expression to be evaluated.
#'
#' @param ntimes `integer(1)` with the number of times to try.
#'
#' @param sleep_mult `numeric(1)` multiplier to define the increasing waiting
#'     time (in seconds).
#'
#' @return The value of `expr` when it succeeds, for all failures throws the
#'     last error.
#'
#' @note
#'
#' Warnings are suppressed.
#'
#' @author Johannes Rainer
#'
#' @importFrom methods is
#'
#' @examples
#' a <- function() {
#'     if (sample(0:1, 1) == 0)
#'         stop("A, got a 0")
#'     1
#' }
#' set.seed(123)
#' res <- retry(a(), ntimes = 5L)
#'
#' @export
retry <- function(expr, ntimes = 5L, sleep_mult = 0L) {
    res <- NULL
    for (i in seq_len(ntimes)) {
        res <- suppressWarnings(tryCatch(expr, error = function(e) e))
        if (is(res, "simpleError")) {
            if (i == ntimes)
                stop(res)
            Sys.sleep(i * sleep_mult)
        } else break
    }
    res
}

.sleep_mult <- function() {
    as.integer(getOption("massive.sleep_mult", default = 7L))
}
