# Dataset

Folder containing the necessary code to create a dataset for analysis from the PubMed Central Open Access collection.

## Contents

* [config folder](config): contains config files, ground truth, the list of BMC and PLoS journals as well as the Science-Metrix journal classification.
* [das classifier folder](das_classifier): contains code and instructions to reproduce the DAS classification step.
* [dev set folder](dev_set): contains a uniform sample of articles from the PMC OA collection.
* [exports folder](exports): contains exports from scripts.
* [logs folder](logs): empty, for log files.
* A set of scripts to create the dataset, see below for instructions. You might need to adjust some parameters at the beginning of each script before using them.

## Instructions

1. Download the Pubmed OA collection, e.g. via their FTP service: https://www.ncbi.nlm.nih.gov/pmc/tools/ftp. For testing,you can use the data in the [dev set folder](dev_set).
2. Setup a MongoDB and update the [config file](config/config.conf) or run `docker compose up` with the current config.
3. Uncompress `PLOS_Dataset_Classification.zip` in the config folder then move the folder content into the current folder.
4. Run the [parser_main.py](parser_main.py) script, which will create a first collection of articles in Mongo.
5. Run the [calculate_stats.py](calculate_stats.py) script, which will calculate citation counts for articles and authors and create the relative collections in Mongo.
6. Run the [calculate_h_index.py](calculate_h_index.py) script, which will update the `h_indexes` elements of each documents with the result of the h_index calculaiton.
7. Run the [get_export.py](get_export.py) script, which will create a first export of the dataset in the [exports folder](exports).

## Requirements

See [requirements](../requirements.txt).