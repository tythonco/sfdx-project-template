#!/bin/bash -l

# This script uses SFDX to generate a new version of a package, creating the package if needed.
# Package versions are what actually get installed into Orgs.
# Prior to running this script and generating the package, it is expected the developer:
# - Verified that all package components are in the project directory where you want to create the package
# - Setup the Namespace and specified the "namespace" key in sfdx-project.json
# 2GP workflow documentation see: https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_dev2gp_workflow.htm

# IMPORTANT! Replace with the actual project name!
PROJECT_NAME=MyProject

set -e

# Guess the package directory from entered name
PKG_PATH=$(echo "$PROJECT_NAME"\
    | sed -E 's/[[:blank:]]+([a-z0-9])/\U\1/gi'\
    | sed -E 's/_([A-Z0-9])/\U\1/gi'\
    | sed -E 's/-([A-Z0-9])/\U\1/gi'\
    | sed -E 's/^([A-Z0-9])/\l\1/')

read -p "Is this the correct package path: ${PKG_PATH}? y/n " ACCEPT_PATH

# Ensure package folder name and existence
if [[ "$ACCEPT_PATH" != 'y' ]] ; then
    read -p "Enter directory path to this package (relative to project root): " PKG_PATH
fi

if [[ ! -d "$PKG_PATH" ]]; then
    echo "Package directory does not exist!"
    exit 1
fi

# Check if package has already been created; If not, create package now
if grep "\"$PROJECT_NAME\"," sfdx-project.json; then
    echo 'This package has already been created! Moving on to versioning ... '
else
    echo "Creating the package ${PROJECT_NAME}."
    read  -p "Is this a Managed package (and Namespace is prepared)? y/n " PKG_TYPE
    test "$PKG_TYPE" == 'y' && PKG_TYPE='Managed' || PKG_TYPE='Unlocked'
    sfdx force:package:create --name "$PROJECT_NAME" --packagetype "$PKG_TYPE" --path "$PKG_PATH"
fi

#
# TODO: A step for updating the newly-generated package's configuration fields can go here (see package.json)
#

# Optionally skip validation for rapid development
# NOTE: When readying for release, a validated version is mandatory for package promotion
read -p "Temporarily skip validation in package version creation? " SKIP_VALIDATION

# Create package version
# NOTE: Version ID based on convention noted in package:version:report cmd doc: "ID (starts with 04t)"
if [ "$SKIP_VALIDATION" == 'y' ]; then
    echo "Creating new version of package ${PROJECT_NAME} ... skipping validation ..."
    PACKAGE_VER_ID=$(sfdx force:package:version:create --package "$PROJECT_NAME" --installationkeybypass --wait 15 --skipvalidation \
    | grep login.salesforce.com \
    | sed -E 's/^.*(04t[[:alnum:]]*)$/\1/')
else
    echo "Creating new version of package ${PROJECT_NAME} ..."
    PACKAGE_VER_ID=$(sfdx force:package:version:create --package "$PROJECT_NAME" --installationkeybypass --wait 15 \
    | grep login.salesforce.com \
    | sed -E 's/^.*(04t[[:alnum:]]*)$/\1/')
fi

echo "Successfully generated package with version ID: ${PACKAGE_VER_ID}"

# Optionally install this new package version into a test scratch org for immediate testing
while true; do
    read -p "Continue with test org installation? y/n " TEST_INSTALL
    case "$TEST_INSTALL" in
        [Yy]* ) source scripts/install-test-package.sh;;
        [Nn]* ) break;;
        * ) echo "y/n.";;
    esac
done
