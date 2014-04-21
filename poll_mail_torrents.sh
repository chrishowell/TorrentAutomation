#!/bin/bash

. ./mail_utils.sh

echo "Starting login"
imap_login
[ "$?" != 0 ] \
  && imap_logout \
  && exit 1

echo "Starting select"
imap_select_mbox "Torrents"
[ "$?" != 0 ] \
  && imap_logout \
  && exit 1

echo "Starting status"
imap_status
[ "$?" != 0 ] \
  && imap_logout \
  && exit 1

echo "Starting search"

imap_search "SUBJECT" "Torrent"

echo "Starting logout"
imap_logout
[ "$?" != 0 ] \
  && exit 1
