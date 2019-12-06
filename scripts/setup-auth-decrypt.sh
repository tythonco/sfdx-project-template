#!/bin/sh

PROJECT_NAME=$1
DEVHUB_NAME="${PROJECT_NAME}DevHub"
PROD_NAME="${PROJECT_NAME}Prod"
QA_NAME="${PROJECT_NAME}QA"
AUTH_FILE=sfdx_auth_url.txt
PROD_AUTH_FILE=prod_auth_url.txt
QA_AUTH_FILE=qa_auth_url.txt

if [ -z "$PROJECT_NAME" ]
then
      read -p "Enter project name " PROJECT_NAME
fi

echo ""
read -p "Enter password securely shared w/ team for auth file encryption/decryption " AUTH_URL_PASSWORD

# Decrypt Prod auth file
if openssl enc -d -aes-256-cbc -md md5 -in ${PROD_AUTH_FILE}.enc -out ${PROD_AUTH_FILE} -k ${AUTH_URL_PASSWORD} ; then
    echo ""
else
    echo "" && echo "ERROR: Problem decrypting auth file, please double-check your password and verify ${PROD_AUTH_FILE}.enc exists in the source"
    exit
fi

# Conditionally set up an alias for the Prod org, unless it is the same as the DevHub org
while true; do
    read -p "Is the production org the same as the DevHub org? (This is the case in most instances except for ISV projects) " DEVHUB_IS_PROD
    case $DEVHUB_IS_PROD in
        [Yy]* ) break;;
        [Nn]* ) echo "" && echo "Authenticating to Prod org..." && sfdx force:auth:sfdxurl:store -f ${PROD_AUTH_FILE} -a ${PROD_NAME} && break;;
        * ) echo "y/n.";;
    esac
done

# Conditionally decrypt QA auth file & set up an alias for the QA org
if [ -f "${QA_AUTH_FILE}.enc" ]; then
    echo "" && echo "Authenticating to QA org"
    if openssl enc -d -aes-256-cbc -md md5 -in ${QA_AUTH_FILE}.enc -out ${QA_AUTH_FILE} -k ${AUTH_URL_PASSWORD} ; then
        sfdx force:auth:sfdxurl:store -f ${QA_AUTH_FILE} -a ${QA_NAME}
    else
        echo "" && echo "ERROR: Problem decrypting auth file, please double-check your password and verify ${QA_AUTH_FILE}.enc exists in the source"
        exit
    fi
fi

# Decrypt DevHub auth file & set up an alias for the DevHub org
echo "" && echo "Authenticating to DevHub org..."
if openssl enc -d -aes-256-cbc -md md5 -in ${AUTH_FILE}.enc -out ${AUTH_FILE} -k ${AUTH_URL_PASSWORD} ; then
    sfdx force:auth:sfdxurl:store -f ${AUTH_FILE} -d -a ${DEVHUB_NAME}
    echo "" && echo "Initial setup completed!" && echo "Running 'npm start' should now work to create new scratch orgs."
else
    echo "" && echo "ERROR: Problem decrypting auth file, please double-check your password and verify ${AUTH_FILE}.enc exists in the source"
    exit
fi

exit
