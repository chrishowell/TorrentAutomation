#!/bin/bash
desttorrentfile=/home/chris/torrent/.scripts//$(date +%s).torrent
curl -L --globoff -o $desttorrentfile $1
echo "torrent file downloaded successfully, located at $desttorrentfile"
