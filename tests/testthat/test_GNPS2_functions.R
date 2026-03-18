## MSV000080547: MassIVE ID with small mzML.
## MSV000083058: MassIVE ID without CCMS_PEAK folder. The mzML files are in
##               original volumes.
## MSV000083385: MassIVE ID with CCMS_PEAK folder. The mzML files are in volume
##               z01.
## MSV000065798: MassIVE ID in MassIVE website but not in GNPS2 database. In
##               MasssIVE it has only a .tar.gz file.

test_that("massive_gnps2_query works", {
    query_args <- NULL
    mock_GET <- function(url, query) {
        query_args <<- list(url = url, query = query)
        stop("simulated GET failure")
    }

    with_mocked_bindings("GET" = mock_GET, {
        expect_error(massive_gnps2_query("MSV000123456"),
                     "Failed to connect to GNPS2 dataset")
    })

    expect_equal(query_args$url,
                 "https://datasetcache.gnps2.org/datasette/database.csv")
    expect_match(query_args$query$sql,
                 'SELECT * FROM filename WHERE dataset IN ("MSV000123456")',
                 fixed = TRUE)

    Sys.sleep(1)
    res <- massive_gnps2_query("MSV000080547")
    expect_true(is.data.frame(res))

    Sys.sleep(1)
    res <- massive_gnps2_query(c("MSV000083058", "MSV000080547"))
    expect_true(is.data.frame(res))

    expect_error(massive_list_files("AAA"), "No MS data files found")

    expect_error(massive_list_files("MSV000065798"),
                 "No MS data files found")
})