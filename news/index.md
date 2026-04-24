# Changelog

## MsBackendMassIVE 0.99

### Changers in 0.99.0

- Fix bug in ftp url encoding.
- Improve performance
  [`massive_ftp_path()`](https://rformassspectrometry.github.io/MsBackendMassIVE/reference/MassIVE-utils.md).
- Add
  [`massive_number_files()`](https://rformassspectrometry.github.io/MsBackendMassIVE/reference/MassIVE-utils.md).
- Fix bug handling duplicates files.
- Update examples and tests

### Changes in 0.1.5

- Add examples for MassIVE and GNPS2 utility functions to the vignette.

### Changes in 0.1.4

- Add
  [`gnps2_usi_download_link()`](https://rformassspectrometry.github.io/MsBackendMassIVE/reference/GNPS2-utils.md)
  to get download link for a USI

### Changes in 0.1.3

- Separate GNPS2 function from
  [`massive_list_files()`](https://rformassspectrometry.github.io/MsBackendMassIVE/reference/MassIVE-utils.md)
- Remove repetitive error

### Changes in 0.1.2

- Add
  [`massive_param_file()`](https://rformassspectrometry.github.io/MsBackendMassIVE/reference/MassIVE-utils.md)
  to parse params.xml file.
- Add additional test for
  [`massive_list_files()`](https://rformassspectrometry.github.io/MsBackendMassIVE/reference/MassIVE-utils.md)
  and `.massive_data_files()`

### Changes in 0.1.1

- Add package vignette.
- Replace interactive
  [`readline()`](https://rdrr.io/r/base/readline.html) with `overwrite`
  parameter in
  [`massive_download_file()`](https://rformassspectrometry.github.io/MsBackendMassIVE/reference/MassIVE-utils.md).
- Replace [`cat()`](https://rdrr.io/r/base/cat.html) with
  [`message()`](https://rdrr.io/r/base/message.html) in
  [`massive_download_file()`](https://rformassspectrometry.github.io/MsBackendMassIVE/reference/MassIVE-utils.md).

### Changes in 0.1.0

- Add MassIVE utilities.
- Add functionality to download and cache MS data files from MassIVE.
- Add unit tests.
