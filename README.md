# FMD-brachialtools-analyzer
R script for the analysis of FMD including viscosity and shear stress calculations

The FMD-R Scripts are designed for the automated analysis of FMD and blood viscosity using data from Brachial Tools Software and Labchart

Requires:
 R ([link](https://mirror.rcg.sfu.ca/mirror/CRAN/)) and RStudio ([link](https://posit.co/downloads/)) 
## Creating your project folder

Begin setting up for analysis by creating a project in RStudio (File > New Directory > New Project).
In the new project console, copy and paste the following code:
```R
source("https://github.com/nkcheung95/FMD-Vessel-Analyzer/blob/main/FMD_Vessel_Version.R?raw=TRUE")
```

You should now have a folder labelled "data" nested in the working folder.
Into this folder, you can now drop your working data

## File Preparation

Place the following files into the "data" folder
LC.txt
DIA.csv
## Analyzing Files
Run Script version required using given command

 - FMD-R Vessel no visc
	 - No viscosity model - diameter from VesselApp in labchart
```R
source("https://github.com/nkcheung95/FMD-Vessel-Analyzer/blob/main/FMD_Vessel_Version.R?raw=TRUE")
```

Results immediately available for QC in working directory and saved under participant IDs from the brachial tools output.


