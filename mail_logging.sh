#/bin/bash

. ./mail_config.sh

maillog_info() {
  infostring="PROCESS-INFO: $1"
  echo $infostring
  echo $infostring | mail -s "PROCESS-INFO" $monitor_email
}

maillog_error() {
  errorstring="PROCESS-ERROR: $1"
  echo $errorstring
  echo $errorstring | mail -s "PROCESS-ERROR" $monitor_email
}

maillog_warning() {
  warningstring="PROCESS-WARNING: $1"
  echo $warningstring
  echo $warningstring | mail -s "PROCESS-WARNING" $monitor_email
}
