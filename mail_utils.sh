#!/bin/bash

. ./mail_config.sh
. ./cleansing_utils.sh

MBOX="INBOX"

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

  command="tag $@"
  echo "$command" >&5

  OUTPUT=""

  while read -t 2 result; do
    line="`echo "$result" | tr '\r' ' '`"
    OUTPUT=$OUTPUT$'\n'$line

    echo "$line" | grep "^tag OK" >/dev/null && return 0
    echo "$line" | grep "^tag NO" >/dev/null && echo "imap:error:$line" && return 1
    echo "$line" | grep "^tag BAD" >/dev/null && echo "imap:error:$line" && return 1
  done <&6

  return 1
}

function imap_logout() {
  imap_send "logout"
  rm -f ./.ncin ./.ncout
  return 0
}

function imap_select_mbox() {
  local mbox

  mbox=$1
  [ -z "$mbox" ] && MBOX="$MBOX" || MBOX="$mbox"

  imap_send "select" "$MBOX"
  [ "$?" != 0 ] && return 1 || return 0
}

function imap_search() {
  RESULT=""
  imap_send "search" $@
  [ "$?" != 0 ] && return 1

  RESULT=`echo "$OUTPUT" | grep "^* SEARCH" | sed 's,.*SEARCH \(.*[0-9]*\).*,\1,'`
  return 0
}

function imap_status() {
  RESULT=''
  imap_send "status" "$MBOX" "(UNSEEN MESSAGES)"
  [ "$?" != 0 ] && return 1
  RESULT=`echo "$OUTPUT" | grep "^* STATUS"`
  resultregex="MESSAGES ([0-9]+) UNSEEN ([0-9]+)"
  if [[ $RESULT =~ $resultregex ]]; then
    RESULT='Messages: '${BASH_REMATCH[1]}' Unread: '${BASH_REMATCH[2]}
  fi
}

function imap_delete() {
  local uid
  uid=$1

  imap_send "store" "$uid" "flags" "\\Deleted"
  [ "$?" != 0 ] && return 1 || return 0
}

function imap_subject() {
  local uid
  uid=$1

  imap_send "fetch" "$uid (BODY[HEADER.FIELDS (subject)])"
  [ "$?" != 0 ] && return 1

  subjectregex=".*?\{[0-9]+\}.*?Subject:[ ]*(.*?)\)"

  if [[ $OUTPUT =~ $subjectregex ]]; then
#strange
    RESULT="${BASH_REMATCH[1]}"
    RESULT=$(trim "$RESULT")
  fi
}

function imap_body() {
  local uid
  uid=$1

  RESULT=''

  imap_send "fetch" "$uid (BODY[TEXT])"
  [ "$?" != 0 ] && return 1

  bodyregex=".*?\{[0-9]+\}[ ]*(.*?)\)"

  if [[ $OUTPUT =~ $bodyregex ]]; then
#strange
    RESULT="${BASH_REMATCH[1]}"
    RESULT="$(trim $RESULT)"
  fi
}
