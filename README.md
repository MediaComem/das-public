# das-public

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.10136232.svg)](https://doi.org/10.5281/zenodo.10136232)

## Code and data

* See the [dataset folder](dataset) to creates from the [PubMed Central OA collection](https://www.ncbi.nlm.nih.gov/pmc/tools/openftlist) dataset, an CSV file to analyze the h_index impact on publication citation.
  * In `dataset/dev_set`, some articles are added to the previous ones to validate the `h_index` calculation.
  * The source code has been updated to the latest python and packages release when necessary.
  * Detect authors in the OSI dataset.
  * Collect all citations given from any article in PubMed OA to OSI articles, using identifiers contained in the lists of references.
  * Calculate citation counts for 1, 2, and possibly 3 years after publication of all OSI articles, using month level precision (e.g., for an article published in June 2019, a 2 year citation window comprises all citations received by articles published until June 2021). Furthermore, calculate the author-level H-index based on the same data.
  * Compute the H-index and timed citation indicators as a dataset that can be joined with the OSI dataset.
  * Develop and run satisfactory tests to insure the correctness of results.
* To validate the code, please refer the [testing procedure](test.md)
* The result could be found in `dataset/exports/export_plos.csv`

# Original work
This repository is based on the previous work here:

[![DOI](https://zenodo.org/badge/180121200.svg)](https://zenodo.org/badge/latestdoi/180121200)
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/alan-turing-institute/das-public/master?filepath=notebooks%2FDescriptiveFigures.ipynb)

## Previous publications
The original code is mentioned in the following papers:

* 📃 Preprint: https://arxiv.org/abs/1907.02565.
* 📝 Peer reviewed publication: https://doi.org/10.1371/journal.pone.0230416

Blogs and talks:
* "A selfish reason to share research data": https://www.turing.ac.uk/blog/selfish-reason-share-research-data

## Code and data

* See the [dataset folder](dataset) to create a dataset for analysis from the [PubMed Central OA collection](https://www.ncbi.nlm.nih.gov/pmc/tools/openftlist).
* See the [notebooks](notebooks) and [scripts](scripts) folders to replicate Figure 2 (shown below) and have a descriptive overview of the dataset.
* See the [analysis folder](analysis) to replicate analytical results from the paper. The [dataset analysed in the paper](analysis/dataset/export_full.csv.zip) is provided, so that the two replication steps can be done independently.
* The [figures](figures) and [resources](resources) folders contain supporting files.

![](figures/Figure2.png)

## Report issues

Please add an issue or notify the authors should you find any error to correct or improvement to make.
Well-documented pull requests are particularly appreciated.

## How to cite

> Colavizza, G., Hrynaszkiewicz, I., Staden, I., Whitaker, K., & McGillivray, B. (2020). The citation advantage of linking publications to research data. PLOS ONE, 15(4), e0230416. https://doi.org/10.1371/journal.pone.0230416

```
@article{Colavizza_Hrynaszkiewicz_Staden_Whitaker_McGillivray_2020,
  title =     {The citation advantage of linking publications to research data},
  volume =    {15},
  url =       {http://dx.doi.org/10.1371/journal.pone.0230416},
  DOI =       {10.1371/journal.pone.0230416},
  number =    {4},
  journal =   {PLOS ONE},
  publisher = {Public Library of Science (PLoS)},
  author =    {Colavizza, Giovanni and
               Hrynaszkiewicz, Iain and 
               Staden, Isla and 
               Whitaker, Kirstie and 
               McGillivray, Barbara},
  editor =    {Wicherts, Jelte M.Editor},
  year =     {2020},
  month =    {Apr},
  pages =    {e0230416}
  }
```
