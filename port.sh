#!/bin/bash
if ! command -v rsync 2>&1 >/dev/null
then
	echo "rsync not found. Please install rsync using your package manager"
	exit 1
fi

if ! command -v xdelta3 2>&1 >/dev/null
then
	echo "xdelta3 not found. Please install xdelta using your package manager"
	exit 1
fi

DELTARUNEDIR=""
SCRIPTDIR=$(pwd)

function port_game() {
   echo ""
   cd $DELTARUNEDIR

   echo -e "\e[1;34m::\e[0m \e[1mRenaming files\e[0m"
   find -name "chapter*" | sed 'p;s/windows/linux/' | xargs -d '\n' -n 2 mv
   find "mus/" -exec bash -c 'mv $0 ${0,,}' {} \;
   find "chapter3_linux/vid/" -exec bash -c 'mv $0 ${0,,}' {} \;
   mv "$DELTARUNEDIR/chapter1_linux/AUDIO_INTRONOISE.ogg" "$DELTARUNEDIR/chapter1_linux/audio_intronoise.ogg"
   mv "$DELTARUNEDIR/chapter2_linux/AUDIO_INTRONOISE.ogg" "$DELTARUNEDIR/chapter2_linux/audio_intronoise.ogg" 
   mv "$DELTARUNEDIR/chapter3_linux/AUDIO_INTRONOISE.ogg" "$DELTARUNEDIR/chapter3_linux/audio_intronoise.ogg" 
   mv "$DELTARUNEDIR/chapter4_linux/AUDIO_INTRONOISE.ogg" "$DELTARUNEDIR/chapter4_linux/audio_intronoise.ogg"
   echo ""

   echo -e "\e[1;34m::\e[0m \e[1mMoving files...\e[0m"
   rm -fr DELTARUNE.exe
   rm -fr options.ini
   mv data.win game.unx
    
   cp "$SCRIPTDIR/deltarune" .
   cp "$SCRIPTDIR/DELTARUNE.sh" .
   cp "$SCRIPTDIR/icon.png" .
   cp "$SCRIPTDIR/splash.png" .
   cp -r "$SCRIPTDIR/files/lib" .

   find . -type d -name "chapter*_linux" -print0 | while IFS= read -r -d $'\0' chapter_dir; do
        rm -fr "$chapter_dir/options.ini"
        mv "$chapter_dir/data.win" "$chapter_dir/game.unx"
        
        mkdir -p "$chapter_dir/assets"
        rsync -vau --remove-source-files "$chapter_dir/" "$chapter_dir/assets"
        rm -fr "$chapter_dir/assets/assets"
        rm -fr "$chapter_dir/lang"

        cp "$SCRIPTDIR/deltarune" "$chapter_dir/"
        cp "$SCRIPTDIR/icon.png" "$chapter_dir/"
        cp "$SCRIPTDIR/splash.png" "$chapter_dir/"
        cp -r "$SCRIPTDIR/files/lib" "$chapter_dir/"
        ln -sf "../../mus" "$chapter_dir/assets/mus"
   done

   cp "$SCRIPTDIR/files/options_1.ini" "$DELTARUNEDIR/chapter1_linux/options.ini"
   cp "$SCRIPTDIR/files/options_2.ini" "$DELTARUNEDIR/chapter2_linux/options.ini"
   cp "$SCRIPTDIR/files/options_3.ini" "$DELTARUNEDIR/chapter3_linux/options.ini"
   cp "$SCRIPTDIR/files/options_4.ini" "$DELTARUNEDIR/chapter4_linux/options.ini"
   cp "$SCRIPTDIR/files/subtitles.srt" "$DELTARUNEDIR/chapter3_linux/assets/vid/"
   rm -fr "$DELTARUNEDIR/chapter3_linux/vid"

   echo -e "\e[1;34m::\e[0m \e[1mApplying patches\e[0m"
   echo ""
   xdelta -d -s "$DELTARUNEDIR/game.unx" "$SCRIPTDIR/files/patches/01-menu.delta" "$DELTARUNEDIR/game.unx.1"
   xdelta -d -s "$DELTARUNEDIR/chapter1_linux/assets/game.unx" "$SCRIPTDIR/files/patches/02-chapter_01.delta" "$DELTARUNEDIR/chapter1_linux/assets/game.unx.1"
   xdelta -d -s "$DELTARUNEDIR/chapter2_linux/assets/game.unx" "$SCRIPTDIR/files/patches/03-chapter_02.delta" "$DELTARUNEDIR/chapter2_linux/assets/game.unx.1"
   xdelta -d -s "$DELTARUNEDIR/chapter3_linux/assets/game.unx" "$SCRIPTDIR/files/patches/04-chapter_03.delta" "$DELTARUNEDIR/chapter3_linux/assets/game.unx.1"
   xdelta -d -s "$DELTARUNEDIR/chapter3_linux/assets/game.unx.1" "$SCRIPTDIR/files/patches/05-chapter_03_video_fix.delta" "$DELTARUNEDIR/chapter3_linux/assets/game.unx.2"
   xdelta -d -s "$DELTARUNEDIR/chapter4_linux/assets/game.unx" "$SCRIPTDIR/files/patches/06-chapter_04.delta" "$DELTARUNEDIR/chapter4_linux/assets/game.unx.1"

   rm -fr "$DELTARUNEDIR/game.unx"
   rm -fr "$DELTARUNEDIR/chapter1_linux/assets/game.unx"
   rm -fr "$DELTARUNEDIR/chapter2_linux/assets/game.unx"
   rm -fr "$DELTARUNEDIR/chapter3_linux/assets/game.unx"
   rm -fr "$DELTARUNEDIR/chapter3_linux/assets/game.unx.1"
   rm -fr "$DELTARUNEDIR/chapter4_linux/assets/game.unx"
   mv "$DELTARUNEDIR/game.unx.1" "$DELTARUNEDIR/game.unx"
   mv "$DELTARUNEDIR/chapter1_linux/assets/game.unx.1" "$DELTARUNEDIR/chapter1_linux/assets/game.unx"
   mv "$DELTARUNEDIR/chapter2_linux/assets/game.unx.1" "$DELTARUNEDIR/chapter2_linux/assets/game.unx"
   mv "$DELTARUNEDIR/chapter3_linux/assets/game.unx.2" "$DELTARUNEDIR/chapter3_linux/assets/game.unx"
   mv "$DELTARUNEDIR/chapter4_linux/assets/game.unx.1" "$DELTARUNEDIR/chapter4_linux/assets/game.unx"

   ln -sf "$DELTARUNEDIR/DELTARUNE.sh" "$DELTARUNEDIR/DELTARUNE.exe"

   echo -e "\e[1;32m SUCCESS! The port script finished. \e[0m"
   echo -e '\e[1;34m::\e[0m \e[1mTo play DELTARUNE, go to Steam -> DELTARUNE -> Properties -> Launch Options -> Put this: "./DELTARUNE.sh" %command% \e[0m'
   echo -e "\e[1;34m::\e[0m \e[1mOr, you can run ./DELTARUNE.sh in the game folder. (If you have issues with Steam, run the game this way)\e[0m"
   echo -e "\e[1;34m::\e[0m \e[1mEnjoy and have fun! \e[0m"
}

function select_dir() {
   echo ""
   echo -e "\e[1;34m::\e[0m \e[1mPlease type the path of DELTARUNE below (eg. /home/pug/.local/share/Steam/steamapps/common/DELTARUNE):\e[0m"
   read path

   if [ "$path" = "" ]; then
      exit;
   fi

   if [ ! -d "$path" ]; then
      echo -e "\e[31mERROR: Directory dosen't exist, please try again\e[0m"
      exit;
   fi

   DELTARUNEDIR=$path
   port_game
}

echo -e "\e[1;34mWelcome to the unofficial DELTARUNE Chapter 3 & 4 Linux port!\e[0m"
echo -e "\e[1;34mThis port is for version 1.01C\e[0m"
echo -e "\e[1;34mSince Chapter 3&4 are paid, you are gonna need to own a copy. This dosen't include any game data\e[0m"
echo ""

if [ -d "$HOME/.steam/steam/steamapps/common/DELTARUNE" ]; then
	DELTARUNEDIR="$HOME/.steam/steam/steamapps/common/DELTARUNE"
	echo -e "\e[1;34m::\e[0m \e[1mDetected deltarune directory at $DELTARUNEDIR."
	while true; do
		read -p "Is this correct? [y/n]: " yn
		case $yn in
			[Yy]* ) port_game; break;;
			[Nn]* ) select_dir; break;;
			* ) select_dir; break;;
		    esac
		done
else
	select_dir
fi
