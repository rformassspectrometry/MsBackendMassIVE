# Query the GNPS2 datasetchache resource

The GNPS2 *datasetcache* collects and provides general information on
data sets/experiments with their related MS data files for various
repositories including MassIVE and MetaboLights. The resource is updated
on a regular basis. *MsBackendMassIVE* provides utility functions to
retrieve information from this resource directly in R:

- `gnps2_query()`: query the datasetcache for metadata of data sets with
  the provided (MassIVE) dataset ID(s). Returns a `data.frame` with one
  row per file entry from the *filename* table.

- `gnps2_usi_download_link()`: retrieve the download link for a specific
  USI. Returns a `character(1)` with the link.

## Usage

``` r
gnps2_query(id = character(), usi_pattern = "*", filepath_pattern = "*")

gnps2_usi_download_link(usi = character())
```

## Arguments

- id:

  for `gnps2_query()`: `character` with the ID(s) of the MassIVE data
  set(s).

- usi_pattern:

  for `gnps2_query()`: `character(1)` defining a pattern to filter the
  *USI*, such as `usi_pattern = ".mzML"` to retrieve the USI of all
  files of the data set (i.e., files with extension `".mzML"`). This
  parameter is passed to the
  [`grepl()`](https://rdrr.io/r/base/grep.html) function.

- filepath_pattern:

  for `gnps2_query()`: `character(1)` defining a pattern to filter the
  `filepath`, such as `filepath_pattern = "metadata"` to retrieve the
  `filepath` of all files of the data set (i.e., files with metadata
  info). This parameter is passed to the
  [`grepl()`](https://rdrr.io/r/base/grep.html) function.

- usi:

  for `gnps2_usi_download_link()`: `character(1)` with the USI of a file
  in GNPS2 DB.

## Value

- For `gnps2_query()`: a `data.frame` with the all information in the
  GNPS2 datasetcache database for the data set IDs provided.

- For `gnps2_usi_download_link()`: a `character(1)` with the downlaod
  link of the USI.

## Details

The `gnps2_query()` function queries the GNPS2 Datasette API at
`https://datasetcache.gnps2.org/datasette/database.csv` by executing a
SQL query on the *filename* table filtered by dataset IDs. It returns
all matching file metadata records. This metadata is used by downstream
functions to determine the FTP paths and to download files. The
`gnps2_usi_download_link()` makes a GET request to the GNPS2 dashboard
to get the download link of a specific USI.

## Note

The Datasette API enforces a maximum limit of 50,000 rows per query.
Longer results will thus be truncated.

## Author

Gabriele Tomè

## Examples

``` r

## Get the GNPS2 table to the data set MSV000080547
gnps2_query("MSV000080547")
#>                                                                     usi
#> 1                        mzspec:MSV000080547:ccms_parameters/params.xml
#> 2   mzspec:MSV000080547:peak/Quant_assesment_QE/AG_spiked_sample1.mzXML
#> 3  mzspec:MSV000080547:peak/Quant_assesment_QE/AG_spiked_sample10.mzXML
#> 4  mzspec:MSV000080547:peak/Quant_assesment_QE/AG_spiked_sample11.mzXML
#> 5  mzspec:MSV000080547:peak/Quant_assesment_QE/AG_spiked_sample12.mzXML
#> 6  mzspec:MSV000080547:peak/Quant_assesment_QE/AG_spiked_sample13.mzXML
#> 7  mzspec:MSV000080547:peak/Quant_assesment_QE/AG_spiked_sample14.mzXML
#> 8  mzspec:MSV000080547:peak/Quant_assesment_QE/AG_spiked_sample15.mzXML
#> 9  mzspec:MSV000080547:peak/Quant_assesment_QE/AG_spiked_sample16.mzXML
#> 10 mzspec:MSV000080547:peak/Quant_assesment_QE/AG_spiked_sample17.mzXML
#> 11 mzspec:MSV000080547:peak/Quant_assesment_QE/AG_spiked_sample18.mzXML
#> 12 mzspec:MSV000080547:peak/Quant_assesment_QE/AG_spiked_sample19.mzXML
#> 13  mzspec:MSV000080547:peak/Quant_assesment_QE/AG_spiked_sample2.mzXML
#> 14 mzspec:MSV000080547:peak/Quant_assesment_QE/AG_spiked_sample20.mzXML
#> 15  mzspec:MSV000080547:peak/Quant_assesment_QE/AG_spiked_sample3.mzXML
#> 16  mzspec:MSV000080547:peak/Quant_assesment_QE/AG_spiked_sample4.mzXML
#> 17  mzspec:MSV000080547:peak/Quant_assesment_QE/AG_spiked_sample5.mzXML
#> 18  mzspec:MSV000080547:peak/Quant_assesment_QE/AG_spiked_sample6.mzXML
#> 19  mzspec:MSV000080547:peak/Quant_assesment_QE/AG_spiked_sample7.mzXML
#> 20  mzspec:MSV000080547:peak/Quant_assesment_QE/AG_spiked_sample8.mzXML
#> 21  mzspec:MSV000080547:peak/Quant_assesment_QE/AG_spiked_sample9.mzXML
#> 22  mzspec:MSV000080547:peak/Quant_assesment_QQQ/AG_spiked_sample1.mzML
#> 23 mzspec:MSV000080547:peak/Quant_assesment_QQQ/AG_spiked_sample10.mzML
#> 24 mzspec:MSV000080547:peak/Quant_assesment_QQQ/AG_spiked_sample11.mzML
#> 25 mzspec:MSV000080547:peak/Quant_assesment_QQQ/AG_spiked_sample12.mzML
#> 26 mzspec:MSV000080547:peak/Quant_assesment_QQQ/AG_spiked_sample13.mzML
#> 27 mzspec:MSV000080547:peak/Quant_assesment_QQQ/AG_spiked_sample14.mzML
#> 28 mzspec:MSV000080547:peak/Quant_assesment_QQQ/AG_spiked_sample15.mzML
#> 29 mzspec:MSV000080547:peak/Quant_assesment_QQQ/AG_spiked_sample16.mzML
#> 30 mzspec:MSV000080547:peak/Quant_assesment_QQQ/AG_spiked_sample17.mzML
#> 31 mzspec:MSV000080547:peak/Quant_assesment_QQQ/AG_spiked_sample18.mzML
#> 32 mzspec:MSV000080547:peak/Quant_assesment_QQQ/AG_spiked_sample19.mzML
#> 33  mzspec:MSV000080547:peak/Quant_assesment_QQQ/AG_spiked_sample2.mzML
#> 34 mzspec:MSV000080547:peak/Quant_assesment_QQQ/AG_spiked_sample20.mzML
#> 35  mzspec:MSV000080547:peak/Quant_assesment_QQQ/AG_spiked_sample3.mzML
#> 36  mzspec:MSV000080547:peak/Quant_assesment_QQQ/AG_spiked_sample4.mzML
#> 37  mzspec:MSV000080547:peak/Quant_assesment_QQQ/AG_spiked_sample5.mzML
#> 38  mzspec:MSV000080547:peak/Quant_assesment_QQQ/AG_spiked_sample6.mzML
#> 39  mzspec:MSV000080547:peak/Quant_assesment_QQQ/AG_spiked_sample7.mzML
#> 40  mzspec:MSV000080547:peak/Quant_assesment_QQQ/AG_spiked_sample8.mzML
#> 41  mzspec:MSV000080547:peak/Quant_assesment_QQQ/AG_spiked_sample9.mzML
#>                                            filepath      dataset
#> 1                        ccms_parameters/params.xml MSV000080547
#> 2   peak/Quant_assesment_QE/AG_spiked_sample1.mzXML MSV000080547
#> 3  peak/Quant_assesment_QE/AG_spiked_sample10.mzXML MSV000080547
#> 4  peak/Quant_assesment_QE/AG_spiked_sample11.mzXML MSV000080547
#> 5  peak/Quant_assesment_QE/AG_spiked_sample12.mzXML MSV000080547
#> 6  peak/Quant_assesment_QE/AG_spiked_sample13.mzXML MSV000080547
#> 7  peak/Quant_assesment_QE/AG_spiked_sample14.mzXML MSV000080547
#> 8  peak/Quant_assesment_QE/AG_spiked_sample15.mzXML MSV000080547
#> 9  peak/Quant_assesment_QE/AG_spiked_sample16.mzXML MSV000080547
#> 10 peak/Quant_assesment_QE/AG_spiked_sample17.mzXML MSV000080547
#> 11 peak/Quant_assesment_QE/AG_spiked_sample18.mzXML MSV000080547
#> 12 peak/Quant_assesment_QE/AG_spiked_sample19.mzXML MSV000080547
#> 13  peak/Quant_assesment_QE/AG_spiked_sample2.mzXML MSV000080547
#> 14 peak/Quant_assesment_QE/AG_spiked_sample20.mzXML MSV000080547
#> 15  peak/Quant_assesment_QE/AG_spiked_sample3.mzXML MSV000080547
#> 16  peak/Quant_assesment_QE/AG_spiked_sample4.mzXML MSV000080547
#> 17  peak/Quant_assesment_QE/AG_spiked_sample5.mzXML MSV000080547
#> 18  peak/Quant_assesment_QE/AG_spiked_sample6.mzXML MSV000080547
#> 19  peak/Quant_assesment_QE/AG_spiked_sample7.mzXML MSV000080547
#> 20  peak/Quant_assesment_QE/AG_spiked_sample8.mzXML MSV000080547
#> 21  peak/Quant_assesment_QE/AG_spiked_sample9.mzXML MSV000080547
#> 22  peak/Quant_assesment_QQQ/AG_spiked_sample1.mzML MSV000080547
#> 23 peak/Quant_assesment_QQQ/AG_spiked_sample10.mzML MSV000080547
#> 24 peak/Quant_assesment_QQQ/AG_spiked_sample11.mzML MSV000080547
#> 25 peak/Quant_assesment_QQQ/AG_spiked_sample12.mzML MSV000080547
#> 26 peak/Quant_assesment_QQQ/AG_spiked_sample13.mzML MSV000080547
#> 27 peak/Quant_assesment_QQQ/AG_spiked_sample14.mzML MSV000080547
#> 28 peak/Quant_assesment_QQQ/AG_spiked_sample15.mzML MSV000080547
#> 29 peak/Quant_assesment_QQQ/AG_spiked_sample16.mzML MSV000080547
#> 30 peak/Quant_assesment_QQQ/AG_spiked_sample17.mzML MSV000080547
#> 31 peak/Quant_assesment_QQQ/AG_spiked_sample18.mzML MSV000080547
#> 32 peak/Quant_assesment_QQQ/AG_spiked_sample19.mzML MSV000080547
#> 33  peak/Quant_assesment_QQQ/AG_spiked_sample2.mzML MSV000080547
#> 34 peak/Quant_assesment_QQQ/AG_spiked_sample20.mzML MSV000080547
#> 35  peak/Quant_assesment_QQQ/AG_spiked_sample3.mzML MSV000080547
#> 36  peak/Quant_assesment_QQQ/AG_spiked_sample4.mzML MSV000080547
#> 37  peak/Quant_assesment_QQQ/AG_spiked_sample5.mzML MSV000080547
#> 38  peak/Quant_assesment_QQQ/AG_spiked_sample6.mzML MSV000080547
#> 39  peak/Quant_assesment_QQQ/AG_spiked_sample7.mzML MSV000080547
#> 40  peak/Quant_assesment_QQQ/AG_spiked_sample8.mzML MSV000080547
#> 41  peak/Quant_assesment_QQQ/AG_spiked_sample9.mzML MSV000080547
#>             collection is_update update_name                create_time
#> 1                              0          NA 2023-12-14 19:58:42.070000
#> 2   Quant_assesment_QE         0          NA 2023-12-14 19:58:44.045000
#> 3   Quant_assesment_QE         0          NA 2023-12-14 19:58:46.297000
#> 4   Quant_assesment_QE         0          NA 2023-12-14 19:58:47.947000
#> 5   Quant_assesment_QE         0          NA 2023-12-14 19:58:49.627000
#> 6   Quant_assesment_QE         0          NA 2023-12-14 19:58:51.647000
#> 7   Quant_assesment_QE         0          NA 2023-12-14 19:58:53.567000
#> 8   Quant_assesment_QE         0          NA 2023-12-14 19:58:55.129000
#> 9   Quant_assesment_QE         0          NA 2023-12-14 19:58:57.441000
#> 10  Quant_assesment_QE         0          NA 2023-12-14 19:58:59.260000
#> 11  Quant_assesment_QE         0          NA 2023-12-14 19:59:00.921000
#> 12  Quant_assesment_QE         0          NA 2023-12-14 19:59:03.107000
#> 13  Quant_assesment_QE         0          NA 2023-12-14 19:59:04.590000
#> 14  Quant_assesment_QE         0          NA 2023-12-14 19:59:06.340000
#> 15  Quant_assesment_QE         0          NA 2023-12-14 19:59:08.534000
#> 16  Quant_assesment_QE         0          NA 2023-12-14 19:59:10.439000
#> 17  Quant_assesment_QE         0          NA 2023-12-14 19:59:12.271000
#> 18  Quant_assesment_QE         0          NA 2023-12-14 19:59:14.019000
#> 19  Quant_assesment_QE         0          NA 2023-12-14 19:59:15.700000
#> 20  Quant_assesment_QE         0          NA 2023-12-14 19:59:17.352000
#> 21  Quant_assesment_QE         0          NA 2023-12-14 19:59:19.533000
#> 22 Quant_assesment_QQQ         0          NA 2023-12-14 19:59:19.667000
#> 23 Quant_assesment_QQQ         0          NA 2023-12-14 19:59:19.879000
#> 24 Quant_assesment_QQQ         0          NA 2023-12-14 19:59:20.014000
#> 25 Quant_assesment_QQQ         0          NA 2023-12-14 19:59:20.108000
#> 26 Quant_assesment_QQQ         0          NA 2023-12-14 19:59:20.257000
#> 27 Quant_assesment_QQQ         0          NA 2023-12-14 19:59:20.396000
#> 28 Quant_assesment_QQQ         0          NA 2023-12-14 19:59:20.512000
#> 29 Quant_assesment_QQQ         0          NA 2023-12-14 19:59:20.594000
#> 30 Quant_assesment_QQQ         0          NA 2023-12-14 19:59:20.667000
#> 31 Quant_assesment_QQQ         0          NA 2023-12-14 19:59:20.758000
#> 32 Quant_assesment_QQQ         0          NA 2023-12-14 19:59:20.844000
#> 33 Quant_assesment_QQQ         0          NA 2023-12-14 19:59:20.919000
#> 34 Quant_assesment_QQQ         0          NA 2023-12-14 19:59:21.016000
#> 35 Quant_assesment_QQQ         0          NA 2023-12-14 19:59:21.099000
#> 36 Quant_assesment_QQQ         0          NA 2023-12-14 19:59:21.196000
#> 37 Quant_assesment_QQQ         0          NA 2023-12-14 19:59:21.302000
#> 38 Quant_assesment_QQQ         0          NA 2023-12-14 19:59:21.395000
#> 39 Quant_assesment_QQQ         0          NA 2023-12-14 19:59:21.460000
#> 40 Quant_assesment_QQQ         0          NA 2023-12-14 19:59:21.600000
#> 41 Quant_assesment_QQQ         0          NA 2023-12-14 19:59:21.668000
#>         size size_mb sample_type spectra_ms1 spectra_ms2 instrument_vendor
#> 1       5801       0     MASSIVE           0           0                NA
#> 2   77825878      74     MASSIVE           0           0                NA
#> 3   83053496      79     MASSIVE           0           0                NA
#> 4   71125835      67     MASSIVE           0           0                NA
#> 5   74646509      71     MASSIVE           0           0                NA
#> 6   81068518      77     MASSIVE           0           0                NA
#> 7   73759240      70     MASSIVE           0           0                NA
#> 8   66366696      63     MASSIVE           0           0                NA
#> 9   85580871      81     MASSIVE           0           0                NA
#> 10  76035689      72     MASSIVE           0           0                NA
#> 11  74473877      71     MASSIVE           0           0                NA
#> 12  88730540      84     MASSIVE           0           0                NA
#> 13  67938213      64     MASSIVE           0           0                NA
#> 14  76273532      72     MASSIVE           0           0                NA
#> 15 100373730      95     MASSIVE           0           0                NA
#> 16  80690230      76     MASSIVE           0           0                NA
#> 17  83600234      79     MASSIVE           0           0                NA
#> 18  76815466      73     MASSIVE           0           0                NA
#> 19  70473590      67     MASSIVE           0           0                NA
#> 20  71789865      68     MASSIVE           0           0                NA
#> 21  91403666      87     MASSIVE           0           0                NA
#> 22   3371947       3     MASSIVE           0           0                NA
#> 23   3371964       3     MASSIVE           0           0                NA
#> 24   3371949       3     MASSIVE           0           0                NA
#> 25   3371959       3     MASSIVE           0           0                NA
#> 26   3371938       3     MASSIVE           0           0                NA
#> 27   3371919       3     MASSIVE           0           0                NA
#> 28   3371888       3     MASSIVE           0           0                NA
#> 29   3371972       3     MASSIVE           0           0                NA
#> 30   3370398       3     MASSIVE           0           0                NA
#> 31   3371940       3     MASSIVE           0           0                NA
#> 32   3371928       3     MASSIVE           0           0                NA
#> 33   3371910       3     MASSIVE           0           0                NA
#> 34   3370336       3     MASSIVE           0           0                NA
#> 35   3371942       3     MASSIVE           0           0                NA
#> 36   3370377       3     MASSIVE           0           0                NA
#> 37   3371943       3     MASSIVE           0           0                NA
#> 38   3371988       3     MASSIVE           0           0                NA
#> 39   3370409       3     MASSIVE           0           0                NA
#> 40   3370378       3     MASSIVE           0           0                NA
#> 41   3371940       3     MASSIVE           0           0                NA
#>    instrument_model file_processed
#> 1                NA             No
#> 2                NA             No
#> 3                NA             No
#> 4                NA             No
#> 5                NA             No
#> 6                NA             No
#> 7                NA             No
#> 8                NA             No
#> 9                NA             No
#> 10               NA             No
#> 11               NA             No
#> 12               NA             No
#> 13               NA             No
#> 14               NA             No
#> 15               NA             No
#> 16               NA             No
#> 17               NA             No
#> 18               NA             No
#> 19               NA             No
#> 20               NA             No
#> 21               NA             No
#> 22               NA             No
#> 23               NA             No
#> 24               NA             No
#> 25               NA             No
#> 26               NA             No
#> 27               NA             No
#> 28               NA             No
#> 29               NA             No
#> 30               NA             No
#> 31               NA             No
#> 32               NA             No
#> 33               NA             No
#> 34               NA             No
#> 35               NA             No
#> 36               NA             No
#> 37               NA             No
#> 38               NA             No
#> 39               NA             No
#> 40               NA             No
#> 41               NA             No

## Get link for an USI
gnps2_usi_download_link("mzspec:MTBLS39:FILES/AM063A.cdf")
#> [1] "https://www.ebi.ac.uk:443/metabolights/ws/studies/MTBLS39/download?file=FILES/AM063A.cdf"
```
