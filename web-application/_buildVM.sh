## e2-small	2vCPUs (25%) + burst 100% (2-3min)	2GB RAM us-west Oregon $12.23 month
## Ubuntu 16.04 LTS

## set user privileges
sudo passwd
******** # set
******** # set
su root
passwd dh_conciani
******** #set
******** # set
gpasswd -a dh_conciani sudo
su dh_conciani

## create swap partition
cd /
sudo dd if=/dev/zero of=swapfile bs=1M count=3000
sudo mkswap swapfile
sudo swapon swapfile
sudo nano etc/fstab
/swapfile none swap sw 0 0
cat /proc/meminfo

## install nginx server
sudo apt-get update
sudo apt-get -y install nginx

## install system dependencies
sudo apt-get update
## libraries
sudo apt-get install libudunits2-dev
## GDAL
sudo add-apt-repository ppa:ubuntugis/ppa
sudo apt-get update
sudo apt-get install gdal-bin
sudo apt-get install libgdal-dev
export CPLUS_INCLUDE_PATH=/usr/include/gdal
export C_INCLUDE_PATH=/usr/include/gdal

## install r-base
sudo bash -c 'echo "deb https://cloud.r-project.org/bin/linux/ubuntu xenial-cran40/" >> /etc/apt/sources.list' && sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && sudo apt update
sudo apt install r-base

## install r packages
sudo su - -c "R -e \"install.packages(c('codetools'))\""
sudo su - -c "R -e \"install.packages(c('shinyjs'))\""
sudo su - -c "R -e \"install.packages(c('lattice'))\""
sudo su - -c "R -e \"install.packages(c('sp'))\""
sudo su - -c "R -e \"install.packages(c('leaflet'))\""
sudo su - -c "R -e \"install.packages(c('leaflet.extras'))\""
sudo su - -c "R -e \"install.packages(c('stringi'))\""
sudo su - -c "R -e \"install.packages(c('sf'))\""
sudo su - -c "R -e \"install.packages(c('rgdal'))\""






## update ubuntu libraries
#sudo apt-get -y install libcurl4-gnutls-dev libxml2-dev libssl-dev
#sudo apt-get update
#sudo apt-get install libudunits2-dev

## install GDAL
#sudo add-apt-repository ppa:ubuntugis/ppa
#sudo apt-get update
#sudo apt-get install gdal-bin

## build python GDAL
#sudo apt-get install libgdal-dev
#export CPLUS_INCLUDE_PATH=/usr/include/gdal
#export C_INCLUDE_PATH=/usr/include/gdal
#pip install GDAL==<GDAL VERSION FROM OGRINFO>

## install r packages
sudo su - -c "R -e \"install.packages(c('shinyjs','leaflet', 'leaflet.extras', 'rgdal', 'stringi', 'sf', 'raster', 'htmlwidgets', 'shiniydashboard', 'ggplot2', 'bsplus'), repos='http://cran.rstudio.com/')\""

## install r studio server
sudo apt-get install gdebi-core
wget https://download2.rstudio.org/rstudio-server-1.1.456-amd64.deb
sudo gdebi rstudio-server-1.1.456-amd64.deb

## install shiny server
sudo su - -c "R -e \"install.packages('shiny', repos='https://cran.rstudio.com/')\""
sudo apt-get install gdebi-core
sudo wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.9.923-amd64.deb
sudo gdebi shiny-server-1.5.9.923-amd64.deb

## server started at 3838 port

