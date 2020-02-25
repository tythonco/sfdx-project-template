#!/bin/bash -l

AUTH_FILE_KEY=$1
TARGET_ALIAS=$2
AUTH_URL="${TARGET_ALIAS,,}_auth_url.txt"
ENC_AUTH_URL="${AUTH_URL}.enc"

echo "CI-Validate: Setting up connection to Salesforce org with user/alias ... ${TARGET_ALIAS}"

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
    #Convert to MDAPI format for validation against prod
    echo "Converting to MDAPI format..."
    sfdx force:source:convert -d deploy_components -r force-app
    #Simulate deployment to prod & run all tests
    echo "Validating against production by simulating a deployment & running all tests..."
    sfdx force:mdapi:deploy -c -d deploy_components -u "$TARGET_ALIAS" -l RunLocalTests -w -1

    if [ "$?" = "1" ]
    then
        echo "Problem encountered during check deploy! Exiting!"
        exit 1
    fi
else
    echo "There was a problem generating ${AUTH_URL} file! Exiting!"
    exit 1
fi
