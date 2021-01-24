#!/bin/bash
which curl > /dev/null 2>&1
if [ $? != 0 ]; then
	echo "ERROR: $0 require 'curl' to be installed !!!"
	exit 1
fi
which jq > /dev/null 2>&1
if [ $? != 0 ]; then
    echo "ERROR: $0 require 'jq' to be installed  !!!"
    exit 1
fi
CURRENT_PATH=$(pwd)
MODPACK=$(jq ".parent" version.json)
if [ "$(uname)" == "Darwin" ]; then
	OS="mac"
else
	OS="linux"
fi
if [[ $? == 0 ]]; then
    CURRENTID=$(jq ".id" version.json)
    NEWID=$(curl -s https://api.modpacks.ch/public/modpack/$(jq ".parent" version.json) | jq ".versions[] | select(.id > $(jq '.id' version.json)) | select(.type | ascii_downcase == \"release\")" | jq ".id" | sort | tail -n1)
    if [[ "$NEWID" == "" ]]; then
        echo "There is no new version"
    else
        NEW_VERSION=$(curl -s https://api.modpacks.ch/public/modpack/$(jq ".parent" version.json) | jq ".versions[] | select(.id == $NEWID)" | jq ".name" | tr -d '"' )
        CURRENT_VERSION=$(jq ".name" version.json | tr -d '"')
        FILENAME="serverinstall_${MODPACK}_${NEWID}"
        echo "Filename: $FILENAME"
        echo "Current Version: $CURRENT_VERSION"
        echo "New Version: $NEW_VERSION"
        echo "Current Path: $CURRENT_PATH"
        if [ -d "../$NEW_VERSION/" ]; then
            echo "$NEW_VERSION already exists!"
            exit 1
        fi
        mkdir ../$NEW_VERSION
        cd ../$NEW_VERSION 
        curl -o $FILENAME https://api.modpacks.ch/public/modpack/$MODPACK/$NEWID/server/$OS
        chmod u+x $FILENAME
        ./$FILENAME
        if [[ $? == 0 ]]; then
	    echo -n "Copy world..."
            cp -a ../$CURRENT_VERSION/world .
	    echo "Done"
            echo -n "Copy essential files from the current version..."
            cp ../$CURRENT_VERSION/server.properties .
            cp ../$CURRENT_VERSION/eula.txt .
            cp -a ../$CURRENT_VERSION/local .
            cp ../$CURRENT_VERSION/[b,o,u,w]*.json .
            sed -i "s/$CURRENT_VERSION/$NEW_VERSION/" server.properties
	    echo "Done"
            if [ -f ../$CURRENT_VERSION/post-update.sh ]; then
		echo -n "Run post script..."
                source ../$CURRENT_VERSION/post-update.sh
                cp ../$CURRENT_VERSION/post-update.sh .
		echo "Done"
            fi
	    echo -n "Cleanup..."
            rm $FILENAME
	    chmod u+x start.sh
	    echo "Done"
        else
            echo "No new version"
        fi
    fi
else
    echo "!!! You need to be in a ftp modepack folder !!!"
fi
