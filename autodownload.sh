#/bin/bash

torrentzurl=$1
torrentzbaseurl=http://torrentz-proxy.com
limetorrentstub=www.limetorrents.com
torrentwatchloc=/home/chris/torrent/watch
temploc=/home/chris/torrent/.scripts/temp
uniquecode=$(date +%s)
torrentutility=/home/chris/torrent/.scripts/addtrackers.pl

temptorrentfiledest=$temploc/$uniquecode.torrent
temptrackerfiledest=$temploc/$uniquecode.tracker
torrentfiledest=$torrentwatchloc/$uniquecode.torrent

torrentzcontent=$(curl -L $torrentzurl)
[[ $torrentzcontent =~ (http:\/\/$limetorrentstub\/[^\"]*)\" ]] && torrenturl=${BASH_REMATCH[1]}
echo "found limetorrent torrent page at $torrenturl"

[[ $torrentzcontent =~ (/announcelist_[^\"]*)\" ]] && trackerurl=$torrentzbaseurl${BASH_REMATCH[1]}
echo "found limetorrent tracker page at $trackerurl"

trackercontent=$(curl -L --globoff -o $temptrackerfiledest $trackerurl)
echo "tracker file downloaded successfully, located at $temptrackerfiledest"

torrentcontent=$(curl -L $torrenturl)
[[ $torrentcontent =~ (http:\/\/www.limetorrents.com\/download\/[^\"]*)\" ]] && torrentfileurl=${BASH_REMATCH[1]}
echo "found torrent file at $torrentfileurl"

desttorrentfile=$torrentwatchloc/$(date +%s).torrent
torrentfilecontent=$(curl -L --globoff -o $temptorrentfiledest $torrentfileurl)
echo "torrent file downloaded successfully, located at $temptorrentfiledest"

$torrentutility -a -noconfirm "$temptrackerfiledest" "$temptorrentfiledest"

cp $temptorrentfiledest $torrentfiledest
echo "PROCESS-COMPLETE: torrent file placed into watch directory"
