#!/bin/bash

set -eu
NL=$'\n'
NS=${1:-'tutorial'}

while [[ true ]]; do
 for (( i = 0; i < 70; i++ )); do
  URL="helloworld-$i-$NS.apps.azr.workspace7.org"
  echo "Calling URL: $URL"

  RESP_CODE=$(http --headers $URL |\
     grep 'HTTP/' |\
     awk '{print $2}')
  if [ $RESP_CODE != 200 ];
  then
     echo "Error getting route '$URL', $NL expecting 200 but got $RESP_CODE"
  fi
 done

done
