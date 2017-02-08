#!/usr/bin/osascript
use scripting additions
use framework "Foundation"
use framework "AppKit"


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

-- get the astronomer's explanation of what the image is
set explanation to do shell script "curl -s " & nasa_API_URL & "| python -c \"import sys, json; print json.load(sys.stdin)['explanation']\""

-- download the image to the path_to_background
do shell script "curl -L -o" & quoted form of path_to_background & " " & quoted form of hd_url

-- build path for exported image
set theFile to current application's NSString's stringWithString:path_to_background
set newPath to theFile--(theFile's stringByDeletingPathExtension()'s stringByAppendingString:"-out")'s stringByAppendingPathExtension:"jpg"
-- make NSString of the text, and define text attributes
set theNSString to current application's NSString's stringWithString:explanation
set theNSFont to current application's NSFont's fontWithName:"Helvetica" |size|:12
set theNSColor to current application's NSColor's whiteColor()
set attributesNSDictionary to current application's NSDictionary's dictionaryWithObjects:{theNSFont, theNSColor} forKeys:{current application's NSFontAttributeName, current application's NSForegroundColorAttributeName}
-- load the image
set theNSImage to current application's NSImage's alloc()'s initWithContentsOfFile:theFile
-- draw the text; change point to suit, remembering y 0 is at bottom
theNSImage's lockFocus()
theNSString's drawAtPoint:{72, 72} withAttributes:attributesNSDictionary
theNSImage's unlockFocus()
-- get the bitmap as data
set theNSData to theNSImage's TIFFRepresentation()
-- make a bitmap image representaion from the data
set theNSBitmapImageRep to (current application's NSBitmapImageRep's imageRepsWithData:theNSData)'s objectAtIndex:0
-- create jpeg data from the bitmap image rep
set newNSData to theNSBitmapImageRep's representationUsingType:(current application's NSJPEGFileType) |properties|:{NSImageCompressionFactor:0.8, NSImageProgressive:false}
-- save it to a file
newNSData's writeToFile:newPath atomically:true

-------------  Set the background picture on all the desktops  -----------------

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

---reset the dock process to refresh images
do shell script "killall Dock"
