set operonPath to "/Applications/ExFalso.app/Contents/MacOS/operon"
set kid3Path to "/Applications/kid3.app/Contents/MacOS/kid3-cli"
set tagField to ""
set tagSource to ""

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

if chosenTagger is "operon" then
	set tagFieldsList to {"arranger", "conductor", "discsubtitle", "initialkey", "isrc", "label/publisher", "language", "lyricist", "media", "originaldate", "recordingdate", "releasecountry", "song subtitle"}
	set tagField to first item of (choose from list tagFieldsList with prompt "Choose tag" default items {"discsubtitle"})
	if tagField is "label/publisher" then
		set tagField to "organization"
	else if tagField is "song subtitle" then
		set tagField to "version"
	end if
	if tagField is "arranger" or tagField is "conductor" or tagField is "lyricist" or tagField is "language" then
		set setAddRemove to button returned of (display dialog "Set, Add or Remove" buttons {"set", "add", "remove"} default button 1)
	else
		set setAddRemove to "set"
	end if
else if chosenTagger is "kid3" then
	set tagFieldsList to {"Arranger", "Catalog Number", "Conductor", "Disc Subtitle", "DJ Mixer", "Initial Key", "ISRC", "Label/Publisher", "Language", "Lyricist", "Media", "Original Date", "Producer", "Release Country", "Release Type", "Remixer", "Song Subtitle/Desciption"}
	set tagField to first item of (choose from list tagFieldsList with prompt "Choose tag" default items {"Subtitle"})
	if tagField is "Song Subtitle/Description" then
		set tagField to "Description"
	else if tagField is "Disc Subtitle" then
		set tagField to "Subtitle"
	else if tagField is "Label/Publisher" then
		set tagField to "Publisher"
	end if
end if

if (tagField is "media") or (tagField is "Media") then
	set mediaList to {"CD", "DIG", "TT", "RAD", "MC"}
	set tagValue to first item of (choose from list mediaList with prompt "Choose media type" default items {"CD"})
else if (tagField is "language") or (tagField is "Language") then
	set languageList to {"eng", "fra", "spa", "ger", "ita", "dut", "swe", "por", "nor", "rus", "ara", "chi", "jpn", "kor", "hin", "other"}
	set tagValue to first item of (choose from list languageList with prompt "Choose language" default items {"eng"})
	if tagValue is "other" then
		set tagValue to text returned of (display dialog "Enter language (three letter code)" default answer "" buttons {"Continue..."} default button 1)
	end if
else if tagField is not "" then
	set sources to (display dialog "Input source" default answer "" buttons {"Copy From Comments", "Copy From Grouping", "Manual Text..."} default button 3)
	set tagSource to button returned of the sources
	set tagValue to text returned of the sources
end if

if tagField is not "" and tagValue is "" and setAddRemove is "set" then
	set warningText to "Are you sure you want to continue setting " & tagField & " to empty?"
	set continueTagging to button returned of (display dialog warningText buttons {"Yes Continue", "Cancel"} default button 2)
	if continueTagging is "Cancel" then
		set tagField to ""
	end if
end if

if tagField is "DJ Mixer" then
	set tagField to "Arranger"
	set tagValue to "DJ-mix|" & tagValue
else if tagField is "Producer" then
	set tagField to "Arranger"
	set tagValue to "Producer|" & tagValue
end if

tell application "Music"
	--tell application "iTunes" --replace the previous line with this if you're on Mojave or earlier
	if (selection is not {}) and (tagField is not "") then
		set FilesCounter to 0
		set TagsWrittenCounter to 0
		repeat with thetrack in selection
			set FilesCounter to FilesCounter + 1
			set fixed indexing to true
			set frontmost to true
			set fileLocation to POSIX path of (get location of thetrack)
			
			if tagSource is "Copy From Comment" then
				set tagValue to comment of thetrack as text
			else if tagSource is "Copy From Grouping" then
				set tagValue to grouping of thetrack as text
			end if
			
			if chosenTagger is "operon" then
				set shellScriptCommand to (quoted form of operonPath) & " " & setAddRemove & " " & tagField & " " & (quoted form of tagValue) & " " & (quoted form of fileLocation)
			else if chosenTagger is "kid3" then
				set shellScriptCommand to (quoted form of kid3Path) & " -c " & "\"set " & (quoted form of tagField) & " " & (quoted form of tagValue) & "\" " & (quoted form of fileLocation)
			end if
			
			do shell script shellScriptCommand
			set TagsWrittenCounter to TagsWrittenCounter + 1
		end repeat
	end if
end tell
set finalText to "Done: " & TagsWrittenCounter & " " & tagField & " tags written out of " & FilesCounter & " selected songs"
display dialog finalText buttons {"ok"}
