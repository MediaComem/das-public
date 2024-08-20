#################
# MODEL FITTING #
#################
# Author: Giovanni Colavizza

# Set your own working directory here
setwd("~/Dropbox/db_projects/Odoma_projects/das-public/analysis")

options(scipen=999) # prevents excessive use of scientific notation

require(ggplot2)
require(GGally)
require(xtable)
require(dplyr)
require(stargazer)

###################
# Please JUMP to START HERE below if you want to go directly to models. #
###################

# load OSI datasets (remember to download them first!)
df_OSI_PLOS <- read.csv("dataset/PLOS-OSI-Dataset_v5/Main Data Files/PLOS-Dataset_v5_Dec23.csv", sep = ",", quote = '"')
df_OSI_PMC <- read.csv("dataset/PLOS-OSI-Dataset_v5/Main Data Files/Comparator-Dataset_v5_Dec23.csv", sep = ",", quote = '"')
setdiff(names(df_OSI_PLOS),names(df_OSI_PMC))
setdiff(names(df_OSI_PMC),names(df_OSI_PLOS))
df_OSI_PMC <- df_OSI_PMC %>% 
  rename("Disciplines" = "Discipline")

# add provenance
df_OSI_PMC$is_osi_plos <- 0
df_OSI_PLOS$is_osi_plos <- 1

# merge into one OSI dataset
df_OSI <- rbind(df_OSI_PLOS,df_OSI_PMC)
df_OSI <- df_OSI %>% 
  rename("doi" = "DOI")

# cleanup Preprint_Match column
df_OSI$Preprint_Match[df_OSI$Preprint_Match == "No"] <- 0
df_OSI$Preprint_Match[df_OSI$Preprint_Match == "False"] <- 0
df_OSI$Preprint_Match[df_OSI$Preprint_Match == "Yes"] <- 1
df_OSI$Preprint_Match[df_OSI$Preprint_Match == "True"] <- 1

# cleanup Data_Location column
df_OSI$Data_Location[df_OSI$Data_Location == "Online|Supplementary Information"] <- "Online"

# binarize Repositories_data
df_OSI$Repositories_data_bool <- 1
df_OSI$Repositories_data_bool[df_OSI$Repositories_data == "N/A"] <- 0

# create DAS column
df_OSI$das_new <- 1
df_OSI$das_new[df_OSI$Data_Shared == "Yes" & df_OSI$Data_Location == "Supplementary Information"] <- 2
df_OSI$das_new[df_OSI$Data_Shared == "Yes" & df_OSI$Data_Location == "Online"] <- 3

# transform to integer
df_OSI$Preprint_Day <- as.integer(df_OSI$Preprint_Day)
df_OSI$Preprint_Month <- as.integer(df_OSI$Preprint_Month)
df_OSI$Preprint_Year <- as.integer(df_OSI$Preprint_Year)
df_OSI$Data_Generated <- ifelse(df_OSI$Data_Generated == "Yes", 1, 0)
df_OSI$Data_Shared <- ifelse(df_OSI$Data_Shared == "Yes", 1, 0)
df_OSI$Code_Generated <- ifelse(df_OSI$Code_Generated == "Yes", 1, 0)
df_OSI$Code_Shared <- ifelse(df_OSI$Code_Shared == "Yes", 1, 0)

# read and add ANZSRC FoR Division 
df_OSI_classes_top <- read.csv("dataset/df_OSI_classes_top.csv")
df_OSI <- merge(x = df_OSI, y = df_OSI_classes_top, by = "doi")

summary(df_OSI)

# save
write.csv(df_OSI, "dataset/df_OSI.csv", row.names=FALSE)

# make transformations as necessary
df_OSI$Country <- factor(df_OSI$Country)
df_OSI$Data_Shared <- factor(df_OSI$Data_Shared)
df_OSI$Data_Location <- factor(df_OSI$Data_Location)
df_OSI$Preprint_Match <- factor(df_OSI$Preprint_Match)
df_OSI$Code_Generated <- factor(df_OSI$Code_Generated)
df_OSI$Code_Shared <- factor(df_OSI$Code_Shared)
df_OSI$Code_Location <- factor(df_OSI$Code_Location)
df_OSI$is_osi_plos <- factor(df_OSI$is_osi_plos)
df_OSI$das_new <- factor(df_OSI$das_new)
df_OSI$Repositories_data_bool <- factor(df_OSI$Repositories_data_bool)

df_OSI$division_1 <- factor(df_OSI$division_1)
df_OSI$division_2 <- factor(df_OSI$division_2)
df_OSI$division_3 <- factor(df_OSI$division_3)
df_OSI$division_4 <- factor(df_OSI$division_4)
df_OSI$division_5 <- factor(df_OSI$division_5)
df_OSI$division_6 <- factor(df_OSI$division_6)
df_OSI$division_7 <- factor(df_OSI$division_7)
df_OSI$division_8 <- factor(df_OSI$division_8)
df_OSI$division_9 <- factor(df_OSI$division_9)
df_OSI$division_10 <- factor(df_OSI$division_10)
df_OSI$division_11 <- factor(df_OSI$division_11)
df_OSI$division_12 <- factor(df_OSI$division_12)
df_OSI$division_13 <- factor(df_OSI$division_13)
df_OSI$division_14 <- factor(df_OSI$division_14)
df_OSI$division_15 <- factor(df_OSI$division_15)
df_OSI$division_16 <- factor(df_OSI$division_16)
df_OSI$division_17 <- factor(df_OSI$division_17)
df_OSI$division_18 <- factor(df_OSI$division_18)

# load the citations dataset and make transformations
df <- read.csv("dataset/export_plos.csv", sep = ";")

# add minimum one author
df$n_authors[df$n_authors == 0] <- 1

# add column for PLOS ONE vs all
df$is_plos_one <- 0
df <- df %>%
  mutate(is_plos_one = case_when(
    startsWith(journal, "PLoS ONE") ~ 1,
    startsWith(journal, "PLOS ONE") ~ 1,
    !endsWith(journal, "ONE") ~ 0
  ))

summary(df)

# make transformations as necessary
df$has_das <- factor(df$has_das)
df$is_plos <- factor(df$is_plos)
df$is_plos_one <- factor(df$is_plos_one)
df$is_bmc <- factor(df$is_bmc)
df$is_bmc <- factor(df$is_pmc)
df$has_month <- factor(df$has_month)
df$journal_domain <- factor(df$journal_domain)
df$journal_field <- factor(df$journal_field)
df$journal_subfield <- factor(df$journal_subfield)

# filter for time if necessary
df_filtered <- df[df$p_year<2024,]

# log-transform citation counts (add 1 to bound between zero and infinity)
df_filtered$n_cit_1_log <- df_filtered$n_cit_1 + 1
df_filtered$n_cit_1_log <- df_filtered$n_cit_1_log %>% replace(is.na(.), 1)
df_filtered$n_cit_1_log <- sapply(df_filtered$n_cit_1_log,log)
df_filtered$n_cit_2_log <- df_filtered$n_cit_2 + 1
df_filtered$n_cit_2_log <- df_filtered$n_cit_2_log %>% replace(is.na(.), 1)
df_filtered$n_cit_2_log <- sapply(df_filtered$n_cit_2_log,log)
df_filtered$n_cit_3_log <- df_filtered$n_cit_3 + 1
df_filtered$n_cit_3_log <- df_filtered$n_cit_3_log %>% replace(is.na(.), 1)
df_filtered$n_cit_3_log <- sapply(df_filtered$n_cit_3_log,log)
df_filtered$n_cit_tot_log <- df_filtered$n_cit_tot + 1
df_filtered$n_cit_tot_log <- df_filtered$n_cit_tot_log %>% replace(is.na(.), 1)
df_filtered$n_cit_tot_log <- sapply(df_filtered$n_cit_tot_log,log)

# log-transform other variables (optional, but better fitting due to outliers)
df_filtered$n_authors_log <- df_filtered$n_authors + 1
df_filtered$n_authors_log <- df_filtered$n_authors_log %>% replace(is.na(.), 1)
df_filtered$n_authors_log <- sapply(df_filtered$n_authors_log,log)
df_filtered$h_index_mean_log <- df_filtered$h_index_mean + 1
df_filtered$h_index_mean_log <- df_filtered$h_index_mean_log %>% replace(is.na(.), 1)
df_filtered$h_index_mean_log <- sapply(df_filtered$h_index_mean_log,log)
df_filtered$h_index_median_log <- df_filtered$h_index_median + 1
df_filtered$h_index_median_log <- df_filtered$h_index_median_log %>% replace(is.na(.), 1)
df_filtered$h_index_median_log <- sapply(df_filtered$h_index_median_log,log)
df_filtered$h_index_max_log <- df_filtered$h_index_max + 1
df_filtered$h_index_max_log <- df_filtered$h_index_max_log %>% replace(is.na(.), 1)
df_filtered$h_index_max_log <- sapply(df_filtered$h_index_max_log,log)
df_filtered$n_references_tot_log <- df_filtered$n_references_tot + 1
df_filtered$n_references_tot_log <- df_filtered$n_references_tot_log %>% replace(is.na(.), 1)
df_filtered$n_references_tot_log <- sapply(df_filtered$n_references_tot_log,log)

# select the dataset which will be used in regressions
DATASET <- df_filtered

# merge with OSI
DATASET <- merge(DATASET, df_OSI, by.x = "doi", by.y = "doi")

# save
write.csv(DATASET, "dataset/DATASET.csv", row.names=FALSE)

##################
### START HERE ###
##################
# read
DATASET <- read.csv("dataset/DATASET.csv")

# TABLE controls and dependent
summary(DATASET[c("n_cit_tot", "n_cit_2", "n_authors", "n_references_tot", "p_year", "p_month", "h_index_mean", "is_plos", "is_plos_one")])

# TABLE OSI
summary(DATASET[c("Data_Shared","Data_Location","Repositories_data_bool","Code_Generated","Code_Shared","Code_Location","Preprint_Match")])

###############
# MODELS: OLS #
###############
# https://stats.idre.ucla.edu/r/dae/robust-regression/

require(MASS)

# OLS test
summary(m_ols <- lm(n_cit_tot_log ~ C(is_plos) + C(has_das), data = DATASET))
# OLS test 2
summary(m_ols <- lm(n_cit_tot_log ~ n_authors_log + n_references_tot_log + p_year + p_month + h_index_mean_log + C(is_plos) + C(is_plos_one), data = DATASET))

# BASE MODEL #
summary(m_ols <- lm(n_cit_tot_log ~ n_authors_log + n_references_tot_log + p_year + p_month + h_index_mean_log + C(is_plos) + C(is_plos_one) + 
                      C(Data_Shared) + C(Data_Location) + C(Repositories_data_bool) + C(Code_Shared) + C(Code_Location) + C(Preprint_Match) , data = DATASET))

# Control for OSI: DAS
summary(m_ols <- lm(n_cit_tot_log ~ n_authors_log + n_references_tot_log + p_year + p_month + h_index_mean_log + C(is_plos) + C(is_plos_one) + 
                      C(das_new) + C(Repositories_data_bool) + C(Code_Shared) + C(Code_Location) + C(Preprint_Match) , data = DATASET))

# Control for OSI: Preprint_Year and Month
summary(m_ols <- lm(n_cit_tot_log ~ n_authors_log + n_references_tot_log + p_year + p_month + h_index_mean_log + C(is_plos) + C(is_plos_one) + 
                      C(Data_Shared) + C(Data_Location) + C(Repositories_data_bool) + C(Code_Shared) + C(Code_Location) + Preprint_Year + Preprint_Month , data = DATASET))

# Control for OSI: Code Generated
summary(m_ols <- lm(n_cit_tot_log ~ n_authors_log + n_references_tot_log + p_year + p_month + h_index_mean_log + C(is_plos) + C(is_plos_one) + 
                      C(Data_Shared) + C(Data_Location) + C(Repositories_data_bool) + C(Code_Generated) + C(Code_Shared) + C(Code_Location) + C(Preprint_Match) , data = DATASET))
summary(m_rols <- rlm(n_cit_tot_log ~ n_authors_log + n_references_tot_log + p_year + p_month + h_index_mean_log + C(is_plos) + C(is_plos_one) + 
                      C(Data_Shared) + C(Data_Location) + C(Repositories_data_bool) + C(Code_Generated) + C(Code_Shared) + C(Code_Location) + C(Preprint_Match) , data = DATASET))

# BASE MODEL: Use ONLY division X #
summary(m_ols <- lm(n_cit_tot_log ~ n_authors_log + n_references_tot_log + p_year + p_month + h_index_mean_log + C(is_plos) + C(is_plos_one) + 
                      C(Data_Shared) + C(Data_Location) + C(Repositories_data_bool) + C(Code_Shared) + C(Code_Location) + C(Preprint_Match) 
                    , data = DATASET[(DATASET$division_2=="True"),]))

# Control for interactions
summary(m_ols <- lm(n_cit_tot_log ~ n_authors_log + n_references_tot_log + p_year + p_month + h_index_mean_log + C(is_plos) + C(is_plos_one) + 
                      C(Data_Shared) + C(Data_Location) + C(Repositories_data_bool)*C(Preprint_Match) + C(Code_Generated)*C(Code_Shared) + C(Code_Location) , data = DATASET))
summary(m_rols <- rlm(n_cit_tot_log ~ n_authors_log + n_references_tot_log + p_year + p_month + h_index_mean_log + C(is_plos) + C(is_plos_one) + 
                      C(Data_Shared) + C(Data_Location) + C(Repositories_data_bool)*C(Preprint_Match) + C(Code_Generated)*C(Code_Shared) + C(Code_Location) , data = DATASET))


# Using jitter, different shapes, and alpha blending
ggplot(DATASET, aes(x = Repositories_data_bool, y = n_cit_tot_log, 
                    color = as.factor(Preprint_Match), shape = as.factor(Preprint_Match))) +
  geom_jitter(alpha = 0.6, position = position_jitter(width = 0.2, height = 0)) +
  geom_smooth(method = "lm", se = FALSE) +
  theme_minimal()

# FULL MODEL: Use division #
summary(m_ols <- lm(n_cit_tot_log ~ n_authors_log + n_references_tot_log + p_year + p_month + h_index_mean_log + C(is_plos) + C(is_plos_one) + 
                      C(Data_Shared) + C(Data_Location) + C(Repositories_data_bool) + C(Code_Shared) + C(Code_Location) + C(Preprint_Match) 
                    + C(division_1) + C(division_2) + C(division_3) + C(division_4) + C(division_5) + C(division_6) + C(division_7) + C(division_8) + C(division_9) + C(division_10) + C(division_11) + C(division_12) + C(division_13) + C(division_14) + C(division_15) + C(division_16) + C(division_17) + C(division_18)
                    , data = DATASET))

# control for interactions
summary(m_ols <- lm(n_cit_tot_log ~ n_authors_log + n_references_tot_log + p_year + p_month + h_index_mean_log + C(is_plos) + C(is_plos_one) + 
                      C(Data_Shared) + C(Data_Location) + C(Repositories_data_bool)*C(Preprint_Match) + C(Code_Generated)*C(Code_Shared) + C(Code_Location) 
                    + C(division_1) + C(division_2) + C(division_3) + C(division_4) + C(division_5) + C(division_6) + C(division_7) + C(division_8) + C(division_9) + C(division_10) + C(division_11) + C(division_12) + C(division_13) + C(division_14) + C(division_15) + C(division_16) + C(division_17) + C(division_18)
                    , data = DATASET))

# Calculate residuals
residuals <- resid(m_ols)
# Open a new plotting window
#dev.new()
# Generate the Q-Q plot of the residuals
qqnorm(residuals)
qqline(residuals, col = "red")

###
# Robust OLS
###

# Base model: 
summary(m_rols <- rlm(n_cit_tot_log ~ n_authors_log + n_references_tot_log + p_year + p_month + h_index_mean_log + C(is_plos) + C(is_plos_one) + 
                        C(Data_Shared) + C(Data_Location) + C(Repositories_data_bool) + C(Code_Shared) + C(Code_Location) + C(Preprint_Match) , data = DATASET))

# Full model:
summary(m_rols <- rlm(n_cit_tot_log ~ n_authors_log + n_references_tot_log + p_year + p_month + h_index_mean_log + C(is_plos) + C(is_plos_one) + 
                        C(Data_Shared) + C(Data_Location) + C(Repositories_data_bool) + C(Code_Shared) + C(Code_Location) + C(Preprint_Match) 
                      + C(division_1) + C(division_2) + C(division_3) + C(division_4) + C(division_5) + C(division_6) + C(division_7) + C(division_8) + C(division_9) + C(division_10) + C(division_11) + C(division_12) + C(division_13) + C(division_14) + C(division_15) + C(division_16) + C(division_17) + C(division_18)
                      , data = DATASET))

# Calculate residuals
residuals <- resid(m_rols)
# Open a new plotting window
#dev.new()
# Generate the Q-Q plot of the residuals
qqnorm(residuals)
qqline(residuals, col = "red")

###
# Output in LaTeX
###
stargazer(m_ols, m_rols, title="Results", align=TRUE, mean.sd = FALSE)

###
# SANITY CHECKS
###

# Calculate residuals
residuals <- resid(m_ols)
# Open a new plotting window
#dev.new()
# Generate the Q-Q plot of the residuals
qqnorm(residuals)
qqline(residuals, col = "red")

# check residuals
opar <- par(mfrow = c(2,2), oma = c(0, 0, 1.1, 0))
plot(m_ols, las = 1)

# Check leverage of data points
# Calculate Cook's Distance
cooks.distance <- cooks.distance(m_ols)
# Plot Cook's Distance
plot(cooks.distance, type="h", main="Cook's Distance")
abline(h=4/length(cooks.distance), col="red")

# Sort Cook's Distance in descending order and get the top 10
top_influential <- order(cooks.distance, decreasing = TRUE)[1:10]
# Print the indices of the top 10 influential observations
print(top_influential)
# If you want to see the Cook's Distance values as well
top_cooks_values <- sort(cooks.distance, decreasing = TRUE)[1:10]
print(top_cooks_values)
# To retrieve the actual observations
DATASET[top_influential, c("n_cit_tot", "n_authors", "n_references_tot", "p_year", "h_index_mean")]

###################################
# ALTERNATIVE models and controls #
###################################

# Compare n_cit_tot with n_cit_1/2/3
DATASET_2020 <- DATASET[(DATASET$p_year<2021),]
DATASET_2021 <- DATASET[(DATASET$p_year<2022),]
DATASET_2022 <- DATASET[(DATASET$p_year<2023),]

summary(m_ols <- lm(n_cit_1_log ~ n_authors_log + n_references_tot_log + p_year + p_month + h_index_mean_log + C(is_plos) + C(is_plos_one) + 
                      C(Data_Shared) + C(Data_Location) + C(Repositories_data_bool) + C(Code_Shared) + C(Code_Location) + C(Preprint_Match) 
                    + C(division_1) + C(division_2) + C(division_3) + C(division_4) + C(division_5) + C(division_6) + C(division_7) + C(division_8) + C(division_9) + C(division_10) + C(division_11) + C(division_12) + C(division_13) + C(division_14) + C(division_15) + C(division_16) + C(division_17) + C(division_18)
                    , data = DATASET_2022)) # change DATASET here
summary(m_rols <- rlm(n_cit_1_log ~ n_authors_log + n_references_tot_log + p_year + p_month + h_index_mean_log + C(is_plos) + C(is_plos_one) + 
                      C(Data_Shared) + C(Data_Location) + C(Repositories_data_bool) + C(Code_Shared) + C(Code_Location) + C(Preprint_Match) 
                    + C(division_1) + C(division_2) + C(division_3) + C(division_4) + C(division_5) + C(division_6) + C(division_7) + C(division_8) + C(division_9) + C(division_10) + C(division_11) + C(division_12) + C(division_13) + C(division_14) + C(division_15) + C(division_16) + C(division_17) + C(division_18)
                    , data = DATASET_2022)) # change DATASET here

# control only on journals with > l publications
l = 1000
j_freq <- as.data.frame(table(DATASET$journal))
j_freq <- j_freq %>%
  rename(journal = Var1) %>%
  filter(Freq > l)
DATASET_L <- merge(x = DATASET, y = j_freq, by = "journal")
summary(m_ols <- lm(n_cit_tot_log ~ n_authors_log + n_references_tot_log + p_year + p_month + h_index_mean_log + C(is_plos) + C(is_plos_one) + 
                      C(Data_Shared) + C(Data_Location) + C(Repositories_data_bool) + C(Code_Shared) + C(Code_Location) + C(Preprint_Match)
                      + C(journal), data = DATASET_L))

# control only on country with > l country
l = 2000
j_freq <- as.data.frame(table(DATASET$Country))
j_freq <- j_freq %>%
  rename(Country = Var1) %>%
  filter(Freq > l)
DATASET_C <- merge(x = DATASET, y = j_freq, by = "Country")
summary(m_ols <- lm(n_cit_tot_log ~ n_authors_log + n_references_tot_log + p_year + p_month + h_index_mean_log + C(is_plos) + C(is_plos_one) + 
                      C(Data_Shared) + C(Data_Location) + C(Repositories_data_bool) + C(Code_Shared) + C(Code_Location) + C(Preprint_Match)
                    + C(Country), data = DATASET_C))

# control only on Preprint_Server with > l Preprint_Server class
l = 500
j_freq <- as.data.frame(table(DATASET$Preprint_Server))
j_freq <- j_freq %>%
  rename(Preprint_Server = Var1) %>%
  filter(Freq > l)
DATASET_PS <- merge(x = DATASET, y = j_freq, by = "Preprint_Server")
summary(m_ols <- lm(n_cit_tot_log ~ n_authors_log + n_references_tot_log + p_year + p_month + h_index_mean_log + C(is_plos) + C(is_plos_one) + 
                      C(Data_Shared) + C(Data_Location) + C(Repositories_data_bool) + C(Code_Shared) + C(Code_Location) + C(Preprint_Match)
                    + C(Preprint_Server), data = DATASET_PS))
summary(m_rols <- rlm(n_cit_tot_log ~ n_authors_log + n_references_tot_log + p_year + p_month + h_index_mean_log + C(is_plos) + C(is_plos_one) + 
                      C(Data_Shared) + C(Data_Location) + C(Repositories_data_bool) + C(Code_Shared) + C(Code_Location) + C(Preprint_Match)
                    + C(Preprint_Server), data = DATASET_PS))

######################
# More models checks #
######################

#########
# ANOVA #
#########

# Base model: 
summary(m_aov <- aov(n_cit_tot_log ~ n_authors_log + n_references_tot_log + p_year + p_month + h_index_mean_log + C(is_plos) + C(is_plos_one) + 
                       C(Data_Shared) + C(Data_Location) + C(Repositories_data_bool) + C(Code_Shared) + C(Code_Location) + C(Preprint_Match) , data = DATASET))
# Full model:
summary(m_aov <- aov(n_cit_tot_log ~ n_authors_log + n_references_tot_log + p_year + p_month + h_index_mean_log + C(is_plos) + C(is_plos_one) + 
                       C(Data_Shared) + C(Data_Location) + C(Repositories_data_bool) + C(Code_Shared) + C(Code_Location) + C(Preprint_Match) 
                     + C(division_1) + C(division_2) + C(division_3) + C(division_4) + C(division_5) + C(division_6) + C(division_7) + C(division_8) + C(division_9) + C(division_10) + C(division_11) + C(division_12) + C(division_13) + C(division_14) + C(division_15) + C(division_16) + C(division_17) + C(division_18)
                     , data = DATASET))

#########
# TOBIT #
#########
# https://stats.idre.ucla.edu/r/dae/tobit-models/
# Also see: http://www.stat.columbia.edu/~madigan/G6101/notes/logisticTobit.pdf 

require(VGAM)

# read
DATASET <- read.csv("dataset/DATASET.csv")

summary(m <- vglm(n_cit_tot_log ~ n_authors_log + n_references_tot_log + p_year + p_month + h_index_mean_log + C(is_plos) + C(is_plos_one) + 
                    C(Data_Shared) + C(Data_Location) + C(Repositories_data_bool) + C(Code_Shared) + C(Code_Location) + C(Preprint_Match), tobit(Lower = 0), data = DATASET))
ctable <- coef(summary(m))
pvals <- 2 * pt(abs(ctable[, "z value"]), df.residual(m), lower.tail = FALSE)
t <- cbind(ctable, pvals)
#t

# significance via loglikelihood ratio test
m2 <- vglm(n_cit_tot_log ~ n_authors_log + n_references_tot_log + p_year + p_month + h_index_mean_log + C(is_plos) + C(is_plos_one) + 
             C(Data_Shared) + C(Data_Location) + C(Repositories_data_bool) + C(Code_Shared) + C(Code_Location) + C(Preprint_Match), tobit(Lower = 0), data = DATASET)
(p <- pchisq(2 * (logLik(m) - logLik(m2)), df = 2, lower.tail = FALSE))

# check residuals
DATASET$yhat <- fitted(m)[,1]
DATASET$rr <- resid(m, type = "response")
DATASET$rp <- resid(m, type = "pearson")[,1]

par(mfcol = c(2, 3))
par(mar=c(4,4,4,4))

with(DATASET, {
  plot(yhat, rr, main = "Fitted vs Residuals")
  qqnorm(rr)
  plot(yhat, rp, main = "Fitted vs Pearson Residuals")
  qqnorm(rp)
  plot(n_cit_tot_log, rp, main = "Actual vs Pearson Residuals")
  plot(n_cit_tot_log, yhat, main = "Actual vs Fitted")
})

# correlation predicted vs data
(r <- with(DATASET, cor(yhat, n_cit_tot_log)))

###################################
# GLM: NEGATIVE BINOMIAL and more #
###################################
# https://stats.idre.ucla.edu/r/dae/zinb/

require(MASS)
require(gamlss)

# read
DATASET <- read.csv("dataset/DATASET.csv")

lapply(DATASET[c("is_plos","is_plos_one","Data_Shared","Data_Location","Repositories_data_bool","Code_Shared","Code_Location","Preprint_Match")], unique)

# standard negative binomial
summary(m_neg <- gamlss(n_cit_tot ~ n_authors + n_references_tot + p_year + p_month + h_index_mean + C(is_plos) + C(is_plos_one) + 
                          C(Data_Shared) + C(Data_Location) + C(Repositories_data_bool) + C(Code_Shared) + C(Code_Location) + C(Preprint_Match), data = na.omit(DATASET), family=NBF()))
# continuous lognormal
summary(m_log <- gamlss(n_cit_tot + 1 ~ n_authors + n_references_tot + p_year + p_month + h_index_mean + C(is_plos) + C(is_plos_one) + 
                          C(Data_Shared) + C(Data_Location) + C(Repositories_data_bool) + C(Code_Shared) + C(Code_Location) + C(Preprint_Match), data = na.omit(DATASET), family=LOGNO()))
# Pareto type 2
summary(m_par <- gamlss(n_cit_tot +1 ~ n_authors + n_references_tot + p_year + p_month + h_index_mean + C(is_plos) + C(is_plos_one) + 
                          C(Data_Shared) + C(Data_Location) + C(Repositories_data_bool) + C(Code_Shared) + C(Code_Location) + C(Preprint_Match), data = na.omit(DATASET), family=PARETO2()))
# zero-inflated negative binomial
summary(m_zero_neg <- gamlss(n_cit_tot ~ n_authors + n_references_tot + p_year + p_month + h_index_mean + C(is_plos) + C(is_plos_one) + 
                               C(Data_Shared) + C(Data_Location) + C(Repositories_data_bool) + C(Code_Shared) + C(Code_Location) + C(Preprint_Match), data = na.omit(DATASET), family=ZINBF()))
