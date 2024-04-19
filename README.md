# certuna's Applescripts for Music

[Script 1: Automatic tagging of Year and/or Genres from Discogs](#script-1-automatic-tagging-of-year-andor-genres-from-discogs)

[Script 2: Tagging non-Apple fields](#script-2-non-apple-tags)

[Script 3: Explicit to Song Title](#script-3-explicit-to-song-title)

[Script 4: Display All Tags](#script-4-display-all-tags)

## Script 1: Automatic tagging of Year and/or Genres from Discogs

You are a happy macOS user, and you've successfully survived the transition from iTunes to the new Music app, introduced with macOS Catalina last year. You might like the interface, the scriptabilty, or you simply need Music to sync music to your iPhone or iPad, or stream to your AppleTV. If you have a sizeable music library, you will probably recognise these scenarios:
- You have an awesome disco compilation that was released in 2018, but contains tracks from 1975-1985. Tagging these tracks with 2018 makes little sense: your smart playlist of "70s Disco" will not pick these tracks up, and instead these tunes show up between modern songs by Doja Cat and Dua Lipa.
- You have ripped your cherished red and blue Beatles best-of CDs, released in 1993. To your frustration, Beatles songs keep appearing in your "90s Rock" smart playlists.
- You have a big folder of random tracks you downloaded on Napster back in the 1990s because you loved the videos on MTV! But they have no genre or year tags. So none of these songs ever get included in your Genre or Decade playlists, and this makes you sad.
- You have a compilation album with collected hit singles, but they're pretty diverse: Pop, Punk Rock, Hip-Hop, House, Reggaeton. But unfortunately, all songs are tagged with the same genre(s).
- You've started using a new music player that supports multiple genres, but all your tracks are tagged with one genre.
- You might have tried auto-tagging genres with some tagger using last.fm or MusicBrainz but you've found out that the genres in those databases are all over the place.

Clearly, for search/filter/smart playlists to work as expected, these songs need to be tagged with their *original* release year, and preferably, the genre of the specific song. But looking up every single song, checking its original release year and genre(s), and writing that in the tags is tedious manual work. MusicBrainz Picard is pretty awesome, but will still tag (most) compilation album tracks with the release date of the album, not the years when the original singles were released. Genres also only go on the album level. This is where this script comes in: it will try to find the *original single* on Discogs, and tag the song with that year and its specific genre(s).

### How to install:
1. Download the `Discogs Year and Genres.applescript` file from this repository to your drive and open it in Script Editor
2. Replace the text `please_insert_your_own_API_key_here` in the `QueryDiscogs` function with your own [Discogs API key](https://www.discogs.com/settings/developers) (you need to set up a Discogs account if you haven't got one)
3. If you are on macOS Mojave or older, you still have iTunes. Replace the `tell application "Music"` line with `tell application "iTunes"`
4. Save the script as `Discogs Year and Genres.scpt`
5. Put this file in `/Library/Music/Scripts` (all users) or `/Users/rickastley/Library/Music/Scripts` (one user). If the folder doesn't exist, create it. (note: for iTunes users, the folder is `/Library/iTunes/Scripts`)
6. When you open Music, there's now a scripts dropdown menu in the top menu bar between `Window` and `Help`

### How it works in practice:
1. You select one or more songs in Music, you run the script `Discogs Year and Genres`

![screenshot1](images/1.png)

2. You choose to write Year, Genre or both

![screenshot2](images/2.png)

3. **Choose Genre**: the script will the prompt you *for each track* for the Genre to write. **One Genre (Auto)** the script will write only one Genre. **Multiple Genres (Auto)**: the script will write all genres and styles in the Genre field, separated by semicolons, for example `Pop;New Wave;Synthpop`

![screenshot3](images/3.png)

4. The script can optionally write the `"Artist - Release"` of the Discogs item into the Comments field, so you can check afterwards which master release this year came from.

![screenshot4](images/4.png)

5. The script performs a Discogs API search for `Artist SongTitle` for the 'master release' of the single, gets back the Year, Genres and Styles.
6. The script writes the tags. If you've chosen **Choose Genre** and Discogs has more than one Genre/Style for the release, you will get a popup to pick which Genre to apply (note: yes 3 items max - blame Apple since AppleScript dialog boxes max out at three buttons)

![screenshot6](images/6.png)

7. and shows a dialog at the end how many songs were updated

![screenshot7](images/7.png)

8. The Year and Genre are updated

![screenshot8](images/8.png)

### Notes:

**Note 1**: even though this Discogs search query specifies that only singles should be included in the search (with `&format_exact=Single`), in fact Discogs seems to ignore this, and will also return years from albums, compilations etc. Hence, I've added the option to write the Discogs "Artist - Release" to the comments field, so you can check where the hell Discogs got that year from. This script is not perfect, various things can make the search not return the 'correct' master release: special characters, misspellings, multiple artists, etc. Feel free to tweak the code to make these searches more reliable.

**Note 2**: I am aware that semicolons as genre separators are non-standard, not for mp3 nor for mp4/aac. Technically, multiple genres are not allowed *at all* in [id3v2.3](https://id3.org/id3v2.3.0#Declared_ID3v2_frames), and are defined as null-separated strings in [id3v2.4](https://id3.org/id3v2.4.0-frames). However:
- iTunes/Apple Music cannot handle null-separated strings in id3 frames (more precise: if the id3v2.4 frame is UTF-8 encoded, multiple genres look like this: `RockPopReggae`, if the frame is ISO-8859-1 encoded it will display only the first genre `Rock`). Apple developers should hang their heads in shame, it's been 20+ (!) years since id3v2.4 was published and they still can't be bothered to implement it correctly.
- despite being non-standard, semicolon-separated multiple genres are nonetheless supported by many other players such as Navidrome, Windows Media Player, Kodi, Plex, MusicBee, Emby, foobar2000 and DBPowerAmp

So: for genre tagging in Apple Music, the choice is to either tag one genre, or tag multiple genres with another separator. I might be able implement 'proper' null-separated genres in the future, but first I'd have to figure out a way in Applescript to detect if a frame is UTF-8 encoded id3v2.4.

**Note 3**: Technically the `TDRC` ("Recording Time") field should contain the recording date/year of the music, not when it was first released, but this is usually close enough. And certainly better than the (re-)issue date which could be decades later.

**Note 4**: This is not a fast script. Discogs only allows 60 requests per minute for their API, so the code intentionally has a 1 second delay per track built in. If you let this script loose on big selections, go grab a cup of coffee, walk your dog, look at cat pictures on the internet.

## Script 2: Non-Apple Tags

Apple Music only supports a limited subset of tags, many fields like _Language_, _Record Label_, _Release Date_ or _Disc Subtitle_ can only be set using external tagging apps.

This script allows you to set these "invisible" tags from within Apple Music, using the command line utilities of two "real" tagging apps in the background:

[Ex Falso](https://quodlibet.readthedocs.io/en/latest/downloads.html#macosx) (contains the command line utility `operon`)

[kid3](https://kid3.kde.org/) (contains the command line utility `kid3-cli`)

### How to install:
1. Install either Ex Falso or kid3 in your `/Applications` folder, and run them at least once to set the right permissions
2. Download the `Non-Apple Tags.applescript` file from this repository to your drive and open it in Script Editor
3. Save the script as `Non-Apple Tags.scpt`
4. Put this file in `/Library/Music/Scripts` (all users) or `/Users/rickastley/Library/Music/Scripts` (one user). If the folder doesn't exist, create it. (note: for iTunes users, the folder is `/Library/iTunes/Scripts`)
5. When you open Apple Music, there's now a scripts dropdown menu in the top menu bar between `Window` and `Help`

### How it works in practice:
Select the files you want to tag, start the script, click `Add` or `Remove`, and watch the magic happen.

## Script 3: Explicit to Song Title

Apple Music will only read the Explicit tag for MP4 (AAC/Apple Lossless), not MP3 (id3v2). You also cannot set it yourself.

This script does the next best thing: it simply takes the Song Title and adds (or removes) an Explicit symbol (🅴), so "Dick In A Box" becomes "Dick In A Box 🅴". Works in any music player.

### How to install:
1. Download the `Explicit to Song Title.applescript` file from this repository to your drive and open it in Script Editor
2. Save the script as `Explicit to Song Title.scpt`
3. Put this file in `/Library/Music/Scripts` (all users) or `/Users/rickastley/Library/Music/Scripts` (one user). If the folder doesn't exist, create it. (note: for iTunes users, the folder is `/Library/iTunes/Scripts`)
4. When you open Apple Music, there's now a scripts dropdown menu in the top menu bar between `Window` and `Help`

### How it works in practice:
Select the files you want to tag, select the script from the drop-down menu, click `Add` or `Remove`, and watch the magic happen.

## Script 4: Display All Tags

Apple Music only supports a limited subset of tags. This script uses command line utilities `operon` or `kid3` (see above) to display all tags fields in a file.

### How to install:
1. Download the `Display All Tags.applescript` file from this repository to your drive and open it in Script Editor
2. Save the script as `Display All Tags.scpt`
3. Put this file in `/Library/Music/Scripts` (all users) or `/Users/rickastley/Library/Music/Scripts` (one user). If the folder doesn't exist, create it. (note: for iTunes users, the folder is `/Library/iTunes/Scripts`)
4. When you open Apple Music, there's now a scripts dropdown menu in the top menu bar between `Window` and `Help`

### How it works in practice:
Select the file you want to inspect, select the script from the drop-down menu.

## Script 5: Plex set Date Added to File Creation Date

Many people want the "Date Added" in Plex for a song or album to be the time when they downloaded/ripped it, not when it was last modified, or when Plex read it first.

This script modifies the Plex Media Server internal database to set the Date Added value for each mediafile (songs, but also movies, TV episodes, etc) to its File Creation Date (`btime` for those filesystem nerds).

It first goes through all files in the selected folder range, reads their btime, and sets this in the Plex database.
It then cycles through all associated Albums, and set "Date Added" to the date of the first Song

(It actually does not involve Apple Music at all, but if you install it in your Apple Music scripts folder, you can launch the script from there)

### How to install:
1. Download the `Plex set Date Added to File Creation Date.applescript` file from this repository to your drive and open it in Script Editor
2. Replace the `/username/` bit in the `defaultLibrary` variable with your own
3. Save the script as `Plex set Date Added to File Creation Date.scpt`
4. Put this file in `/Library/Music/Scripts` (all users) or `/Users/rickastley/Library/Music/Scripts` (one user). If the folder doesn't exist, create it. (note: for iTunes users, the folder is `/Library/iTunes/Scripts`)
5. When you open Apple Music, there's now a scripts dropdown menu in the top menu bar between `Window` and `Help`

### How it works in practice:
1. Run the script
2. Confirm the Plex library location
3. Choose if you want to process the whole library (may take very long!), or only a range of folders
4. the script opens a Terminal windows so you can see what it does to the Plex database
