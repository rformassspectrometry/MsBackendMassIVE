#' @title MsBackend representing MS data from MassIVE
#'
#' @name MsBackendMassIVE
#'
#' @aliases MsBackendMassIVE-class
#'
#' @description
#'
#' `MsBackendMassIVE` retrieves and represents mass spectrometry (MS)
#' data from proteomics and metabolomics experiments stored in the
#' [MassIVE](https://massive.ucsd.edu/ProteoSAFe/static/massive.jsp)
#' (Mass Spectrometry Interactive Virtual Environment) repository, a
#' community resource developed by the NIH-funded Center for Computational
#' Mass Spectrometry at UC San Diego. The backend directly extends the
#' [Spectra::MsBackendMzR] backend from the *Spectra* package and hence
#' supports MS data in mzML, netCDF and mzXML format. Data in other formats
#' can not be loaded with `MsBackendMassIVE`.
#' Upon initialization with the `backendInitialize()` method, the
#' `MsBackendMassIVE` backend downloads and caches the MS data files of
#' a dataset locally, avoiding repeated download of the data.
#' The local data cache is managed by Bioconductor's *BiocFileCache* package.
#' See the help and vignettes from that package for details on cached data
#' resources. Additional utility functions for management of cached files are
#' also provided by *MsBackendMassIVE*. See help for
#' [massive_cached_data_files()] for more information.
#'
#' @section Initialization and loading of data:
#'
#' New instances of the class can be created with the `MsBackendMassIVE()`
#' function. Data is loaded and initialized using the `backendInitialize()`
#' function which can be configured with parameters `massiveId` and
#' `filePattern`. `massiveId` must be the ID of a **single** (existing)
#' MassIVE dataset (e.g. `"MSV000079514"`). Optional parameter `filePattern`
#' defines the pattern used to filter the file names of the MS data files.
#' It defaults to data files with file endings of supported MS data formats.
#' `backendInitialize()` requires an active internet connection as the
#' function first compares the remote file content to the locally cached
#' files and eventually synchronizes changes/updates. This can be skipped
#' with `offline = TRUE` in which case only locally cached content is queried.
#'
#' The `backendRequiredSpectraVariables()` function returns the names of the
#' spectra variables required for the backend to provide the MS data.
#'
#' The `massive_sync()` function can be used to *synchronize* the local data
#' cache and ensure that all data files are locally available. The function
#' will check the local cache and eventually download missing data files from
#' the MassIVE repository.
#'
#' @note
#'
#' To account for high server load and eventually failing or rejected
#' downloads from the MassIVE FTP server (`ftp://massive-ftp.ucsd.edu/`), the
#' download functions repeatedly retry to download a file. An error is thrown
#' if the download fails for 3 consecutive attempts. Between each attempt,
#' the function waits for an increasing time period (5 seconds between the
#' first and second and 10 seconds between the 2nd and 3rd attempt). This
#' time period can also be configured with the `"massive.sleep_mult"` option,
#' which defines the *sleep time multiplicator* (defaults to 5).
#'
#' @param object an instance of `MsBackendMassIVE`.
#'
#' @param massiveId `character(1)` with the ID of a single MassIVE data
#'     set/experiment.
#'
#' @param filePattern `character` with the pattern defining the supported (or
#'     requested) file types. Defaults to
#'     `filePattern = "mzML$|CDF$|cdf$|mzXML$"` hence restricting to mzML,
#'     CDF and mzXML files which are supported by *Spectra*'s
#'     `MsBackendMzR` backend.
#'
#' @param offline `logical(1)` whether only locally cached content should be
#'     evaluated/loaded.
#'
#' @param x an instance of `MsBackendMassIVE`.
#'
#' @param ... additional parameters; currently ignored.
#'
#' @return
#'
#' - For `MsBackendMassIVE()`: an instance of `MsBackendMassIVE`.
#' - For `backendInitialize()`: an instance of `MsBackendMassIVE` with
#'   the MS data of the specified MassIVE data set.
#' - For `backendRequiredSpectraVariables()`: `character` with spectra
#'   variables that are needed for the backend to provide the MS data.
#' - For `massive_sync()`: the input `MsBackendMassIVE` with the paths to
#'   the locally cached data files being eventually updated.
#'
#' @details
#'
#' File names for data files are by default extracted from the column
#' `"filepath"` of the
#' [GNPS2 database](https://datasetcache.gnps2.org/datasette/database/filename).
#'
#' The backend uses the
#' [BiocFileCache](https://bioconductor.org/packages/BiocFileCache) package for
#' caching of the data files. These are stored in the default local
#' *BiocFileCache* cache along with additional metadata that includes the
#' MassIVE ID. Note that at present only MS data files in *mzML*, *CDF*
#' and *mzXML* format are supported.
#'
#' The `MsBackendMassIVE` backend defines and provides additional spectra
#' variables `"massive_id"` and `"data_file"` that list the MassIVE ID,
#' and the original data file name on the MassIVE ftp
#' server for each individual spectrum. The `"data_file"` can
#' be used for the mapping between the experiment's samples and the
#' individual data files, respective their spectra.
#'
#' The `MsBackendMassIVE` backend is considered *read-only* and does
#' thus not support changing *m/z* and intensity values directly.
#'
#' @importClassesFrom Spectra MsBackendMzR
#'
#' @importClassesFrom Spectra MsBackendDataFrame
#'
#' @importFrom S4Vectors DataFrame
#'
#' @exportClass MsBackendMassIVE
#'
#' @author Gabriele Tomè, Philippine Louail, Johannes Rainer
#'
#' @examples
#'
#' library(MsBackendMassIVE)
#'
#' ## List files of a MassIVE data set
#' massive_list_files("MSV000080547")
#'
#' ## Initialize a MsBackendMassIVE representing all MS data files of
#' ## the data set with the ID "MSV000080547". This will download and cache all
#' ## files and subsequently load and represent them in R.
#'
#' be <- backendInitialize(MsBackendMassIVE(), "MSV000080547",
#'                         filePattern = "1.mzML$")
#' be
#'
#' ## The `massive_sync()` function can be used to ensure that all data files
#' ## are available locally. This function will eventually download missing data
#' ## files or update their paths.
#' be <- massive_sync(be)
NULL


setClass("MsBackendMassIVE",
         contains = "MsBackendMzR")

#' @rdname MsBackendMassIVE
#'
#' @importFrom methods new
#'
#' @export
MsBackendMassIVE <- function() {
    new("MsBackendMassIVE")
}

#' @rdname MsBackendMassIVE
#'
#' @importMethodsFrom ProtGenerics backendInitialize
#'
#' @importMethodsFrom Spectra backendInitialize
#'
#' @importMethodsFrom Spectra [
#'
#' @importMethodsFrom ProtGenerics dataOrigin
#'
#' @importFrom methods callNextMethod
#'
#' @importFrom methods as
#'
#' @importFrom Spectra MsBackendMzR
#'
#' @exportMethod backendInitialize
setMethod(
    "backendInitialize", "MsBackendMassIVE",
    function(object, massiveId = character(),
             filePattern = "mzML$|CDF$|cdf$|mzXML$", offline = FALSE, ...) {
        dots <- list(...)
        if (any(names(dots) == "data"))
            stop("Parameter 'data' is not supported for ",
                 "'MsBackendMassIVE'. A 'MsBackendMassIVE' object ",
                 "can only be instantiated using 'backendInitialize()'.")
        if (length(massiveId) != 1)
            stop("Parameter 'massiveId' is required and can only be a single ",
                 "ID of a MassIVE data set.")
        if (offline)
            mdata <- .massive_data_files_offline(massiveId, filePattern)
        else mdata <- .massive_data_files(massiveId, filePattern)
        object <- backendInitialize(MsBackendMzR(), files = mdata$rpath)
        idx <- match(dataOrigin(object),
                     normalizePath(mdata$rpath, mustWork = FALSE))
        object@spectraData$massive_id <- mdata$massive_id[idx]
        object@spectraData$data_file <- mdata$data_file[idx]
        object <- as(object, "MsBackendMassIVE")
    })


#' @rdname MsBackendMassIVE
#'
#' @importMethodsFrom Spectra backendRequiredSpectraVariables
#'
#' @exportMethod backendRequiredSpectraVariables
setMethod(
    "backendRequiredSpectraVariables", "MsBackendMassIVE",
    function(object, ...) {
        c(callNextMethod(), "massive_id", "data_file")
    })

.valid_massive_required_columns <- function(object) {
    if (nrow(object@spectraData)) {
        if (!all(c("massive_id", "data_file") %in%
                 colnames(object@spectraData)))
            return(paste0("One or more of required spectra variable(s) ",
                          "\"massive_id\", \"data_file\" is (are) missing"))
    }
    character()
}

.valid_files_local <- function(object) {
    if (nrow(object@spectraData)) {
        if (!all(file.exists(object@spectraData$dataStorage)))
            return(paste0("One or more of the data files are not found in ",
                          "the local cache. Please run `massive_sync()` on ",
                          "the data object."))
    }
    character()
}

setValidity("MsBackendMassIVE", function(object) {
    msg <- .valid_massive_required_columns(object)
    msg <- c(msg, .valid_files_local(object))
    if (length(msg)) return(msg)
    else TRUE
})

#' @importFrom methods validObject
#'
#' @rdname MsBackendMassIVE
#'
#' @export
massive_sync <- function(x, offline = FALSE) {
    if (!inherits(x, "MsBackendMassIVE"))
        stop("'x' is expected to be an instance of 'MsBackendMassIVE'")
    sdata <- unique(
        as.data.frame(x@spectraData[, c("massive_id", "data_file")]))
    cn <- c("data_file", "rpath")
    res <- lapply(split(sdata, sdata$massive_id), function(z, offline) {
        if (offline)
            massive_cached_data_files(
                sdata$massive_id[1L], pattern = "*",
                fileName = basename(sdata$data_file))[, cn]
        else
            massive_sync_data_files(
                sdata$massive_id[1L], pattern = "*",
                fileName = basename(sdata$data_file))[, cn]
    }, offline = offline)
    res <- do.call(rbind, res)
    if (!all(sdata$data_file %in%
             res$data_file))
        stop("Some of the data files are not available. Please run with ",
             "'offline = FALSE' to ensure data missing data files get ",
             "downloaded.")
    x@spectraData$dataStorage <- res[match(
        x@spectraData$data_file,
        res$data_file), "rpath"]
    validObject(x)
    x
}


################################################################################
## Utility functions for MassIVE
##
################################################################################

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
#'   With `mustWork = TRUE` (the default) the function throws an error if
#'   either because the data set does not exist in
#'   [GNPS2 DB](https://datasetcache.gnps2.org/datasette/database/filename) or
#'   no internet connection is available. The function returns a
#'   `character(1)` with the FTP path to the data set folder.
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
#' - `massive_sync_data_files()`: synchronize data files of a specifies
#'   MassIVE data set eventually downloading and locally caching them.
#'   Parameter `fileName` allows to specify names of selected data files to
#'   sync.
#'
#' - `massive_delete_cache()`: removes all local content for the MassIVE
#'   data set with ID `massiveId`. This will delete eventually present
#'   locally cached data files for the specified data set. This does not
#'   change any other data eventually present in the local `BiocFileCache`.
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
#' @param pattern for `massive_list_files()`, `massive_sync_data_files()` and
#'     `massive_cached_data_files()`: `character(1)` defining a pattern
#'     to filter the file names, such as `pattern = "mzML$"` to retrieve the
#'     file names of all files of the data set (i.e., files with extension
#'     `"mzML"`). This parameter is passed to the [grepl()] function.
#'
#' @param fileName for `massive_sync_data_files()` and
#'     `massive_cached_data_files()`: optional `character`
#'     defining the names of specific data files of a data set that should be
#'     downloaded and cached.
#'
#' @return
#'
#' - For `massive_ftp_path()`: `character(1)` with the ftp path to the specified
#'   data set on the MassIVE ftp server.
#' - For `massive_list_files()`: `character` with the names of the files in the
#'   data set's base ftp directory.
#' - For `massive_sync_data_files()` and `massive_cached_data_files()`: a
#'   `data.frame` with the MassIVE ID, the name(s) and remote and
#'   local file names of the synchronized data files.
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
NULL


#' @importFrom rvest read_html html_elements html_attr
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
                     sleep_mult = .sleep_mult())
    }, error = function(e) {
        stop("Failed to connect to MassIVE. No internet connection? ",
             "Does the data set \"", x, "\" exist?\n - ", e$message,
             call. = FALSE)
    })

    if (mustWork)
        massive_list_files(x)
    res
}


#' @importFrom httr GET content
#'
#' @importFrom utils read.csv
#'
#' @rdname MassIVE-utils
#'
#' @export
massive_list_files <- function(x = character(), pattern = NULL) {

    api = "https://datasetcache.gnps2.org/datasette/database.csv"
    params = list("_stream" = "on",
                  "_sort" = "filepath",
                  "_size" = "max",
                  "sql" = paste0('SELECT * FROM filename ',
                                 'WHERE dataset = "', x, '"'))
    tryCatch({
        res <- retry(
            GET(api, query = params),
            sleep_mult = .sleep_mult())
    }, error = function(e) {
        stop("Failed to connect to MassIVE. No internet connection? ",
             "Does the data set \"", x, "\" exist?\n - ", e$message,
             call. = FALSE)
    })
    project_annotation <- retry(read.csv(text = content(res, as = "text")),
                                sleep_mult = .sleep_mult())
    fls <- project_annotation$filepath

    ## Check query as a correct id
    if(!length(fls))
        stop("Failed to connect to MassIVE. No internet connection? ",
             "Does the data set \"", x, "\" exist?", call. = FALSE)

    if (length(pattern))
        fls[grepl(pattern, fls)]
    else fls
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
#' @importFrom utils capture.output
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
    api_z_volume = "ftp://massive-ftp.ucsd.edu/z01/"
    ffiles <- sapply(dfiles,
                     function(f) {
                         ifelse(grepl("^ccms_peak", f),
                                paste0(api_z_volume, massiveId, "/", f),
                                paste0(fpath, f))
                     }, USE.NAMES = FALSE)

    ## Cache files
    bfc <- BiocFileCache()
    pb <- progress_bar$new(format = paste0("[:bar] :current/:",
                                           "total (:percent) in ",
                                           ":elapsed"),
                           total = length(ffiles), clear = FALSE)
    lfiles <- unlist(lapply(ffiles, function(z) {
        pb$tick()
        invisible(capture.output(suppressMessages(
            f <- retry(bfcrpath(bfc, z, fname = "exact"),
                       sleep_mult = .sleep_mult()))))
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
