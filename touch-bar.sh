#!/bin/bash
set -e

echo "Checking kernel version..."
KERNEL_VERSION=$(uname -r | cut -d'-' -f1)
KERNEL_MAJOR=$(echo $KERNEL_VERSION | cut -d'.' -f1)
KERNEL_MINOR=$(echo $KERNEL_VERSION | cut -d'.' -f2)

if ((KERNEL_MAJOR < 5 || (KERNEL_MAJOR == 5 && KERNEL_MINOR < 3))); then
	echo "ERROR: Kernel version 5.3 or newer required. You have $KERNEL_VERSION."
	echo "Please upgrade your kernel before proceeding."
	exit 1
fi

echo "Loading required kernel modules..."
sudo modprobe spi_pxa2xx_platform
sudo modprobe intel_lpss_pci
sudo modprobe apple_ibridge
sudo modprobe apple_ib_tb
sudo modprobe apple_ib_als

echo "Adding modules to mkinitcpio.conf..."

MKINITCPIO_CONF="/etc/mkinitcpio.conf"

# Backup original config if not already done
if [ ! -f "${MKINITCPIO_CONF}.bak" ]; then
	sudo cp "$MKINITCPIO_CONF" "${MKINITCPIO_CONF}.bak"
	echo "Backup of mkinitcpio.conf created at ${MKINITCPIO_CONF}.bak"
fi

# Add modules if not present
for module in apple_ibridge apple_ib_tb apple_ib_als spi_pxa2xx_platform intel_lpss_pci; do
	if ! grep -q "$module" "$MKINITCPIO_CONF"; then
		sudo sed -i "/^MODULES=/ s/)/ $module)/" "$MKINITCPIO_CONF"
		echo "Added $module to MODULES in mkinitcpio.conf"
	else
		echo "$module already present in mkinitcpio.conf"
	fi
done

echo "Rebuilding initramfs images..."
sudo mkinitcpio -P

echo "Done. Please reboot your system."

echo ""
echo "After reboot, you can check if modules loaded with:"
echo "  lsmod | grep apple_ib"
echo ""
echo "Optional: Adjust Touch Bar timeout values with these commands:"
echo "  echo 300 | sudo tee /sys/class/input/input*/device/idle_timeout"
echo "  echo 270 | sudo tee /sys/class/input/input*/device/dim_timeout"
