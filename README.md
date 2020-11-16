# Applescripts for Music: Year and/or Genre from Discogs

How to install:
1. Create new script in macOS Script Editor
2. Copy/paste the code from this repository
3. Replace the text "please_insert_your_own_API_key_here" in the QueryDiscogs function with your own Discogs API key, see https://www.discogs.com/developers/
4. Save script as .scpt
5. Put script in /Library/Music/Scripts (all users) or /User/johndoe/Library/Music/Scripts (one user)

*YearFromDiscogs*

Intended to find the original release year for a single or compilation track

1. Select one or more tracks, run the script
2. The script performs a Discogs search for "Artist Song Name" for the master single, gets the year back
3. Writes this year in the Year field
4. Optionally writes the "Artist - Release" to the Comments field, so you can check afterwards which master release this year came from.

Note: even though the Discogs search query specifies that only singles should be included in the search, in fact Discogs seems to ignore this, and also returns years from albums, compilations etc. Hence, the option to write Artist - Release to the comments field, so you can check.

