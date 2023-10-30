#!/bin/sh

source utils.bash
PROJECT_NAME="$(project_name)"
DEVHUB_NAME="$(devhub_name)"
#ADMIN_PERMSET_NAME="${PROJECT_NAME}AdminUserPermissions"
#USER_PERMSET_NAME="${PROJECT_NAME}StandardUserPermissions"
SFDX_AUTH_URL=sfdx_auth_url.txt

# SAMPLE DATA: Define your sample data, uncomment below while updating comma-separated data
# file names DATA_IMPORT_FILES=data/SomeObjects1.json,data/MySettings.json,data/EtcEtc.json

echo ""
echo "Authorizing you with the ${PROJECT_NAME} Dev Hub org..."
echo ""
sf auth sfdxurl store \
    --sfdx-url-file ${SFDX_AUTH_URL} \
    --set-default-dev-hub \
    --alias ${DEVHUB_NAME} \
    --json
echo ""
if [ "$?" = "1" ]
then
	echo "ERROR: Can't authorize you with the ${PROJECT_NAME} Dev Hub org!"
	exit
fi
echo "SUCCESS: You've been authorized with the ${PROJECT_NAME} Dev Hub org!"

echo ""
echo "Building your scratch org, please wait..."
echo ""
sf org create scratch \
    --target-dev-hub ${DEVHUB_NAME} \
    --definition-file config/project-scratch-def.json \
    --set-default \
    --alias ${PROJECT_NAME} \
    --duration-days 21 \
    --json
echo ""
if [ "$?" = "1" ]
then
	echo "ERROR: Can't create your org!"
	exit
fi
echo "SUCCESS: Scratch org created!"

echo ""
echo "Pushing source to the scratch org! This may take a while! So now might be a good time to stretch your legs and/or grab your productivity beverage of choice..."
echo ""
sf project deploy start --json
echo ""
if [ "$?" = "1" ]
then
	echo "ERROR: Pushing source to the scratch org failed!"
	exit
fi
echo "SUCCESS: Source pushed successfully to the scratch org!"

#echo ""
#echo "Deploying dev artifacts to the scratch org..."
#echo ""
#sfdx force:source:deploy -p force-dev --json
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
#sfdx force:user:permset:assign -n ${ADMIN_PERMSET_NAME} --json
#echo ""
#if [ "$?" = "1" ]
#then
#	echo "ERROR: Assigning a project permission set to the default scratch org user failed!"
#	exit
#fi
#sfdx force:user:permset:assign -n ${USER_PERMSET_NAME} --json
#echo ""
#if [ "$?" = "1" ]
#then
#	echo "ERROR: Assigning a project permission set to the default scratch org user failed!"
#	exit
#fi
#echo "SUCCESS: Project permission sets assigned successfully to the default scratch org user!"

echo ""
echo "Importing default data to the scratch org..."
echo ""
echo "TODO: Data import!!! Create your sample data and uncomment below!"
# sfdx force:data:tree:import -f ${DATA_IMPORT_FILES} --json
echo ""
if [ "$?" = "1" ]
then
	echo "ERROR: Importing default data to the scratch org failed!"
	exit
fi
echo "SUCCESS: Default data was successfully imported to the scratch org!"

echo ""
echo "Running anonymous Apex scripts against the scratch org for additional configuration..."
echo ""
echo "TODO: Setup any objects e.g. user roles, if needed! Needs external apex script!"
# sfdx force:apex:execute -f scripts/setup.apex --json
echo ""
if [ "$?" = "1" ]
then
	echo "ERROR: Running anonymous Apex scripts against the scratch org failed!"
	exit
fi
echo "SUCCESS: Successfully ran anonymous Apex scripts against the scratch org!"

sf project reset tracking --no-prompt

echo ""
echo "Opening scratch org for development, may the Flow be with you!"
echo ""
sleep 3
sf org open
