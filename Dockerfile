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

RUN apt update && apt install --no-install-recommends -y \
    tzdata \
    curl \
    sudo \
    wget \
    unzip \
    bzip2 \
    libdrm-dev \
    libxkbcommon-dev \
    libgbm-dev \
    libasound-dev \
    libnss3 \
    libxcursor1 \
    libpulse-dev \
    libxshmfence-dev \
    xauth \
    xvfb \
    x11vnc \
    fluxbox \
    wmctrl \
    libdbus-glib-1-2 \
    iputils-ping \
    net-tools && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

#=========================
# Emulator Configurations
#=========================s
# Emulator settings
ENV EMULATOR_DEVICE="pixel_6"
ENV EMULATOR_NAME="emu"
ENV EMULATOR_TIMEOUT=300

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
RUN chmod a+x create-emulator.sh && \
    chmod a+x start.sh

#====================================
# Run SDK and Emulator Setup Scripts
# ====================================
RUN ./create-emulator.sh --EMULATOR_NAME "$EMULATOR_NAME" --EMULATOR_DEVICE "$EMULATOR_DEVICE" --EMULATOR_PACKAGE "$EMULATOR_PACKAGE"


#============================================
# Clean up the installation files and caches
#============================================
RUN rm -f create-emulator \
    rm -rf /tmp/* /var/tmp/*

#=========================
# Entry Command
#=========================
CMD ["./start.sh", "--EMULATOR_NAME=${EMULATOR_NAME}", "--EMULATOR_TIMEOUT=${EMULATOR_TIMEOUT}"]
