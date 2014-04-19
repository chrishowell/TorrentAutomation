#!/bin/bash

. ./mail_utils.sh

imap_login
[ "$?" != 0 ] \
  && printf "imap_error:login\n$OUTPUT\n" \
  && imap_logout \
  && exit 1

echo "Hello"

imap_select_mbox

imap_send "STATUS" "INBOX" "(MESSAGES)"

imap_logout

exit 0
