#/bin/bash

torrentzurl=$1 
limetorrentstub=www.limetorrents.com
torrentwatchloc=/home/chris/torrent/watch 

torrentzcontent=$(curl -L $torrentzurl)
[[ $torrentzcontent =~ (http:\/\/$limetorrentstub\/[^\"]*)\" ]] && torrenturl=${BASH_REMATCH[1]}
echo "found limetorrent torrent page at $torrenturl"

torrentcontent=$(curl -L $torrenturl)
[[ $torrentcontent =~ (http:\/\/www.limetorrents.com\/download\/[^\"]*)\" ]] && torrentfileurl=${BASH_REMATCH[1]}
echo "found torrent file at $torrentfileurl"

desttorrentfile=$torrentwatchloc/$(date +%s).torrent
torrentfilecontent=$(curl -L --globoff -o $desttorrentfile $torrentfileurl)
echo "torrent file downloaded successfully, located at $desttorrentfile"
