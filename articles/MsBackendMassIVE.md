# Retrieve and Use Mass Spectrometry Data from MassIVE

**Package**:
*[MsBackendMassIVE](https://bioconductor.org/packages/3.23/MsBackendMassIVE)*\
**Authors**: Gabriele Tomè \[aut, cre\] (ORCID:
<https://orcid.org/0000-0002-3976-6068>), Philippine Louail \[aut\]
(ORCID: <https://orcid.org/0009-0007-5429-6846>), Johannes Rainer
\[aut\] (ORCID: <https://orcid.org/0000-0002-6977-7147>)\
**Last modified:** 2026-03-18 07:45:10.043802\
**Compiled**: Wed Mar 18 08:23:59 2026

## Introduction

The *[Spectra](https://bioconductor.org/packages/3.23/Spectra)* package
provides a central infrastructure for the handling of Mass Spectrometry
(MS) data in Bioconductor. The package supports interchangeable use of
different *backends* to import and represent MS data from a variety of
sources and data formats. The *MsBackendMassIVE* package allows to
retrieve MS data files directly from the
[MassIVE](https://massive.ucsd.edu/ProteoSAFe/static/massive.jsp) (Mass
Spectrometry Interactive Virtual Environment) repository. MassIVE is a
community resource developed by the NIH-funded Center for Computational
Mass Spectrometry at UC San Diego to promote the global, free exchange
of mass spectrometry data. MassIVE supports deposition of both
proteomics and metabolomics experiments and is a full member of the
[ProteomeXchange](http://www.proteomexchange.org/) consortium.

The *MsBackendMassIVE* package downloads and locally caches MS data
files for a MassIVE data set and enables further analyses of this data
directly in R.

## Installation

The package can be installed from within R with the commands below:

``` r

if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("RforMassSpectrometry/MsBackendMassIVE")
```

## Importing MS Data from MassIVE

Each experiment in MassIVE is identified by a unique accession starting
with *MSV* followed by a number. The MS data files of a dataset are
listed in the [GNPS2
database](https://datasetcache.gnps2.org/datasette/database/filename)
and can be downloaded from MassIVE’s FTP server.

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
and therefore supports import of MS data files in *mzML*, *CDF* or
*mzXML* formats). By default, all MS data files of the data set would be
retrieved, but in our example below we restrict to a few data files to
reduce the amount of data that needs to be downloaded. To this end we
define a pattern matching the file name of only some data files using
the `filePattern` parameter.

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

This call downloaded the files to the local cache and loaded them as a
`Spectra` object. The downloading and caching of the data is handled by
Bioconductor’s
*[BiocFileCache](https://bioconductor.org/packages/3.23/BiocFileCache)*.
The local cache can thus be managed directly using functionality from
that package. Any subsequent loading of the same data files will load
the locally cached versions avoiding thus repetitive download of the
same data.

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
on the MassIVE FTP server for each individual spectrum.

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

The
[`massive_sync()`](https://rformassspectrometry.github.io/MsBackendMassIVE/reference/MsBackendMassIVE.md)
function can be used to *synchronize* the local content of a
`MsBackendMassIVE`. This function checks if all data files of the
backend are available locally and eventually downloads and caches
missing files.

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

Also, it is possible to *manually* cache and download data files from
MassIVE using the
[`massive_sync_data_files()`](https://rformassspectrometry.github.io/MsBackendMassIVE/reference/MassIVE-utils.md)
function. This function evaluates if the respective data files are
already cached and, if so, does not download them again. Below we use
this to retrieve the local storage information on one of the data files
of the MassIVE data set *MSV000080547*:

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
function can be used to inspect and list locally cached MassIVE data
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

## Session information

``` r

sessionInfo()
```

    ## R Under development (unstable) (2026-03-15 r89629)
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
    ## [1] MsBackendMassIVE_0.1.2 Spectra_1.21.5         BiocParallel_1.45.0   
    ## [4] S4Vectors_0.49.0       BiocGenerics_0.57.0    generics_0.1.4        
    ## [7] BiocStyle_2.39.0      
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] xfun_0.56              bslib_0.10.0           httr2_1.2.2           
    ##  [4] htmlwidgets_1.6.4      Biobase_2.71.0         vctrs_0.7.1           
    ##  [7] tools_4.6.0            curl_7.0.0             parallel_4.6.0        
    ## [10] tibble_3.3.1           RSQLite_2.4.6          cluster_2.1.8.2       
    ## [13] blob_1.3.0             pkgconfig_2.0.3        data.table_1.18.2.1   
    ## [16] dbplyr_2.5.2           desc_1.4.3             lifecycle_1.0.5       
    ## [19] stringr_1.6.0          compiler_4.6.0         textshaping_1.0.5     
    ## [22] progress_1.2.3         codetools_0.2-20       ncdf4_1.24            
    ## [25] clue_0.3-67            htmltools_0.5.9        sass_0.4.10           
    ## [28] yaml_2.3.12            pkgdown_2.2.0.9000     pillar_1.11.1         
    ## [31] crayon_1.5.3           jquerylib_0.1.4        MASS_7.3-65           
    ## [34] cachem_1.1.0           MetaboCoreUtils_1.19.2 rvest_1.0.5           
    ## [37] tidyselect_1.2.1       digest_0.6.39          stringi_1.8.7         
    ## [40] purrr_1.2.1            dplyr_1.2.0            bookdown_0.46         
    ## [43] fastmap_1.2.0          cli_3.6.5              magrittr_2.0.4        
    ## [46] withr_3.0.2            prettyunits_1.2.0      filelock_1.0.3        
    ## [49] rappdirs_0.3.4         bit64_4.6.0-1          rmarkdown_2.30        
    ## [52] httr_1.4.8             bit_4.6.0              otel_0.2.0            
    ## [55] ragg_1.5.1             hms_1.1.4              memoise_2.0.1         
    ## [58] evaluate_1.0.5         knitr_1.51             IRanges_2.45.0        
    ## [61] BiocFileCache_3.1.0    rlang_1.1.7            Rcpp_1.1.1            
    ## [64] glue_1.8.0             DBI_1.3.0              mzR_2.45.0            
    ## [67] selectr_0.5-1          xml2_1.5.2             BiocManager_1.30.27   
    ## [70] jsonlite_2.0.0         R6_2.6.1               systemfonts_1.3.2     
    ## [73] fs_1.6.7               ProtGenerics_1.43.0    MsCoreUtils_1.23.6
