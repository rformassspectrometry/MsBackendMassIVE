## MSV000080547: MassIVE ID with small mzML.
## MSV000083058: MassIVE ID without CCMS_PEAK folder. The mzML files are in
##               original volumes.
## MSV000083385: MassIVE ID with CCMS_PEAK folder. The mzML files are in volume
##               z01.
## MSV000065798: MassIVE ID in MassIVE website but not in GNPS2 database. In
##               MasssIVE it has only a .tar.gz file.

test_that("gnps2_query works", {
    query_args <- NULL
    mock_GET <- function(url, query) {
        query_args <<- list(url = url, query = query)
        stop("simulated GET failure")
    }

    with_mocked_bindings("GET" = mock_GET, {
        expect_error(gnps2_query("MSV000123456"),
                     "Failed to connect to GNPS2 dataset")
    })

    expect_equal(query_args$url,
                 "https://datasetcache.gnps2.org/datasette/database.csv")
    expect_match(query_args$query$sql,
                 'SELECT * FROM filename WHERE dataset IN ("MSV000123456")',
                 fixed = TRUE)

    res <- gnps2_query("MSV000080547")
    expect_true(is.data.frame(res))

    res <- gnps2_query(c("MSV000083058", "MSV000080547"))
    expect_true(is.data.frame(res))

    expect_error(gnps2_query("AAA"), "No MS data files found")

    expect_error(gnps2_query("MSV000065798"),
                 "No MS data files found")

    expect_error(gnps2_query("MSV000083058",
                             usi_pattern = "nonexistentpattern"),
                 "No files found")

    expect_error(gnps2_query("MSV000083058",
                             filepath_pattern = "nonexistentpattern"),
                 "No files found")

    res <- gnps2_query("MSV000100512", filepath_pattern = "metadata")
    expect_true(is.data.frame(res))
    expect_true(nrow(res) == 2)
})

test_that("gnps2_usi_download_link works", {
    expect_error(gnps2_usi_download_link(), "Provide 1 USI ID")
    expect_error(gnps2_usi_download_link(
        usi = c("mzspec:ST002115:HT1080_DMSO_01_HILIC.mzXML",
                "mzspec:ST002115:HT1080_DMSO_02_HILIC.mzXML")),
        "Provide 1 USI ID")


    query_args <- NULL
    mock_GET <- function(usi) {
        query_args <<- list(usi = usi)
        stop("simulated GET failure")
    }

    with_mocked_bindings("GET" = mock_GET, {
        expect_error(gnps2_query("mzspec:ST002115:HT1080_DMSO_01_HILIC.mzXML"),
                     "Failed to connect to GNPS2 dataset")
    })

    expect_error(gnps2_usi_download_link("notexistUsi"),
                 "Link not retrieved")

    ## MWB
    res <- gnps2_usi_download_link("mzspec:ST002115:HT1080_DMSO_01_HILIC.mzXML")
    expect_true(grepl("^https://www.metabolomicsworkbench.org", res))

    ## MassIVE
    res <- gnps2_usi_download_link(
        "mzspec:MSV000080547:peak/Quant_assesment_QE/AG_spiked_sample1.mzXML")
    expect_true(grepl("^https://massiveproxy.gnps2.org", res))

    ## Metabolights
    res <- gnps2_usi_download_link("mzspec:MTBLS39:FILES/AM063A.cdf")
    expect_true(grepl("^https://www.ebi.ac.uk", res))

})
