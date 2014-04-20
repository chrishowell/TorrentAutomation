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

# Logging

loginfo() {
  infostring="PROCESS-INFO: $1"
  echo $infostring
  echo $infostring | mail -s "PROCESS-INFO" $monitor_email
}

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

# CURLing

getcontent() {
  url=$(cleanseurl "$1")
  echo $(curl --globoff -L "$url")
}

getfile() {
  url=$(cleanseurl "$2")
  curl -L --globoff -o "$1" "$url"
}

cleanseurl() {
  url=`echo "$1"|sed 's/ /%20/g'`
  echo $url
}

# Script

torrentzcontent=$(getcontent "$torrentzurl")
if [[ $torrentzcontent =~ (http:\/\/$limetorrentstub\/[^\"]*)\" ]]; then
  torrenturl=${BASH_REMATCH[1]}
  echo "found limetorrent torrent page at $torrenturl"
else
  logerror "did not find limetorrent torrent page at $torrentzurl"
  exit 1
fi

if [[ $torrentzcontent =~ (/announcelist_[^\"]*)\" ]]; then
  trackerurl=$torrentzbaseurl${BASH_REMATCH[1]}
  echo "found limetorrent tracker page at $trackerurl"
  getfile "$temptrackerfiledest" "$trackerurl"
  echo "tracker file downloaded successfully, located at $temptrackerfiledest"
else
  logwarning "did not find torrent tracker file at $torrentzurl"
fi

torrentcontent=$(getcontent "$torrenturl")
if [[ $torrentcontent =~ (http:\/\/www.limetorrents.com\/download\/[^\"]*)\" ]]; then
  torrentfileurl=${BASH_REMATCH[1]}
  echo "found torrent file at $torrentfileurl"
else
  logerror "did not find torrent file at $torrenturl"
  exit 1
fi

getfile "$temptorrentfiledest" "$torrentfileurl"
echo "torrent file downloaded successfully, located at $temptorrentfiledest"

$torrentutility -a -noconfirm "$temptrackerfiledest" "$temptorrentfiledest"

mv $temptorrentfiledest $torrentfiledest
rm $temptrackerfiledest
loginfo "torrent download in progress"
