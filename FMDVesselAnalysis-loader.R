packages <- c(
  "shiny","shinycssloaders","tidyverse", "zoo", "imputeTS","stringr","magick","ggplot2","devtools","bayestestR","curl"
)

# Function to install and load packages
install_load_packages <- function(packages) {
  # Check which packages are not installed
  not_installed <- setdiff(packages, rownames(installed.packages()))
  
  # Install the missing packages
  if (length(not_installed) > 0) {
    install.packages(not_installed)
  }
  
  # Load all the packages
  invisible(sapply(packages, library, character.only = TRUE))
}

# Call the function to install and load packages
install_load_packages(packages)
# Define the GitHub username and repository name
github_username <- "nkcheung95"
repo_name <- "FMD-Vessel-Analyzer"

# Run the Shiny app from GitHub
runGitHub(repo = repo_name, username = github_username)
