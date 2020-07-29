#!/bin/bash

## ****************************************
## Backup scripts Configuration
## Created for Ubuntu operating systems
## Author: Ryan Fitton (ryanfitton.co.uk)
## Version 3.0.0
## ****************************************
##
## Usage: backup-config.sh
##
## Make the scripts executable:
##   chmod +x backup-config.sh
##   chmod +x backup-tar-files.sh
##   chmod +x backup-container-snapshot.sh
##   chmod +x backup-mysqldump.sh
##
## Run these scripts using:
##   sudo ./backup-tar-files.sh 'yourfilename' '/' '--exclude=/var/snap/lxd --exclude=/snap --exclude=/var/lib/lxd'
##   sudo ./backup-container-snapshot.sh 'yourlxdcontainername'
##   sudo ./backup-mysqldump.sh 'yourfilename' 'yourdatabasehost' 'yourdatabaseuser' 'yourdatabasepassword'
##
## Or setup as Cron Jobs:
##   1 0 * * * ./backup-tar-files.sh 'yourfilename' '/' '--exclude=/var/snap/lxd --exclude=/snap --exclude=/var/lib/lxd'
##   1 0 * * * ./backup-container-snapshot.sh 'yourlxdcontainername'
##   1 0 * * * ./backup-mysqldump.sh 'yourfilename' 'yourdatabasehost' 'yourdatabaseuser' 'yourdatabasepassword'
##
## Required software libaries:
##   'netcat'           Used for checking if a connection can be made to the FTP server
##   'exim4'            Used for sending email using the 'mail' command
##   'lftp'             Used for sending files using via the 'lftp' command. Allows paths to be created at multi-levels
##   'curl'             Used for check if the file exists on the FTP server via the 'curl' command


# Temporary backup location on the server. File will be kept here until FTP transfer is completed.
GLOBAL_BACKUP_TEMP_SAVEPATH='/tmp'

# The backup location which the scripts will use. Each script will create it's own folder within this location.
GLOBAL_REMOTE_FTP_LOCATION='/'

# Email address for notification of backups status
GLOBAL_EMAIL_TO='youremail@example.com'

# FTP remote server connection details
FTP_SERVER='yourftpserver.example.com'
FTP_USERNAME='yourftpusername'
FTP_PASSWORD='yourftppassword'
FTP_PORT=21
FTP_ARGUMENTS='-np'                     # Notes: '-n' = Do not attempt to autologin. '-p' = Enable passive mode.
CURL_FTP_ARGUMENTS='--ftp-pasv'         # Curl is used to verify the FTP upload. Notes: '' = Enable passive mode.
