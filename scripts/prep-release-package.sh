#!/bin/bash -l

# This script will create a PROMOTED package version for tentative release.
# Only released package versions can be listed on AppExchange and installed in customer orgs.
# Prior to running the script, it is expected that the package has been fully-tested (incl. unit tests and adequate code coverage) and is release-ready.

set -e

# Get the package name and the package directory
read -p "Enter package name: " PKG_NAME

if ! grep "\"$PKG_NAME\"," sfdx-project.json; then
    echo 'Specified package does not exist! Double check the package name. Exiting ... '
    exit
fi

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
sfdx force:package:version:create --package "$PKG_NAME" --installationkeybypass --codecoverage --wait 15

if [ "$?" = "1" ]; then
	echo "" && echo "ERROR: Problem creating release-ready package version! Ensure passing unit tests and code coverage! Exiting ..."
    exit 1
fi

PKG_VER_ID=$(grep "Test Package 1" sfdx-project.json | tail -1 | sed -E 's/^.*"(04t[[:alnum:]]*)"$/\1/')

# Promote package
echo "Promote package ${PKG_NAME} for release ..."
sfdx force:package:version:promote --package "$PKG_VER_ID" --noprompt
echo "Package version has been promoted!"

# TODO: Specify a specific pre-release (non-scratch) org for testing?
# Generate a fresh test scratch org to install the package
echo "Install promoted package to temporary scratch org for final testing ... "
if sfdx force:org:list | grep 'PackageTestOrg'; then
    echo "Deleting pre-existing test scratch org ..."
    sfdx force:org:delete -u PackageTestOrg -p
fi
sfdx force:org:create --definitionfile config/project-scratch-def.json --setalias PackageTestOrg
echo "Test scratch org created."

echo "Preparing to test install PROMOTED package ${PKG_NAME} ... "
sfdx force:package:install --package "$PKG_VER_ID" --targetusername PackageTestOrg --noprompt --wait -1

if [ "$?" = "1" ]
then
	echo "" && echo "ERROR: Problem installing test package!"
	exit
else
    echo "Package install successful!"
fi

unset PKG_VER_ID

echo ""
echo "Opening scratch org for final testing before official release!"
echo ""
sleep 3
sfdx force:org:open --targetusername PackageTestOrg

exit
