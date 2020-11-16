# Applescripts for Music
# Automatic retrieval of Year and/or Genres from Discogs

Imagine these scenarios:
- You have an awesome disco compilation that was released in 2018, but contains tracks from 1975-1985. Tagging these tracks with 2018 makes little sense: your smart playlist of "70s Disco" will not pick these tracks up, and instead these tunes show up between modern songs by Jessie Ware and Dua Lipa.
- You have ripped your cherished red and blue Beatles best-of CDs, released in 1993. To your frustration, these songs keep appearing in your "90s Rock" playlists.
- You have a big folder of loose tracks you downloaded on Napster back in the 1990s because you loved the videos on MTV! But they have no genre or year tags. So none of these songs ever get included in your Genre or Decade playlists, and this makes you sad.

Clearly, these songs need to be tagged with their *original* release year. But looking up every single song, checking its original release year, and writing that in the tags is tedious manual work. MusicBrainz Picard is pretty awesome, but will still tag compilation album tracks with the release date of the album, not the years when the original singles were released. This is where these scripts come in.

# How to install:
1. Create new script in macOS Script Editor
2. Copy/paste the code from this repository
3. Replace the text "please_insert_your_own_API_key_here" in the QueryDiscogs function with your own Discogs API key, see https://www.discogs.com/developers/
4. Save script as .scpt
5. Put script in /Library/Music/Scripts (all users) or /User/johndoe/Library/Music/Scripts (one user)
6. When you open Music, there's a scripts dropdown menu in the top menu bar between "Window" and "Help"

# Script 1: DiscogsYearGenres

1. You select one or more tracks, you run the script
2. Year, Genre or both? (self-explanatory)
3. One genre: the script will the prompt you *for each track* which genre to write to the Genre field
  Multiple: the script will write all genres and styles in the Genre field, separated by semicolons
4. Optionally writes the "Artist - Release" of the Discogs item to the Comments field, so you can check afterwards which master release this year came from.
5. The script performs a Discogs search for "Artist Song Name" for the master single, gets the Year, Genres and Styles back.
6. Writes the tags, and shows a dialog at the end how many songs were updated

Note 1: even though this Discogs search query specifies that only singles should be included in the search, in fact Discogs seems to ignore this, and will also return years from albums, compilations etc. Hence, the option to write Artist - Release to the comments field, so you can check.

Note 2: I am aware that semicolons as genre separators are non-standard. Multipe genres are not allowed *at all* in id3v2.3, and are defined as null separated strings in id3v2.4. However, Apple's Music app cannot handle null-separated multi-valued fields (or more precise: if the tags are UTF-8 encoded it will display only the first genre, if it's ISO-8859-1 encoded it will show it like this: "RockPopReggae"). Apple should hang their heads in shame. Meanwhile in the real world, while technically non-standard, semicolon-separated genres are supported by many other players.
