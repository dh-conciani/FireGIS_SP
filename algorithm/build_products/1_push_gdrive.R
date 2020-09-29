## Load Google Drive for R  
library (googledrive)

## Authenticate into Google Drive
drive_auth()

## List Google Drive files
files <- drive_ls("~/BACKUP/LAFirA_versions/5_predicted_size/")

## Download files
for (i in 1:nrow(files)) {
  drive_download(file= as_id(files$id[i]), overwrite=T)
  paste0(print (i/nrow(files)*100), print(" % completed"), print (" at "), print(Sys.time()))
  }