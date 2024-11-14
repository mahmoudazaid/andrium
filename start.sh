#!/bin/bash

/opt/emulator/start-emulator.sh &

if [ "$APPIUM" = "true" ]; then
    /opt/appium/start-appium.sh
else
    tail -f /dev/null
fi