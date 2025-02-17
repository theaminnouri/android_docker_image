FROM ubuntu:24.04

# Metadata labels
LABEL author="theAminNouri <theaminnouri@gmail.com>" \
      description="A Docker image for building Android projects"

USER root

ARG GRADLE_VERSION=8.10.2
ARG SDK_TOOLS_VERSION=11076708
ARG DEBIAN_FRONTEND=noninteractive

ENV ANDROID_HOME="/android-sdk"
ENV PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin:/opt/gradle/gradle-${GRADLE_VERSION}/bin"


# Install necessary libraries
RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y git jq wget unzip curl zip openjdk-21-jdk wget tar unzip lib32stdc++6 lib32z1 libpulse0 \
	&& apt-get clean


RUN wget --output-document=gradle-${GRADLE_VERSION}-all.zip https://downloads.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip \
    && mkdir -p /opt/gradle \
    && unzip gradle-${GRADLE_VERSION}-all.zip -d /opt/gradle \
    && rm ./gradle-${GRADLE_VERSION}-all.zip \
    && mkdir -p ${ANDROID_HOME} \
    && wget --output-document=android-sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-${SDK_TOOLS_VERSION}_latest.zip \
    && mkdir ${ANDROID_HOME}/temp \
    && unzip ./android-sdk.zip -d ${ANDROID_HOME}/temp \
    && rm ./android-sdk.zip \
    && mkdir -p ${ANDROID_HOME}/cmdline-tools/latest \
    && mv ${ANDROID_HOME}/temp/cmdline-tools/* ${ANDROID_HOME}/cmdline-tools/latest/ \
    && rm -rf ${ANDROID_HOME}/temp


RUN yes | sdkmanager --sdk_root=${ANDROID_HOME} --licenses \
        && sdkmanager --sdk_root=${ANDROID_HOME} --update


ADD sdk_packages.txt .
RUN xargs sdkmanager --sdk_root=${ANDROID_HOME} < sdk_packages.txt