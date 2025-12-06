library(shiny)
library(ggplot2)

wine_data <- read.csv("winequality-white.csv", sep = ";")

vars <- setdiff(names(wine_data), "quality")

var_display_names <- c(
  "Fixed Acidity" = "fixed.acidity",
  "Volatile Acidity" = "volatile.acidity",
  "Citric Acid" = "citric.acid",
  "Residual Sugar" = "residual.sugar",
  "Chlorides" = "chlorides",
  "Free Sulfur Dioxide" = "free.sulfur.dioxide",
  "Total Sulfur Dioxide" = "total.sulfur.dioxide",
  "Density" = "density",
  "pH" = "pH",
  "Sulphates" = "sulphates",
  "Alcohol" = "alcohol"
)

var_choices <- var_display_names[var_display_names %in% vars]

regressionChoices <- c("Simple Linear Regression" = "lm_simple",
                       "Multiple Linear Regression" = "lm_multiple")
