# windowsRDP-FTP-SSH-tunnel-script

These scripts are to be used to open an SSH connection and create an SSH tunnel for Windows RDP and/or FTP, the script can be edited by editing the connect.ps1 file.

it will also install all dependencies on the first run

## Setup

### Step 1 - Put the Required files in the folder

rename your private key file to ``key`` and put it in the folder

create a ``connection.rdp`` file in the folder, for the server and user you would like to connect to if you want the script to open the RDP for you.

### Step 2 - Edit config.env

Open the config.env file in your preferred editor E.g VSCode and edit the variables at the very top only changing the ones below the comment if you are sure of what you are doing

```
USER=User here
IP=public IP of Server Here
PORT=SSH Port here
RDP1=port you would like to use to access RDP 
FTP1=port you would like to use to access FTP 
COMPANY_NAME=Name here
SERVER_NAME=Server Name
KEY_PATH=key


## ONLY EDIT BELOW THIS LINE IF YOU ARE SURE YOU WANT TO MAKE THE CHANGES, ADDING MORE VARIABLES WILL MEAN YOU NEED TO EDIT THE CONNECT.PS1 File 
H1=127.0.0.1
H1P=3389
H2P=21
```

### Optional Step - Hide everything except for the link.bat file

as the title says if you want the folder to be simple to use hide everything except the link.bat file

## Step 3 - Run

to run the script just double-click the link.bat file

#### Note

on the first run, the script will ask for admin privileges this is to run the installSSH.ps1 script which installs the required dependencies and then creates a blank text file which the script will find in future and know it doesn't need to install them.

