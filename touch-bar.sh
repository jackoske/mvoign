#!/bin/bash
set -e

echo "Updating system and installing dependencies..."
sudo pacman -Syu --noconfirm git base-devel

echo "Cloning mbp2016-bridge repository..."
git clone https://github.com/mbp2016-linux/mbp2016-bridge.git
cd mbp2016-bridge

echo "Building and installing mbp2016-bridge..."
make
sudo make install

echo "Enabling and starting mbp2016-bridge.service..."
sudo systemctl enable mbp2016-bridge.service
sudo systemctl start mbp2016-bridge.service

cd ..

echo "Cloning mbp2016-touchbar repository..."
git clone https://github.com/mbp2016-linux/mbp2016-touchbar.git
cd mbp2016-touchbar

echo "Building and installing mbp2016-touchbar..."
make
sudo make install

echo "Setup complete!"
echo "You can run the Touch Bar client now with: mbp2016-touchbar"
echo "Consider adding it to your autostart to launch on login."

# Optional: To run the client now automatically:
# mbp2016-touchbar &
