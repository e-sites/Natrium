#!/bin/sh

CONTENTS=`cat Sources/Natrium.swift`
REGEX='var version: String = "([0-9\.]+)"'
if [[ "$CONTENTS" =~ $REGEX ]]
then
   echo ${BASH_REMATCH[1]}
else
  echo "1.0.0"
fi
