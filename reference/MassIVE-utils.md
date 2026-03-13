# Utility functions for the MassIVE repository

[MassIVE](https://massive.ucsd.edu/ProteoSAFe/static/massive.jsp) (Mass
Spectrometry Interactive Virtual Environment) is a community resource
developed by the NIH-funded Center for Computational Mass Spectrometry
to promote the global, free exchange of mass spectrometry data. MassIVE
supports deposition of both proteomics and metabolomics experiments, and
is a full member of the
[ProteomeXchange](http://www.proteomexchange.org/) consortium, allowing
datasets to be assigned ProteomeXchange accessions to satisfy
publication requirements. Submitted data can include raw mass
spectrometry files, identification results, and quantification data. The
repository also provides online workflows for reanalysis of public
datasets and tools for comparison of identification results across
datasets.

Each experiment in MassIVE is identified with its unique identifier,
starting with *MSV* followed by a number. The data (raw MS files,
metadata, and result files) of a dataset are available for public
download and online browsing once the dataset has been made public by
its submitter.

The functions listed here allow to query and retrieve information of a
data set/experiment from MassIVE.

- `massive_ftp_path()`: returns the FTP path for a provided MassIVE ID.
  If the MassIVE ID does not exist the function throws an error. With
  `mustWork = TRUE` (the default) the function throws an error either
  because the data set does not exist in [GNPS2
  DB](https://datasetcache.gnps2.org/datasette/database/filename) (No
  mzML/CDF/mzXML files available) or no internet connection is
  available. The function returns a `character(1)` with the FTP path to
  the data set folder.

- `massive_cached_data_files()`: lists locally cached data files from
  MassIVE. Since this function evaluates only local content it does not
  require an internet connection. With the default parameters all
  available data files are listed. The parameters can be used to
  restrict the lookup.

- `massive_list_files()`: returns the available files (and directories)
  for the specified MassIVE data set (i.e., the FTP directory content of
  the data set). The function returns a `character` vector with the
  relative file names to the absolute FTP path (`massive_ftp_path()`) of
  the data set. Parameter `pattern` allows to filter the file names and
  define which file names should be returned.

- `massive_sync_data_files()`: synchronize data files of a specified
  MassIVE data set eventually downloading and locally caching them.
  Parameter `fileName` allows to specify names of selected data files to
  sync.

- `massive_delete_cache()`: removes all local content for the MassIVE
  data set with ID `massiveId`. This will delete eventually present
  locally cached data files for the specified data set. This does not
  change any other data eventually present in the local `BiocFileCache`.

## Usage

``` r
massive_ftp_path(x = character(), mustWork = TRUE)

massive_list_files(x = character(), pattern = NULL)

massive_sync_data_files(
  massiveId = character(),
  pattern = "mzML$|CDF$|cdf$|mzXML$",
  fileName = character()
)

massive_cached_data_files(
  massiveId = character(),
  pattern = "*",
  fileName = character()
)

massive_delete_cache(massiveId = character())
```

## Arguments

- x:

  `character(1)` with the ID of the MassIVE data set (usually starting
  with a *MSV* followed by a number).

- mustWork:

  for `massive_ftp_path()`: `logical(1)` whether the validity of the
  path should be verified or not. By default (with `mustWork = TRUE`)
  the function throws an error if either the data set does not exist or
  if the folder can not be accessed (e.g. if no internet connection is
  available).

- pattern:

  for `massive_list_files()`, `massive_sync_data_files()` and
  `massive_cached_data_files()`: `character(1)` defining a pattern to
  filter the file names, such as `pattern = "mzML$"` to retrieve the
  file names of all files of the data set (i.e., files with extension
  `"mzML"`). This parameter is passed to the
  [`grepl()`](https://rdrr.io/r/base/grep.html) function.

- massiveId:

  `character(1)` with the ID of a single MassIVE data set/experiment.

- fileName:

  for `massive_sync_data_files()` and `massive_cached_data_files()`:
  optional `character` defining the names of specific data files of a
  data set that should be downloaded and cached.

## Value

- For `massive_ftp_path()`: `character(1)` with the ftp path to the
  specified data set on the MassIVE ftp server.

- For `massive_list_files()`: `character` with the names of the files in
  the data set's base ftp directory.

- For `massive_sync_data_files()` and `massive_cached_data_files()`: a
  `data.frame` with the MassIVE ID, the name(s) and remote and local
  file names of the synchronized data files.

## Details

Data retrieval follows three main steps. First, the package queries the
[GNPS2 DB](https://datasetcache.gnps2.org/datasette/database/filename)
to list all files for the provided `massiveId`, filtering them by
`filePattern` to retain only formats supported by `MsBackendMzR` (mzML,
CDF, mzXML). Second, the FTP link is retrieved from
[MassIVE](https://massive.ucsd.edu/ProteoSAFe/). If the requested files
are in the `ccms_peak` folder, the FTP link is updated by changing the
volume from the project-specific one to volume `z01`, which contains the
`ccms_peak` folder for all projects. Each file is then downloaded from
the MassIVE FTP server and cached locally. Files already present in the
cache are not re-downloaded. Third, the cached local paths are passed to
[`Spectra::MsBackendMzR()`](https://rdrr.io/pkg/Spectra/man/MsBackend.html)
to read and index the spectral data. Two additional per-spectrum
variables are populated: `"massive_id"` and `"data_file"`. When
`offline = TRUE`, the remote query is skipped and only previously cached
content is used.

## Author

Johannes Rainer, Philippine Louail, Gabriele Tomè

## Examples

``` r

## Get the FTP path to the data set MSV000080547
massive_ftp_path("MSV000080547")
#> [1] "ftp://massive-ftp.ucsd.edu/v01/MSV000080547/"

## Retrieve available files (and directories) for the data set MSV000080547
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

## Retrieve the available .mzML files.
mzMLfiles <- massive_list_files("MSV000080547", pattern = "mzML$")
mzMLfiles
#>  [1] "peak/Quant_assesment_QQQ/AG_spiked_sample1.mzML" 
#>  [2] "peak/Quant_assesment_QQQ/AG_spiked_sample10.mzML"
#>  [3] "peak/Quant_assesment_QQQ/AG_spiked_sample11.mzML"
#>  [4] "peak/Quant_assesment_QQQ/AG_spiked_sample12.mzML"
#>  [5] "peak/Quant_assesment_QQQ/AG_spiked_sample13.mzML"
#>  [6] "peak/Quant_assesment_QQQ/AG_spiked_sample14.mzML"
#>  [7] "peak/Quant_assesment_QQQ/AG_spiked_sample15.mzML"
#>  [8] "peak/Quant_assesment_QQQ/AG_spiked_sample16.mzML"
#>  [9] "peak/Quant_assesment_QQQ/AG_spiked_sample17.mzML"
#> [10] "peak/Quant_assesment_QQQ/AG_spiked_sample18.mzML"
#> [11] "peak/Quant_assesment_QQQ/AG_spiked_sample19.mzML"
#> [12] "peak/Quant_assesment_QQQ/AG_spiked_sample2.mzML" 
#> [13] "peak/Quant_assesment_QQQ/AG_spiked_sample20.mzML"
#> [14] "peak/Quant_assesment_QQQ/AG_spiked_sample3.mzML" 
#> [15] "peak/Quant_assesment_QQQ/AG_spiked_sample4.mzML" 
#> [16] "peak/Quant_assesment_QQQ/AG_spiked_sample5.mzML" 
#> [17] "peak/Quant_assesment_QQQ/AG_spiked_sample6.mzML" 
#> [18] "peak/Quant_assesment_QQQ/AG_spiked_sample7.mzML" 
#> [19] "peak/Quant_assesment_QQQ/AG_spiked_sample8.mzML" 
#> [20] "peak/Quant_assesment_QQQ/AG_spiked_sample9.mzML" 
```
