#!/bin/bash

# Update the package list
sudo apt update

# Install Nginx (web server) as an example
sudo apt install -y nginx

# Optionally start and enable Nginx service
sudo systemctl start nginx
sudo systemctl enable nginx

# Example: Install Git
sudo apt install -y git

# Optionally, install other software or packages here
# e.g., sudo apt install -y <package-name>

# Verify installations
nginx -v
git --version
