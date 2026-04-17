# Retrieve and Use Mass Spectrometry Data from MassIVE

**Package**:
*[MsBackendMassIVE](https://bioconductor.org/packages/3.23/MsBackendMassIVE)*\
**Authors**: Gabriele Tomè \[aut, cre\] (ORCID:
<https://orcid.org/0000-0002-3976-6068>, fnd: MetaRbolomics4Galaxy
project (CUP: D53C25001030003) co-funded by the Autonomous Province of
Bolzano under the Joint Projects South Tyrol–Germany 2025 program.),
Philippine Louail \[aut\] (ORCID:
<https://orcid.org/0009-0007-5429-6846>), Johannes Rainer \[aut\]
(ORCID: <https://orcid.org/0000-0002-6977-7147>)\
**Last modified:** 2026-04-17 06:58:57.90974\
**Compiled**: Fri Apr 17 07:53:01 2026

## Introduction

Metabolomics experiments and results including mass spectrometry (MS)
data can be deposited in several public repositories, such as
[MassIVE](https://massive.ucsd.edu/ProteoSAFe/static/massive.jsp) (Mass
Spectrometry Interactive Virtual Environment). MassIVE is a community
resource developed by the NIH-funded Center for Computational Mass
Spectrometry at UC San Diego to promote the global, free exchange of
mass spectrometry data. MassIVE supports deposition of both proteomics
and metabolomics experiments and is a full member of the
[ProteomeXchange](http://www.proteomexchange.org/) consortium. While
data is available, manual lookup and download is cumbersome hampering
the re-analysis of public data and replication of results. The
*MsBackendMassIVE* package closes this gap by providing functionality to
query, retrieve and cache MS data from MassIVE directly from R hence
enabling a direct and seamless integration of MS data from MassIVE into
R-based analysis workflows. *MsBackendMassIVE* leverages on
Bioconductor’s `r Biocpkg("BiocFileCache")` for caching remote data
locally and provides a *MS data backend* for the
*[Spectra](https://bioconductor.org/packages/3.23/Spectra)* package to
enable loading and integrating cached MS data directly into R.

## Installation

The package can be installed from within R with the commands below:

``` r

if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("RforMassSpectrometry/MsBackendMassIVE")
```

## Importing MS Data from MassIVE

Each experiment in MassIVE is identified by a unique accession starting
with *MSV* followed by a number. While the [MassIVE web
page](https://massive.ucsd.edu/ProteoSAFe/) allows only a manual, non
programmatic, lookup of data and experiments, a separate, central
registry of data files and experiments is hosted on GNPS2. This
[datasetcache](https://datasetcache.gnps2.org/datasette/database/filename)
registry allows programmatic access and is used by *MsBackendMassIVE* to
query information on MassIVE experiments.

Below we list all files from the MassIVE data set with the ID
*MSV000080547*.

``` r

library(MsBackendMassIVE)
```

    ## Registered S3 method overwritten by 'bit64':
    ##   method          from 
    ##   print.bitstring tools

``` r

#' List files of a MassIVE data set
all_files <- massive_list_files("MSV000080547")
head(all_files)
```

    ## [1] "ccms_parameters/params.xml"                      
    ## [2] "peak/Quant_assesment_QE/AG_spiked_sample1.mzXML" 
    ## [3] "peak/Quant_assesment_QE/AG_spiked_sample10.mzXML"
    ## [4] "peak/Quant_assesment_QE/AG_spiked_sample11.mzXML"
    ## [5] "peak/Quant_assesment_QE/AG_spiked_sample12.mzXML"
    ## [6] "peak/Quant_assesment_QE/AG_spiked_sample13.mzXML"

These files are accessible through the FTP path associated with the
MassIVE data set. Below we use the
[`massive_ftp_path()`](https://rformassspectrometry.github.io/MsBackendMassIVE/reference/MassIVE-utils.md)
function to return the FTP path for our test data set.

``` r

massive_ftp_path("MSV000080547", mustWork = FALSE)
```

    ## [1] "ftp://massive-ftp.ucsd.edu/v01/MSV000080547/"

MS data files in supported formats (mzML, CDF, mzXML) can be directly
loaded using the `MsBackendMassIVE` backend into R as a `Spectra` object
(`MsBackendMassIVE` directly extends *Spectra*’s `MsBackendMzR` backend
and therefore supports import of MS data files in these formats). By
default, all MS data files of the data set would be retrieved, but in
our example below we restrict to a few data files to reduce the amount
of data that needs to be downloaded. To this end we define a pattern
matching the file name of only some data files using the `filePattern`
parameter.

``` r

library(Spectra)

#' Load MS data files of one data set
s <- Spectra("MSV000080547", filePattern = "1.mzML$",
             source = MsBackendMassIVE())
s
```

    ## MSn data (Spectra) with 4322 spectra in a MsBackendMassIVE backend:
    ##        msLevel     rtime scanIndex
    ##      <integer> <numeric> <integer>
    ## 1            1     0.497         1
    ## 2            1     0.829         2
    ## 3            1     1.159         3
    ## 4            1     1.488         4
    ## 5            1     1.818         5
    ## ...        ...       ...       ...
    ## 4318         1   718.439      2157
    ## 4319         1   718.769      2158
    ## 4320         1   719.099      2159
    ## 4321         1   719.429      2160
    ## 4322         1   719.759      2161
    ##  ... 36 more variables/columns.
    ## 
    ## file(s):
    ## AG_spiked_sample1.mzML
    ## AG_spiked_sample11.mzML

This call downloaded 2 files from the experiment into the local cache
and loaded them as a `Spectra` object. The downloading and caching of
the data is handled by Bioconductor’s
*[BiocFileCache](https://bioconductor.org/packages/3.23/BiocFileCache)*.
The local cache can thus also be managed directly using functionality
from that package. Any subsequent loading of the same data files will
load the locally cached versions avoiding thus repetitive download of
the same data.

The `Spectra` object with the MS data files of the MassIVE data set
enables now any subsequent analysis of the data in R. On top of the
spectra variables and mass peak data values that are provided by the MS
data files also additional information related to the MassIVE data set
are available as specific *spectra variables*. We list all available
spectra variables of the data set below.

``` r

spectraVariables(s)
```

    ##  [1] "msLevel"                  "rtime"                   
    ##  [3] "acquisitionNum"           "scanIndex"               
    ##  [5] "dataStorage"              "dataOrigin"              
    ##  [7] "centroided"               "smoothed"                
    ##  [9] "polarity"                 "precScanNum"             
    ## [11] "precursorMz"              "precursorIntensity"      
    ## [13] "precursorCharge"          "collisionEnergy"         
    ## [15] "isolationWindowLowerMz"   "isolationWindowTargetMz" 
    ## [17] "isolationWindowUpperMz"   "peaksCount"              
    ## [19] "totIonCurrent"            "basePeakMZ"              
    ## [21] "basePeakIntensity"        "electronBeamEnergy"      
    ## [23] "ionisationEnergy"         "lowMZ"                   
    ## [25] "highMZ"                   "mergedScan"              
    ## [27] "mergedResultScanNum"      "mergedResultStartScanNum"
    ## [29] "mergedResultEndScanNum"   "injectionTime"           
    ## [31] "filterString"             "spectrumId"              
    ## [33] "ionMobilityDriftTime"     "scanWindowLowerLimit"    
    ## [35] "scanWindowUpperLimit"     "massive_id"              
    ## [37] "data_file"

The MassIVE-specific variables are `"massive_id"` and `"data_file"`
providing the MassIVE ID of the data set and the original data file name
in the MassIVE FTP server for each individual spectrum.

``` r

spectraData(s, c("massive_id", "data_file"))
```

    ## DataFrame with 4322 rows and 2 columns
    ##        massive_id              data_file
    ##       <character>            <character>
    ## 1    MSV000080547 peak/Quant_assesment..
    ## 2    MSV000080547 peak/Quant_assesment..
    ## 3    MSV000080547 peak/Quant_assesment..
    ## 4    MSV000080547 peak/Quant_assesment..
    ## 5    MSV000080547 peak/Quant_assesment..
    ## ...           ...                    ...
    ## 4318 MSV000080547 peak/Quant_assesment..
    ## 4319 MSV000080547 peak/Quant_assesment..
    ## 4320 MSV000080547 peak/Quant_assesment..
    ## 4321 MSV000080547 peak/Quant_assesment..
    ## 4322 MSV000080547 peak/Quant_assesment..

``` r

basename(s$data_file) |> head()
```

    ## [1] "AG_spiked_sample1.mzML" "AG_spiked_sample1.mzML" "AG_spiked_sample1.mzML"
    ## [4] "AG_spiked_sample1.mzML" "AG_spiked_sample1.mzML" "AG_spiked_sample1.mzML"

The
[`massive_sync()`](https://rformassspectrometry.github.io/MsBackendMassIVE/reference/MsBackendMassIVE.md)
function can be used to *synchronize* the local content of a
`MsBackendMassIVE` and is useful if, for example, locally cached files
were deleted. The function checks if all data files of the backend are
available locally and eventually downloads and caches missing files.

``` r

massive_sync(s@backend)
```

    ## MsBackendMassIVE with 4322 spectra
    ##        msLevel     rtime scanIndex
    ##      <integer> <numeric> <integer>
    ## 1            1     0.497         1
    ## 2            1     0.829         2
    ## 3            1     1.159         3
    ## 4            1     1.488         4
    ## 5            1     1.818         5
    ## ...        ...       ...       ...
    ## 4318         1   718.439      2157
    ## 4319         1   718.769      2158
    ## 4320         1   719.099      2159
    ## 4321         1   719.429      2160
    ## 4322         1   719.759      2161
    ##  ... 36 more variables/columns.
    ## 
    ## file(s):
    ## AG_spiked_sample1.mzML
    ## AG_spiked_sample11.mzML

In addition, it is also possible to *manually* cache and download
selected files from MassIVE using the
[`massive_sync_data_files()`](https://rformassspectrometry.github.io/MsBackendMassIVE/reference/MassIVE-utils.md)
function. Before downloading, this function first evaluates if the
respective data files are already cached and only downloads them if
needed. As a result, the function returns a `data.frame` with the
storage location and other information of the cached file(s). Below we
use this function to retrieve the local storage information on one of
the data files of the MassIVE data set *MSV000080547*:

``` r

res <- massive_sync_data_files("MSV000080547",
                               fileName = "AG_spiked_sample11.mzML")
res
```

    ##     rid   massive_id                                        data_file
    ## 1 BFC12 MSV000080547 peak/Quant_assesment_QQQ/AG_spiked_sample11.mzML
    ##                                                         rpath
    ## 1 /github/home/.cache/R/BiocFileCache/AG_spiked_sample11.mzML

The
[`massive_cached_data_files()`](https://rformassspectrometry.github.io/MsBackendMassIVE/reference/MassIVE-utils.md)
function can be used to inspect and list all locally cached MassIVE data
files. This function does not require an active internet connection
since only local content is queried. With the default settings, a
`data.frame` with all available data files is returned.

``` r

massive_cached_data_files()
```

    ##     rid   massive_id                                        data_file
    ## 3 BFC12 MSV000080547 peak/Quant_assesment_QQQ/AG_spiked_sample11.mzML
    ##                                                         rpath
    ## 3 /github/home/.cache/R/BiocFileCache/AG_spiked_sample11.mzML

Locally cached files for a MassIVE data set can be removed using the
[`massive_delete_cache()`](https://rformassspectrometry.github.io/MsBackendMassIVE/reference/MassIVE-utils.md)
function providing the ID of the MassIVE data set for which local data
files should be removed.

## General use and information retrieval from MassIVE

Next to the `MsBackendMassIVE` backend for `Spectra` objects, the
*MsBackendMassIVE* package provides also various utility functions to
query and retrieve information from MassIVE or GNPS2’s *datasetcache*.

The
[`massive_param_file()`](https://rformassspectrometry.github.io/MsBackendMassIVE/reference/MassIVE-utils.md)
function reads the parameter file from a MassIVE data set that provides
general, experiment-specific information. These are retrieved as a
two-column `data.frame` with the first column containing the names of
the data set properties, and the second their values.

``` r

prm <- massive_param_file("MSV000080547")
head(prm)
```

    ##          ParameterName
    ## 1     dataset.comments
    ## 2   dataset.instrument
    ## 3     dataset.keywords
    ## 4 dataset.modification
    ## 5     dataset.password
    ## 6           dataset.pi
    ##                                                                     Value
    ## 1 Quantity assessment experiment for one sample two metabolomics workflow
    ## 2                                                   MS:1001911;MS:1000644
    ## 3                                            Standards;quantity assesment
    ## 4                                                           PRIDE:0000398
    ## 5                                                                       a
    ## 6                                                         P Dorrestein|||

The
[`massive_download_file()`](https://rformassspectrometry.github.io/MsBackendMassIVE/reference/MassIVE-utils.md)
function allows to download any file of an experiment (directly, i.e.,
without caching). As an example we download below a docx file to a
temporary folder.

``` r

massive_list_files("MSV000083058") |> head()
```

    ## [1] "ccms_parameters/params.xml"            
    ## [2] "ccms_statistics/statistics.tsv"        
    ## [3] "methods/README_Histones_P108_VS3.docx" 
    ## [4] "other/Table 1 SAINT3788_TripleTOF.xlsx"
    ## [5] "other/Table 2 SAINT3788_TripleTOF.xlsx"
    ## [6] "other/Table 3 SAINT3788_TripleTOF.xlsx"

``` r

massive_download_file("MSV000083058",
                      fileName = "README_Histones_P108_VS3.docx",
                      path = tempdir())
```

*MsBackendMassIVE* provides also two utility functions to query the
GNPS2 *datasetcache*,
[`gnps2_query()`](https://rformassspectrometry.github.io/MsBackendMassIVE/reference/GNPS2-utils.md)
and
[`gnps2_usi_download_link()`](https://rformassspectrometry.github.io/MsBackendMassIVE/reference/GNPS2-utils.md).

Below we use
[`gnps2_query()`](https://rformassspectrometry.github.io/MsBackendMassIVE/reference/GNPS2-utils.md)
to retrieve all information for a MassIVE data set from the
datasetcache.

``` r

res <- gnps2_query("MSV000083058")
head(res)
```

    ##                                                          usi
    ## 1             mzspec:MSV000083058:ccms_parameters/params.xml
    ## 2         mzspec:MSV000083058:ccms_statistics/statistics.tsv
    ## 3  mzspec:MSV000083058:methods/README_Histones_P108_VS3.docx
    ## 4 mzspec:MSV000083058:other/Table 1 SAINT3788_TripleTOF.xlsx
    ## 5 mzspec:MSV000083058:other/Table 2 SAINT3788_TripleTOF.xlsx
    ## 6 mzspec:MSV000083058:other/Table 3 SAINT3788_TripleTOF.xlsx
    ##                                 filepath      dataset collection is_update
    ## 1             ccms_parameters/params.xml MSV000083058                    0
    ## 2         ccms_statistics/statistics.tsv MSV000083058                    0
    ## 3  methods/README_Histones_P108_VS3.docx MSV000083058                    0
    ## 4 other/Table 1 SAINT3788_TripleTOF.xlsx MSV000083058                    0
    ## 5 other/Table 2 SAINT3788_TripleTOF.xlsx MSV000083058                    0
    ## 6 other/Table 3 SAINT3788_TripleTOF.xlsx MSV000083058                    0
    ##   update_name                create_time   size size_mb sample_type spectra_ms1
    ## 1          NA 2024-04-11 02:34:07.431000   8619       0     MASSIVE           0
    ## 2          NA 2024-01-23 14:53:43.404000      0       0     MASSIVE           0
    ## 3          NA 2024-03-28 13:07:48.624000  31495       0     MASSIVE           0
    ## 4          NA 2024-04-23 08:04:41.282000  10783       0     MASSIVE           0
    ## 5          NA 2024-04-02 13:03:41.877000 931530       0     MASSIVE           0
    ## 6          NA 2024-03-28 13:07:48.754000 152547       0     MASSIVE           0
    ##   spectra_ms2 instrument_vendor instrument_model file_processed
    ## 1           0                NA               NA             No
    ## 2           0                NA               NA             No
    ## 3           0                NA               NA             No
    ## 4           0                NA               NA             No
    ## 5           0                NA               NA             No
    ## 6           0                NA               NA             No

The
[`gnps2_usi_download_link()`](https://rformassspectrometry.github.io/MsBackendMassIVE/reference/GNPS2-utils.md)
returns a fully qualified link to a data file (listed in the GNPS2
datasetcache), based on it’s USI.

``` r

gnps2_usi_download_link(res$usi[4])
```

    ## [1] "https://massiveproxy.gnps2.org/massiveproxy/MSV000083058/other/Table%201%20SAINT3788_TripleTOF.xlsx"

## Session information

``` r

sessionInfo()
```

    ## R Under development (unstable) (2026-04-12 r89873)
    ## Platform: x86_64-pc-linux-gnu
    ## Running under: Ubuntu 24.04.4 LTS
    ## 
    ## Matrix products: default
    ## BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
    ## LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
    ## 
    ## locale:
    ##  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
    ##  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
    ##  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
    ##  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
    ##  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
    ## [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
    ## 
    ## time zone: UTC
    ## tzcode source: system (glibc)
    ## 
    ## attached base packages:
    ## [1] stats4    stats     graphics  grDevices utils     datasets  methods  
    ## [8] base     
    ## 
    ## other attached packages:
    ## [1] MsBackendMassIVE_0.99.0 Spectra_1.21.7          BiocParallel_1.45.0    
    ## [4] S4Vectors_0.49.1-1      BiocGenerics_0.57.0     generics_0.1.4         
    ## [7] BiocStyle_2.39.0       
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] xfun_0.57              bslib_0.10.0           httr2_1.2.2           
    ##  [4] htmlwidgets_1.6.4      Biobase_2.71.0         vctrs_0.7.3           
    ##  [7] tools_4.7.0            curl_7.0.0             parallel_4.7.0        
    ## [10] tibble_3.3.1           RSQLite_2.4.6          cluster_2.1.8.2       
    ## [13] blob_1.3.0             pkgconfig_2.0.3        data.table_1.18.2.1   
    ## [16] dbplyr_2.5.2           desc_1.4.3             lifecycle_1.0.5       
    ## [19] stringr_1.6.0          compiler_4.7.0         textshaping_1.0.5     
    ## [22] progress_1.2.3         codetools_0.2-20       ncdf4_1.24            
    ## [25] clue_0.3-68            htmltools_0.5.9        sass_0.4.10           
    ## [28] yaml_2.3.12            pkgdown_2.2.0.9000     pillar_1.11.1         
    ## [31] crayon_1.5.3           jquerylib_0.1.4        MASS_7.3-65           
    ## [34] cachem_1.1.0           MetaboCoreUtils_1.19.2 rvest_1.0.5           
    ## [37] tidyselect_1.2.1       digest_0.6.39          stringi_1.8.7         
    ## [40] purrr_1.2.2            dplyr_1.2.1            bookdown_0.46         
    ## [43] fastmap_1.2.0          cli_3.6.6              magrittr_2.0.5        
    ## [46] withr_3.0.2            prettyunits_1.2.0      filelock_1.0.3        
    ## [49] rappdirs_0.3.4         bit64_4.6.0-1          rmarkdown_2.31        
    ## [52] httr_1.4.8             bit_4.6.0              otel_0.2.0            
    ## [55] ragg_1.5.2             hms_1.1.4              memoise_2.0.1         
    ## [58] evaluate_1.0.5         knitr_1.51             IRanges_2.45.0        
    ## [61] BiocFileCache_3.1.0    rlang_1.2.0            Rcpp_1.1.1-1          
    ## [64] glue_1.8.1             DBI_1.3.0              mzR_2.45.1            
    ## [67] selectr_0.5-1          xml2_1.5.2             BiocManager_1.30.27   
    ## [70] jsonlite_2.0.0         R6_2.6.1               systemfonts_1.3.2     
    ## [73] fs_2.0.1               ProtGenerics_1.43.0    MsCoreUtils_1.23.9
