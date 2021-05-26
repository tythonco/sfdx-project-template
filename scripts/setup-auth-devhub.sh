#!/bin/sh

# Set project name here or follow the cmd line prompt when running script.
AUTH_FILE=sfdx_auth_url.txt
PROJECT_NAME=""

if [ -z "$PROJECT_NAME" ]
then
      echo ""
      read -p "Enter project name " PROJECT_NAME
      echo ""
else
      echo "Project name is set as: ${PROJECT_NAME}" && echo ""
fi

DEVHUB_NAME="${PROJECT_NAME}DevHub"

# Conditionally abort if not the project starter
while true; do
    read -p "Are you the project starter? " PROJECT_STARTER
    case $PROJECT_STARTER in
        [Yy]* ) break;;
        [Nn]* ) source scripts/setup-auth-decrypt.sh ${PROJECT_NAME};;
        * ) echo "y/n.";;
    esac
done

# modify files that ref generic project_name: scripts/setup-auth-devhub.sh (this file), scripts/create-scratch-org.sh, config/project-scratch-def.json, & README
sed -E -i.bak -e "s/^PROJECT_NAME=.*$/PROJECT_NAME=${PROJECT_NAME}/" scripts/setup-auth-devhub.sh
sed -E -i.bak -e "s/^PROJECT_NAME=.*$/PROJECT_NAME=${PROJECT_NAME}/" scripts/create-scratch-org.sh && rm scripts/*.bak
sed -E -i.bak -e "s/^PROJECT_NAME=.*$/PROJECT_NAME=${PROJECT_NAME}/" scripts/bootstrap-package.sh && rm scripts/*.bak
sed -E -i.bak -e "s/^PROJECT_NAME=.*$/PROJECT_NAME=${PROJECT_NAME}/" scripts/create-package-version.sh && rm scripts/*.bak
sed -E -i.bak -e "s/^PROJECT_NAME=.*$/PROJECT_NAME=${PROJECT_NAME}/" scripts/install-test-package.sh && rm scripts/*.bak
sed -E -i.bak -e "s/^PROJECT_NAME=.*$/PROJECT_NAME=${PROJECT_NAME}/" scripts/prep-release-package.sh && rm scripts/*.bak
sed -E -i.bak -e "s/\"Tython\",/\"${PROJECT_NAME}\",/" config/project-scratch-def.json && rm config/*.bak
sed -E -i.bak -e "s/\"devs@tython.co\"$/\"$(echo ${PROJECT_NAME} | tr '[:upper:]' '[:lower:]')@tython.co\"/" config/project-scratch-def.json && rm config/*.bak
sed -E -i.bak -e "s/Tython SFDX Project Template/${PROJECT_NAME} Project/" README.md && rm README.md.bak
sed -E -i.bak -e "s/\"MyProject\",/\"${PROJECT_NAME}\",/" package.json && rm *.bak
sed -E -i.bak -e "s/\"MyProject\",/\"${PROJECT_NAME}\",/" package-lock.json && rm *.bak

echo "Authenticating to DevHub org..."
sfdx force:auth:web:login -a ${DEVHUB_NAME} -r https://login.salesforce.com

if [ "$?" = "1" ]
then
	echo "" && echo "ERROR: Authorizization with the ${DEVHUB_NAME} org failed!"
	exit
else
    echo "" && echo "SUCCESS: Authenticated to project DevHub org!" && echo ""
fi

# Obtain authenticated login url to DevHub org
echo "Creating authentication file ..."
sfdx force:org:display -u ${DEVHUB_NAME} --verbose | grep "Sfdx Auth Url" | sed -E 's/^Sfdx Auth Url[[:blank:]]*(.*)$/\1/' > ${AUTH_FILE}

if [ "$?" = "1" ]
then
	echo "" && echo "ERROR: Problem accessing ${DEVHUB_NAME} org details!"
	exit
else
    echo "" && echo "SUCCESS: Authentication file created as ${AUTH_FILE}." && echo ""
fi

# Encrypt auth file
read -p "Enter password to encrypt this file (password will be securely shared w/ team) " AUTH_URL_PASSWORD
openssl enc -aes-256-cbc -md md5 -k ${AUTH_URL_PASSWORD} -in ${AUTH_FILE} -out ${AUTH_FILE}.enc
echo "File has been encrypted as: ${AUTH_FILE}.enc" && echo ""

echo "Initial setup completed!"
echo "Running 'npm start' should now work to create new scratch orgs." && echo ""
echo "Next steps for project setup:"
echo "1) Repeat auth process for Prod org (if different from DevHub) and QA org (optional) "
echo "2) Continue CI/CD confg in CI interface"
echo "3) Setup secure password share for the encrypted Auth_URL file(s)" && echo ""

bash scripts/setup-auth-prod.sh ${PROJECT_NAME} ${AUTH_FILE} ${AUTH_URL_PASSWORD}

# Conditionally continue to QA auth setup flow.
while true; do
    read -p "Continue with QA org authentication? (Requires project sandbox org to have been created) " CONTINUE_QA
    case $CONTINUE_QA in
        [Yy]* ) source scripts/setup-auth-qa.sh ${PROJECT_NAME} ${AUTH_URL_PASSWORD};;
        [Nn]* ) break;;
        * ) echo "y/n.";;
    esac
done
