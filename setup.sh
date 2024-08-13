#!/data/data/com.termux/files/usr/bin/bash
# prepration setup

# Install necessary packages
pkg install git wget proot -y

# Clone the GitHub repository
git clone https://github.com/opiran-club/root-termux.git

# Change to the cloned directory and make scripts executable
cd root-termux || { echo "Failed to change directory to root-termux"; exit 1; }
chmod +x *

# Run the linux.sh script
yes | bash linux.sh
