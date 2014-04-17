#!/bin/sh

WATCHED_DIR="/home/chris/torrent/complete/"

echo "Watching directory: $WATCHED_DIR for new files"
inotifywait -m -e moved_to --format %f "$WATCHED_DIR" |
  while read file
  do
	/home/chris/torrent/.scripts/process_complete.sh
  done

