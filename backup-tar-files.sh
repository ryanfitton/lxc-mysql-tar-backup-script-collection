#!/bin/bash

## Usage: backup-tar-files.sh
##
## Make the script executable:
##   chmod +x backup-tar-files.sh
##
## Pass arguments to the script:
##   1: Name - What folder will be created for the file
##   2: Files to include within the backup.
##   3: Files/directories to exclude, by default this backup file will always be excluded.
##
## Run using:
##   sudo ./backup-tar-files.sh 'yourfilename' '/' '--exclude=/var/snap/lxd --exclude=/snap --exclude=/var/lib/lxd'
##
## Notes: '/' = Backup entire server.
##
## Required software libaries:
##   'netcat'           Used for checking if a connection can be made to the FTP server
##   'exim4'            Used for sending email using the 'mail' command
##   'lftp'             Used for sending files using via the 'lftp' command. Allows paths to be created at multi-levels
##   'curl'             Used for check if the file exists on the FTP server via the 'curl' command


# FTP Connection details
source '/backup-config.sh'   # Include the backup config file

# Backup options
NAME="$1"                   # The Server Name - Used to categorize backups on the FTP server
BACKUP_FILES="$2"           # Files to include within the backup.
EXCLUDE_FILES="$3"          # Files/directories to exclude, by default this backup file will always be excluded.

# Create the save path
FTP_SAVEPATH="$GLOBAL_REMOTE_FTP_LOCATION/$NAME/tar.gz"     # The path for where the .tar.gz file should be uploaded on the FTP server.



# -------------------- Nothing to change after this point --------------------

# Clear terminal window
clear

# Welcome/Start message
echo "****************************************"
echo "File Tar.Gz Backup script"
echo "Created for Ubuntu operating systems"
echo "Author: Ryan Fitton (ryanfitton.co.uk)"
echo "Version 3.0.0"
echo "****************************************"

printf "\n"

echo "Starting in 5 seconds."
echo "..."
printf "\n"
sleep 5s # Wait 5 seconds


# Check if the required arguments are not empty
if [ "$1" != '' ] || [ "$2" != '' ] || [ "$3" != '' ];

# If none of these arguments are empty, the script can proceed
then

    # Check to see if the 'netcat' program is installed
    # Used for checking if a connection can be made to the FTP server
    PACKAGE='netcat'
    if dpkg -s $PACKAGE 2>/dev/null >/dev/null;

    # If 'netcat' is installed
    then

        # Checking to see if the Mail package is installed on your system
        # Used for sending email confirmations of the backup process
        PACKAGE='exim4'     # Sometimes mail package is 'exim4mailtuils'
        echo "Checking to see if '$PACKAGE' is installed on your system."
        printf "\n"

        if dpkg -s $PACKAGE 2>/dev/null >/dev/null

        # If success
        then
            echo "The '$PACKAGE' package is already installed on your system. You will recieve email updates for this backup."
            echo "..."
            printf "\n"


            # Find the hostname
            HOSTNAME=$(hostname --long)

            # Filename variables setup
            NOW=$(date +"%Y-%m-%d-%H%M")                                # Timestamp
            FILENAME="$NAME-tar-backup-$HOSTNAME-$NOW.tar.gz"    # Filename (server_name.tar-backup.hostname.timestamp)

            echo "The .tar.gz backup filename will be: $FILENAME"
            echo "Stored temporarily within: $GLOBAL_BACKUP_TEMP_SAVEPATH"
            echo "Uploaded to the FTP server at: $FTP_SAVEPATH"
            echo "Full temporary savepath: $GLOBAL_BACKUP_TEMP_SAVEPATH/$FILENAME"
            echo "Full FTP savepath: $FTP_SAVEPATH/$FILENAME"
            printf "\n"
            sleep 5s # Wait 5 seconds


            # Start tar.gz backup process
            echo "Starting .tar.gz backup process."
            tar -cvpzf $GLOBAL_BACKUP_TEMP_SAVEPATH/$FILENAME --exclude=$GLOBAL_BACKUP_TEMP_SAVEPATH/$FILENAME $EXCLUDE_FILES --one-file-system $BACKUP_FILES
            echo ".tar.gz backup process has finished."
            echo "..."
            printf "\n"


            # Verify tar.gz file has been created
            echo "Verifying $FILENAME file has been created."
            printf "\n"

            if [ -f $GLOBAL_BACKUP_TEMP_SAVEPATH/$FILENAME ]

            # If success
            then

                echo "File exists on the local server."
                printf "\n"


                # Check to see if the 'lftp' program is installed
                # Used for sending files using via the 'ftp' command
                PACKAGE='lftp'
                if dpkg -s $PACKAGE 2>/dev/null >/dev/null;

                # If success
                then

                    # Check if a connection can be made to the FTP Server address and port using 'netcat'
                    if nc -z -v -w5 $FTP_SERVER $FTP_PORT;

                    # If success
                    then

                        # Start FTP transfer. Syntax: http://manpages.ubuntu.com/manpages/zesty/man1/tnftp.1.html
                        echo "FTP transfer process will begin in in 30 seconds."
                        echo "Press 'ctrl + c' now to cancel and keep the local backup only, otherwise wait for the FTP transfer process to begin."
                        echo "..."
                        printf "\n"

                        sleep 30s # Wait 30 seconds

                        # Start FTP transfer process. Syntax: https://linux.die.net/man/1/lftp
                        echo "Starting FTP transfer process."

# Indents are removed as they cause issues with the 'END_SCRIPT' tag
# 1. Change directory on the local server
# 2. Create directory on the FTP server
# 3. Change to the newly created directory
# 4. Upload file from local server to FTP server
lftp ftp://$FTP_USERNAME:$FTP_PASSWORD@$FTP_SERVER:$FTP_PORT <<END_SCRIPT
lcd "$GLOBAL_BACKUP_TEMP_SAVEPATH"
mkdir -p "$FTP_SAVEPATH"
cd "$FTP_SAVEPATH"
put "$FILENAME"
END_SCRIPT

                        echo "FTP transfer process has finished."
                        printf "\n"


                        # Check to see if the 'curl' program is installed
                        # Used for check if the file exists on the FTP server via the 'curl' command
                        PACKAGE='curl'
                        if dpkg -s $PACKAGE 2>/dev/null >/dev/null;

                        # If success
                        then

                            # Verify the file exists on the FTP server
                            echo "FTP transfer verification will begin in 30 seconds."
                            echo "..."
                            printf "\n"

                            sleep 30s # Wait 30 seconds

                            # If the file can be found using Curl on the FTP server
                            if curl --output /dev/null --silent --head --fail $CURL_FTP_ARGUMENTS "ftp://$FTP_USERNAME:$FTP_PASSWORD@$FTP_SERVER:$FTP_PORT/$FTP_SAVEPATH/$FILENAME"

                            # If success
                            then

                                echo "File exists on the FTP server."
                                echo "..."
                                printf "\n"

                                # Remove tar.gz file from the local server
                                echo "Now removing $FILENAME from the local server."
                                rm $GLOBAL_BACKUP_TEMP_SAVEPATH/$FILENAME
                                echo "Finished removing file."
                                echo "..."
                                printf "\n"


                                # Verify tar.gz file has been removed from the local server
                                echo "Verifying $FILENAME has been removed from the local server."
                                echo "..."
                                printf "\n"

                                if [ -f $GLOBAL_BACKUP_TEMP_SAVEPATH/$FILENAME ]

                                    # If success
                                    then
                                        echo "File still exists on the local server."
                                        echo "Backup has failed."
                                        printf "\n"

                                        # Send an email explaining this failure
                                        echo "An email will be sent to $GLOBAL_EMAIL_TO"
                                        echo "$FILENAME was supposed to removed, but still exists on the local server." | mail -s "Failure: $HOSTNAME Backup to FTP server" $GLOBAL_EMAIL_TO

                                        exit 1 # Exit with general error


                                # If failure
                                else
                                    echo "Backup has finished successfully."
                                    printf "\n"

                                    # Send an email explaing a successful backup
                                    echo "An email will be sent to $GLOBAL_EMAIL_TO"
                                    echo "Backup has finished successfully. $FILENAME has been created on the FTP server ($FTP_SERVER)." | mail -s "Success: $HOSTNAME Backup to FTP server" $GLOBAL_EMAIL_TO

                                    exit 0 # Successful exit

                                fi


                            # If failure
                            else
                                echo "File does not exist on the FTP server."
                                echo "Backup has failed."
                                printf "\n"

                                # Send an email explaining this failure
                                echo "An email will be sent to $GLOBAL_EMAIL_TO"
                                echo "$FILENAME does not exist on the FTP server. The .tar.gz file has been kept on the local server - consider moving this file to the FTP server manually." | mail -s "Failure: $HOSTNAME Backup to FTP server" $GLOBAL_EMAIL_TO

                                exit 1 # Exit with general error
                            fi


                        # If failure
                        else
                            echo "The '$PACKAGE' package is not installed on your system."
                            echo "Install by running: 'sudo apt-get install $PACKAGE'"

                            exit 1 # Exit with general error
                        fi


                    # If failure
                    else
                        echo "Could not connect to '$FTP_SERVER' on port '$FTP_PORT'."

                        exit 1 # Exit with general error
                    fi


                # If failure
                else
                    echo "The '$PACKAGE' package is not installed on your system."
                    echo "Install by running: 'sudo apt-get install $PACKAGE'"

                    exit 1 # Exit with general error
                fi


            # If failure
            else
                echo "File does not exist on the local server."
                echo "Backup has failed."
                printf "\n"

                # Send an email explaining this failure
                echo "An email will be sent to $GLOBAL_EMAIL_TO"
                echo "Creating $FILENAME on local server failed." | mail -s "Failure: $HOSTNAME Backup to FTP server" $GLOBAL_EMAIL_TO

                exit 1 # Exit with general error

            fi


        # If failure
        else
            echo "The '$PACKAGE' package is not installed on your system."
            echo "Backup has failed."
            printf "\n"

            echo "Install by running: 'apt-get install $PACKAGE'"

            exit 1 # Exit with general error

        fi


    # If failure
    else
        echo "The '$PACKAGE' package is not installed on your system."
        echo "Install by running: 'sudo apt-get install $PACKAGE'"

        exit 1 # Exit with general error
    fi
  
  
# If one or more arguments are empty, produce an error
else
    echo "One or more arguments are empty."

    exit 1 # Exit with general error
fi


