#!/bin/sh

# Project name value may be passed in from previous auth script
# ELSE: Set project name here OR follow the cmd line prompt when running script.
AUTH_FILE=qa_auth_url.txt
PROJECT_NAME=$1
AUTH_URL_PASSWORD=$2

if [ -z "$PROJECT_NAME" ]
then
      read -p "Enter project name " PROJECT_NAME
fi

QA="${PROJECT_NAME}QA"
LOGIN_URL="https://test.salesforce.com"

echo "" && echo "Authenticating to QA org..."
sfdx force:auth:web:login -a ${QA} -r ${LOGIN_URL}

if [ "$?" = "1" ]
then
	echo "" && echo "ERROR: Authorizization with the ${QA} org failed!" && echo ""
	exit
else
    echo "" && echo "SUCCESS: Authenticated to project QA org!" && echo ""
fi

# Obtain authenticated login url to QA org
echo "Creating authentication file ..."
sfdx force:org:display -u ${QA} --verbose | grep "Sfdx Auth Url" | sed -E 's/^Sfdx Auth Url[[:blank:]]*(.*)$/\1/' > ${AUTH_FILE}

if [ "$?" = "1" ]
then
	echo "" && echo "ERROR: Problem accessing ${QA} org details!" && echo ""
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

echo "QA auth setup completed!" && echo ""

exit
