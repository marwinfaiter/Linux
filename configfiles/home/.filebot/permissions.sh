#!/bin/bash

if [[ $1 =~ Movies ]]; then
chown -R :sambashare "$1";
chmod 750 "$1";

else
  if [[ `stat -c %a "$3"` != "750" ]]; then
  chmod 750 "$3";
  fi
  if [[ `stat -c %a "$1"` != "750" ]]; then
  chmod 750 "$1";
  fi
chown -R :sambashare "$3";
fi

chmod 640 "$2";
