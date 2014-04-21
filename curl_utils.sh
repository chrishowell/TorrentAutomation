#/bin/bash

. ./cleansing_utils.sh

getcontent() {
  url=$(cleanse_url "$1")
  echo $(curl --globoff -L "$url")
}

getfile() {
  url=$(cleanse_url "$2")
  curl -L --globoff -o "$1" "$url"
}
