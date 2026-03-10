## MSV000080547: MassIVE ID with small mzML.
## MSV000083058: MassIVE ID without CCMS_PEAK folder. The mzML files are in
##               original volumes.
## MSV000083385: MassIVE ID with CCMS_PEAK folder. The mzML files are in volume
##               z01.

test_that("MsBackendMassIVE works", {
    res <- MsBackendMassIVE()
    expect_s4_class(res, "MsBackendMassIVE")
    expect_true(inherits(res, "MsBackendMzR"))
})

test_that("backendInitialize,MsBackendMassIVE works", {
    ## Test errors
    expect_error(backendInitialize(MsBackendMassIVE(),
                                   data = data.frame(a = 3)),
                 "Parameter 'data' is not supported")
    expect_error(backendInitialize(MsBackendMassIVE(),
                                   massiveId = c("a", "b")),
                 "Parameter 'massiveId' is required and can")
    expect_error(backendInitialize(MsBackendMassIVE(), massiveId = "a"),
                 "Failed to connect")

    ## Test NMR data set
    expect_error(backendInitialize(MsBackendMassIVE(),
                                   massiveId = "MSV1000000000"),
                 "Failed to connect")
    ## Test real data set.
    res <- backendInitialize(MsBackendMassIVE(), massiveId = "MSV000080547",
                             filePattern = "1.mzML$")
    expect_s4_class(res, "MsBackendMassIVE")
    expect_true(all(c("massive_id", "data_file") %in%
                        Spectra::spectraVariables(res)))
    expect_true(all(res$massive_id == "MSV000080547"))

    ## Offline
    res_o <- backendInitialize(MsBackendMassIVE(), massiveId = "MSV000080547",
                               filePattern = "1.mzML$", offline = TRUE)
    expect_equal(Spectra::rtime(res), Spectra::rtime(res_o))
})

test_that("backendRequiredSpectraVariables,MsBackendMassIVE works", {
    expect_equal(backendRequiredSpectraVariables(MsBackendMassIVE()),
                 c("dataStorage", "scanIndex", "massive_id", "data_file"))
})

test_that("massive_sync works", {
    expect_error(massive_sync(3, offline = TRUE), "'x' is expected to be")

    x <- backendInitialize(MsBackendMassIVE(), massiveId = "MSV000080547",
                           filePattern = "1.mzML$", offline = TRUE)
    res <- massive_sync(x, offline = TRUE)
    expect_equal(rtime(x), rtime(res))
    expect_equal(mz(x[1:50]), mz(res[1:50]))

    ## Remove local content.
    massive_delete_cache("MSV000080547")
    expect_error(massive_sync(x, offline = TRUE),
                 "No locally cached data files")

    Sys.sleep(4)

    ## Re-add content
    res <- massive_sync(x, offline = FALSE)
    expect_equal(rtime(x), rtime(res))
    expect_equal(mz(x[1:50]), mz(res[1:50]))

    ## Error.
    with_mocked_bindings(
        "massive_cached_data_files" = function(massiveId, ...) {
            data.frame(rid = c("1", "2"),
                       data_file = c("a", "b"),
                       rpath = "tmp")
        },
        code = expect_error(massive_sync(x, offline = TRUE), "not available")
    )
})

test_that(".valid_massive_required_columns works", {
    x <- MsBackendMassIVE()
    expect_equal(.valid_massive_required_columns(x), character())
    x@spectraData <- DataFrame(a = 1:4, b = "c")
    expect_match(.valid_massive_required_columns(x), "One or more")
    x@spectraData$massive_id <- 3
    x@spectraData$data_file <- "b"
    expect_equal(.valid_massive_required_columns(x), character())
})

test_that(".valid_files_local works", {
    x <- MsBackendMassIVE()
    expect_equal(.valid_files_local(x), character())
    x@spectraData <- DataFrame(a = 1:4, b = "c", dataStorage = "d")
    expect_match(.valid_files_local(x), "One or more of the data files")
})

test_that(".massive_data_files and .massive_data_files_offline works", {
    ## error
    expect_error(.massive_data_files(massiveId = "MSV1000000000"),
                 "Failed to connect")

    massive_delete_cache("MSV000080547")
    ## bfc <- BiocFileCache::BiocFileCache()
    ## BiocFileCache::cleanbfc(bfc, days = -10, ask = FALSE)
    ## BiocFileCache::bfcmetaremove(bfc, "MSV")

    ## Error if no cache available
    with_mocked_bindings(
        ".massive_has_massive_table" = function() FALSE,
        code = expect_error(.massive_data_files_offline("MSV000080547"),
                            "No local MassIVE cache")
    )

    ## Cache the data: MSV000080547 contains small cdf files, but they are
    ## listed in the Raw Spectral Data File column. Will use a specfic pattern
    ## to just load 2 files.
    a <- .massive_data_files("MSV000080547", pattern = "1.mzML$")
    expect_true(is.data.frame(a))
    expect_true(nrow(a) == 2)
    expect_true(all(a$massive_id == "MSV000080547"))
    ## Re-call function the data.
    Sys.sleep(4)
    b <- .massive_data_files("MSV000080547", pattern = "1.mzML$")
    expect_true(is.data.frame(b))
    expect_true(nrow(b) == 2)
    expect_true(all(b$massive_id == "MSV000080547"))
    expect_equal(a$rpath, b$rpath)

    ## with fileNames
    expect_error(.massive_data_files("MSV000080547", pattern = "1.mzML$",
                                   fileName = c("a", "b")), "None of the ")


    expect_true(.massive_has_massive_table())

    ## Use offline
    expect_error(.massive_data_files_offline("MSV000080547", pattern = ".raw$"),
                 "No locally cached data files")

    d <- .massive_data_files_offline("MSV000080547", pattern = "1.mzML$")
    expect_true(is.data.frame(a))
    expect_true(nrow(a) == 2)
    expect_true(all(a$massive_id == "MSV000080547"))
    expect_equal(a$rpath, d$rpath)
})

test_that("massive_sync_data_files works", {
    expect_error(massive_sync_data_files(), "No MassIVE data")
    res <- massive_sync_data_files("MSV000080547", pattern = "*",
                                 fileName = c("AG_spiked_sample11.mzML"))
    expect_true(is.data.frame(res))
    expect_equal(nrow(res), 1L)
    expect_equal(res$massive_id, "MSV000080547")
})

test_that("massive_cached_data_files works", {
    res <- massive_cached_data_files()
    expect_true(is.data.frame(res))
    expect_true(nrow(res) > 0)

    res <- massive_cached_data_files(fileName = "other")
    expect_true(is.data.frame(res))
    expect_true(nrow(res) == 0)
})

test_that("massive_ftp_path works", {
    res <- massive_ftp_path("MSV000080547", mustWork = FALSE)
    expect_true(grepl("^ftp://", res))
    expect_true(grepl("MSV000080547/$", res))

    expect_error(massive_ftp_path("A", mustWork = FALSE), "Failed to connect")

    expect_error(massive_ftp_path("A", mustWork = TRUE), "Failed to connect")

    expect_error(massive_ftp_path(c("A", "B")), "single ID")
})

test_that("massive_list_files works", {
    Sys.sleep(4)
    res <- massive_list_files("MSV000080547", pattern = "1.mzML$")
    expect_true(length(res) == 2)
    expect_error(massive_list_files("AAA"), "Failed to connect")
})

test_that("massive_delete_cache works", {
    bfc <- BiocFileCache()
    l <- length(bfc)
    massive_delete_cache()
    expect_equal(length(bfc), l)

    massive_delete_cache("MSV000080547")
    i <- bfcinfo(bfc)
    expect_true(!any(i$massive_id %in% "MSV000080547"))
})

test_that("backendMerge,MsBackendMassIVE works", {
    ## Online mode
    be <- backendInitialize(MsBackendMassIVE(), massiveId = "MSV000080547",
                            filePattern = "1.mzML$")
    l <- split(be, factor(be$dataOrigin, levels = unique(be$dataOrigin)))
    res <- backendMerge(l)

    expect_equal(rtime(be), rtime(res))
    expect_equal(dataOrigin(be), dataOrigin(res))
    expect_equal(mz(be), mz(res))

    ## Offline data
    a <- backendInitialize(MsBackendMassIVE(), massiveId = "MSV000080547",
                           filePattern = "11.mzML$", offline = TRUE)
    b <- backendInitialize(MsBackendMassIVE(), massiveId = "MSV000083058",
                           filePattern = "JPL29462.mzML")

    d <- backendMerge(a, b)
    expect_true(length(d) == (length(a) + length(b)))
    expect_equal(rtime(d), c(rtime(a), rtime(b)))
})