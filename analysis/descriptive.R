########################
# DESCRIPTIVE ANALYSIS #
########################
# Author: Giovanni Colavizza

# Set your own working directory here
setwd("~/Dropbox/db_projects/Odoma_projects/das-public/analysis")

options(scipen=999) # prevents excessive use of scientific notation

require(reshape2)
require(ggplot2)
require(GGally)
require(dplyr)

# read
DATASET <- read.csv("dataset/DATASET.csv")

summary(DATASET)

# correlations
corr <- round(cor(DATASET[, c("n_cit_tot", "n_cit_2", "n_authors", "n_references_tot", "p_year", "p_month", "h_index_mean")], method = "pearson", use="complete.obs"), 2)
upper <- corr
upper[upper.tri(corr, diag = TRUE)] <- ""
upper <- as.data.frame(upper)
upper
ggpairs(DATASET[, c("n_cit_tot", "n_cit_2", "n_authors", "n_references_tot", "p_year", "p_month", "h_index_mean")])

corr <- round(cor(DATASET[, c("n_cit_tot", "n_cit_2", "n_authors", "n_references_tot", "p_year", "p_month", "h_index_mean", "Data_Shared","Repositories_data_bool","Code_Generated","Code_Shared","Preprint_Match")], method = "pearson", use="complete.obs"), 2)
upper <- corr
upper[upper.tri(corr, diag = TRUE)] <- ""
upper <- as.data.frame(upper)
upper

# check for lognormal distribution (and compare vs Pareto): it looks more like the former.
qqnorm(DATASET$n_cit_tot_log)
qex <- function(x) qexp((rank(x)-.375)/(length(x)+.25))
plot(qex(DATASET$n_cit_tot),DATASET$n_cit_tot_log)

# check value counts

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

# DESCRIPTIVE PLOTS

# Load necessary libraries
library(dplyr)
library(tidyr)
library(ggplot2)

# 1: % of OSI over time

# Calculate the percentage of 1s for each variable by year
DATASET_aggregated <- DATASET %>%
  group_by(p_year) %>%
  summarise(across(c(Code_Shared,Repositories_data_bool,Preprint_Match), ~mean(.x) * 100)) # Calculate the mean and convert to percentage

# Reshape the data from wide to long format for plotting
DATASET_long <- reshape2::melt(DATASET_aggregated, id.vars = "p_year", variable.name = "variable", value.name = "percentage")

# Plotting the data
ggplot(DATASET_long, aes(x = p_year, y = percentage, linetype = variable)) +
  geom_line(aes(color = variable)) + # Drawing the lines
  scale_color_manual(values = rep("black", 3)) + # Set the colors to black
  theme_minimal(base_size = 16) + # Minimal theme
  labs(x = "Year", y = "Percentage of publications", title = "Adoption of OSI over time") +
  theme(legend.title = element_blank()) + # Remove legend title
  scale_linetype_manual(values=c("solid", "dotted", "twodash")) # Custom line types

# 2: OSI by DIVISION

# Replace "True" with 1 and "False" with 0 in division_1 to division_18 columns
DATASET <- DATASET %>%
  mutate(across(starts_with("division_"), ~ as.integer(. == "True")))

# Step 1: Filter for division_1 being 1
division_1_data <- DATASET %>% filter(division_1 == 1)

# Step 2: Calculate percentages
percentages <- division_1_data %>%
  summarise(across(c(Code_Shared,Repositories_data_bool,Preprint_Match), ~mean(.x, na.rm = TRUE) * 100)) %>%
  pivot_longer(cols = c(Code_Shared,Repositories_data_bool,Preprint_Match), names_to = "variable", values_to = "percentage")

# Step 3: Plot
ggplot(percentages, aes(x = variable, y = percentage, fill = variable)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  theme_minimal(base_size = 14) +
  labs(x = "Variable", y = "Percentage of 1s", title = "Percentage of 1s in Division 1") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# ALL divisions

# Initialize an empty dataframe to store the aggregated percentages
aggregated_data <- data.frame(division = character(), 
                              variable = character(), 
                              percentage = numeric())

# Loop through each division
for(i in 1:18) {
  division_col <- paste("division_", i, sep = "")
  
  # Calculate the percentage of 1s for Code_Shared,Repositories_data_bool,Preprint_Match within the current division
  temp_data <- DATASET %>%
    filter(.[[division_col]] == 1) %>%
    summarise(Code_Shared = mean(Code_Shared) * 100,
              Repositories_data_bool = mean(Repositories_data_bool) * 100,
              Preprint_Match = mean(Preprint_Match) * 100) %>%
    pivot_longer(cols = c(Code_Shared,Repositories_data_bool,Preprint_Match), names_to = "variable", values_to = "percentage") %>%
    mutate(division = division_col)
  
  # Append the results to the aggregated_data dataframe
  aggregated_data <- bind_rows(aggregated_data, temp_data)
}

# Ensure division is a factor with levels sorted as desired
# Directly setting levels in numeric order will sort them from 1 to 18 in the plot
aggregated_data$division <- factor(aggregated_data$division, levels = paste("division_", 1:18, sep = ""))

# Plotting, ensuring black and white output and correct ordering of divisions
ggplot(aggregated_data, aes(x = division, y = percentage, fill = variable)) +
  geom_bar(stat = "identity", position = position_dodge(), width = 0.7) +
  scale_fill_manual(values=c("black", "grey50", "grey80"), 
                    labels = c("Code_Shared", "Repository_data_bool", "Preprint_Match")) +
  theme_minimal(base_size = 14) +
  labs(x = "Division", y = "Percentage of publications", title = "Adoption of OSI by Division") +
  theme(axis.text.x = element_text(angle = 65, hjust = 1), # Adjust for readability
        legend.title = element_blank()) + # Clean legend
  scale_x_discrete(limits = paste("division_", 1:18, sep = "")) # Ensure correct order

