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
#' if the download fails for 5 consecutive attempts. Between each attempt,
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

