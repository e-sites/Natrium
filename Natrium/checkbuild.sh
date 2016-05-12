#!/bin/sh
# Check to see if the environment pre-action is succesful
export PATH

FILE="./.__environment.log"
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
