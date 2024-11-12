# Set Build Tools and API Level
ARG ANDROID_VERSION=15
FROM mahmoudazaid/android:${ANDROID_VERSION}

# Environment Settings
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ="Europe/Berlin"

# Set working directory
WORKDIR /

#=================================
# Install Essential Dependencies
#=================================
SHELL ["/bin/bash", "-c"]

#=========================
# Emulator Configurations
#=========================s
# Emulator settings
ARG EMULATOR_DEVICE="pixel_6"
ARG EMULATOR_NAME="emu"
ARG EMULATOR_TIMEOUT=300

#====================================
# Expose Ports for Emulator and ADB
#====================================
EXPOSE 5544 5554 5555

#=============
# Copy Scripts
#=============
COPY . /

#=============================
# Set Permissions for Scripts
#=============================
RUN create-emulator.sh start.sh

#====================================
# Run SDK and Emulator Setup Scripts
# ====================================
RUN ./create-emulator.sh --EMULATOR_NAME "$EMULATOR_NAME" --EMULATOR_DEVICE "$EMULATOR_DEVICE" --EMULATOR_PACKAGE "$EMULATOR_PACKAGE"

#=========================
# Entry Command
#=========================
CMD ["./start.sh", "--EMULATOR_NAME=${EMULATOR_NAME}", "--EMULATOR_TIMEOUT=${EMULATOR_TIMEOUT}"]
