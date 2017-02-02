## What is it

This is a simple script I wrote to change the background of the MacOS desktop to NASA's astronomy picture of the day.

## How to run it on your computer

Place the file change_background_nasa_script.scpt somewhere on your computer where it will not be moved frequently. Then fill out the form [here](https://api.nasa.gov/index.html#apply-for-an-api-key) to get an api key from NASA to work with this application. The form is very quick, and it is completely free!

Replace the following line in change_background_nasa_script.scrpt with the api key you received.

```
set api_key to "YOUR API KEY HERE"
```


Then open the file com.murrayLuke.nasa_backgrounds.plist

Replace the following line in com.murrayLuke.nasa_backgrounds.plist with the full path to the location of your file change_background_nasa_script.scpt


```
<string>/Users/lukemurray/Documents/git_repos/change_background_nasa/change_background_nasa_script.scpt</string>
```


then type the following commands into your terminal to start running the program daily at three minutes past midnight.

```
cp com.murrayLuke.nasa_backgrounds.plist ~/Library/LaunchAgents
launchctl load ~/Library/LaunchAgents/com.murrayLuke.nasa_backgrounds.plist
```

To stop the program from running type the following commands into your terminal

```
launchctl unload ~/Library/LaunchAgents/com.murrayLuke.nasa_backgrounds.plist
```

## How it works

There is a short apple script which uses curl to make requests to NASA's picture of the day api. This downloads the current picture of the day into the tmp folder. A separate launchctl plist is used to run the script once every day at three minutes past midnight. Unfortunately due to the limitations of launchctl the script will be run at startup if the computer is put to sleep at night, but the script will not run at startup if the computer has been powered off at night.
