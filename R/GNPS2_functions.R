#' @title Query the GNPS2 datasetchache resource
#'
#' @name GNPS2-utils
#'
#' @description
#'
#' The GNPS2 *datasetcache* collects and provides general information on data
#' sets/experiments with their related MS data files for various repositories
#' including MassIVE and MetaboLights. The resource is updated on a regular
#' basis. *MsBackendMassIVE* provides utility functions to retrieve information
#' from this resource directly in R:
#'
#' - `gnps2_query()`: query the datasetcache for metadata of data sets with
#'   the provided (MassIVE) dataset ID(s). Returns a `data.frame` with one row
#'   per file entry from the *filename* table.
#'
#' - `gnps2_usi_download_link()`: retrieve the download link for
#'   a specific USI. Returns a `character(1)` with the link.
#'
#' @details
#'
#' The `gnps2_query()` function queries the GNPS2 Datasette API
#' at `https://datasetcache.gnps2.org/datasette/database.csv` by executing a
#' SQL query on the *filename* table filtered by dataset IDs. It returns all
#' matching file metadata records. This metadata is used by downstream
#' functions to determine the FTP paths and to download files. The
#' `gnps2_usi_download_link()` makes a GET request to the GNPS2 dashboard to get
#' the download link of a specific USI.
#'
#' @note
#'
#' The Datasette API enforces a maximum limit of 50,000 rows per query. Longer
#' results will thus be truncated.
#'
#' @param id for `gnps2_query()`: `character` with the ID(s) of the MassIVE data
#'     set(s).
#'
#' @param usi_pattern for `gnps2_query()`: `character(1)` defining a pattern to
#'     filter the *USI*, such as `usi_pattern = ".mzML"` to retrieve the USI
#'     of all files of the data set (i.e., files with extension `".mzML"`). This
#'     parameter is passed to the [grepl()] function.
#'
#' @param filepath_pattern for `gnps2_query()`: `character(1)` defining a
#'     pattern to filter the `filepath`, such as `filepath_pattern = "metadata"`
#'     to retrieve the `filepath` of all files of the data set (i.e., files with
#'     metadata info). This parameter is passed to the [grepl()] function.
#'
#' @param usi for `gnps2_usi_download_link()`: `character(1)` with the USI of a
#'     file in GNPS2 DB.
#'
#' @return
#'
#' - For `gnps2_query()`: a `data.frame` with the all information in the
#'   GNPS2 datasetcache database for the data set IDs provided.
#' - For `gnps2_usi_download_link()`: a `character(1)` with the downlaod link of
#'   the USI.
#'
#' @author Gabriele Tomè
#'
#' @examples
#'
#' ## Get the GNPS2 table to the data set MSV000080547
#' gnps2_query("MSV000080547")
#'
#' ## Get link for an USI
#' gnps2_usi_download_link("mzspec:MTBLS39:FILES/AM063A.cdf")
NULL

#' @importFrom httr GET content
#'
#' @importFrom utils read.csv
#'
#' @importFrom MsCoreUtils retry
#'
#' @rdname GNPS2-utils
#'
#' @export
gnps2_query <- function(id = character(), usi_pattern = "*",
                        filepath_pattern = "*") {
    api <- "https://datasetcache.gnps2.org/datasette/database.csv"
    params <- list("_stream" = "on",
                   "_sort" = "filepath",
                   "_size" = "max",
                   "sql" = paste0('SELECT * FROM filename ',
                                  'WHERE dataset IN (',
                                  paste0("\"", id, "\"", collapse = ","), ')'))
    tryCatch({
        res <- retry(
            GET(api, query = params),
            sleep_mult = .sleep_mult(),
            retry_on = .RETRY_ON_PATTERN)
    }, error = function(e) {
        stop("Failed to connect to GNPS2 dataset. No internet connection? - ",
             e$message,
             call. = FALSE)
    })
    project_anno <- retry(read.csv(text = content(res, as = "text")),
                          sleep_mult = .sleep_mult(),
                          retry_on = .RETRY_ON_PATTERN)
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
    project_anno
}


#' @importFrom httr GET content
#'
#' @importFrom MsCoreUtils retry
#'
#' @rdname GNPS2-utils
#'
#' @export
gnps2_usi_download_link <- function(usi = character()) {
    if (length(usi) != 1)
        stop("Provide 1 USI ID.")
    url <- "https://dashboard.gnps2.org/downloadlink"
    params <- list("usi"= usi)
    tryCatch({
        res <- retry(
            GET(url, query = params),
            sleep_mult = .sleep_mult(),
            retry_on = .RETRY_ON_PATTERN)
    }, error = function(e) {
        stop("Failed to connect to GNPS2 dataset. No internet connection? - ",
             e$message,
             call. = FALSE)
    })
    link <- content(res, as = "text")
    if(!grepl("^http|^ftp", link))
        stop("Link not retrieved. Does the USI ", usi, " exist?")
    link
}
