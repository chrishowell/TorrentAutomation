#/bin/bash

trim() {
  trailingnl=$"s/\n//"
  trailingcr=$"s/\r//"
  echo -e `echo "$1" | sed -e 's/ *$//' -e "$trailingnl" -e "$trailingcr"`
}

cleanse_url() {
  url=`echo "$1"|sed 's/ /%20/g'`
  echo $url
}
