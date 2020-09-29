## set user privileges
sudo passwd
fireland-web
fireland-web
su root
passwd dh_conciani
fireland-web
fireland-web
gpasswd -a dh_conciani sudo
su dh_conciani

## install nginx server
sudo apt-get update
sudo apt-get -y install nginx

## create swap (ubuntu 16.04 lts)
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

## update ubuntu libraries
sudo apt-get -y install libcurl4-gnutls-dev libxml2-dev libssl-dev

## install r packages
sudo su - -c "R -e \"install.packages(c('devtools','rmarkdown', 'quantmod'), repos='http://cran.rstudio.com/')\""
sudo su - -c "R -e \"devtools::install_github("jbkunst/highcharter")\""

## install r studio server
sudo apt-get install gdebi-core
wget https://download2.rstudio.org/rstudio-server-1.1.456-amd64.deb
sudo gdebi rstudio-server-1.1.456-amd64.deb


