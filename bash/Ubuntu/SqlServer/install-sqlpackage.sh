#!/bin/bash

# This must run as root
# wget and unzip is needed to download sqlpackage tools
echo "Installing dependencies for SqlPackage..."
apt-get update
apt-get -y install wget
apt-get -y install libunwind8
apt-get -y install libicu60
apt-get -y install unzip

echo "Installing SqlPackage..."
wget -O sqlpackage.zip "https://aka.ms/sqlpackage-linux"
mkdir /opt/sqlpackage
unzip sqlpackage.zip -d /opt/sqlpackage 
rm sqlpackage.zip
chmod a+x /opt/sqlpackage/sqlpackage