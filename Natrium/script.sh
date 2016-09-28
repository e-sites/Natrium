#!/bin/sh
# Shell script to forward xcode build settings to the ruby script

MYPATH="${PROJECT_DIR}/Pods/Natrium/Natrium"
EXEC="ruby \"${MYPATH}/environmentbuild.rb\" --project_dir \"${PROJECT_DIR}\" --target \"${TARGET_NAME}\" --infoplist_file \"${INFOPLIST_FILE}\" --configuration \"${CONFIGURATION}\" --environment $1 > \"${MYPATH}/.__environment.log\""

if [[ $(ls -A ~/.bashrc) ]]; then
  EXEC="source ~/.bashrc && $EXEC"
elif [[ $(ls -A ~/.bash_profile) ]]; then
  EXEC="source ~/.bash_profile && $EXEC"
elif [[ $(ls -A ~/.profile) ]]; then
  EXEC="source ~/.profile && $EXEC"
fi
$(bash -l -c  "$EXEC")
