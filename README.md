# Unofficial DELTARUNE Linux port

This is an unofficial port of DELTARUNE for Linux, currently for Chapters 1, 2, 3 & 4

You need a valid copy of the game, as this dosen't include any game data

To run the setup script, do the following:

Clone the repository, go into the folder and then run on terminal
```
./port.sh
```

It's not recommended to use Flatpak Steam, you will probably have issues

## ⚙️ Dependencies

`mpv`

`rsync`

`xdelta3`

`inotify-tools`

To run the game you may also need:
`openal-dev`
`nettle-dev`

And others not listed, if the game dosen't launch through Steam, run the `DELTARUNE.sh` to check what dependencies are missing

## ⚠️ Known Issues

* When loading saves for any of the chapters, you may notice that the music/audio is gone, to fix this, go to your save at `~/.config/DELTARUNE/`, edit line **569/570** and change both values from `.` to `,`, or vice-versa

* At the start of Chapter 3, there is a section where a video is supposed to play, since `video_play()` is broken on Linux, a workaround has been implemented.
