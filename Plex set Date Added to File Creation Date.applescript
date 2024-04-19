-- this script goes through two steps:
-- step 1. for a given range of Plex directory id's, finds all files in those folders, and sets the added_at date for each file to its file creation time ("btime")
-- note: this for songs, movies, tv episodes, etc
-- step 2. sets the added_at value of the albums of those songs to the added_at of its first track
-- note: this only for music albums

set defaultLibrary to "/Users/username/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db"
set databaseLocation to quoted form of text returned of (display dialog "Database location" default answer defaultLibrary)
set sqliteLocation to quoted form of "/Applications/Plex Media Server.app/Contents/MacOS/Plex SQLite"

set sqlQuery to "SELECT id FROM directories"
set sqlQuery1 to quoted form of (sqlQuery & ";")
set getDirectoryListCommand to sqliteLocation & " " & databaseLocation & " " & sqlQuery1
set sqlOutput to do shell script getDirectoryListCommand
set directoryList to paragraphs of sqlOutput
set directoryCount to last item of directoryList as integer
set dialogText to ("Library has " & directoryCount as text) & " folders, which do you want to process?"

if button returned of (display dialog dialogText buttons {"Whole Library", "Selection"} default button 2) is equal to "whole library" then
	set sqlQuery to "SELECT media_item_id, file FROM media_parts"
else
	set firstDirectory to text returned of (display dialog "First Directory ID:" default answer 1) as integer
	set lastDirectory to text returned of (display dialog "Last Directory ID:" default answer 2) as integer
	set sqlQuery to "SELECT media_item_id, file FROM media_parts WHERE directory_id BETWEEN " & firstDirectory & " and " & lastDirectory
end if

set sqlQuery1 to quoted form of (sqlQuery & ";")
set unixStartTime to date "Thursday, 1 January 1970 at 00:00:00"

-- getting list of all mediaItemId's + filepaths
set getFileListCommand to sqliteLocation & " " & databaseLocation & " " & sqlQuery1
set sqlOutput to do shell script getFileListCommand
set fileList to paragraphs of sqlOutput
-- list in the format:
-- 12345|/Volumes/Drive/Folder/Filename.mp3

if number of items in fileList is 0 then display dialog "No files to process"
if number of items in fileList is 0 then return
display dialog "about to process " & (number of items in fileList as string) & " files"

set counter to 0 as integer
set startTime to (current date)
set AppleScript's text item delimiters to "|"

-- get btime for each file in media_parts
repeat with fileItem in fileList
	set counter to counter + 1
	set valuesArray to text items of fileItem
	
	set mediaItemId to first item of valuesArray
	if counter = 1 then
		set minMediaItemId to mediaItemId
		set maxMediaItemId to mediaItemId
	end if
	if minMediaItemId is greater than mediaItemId then
		set minMediaItemId to mediaItemId
	end if
	if maxMediaItemId is less than mediaItemId then
		set maxMediaItemId to mediaItemId
	end if
	
	set filePath to second item of valuesArray
	set birthTime to do shell script "stat -f %SB -t %D/%T " & quoted form of filePath
	-- 12/30/14/13:40:59 for 30 Dec 2014, i.e. MM/DD/YY/HH:MM/SS
	
	set AppleScript's text item delimiters to "/"
	set birthTime to text items of birthTime
	set _day to second item of birthTime
	set _day to text -1 thru -2 of ("0" & _day)
	set _month to first item of birthTime
	set _month to text -1 thru -2 of ("0" & _month)
	set _year to (third item of birthTime) + 2000
	if _year > 2050 then set _year to (_year - 100)
	set _time to (fourth item of birthTime)
	set birthDate to {_day, _month, _year} as string
	set birthTime to birthDate & " at " & _time as string
	-- 30/12/2014 at 13:40:59
	if birthTime is not "" then
		set birthTime to date birthTime
		set unixTime to my IntegerString(birthTime - unixStartTime) as string
	end if
	set AppleScript's text item delimiters to "|"
	set fileItem to {mediaItemId, unixTime} as string
	-- 12345|1551722656
	
	set item counter of fileList to fileItem
end repeat

-- write btime to each metadata_item
set itemCounter to 0
tell application "Terminal"
	activate
	set currentTab to do script (sqliteLocation)
	delay 2
	do script (".open " & databaseLocation) in currentTab
	delay 2
	repeat with mediaItem in fileList
		set itemCounter to itemCounter + 1
		set valuesArray to text items of mediaItem
		set mediaItemId to first item of valuesArray
		set unixTime to second item of valuesArray
		
		--get metadataItemId
		set sqlCommand to "SELECT metadata_item_id FROM media_items WHERE id = " & mediaItemId
		--write btime to metadataItemID
		set sqlCommand to "UPDATE metadata_items SET added_at = " & unixTime & " WHERE id = (" & sqlCommand & ");"
		do script (sqlCommand) in currentTab
		delay 0.1
	end repeat
end tell

set itemDuration to (current date) - startTime
set itemSpeed to (itemCounter / itemDuration)

-- step 2: set the albums date_added to the date_added of the first track

--returns a list of metadata_item_ids, so we can take the min and max
set sqlQuery to "SELECT metadata_item_id FROM media_items WHERE id BETWEEN " & minMediaItemId & " and " & maxMediaItemId
set sqlQuery1 to quoted form of (sqlQuery & ";")
set getItemListCommand to sqliteLocation & " " & databaseLocation & " " & sqlQuery1
set sqlOutput to do shell script getItemListCommand
set itemList to paragraphs of sqlOutput
set firstMetadataItem to first item of itemList
set lastMetadataItem to last item of itemList

-- select all tracks (metadata_type = 10), and return columns parent_id (=the metadata_item id of the album) and added_at
set sqlQuery to "SELECT parent_id,added_at FROM metadata_items WHERE (metadata_type = 10 AND id BETWEEN " & firstMetadataItem & " and " & lastMetadataItem & ")"
set sqlQuery1 to quoted form of (sqlQuery & ";")
set getItemListCommand to sqliteLocation & " " & databaseLocation & " " & sqlQuery1
set sqlOutput to do shell script getItemListCommand
set itemList to paragraphs of sqlOutput
-- list of parentId|added_at
-- 12345|1551722656

if number of items in itemList is 0 then
	tell application "Terminal"
		do script (".exit") in currentTab
	end tell
	display dialog (itemCounter as string) & " files updated in " & (itemDuration as string) & " seconds (" & (itemSpeed as string) & " files per second)"
	display dialog "No albums to process"
end if
if number of items in itemList is 0 then return
--display dialog "about to process " & (number of items in itemList as string) & " files"

set albumStartTime to (current date)
set AppleScript's text item delimiters to "|"
set trackCounter to 0 as integer
set albumCounter to 0 as integer
set previousTrackAlbumId to ""
-- set album added_at date to the first date encountered in the tracklist
tell application "Terminal"
	repeat with track in itemList
		set trackCounter to trackCounter + 1
		set valuesArray to text items of track
		set albumId to first item of valuesArray
		set trackAddedAt to second item of valuesArray
		
		-- only process when we arrive at a new albumID
		if albumId is not previousTrackAlbumId then
			--write added_at to album
			set sqlCommand to "UPDATE metadata_items SET added_at = " & trackAddedAt & " WHERE id = " & albumId & ";"
			--display dialog sqlCommand
			do script (sqlCommand) in currentTab
			delay 0.05
			set albumCounter to albumCounter + 1
		end if
		set previousTrackAlbumId to albumId
	end repeat
	do script (".exit") in currentTab
end tell

display dialog (itemCounter as string) & " files updated in " & (itemDuration as string) & " seconds (" & (itemSpeed as string) & " files per second)"
set albumDuration to (current date) - albumStartTime
if albumDuration is not 0 then
	set albumSpeed to (albumCounter / albumDuration)
else
	set albumSpeed to -1
end if
display dialog (albumCounter as string) & " albums updated in " & (albumDuration as string) & " seconds (" & (albumSpeed as string) & " files per second)"

property pMaxInt : (2 ^ 29) - 1

on IntegerString(n)
	if n > pMaxInt then
		set {lngRest, str} to {n, ""}
		repeat while lngRest > 10
			set str to ((lngRest mod 10) as integer as string) & str
			set lngRest to lngRest div 10
		end repeat
		(lngRest as string) & str
	else
		n as integer as string
	end if
end IntegerString
