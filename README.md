# Backup scripts
## For LXC containers with MySQL and Tar.GZ file backup to remote FTP Servers

* Author: [Ryan Fitton](https://ryanfitton.co.uk)
* Last updated: 2021/03/28

## How to Use

1. Ensure you have these packages installed:
	* netcat
	* exim4
	* lftp
	* curl

	```
	sudo apt-get install netcat exim4 lftp curl
	```

2. Set your backup options, mainly for the remote FTP server in `backup-config.sh`

3. Ensure each script is 'pulling in' the `backup-config.sh` file with the right path. Edit this line if your file is not being found:

	```
	source '/backup-config.sh'
	```

4. Run your scripts. Amend the default values for your setup:

	* For LXC Container Snapshots:

		```
		sudo ./backup-container-snapshot.sh 'yourlxdcontainername'
		```
	
	* For MySQL Database dumps:

		```
		sudo ./backup-mysqldump.sh 'yourfilename' 'yourdatabasehost' 'yourdatabaseuser' 'yourdatabasepassword'
		```

	* For Tar.GZ file backups:

		```
		sudo ./backup-tar-files.sh 'yourfilename' '/' '--exclude=/var/snap/lxd --exclude=/snap --exclude=/var/lib/lxd'
		```