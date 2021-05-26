#!/bin/bash -l

# This script will create a PROMOTED package version for tentative release.
# Only released package versions can be listed on AppExchange and installed in customer orgs.
# Prior to running the script, it is expected that the package has been fully-tested (incl. unit tests and adequate code coverage) and is release-ready.

# IMPORTANT! Replace with the actual project name!
PROJECT_NAME=MyProject

set -e

if ! grep "\"$PROJECT_NAME\"," sfdx-project.json; then
    echo 'Specified package does not exist! Double check the package name. Exiting ... '
    exit
fi

#ADMIN_PERMSET_NAME="${PROJECT_NAME}AdminUserPermissions"
#USER_PERMSET_NAME="${PROJECT_NAME}StandardUserPermissions"

# Check if this is a new version release
# TODO: redo version check flow to directly modify version info based on prompt instead of requiring manual modifcation before running script
echo "Package versions with same MAJOR.MINOR.PATCH can only be released once!"
read -p "Is this a new version release and have you updated version information in the package configuration file? y/n: " NEW_VER

if [[ "$NEW_VER" != 'y' ]] ; then
    echo "Ensure you have updated the version number in the package configuration file (sfdx-project.json) then rerun this script."
    exit
fi

# Create a new package version for promotion
echo "Create package version for promotion..."
sfdx force:package:version:create --package "$PROJECT_NAME" --installationkeybypass --codecoverage --wait 15

if [ "$?" = "1" ]; then
	echo "" && echo "ERROR: Problem creating release-ready package version! Ensure passing unit tests and code coverage! Exiting ..."
    exit 1
fi

PKG_VER_ID=$(grep "${PROJECT_NAME}" sfdx-project.json | tail -1 | sed -E 's/^.*"(04t[[:alnum:]]*)"$/\1/')

# Promote package
echo "Promote package ${PROJECT_NAME} for release ..."
sfdx force:package:version:promote --package "$PKG_VER_ID" --noprompt
echo "Package version has been promoted!"

# TODO: Specify a specific pre-release (non-scratch) org for testing?
# Generate a fresh test scratch org to install the package
# Ensure namespace is NOT applied to this org since this is to simulate a customer install
echo "Install promoted package to temporary scratch org for final testing ... "
if sfdx force:org:list | grep "${PROJECT_NAME}PackageTestOrg"; then
    echo "Deleting pre-existing test scratch org ..."
    sfdx force:org:delete -u "${PROJECT_NAME}PackageTestOrg" -p
fi
sfdx force:org:create --nonamespace --definitionfile config/project-scratch-def.json --setalias "${PROJECT_NAME}PackageTestOrg"
echo "Test scratch org created."

echo "Preparing to test install PROMOTED package ${PROJECT_NAME} ... "
sfdx force:package:install --package "$PKG_VER_ID" --targetusername "${PROJECT_NAME}PackageTestOrg" --noprompt --wait -1

if [ "$?" = "1" ]
then
	echo "" && echo "ERROR: Problem installing test package!"
	exit
else
    echo "Package install successful!"
fi

unset PKG_VER_ID

# Deploy dev artifacts to the scratch org
#sleep 60
#echo ""
#echo "Deploying dev artifacts to the scratch org..."
#echo ""
#sfdx force:source:deploy -p force-dev --targetusername "${PROJECT_NAME}PackageTestOrg" --json
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
#sfdx force:user:permset:assign -n ${ADMIN_PERMSET_NAME} -u "${PROJECT_NAME}PackageTestOrg" --json
#echo ""
#if [ "$?" = "1" ]
#then
#	echo "ERROR: Assigning a project permission set to the default scratch org user failed!"
#	exit
#fi
#sfdx force:user:permset:assign -n ${USER_PERMSET_NAME} -u "${PROJECT_NAME}PackageTestOrg" --json
#echo ""
#if [ "$?" = "1" ]
#then
#	echo "ERROR: Assigning a project permission set to the default scratch org user failed!"
#	exit
#fi
#echo "SUCCESS: Project permission sets assigned successfully to the default scratch org user!"

echo ""
echo "Opening scratch org for final testing before official release!"
echo ""
sleep 3
sfdx force:org:open --targetusername "${PROJECT_NAME}PackageTestOrg"

exit
