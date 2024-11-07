#!/bin/bash

BL='\033[0;34m'
G='\033[0;32m'
RED='\033[0;31m'
YE='\033[1;33m'
NC='\033[0m' # No Color

function launch_emulator () {
    adb devices | grep emulator | cut -f1 | xargs -I {} adb -s "{}" emu kill
    echo "Starting ${EMULATOR_NAME}"
    if ! emulator -avd "${EMULATOR_NAME}" -no-window -no-snapshot -noaudio -camera-back emulated -no-boot-anim -memory 2048; then
        printf "${RED}Error: Failed to launch emulator.${NC}\n"
        exit 1
    fi
}

function check_emulator_status () {
    printf "${G}==> ${BL}Checking emulator booting up status 🧐${NC}\n"
    start_time=$(date +%s)
    spinner=( "⠹" "⠺" "⠼" "⠶" "⠦" "⠧" "⠇" "⠏" )
    i=0

    while true; do
        result=$(adb shell getprop sys.boot_completed 2>&1)
        if [ "$result" == "1" ]; then
            printf "\e[K${G}==> \u2713 Emulator is ready : '$result'           ${NC}\n"
            adb shell input keyevent 82
            break
        elif [ "$result" == "" ]; then
            printf "${YE}==> Emulator is partially Booted! 😕 ${spinner[$i]} ${NC}\r"
        else
            printf "${RED}==> $result, please wait ${spinner[$i]} ${NC}\r"
            i=$(( (i + 1) % 8 ))
        fi
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if [ $elapsed_time -gt $EMULATOR_TIMEOUT ]; then
            printf "${RED}==> Timeout after ${EMULATOR_TIMEOUT} seconds elapsed 🕛.. ${NC}\n"
            exit 1
        fi
        sleep 20
    done
}

function disable_animation() {
    adb shell "settings put global window_animation_scale 0.0"
    adb shell "settings put global transition_animation_scale 0.0"
    adb shell "settings put global animator_duration_scale 0.0"
}

function hidden_policy() {
    adb shell "settings put global hidden_api_policy_pre_p_apps 1; settings put global hidden_api_policy_p_apps 1; settings put global hidden_api_policy 1"
}

function forwared_port(){
    # Get the IP address of the container (interface eth0)
    ip=$(ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
    socat tcp-listen:5554,bind=$ip,fork tcp:127.0.0.1:5554 &
    socat tcp-listen:5555,bind=$ip,fork tcp:127.0.0.1:5555
}

launch_emulator
check_emulator_status
disable_animation
hidden_policy
forwared_port