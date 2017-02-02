#!/usr/bin/osascript


-------------- Make Call to NASA Picture API ---------------------


-- put your api key here you can get one from https://api.nasa.gov/index.html#apply-for-an-api-key
set api_key to "YOUR API KEY HERE"

set path_to_background to "/tmp/nasa_background"

-- set the url for the api key
set nasa_API_URL to "https://api.nasa.gov/planetary/apod?api_key=" & api_key

-- ensure that we are using utf8 with python, which is what most json uses
do shell script "export PYTHONIOENCODING=utf8"

-- get the hd url for the nasa image of the day
-- we use python to pare the json response so that we don't have any external
-- dependencies
set hd_url to do shell script "curl -s " & nasa_API_URL & "| python -c \"import sys, json; print json.load(sys.stdin)['hdurl']\""

-- download the image to the path_to_background
do shell script "curl -L -o " & quoted form of path_to_background & " " & quoted form of hd_url 

-- set the backgrounds for every desktop to the picture of the day
tell application "System Events" to set picture of every desktop to "/tmp/nasa_background"