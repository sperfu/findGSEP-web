# findGSEP-web
web server of findGSEP


# Shiny Project Setup Guide

## Prerequisites

1. Install Miniconda or Anaconda
2. Install R (Recommended version 4.2.0) and R packages
3. Install necessary Python packages

## Step 1: Install Miniconda

If you haven't installed Miniconda yet, follow these steps:

```bash
# Download Miniconda installation script
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

# Run the installation script
bash Miniconda3-latest-Linux-x86_64.sh

# Follow the prompts to complete the installation
```

## Step 2: Create a Python Virtual Environment

Create a new Python virtual environment using Miniconda:

```bash
# Create a virtual environment named python38
conda create -n python38 python=3.8

# Activate the virtual environment
conda activate python38
```

## Step 3: Install R and R Packages

Install R and the required R packages within the virtual environment:

```bash
# Install R version 4.2.0
conda install -c conda-forge r-base=4.2.0

# Install required R packages
conda install -c r r-scales r-pracma r-fgarch r-png r-dplyr r-ggplot2 r-rcolorbrewer
```

## Step 4: Configure R Environment Variables (Optional)

Set the virtual environment and R package paths in the `prepare_findGSE_server_0521.R` file(Right now it is set as default):

```r
# Set the path to the virtual environment
conda_env_path <- "/home/shiny/miniconda3/envs/python38"

# Set the path to the R executable
rscript_path <- file.path(conda_env_path, "bin", "Rscript")

# Set the path to the R packages
package_path <- file.path(conda_env_path, "lib", "R", "library")

# Set the names of the packages to load
packages <- c("scales", "pracma", "fGarch", "png", "dplyr", "RColorBrewer")

# Load the packages
invisible(sapply(packages, function(p) {
  library(p, lib.loc = package_path, character.only = TRUE)
}))
```

## Step 5: Set Up the Shiny Project (Optional)

In your Shiny project file, ensure that you load all the necessary packages and set the correct environment variables:

```r
library(shiny)
library(shinyjs)
library(shinyBS)
library(DT)
library(ggplot2)
library(stringr)
library(seqinr)
library(shinycssloaders)

# Set the path to the virtual environment
conda_env_path <- "/home/shiny/miniconda3/envs/python38"

# Set the path to the R executable
rscript_path <- file.path(conda_env_path, "bin", "Rscript")

# Set the path to the R packages
package_path <- file.path(conda_env_path, "lib", "R", "library")

# Set the names of the packages to load
packages <- c("scales", "pracma", "fGarch", "png", "dplyr", "RColorBrewer")

# Load the packages
invisible(sapply(packages, function(p) {
  library(p, lib.loc = package_path, character.only = TRUE)
}))

source('findGSE_v1.95_new.R')
source('utils.R')
library(scales)
library(png)
library(dplyr)
library(RColorBrewer)
library(ggplot2)
```

## Step 6: Run the Shiny Application

Navigate to your Shiny project folder in the terminal and run the Shiny application:

```bash
# Navigate to the Shiny project folder
cd your_proj_folder

# Run the Shiny application
Rscript -e "shiny::runApp()"
```

