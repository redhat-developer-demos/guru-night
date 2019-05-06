#!/bin/bash

set -e

echo "Generating Workshop Users"

PASSWORD='r3dh4t1!'
PASSWORD_FILE='./userpass'

for i in {200..400}
do
  echo "Creating user $dev$i"
  if [ ! -f userpass ];
  then
     printf "$PASSWORD_FILE file does not exist, creating"
     touch "$PASSWORD_FILE"
  fi
  # printf "$dev$i:$(openssl passwd -crypt $PASSWORD)\n" >>$PASSWORD_FILE
  htpasswd -b userpass "dev$i" $PASSWORD
done
