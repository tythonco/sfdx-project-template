#!/bin/sh

# Project name & DevHub Auth File values may be passed in from previous auth script
# ELSE: Set project name and DevHub auth file values here OR follow the cmd line prompt when running script.
AUTH_FILE=prod_auth_url.txt
PROJECT_NAME=$1
DEV_HUB_AUTH_FILE=$2
AUTH_URL_PASSWORD=$3

if [ -z "$PROJECT_NAME" ]
then
      read -p "Enter project name " PROJECT_NAME
fi

if [ -z "$DEV_HUB_AUTH_FILE" ]
then
      read -p "Enter DevHub Auth File (.txt file) " DEV_HUB_AUTH_FILE
fi

# Conditionally continue to Prod auth setup flow, unless the Prod Org is the DevHub Org
while true; do
    read -p "Is the production org the same as the DevHub org? (This is the case in most instances except for ISV projects) " DEVHUB_IS_PROD
    case $DEVHUB_IS_PROD in
        [Yy]* ) cp ${DEV_HUB_AUTH_FILE} ${AUTH_FILE} && cp ${DEV_HUB_AUTH_FILE}.enc ${AUTH_FILE}.enc && echo "" && exit;;
        [Nn]* ) break;;
        * ) echo "y/n.";;
    esac
done

PROD="${PROJECT_NAME}Prod"

echo "" && echo "Authenticating to Prod org..."
sfdx force:auth:web:login -a ${PROD}

if [ "$?" = "1" ]
then
	echo "" && echo "ERROR: Authorizization with the ${PROD} org failed!"
	exit
else
    echo "" && echo "SUCCESS: Authenticated to project Prod org!" && echo ""
fi

# Obtain authenticated login url to Prod org
echo "Creating authentication file ..."
sfdx force:org:display -u ${PROD} --verbose | grep "Sfdx Auth Url" | sed -E 's/^Sfdx Auth Url[[:blank:]]*(.*)$/\1/' > ${AUTH_FILE}

if [ "$?" = "1" ]
then
	echo "" && echo "ERROR: Problem accessing ${PROD} org details!"
	exit
else
    echo "" && echo "SUCCESS: Authentication file created as ${AUTH_FILE}." && echo ""
fi

# Encrypt auth file
if [ -z "$AUTH_URL_PASSWORD" ]
then
      read -p "Enter password to encrypt this file " AUTH_URL_PASSWORD
fi
openssl enc -aes-256-cbc -md md5 -k ${AUTH_URL_PASSWORD} -in ${AUTH_FILE} -out ${AUTH_FILE}.enc
echo "File has been encrypted as: ${AUTH_FILE}.enc" && echo ""

echo "Prod auth setup completed!" && echo ""

exit
