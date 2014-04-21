#/bin/bash

normalise() {
  read normal <<< $1
  echo "$normal"
}

trim() {
  trimmed=`echo -e "$1" | sed 's/ *$//' | sed 's/ *\n$//' | sed 's/\n$//'`
  echo -e "$trimmed"
}

cleanse_url() {
  url=`echo "$1"|sed 's/ /%20/g'`
  echo "$url"
}
