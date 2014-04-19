#/bin/bash

. ./mail_config.sh

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

logerror() {
  errorstring="ABANDON-PROCESS: $1"
  echo $errorstring
  echo $errorstring | mail -s "ABANDON-PROCESS" $monitor_email
}

logwarning() {
  warningstring="PROCESS-WARNING $1"
  echo $warningstring
  echo $warningstring | mail -s "PROCESS-WARNING" $monitor_email
}

torrentzcontent=$(curl -L $torrentzurl)
if [[ $torrentzcontent =~ (http:\/\/$limetorrentstub\/[^\"]*)\" ]]; then
  torrenturl=$BASH_REMATCH[1]
  echo "found limetorrent torrent page at $torrenturl"
else
  logerror "did not find limetorrent torrent page at $torrentzurl"
  exit 1
fi

if [[ $torrentzcontent =~ (/announcelist_[^\"]*)\" ]]; then
  trackerurl=$torrentzbaseurl$BASH_REMATCH[1]
  echo "found limetorrent tracker page at $trackerurl"
  trackercontent=$(curl -L --globoff -o $temptrackerfiledest $trackerurl)
  echo "tracker file downloaded successfully, located at $temptrackerfiledest"
else
  logwarning "did not find torrent tracker file at $torrentzurl"
fi

torrentcontent=$(curl -L $torrenturl)
if [[ $torrentcontent =~ (http:\/\/www.limetorrents.com\/download\/[^\"]*)\" ]]; then
  torrentfileurl=$BASH_REMATCH[1]
  echo "found torrent file at $torrentfileurl"
else
  logerror "did not find torrent file at $torrentfileurl"
  exit 1
fi

desttorrentfile=$torrentwatchloc/$(date +%s).torrent
torrentfilecontent=$(curl -L --globoff -o $temptorrentfiledest $torrentfileurl)
echo "torrent file downloaded successfully, located at $temptorrentfiledest"

$torrentutility -a -noconfirm "$temptrackerfiledest" "$temptorrentfiledest"

mv $temptorrentfiledest $torrentfiledest
rm $temptrackerfiledest
echo "PROCESS-COMPLETE: torrent file placed into watch directory"
