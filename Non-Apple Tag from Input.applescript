set operonPath to "/Applications/ExFalso.app/Contents/MacOS/operon"
set kid3Path to "/Applications/kid3.app/Contents/MacOS/kid3-cli"

if (exists operonPath) and (exists kid3Path) then
	set chosenTagger to button returned of (display dialog "Choose tagger" buttons {"operon", "kid3"} default button 1)
else if exists operonPath then
	set chosenTagger to "operon"
else if exists kid3Path then
	set chosenTagger to "kid3"
else
	display dialog "no tagger installed, please install Ex Falso or kid3" buttons {"ok"}
	set chosenTagger to "none"
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

if tagField is "media" or tagField is "Media" then
	set mediaList to {"CD", "DIG", "TT", "RAD", "MC"}
	set tagValue to first item of (choose from list mediaList with prompt "Choose media type" default items {"CD"})
else if tagField is "language" or tagField is "Language" then
	set languageList to {"eng", "fra", "spa", "ger", "dut", "swe", "nor", "ita", "other"}
	set tagValue to first item of (choose from list languageList with prompt "Choose language" default items {"eng"})
	if tagValue is "other" then
		set tagValue to text returned of (display dialog "Enter language (three letter code)" default answer "" buttons {"Continue..."} default button 1)
	end if
else if chosenTagger is "none" then
	set tagValue to ""
else
	set tagValue to text returned of (display dialog "Value" default answer "" buttons {"Continue..."} default button 1)
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
	if (selection is not {}) and (tagValue is not "") then
		set FilesCounter to 0
		set TagsWrittenCounter to 0
		repeat with thetrack in selection
			set FilesCounter to FilesCounter + 1
			set fixed indexing to true
			set frontmost to true
			set fileLocation to POSIX path of (get location of thetrack)
			if chosenTagger is "operon" then
				set shellScriptCommand to (quoted form of operonPath) & " " & setAddRemove & " " & tagField & " " & (quoted form of tagValue) & " " & (quoted form of fileLocation)
			else if chosenTagger is "kid3" then
				set shellScriptCommand to (quoted form of kid3Path) & " -c " & "\"set " & (quoted form of tagField) & " " & (quoted form of tagValue) & "\" " & (quoted form of fileLocation)
			end if
			do shell script shellScriptCommand
			set TagsWrittenCounter to TagsWrittenCounter + 1
		end repeat
		--		set DialogText to "Done: " & TagsWrittenCounter & " tags written"
		--		display dialog DialogText buttons {"ok"}
	end if
end tell