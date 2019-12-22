# BUILDKITE BASE
FROM buildkite/agent:ubuntu
USER root

# BUILDPIPE
# https://github.com/ksindi/buildpipe
RUN apt-get -y update && apt-get -y upgrade && apt-get install -y python3 python3-pip
RUN pip3 install buildpipe awscli pyyaml

# BAZEL
# https://docs.bazel.build/versions/master/install-ubuntu.html
RUN apt-get update &&\
    apt-get install -y openjdk-8-jdk curl gnupg python

RUN echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" | \
    tee /etc/apt/sources.list.d/bazel.list && \
    curl https://bazel.build/bazel-release.pub.gpg | apt-key add -

RUN apt-get update && apt-get install -y bazel

RUN apt-get install -y zip unzip curl jq

# XCBUILD
RUN apt-get update -y && apt-get install -y git cmake ninja-build libpng-dev zlib1g-dev libxml2-dev pkg-config
RUN git clone https://github.com/facebook/xcbuild && cd xcbuild && git submodule update --init && make -j 8 && cp -a build/. /usr/bin/

RUN mkdir /root/.ssh/
RUN git config --global core.autocrlf input # For Windows agents.
RUN git config --global core.sparseCheckout true # Faster, and also helps Windows agents.

# -----------------------------
# ----------- UNITY -----------
# -----------------------------

# cocoapods, for iOS builds
RUN apt-get install -y ruby-dev
RUN gem install -n /usr/local/bin cocoapods

ARG UNITY_VERSION
ARG SHA1

# FROM: https://forum.unity.com/threads/unity-on-linux-release-notes-and-known-issues.350256/page-2
# Steal the SHA from "Linux Download Assistant"
ARG COMPONENTS=Unity,Windows-Mono,Mac-Mono,WebGL,Android,iOS

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN echo "America/New_York" > /etc/timezone && \
    apt-get update -qq; \
    apt-get install -qq -y \
    gconf-service \
    lib32gcc1 \
    lib32stdc++6 \
    libasound2 \
    libarchive13 \
    libc6 \
    libc6-i386 \
    libcairo2 \
    libcap2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libfreetype6 \
    libgcc1 \
    libgconf-2-4 \
    libgdk-pixbuf2.0-0 \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libglu1-mesa \
    libgtk2.0-0 \
    libgtk3.0 \
    libnotify4 \
    libnspr4 \
    libnss3 \
    libpango1.0-0 \
    libsoup2.4-1 \
    libstdc++6 \
    libx11-6 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxtst6 \
    libunwind-dev \
    zlib1g \
    pulseaudio \
    debconf \
    npm \
    xdg-utils \
    lsb-release \
    libpq5 \
    xvfb \
    wget \
    locales \
    software-properties-common \
    unzip \
    && add-apt-repository ppa:openjdk-r/ppa \
    && add-apt-repository ppa:cwchien/gradle \
    && apt-get install -qq -y \
    gradle \
    openjdk-8-jdk \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# Android Support: Add JDK & ADK
# From: Command Line Tools Only: https://developer.android.com/studio/#downloads

ENV ANDROID_SDK_VERSION ${ANDROID_SDK_VERSION:-28}
ENV ANDROID_SDK_COMPONENTS platforms;android-$ANDROID_SDK_VERSION
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/jre/
ENV PATH ${PATH}:/usr/lib/jvm/java-8-openjdk-amd64/jre/bin
ENV ANDROID_HOME /opt/android-sdk-linux

ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools
ENV LANG en_US.UTF-8

# Install Android SDK Installer...
RUN cd /opt && \
    wget -q https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip -O android-sdk.zip && \
    unzip -q android-sdk.zip -d android-sdk-linux && \
    rm -f android-sdk.zip && \
    ls -ahl android-sdk-linux

RUN chmod -R 755 .${ANDROID_HOME}/tools/*

# Install Android SDK
RUN ${ANDROID_HOME}/tools/bin/sdkmanager ${ANDROID_SDK_COMPONENTS}

# accept license
RUN yes | ${ANDROID_HOME}/tools/bin/sdkmanager --licenses

RUN gradle -v

RUN DOWNLOAD_URL=$(curl https://public-cdn.cloud.unity3d.com/hub/prod/releases-linux.json | \
    jq ".[][] | select(.version == \"${UNITY_VERSION}\").downloadUrl" | \
    sed "s|LinuxEditorInstaller/Unity.tar.xz|UnitySetup-${UNITY_VERSION}|" | sed "s|\"||g") && \
    wget -nv ${DOWNLOAD_URL} -O UnitySetup && \
    echo "GOT download!!" && \
    # compare sha1 if given
    if [ -n "${SHA1}" -a "${SHA1}" != "" ]; then \
     echo "${SHA1}  UnitySetup" | shasum -a 1 --check -; \
    else \
     echo "no sha1 given, skipping checksum"; \
    fi && \
    # make executable
    chmod +x UnitySetup && \
    # agree with license
    echo y | \
    # install unity with required components
    ./UnitySetup \
    --unattended \
    --install-location=/opt/Unity \
    --verbose \
    --download-location=/tmp/unity \
    --components=$COMPONENTS && \
    # make a directory for the certificate Unity needs to run
    mkdir -p /root/.local/share/unity3d/Certificates/ && \
    # remove setup & temp files
    rm UnitySetup && \
    rm -rf /tmp/unity && \
    rm -rf /root/.local/share/Trash/* && \
    # android specific paths
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

# Ensure Python 3.7
RUN apt-get -y update && apt-get -y upgrade && apt-get install -y python3.7
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 1
RUN pip3 install pyyaml awscli

# Buildkite
ADD ./buildkite-agent /etc/buildkite-agent
RUN chmod +rwx /etc/buildkite-agent/buildkite-agent.cfg

# Docker entrypoint
COPY ./docker-entrypoint.d /docker-entrypoint.d
RUN chmod -R +x /docker-entrypoint.d

# Smith run-script & cron job
ADD ./bin /bin
RUN chmod +x /bin/smith.sh

# Add the buildkite-agent user, which will be used during builds
RUN useradd buildkite-agent && \
    echo "buildkite-agent:buildkite-agent" | chpasswd && \
    mkdir -p /home/buildkite-agent && chown -R buildkite-agent:buildkite-agent /home/buildkite-agent
RUN chown -R buildkite-agent:buildkite-agent /opt/Unity
USER buildkite-agent
WORKDIR /home/buildkite-agent

