# Automatic retrieval of Year and/or Genres from Discogs
# Applescripts for Music

Imagine these scenarios:
- You have an awesome disco compilation that was released in 2018, but contains tracks from 1975-1985. Tagging these tracks with 2018 makes little sense: your smart playlist of "70s Disco" will not pick these tracks up, and instead these tunes show up between modern songs by Jessie Ware and Dua Lipa.
- You have ripped your cherished red and blue Beatles best-of CDs, released in 1993. To your frustration, these songs keep appearing in your "90s Rock" playlists.
- You have a big folder of loose tracks you downloaded on Napster back in the 1990s because you loved the videos on MTV! But they have no genre or year tags. So none of these songs ever get included in your Genre or Decade playlists, and this makes you sad.
- You have an album with collected singles, but they're pretty diverse: Pop, Punk Rock, Hip-Hop, House, Reggaeton. But unfortunately, all songs are tagged with the same genre(s).

Clearly, these songs need to be tagged with their *original* release year, and preferably, the genre of the specific song. But looking up every single song, checking its original release year and genre(s), and writing that in the tags is tedious manual work. MusicBrainz Picard is pretty awesome, but will still tag compilation album tracks with the release date of the album, not the years when the original singles were released. Genres also only go on the album level. This is where this script comes in: it will try to find the original single on Discogs, and tag the song with that year and its specific genre(s).

# How to install:
1. Create new script in macOS Script Editor
2. Copy/paste the code from this repository
3. Replace the text `please_insert_your_own_API_key_here` in the QueryDiscogs function with your own Discogs API key, see https://www.discogs.com/developers/
4. If you are on macOS Mojave or earlier, you still have iTunes. Replace the `tell application "Music"` line with `tell application "iTunes"`
4. Save the script as `Discogs Year and Genres.scpt`
5. Put this script in `/Library/Music/Scripts` (all users) or `/User/johndoe/Library/Music/Scripts` (one user). If the folder doesn't exist, create it.
6. When you open Music, there's a scripts dropdown menu in the top menu bar between `Window` and `Help`

# Script 1: DiscogsYearGenres
1. You select one or more tracks, you run the script `Discogs Year and Genres`
2. Choose to write Year, Genre(s) or both
3. One genre: the script will the prompt you *for each track* which genre to write to the Genre field
  Multiple: the script will write all genres and styles in the Genre field, separated by semicolons
4. Optionally writes the `"Artist - Release` of the Discogs item to the Comments field, so you can check afterwards which master release this year came from.
5. The script performs a Discogs search for `Artist SongTitle` for the 'master release' of the single, gets back the Year, Genres and Styles.
6. Writes the tags, and shows a dialog at the end how many songs were updated

Note 1: even though this Discogs search query specifies that only singles should be included in the search, in fact Discogs seems to ignore this, and will also return years from albums, compilations etc. Hence, the option to write Artist - Release to the comments field, so you can check. This script is not perfect, various things can make the search not work: special characters, misspellings, multiple artists, etc.

Note 2: I am aware that semicolons as genre separators are non-standard. Multipe genres are not allowed *at all* in id3v2.3, and are defined as null separated strings in id3v2.4. However, Apple's Music app cannot handle null-separated multi-valued fields (or more precise: if the id3v2.4 tag is ISO-8859-1 encoded it will display only the first genre, if it's UTF-8 encoded it will show it like this: `RockPopReggae`). Apple developers should hang their heads in shame. Meanwhile the world moved on, and while technically non-standard, semicolon-separated genres are supported by many other players.
