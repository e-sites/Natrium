#!/bin/sh
# Check to see if the environment pre-action is succesful
export PATH

MYPATH="`dirname \"$0\"`"
FILE="${MYPATH}/.natrium.log"

LOG=`cat $FILE`
rm $FILE
if [[ $LOG =~ ^error:* ]]; then
  echo $LOG
  echo ""
  exit 1
fi
if [[ $LOG =~ ^warning:* ]]; then
  echo $LOG
fi
