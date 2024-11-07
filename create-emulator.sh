#!/bin/bash

BL='\033[0;34m'
G='\033[0;32m'
RED='\033[0;31m'
YE='\033[1;33m'
NC='\033[0m' # No Color

# Check if required environment variables are set
if [ -z "${EMULATOR_NAME}" ] || [ -z "${EMULATOR_DEVICE}" ] || [ -z "${EMULATOR_PACKAGE}" ]; then
    echo "One or more required environment variables (EMULATOR_NAME, EMULATOR_DEVICE, EMULATOR_PACKAGE) are not set. Exiting."
    exit 1
fi

#============================================
# Create required emulator
#============================================
printf "${G}==>  ${BL}Creating Emulator With the following aspects:\n \
         ${G}-name: ${YE}${EMULATOR_NAME} \n \
         ${G}-Device type: ${YE}${EMULATOR_DEVICE} \n \
         ${G}-Package: ${YE}${EMULATOR_PACKAGE}\
<==${NC}\n"

if ! echo "no" | avdmanager --verbose create avd --force --name "${EMULATOR_NAME}" --device "${EMULATOR_DEVICE}" --package "${EMULATOR_PACKAGE}"; then
    printf "${RED}Error: Failed to create emulator.${NC}\n"
    exit 1
fi
