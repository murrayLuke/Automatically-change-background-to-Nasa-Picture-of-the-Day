#!/usr/bin/osascript


-------------- Make Call to NASA Picture API ---------------------


-- put your api key here you can get one from https://api.nasa.gov/index.html#apply-for-an-api-key
set api_key to "YOUR_API_KEY"

set path_to_background to "/tmp/nasa_background.jpg"

-- set the url for the api key
set nasa_API_URL to "https://api.nasa.gov/planetary/apod?api_key=" & api_key

-- ensure that we are using utf8 with python, which is what most json uses
do shell script "export PYTHONIOENCODING=utf8"

-- get the hd url for the nasa image of the day
-- we use python to pare the json response so that we don't have any external
-- dependencies
set hd_url to do shell script "curl -s " & nasa_API_URL & "| python -c \"import sys, json; print json.load(sys.stdin)['hdurl']\""

-- download the image to the path_to_background
do shell script "curl -L -o" & quoted form of path_to_background & " " & quoted form of hd_url 

-- set the backgrounds for every desktop to the picture of the day
-- tell application "System Events" to set picture of every desktop to path_to_background



-------------- Make Call to NASA Picture API ---------------------


-- put your api key here you can get one from https://api.nasa.gov/index.html#apply-for-an-api-key
set api_key to "FFfHRjP8nZXH6gXtNeBUNJBWX6GjVyYjmM4nuufG"

set path_to_background to "/tmp/nasa_background.jpg"

-- set the url for the api key
set nasa_API_URL to "https://api.nasa.gov/planetary/apod?api_key=" & api_key

-- ensure that we are using utf8 with python, which is what most json uses
do shell script "export PYTHONIOENCODING=utf8"

-- get the hd url for the nasa image of the day
-- we use python to pare the json response so that we don't have any external
-- dependencies
set hd_url to do shell script "curl -s " & nasa_API_URL & "| python -c \"import sys, json; print json.load(sys.stdin)['hdurl']\""

-- download the image to the path_to_background
do shell script "curl -L -o" & quoted form of path_to_background & " " & quoted form of hd_url

-- this portion is now DEPRECATED!!!
-- set the backgrounds for every desktop to the picture of the day
-- tell application "System Events" to set picture of every desktop to path_to_background

tell application "Finder"
	
	-- wrapped in a try block for error suppression
	try
		
		-- determine which picture to use for main display
		set mainDisplayPicture to my path_to_background
		
		-- set the picture for additional monitors, if applicable
		tell application "System Events"
			
			-- get a reference to all desktops
			set theDesktops to a reference to every desktop
			
			-- handle additional desktops
			if ((count theDesktops) > 1) then
				
				-- loop through all desktops (beginning with the second desktop)
				repeat with x from 2 to (count theDesktops)
					
					-- determine which image to use						
					set secondaryDisplayPicture to my mainDisplayPicture
					
					-- apply image to desktop
					set picture of item x of the theDesktops to secondaryDisplayPicture
					
				end repeat
				
			end if
			
		end tell
		
		-- set the primary monitor's picture
		-- due to a Finder quirk, this has to be done AFTER setting the other displays
		set desktop picture to mainDisplayPicture
		
	end try
	
end tell

do shell script "killall Dock"
