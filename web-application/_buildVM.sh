## e2-micro	2	1GB	$9.71 month
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

## install nginx server
sudo apt-get update
sudo apt-get -y install nginx

## create 3GB swap (ubuntu 16.04 lts)
cd /
sudo dd if=/dev/zero of=swapfile bs=1M count=3000
sudo mkswap swapfile
sudo swapon swapfile
sudo nano etc/fstab
/swapfile none swap sw 0 0 ^X
cat /proc/meminfo

## install r 
sudo sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/" >> /etc/apt/sources.list'
gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
gpg -a --export E084DAB9 | sudo apt-key add -
sudo apt-get update
sudo apt-get -y install r-base

## update r base
sudo su
echo "deb http://www.stats.bris.ac.uk/R/bin/linux/ubuntu precise/" >> /etc/apt/sources.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
apt-get update
apt-get upgrade

## update ubuntu libraries
sudo apt-get -y install libcurl4-gnutls-dev libxml2-dev libssl-dev

## install r packages
sudo su - -c "R -e \"install.packages(c('devtools','rmarkdown', 'quantmod'), repos='http://cran.rstudio.com/')\""
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

