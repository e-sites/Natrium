#!/bin/sh
# Check to see if the environment pre-action is succesful
export PATH

MYPATH="`dirname \"$0\"`"
FILE="${MYPATH}/.__environment.log"
if [ ! -f "$FILE" ]; then
    echo "Log file ($FILE) not found"
    exit 1
fi
LOG=`cat $FILE`
rm $FILE
if [[ $LOG =~ ^Error:* ]]; then
  echo $LOG
  echo ""
  exit 1
fi
