# FMD Vessel Analyzer (WIP)
R script for the analysis of FMD including viscosity and shear stress calculations

The FMD-R Scripts are designed for the automated analysis of FMD and blood viscosity using data from Brachial Tools Software and Labchart

Requires:
 R ([link](https://mirror.rcg.sfu.ca/mirror/CRAN/)) and RStudio ([link](https://posit.co/downloads/)) 
## Creating your project folder


## File Preparation

Place the following files into the "data" folder
LC.txt
DIA.csv
## Analyzing Files
Run Script version required using given command

 - FMD-R Vessel Launcher
	 - No viscosity model - diameter from VesselApp in labchart
```R
source("https://github.com/nkcheung95/FMD-Vessel-Analyzer?raw=TRUE")
```

Results immediately available for QC in working directory and saved under participant IDs from the brachial tools output.


