#!/bin/bash
if ! command -v inotifywait 2>&1 >/dev/null
then
	echo "inotifywait not found. Please install inotify-tools using your package manager"
	exit 1
fi

DELTARUNEDIR=$(pwd)
SAVEDIR="$HOME/.config/DELTARUNE"

CHAPTERSELECT_FILE="$SAVEDIR/deltarune_chapterselect"
CHAPTER1_FILE="$SAVEDIR/deltarune_chapter1"
CHAPTER2_FILE="$SAVEDIR/deltarune_chapter2"
CHAPTER3_FILE="$SAVEDIR/deltarune_chapter3"
CHAPTER4_FILE="$SAVEDIR/deltarune_chapter4"

# Just in case
mkdir -p $SAVEDIR

# Check if trigger files are somehow there and delete them
if [ -f "$CHAPTERSELECT_FILE" ]; then
	# Scary! owo
	rm -fr $CHAPTERSELECT_FILE
fi

if [ -f "$CHAPTER1_FILE" ]; then
	rm -fr $CHAPTER1_FILE
fi

if [ -f "$CHAPTER2_FILE" ]; then
	rm -fr $CHAPTER2_FILE
fi

if [ -f "$CHAPTER3_FILE" ]; then
	rm -fr $CHAPTER3_FILE
fi

if [ -f "$CHAPTER4_FILE" ]; then
	rm -fr $CHAPTER4_FILE
fi

function run_game {
	LD_LIBRARY_PATH="$DELTARUNEDIR/lib" "./deltarune" &
}

# Run the game! 
run_game

# All the logic for changing chapters -=
parse_file() {
	if [ "$1" == "deltarune_chapterselect" ]; then
		rm -fr $2/$1
		change_chapter 0
	elif [ "$1" == "deltarune_chapter1" ]; then
		rm -fr $2/$1
		change_chapter 1
	elif [ "$1" == "deltarune_chapter2" ]; then
		rm -fr $2/$1
		change_chapter 2
    	elif [ "$1" == "deltarune_chapter3" ]; then
		rm -fr $2/$1
		change_chapter 3
	elif [ "$1" == "deltarune_chapter4" ]; then
		rm -fr $2/$1
		change_chapter 4
	else
		return
	fi
}

change_chapter() {
	if [ "$1" == "0" ]; then
		cd ".."
		run_game
	elif [ "$1" == "1" ]; then
		cd "$DELTARUNEDIR/chapter1_linux"
		run_game
	elif [ "$1" == "2" ]; then
		cd "$DELTARUNEDIR/chapter2_linux"
		run_game
	elif [ "$1" == "3" ]; then
		cd "$DELTARUNEDIR/chapter3_linux"
		run_game
	elif [ "$1" == "4" ]; then
		cd "$DELTARUNEDIR/chapter4_linux"
		run_game
	fi
}

# Watch the game save directory for trigger files
inotifywait -m $SAVEDIR |
	while read filepath operation file; do
		[[ $operation == *CREATE* ]] && parse_file $file $filepath
	done


