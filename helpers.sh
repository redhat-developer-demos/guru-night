BLACK='\e[1;30m'        # Black
RED='\e[0;31m'          # Red
GREEN='\e[1;32m'        # Green
YELLOW='\e[1;33m'       # Yellow
header_color="$YELLOW"
reset=$'\e[0m'

NO_COLOR=${NO_COLOR:-""}

if [ -z "$NO_COLOR" ]; then
  header_color="$BLACK"
  reset=$'\e[0m'
else
  header=''
  reset=''
fi

function header_text {
  printf "$header_color$*$reset"
}

function log_waiting {
  printf "$YELLOW$*$reset"
}

function log_error {
  printf "$RED$*$reset"
}

function log_success {
  printf "$GREEN$*$reset"
}

function csv_status {
 local timeout=30
 header_color="$YELLOW"
 header_text "Checking status of subscription : '$1'"
 local csv=$(kubectl get subscriptions -n openshift-operators \
   $1 -ojsonpath="{.status.installedCSV}")
 local csvStatus=$(kubectl get csv -n openshift-operators "${csv}" \
   -ojsonpath="{.status.phase}" 2>/dev/null)
 
 if $(hasflag --verbose -v); then
   header_text "Status of $csv : '$csvStatus'"
 fi

 # make sure the csv has value
 while [ -z "$csv" ];
 do
  log_waiting "\n Waiting for '$1' CSV ...\n"
  csv=$(kubectl get subscriptions -n openshift-operators \
   "${1}" -ojsonpath="{.status.installedCSV}")
 done

 local cmd_time=5
 while [ "$csvStatus" != "Succeeded" ];
 do   
   log_waiting "\n Waiting for '$1' to be installed and ready ...\n"
   
   sleep 5
   ((cmd_time+=5))

   csvStatus=$(kubectl get csv -n openshift-operators $csv \
   -ojsonpath="{.status.phase}" 2>/dev/null)

   if $(hasflag --verbose -v); then
     log_waiting "Current Status of $1 : $csvStatus"
   fi

   if [[ "$csvStatus" != "Succeeded" && $cmd_time -ge $timeout ]];
   then
    log_error "\n[ERR] Timed out waiting for '$1' to be installed and ready \n"
    exit 1;
   fi
 done

 return 0
}

# Checks if a flag is present in the arguments.
hasflag() {
  local flags="$@"
  for var in $ARGS; do
    for flag in $flags; do
      if [ "$var" = "$flag" ]; then
        echo 'true'
        return
      fi
    done
  done
  echo 'false'
}

# Read the value of an option.
readopt() {
  local opts="$@"
  for var in $ARGS; do
    for opt in $opts; do
      if [[ "$var" = ${opt}* ]]; then
        # TODO space handling
        local value="${var//${opt}=/}"
        if [ "$value" != "$var" ]; then
          # Value could be extracted
          echo $value
          return
        fi
      fi
    done
  done
  # Nothing found
  echo ""
}

check_error() {
  local msg="$*"
  if [ "${msg//ERROR/}" != "${msg}" ]; then
    echo "${msg}"
    exit 1
  fi
}

function create_project {
 # wait for project creation
 local pStatus=$(oc get project $1 -o jsonpath="{.status.phase}" 2>/dev/null)
 
 if [ "$pStatus" != "Active" ]; then
   oc adm new-project "$1" \
     --description="Project $1"
 fi

 pStatus=$(oc get project $1 -o jsonpath="{.status.phase}" 2>/dev/null)
 
 while [ "$pStatus" != "Active" ]
 do   
   header_text "\n Waiting for $1 to be created  ...\n"
   sleep 2
 done

 echo "$1"
}