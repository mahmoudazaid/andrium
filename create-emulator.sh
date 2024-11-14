#!/bin/bash

# Color codes for output
BL='\033[0;34m'
G='\033[0;32m'
RED='\033[0;31m'
YE='\033[1;33m'
NC='\033[0m' # No Color

# Exit immediately if a command exits with a non-zero status
set -e

# Emulator Configuration
EMULATOR_NAME="${EMULATOR_NAME:-"emu"}"

# Ensure the AVD directory is set correctly
if [ -z "$ANDROID_AVD_HOME" ]; then
    export ANDROID_AVD_HOME="$HOME/.android/avd"
fi

# Create required emulator if it doesn't exist
if [ -d "$ANDROID_AVD_HOME/${EMULATOR_NAME}.avd" ]; then
    echo -e "${G}==> Emulator ${EMULATOR_NAME} already exists. Skipping creation.${NC}"
else
    echo -e "${G}==> ${BL}Creating Emulator: ${YE}${EMULATOR_NAME}${NC}"
    avdmanager --verbose create avd --force --name "${EMULATOR_NAME}" --device "${EMULATOR_DEVICE}" --package "${EMULATOR_PACKAGE}"
fi

# Verify if the .ini file exists for the created AVD
AVD_INI_FILE="$ANDROID_AVD_HOME/${EMULATOR_NAME}.ini"
if [ ! -f "$AVD_INI_FILE" ]; then
    echo -e "${RED}Error: .ini file for AVD ${EMULATOR_NAME} not found at ${AVD_INI_FILE}. Exiting.${NC}"
    exit 1
fi

echo -e "${G}==> Emulator ${EMULATOR_NAME} created successfully.${NC}"