#!/bin/bash

# Prompt user if they want to use the default directory for shared folder
read -p "Do you want to use the default directory for the shared folder? (Y/N): " use_default_directory

if [[ $use_default_directory =~ ^[Yy]$ ]]; then
    # Use default directory (create "shared" folder in user's home directory)
    shared_folder_path="$HOME/shared"
else
    # Prompt user for shared folder path
    read -p "Enter the path to the shared folder: " shared_folder_path
fi

# Prompt user for Samba username
read -p "Enter your Samba username: " samba_username

# Prompt user for Samba password
read -sp "Enter your Samba password: " samba_password
echo

# Update and install Samba
sudo apt update -y
sudo apt upgrade -y
sudo apt install samba -y

# Configure Samba
sudo nano /etc/samba/smb.conf << EOF
[shared]
path = $shared_folder_path
read only = no
guest ok = yes
EOF

# Add user to Samba
sudo smbpasswd -a $samba_username

# Restart Samba
sudo systemctl restart smbd

# Create shared folder structure
mkdir -p "$shared_folder_path/media/films"
mkdir -p "$shared_folder_path/media/tv shows"

# Install Plex Media Server
wget https://downloads.plex.tv/plex-media-server-new/1.32.8.7639-fb6452ebf/debian/plexmediaserver_1.32.8.7639-fb6452ebf_amd64.deb
sudo dpkg -i plexmediaserver_1.32.8.7639-fb6452ebf_amd64.deb
sudo systemctl start plexmediaserver
sudo systemctl enable plexmediaserver

# Fix ownership issues with the shared directory
sudo chmod -R 755 "$shared_folder_path"
sudo systemctl restart plexmediaserver

echo "Setup completed successfully!"
