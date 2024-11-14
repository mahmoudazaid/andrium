# Android Emulator with Appium for Device Farm

This project builds Docker images with Android emulators pre-configured for automated testing using Appium. These images can be used as nodes in a device farm setup and connected to a device-farm hub to scale testing across multiple emulators.

# Badges

[![Docker Publish](https://github.com/mahmoudazaid/android-emulator/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/mahmoudazaid/android-emulator/actions/workflows/docker-publish.yml)

## Table of Contents

1. [Project Overview](#project-overview)
2. [Build Options](#build-options)
   - [Available Build Arguments](#available-build-arguments)
   - [Device Options](#device-options)
3. [Building the Docker Image](#building-the-docker-image)
   - [Default Build](#default-build)
   - [Custom Build](#custom-build)
4. [Running Appium with Emulator](#running-appium-with-emulator)
   - [Running Emulator without Appium](#running-emulator-without-appium)
   - [Running Emulator with Appium](#running-emulator-with-appium)
5. [Emulator Startup Process](#emulator-startup-process)
6. [Emulator Configuration](#emulator-configuration)
7. [Using as a Node in Device Farm](#using-as-a-node-in-device-farm)
8. [Build and Run Variables](#build-and-run-variables)
   - [Build Variables](#build-variables)
   - [Run Variables](#run-variables)
9. [Usage Example](#usage-example)
   - [Build Command](#build-command)
   - [Run Command](#run-command)
10. [Conclusion](#conclusion)

## Project Overview

- **Purpose**: Provides ready-to-use Android emulators with Appium pre-installed.
- **Usage**: Suitable for integration into device farms for scalable, automated testing environments.

## Build Options

This Docker image allows two primary options for building an emulator:

1. **Default Version**: Uses default `ANDROID_VERSION` and `EMULATOR_DEVICE` values from the Dockerfile.
2. **Custom Version**: You can override these defaults through build arguments for a customized build.

### Available Build Arguments

To customize your build, adjust the following build arguments:

- **`ANDROID_VERSION`**: Specifies the Android API level for the emulator. Default is `15`.
- **`EMULATOR_DEVICE`**: Specifies the emulator device model. See the table below for available options.

### Device Options

Here is a list of available device options for `EMULATOR_DEVICE`:

| Name         | Creation ID | Creation Name  |
| ------------ | ----------- | -------------- |
| Galaxy Nexus | 1           | "Galaxy Nexus" |
| Nexus 10     | 6           | "Nexus 10"     |
| Nexus 4      | 4           | "Nexus 4"      |
| Nexus 5      | 8           | "Nexus 5"      |
| Nexus 5X     | 9           | "Nexus 5X"     |
| Nexus 6      | 10          | "Nexus 6"      |
| Nexus 6P     | 11          | "Nexus 6P"     |
| Nexus 7 2013 | 12          | "Nexus 7 2013" |
| Nexus 7      | 13          | "Nexus 7"      |
| Nexus 9      | 14          | "Nexus 9"      |
| Nexus One    | 15          | "Nexus One"    |
| Nexus S      | 16          | "Nexus S"      |
| Pixel        | 17          | "pixel"        |
| Pixel 2      | 18          | "pixel_2"      |
| Pixel 2 XL   | 19          | "pixel_2_xl"   |
| Pixel 3      | 20          | "pixel_3"      |
| Pixel 3 XL   | 21          | pixel_3_xl     |
| Pixel 3a     | 22          | "pixel_3a"     |
| Pixel 3a XL  | 23          | "pixel_3a_xl"  |
| Pixel 4      | 24          | "pixel_4"      |
| Pixel 4 XL   | 25          | "pixel_4_xl"   |
| Pixel 4a     | 26          | "pixel_4a"     |
| Pixel 5      | 27          | "pixel_5"      |
| Pixel 6      | 28          | "pixel_6"      |
| Pixel 6 Pro  | 29          | "pixel_6_pro"  |
| Pixel 6a     | 30          | "pixel_6a"     |
| Pixel 7      | 31          | "pixel_7"      |
| Pixel 7 Pro  | 32          | "pixel_7_pro"  |
| Pixel C      | 33          | "pixel_c"      |
| Pixel Tablet | 34          | "pixel_tablet" |
| Pixel XL     | 35          | "pixel_xl"     |

## Building the Docker Image

To build the Docker image with default or customized settings, use the following commands:

### Default Build:

This uses the default values set in the Dockerfile:

```bash
docker build -t your_dockerhub_username/emulator:${ANDROID_VERSION} .
```

## Custom Build

Override `ANDROID_VERSION` and `EMULATOR_DEVICE` with your custom values:

```bash
docker build --build-arg ANDROID_VERSION=<version> --build-arg EMULATOR_DEVICE=<device> -t your_dockerhub_username/emulator:<custom_version> .
```

## Running Appium with Emulator

By default, Appium is not running inside the container. However, it can be started by setting the environment variable `APPIUM=true` .

### Running Emulator without Appium:

The emulator will run without Appium by default. To start the emulator only, use the following:

```bash
docker run -e APPIUM=false your_dockerhub_username/emulator
```

### Running Emulator with Appium:

To run the emulator with Appium, set the `APPIUM` environment variable to `true` :

```bash
docker run -e APPIUM=true your_dockerhub_username/emulator
```

The emulator will launch, and Appium will be started automatically inside the container.

## Emulator Startup Process

Upon starting the container, the following process happens: 1. Emulator Creation: If the emulator does not exist, it is created based on the device and Android version specified. This process uses the Android AVD Manager. 2. Emulator Startup: The emulator starts in a headless mode (without a graphical interface), which makes it suitable for CI/CD environments. 3. Appium (Optional): If `APPIUM=true` is set, the Appium server is started automatically and can be used for automated testing.

## Emulator Configuration

    1. Timeout: The emulator waits for up to 300 seconds for the emulator to boot. You can modify this timeout by setting the `EMULATOR_TIMEOUT` environment variable.
    2. No Boot Animation: The emulator is started with no boot animation for faster startup.

## Using as a Node in Device Farm

To use this Docker image as a node in a device farm, you will need to register this container as a node on your device farm hub.

1.  Docker Image Setup: Ensure you have built and pushed your Docker image to a registry (e.g., Docker Hub) with a unique tag.

2.  Hub Setup: On your device farm hub, register a new node by specifying the URL of your Docker image and the environment variables. For example:

    - Node Image: `mahmoudazaid/emulator:${any-emulator}`
    - Environment Variables:
      - `APPIUM=true`
      - `EMULATOR_DEVICE=pixel_6`

3.  Connect Node to Hub: Follow your device farm's instructions for adding Docker-based nodes. Typically, you will need to configure the node to point to the hub's address, and the hub will handle the communication with the emulator nodes.

4.  Scaling: Add as many nodes as necessary to your device farm setup. Each node will run an emulator with the specified configuration, and you can dynamically scale the number of emulators as needed.

## Build and Run Variables

Below is a table that outlines the key variables you can use when building and running the Android Emulator with Appium.

### Build Variables

| **Variable**      | **Description**                                                  | **Default Value** | **Example** |
| ----------------- | ---------------------------------------------------------------- | ----------------- | ----------- |
| `ANDROID_VERSION` | The Android API version to use for the emulator.                 | 15                | 30          |
| `EMULATOR_DEVICE` | The name of the device to emulate (e.g., `pixel_6`, `Nexus_5X`). | `pixel_6`         | `Nexus_5X`  |
| `CUSTOM_VERSION`  | The custom version tag for your Docker image.                    | `latest`          | `v1.0`      |

### Run Variables

| **Variable**       | **Description**                                          | **Default Value** | **Example** |
| ------------------ | -------------------------------------------------------- | ----------------- | ----------- |
| `APPIUM`           | Determines whether Appium is started with the emulator.  | `false`           | `true`      |
| `EMULATOR_TIMEOUT` | The timeout (in seconds) for the emulator to fully boot. | `300`             | `600`       |
| `APPIUM_HOST`      | The host address for the Appium server.                  | `0.0.0.0`         | `localhost` |
| `APPIUM_PORT`      | The port for the Appium server to listen on.             | `4723`            | `4723`      |

## Usage Example

### Build Command

To build a custom image with a specific Android version and device, use the following command:

```bash
docker build --build-arg ANDROID_VERSION=30 --build-arg EMULATOR_DEVICE=pixel_6 -t emulator:v1.0 .
```

### Run Command

To run a custom container with specific conditions (e.g., with Appium or without it), use the following command:

```bash
docker run -d -p "4723:4723" -e APPIUM=true emulator:v1.0
```

This will run the container with the emulator and Appium enabled. To run the emulator without Appium, set the `APPIUM=false` environment variable or don't mention to the command:

```bash
docker run -d -e APPIUM=false emulator:v1.0
```

OR

```bash
docker run -d emulator:v1.0
```

### Conclusion

This Docker image provides an easy-to-deploy solution for running Android emulators with Appium for automated testing. You can use it as a part of a device farm setup and scale your testing efforts by adding more emulator nodes.
