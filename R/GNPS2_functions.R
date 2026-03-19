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
#' and to return that metadata as an R data.frame. The Datasette API enforces
#' a maximum limit of 50,000 rows per query.
#'
#' In this package, GNPS2 queries are used as the first step to determine the
#' remote files available for a dataset and to support downstream MassIVE
#' dataset download and caching functions.
#'
#' - `gnps2_query()`: query GNPS2 DB for dataset file metadata using
#'   the provided MassIVE dataset IDs. Returns a data.frame with one row per
#'   file entry from the `filename` table.
#'
#' @details
#'
#' The `gnps2_query()` function queries the GNPS2 Datasette API
#' at `https://datasetcache.gnps2.org/datasette/database.csv` by executing a
#' SQL query on the `filename` table filtered by dataset IDs. It returns all
#' matching file metadata records. This metadata is used by downstream
#' functions to compute FTP paths and to download files.
#'
#' @param id `character` with the IDs of the MassIVE data set.
#'
#' @param usi_pattern `character(1)` defining a pattern to filter the `USI`,
#'     such as `usi_pattern = ".mzML"` to retrieve the `USI` of all files of the
#'     data set (i.e., files with extension `".mzML"`). This parameter is passed
#'     to the [grepl()] function.
#'
#' @param filepath_pattern `character(1)` defining a pattern to filter the
#'     `filepath`, such as `filepath_pattern = "metadata"` to retrieve the
#'     `filepath` of all files of the data set (i.e., files with matadata info).
#'     This parameter is passed to the [grepl()] function.
#'
#' @return
#'
#' - For `gnps2_query()`: a `data.frame` with the all information in
#'   GNPS2 database for the MassIVE IDs provided.
#'
#' @author Johannes Rainer, Philippine Louail, Gabriele Tomè
#'
#' @examples
#'
#' ## Get the GNPS2 table to the data set MSV000080547
#' gnps2_query("MSV000080547")
#'
NULL

#' @importFrom httr GET content
#'
#' @importFrom utils read.csv
#'
#' @rdname GNPS2-utils
#'
#' @export
gnps2_query <- function(id = character(), usi_pattern = "*",
                        filepath_pattern = "*") {
    api = "https://datasetcache.gnps2.org/datasette/database.csv"
    params = list("_stream" = "on",
                  "_sort" = "filepath",
                  "_size" = "max",
                  "sql" = paste0('SELECT * FROM filename ',
                                 'WHERE dataset IN ("',
                                 paste0(id, collapse = "\",\""), '")'))
    tryCatch({
        res <- retry(
            GET(api, query = params),
            sleep_mult = .sleep_mult())
    }, error = function(e) {
        stop("Failed to connect to GNPS2 dataset. No internet connection? - ",
             e$message,
             call. = FALSE)
    })
    project_anno <- retry(read.csv(text = content(res, as = "text")),
                          sleep_mult = .sleep_mult())

    ## Check query as a correct id
    if(!nrow(project_anno))
        stop("No MS data files found in GNPS2 dataset. Does the data set \"",
             id, "\" exist or have them?", call. = FALSE)

    ## Filter USI based on the pattern
    project_anno <- project_anno[grepl(usi_pattern, project_anno$usi), ]
    if(!nrow(project_anno))
        stop("No files found with corresponding `usi` pattern.")

    ## Filter filepath based on the patter
    project_anno <- project_anno[grepl(filepath_pattern,
                                       project_anno$filepath), ]
    if(!nrow(project_anno))
        stop("No files found with corresponding `filepath` pattern.")

    return(project_anno)
}
