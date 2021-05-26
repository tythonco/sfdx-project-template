#!/bin/bash -l

# This script creates the starting directory structure for a new package and optionally runs SFDX package:create
# If choosing to generate the package when running this script, it is expected the developer:
# - Setup the Namespace and specified the "namespace" key in sfdx-project.json
# 2GP workflow documentation see: https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_dev2gp_workflow.htm

# IMPORTANT! Replace with the actual project name!
PROJECT_NAME=MyProject
DEVHUB_NAME="${PROJECT_NAME}DevHub"

set -e

if grep "\"$PROJECT_NAME\"," sfdx-project.json; then
    echo 'This package has already been created! Exiting ... '
    exit 1
fi

# Guess the package directory from entered name
PKG_PATH=$(echo "$PROJECT_NAME"\
    | sed -E 's/[[:blank:]]+([a-z0-9])/\U\1/gi'\
    | sed -E 's/_([A-Z0-9])/\U\1/gi'\
    | sed -E 's/-([A-Z0-9])/\U\1/gi'\
    | sed -E 's/^([A-Z0-9])/\l\1/')

read -p "Is this the desired package path: ${PKG_PATH}? y/n " ACCEPT_PATH

# Ensure package folder name and existence
if [[ "$ACCEPT_PATH" != 'y' ]] ; then
    read -p "Enter directory path to this package (relative to project root): " PKG_PATH
fi

# Generate folder structure for new module
mkdir -p "force-app"
mkdir -p "$PKG_PATH"
mkdir -p "${PKG_PATH}/core"
mkdir -p "${PKG_PATH}/core/default"

echo "Generated directories for new module ${PROJECT_NAME}."
echo "You can run SFDX package create step now."
echo "NOTE: Namespace must already be prepared and entered in sfdx-project.json. This can also be done later when creating test package versions."
read -p "Create package now? y/n " RUN_CREATE

# Check if package has already been created; If not, create package now
if [[ "$RUN_CREATE" == 'y' ]]; then
    echo "Creating the package ${PROJECT_NAME}."
    read  -p "Is this a Managed package (and Namespace is prepared)? y/n " PKG_TYPE
    test "$PKG_TYPE" == 'y' && PKG_TYPE='Managed' || PKG_TYPE='Unlocked'
    sfdx force:package:create -v ${DEVHUB_NAME} --name "$PROJECT_NAME" --packagetype "$PKG_TYPE" --path "$PKG_PATH"
fi

echo "Package bootstrapped! May the Flow be with you!"

exit
