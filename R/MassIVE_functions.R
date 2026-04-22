#' @title Utility functions for the MassIVE repository
#'
#' @name MassIVE-utils
#'
#' @description
#'
#' [MassIVE](https://massive.ucsd.edu/ProteoSAFe/static/massive.jsp)
#' (Mass Spectrometry Interactive Virtual Environment) is a community
#' resource developed by the NIH-funded Center for Computational Mass
#' Spectrometry to promote the global, free exchange of mass spectrometry
#' data. MassIVE supports deposition of both proteomics and metabolomics
#' experiments, and is a full member of the
#' [ProteomeXchange](http://www.proteomexchange.org/) consortium, allowing
#' datasets to be assigned ProteomeXchange accessions to satisfy publication
#' requirements. Submitted data can include raw mass spectrometry files,
#' identification results, and quantification data. The repository also
#' provides online workflows for reanalysis of public datasets and tools
#' for comparison of identification results across datasets.
#'
#' Each experiment in MassIVE is identified with its unique identifier,
#' starting with *MSV* followed by a number. The data (raw MS files,
#' metadata, and result files) of a dataset are available for public
#' download and online browsing once the dataset has been made public by
#' its submitter.
#'
#' The functions listed here allow to query and retrieve information of a
#' data set/experiment from MassIVE.
#'
#' - `massive_ftp_path()`: returns the FTP path for a provided MassIVE ID.
#'   If the MassIVE ID does not exist the function throws an error.
#'   With `mustWork = TRUE` (the default) the function throws an error
#'   either because the data set does not exist in
#'   [GNPS2 DB](https://datasetcache.gnps2.org/datasette/database/filename) (No
#'   mzML/CDF/mzXML files available) or no internet connection is available.
#'   The function returns a `character(1)` with the FTP path to the data set
#'   folder.
#'
#' - `massive_cached_data_files()`: lists locally cached data files from
#'   MassIVE. Since this function evaluates only local content it does not
#'   require an internet connection. With the default parameters all available
#'   data files are listed. The parameters can be used to restrict the lookup.
#'
#' - `massive_list_files()`: returns the available files (and directories) for
#'   the specified MassIVE data set (i.e., the FTP directory content of the
#'   data set). The function returns a `character` vector with the relative
#'   file names to the absolute FTP path (`massive_ftp_path()`) of the data set.
#'   Parameter `pattern` allows to filter the file names and define which
#'   file names should be returned.
#'
#' - `massive_sync_data_files()`: synchronize data files of a specified
#'   MassIVE data set eventually downloading and locally caching them.
#'   Parameter `fileName` allows to specify names of selected data files to
#'   sync.
#'
#' - `massive_download_file()`: download files from the MassIVE repository for a
#'   specified MassIVE dataset. Use `pattern` to filter files by name using a
#'   regular expression (downloads all files by default). Use `fileName` to
#'   specify one or more exact file names to download. Use `path` to set the
#'   destination directory for downloaded files.
#'
#' - `massive_param_file()`: download and parse the `params.xml` files of
#'   the data set. The function return a `data.frame` or a `list` of
#'   `data.frame` with 2 columns (Parameter Name, Value). Use `fileName` to
#'   parse additional `xml` files in the data.set.
#'
#' - `massive_number_files()`: return the number of data files in a specified
#'   MassIVE data set. Use `pattern` to filter files by name using a regular
#'   expression, default: `pattern = "mzML$|CDF$|cdf$|mzXML$"`.
#'
#' - `massive_delete_cache()`: removes all local content for the MassIVE
#'   data set with ID `massiveId`. This will delete eventually present
#'   locally cached data files for the specified data set. This does not
#'   change any other data eventually present in the local `BiocFileCache`.
#'
#' @details
#'
#' Data retrieval follows three main steps. First, the package queries the
#' [GNPS2 DB](https://datasetcache.gnps2.org/datasette/database/filename)
#' to list all files for the provided `massiveId`, filtering them by
#' `filePattern` to retain only formats supported by `MsBackendMzR` (mzML,
#' CDF, mzXML). Second, the FTP link is retrieved from
#' [MassIVE](https://massive.ucsd.edu/ProteoSAFe/). If the requested files are
#' in the `ccms_peak` folder, the FTP link is updated by changing the volume
#' from the project-specific one to volume `z01`, which contains the
#' `ccms_peak` folder for all projects. Each file is then downloaded from the
#' MassIVE FTP server and cached locally. Files already present in the cache
#' are not re-downloaded. Third, the cached local paths are passed to
#' [Spectra::MsBackendMzR()] to read and index the spectral data. Two
#' additional per-spectrum variables are populated: `"massive_id"` and
#' `"data_file"`. When `offline = TRUE`, the remote query is skipped and
#' only previously cached content is used.
#'
#'
#' @param x `character(1)` with the ID of the MassIVE data set (usually
#'     starting with a *MSV* followed by a number).
#'
#' @param massiveId `character(1)` with the ID of a single MassIVE data
#'     set/experiment.
#'
#' @param mustWork for `massive_ftp_path()`: `logical(1)` whether the validity
#'     of the path should be verified or not. By default (with
#'     `mustWork = TRUE`) the function throws an error if either the data set
#'     does not exist or if the folder can not be accessed (e.g. if no internet
#'     connection is available).
#'
#' @param pattern for `massive_list_files()`, `massive_sync_data_files()`,
#'     `massive_cached_data_files()`, `massive_donwload_file()`, and
#'     `massive_number_files()`: `character(1)` defining a pattern to filter
#'     the file names, such as `pattern = "mzML$"` to retrieve the file names
#'     of all files of the data set (i.e., files with extension `"mzML"`). This
#'     parameter is passed to the [grepl()] function.
#'
#' @param fileName for `massive_sync_data_files()`,
#'     `massive_cached_data_files()` and `massive_download_file()`: optional
#'     `character` defining the names of specific data files of a data set that
#'     should be downloaded and cached.
#'
#' @param path for `massive_download_file()`: optional `character` defining the
#'     directory where download the files.
#'
#' @param overwrite for `massive_download_file()`: `logical(1)` whether
#'     existing files should be overwritten. Defaults to `FALSE`, in which
#'     case files that already exist in `path` are skipped.
#'
#' @return
#'
#' - For `massive_ftp_path()`: `character(1)` with the ftp path to the specified
#'   data set on the MassIVE ftp server.
#' - For `massive_list_files()`: `character` with the names of the files in the
#'   data set's base ftp directory.
#' - For `massive_sync_data_files()` and `massive_cached_data_files()`: a
#'   `data.frame` with the MassIVE ID, the name(s) and remote and
#'   local file names of the synchronized data files
#' - For `massive_number_files()`: `integer(1)` with the number of data files
#'   in the data set.
#'
#' @author Johannes Rainer, Philippine Louail, Gabriele Tomè
#'
#' @examples
#'
#' ## Get the FTP path to the data set MSV000080547
#' massive_ftp_path("MSV000080547")
#'
#' ## Retrieve available files (and directories) for the data set MSV000080547
#' massive_list_files("MSV000080547")
#'
#' ## Retrieve the available .mzML files.
#' mzMLfiles <- massive_list_files("MSV000080547", pattern = "mzML$")
#' mzMLfiles
#'
#' ## Download parameter file for the data set MSV000080547
#' massive_download_file("MSV000080547", pattern = "params.xml",
#'                       path = tempdir())
#'
NULL


#' @importFrom rvest read_html html_elements html_attr
#'
#' @importFrom MsCoreUtils retry
#'
#' @rdname MassIVE-utils
#'
#' @export
massive_ftp_path <- function(x = character(), mustWork = TRUE) {
    if (length(x) != 1L)
        stop("'x' has to be a single ID.")

    url <- paste0("https://massive.ucsd.edu/ProteoSAFe/",
                  "dataset.jsp?accession=", x)
    tryCatch({
        res <- retry(read_html(url) |>
                         html_elements("input[value^='ftp:']") |>
                         html_attr("value"),
                     sleep_mult = .sleep_mult(),
                     retry_on = .RETRY_ON_PATTERN,
                     ntimes = 3L)
    }, error = function(e) {
        stop("Failed to connect to MassIVE. No internet connection? ",
             "Does the data set \"", x, "\" exist?\n - ", e$message,
             call. = FALSE)
    })

    if (mustWork)
        massive_list_files(x)
    res
}


#' @rdname MassIVE-utils
#'
#' @export
massive_list_files <- function(x = character(), pattern = NULL) {
    if(length(x) > 1)
        stop("Provide a single MassIVE ID")

    project_annotation <- gnps2_query(x)
    fls <- project_annotation$filepath

    if (length(pattern))
        fls[grepl(pattern, fls)]
    else
        fls
}


#' @rdname MassIVE-utils
#'
#' @importFrom progress progress_bar
#'
#' @importFrom utils capture.output URLencode download.file
#'
#' @importFrom MsCoreUtils retry
#'
#' @export
massive_download_file <- function(massiveId = character(), pattern = "*",
                                  fileName = character(), path = "./",
                                  overwrite = FALSE){
    if (!length(massiveId))
        stop("No MassIVE data set ID provided with parameter 'massiveId'")

    fpath <- massive_ftp_path(massiveId, mustWork = FALSE)
    dfiles <- massive_list_files(massiveId, pattern = pattern)
    if (!length(dfiles)) {
        stop("No files matching the provided file pattern found for ",
             "MassIVE data set ", massiveId, ".", call. = FALSE)
    }

    if (length(fileName)) {
        keep <- basename(dfiles) %in% fileName
        if (!any(keep))
            stop("None of the 'fileName' found in data set \"", massiveId, "\"")
        dfiles <- dfiles[keep]
    }

    ## Create dir if not exist
    if (!dir.exists(path)) {
        dir.create(path, recursive = TRUE)
    }

    ## Update the Volume if files are in ccms_peak folder
    ## ccms_peak is in volume z01 for all the project
    api_z_volume <- "ftp://massive-ftp.ucsd.edu/z01/"
    ffiles <- vapply(dfiles,
                     function(f) {
                         u <- ifelse(grepl("^ccms_peak", f),
                                     paste0(api_z_volume, massiveId, "/", f),
                                     paste0(fpath, f))
                         ## URLencode for file name with spaces
                         gsub("%3A", ":",
                            gsub("%2F", "/",
                                URLencode(u, reserved = TRUE)))
                     }, FUN.VALUE = character(1), USE.NAMES = FALSE)

    ## Save files in the folder
    pb <- progress_bar$new(format = paste0("[:bar] :current/:",
                                           "total (:percent) in ",
                                           ":elapsed"),
                           total = length(ffiles), clear = FALSE)
    res <- lapply(ffiles, function(z) {
        pb$tick()
        dest <- file.path(path, basename(z))
        if (file.exists(dest) && !overwrite) {
            message("File '", basename(z), "' already exists in '",
                    path, "'. Skipping. Use 'overwrite = TRUE' to replace.")
            return(invisible(NULL))
        }
        invisible(capture.output(suppressMessages(
            retry(download.file(url = z, destfile = dest, mode = "wb"),
                  sleep_mult = .sleep_mult(),
                  retry_on = .RETRY_ON_PATTERN))))
    })
}

#' @rdname MassIVE-utils
#'
#' @importFrom progress progress_bar
#'
#' @importFrom xml2 read_xml xml_find_all xml_attrs xml_text
#'
#' @importFrom MsCoreUtils retry
#'
#' @export
massive_param_file <- function(massiveId = character(),
                               fileName = "params.xml") {
    if (!length(massiveId))
        stop("No MassIVE data set ID provided with parameter 'massiveId'")

    fpath <- massive_ftp_path(massiveId, mustWork = FALSE)
    dfiles <- massive_list_files(massiveId)

    if (length(fileName)) {
        keep <- basename(dfiles) == fileName
        if (!any(keep))
            stop("No '", fileName, "' found in data set \"", massiveId, "\"")
        dfiles <- dfiles[keep]
    }

    if (length(dfiles) > 1) {
        message("Multiple '", fileName, "' found in the data set. ",
                "Downloading all.\n\t- ", paste0(dfiles, collapse = "\n\t- "))
    }

    ## Prepare ftp link
    ffiles <- paste0(fpath, dfiles)

    pb <- progress_bar$new(format = paste0("[:bar] :current/:",
                                           "total (:percent) in ",
                                           ":elapsed"),
                           total = length(ffiles), clear = FALSE)
    res <- lapply(ffiles, function(z) {
        pb$tick()
        ## Get and parse the xml file
        xml <- retry(read_xml(z), sleep_mult = .sleep_mult(),
                     retry_on = .RETRY_ON_PATTERN)
        xml_parsed <- xml_find_all(xml, "//parameter")
        df <- data.frame("ParameterName" = unlist(xml_attrs(xml_parsed)),
                         "Value" = xml_text(xml_parsed))
        df
    })

    names(res) <- dfiles

    if (length(res) == 1)
        res <- res[[1]]

    res
}

#' @rdname MassIVE-utils
#'
#' @export
massive_number_files <- function(massiveId = character(),
                                 pattern = "mzML$|CDF$|cdf$|mzXML$") {
    if(length(massiveId) != 1)
        stop("Provide a single MassIVE ID")

    length(massive_list_files(massiveId, pattern))
}

################################################################################
##
## File caching utils
##
################################################################################

#' @rdname MassIVE-utils
#'
#' @export
massive_sync_data_files <- function(massiveId = character(),
                                    pattern = "mzML$|CDF$|cdf$|mzXML$",
                                    fileName = character()) {
    if (!length(massiveId))
        stop("No MassIVE data set ID provided with parameter 'massiveId'")
    .massive_data_files(massiveId, pattern, fileName)
}

#' @rdname MassIVE-utils
#'
#' @export
massive_cached_data_files <- function(massiveId = character(),
                                      pattern = "*", fileName = character()) {
    res <- .massive_data_files_offline(massiveId = massiveId,
                                       pattern = pattern)
    if (length(fileName))
        res <- res[basename(res$data_file) %in% fileName, ]
    else res
}

#' Get information on data files for a given MSV ID eventually
#' downloading and caching them. This function needs an active internet
#' connection as it queries the MSV ftp server for available data files
#' that are then cached. The function returns the **local** file names
#' **from the cache**.
#'
#' The function:
#' - retrieves all files for one MassIVE ID.
#' - uses BiocFileCache to cache these files, i.e. downloading them if they
#'   are not yet cached.
#' - returns a `data.frame` with all information.
#'
#' This `data.frame` has one row per data file with columns:
#' - `"rid"`: the BiocFileCache ID of each file.
#' - `"massive_id"`: the MSV ID
#' - `"data_file"`: the name of the data file
#' - `"rpath"`: the name of the cached data file (full local path)
#'
#' @note
#'
#' Download from MsBackendMassIVE is tried 3 times with an increasing time
#' delay between tries that can be configured using the
#' `"massive.sleep_mult"` option.
#'
#' @importFrom BiocFileCache BiocFileCache
#'
#' @importFrom progress progress_bar
#'
#' @importMethodsFrom BiocFileCache bfcrpath bfcmeta<-
#'
#' @importFrom utils capture.output URLencode
#'
#' @importFrom MsCoreUtils retry
#'
#' @noRd
.massive_data_files <- function(massiveId = character(),
                                pattern = "mzML$|CDF$|mzXML$",
                                fileName = character()) {
    fpath <- massive_ftp_path(massiveId, mustWork = FALSE)
    dfiles <- massive_list_files(massiveId, pattern = pattern)
    if(!length(dfiles)) {
        stop("No files matching the provided file pattern found for ",
             "MassIVE data set ", massiveId, ".", call. = FALSE)
    }

    if (length(fileName)) {
        keep <- basename(dfiles) %in% fileName
        if (!any(keep))
            stop("None of the 'fileName' found in data set \"", massiveId, "\"")
        dfiles <- dfiles[keep]
    }

    ## Update the Volume if files are in ccms_peak folder
    ## ccms_peak is in volume z01 for all the project
    api_z_volume <- "ftp://massive-ftp.ucsd.edu/z01/"
    ffiles <- vapply(dfiles,
                     function(f) {
                         u <- ifelse(grepl("^ccms_peak", f),
                                     paste0(api_z_volume, massiveId, "/", f),
                                     paste0(fpath, f))
                         ## URLencode for file name with spaces
                         gsub("%3A", ":",
                            gsub("%2F", "/",
                                URLencode(u, reserved = TRUE)))
                     }, FUN.VALUE = character(1), USE.NAMES = FALSE)

    ## Cache files
    bfc <- BiocFileCache()
    pb <- progress_bar$new(format = paste0("[:bar] :current/:",
                                           "total (:percent) in ",
                                           ":elapsed, :rate"),
                           total = length(ffiles), clear = FALSE)
    lfiles <- unlist(lapply(ffiles, function(z) {
        pb$tick()
        invisible(capture.output(suppressMessages(
            f <- retry(bfcrpath(bfc, z, fname = "exact"),
                       sleep_mult = .sleep_mult(),
                       retry_on = .RETRY_ON_PATTERN))))
        f
    }))

    ## Add and store metadata to the cached files
    mdata <- data.frame(
        rid = names(lfiles),
        massive_id = massiveId,
        data_file = dfiles)
    bfcmeta(bfc, name = "MSV", overwrite = TRUE) <- mdata
    mdata$rpath <- lfiles
    mdata
}

#' Check for a given MSV ID if we have cached data files. This function is
#' supposed to work also offline using only previously cached content.
#' In contrast to `.massive_data_files()`, this function just
#' queries the BiocFileCache for content and returns a `data.frame` with
#' all cached data files for a given MSV ID, assay name and pattern. The
#' returned `data.frame` has the same format as the one returned by
#' `.massive_data_files()`.
#'
#' @importMethodsFrom BiocFileCache bfcquery
#'
#' @noRd
.massive_data_files_offline <- function(massiveId = character(),
                                        pattern = "mzML$|CDF$|mzXML$") {
    bfc <- BiocFileCache()
    if (!.massive_has_massive_table())
        stop("No local MassIVE cache available. Please re-run with ",
             "'offline = FALSE' first.", call. = FALSE)
    res <- as.data.frame(bfcquery(bfc, massiveId, field = "massive_id"))
    res <- res[grepl(pattern, res$data_file), ]
    if (!nrow(res))
        stop("No locally cached data files found for the specified ",
             "parameters.", call. = FALSE)
    res[, c("rid", "massive_id", "data_file", "rpath")]
}

#' @importMethodsFrom BiocFileCache bfcmetalist
#'
#' @noRd
.massive_has_massive_table <- function() {
    bfc <- BiocFileCache()
    any(bfcmetalist(bfc) == "MSV")
}

#' @rdname MassIVE-utils
#'
#' @importFrom BiocFileCache bfcremove bfcinfo
#'
#' @export
massive_delete_cache <- function(massiveId = character()) {
    bfc <- BiocFileCache()
    b <- as.data.frame(bfcinfo(bfc))
    if (nrow(b) && any(colnames(b) == "massive_id")) {
        if (length(massiveId)) {
            rem <- b[b$massive_id %in% massiveId, ]
            bfcremove(bfc, rids = rem$rid)
        }
    }
}

#' @noRd
.sleep_mult <- function() {
    as.integer(getOption("massive.sleep_mult", default = 7L))
}


## "resolve"    missing internet connection
## "connection" server not reachable
.RETRY_ON_PATTERN <- "resolve|connection"
