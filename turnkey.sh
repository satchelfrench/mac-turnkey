#!/bin/bash


######### CONFIGURATION ##########

CONFIG='config.txt'
APP_DIR='/Applications'

# READ INFO FROM CONFIG.TXT

# LIST OF BREW APPS/COMMANDS 
tempText=$(awk -v FS=': ' '/#brew/ { printf $2";"}' $CONFIG)
IFS=';' read -r -a brewApps <<< "$tempText"

# LIST OF APP STORE APPLICATIONS (WILL DOWNLOAD FIRST RESULT MATCHING STRING)
tempText=$(awk -v FS=': ' '/#app/ {$1=""; printf $0";"}' $CONFIG)
IFS=';' read -r -a masApps <<< "$tempText"

# LIST OF OTHER APPS (DIRET LINK TO .ZIP or .DMG)
tempText=$(awk -v FS=': ' '/#install/ { printf $2";"}' $CONFIG)
IFS=';' read -r -a appLinks <<< "$tempText"


# Functions for installation

function zipInstall () {
    tmp_file=/tmp/`openssl rand -base64 10 | tr -dc '[:alnum:]'`.zip
    echo "Downloading $tmp_file "
    curl -o "$tmp_file" "$1"  # download file
    unzip "$tmp_file" -d "$APP_DIR" # unzip to applications !
    rm $tmp_file
}


function dmgInstall () {
    url=$1
    
    # Generate a random file name
    tmp_file=/tmp/`openssl rand -base64 10 | tr -dc '[:alnum:]'`.dmg


    # Download file
    echo "Downloading $url..."
    curl -# -L -o $tmp_file $url

    echo "Mounting image..."
    volume=$(hdiutil mount $tmp_file | tail -n1 | awk '/Volumes/{ $1=$2=""; printf substr($0,3) }')
    echo "$volume"   

    # Locate .app folder and move to /Applications
    app=$(find "$volume"/. -name *.app -maxdepth 3 -type d -print0)
    echo "Copying `echo $app | awk -F/ '{print $NF}'` into $APP_DIR..."
    cp -ir "$app" $APP_DIR

    # Unmount volume, delete temporal file
    echo "Cleaning up..."
    hdiutil unmount "$volume"
    rm $tmp_file

}

########## MAIN PROGRAM ##############

echo "Welcome! Beginning System Setup.." 

## INSTALL BREW PACKAGES ##
echo "Installing Homebrew Package Manager.."
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" # install homebrew 


# install brew packages

for i in "${brewApps[@]}"; do 
    echo "Using brew to install $i.."
   brew install $i
done 


## INSTALL APP STORE APPS ##

echo "Now installing app store applications.."
echo -n "Please sign into Mac App Store, and enter 'c' + [ENTER] to continue afterwards!: " 

open /Applications/App\ Store.app/ 

while [ "$loggedIn" != 'c' ]  
do
    read loggedIn
    if [ "$loggedIn" != 'c' ]; then
        echo -n "Incorrect input. Only entering 'c' will continue program.. :"
    fi
done

# install app store applications
for i in "${masApps[@]}"; do 
    echo "Using mas to install $i.."
    mas lucky "$i" 
done

echo "Starting non-app store installs.."

## INSTALL OTHER APPLICATIONS ##
for i in "${appLinks[@]}"; do 
    if [ "${i:(-3)}" == "dmg" ]; then
        dmgInstall $i
    elif [ "${i:(-3)}" == "zip" ]; then
    	zipInstall $i
    fi
