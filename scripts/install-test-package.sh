#!/bin/bash -l

# This script attempts to install a freshly created package version into a temporary test scratch org.
# Requires that a Package version ID was successfully generated in prior step.

# IMPORTANT! Replace with the actual project name!
PROJECT_NAME=MyProject

set -e

TEST_ORG="${PROJECT_NAME}PackageTestOrg"
#ADMIN_PERMSET_NAME="${PROJECT_NAME}AdminUserPermissions"
#USER_PERMSET_NAME="${PROJECT_NAME}StandardUserPermissions"


if [ -z "$PACKAGE_VER_ID" ]; then
    PACKAGE_VER_ID=$(grep "${PROJECT_NAME}" sfdx-project.json | tail -1 | sed -E 's/^.*"(04t[[:alnum:]]*)"$/\1/')
fi

echo "Install package to temporary scratch org for testing with version ID: ${PACKAGE_VER_ID} ... "

# Check if "PackageTestOrg" already exists, delete if it does
if sfdx force:org:list | grep "$TEST_ORG"; then
    echo "Pre-existing test scratch org detected! Deleting ..."
    sfdx force:org:delete -u "$TEST_ORG" -p
fi

# Generate a fresh scratch org to install & test the package
# Ensure namespace is NOT applied to this org since this is to simulate a customer install
sfdx force:org:create --nonamespace --definitionfile config/project-scratch-def.json --setalias "$TEST_ORG"

# Install the package
sfdx force:package:install --package "$PACKAGE_VER_ID" --targetusername "$TEST_ORG"

unset PACKAGE_VER_ID

# Deploy dev artifacts to the scratch org
#sleep 60
#echo ""
#echo "Deploying dev artifacts to the scratch org..."
#echo ""
#sfdx force:source:deploy -p force-dev --targetusername "$TEST_ORG" --json
#echo ""
#if [ "$?" = "1" ]
#then
#	echo "ERROR: Deploying dev artifacts to the scratch org failed!"
#	exit
#fi
#echo "SUCCESS: Dev artifacts deployed successfully to the scratch org!"


#echo ""
#echo "Assigning project permission sets to the default scratch org user..."
#echo ""
#sfdx force:user:permset:assign -n ${ADMIN_PERMSET_NAME} -u "$TEST_ORG" --json
#echo ""
#if [ "$?" = "1" ]
#then
#	echo "ERROR: Assigning a project permission set to the default scratch org user failed!"
#	exit
#fi
#sfdx force:user:permset:assign -n ${USER_PERMSET_NAME} -u "$TEST_ORG" --json
#echo ""
#if [ "$?" = "1" ]
#then
#	echo "ERROR: Assigning a project permission set to the default scratch org user failed!"
#	exit
#fi
#echo "SUCCESS: Project permission sets assigned successfully to the default scratch org user!"

echo ""
echo "Opening scratch org for testing, may the Flow be with you!"
echo ""
sleep 3
sfdx force:org:open --targetusername "$TEST_ORG"

exit
