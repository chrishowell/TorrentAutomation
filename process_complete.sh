#!/bin/bash
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

SRC=~/torrent/complete
DEST=~/Videos
MUSIC_DEST=~/Music
OTHER_DEST=~/torrent/othercomplete
FAILED_DEST=~/torrent/failedconversion
DONE_DEST=~/torrent/converted_old
LOG_FILE=~/torrent/process.log

DEST_EXT=mp4
HANDBRAKE=HandBrakeCLI
VIDEXT_REGEX="avi|mov|mkv|flv"
MUSEXT_REGEX="mp3|m4a"

convert() {
	file_path="$1"
	full_filename="$(basename $file_path)"
	filename="${full_filename%.*}"

	log "Converting to: $DEST/$filename.$DEST_EXT"
	$HANDBRAKE -i "$file_path" -o "$DEST/$filename.$DEST_EXT" -e x264

	if [ $? != 0 ]; then
		log "CONVERT_FAIL moving to: $FAILED_DEST/$full_filename"
		mv "$file_path" "$FAILED_DEST/$full_filename"
	else
		log "CONVERT-SUCCESS moving old file to: $DONE_DEST/$full_filename"
		mv "$file_path" "$DONE_DEST/$full_filename"
	fi
}

log() {
	echo $(date +"%D %T : $1") >> $LOG_FILE
}

# DOING THE WORK -------

log "========== STARTING BATCH ==========="

for FILE in `find "$SRC" -type f`
do
	full_filename=$(basename "$FILE")
	extension="${full_filename##*.}"

	shopt -s nocasematch
	if [[ "$extension" = $DEST_EXT ]]; then
		log "NO_CONVERT: $FILE"
		log "Moving to: $DEST/$full_filename"
		mv "$FILE" "$DEST/$full_filename"
	elif [[ $extension =~ $VIDEXT_REGEX ]] ; then
		log "CONVERT: $FILE"
		convert "$FILE"
	elif [[ $extension =~ $MUSEXT_REGEX ]] ; then
		log "NO_CONVERT_MUSIC: $FILE"
		log "Moving to: $MUSIC_DEST/$full_filename"
		mv "$FILE" "$MUSIC_DEST/$full_filename"
	else
		log "OTHER_FILE: $FILE"
		log "Moving to: $OTHER_DEST/$full_filename"
		mv "$FILE" "$OTHER_DEST/$full_filename"
	fi
done

IFS=$SAVEIFS

log "=========== FINISHED BATCH ============"
