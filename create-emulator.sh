#!/bin/bash

BL='\033[0;34m'
G='\033[0;32m'
RED='\033[0;31m'
YE='\033[1;33m'
NC='\033[0m' # No Color

# Check if required environment variables are set
if [ -z "${EMULATOR_NAME}" ]; then
    echo -e "${RED}Error: One or more required environment variables (EMULATOR_NAME) are not set. Exiting.${NC}"
    exit 1
fi

# Check if required environment variables are set
if [ -z "${EMULATOR_DEVICE}" ]; then
    echo -e "${RED}Error: One or more required environment variables (EMULATOR_DEVICE) are not set. Exiting.${NC}"
    exit 1
fi

# Check if required environment variables are set
if [ -z "${EMULATOR_PACKAGE}" ]; then
    echo -e "${RED}Error: One or more required environment variables (EMULATOR_PACKAGE) are not set. Exiting.${NC}"
    exit 1
fi

# Ensure the AVD directory is set correctly
if [ -z "$ANDROID_AVD_HOME" ]; then
    export ANDROID_AVD_HOME="$HOME/.android/avd"
fi

# Create required emulator
echo -e "${G}==> ${BL}Creating Emulator with the following details:${NC}"
echo -e "${G}- Name: ${YE}${EMULATOR_NAME}${NC}"
echo -e "${G}- Device: ${YE}${EMULATOR_DEVICE}${NC}"
echo -e "${G}- Package: ${YE}${EMULATOR_PACKAGE}${NC}"

# Create the AVD using avdmanager
if ! avdmanager --verbose create avd --force --name "${EMULATOR_NAME}" --device "${EMULATOR_DEVICE}" --package "${EMULATOR_PACKAGE}"; then
    echo -e "${RED}Error: Failed to create emulator. Ensure the device and package are correct.${NC}"
    exit 1
fi

# Check if the .ini file exists for the created AVD
AVD_INI_FILE="$ANDROID_AVD_HOME/${EMULATOR_NAME}.ini"
if [ ! -f "$AVD_INI_FILE" ]; then
    echo -e "${RED}Error: .ini file for AVD ${EMULATOR_NAME} not found at ${AVD_INI_FILE}. Exiting.${NC}"
    exit 1
fi

echo -e "${G}==> Emulator ${EMULATOR_NAME} created successfully.${NC}"