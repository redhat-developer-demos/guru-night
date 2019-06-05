#!/bin/bash

set -e

_CURR_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
source $_CURR_DIR/setEnv.sh

echo "Generating Workshop Users"

PASSWORD=${USER_PASSWORD:-'open$hif1!'}
# keep this name avoids setting key in the oc secret command
PASSWORD_FILE="$WORK_DIR/htpasswd"
ADMIN_USER_NAME="ocpadmin"

if [ ! -f $PASSWORD_FILE ];
then
    printf "$PASSWORD_FILE file does not exist, creating"
    touch "$PASSWORD_FILE"
else
  printf "$PASSWORD_FILE file alreay exist resetting"
  : > "$PASSWORD_FILE"
fi

i=$USERS_FROM
j=$USERS_TO
while [[ $i -le $j ]];
do
  echo "Creating user $USER_SUFFIX$i"  
  htpasswd -b $PASSWORD_FILE "$USER_SUFFIX$i" $PASSWORD
  ((i++))
done

# Add openshift cluster admin user
htpasswd -b $PASSWORD_FILE $ADMIN_USER_NAME $ADMIN_PASSWORD

# Create user secret in OpenShift
! oc -n openshift-config delete secret htpass-secret
oc -n openshift-config create secret generic htpass-secret --from-file="$PASSWORD_FILE"

#TODO delete the existing OAuth named htpassidp
# Add the users to OpenShift OAuth
oc -n openshift-config get oauth cluster -o yaml | yq w - -s $CONFIGS_DIR/htpass.yaml | oc apply -f -

# sleep for 30 seconds for the pods to be restarted
echo "Wait for 30s for new OAuth to take effect"
sleep 30

# Make the admin as cluster admin
oc adm policy add-cluster-role-to-user cluster-admin $ADMIN_USER_NAME 

