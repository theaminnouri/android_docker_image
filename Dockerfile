FROM ubuntu:24.04

# Add metadata labels
LABEL author="theAminNouri <theaminnouri@gmail.com>" \
      description="A Docker image for building Android projects"

USER root

ARG GRADLE_VERSION=8.10.2
ARG SDK_TOOLS_VERSION=11076708
ARG ANDROID_EMULATOR_VERSION=12836668
ARG DEBIAN_FRONTEND=noninteractive

ENV ANDROID_HOME="/android-sdk"
ENV PATH="$PATH:${ANDROID_HOME}/tools:/opt/gradle/gradle-${GRADLE_VERSION}/bin"
ENV ANDROID_BUILD_TOOLS_VERSION="35.0.1"
ENV ANDROID_PLATFORMS_VERSION="android-35"

# Install necessary libraries
RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y git jq wget unzip curl zip openjdk-21-jdk wget tar unzip lib32stdc++6 lib32z1 \
	&& apt-get clean


RUN wget --output-document=gradle-${GRADLE_VERSION}-all.zip https://downloads.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip \
    && mkdir -p /opt/gradle \
    && unzip gradle-${GRADLE_VERSION}-all.zip -d /opt/gradle \
    && rm ./gradle-${GRADLE_VERSION}-all.zip \
    && mkdir -p ${ANDROID_HOME} \
    && wget --output-document=android-sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-${SDK_TOOLS_VERSION}_latest.zip \
    && unzip ./android-sdk.zip -d ${ANDROID_HOME} \
    && rm ./android-sdk.zip \
    && mkdir -p ~/.android \
    && touch ~/.android/repositories.cfg \
    && wget --output-document=emulator.zip https://redirector.gvt1.com/edgedl/android/repository/emulator-linux_x64-${ANDROID_EMULATOR_VERSION}.zip \
    && unzip ./emulator.zip -d ${ANDROID_HOME} \
    && rm ./emulator.zip


RUN yes | ${ANDROID_HOME}/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --licenses \
        && ${ANDROID_HOME}/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --update


RUN ./${ANDROID_HOME}/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "build-tools;$ANDROID_BUILD_TOOLS_VERSION" \
    "platforms;$ANDROID_PLATFORMS_VERSION" \
    "platform-tools"