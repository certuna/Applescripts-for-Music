set operonPath to "/Applications/ExFalso.app/Contents/MacOS/operon"
set kid3Path to "/Applications/kid3.app/Contents/MacOS/kid3-cli"

tell application "System Events"
	if (exists file operonPath) and (exists file kid3Path) then
		set chosenTagger to "both"
	else if (exists file operonPath) then
		set chosenTagger to "operon"
	else if (exists file kid3Path) then
		set chosenTagger to "kid3"
	else
		set chosenTagger to "none"
	end if
end tell

if chosenTagger is "both" then
	set chosenTagger to button returned of (display dialog "Choose tagger" buttons {"operon", "kid3"} default button 1)
else if chosenTagger is "none" then
	display dialog "Please install the applications Ex Falso or kid3 in Applications" buttons {"ok"} default button 1
end if

tell application "Music"
	--tell application "iTunes" --replace the previous line with this if you're on Mojave or earlier
	if selection is not {} then
		set thetrack to first item of selection
		if chosenTagger is "kid3" then
			set fileLocation to POSIX path of (get location of thetrack)
			set shellScriptCommand to (quoted form of kid3Path) & " " & (quoted form of fileLocation) & " -c get"
			set taggerOutput to do shell script shellScriptCommand
			display dialog taggerOutput buttons ("ok")
		else if chosenTagger is "operon" then
			set fileLocation to POSIX path of (get location of thetrack)
			set shellScriptCommand to (quoted form of operonPath) & " list -t " & (quoted form of fileLocation)
			set taggerOutput to do shell script shellScriptCommand
			display dialog taggerOutput buttons ("ok")
		end if
	end if
end tell