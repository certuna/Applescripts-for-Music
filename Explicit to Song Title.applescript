set explicitString to " 🅴"
set addOrRemove to the button returned of (display dialog "Add or Remove?" buttons {"Add", "Remove"} default button "Add")



tell application "Music"
	--tell application "iTunes" --replace the previous line with this if you're on Mojave or earlier
	if selection is not {} then
		set theSelectedTracks to selection
		set filesCounter to 0
		set tagsWrittenCounter to 0
		repeat with theTrack in theSelectedTracks
			set filesCounter to filesCounter + 1
			set fixed indexing to true
			set frontmost to true
			tell theTrack
				if (addOrRemove is "Add") and (name is not null) and (name does not contain explicitString) then
					set name to (name & explicitString)
					set tagsWrittenCounter to tagsWrittenCounter + 1
				end if
				if (addOrRemove is "Remove") and (name contains explicitString) then
					set name to my findAndReplaceInText(name, explicitString, "")
					set tagsWrittenCounter to tagsWrittenCounter + 1
				end if
			end tell
		end repeat
		--		set DialogText to "Done: " & TagsWrittenCounter & " tags written"
		--		display dialog DialogText buttons {"ok"}
	end if
end tell

on findAndReplaceInText(theText, theSearchString, theReplacementString)
	set AppleScript's text item delimiters to theSearchString
	set theTextItems to every text item of theText
	set AppleScript's text item delimiters to theReplacementString
	set theText to theTextItems as string
	set AppleScript's text item delimiters to ""
	return theText
end findAndReplaceInText