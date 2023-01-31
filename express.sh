#!/bin/bash

########################################################################


#This script will run all the commands one after the other, 
#and after completing the installation of bitcoin related 
#dependencies, it will prompt the user to select which coin 
#they want to clone.

#Please note that, depending on the speed of your internet 
#connection and the performance of your machine, it may take 
#some time for the script to complete all the commands.


# Check if swapfile already exists
if grep -q 'swapfile' /etc/fstab; then
    echo "Swapfile already exists, skipping creation..."
else
    echo "Creating 2GB swapfile..."
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo "Swapfile created and activated!"
    echo "Adding swapfile to /etc/fstab for persistence on reboot..."
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    echo "Swapfile added to /etc/fstab!"
fi


set -e
trap 'echo "Error Occured, Exiting..."' ERR

echo "This script will install dependencies and clone a selected coin. Do you want to proceed? (y/n)"
read -r confirmation
if [[ ! $confirmation =~ ^[Yy]$ ]]; then
    exit 1
fi

echo "Enter your sudo password:"
read -s -r password
echo ""
echo "Updating package lists..."
echo "$password" | sudo -S apt-get update
echo "Package lists updated successfully!"

echo "Installing git..."
echo "$password" | sudo -S apt-get install git
echo "git installed successfully!"

echo "Installing build-essential and other dependencies..."
echo "$password" | sudo -S apt-get install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils
echo "$password" | sudo -S apt-get install -y libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev
echo "$password" | sudo -S apt-get install -y libboost-all-dev
echo "$password" | sudo -S apt-get install -y software-properties-common
echo "Dependencies installed successfully!"

echo "Adding bitcoin repository..."
echo "$password" | sudo -S add-apt-repository -y ppa:bitcoin/bitcoin

echo "Updating package lists..."
echo "$password" | sudo -S apt-get update
echo "Package lists updated successfully!"

echo "Installing bitcoin related dependencies..."
echo "$password" | sudo -S apt-get install -y libdb4.8-dev libdb4.8++-dev
echo "$password" | sudo -S apt-get install -y libminiupnpc-dev
echo "$password" | sudo -S apt-get install -y libzmq3-dev
echo "$password" | sudo -S apt-get install -y libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler
echo "$password" | sudo -S apt-get install -y libqt4-dev libprotobuf-dev protobuf-compiler
echo "Bitcoin related dependencies installed successfully!"

read -p "Please select a coin to clone (1-Sumcoin, 2-Bitcoin, 3-Litecoin): " coin_number
case $coin_number in
"1") git clone -b 0.17 https://github.com/sumcoinlabs/sumcoin.git
    coin_dir="sumcoin";;
"2") git clone -b 0.17 https://github.com/bitcoin/bitcoin.git
    coin_dir="bitcoin";;
"3") git clone -b 0.17 https://github.com/litecoin-project/litecoin.git
    coin_dir="litecoin";;
*) echo "Invalid option selected.";;
esac
read -p "Do you want to configure and build $coin_dir? (y/n): " build_coin
if [ "$build_coin" == "y" ]; then
    cd $coin_dir
    ./autogen.sh
    ./configure --disable-tests
    make
else
    echo "Skipping build process for $coin_dir."
fi
echo "Installation and configuration complete!"
