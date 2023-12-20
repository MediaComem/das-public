# OSI Modelling and Analysis

This folder contains R code to replicate the analyses done in the paper. It further contains a copy of the dataset we analysed in the paper, thus analyses can be reproduced independently from the creation of the dataset from scratch.

* [R models](r_models.R): code to replicate the modelling analyses.
* [R descriptive](descriptive.R): code to replicate the descriptive analyses.
* [dataset/compressed](dataset/compressed/): folder containing the zipped copy of the datasets used for analysis, created as per instructions in [R models](r_models.R). Please unzip them in the /dataset folder for reproducing our results.
	- *DATASET.csv*: contains the complete data frame used for modelling. 
	- *df_OSI.csv*: contains the OSI data frame, consolidated from version 5.2.
	- *df_OSI_classes_top.csv*: contains the ANZSRC FoR Division as dummy variables.
	- *export_plos.csv*: contains citation counts (as in the *datasets/exports* folder).

## Instructions

See comments in the code.

## Requirements

We used the following R libraries (and versions):

* R 4.3.2
* ggplot2 3.4.4
* GGally 2.1.2
* VGAM 1.1.9
* glamss 5.4.20
* MASS 7.3.60
* stargazer 5.2.3
* dyplr 1.1.3
* xtable 1.8.4