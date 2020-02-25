#!/bin/bash -l

AUTH_FILE_KEY=$1
TARGET_ALIAS=$2
DEPLOY_ID=$3
AUTH_URL="${TARGET_ALIAS,,}_auth_url.txt"
ENC_AUTH_URL="${AUTH_URL}.enc"

echo "CI-Deploy: Setting up connection to org with user/alias ... ${TARGET_ALIAS}"

if test -f "$ENC_AUTH_URL" ; then
    openssl enc -d -aes-256-cbc -md md5 -in "$ENC_AUTH_URL" -out "$AUTH_URL" -k "$AUTH_FILE_KEY"
else
    echo "Required file missing: ${ENC_AUTH_URL}! Exiting!"
    exit 1
fi

if test -f "$AUTH_URL" ; then
    # Authenticate to salesforce Prod org
    echo "Authenticating..."
    sfdx force:auth:sfdxurl:store -f "$AUTH_URL" -a "$TARGET_ALIAS" && rm "$AUTH_URL"

    # If not provided, get deploy ID from prev successful step
    echo "Fetch Deploy ID and perform quick deployment ..."
    if [ -z "$DEPLOY_ID" ] ; then
        DEPLOY_ID=$(sfdx force:mdapi:deploy:report -u "$TARGET_ALIAS" | grep "jobid" | sed -E 's/^jobid:[[:blank:]]*(.*)$/\1/')
    fi
    sfdx force:mdapi:deploy -u "$TARGET_ALIAS"  -w -1 -q "$DEPLOY_ID"

    if [ "$?" = "1" ] ; then
        echo "Problem encountered during deploy! Exiting!"
        exit 1
    fi
else
    echo "There was a problem generating ${AUTH_URL} file! Exiting!"
    exit 1
fi
