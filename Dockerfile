ARG ANDROID_VERSION=15

FROM mahmoudazaid/android:${ANDROID_VERSION}

ENV DEBIAN_FRONTEND noninteractive
ENV TZ="Europe/Berlin"

WORKDIR /
#=============================
# Install Dependenices 
#=============================
SHELL ["/bin/bash", "-c"]   

RUN apt update && apt install tzdata -y curl sudo wget unzip bzip2 libdrm-dev libxkbcommon-dev libgbm-dev libasound-dev libnss3 libxcursor1 libpulse-dev libxshmfence-dev xauth xvfb x11vnc fluxbox wmctrl libdbus-glib-1-2

#==============================
# Device ARGs
#==============================
ARG EMULATOR_NAME="emu-1"
ARG EMULATOR_DEVICE="pixel_6"
ARG DEVICES_NUM=5

#==============================
# Expose Ports
#==============================
# ADB Ports
#==============================
EXPOSE 5544 5554 5555 

#=========================
# Copying Scripts to root
#=========================
COPY . /

RUN chmod a+x create-emulator.sh && \
    chmod a+x start.sh
#====================================
# Run Scripts
#====================================
RUN ./create-emulator.sh \
    --EMULATOR_NAME $EMULATOR_NAME \
    --EMULATOR_DEVICE $EMULATOR_DEVICE \
    --EMULATOR_PACKAGE $EMULATOR_PACKAGE

CMD ["./start.sh", "--EMULATOR_NAME=${EMULATOR_NAME} --EMULATOR_TIMEOUT=${EMULATOR_TIMEOUT}"]
