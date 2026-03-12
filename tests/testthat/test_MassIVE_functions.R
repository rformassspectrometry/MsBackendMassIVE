## MSV000080547: MassIVE ID with small mzML.
## MSV000083058: MassIVE ID without CCMS_PEAK folder. The mzML files are in
##               original volumes.
## MSV000083385: MassIVE ID with CCMS_PEAK folder. The mzML files are in volume
##               z01.
## MSV000065798: MassIVE ID in MassIVE website but not in GNPS2 database. In
##               MasssIVE it has only a .tar.gz file.

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

    ## MassIVE ID does not exist, it fail at the same way
    expect_error(massive_ftp_path("A", mustWork = FALSE), "Failed to connect")

    expect_error(massive_ftp_path("A", mustWork = TRUE), "Failed to connect")

    ## MassIVE ID exist on MassIVE but not in GNPS2 database. The project
    ## does not contain mzML/CDF/mzXML files
    res <- massive_ftp_path("MSV000065798", mustWork = FALSE)
    expect_true(grepl("^ftp://", res))
    expect_true(grepl("MSV000065798/$", res))

    expect_error(massive_ftp_path("MSV000065798", mustWork = TRUE),
                 "No files found")

    expect_error(massive_ftp_path(c("A", "B")), "single ID")
})

test_that("massive_list_files works", {
    Sys.sleep(4)
    res <- massive_list_files("MSV000080547", pattern = "1.mzML$")
    expect_true(length(res) == 2)
    expect_error(massive_list_files("AAA"), "No files found")
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
