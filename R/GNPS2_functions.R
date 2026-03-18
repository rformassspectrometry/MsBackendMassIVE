#' @title Utility functions for querying GNPS2 dataset metadata
#'
#' @name GNPS2-utils
#'
#' @description
#'
#' These functions provide utilities to query the GNPS2 dataset cache and
#' to map MassIVE dataset IDs to available files and dataset metadata.
#' GNPS2 is an indexed database of public MassIVE (MSV) datasets and their
#' file listings, exposed through a Datasette API. The functions here are
#' used primarily to query GNPS2 for file listings for a given MassIVE ID,
#' and to return that metadata as an R data.frame.
#'
#' In this package, GNPS2 queries are used as the first step to determine the
#' remote files available for a dataset and to support downstream MassIVE
#' dataset download and caching functions.
#'
#' - `massive_gnps2_query()`: query GNPS2 DB for dataset file metadata using
#'   the provided MassIVE dataset IDs. Returns a data.frame with one row per
#'   file entry from the `filename` table.
#'
#' @details
#'
#' The `massive_gnps2_query()` function queries the GNPS2 Datasette API
#' at `https://datasetcache.gnps2.org/datasette/database.csv` by executing a
#' SQL query on the `filename` table filtered by dataset IDs. It returns all
#' matching file metadata records. This metadata is used by downstream
#' functions to compute FTP paths and to download files.
#'
#' @param x `character(1)` with the ID of the MassIVE data set (usually
#'     starting with a *MSV* followed by a number).
#'
#' @return
#'
#' - For `massive_gnps2_query()`: a `data.frame` with the all information in
#'   GNPS2 database for the MassIVE IDs provided.
#'
#' @author Johannes Rainer, Philippine Louail, Gabriele Tomè
#'
#' @examples
#'
#' ## Get the GNPS2 table to the data set MSV000080547
#' massive_gnps2_query("MSV000080547")
#'
NULL

#' @importFrom httr GET content
#'
#' @importFrom utils read.csv
#'
#' @rdname GNPS2-utils
#'
#' @export
massive_gnps2_query <- function(x = character()) {
    api = "https://datasetcache.gnps2.org/datasette/database.csv"
    params = list("_stream" = "on",
                  "_sort" = "filepath",
                  "_size" = "max",
                  "sql" = paste0('SELECT * FROM filename ',
                                 'WHERE dataset IN ("',
                                 paste0(x, collapse = "\",\""), '")'))
    tryCatch({
        res <- retry(
            GET(api, query = params),
            sleep_mult = .sleep_mult())
    }, error = function(e) {
        stop("Failed to connect to GNPS2 dataset. No internet connection? - ",
             e$message,
             call. = FALSE)
    })
    project_annotation <- retry(read.csv(text = content(res, as = "text")),
                                sleep_mult = .sleep_mult())

    ## Check query as a correct id
    if(!nrow(project_annotation))
        stop("No MS data files found in GNPS2 dataset. Does the data set \"", x,
             "\" exist or have them?", call. = FALSE)

    return(project_annotation)
}
