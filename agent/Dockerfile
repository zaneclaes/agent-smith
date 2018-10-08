# BUILDKITE BASE
FROM buildkite/agent:ubuntu
USER root
COPY ./buildkite-agent.cfg /etc/buildkite-agent/buildkite-agent.cfg

# BUILDPIPE
# https://github.com/ksindi/buildpipe
RUN apt-get update && apt-get install -y python3 python3-pip
RUN pip3 install buildpipe awscli

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

# ENTRYPOINT
# n.b. buildkite base doesn't like the entrypoint to be overridden.
# https://hub.docker.com/r/buildkite/agent/
RUN mkdir /root/.ssh/
ADD hooks /buildkite/hooks
COPY ./docker-entrypoint.d /docker-entrypoint.d
RUN chmod +x /docker-entrypoint.d/agent
RUN chmod +x /docker-entrypoint.d/smith
RUN git config --global core.autocrlf input # For Windows agents.
RUN git config --global core.sparseCheckout true # Faster, and also helps Windows agents.

# -----------------------------
# ----------- UNITY -----------
# -----------------------------

# FROM: https://forum.unity.com/threads/unity-on-linux-release-notes-and-known-issues.350256/page-2
# Steal the SHA from "Linux Download Assistant"
ARG DOWNLOAD_URL="https://beta.unity3d.com/download/793261fe3e9a/UnitySetup-2018.2.6f1"
ARG COMPONENTS=Unity,Windows,Windows-Mono,Mac,Mac-Mono,WebGL,Android,iOS

RUN apt-get update -qq; \
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
    zlib1g \
    debconf \
    npm \
    xdg-utils \
    lsb-release \
    libpq5 \
    xvfb \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN wget -nv ${DOWNLOAD_URL} -O UnitySetup && \
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
    ./UnitySetup --unattended \
    --install-location=/opt/Unity \
    --verbose \
    --download-location=/tmp/unity \
    --components=$COMPONENTS && \
    # remove setup
    rm UnitySetup

# Android Support: Add JDK & ADK
# From: Command Line Tools Only: https://developer.android.com/studio/#downloads
RUN apt-get update && apt-get install -y software-properties-common
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
RUN add-apt-repository ppa:webupd8team/java && apt-get update && yes | apt-get install -y oracle-java8-installer
RUN apt-get update && apt-get install -y zip unzip lib32ncurses5 lib32stdc++6
RUN wget -O android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN unzip android-sdk.zip -d /root/Android
RUN chmod -R +xr /root/Android/
RUN mkdir /root/.android || true && touch /root/.android/repositories.cfg
RUN /root/Android/tools/bin/sdkmanager --update && \
    echo 'y' | /root/Android/tools/bin/sdkmanager "platforms;android-27" "build-tools;27.0.3" "extras;google;m2repository" "extras;android;m2repository" && \
    yes | /root/Android/tools/bin/sdkmanager --licenses

# Clean up
RUN rm -rf /tmp/* /var/tmp/*

#COPY ./docker-entrypoint /usr/local/bin/docker-entrypoint
#RUN chmod +x /usr/local/bin/docker-entrypoint
#COPY ./unity_run.sh /bin/unity_run.sh
#RUN chmod +x /bin/unity_run.sh
COPY ./ci.sh /bin/ci.sh
RUN chmod +x /bin/ci.sh
#ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]