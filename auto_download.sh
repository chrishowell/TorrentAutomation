#/bin/bash

. ./cleansing_utils.sh
. ./curl_utils.sh
. ./mail_logging.sh

torrentzurl=$1
torrentname=$2

[[ -z $torrentname ]] && torrentname="Unnamed Torrent"

torrentzbaseurl=http://torrentz-proxy.com
limetorrentstub=www.limetorrents.com
torrentwatchloc=/home/chris/torrent/watch
temploc=/home/chris/torrent/.scripts/temp
uniquecode=$torrentname$(date +%s)
torrentutility=/home/chris/torrent/.scripts/addtrackers.pl

temptorrentfiledest=$temploc/$uniquecode.torrent
temptrackerfiledest=$temploc/$uniquecode.tracker
torrentfiledest=$torrentwatchloc/$uniquecode.torrent

# Logging

loginfo() {
  maillog_info "$1 for $torrentname"
}

logerror() {
  maillog_error "$1 for torrentname"
}

logwarning() {
  maillog_warning "$1 for torrentname"
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

#mv $temptorrentfiledest $torrentfiledest
rm "$temptrackerfiledest"
loginfo "torrent download in progress"
