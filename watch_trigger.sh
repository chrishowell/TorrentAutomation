#!/bin/sh

WATCHED_DIR="/home/chris/torrent/complete/"

echo "Watching directory: $WATCHED_DIR for new files"
inotifywait -m -e moved_to "$WATCHED_DIR" |
  while read file
  do
	./process_complete.sh
  done
