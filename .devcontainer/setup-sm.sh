#!/bin/bash
set -e

echo "🔹 Detecting OS and architecture for AWS Session Manager Plugin installation..."

# Detect OS
OS_ID=$(grep '^ID=' /etc/os-release | cut -d '=' -f2 | tr -d '"')

# Detect CPU Architecture
ARCH=$(dpkg --print-architecture)

# Set AWS Session Manager Plugin URL based on architecture
if [ "$ARCH" == "arm64" ]; then
    PLUGIN_URL="https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_arm64/session-manager-plugin.deb"
else
    PLUGIN_URL="https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_amd64/session-manager-plugin.deb"
fi

if [ "$OS_ID" == "ubuntu" ] || [ "$OS_ID" == "debian" ]; then
    echo "🔹 Installing AWS Session Manager Plugin for Ubuntu/Debian ($ARCH)..."
    curl -fsSL "$PLUGIN_URL" -o session-manager-plugin.deb
    sudo dpkg -i session-manager-plugin.deb

    echo "🔹 Removing session-manager-plugin..."
    rm session-manager-plugin.deb
elif [ "$OS_ID" == "amazon" ] || [ "$OS_ID" == "rhel" ] || [ "$OS_ID" == "centos" ]; then
    echo "🔹 Installing AWS Session Manager Plugin for Amazon Linux/RHEL/CentOS..."
    curl -fsSL "https://s3.amazonaws.com/session-manager-downloads/latest/linux_arm64/session-manager-plugin.rpm" -o session-manager-plugin.rpm

    echo "🔹 Removing session-manager-plugin..."
    sudo yum install -y session-manager-plugin.rpm
else
    echo "⚠️ OS not supported. Please install the plugin manually."
    exit 1
fi

# Verify installation
echo "🔹 Checking session-manager-plugin version..."
session-manager-plugin --version
