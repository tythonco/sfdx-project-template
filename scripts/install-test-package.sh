#!/bin/bash -l

# This script attempts to install a freshly created package version into a temporary test scratch org.
# Requires that a Package version ID was successfully generated in prior step.

set -e

TEST_ORG="PackageTestOrg"

if [ -z "$PACKAGE_VER_ID" ]; then
    echo "No package version specified for install! Exiting ... "
    exit 1
fi

echo "Install package to temporary scratch org for testing with version ID: ${PACKAGE_VER_ID} ... "

# Check if "PackageTestOrg" already exists, delete if it does
if sfdx force:org:list | grep "$TEST_ORG"; then
    echo "Pre-existing test scratch org detected! Deleting ..."
    sfdx force:org:delete -u "$TEST_ORG" -p
fi

# Generate a fresh scratch org to install the package
sfdx force:org:create --definitionfile config/project-scratch-def.json --setalias "$TEST_ORG"

# Install the package and open the new scratch org for testing
sfdx force:package:install --package "$PACKAGE_VER_ID" --targetusername "$TEST_ORG"

unset PACKAGE_VER_ID

echo ""
echo "Opening scratch org for testing, may the Flow be with you!"
echo ""
sleep 3
sfdx force:org:open --targetusername "$TEST_ORG"

exit
