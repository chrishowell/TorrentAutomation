#!/bin/bash

. ./mail_config.sh

function imap_login() {
  local user passwd

  user=$mail_user
  passwd=$mail_passwd

  rm -f ./.ncin ./.ncout
  mkfifo ./.ncin ./.ncout
  exec 5<>./.ncin 6<>./.ncout

  openssl s_client -crlf -quiet -connect $mail_server:$mail_port <&5 >&6 &

  imap_send "login" "$user" "$passwd"
  [ "$?" != 0 ] && return 1 || return 0
}

function imap_send() {
  local result line

  echo "tag $@" >&5
  OUTPUT=""

  while read -t 2 result; do
    line="`echo "$result" | tr '\r' ' '`"
    OUTPUT=$OUTPUT$'\n'$line

    echo "$line" | grep "^tag OK" >/dev/null
# && return 0
    echo "$line" | grep "^tag NO" >/dev/null && echo "imap:error:$line" && return 1
  done <&6

  echo "$OUTPUT"

  return 0
}

function imap_logout() {
  imap_send "logout"
  rm -f ./.ncin ./.ncout
  return 0
}

function imap_select_mbox() {
  local mbox

  mbox=$1
  [ -z "$mbox" ] && mbox=INBOX

  imap_send "select" "$mbox"
  [ "$?" != 0 ] && return 1 || return 0
}

function imap_search() {
  RESULT=""
  imap_send "search" $@
  [ "$?" != 0 ] && return 1

  RESULT=`echo "$OUTPUT" | grep "^* SEARCH" | sed 's,.*SEARCH \(.*[0-9]*\).*,\1,'`
  return 0
}

function imap_delete() {
  local uid

  uid=$1

  imap_send "store" "$uid" "flags" "\\Deleted"
  [ "$?" != 0 ] && return 1 || return 0
}
