# PLOS Open Science Indicators

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.11027260.svg)](https://doi.org/10.5281/zenodo.11027260)

PLOS recently published an innovative [dataset of Open Science Indicators (OSI)](https://doi.org/10.6084/m9.figshare.21687686.v5), focused on its entire collection plus a comparison dataset from PubMed. We use here the [OSI version 5](https://plos.figshare.com/articles/dataset/PLOS_Open_Science_Indicators/21687686/5), containing approximately 124000 PMC and PLOS articles. The OSI is primarily concerned with indicators on: sharing of research data, in particular, data shared in data repositories; sharing of code; and posting of preprints.

The [Media Engineering Institute (MEI)](https://heig-vd.ch/en/research/mei) has been involved in collecting data from the PubMed Open Access collection to equip the OSI dataset with citation data (article) and h-index data (author level), in preparation for further analysis. The data collection pipeline has been adapted following the process described in the previous work on Data Availability Statements, described below.

## Code and data

* We start from the OSI dataset and the [PubMed Central Open Access collection](https://www.ncbi.nlm.nih.gov/pmc/tools/openftlist). Our goal is to extract a CSV file containing citation data and h-index data for every article in OSI, calculated from PubMed OA.
* See the [dataset folder](dataset) for more details on the steps taken:
  * Detect authors in the OSI dataset.
  * Collect all citations given from any article in PubMed OA to any OSI article, using known identifiers contained in the lists of references.
  * Calculate citation counts for 1, 2, and 3 years after the publication of all OSI articles, using month-level precision (e.g., for an article published in June 2019, a 2-year citation window comprises all citations received by articles published until June 2021). Furthermore, calculate the author-level h-index based on the same data.
  * Compute the h-index and timed citation indicators as a dataset that can be joined with the OSI dataset.
  * Develop and run satisfactory tests to ensure the correctness of results. In `dataset/dev_set`, some articles are added to the previous ones to validate the citation and h_index calculations.
  * The source code has been updated to the latest Python and packages release when necessary.
* To validate the code, please refer to the [testing procedure](test.md).
* The final result can be found in [dataset/exports/export_plos.csv.zip](dataset/exports/export_plos.csv.zip).

## Modelling and analysis

The code and data for the modelling and analysis can be found in the [analysis folder](analysis).


## Original work

This repository is a fork of previous work that can be found here:

* [![DOI](https://zenodo.org/badge/180121200.svg)](https://zenodo.org/badge/latestdoi/180121200)
* [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/alan-turing-institute/das-public/master?filepath=notebooks%2FDescriptiveFigures.ipynb)

The original code is mentioned in the following papers:

* 📃 Preprint: https://arxiv.org/abs/1907.02565.
* 📝 Peer-reviewed publication: https://doi.org/10.1371/journal.pone.0230416.

Please add an issue or notify the authors should you find any error to correct or improvements to make.
Well-documented pull requests are particularly appreciated.