#/bin/bash

torrentzurl=$1 
limetorrentstub=www.limetorrents.com
torrentwatchloc=/home/chris/torrent/watch 

torrentzcontent=$(curl -L $torrentzurl)
[[ $torrentzcontent =~ (http:\/\/$limetorrentstub\/[^\"]*)\" ]] && torrenturl=$$
echo "found limetorrent torrent page at $torrenturl"

torrentcontent=$(curl -L $torrenturl)
[[ $torrentcontent =~ (http:\/\/www.limetorrents.com\/download\/[^\"]*)\" ]] &&$
echo "found torrent file at $torrentfileurl"

torrentfilecontent=$(curl -L --globoff $torrentfileurl)
desttorrentfile=$torrentwatchloc/$(date +%s).torrent
echo "$torrentfilecontent" > $desttorrentfile
echo "torrent file downloaded successfully, located at $desttorrentfile"