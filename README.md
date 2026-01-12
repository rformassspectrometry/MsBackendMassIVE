# Retrieve Mass Spectrometry Data from MetaboLights

[![Project Status: Concept – Minimal or no implementation has been done yet, or the repository is only intended to be a limited example, demo, or proof-of-concept.](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)


This repository provides a *backend* for
[Spectra](https://github.com/RforMassSpectrometry/Spectra) objects that
represents and retrieves mass spectrometry (MS) data directly from metabolomics
experiments deposited at the public
[MassIVE](...) repository. Mass
spectrometry data files of an experiment are downloaded and cached locally using
the [BiocFileCache](https://bioconductor.org/packages/BiocFileCache) package.


# Installation

The package can be installed with

```r
install.packages("BiocManager")
BiocManager::install("RforMassSpectrometry/MsBackendMassIVE")
```


# Contributions

Contributions are highly welcome and should follow the [contribution
guidelines](https://rformassspectrometry.github.io/RforMassSpectrometry/articles/RforMassSpectrometry.html#contributions).
Also, please check the coding style guidelines in the [RforMassSpectrometry
vignette](https://rformassspectrometry.github.io/RforMassSpectrometry/articles/RforMassSpectrometry.html).
