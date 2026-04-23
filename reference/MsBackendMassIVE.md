# MsBackend representing MS data from MassIVE

`MsBackendMassIVE` retrieves and represents mass spectrometry (MS) data
from proteomics and metabolomics experiments stored in the
[MassIVE](https://massive.ucsd.edu/ProteoSAFe/static/massive.jsp) (Mass
Spectrometry Interactive Virtual Environment) repository, a community
resource developed by the NIH-funded Center for Computational Mass
Spectrometry at UC San Diego. The backend directly extends the
[Spectra::MsBackendMzR](https://rdrr.io/pkg/Spectra/man/MsBackend.html)
backend from the *Spectra* package and hence supports MS data in mzML,
netCDF and mzXML format. Data in other formats can not be loaded with
`MsBackendMassIVE`. Upon initialization with the `backendInitialize()`
method, the `MsBackendMassIVE` backend downloads and caches the MS data
files of a dataset locally, avoiding repeated download of the data. The
local data cache is managed by Bioconductor's *BiocFileCache* package.
See the help and vignettes from that package for details on cached data
resources. Additional utility functions for management of cached files
are also provided by *MsBackendMassIVE*. See help for
[`massive_cached_data_files()`](https://rformassspectrometry.github.io/MsBackendMassIVE/reference/MassIVE-utils.md)
for more information.

## Usage

``` r
MsBackendMassIVE()

# S4 method for class 'MsBackendMassIVE'
backendInitialize(
  object,
  massiveId = character(),
  filePattern = "mzML$|CDF$|cdf$|mzXML$",
  offline = FALSE,
  ...
)

# S4 method for class 'MsBackendMassIVE'
backendRequiredSpectraVariables(object, ...)

massive_sync(x, offline = FALSE)
```

## Arguments

- object:

  an instance of `MsBackendMassIVE`.

- massiveId:

  `character(1)` with the ID of a single MassIVE data set/experiment.

- filePattern:

  `character` with the pattern defining the supported (or requested)
  file types. Defaults to `filePattern = "mzML$|CDF$|cdf$|mzXML$"` hence
  restricting to mzML, CDF and mzXML files which are supported by
  *Spectra*'s `MsBackendMzR` backend.

- offline:

  `logical(1)` whether only locally cached content should be
  evaluated/loaded.

- ...:

  additional parameters; currently ignored.

- x:

  an instance of `MsBackendMassIVE`.

## Value

- For `MsBackendMassIVE()`: an instance of `MsBackendMassIVE`.

- For
  [`backendInitialize()`](https://rdrr.io/pkg/ProtGenerics/man/backendInitialize.html):
  an instance of `MsBackendMassIVE` with the MS data of the specified
  MassIVE data set.

- For
  [`backendRequiredSpectraVariables()`](https://rdrr.io/pkg/Spectra/man/MsBackend.html):
  `character` with spectra variables that are needed for the backend to
  provide the MS data.

- For `massive_sync()`: the input `MsBackendMassIVE` with the paths to
  the locally cached data files being eventually updated.

## Details

File names for data files are by default extracted from the column
`"filepath"` of the [GNPS2
database](https://datasetcache.gnps2.org/datasette/database/filename).

The backend uses the
[BiocFileCache](https://bioconductor.org/packages/BiocFileCache) package
for caching of the data files. These are stored in the default local
*BiocFileCache* cache along with additional metadata that includes the
MassIVE ID. Note that at present only MS data files in *mzML*, *CDF* and
*mzXML* format are supported.

The `MsBackendMassIVE` backend defines and provides additional spectra
variables `"massive_id"` and `"data_file"` that list the MassIVE ID, and
the original data file name on the MassIVE ftp server for each
individual spectrum. The `"data_file"` can be used for the mapping
between the experiment's samples and the individual data files,
respective their spectra.

The `MsBackendMassIVE` backend is considered *read-only* and does thus
not support changing *m/z* and intensity values directly.

## Note

To account for high server load and eventually failing or rejected
downloads from the MassIVE FTP server (`ftp://massive-ftp.ucsd.edu/`),
the download functions repeatedly retry to download a file. An error is
thrown if the download fails for 5 consecutive attempts. Between each
attempt, the function waits for an increasing time period (5 seconds
between the first and second and 10 seconds between the 2nd and 3rd
attempt). This time period can also be configured with the
`"massive.sleep_mult"` option, which defines the *sleep time
multiplicator* (defaults to 5).

## Initialization and loading of data

New instances of the class can be created with the `MsBackendMassIVE()`
function. Data is loaded and initialized using the
[`backendInitialize()`](https://rdrr.io/pkg/ProtGenerics/man/backendInitialize.html)
function which can be configured with parameters `massiveId` and
`filePattern`. `massiveId` must be the ID of a **single** (existing)
MassIVE dataset (e.g. `"MSV000079514"`). Optional parameter
`filePattern` defines the pattern used to filter the file names of the
MS data files. It defaults to data files with file endings of supported
MS data formats.
[`backendInitialize()`](https://rdrr.io/pkg/ProtGenerics/man/backendInitialize.html)
requires an active internet connection as the function first compares
the remote file content to the locally cached files and eventually
synchronizes changes/updates. This can be skipped with `offline = TRUE`
in which case only locally cached content is queried.

The
[`backendRequiredSpectraVariables()`](https://rdrr.io/pkg/Spectra/man/MsBackend.html)
function returns the names of the spectra variables required for the
backend to provide the MS data.

The `massive_sync()` function can be used to *synchronize* the local
data cache and ensure that all data files are locally available. The
function will check the local cache and eventually download missing data
files from the MassIVE repository.

## Author

Gabriele Tomè, Philippine Louail, Johannes Rainer

## Examples

``` r

library(MsBackendMassIVE)

## List files of a MassIVE data set
massive_list_files("MSV000080547")
#>  [1] "ccms_parameters/params.xml"                      
#>  [2] "peak/Quant_assesment_QE/AG_spiked_sample1.mzXML" 
#>  [3] "peak/Quant_assesment_QE/AG_spiked_sample10.mzXML"
#>  [4] "peak/Quant_assesment_QE/AG_spiked_sample11.mzXML"
#>  [5] "peak/Quant_assesment_QE/AG_spiked_sample12.mzXML"
#>  [6] "peak/Quant_assesment_QE/AG_spiked_sample13.mzXML"
#>  [7] "peak/Quant_assesment_QE/AG_spiked_sample14.mzXML"
#>  [8] "peak/Quant_assesment_QE/AG_spiked_sample15.mzXML"
#>  [9] "peak/Quant_assesment_QE/AG_spiked_sample16.mzXML"
#> [10] "peak/Quant_assesment_QE/AG_spiked_sample17.mzXML"
#> [11] "peak/Quant_assesment_QE/AG_spiked_sample18.mzXML"
#> [12] "peak/Quant_assesment_QE/AG_spiked_sample19.mzXML"
#> [13] "peak/Quant_assesment_QE/AG_spiked_sample2.mzXML" 
#> [14] "peak/Quant_assesment_QE/AG_spiked_sample20.mzXML"
#> [15] "peak/Quant_assesment_QE/AG_spiked_sample3.mzXML" 
#> [16] "peak/Quant_assesment_QE/AG_spiked_sample4.mzXML" 
#> [17] "peak/Quant_assesment_QE/AG_spiked_sample5.mzXML" 
#> [18] "peak/Quant_assesment_QE/AG_spiked_sample6.mzXML" 
#> [19] "peak/Quant_assesment_QE/AG_spiked_sample7.mzXML" 
#> [20] "peak/Quant_assesment_QE/AG_spiked_sample8.mzXML" 
#> [21] "peak/Quant_assesment_QE/AG_spiked_sample9.mzXML" 
#> [22] "peak/Quant_assesment_QQQ/AG_spiked_sample1.mzML" 
#> [23] "peak/Quant_assesment_QQQ/AG_spiked_sample10.mzML"
#> [24] "peak/Quant_assesment_QQQ/AG_spiked_sample11.mzML"
#> [25] "peak/Quant_assesment_QQQ/AG_spiked_sample12.mzML"
#> [26] "peak/Quant_assesment_QQQ/AG_spiked_sample13.mzML"
#> [27] "peak/Quant_assesment_QQQ/AG_spiked_sample14.mzML"
#> [28] "peak/Quant_assesment_QQQ/AG_spiked_sample15.mzML"
#> [29] "peak/Quant_assesment_QQQ/AG_spiked_sample16.mzML"
#> [30] "peak/Quant_assesment_QQQ/AG_spiked_sample17.mzML"
#> [31] "peak/Quant_assesment_QQQ/AG_spiked_sample18.mzML"
#> [32] "peak/Quant_assesment_QQQ/AG_spiked_sample19.mzML"
#> [33] "peak/Quant_assesment_QQQ/AG_spiked_sample2.mzML" 
#> [34] "peak/Quant_assesment_QQQ/AG_spiked_sample20.mzML"
#> [35] "peak/Quant_assesment_QQQ/AG_spiked_sample3.mzML" 
#> [36] "peak/Quant_assesment_QQQ/AG_spiked_sample4.mzML" 
#> [37] "peak/Quant_assesment_QQQ/AG_spiked_sample5.mzML" 
#> [38] "peak/Quant_assesment_QQQ/AG_spiked_sample6.mzML" 
#> [39] "peak/Quant_assesment_QQQ/AG_spiked_sample7.mzML" 
#> [40] "peak/Quant_assesment_QQQ/AG_spiked_sample8.mzML" 
#> [41] "peak/Quant_assesment_QQQ/AG_spiked_sample9.mzML" 

## Initialize a MsBackendMassIVE representing all MS data files of
## the data set with the ID "MSV000080547". This will download and cache all
## files and subsequently load and represent them in R.

be <- backendInitialize(MsBackendMassIVE(), "MSV000080547",
                        filePattern = "11.mzML$")
be
#> MsBackendMassIVE with 2161 spectra
#>        msLevel     rtime scanIndex
#>      <integer> <numeric> <integer>
#> 1            1     0.515         1
#> 2            1     0.845         2
#> 3            1     1.175         3
#> 4            1     1.513         4
#> 5            1     1.857         5
#> ...        ...       ...       ...
#> 2157         1   718.439      2157
#> 2158         1   718.769      2158
#> 2159         1   719.099      2159
#> 2160         1   719.429      2160
#> 2161         1   719.759      2161
#>  ... 36 more variables/columns.
#> 
#> file(s):
#> AG_spiked_sample11.mzML

## The `massive_sync()` function can be used to ensure that all data files
## are available locally. This function will eventually download missing data
## files or update their paths.
be <- massive_sync(be)
```
