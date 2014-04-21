#/bin/bash

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

#take in torrent name
torrentname=$1

#do some cleansing
if [[ $torrentname =~ (.*?(19|20)[0-9]{2}) ]]; then
  torrentname=${BASH_REMATCH[1]}
fi

#Normalise spaces
torrentname=${torrentname//./ }
torrentname=${torrentname//\-/ }

#Remove any funnychars
torrentname=${torrentname//\(/}

#Replace spaces with plus
torrentname=${torrentname// /+}

imdbsearchurl="http://www.imdb.com/find?q=$torrentname&s=tt"
imdbsearchcontent=$(getcontent $imdbsearchurl)

if [[ $imdbsearchcontent =~ \"(/title/[^\"]*) ]]; then
  titleurl="http://www.imdb.com${BASH_REMATCH[1]}"
else
  echo "ERROR:could not find title"
  exit 1
fi

titlecontent=$(getcontent $titleurl)
if [[ $titlecontent =~ Poster\"[[:space:]]src=\"([^\"]*) ]]; then
  posterurl="${BASH_REMATCH[1]}"
else 
  echo "ERROR:could not find Poster"
  exit 1
fi

titleregex="<span class=\"itemprop\" itemprop=\"name\">([^<]*?)"
if [[ $titlecontent =~ $titleregex ]]; then
  titlename="${BASH_REMATCH[1]}"
fi

if [[ $titlecontent =~ href=\"/year/([^/]*) ]]; then
  year="${BASH_REMATCH[1]}"
fi

echo "Title: $titlename"
echo "Year: $year"
echo "IMDB URL: $titleurl"
echo "Poster URL: $posterurl"

getfile "/home/chris/torrent/.scripts/temp/$titlename ($year).jpg" "$posterurl"
