### LIBLOAD
# Define the packages you want to use
packages <- c(
  "tidyverse", "zoo", "imputeTS", "stringr", "magick", 
  "ggplot2", "devtools", "bayestestR", "curl", "tcltk","fs"
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


#filesystem_create

folder2 <- "Master FMD Export"

if (file.exists(folder2)) {
  
  cat("The folder already exists")
  
} else {
  
  dir.create(folder2)
  
}
folder4 <- "Master QC Plots"
if (file.exists(folder4)) {
  
  cat("The folder already exists")
  
} else {
  
  dir.create(folder4)
  
}
directory <- tclvalue(tkchooseDirectory())
dia_file <- file.path(directory,"DIA.csv")
lc_file <- file.path(directory,"LC.txt")
#dataload labchart files downsample by 333 to match DIA, blockheaderON, Time selected as true
dia_data <- read.delim(dia_file, header=F,sep=",", skip=49)
dia_data <- rename(dia_data, "diameter_raw"= "V2", "index"="V1", "participant_id"="V7","diameter"="V6")
lc_data <- read.delim(lc_file, header=F, sep="\t",skip=9)
#visco_data <- read.csv("data/VISC.csv", header=F,skip=45)
dia_data <- subset(dia_data, select = c("diameter","index","participant_id"))
#file_id
file.id<- as.character(dia_data[1,3])
file.id <- str_replace_all(string=file.id, pattern=".txt", repl="")
participant.id <- as.character(dia_data[1,3])
participant.id <- str_replace_all(string=file.id, pattern=".txt", repl="")

fmd_length <- min(nrow(dia_data),nrow(lc_data))
fmd_data <- cbind(head(dia_data,fmd_length),head(lc_data,fmd_length))
fmd_data <- rename(fmd_data,"time"="V1","flow_vel"="V2","fing_pres"="V3")


bl_data <- fmd_data[50:550, ]
fmd_data <- tail(fmd_data,1800)

#visco_data <-cbind(visco_data$V8,visco_data$V4)
#visco_data <- as.data.frame(visco_data)
#visco_data <- rename(visco_data, "visc_sr"="V1", "visc_visc"="V2")



#output folders
folder3 <- "results"

if (file.exists(file.path(getwd(),"Analyzed",participant.id,file.id,folder3), recursive = TRUE)) {
  
  cat("The folder already exists")
  
} else {
  
  dir.create(file.path(getwd(),"Analyzed",participant.id,file.id,"results"), recursive = T)
  dir.create(file.path(getwd(),"Analyzed",participant.id,file.id,"plots"), recursive = T)
  dir.create(file.path(getwd(),"Analyzed",participant.id,file.id,"data"), recursive = T)
}


#smooth
fill_dia <- na_interpolation(fmd_data$diameter)
smo_index <- seq(1, 1800, by = 1) 
smo_dia <- rollmean(fill_dia, k = 30, fill = NA)
smo_Qvel <- rollmean(fmd_data$flow_vel, k=30, fill= NA)
smo_fing_pres <- rollmean(fmd_data$fing_pres, k=30, fill= NA)
smo_fmd <- cbind(smo_dia,smo_fing_pres,smo_Qvel,smo_index)
smo_fmd <- as.data.frame(smo_fmd)
fmd_clean <- as.data.frame(smo_fmd)

fmd_clean <- rename(fmd_clean,"diameter"="smo_dia","flow_vel"="smo_Qvel","fing_pres"="smo_fing_pres","index"="smo_index")
fmd_clean$index <- fmd_clean$index/10
#variablecreate



#fmd
fmd_clean$shear_rate <- 8*(fmd_clean$flow_vel/fmd_clean$diameter)
fmd_clean$bulk_flow <- fmd_clean$flow_vel*(pi*((fmd_clean$diameter/20)^2))*60
fmd_clean$fvc <- fmd_clean$bulk_flow/fmd_clean$fing_pres

#bl
bl_data$shear_rate <- 8*(bl_data$flow_vel/bl_data$diameter)
bl_data$bulk_flow <- bl_data$flow_vel*(pi*((bl_data$diameter/20)^2))*60
bl_data$fvc <- bl_data$bulk_flow/bl_data$fing_pres


#SS AUC
max_dia_row <-  which.max(fmd_clean$diameter)
max_row_num <- which(row.names(fmd_clean) == max_dia_row)
auc_df <- cbind.data.frame(head(fmd_clean$shear_rate,max_row_num),head(fmd_clean$index,max_row_num))
auc_df <- rename(auc_df,"shearrate"="head(fmd_clean$shear_rate, max_row_num)","index"="head(fmd_clean$index, max_row_num)")
auc_df$time <- auc_df$index
auc_df[is.na(auc_df)] <- 0
auc_ss <- area_under_curve(auc_df$time, auc_df$shearrate, method = "trapezoid")

#outcomes
bl_diameter <- mean(bl_data$diameter,na.rm=TRUE)
bl_fvc <- mean(bl_data$fvc,na.rm=TRUE)
bl_flow <- mean(bl_data$bulk_flow,na.rm=TRUE)
bl_sr <- mean(bl_data$shear_rate,na.rm=TRUE)


peak_diameter <- max(fmd_clean$diameter,na.rm=TRUE)
peak_fvc <- max(fmd_clean$fvc,na.rm=TRUE)
peak_flow <- max(fmd_clean$bulk_flow,na.rm=TRUE)
peak_sr <- max(fmd_clean$shear_rate,na.rm=TRUE)


delta_fvc <- peak_fvc-bl_fvc
delta_flow <- peak_flow-bl_flow

fmd_mm <- peak_diameter-bl_diameter
fmd_per <- fmd_mm/bl_diameter*100
fmd_mm_ss <- fmd_mm/auc_ss
fmd_per_ss <- fmd_per/auc_ss

time_to_peak <- max(auc_df$time)
#RESULTS
results <- cbind.data.frame(file.id,bl_diameter, bl_fvc, bl_flow, bl_sr,peak_diameter, peak_fvc, peak_flow, peak_sr, fmd_mm,fmd_per,fmd_mm_ss,fmd_per_ss,time_to_peak)
#plotsFMD
dir.create("plots")
png("plots/DIA_BL.png")
plot(bl_data$index,bl_data$diameter,xlab=paste(file.id,"index"),ylab="diameterBL",col = "#2E9FDF",pch=16)
dev.off()
png("plots/SR_BL.png")
plot(bl_data$index,bl_data$shear_rate,xlab=paste(file.id,"index"),ylab="shear rateBL",col = "#2E9FDF",pch=16)
dev.off()
png("plots/FV_BL.png")
plot(bl_data$index,bl_data$flow_vel,xlab=paste(file.id,"index"),ylab="flow velocityBL",col = "#2E9FDF",pch=16)
dev.off()


png("plots/DIA_PO.png")
plot(fmd_clean$index,fmd_clean$diameter,xlab=paste(file.id,"index"),ylab="diameterPO",col = "#FF5733",pch=16)
dev.off()
png("plots/SR_PO.png")
plot(fmd_clean$index,fmd_clean$shear_rate,xlab=paste(file.id,"index"),ylab="shear ratePO",col = "#FF5733",pch=16)
dev.off()
png("plots/FV_PO.png")
plot(fmd_clean$index,fmd_clean$flow_vel,xlab=paste(file.id,"index"),ylab="flow velocityPO",col = "#FF5733",pch=16)
dev.off()

#combine and report
# Load the six images into R using the png package
img1 <- image_read("plots/DIA_BL.png")
img2 <- image_read("plots/SR_BL.png")
img3 <- image_read("plots/FV_BL.png")

img5 <- image_read("plots/DIA_PO.png")
img6 <- image_read("plots/SR_PO.png")
img7 <- image_read("plots/FV_PO.png")


# Combine the images into a single image
combined_img1 <- image_append(c(img1, img2, img3), stack = FALSE)
combined_img2 <- image_append(c(img5, img6, img7), stack = FALSE)
combined_img <- image_append(c(combined_img1,combined_img2), stack=TRUE)
# Save the combined image as a PNG file
image_write(combined_img, "QCPlots.png")
image_write(combined_img, file.path(getwd(),"Analyzed",participant.id,file.id,"plots","QCPlots.png"))
image_write(combined_img, file.path(getwd(),folder4,paste0(file.id,".png")))

#raw_data_output
if (file.exists(file.path(getwd(),"Analyzed",participant.id,file.id,"data","BL_DIA.txt")) )
{
  
  cat("The folder already exists")
  
} else {
  data_files <- list.files(directory)
  file_copy(file.path(directory,data_files),file.path(getwd(),"Analyzed",participant.id,file.id,"data"),data_files)
}

#results_print csv
write.csv(results,file.path(getwd(),"Analyzed",participant.id,file.id,"results","FMD_results.csv"), row.names=FALSE)
write.csv(bl_data,file.path(getwd(),"Analyzed",participant.id,file.id,"results","BL_data_clean.csv"), row.names=FALSE)
write.csv(fmd_clean,file.path(getwd(),"Analyzed",participant.id,file.id,"results","PO_data_clean.csv"), row.names=FALSE)



if (file.exists("Master FMD Export/MASTER_FMD_DATA.csv") ){
  
  write.table( results,  
               file="Master FMD Export/MASTER_FMD_DATA.csv", 
               append = T, 
               sep=',', 
               row.names=F, 
               col.names=F )
  
  
} else {
  write.table( results,  
               file="Master FMD Export/MASTER_FMD_DATA.csv", 
               append = T, 
               sep=',', 
               row.names=F, 
               col.names=T )
}

print(paste("FMD Analyzed for ",file.id)
