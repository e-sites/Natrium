#!/bin/sh
# Shell script to forward xcode build settings to the ruby script
export PATH

MYPATH="`dirname \"$0\"`"

ruby "${MYPATH}/environmentbuild.rb" --project_dir "${PROJECT_DIR}" --target "${TARGET_NAME}" --infoplist_file "${INFOPLIST_FILE}" --configuration "${CONFIGURATION}" --environment $1 > "${MYPATH}/.__environment.log"
