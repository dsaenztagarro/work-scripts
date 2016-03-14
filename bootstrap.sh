#!/usr/bin/env bash

DEFAULT_EXTRA_FILE="macbook"

while [[ $# > 0 ]]
do
key="$1"

case $key in
    -e|--extra)
      EXTRA_FILE="$2"
      shift # past argument
      ;;
    -d|--defaults)
      EXTRA_FILE="${DEFAULT_EXTRA_FILE}"
      ;;
    *)
      # unknown option
      ;;
esac
shift # past argument or value
done

EXTRA_FILEPATH="extra/${EXTRA_FILE}.sh"

if [ -n "${EXTRA_FILE}" ]
then
  echo EXTRA_FILE = "${EXTRA_FILE}"
  echo EXTRA_FILEPATH = "${EXTRA_FILEPATH}"

  if [ -f $EXTRA_FILEPATH ]
  then
    cp -f $EXTRA_FILEPATH ~/.extra
    echo INFO: Overriden .extra file with "${EXTRA_FILEPATH}"
  else
    echo ERROR: Unable to find "${EXTRA_FILEPATH}"
    exit 1
  fi
else
  echo Examples of use:
  echo ./bootstrap.sh --extra EXTRA
  echo ./bootstrap.sh --defaults
  exit 1
fi

cd "$(dirname "${BASH_SOURCE}")";

git pull origin master;

function doIt() {
  rsync --exclude ".git/" --exclude "bootstrap.sh" \
    --exclude "docs/" --exclude "README.md" \
    -avh --no-perms --verbose . ~;
  source ~/.bash_profile;
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
  doIt;
else
  read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
  echo "";
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    doIt;
  fi;
fi;
unset doIt;
