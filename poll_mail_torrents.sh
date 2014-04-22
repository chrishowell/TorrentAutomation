#!/bin/bash

. ./mail_utils.sh
. ./cleansing_utils.sh

# Helper Functions

processmessage() {
  subject=$(trim "$1")
  body=$(trim "$2")

  /home/chris/torrent/.scripts/auto_download.sh "$body" "$subject"
}

# Actual Script

imap_login
[ "$?" != 0 ] \
  && imap_logout \
  && exit 1

# Select the Torrents mailbox
imap_select_mbox "Torrents"
[ "$?" != 0 ] \
  && imap_logout \
  && exit 1

# Check for unread messages
imap_status
[ "$?" != 0 ] \
  && imap_logout \
  && exit 1

unreadregex="Unread: ([1-9][0-9]*)"
if [[ $RESULT =~ $unreadregex ]]; then
  echo ${BASH_REMATCH[1]}' unread messages, starting processing'
else
  echo 'no unread messages, stopping processing'
  exit 0
fi

# Get the body of any unread emails
imap_search "HEADER X-Originating-Email $monitor_email"
[ "$?" != 0 ] \
  && imap_logout \
  && exit 1
IFS=' ' read -a messageids <<< "$RESULT"

for messageid in "${messageids[@]}"
do
    imap_subject $messageid
    subject="$RESULT"
    imap_body $messageid
    body="$RESULT"
    processmessage "$subject" "$body"
    if [ "$?" != 0 ]; then
      continue
    fi

#    imap_delete $messageid
done

# Logout
imap_logout
[ "$?" != 0 ] \
  && exit 1
