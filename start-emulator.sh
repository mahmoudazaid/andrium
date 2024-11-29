#!/bin/bash

# Color codes for output
BL='\033[0;34m'
G='\033[0;32m'
RED='\033[0;31m'
YE='\033[1;33m'
NC='\033[0m' # No Color

# Emulator Configurations
EMULATOR_NAME="${EMULATOR_NAME:-emu}"
EMULATOR_TIMEOUT="${EMULATOR_TIMEOUT:-300}"
NETWORK_CONNECTION="${NETWORK_CONNECTION:-wifi}"

# Function to terminate existing emulator instances
function terminate_existing_emulators() {
    echo -e "${G}==> ${BL}Terminating any existing emulator instances...${NC}"
    if adb devices | grep emulator; then
        adb devices | grep emulator | cut -f1 | xargs -I {} adb -s "{}" emu kill
    fi
}

# Function to launch the emulator
function launch_emulator() {
    terminate_existing_emulators
    echo -e "${G}==> ${BL}Starting emulator: ${YE}${EMULATOR_NAME}${NC}"

    # Start emulator with specified parameters
    emulator -avd "${EMULATOR_NAME}" -no-window -no-snapshot -noaudio -camera-back emulated -no-boot-anim -memory 2048 &
    sleep 5

    # Ensure the emulator started successfully
    if ! pgrep -f "${EMULATOR_NAME}" &> /dev/null; then
        echo -e "${RED}Error: Failed to start the emulator. Please check your configuration.${NC}"
        exit 1
    fi
}

# Function to check if the emulator has fully booted
function check_emulator_status() {
    echo -e "${G}==> ${BL}Checking emulator boot status 🧐${NC}"
    start_time=$(date +%s)
    spinner=( "⠹" "⠺" "⠼" "⠶" "⠦" "⠧" "⠇" "⠏" )
    i=0

    while true; do
        result=$(adb shell getprop sys.boot_completed 2>&1)
        if [[ "$result" == "1" ]]; then
            echo -e "${G}==> \u2713 Emulator is ready: sys.boot_completed = '$result'${NC}"
            adb shell input keyevent 82 # Unlock screen
            break
        elif [[ -z "$result" ]]; then
            echo -ne "${YE}==> Emulator partially booted ${spinner[$i]} ${NC}\r"
        else
            echo -ne "${RED}==> Status: $result - waiting ${spinner[$i]} ${NC}\r"
            i=$(( (i + 1) % 8 ))
        fi
        
        # Check for timeout
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        if [ $elapsed_time -gt $EMULATOR_TIMEOUT ]; then
            echo -e "${RED}==> Timeout: ${EMULATOR_TIMEOUT} seconds elapsed. Exiting.${NC}"
            exit 1
        fi
        sleep 5
    done
}

# Function to disable animations for smoother emulator performance
function disable_animation() {
    echo -e "${G}==> ${BL}Disabling emulator animations for improved performance${NC}"
    adb shell "settings put global window_animation_scale 0.0"
    adb shell "settings put global transition_animation_scale 0.0"
    adb shell "settings put global animator_duration_scale 0.0"
}

# Function to configure hidden API policies
function hidden_policy() {
    echo -e "${G}==> ${BL}Setting hidden API policies${NC}"
    adb shell "settings put global hidden_api_policy_pre_p_apps 1"
    adb shell "settings put global hidden_api_policy_p_apps 1"
    adb shell "settings put global hidden_api_policy 1"
}

# Function to configure network based on environment variable
function configure_network() {
    echo -e "${G}==> ${BL}Configuring emulator network based on environment settings${NC}"

    case "${NETWORK_CONNECTION}" in
        "wifi")
            echo -e "${G}==> ${YE}Enabling Wi-Fi and disabling mobile data${NC}"
            adb shell svc wifi enable
            adb shell svc data disable
            ;;
        "data")
            echo -e "${G}==> ${YE}Disabling Wi-Fi and enabling mobile data${NC}"
            adb shell svc wifi disable
            adb shell svc data enable
            ;;
        *)
            echo -e "${RED}Error: Invalid value for NETWORK_CONNECTION. Expected 'wifi' or 'data'.${NC}"
            echo -e "${YE}Example:${NC} export NETWORK_CONNECTION=wifi or export NETWORK_CONNECTION=data${NC}"
            exit 1
            ;;
    esac
}

# Function to check if the desired network connection is active and the other is disabled
function verify_network_status() {
    echo -e "${G}==> ${BL}Verifying the active network connection...${NC}"
    
    case "${NETWORK_CONNECTION}" in
        "wifi")
            wifi_status=$(adb shell dumpsys wifi | grep "Wi-Fi is" | awk '{print $3}')
            data_status=$(adb shell dumpsys connectivity | grep "NetworkInfo:" | grep -m 1 MOBILE | grep -o "state: CONNECTED")
            
            if [[ "$wifi_status" == "enabled" && -z "$data_status" ]]; then
                echo -e "${G}==> \u2713 Wi-Fi is enabled and mobile data is disabled.${NC}"
            else
                echo -e "${RED}Error: Network misconfiguration. Expected Wi-Fi enabled and mobile data disabled.${NC}"
                exit 1
            fi
            ;;
        "data")
            data_status=$(adb shell dumpsys connectivity | grep "NetworkInfo:" | grep -m 1 MOBILE | grep -o "state: CONNECTED")
            wifi_status=$(adb shell dumpsys wifi | grep "Wi-Fi is" | awk '{print $3}')
            
            if [[ "$data_status" == "state: CONNECTED" && "$wifi_status" == "disabled" ]]; then
                echo -e "${G}==> \u2713 Mobile data is enabled and Wi-Fi is disabled.${NC}"
            else
                echo -e "${RED}Error: Network misconfiguration. Expected mobile data enabled and Wi-Fi disabled.${NC}"
                exit 1
            fi
            ;;
        *)
            echo -e "${RED}Error: Invalid network type for verification.${NC}"
            exit 1
            ;;
    esac
}

# Function to check network connectivity
function check_network_connectivity() {
    echo -e "${G}==> ${BL}Checking network connectivity...${NC}"
    if ! adb shell ping -c 4 8.8.8.8 &> /dev/null; then
        echo -e "${RED}==> Network connectivity check failed!${NC}"
        exit 1
    fi
    echo -e "${G}==> Network is connected!${NC}"
}

# Check if adb and emulator commands are available
if ! command -v adb &> /dev/null || ! command -v emulator &> /dev/null; then
    echo -e "${RED}Error: 'adb' or 'emulator' command not found. Ensure Android SDK is installed and in PATH.${NC}"
    exit 1
fi

# Check if the emulator exists
if ! emulator -list-avds | grep -q "${EMULATOR_NAME}"; then
    echo -e "${RED}Error: Emulator '${EMULATOR_NAME}' not found. Please create the AVD first.${NC}"
    exit 1
fi

# Execute functions in sequence
launch_emulator
check_emulator_status
disable_animation
hidden_policy
configure_network
verify_network_status
check_network_connectivity
