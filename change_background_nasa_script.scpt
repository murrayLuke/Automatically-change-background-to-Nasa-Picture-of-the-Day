#!/usr/bin/osascript
use scripting additions
use framework "Foundation"
use framework "AppKit"

-------------- Stuff for logging --------------------------
log (date string of (current date))
log (time string of (current date))


-------------- Wait for a network connection to load ---------------
set network_status to do shell script "./wait_for_network.sh"
log network_status

-------------- Download Picture from NASA API  ---------------------

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

-------------- Scale the Image to Fit the Sreen -------------------

-- get the width and height of the screen
tell application "Finder"
    set _b to bounds of window of desktop
    set screen_width to item 3 of _b
    set screen_height to (item 4 of _b)
end tell

-- get the width and height of the image
tell application "Image Events"
	set my_image to open path_to_background
	set _im_properties to the properties of my_image
	set _im_dim to dimensions of _im_properties
	set image_width to item 1 of _im_dim
	set image_height to item 2 of _im_dim
	close my_image
end tell

-- get the ratios for the image
set width_ratio to (image_width / screen_width)

-- the background is always scaled in the x direction
set scaling_factor to (1 / width_ratio)


-- scale the image so that at least one of it's dimensions is the same size
-- as the screen
tell application "Image Events"
	set my_image to open path_to_background
	if  image_width > image_height then 
		set target_width to (image_width * scaling_factor)
		scale my_image to size target_width
	else 
		set target_height to (image_height * scaling_factor)
		scale my_image to size target_height
	end if
	save my_image with icon
	close my_image
end tell

-- update the width and height of the image
tell application "Image Events"
	set my_image to open path_to_background
	set _im_properties to the properties of my_image
	set _im_dim to dimensions of _im_properties
	set image_width to item 1 of _im_dim
	set image_height to item 2 of _im_dim
	close my_image
end tell

-- height of the menu bar is a constant
set menu_bar_height to 22

-- get the offset of the image in the x and y direction
set text_padding to 10
set text_x_offset to (screen_width - image_width) / 2 + text_padding
set text_y_offset to (screen_height - image_height) / 2 - menu_bar_height - text_padding

---------------------- Drawing Explanation on the Image --------------------

-- build path for exported image
set image to current application's NSString's stringWithString:path_to_background
set newImagePath to image
-- set the string we are goign to use
set theNSString to current application's NSString's stringWithString:explanation
-- set the font we are going to use
set theNSFont to current application's NSFont's fontWithName:"Helvetica" |size|:12
-- set the color we are going to use for the font
set theNSForegroundColor to current application's NSColor's whiteColor()
-- set the color we are going to use for the bakground
set theNSBackgroundColor to current application's NSColor's colorWithRed:.5 green:.5 blue:.5 alpha:.5
-- set values for drawing text within a rectagnel
set attributesNSDictionary to current application's NSDictionary's dictionaryWithObjects:{theNSFont, theNSForegroundColor, theNSBackgroundColor} forKeys:{current application's NSFontAttributeName, current application's NSForegroundColorAttributeName, current application's NSBackgroundColorAttributeName}
set theCGRect to current application's CoreGraphics's CGRectMake(text_x_offset, text_y_offset, 300, image_height)
set theNSOptions to current application's NSStringDrawingUsesLineFragmentOrigin
-- load the image
set theNSImage to current application's NSImage's alloc()'s initWithContentsOfFile:image
-- draw the text;
theNSImage's lockFocus()
theNSString's drawWithRect:theCGRect options:theNSOptions attributes:attributesNSDictionary
theNSImage's unlockFocus()
-- get the bitmap as data
set theNSData to theNSImage's TIFFRepresentation()
-- make a bitmap image representaion from the data
set theNSBitmapImageRep to (current application's NSBitmapImageRep's imageRepsWithData:theNSData)'s objectAtIndex:0
-- create jpeg data from the bitmap image rep
set newNSData to theNSBitmapImageRep's representationUsingType:(current application's NSJPEGFileType) |properties|:{NSImageCompressionFactor:0.8, NSImageProgressive:false}
-- save it to a file
newNSData's writeToFile:newImagePath atomically:true

-------------  Set the background picture on all the desktops  ----------------

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

log(hd_url)
log(explanation)
