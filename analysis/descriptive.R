########################
# DESCRIPTIVE ANALYSIS #
########################
# Author: Giovanni Colavizza

# Set your own working directory here
setwd("~/das-public/analysis")

options(scipen=999) # prevents excessive use of scientific notation

require(ggplot2)
require(GGally)
require(dplyr)

# read
DATASET <- read.csv("dataset/DATASET.csv")

summary(DATASET)

# correlations
corr <- round(cor(DATASET[, c("n_cit_tot", "n_cit_2", "n_authors", "n_references_tot", "p_year", "h_index_mean")], method = "pearson", use="complete.obs"), 2)
upper <- corr
upper[upper.tri(corr, diag = TRUE)] <- ""
upper <- as.data.frame(upper)
upper
ggpairs(DATASET[, c("n_cit_tot", "n_cit_2", "n_authors", "n_references_tot", "p_year", "h_index_mean")])

corr <- round(cor(DATASET[, c("n_cit_tot", "n_cit_2", "n_authors", "n_references_tot", "p_year", "h_index_mean", "Data_Shared","Repositories_data_bool","Code_Generated","Code_Shared","Preprint_Match")], method = "pearson", use="complete.obs"), 2)
upper <- corr
upper[upper.tri(corr, diag = TRUE)] <- ""
upper <- as.data.frame(upper)
upper

# check for lognormal distribution (and compare vs Pareto): it looks more like the former.
qqnorm(DATASET$n_cit_tot_log)
qex <- function(x) qexp((rank(x)-.375)/(length(x)+.25))
plot(qex(DATASET$n_cit_tot),DATASET$n_cit_tot_log)

# check value count distributions

mat <- stack(table(DATASET$Country)) # USE, filtering low value counts
mat <- mat[order(mat$values), ]
tail(mat,10)

mat <- stack(table(DATASET$Preprint_Server)) # USE, filtering low value counts
mat <- mat[order(mat$values), ]
tail(mat,10)

mat <- stack(table(DATASET$Data_Generated)) # Not useful
mat <- mat[order(mat$values), ]
tail(mat,10)

mat <- stack(table(DATASET$Data_Shared)) # USE
mat <- mat[order(mat$values), ]
tail(mat,10)

mat <- stack(table(DATASET$Data_Location)) # USE
mat <- mat[order(mat$values), ]
tail(mat,10)

mat <- stack(table(DATASET$Repositories_data)) # USE, trasform to binary
mat <- mat[order(mat$values), ]
tail(mat,10)

mat <- stack(table(DATASET$Repositories_data_bool)) # USE
mat <- mat[order(mat$values), ]
tail(mat,10)

mat <- stack(table(DATASET$Code_Generated)) # Not useful
mat <- mat[order(mat$values), ]
tail(mat,10)

mat <- stack(table(DATASET$Code_Shared)) # USE
mat <- mat[order(mat$values), ]
tail(mat,10)

mat <- stack(table(DATASET$Code_Location)) # USE
mat <- mat[order(mat$values), ]
tail(mat,10)

mat <- stack(table(DATASET$Preprint_Match)) # USE
mat <- mat[order(mat$values), ]
tail(mat,10)

mat <- stack(table(DATASET$journal)) # Not useful
mat <- mat[order(mat$values), ]
tail(mat,10)

mat <- stack(table(DATASET$journal_domain)) # Not useful
mat <- mat[order(mat$values), ]
tail(mat,10)

mat <- stack(table(DATASET$journal_field)) # Not useful
mat <- mat[order(mat$values), ]
tail(mat,10)

mat <- stack(table(DATASET$journal_subfield)) # Not useful
mat <- mat[order(mat$values), ]
tail(mat,10)
