#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi
##Working directories
gitdir=$PWD
logfile=/var/log/rdp_install.log
mkfifo ${logfile}.pipe
tee < ${logfile}.pipe $logfile &
exec &> ${logfile}.pipe
rm ${logfile}.pipe
 
##Colors!!
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

##Functions!!
function print_status ()
{
    echo -e "\x1B[01;34m[*]\x1B[0m $1"
}

function print_good ()
{
    echo -e "\x1B[01;32m[*]\x1B[0m $1"
}

function print_error ()
{
    echo -e "\x1B[01;31m[*]\x1B[0m $1"
}

function print_notification ()
{
	echo -e "\x1B[01;33m[*]\x1B[0m $1"
}

function error_check
{

if [ $? -eq 0 ]; then
	print_good "$1 successfully completed."
else
	print_error "$1 failed. Please check $logfile for more details."
exit 1
fi

}
export DEBIAN_FRONTEND=noninteractive

##Begin scripting
print_status "Updating and installing packages"
apt-get update -y &>> $logfile
error_check 'Updated'
apt-get upgrade -y &>> $logfile
error_check 'Upgraded'
apt-get autoclean -y &>> $logfile
error_check 'Cleaned'

print_status "Downloading TigerVNC"
wget https://bintray.com/tigervnc/stable/download_file?file_path=tigervnc-Linux-x86_64-1.6.0.tar.gz &>> $logfile
error_check 'Tiger Download'
print_status "Installing TigerVNC"
dpkg -i tigervncserver_1.6.80-4_amd64.deb &>> $logfile
apt-get install -f &>> $logfile
error_check 'Tiger Install'

print_status "Installing xrdp"
apt-get install xrdp -y &>> $logfile
error_check 'XRDP Install'

echo unity>~/.xsession

# Set keyboard layout in xrdp sessions 
cd /etc/xrdp 
test=$(setxkbmap -query | awk -F":" '/layout/ {print $2}') 
echo "your current keyboard layout is.." $test
setxkbmap -layout $test 
sudo cp /etc/xrdp/km-0409.ini /etc/xrdp/km-0409.ini.bak 
sudo xrdp-genkeymap km-0409.ini

print_status "Finished"
