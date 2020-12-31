# Script for updating FTB Modpack

The update-modpack.sh script is for help update a FTB modpack to a new version. To run the script, enter the modpack folder and run the script, it will check if there is a new version of the current modpack. If it is, it will create a new folder with that version number and download the installation file and run it. It will prompt you if you want to install the new version or not! It will copy the the following:

* server.properties
* eula.txt
* json files
* local folder 
* the world folder

If there is a script called `post-update.sh` in the modpack folder, it will run that too and copy it over.

## post-update.sh

You can use post-update.sh if you have made some changes in the modpack which you want to apply to the new version. In my case the post-update.sh looks like this:
```
#!/bin/bash
cp ../$CURRENT_VERSION/start.sh .
cp ../$CURRENT_VERSION/config/rats-common.toml config/
```