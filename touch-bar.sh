#!/bin/bash
set -e

echo "Installing dependencies..."
sudo pacman -Syu --noconfirm git base-devel linux-headers dkms

echo "Cloning macbook12-spi-driver repo..."
git clone https://github.com/PatrickVerner/macbook12-spi-driver.git
cd macbook12-spi-driver

echo "Installing module with DKMS..."
sudo ./install.sh

echo "Loading apple-ib-tb module..."
sudo modprobe apple_ib_tb

echo "Touch Bar basic support should now be active."

echo "You can check with: lsmod | grep apple_ib_tb"
