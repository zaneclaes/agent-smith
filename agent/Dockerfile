# BUILDKITE BASE
FROM buildkite/agent:ubuntu
USER root
COPY ./buildkite-agent.cfg /etc/buildkite-agent/buildkite-agent.cfg

# BAZEL
# https://docs.bazel.build/versions/master/install-ubuntu.html
RUN apt-get update &&\
    apt-get install -y openjdk-8-jdk curl gnupg python

RUN echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" | \
    tee /etc/apt/sources.list.d/bazel.list && \
    curl https://bazel.build/bazel-release.pub.gpg | apt-key add -

RUN apt-get update && apt-get install -y bazel

# ENTRYPOINT
# n.b. buildkite base doesn't like the entrypoint to be overridden.
# https://hub.docker.com/r/buildkite/agent/
RUN mkdir /root/.ssh/
ADD hooks /buildkite/hooks
ADD plugins /buildkite/plugins
COPY ./docker-entrypoint.d /docker-entrypoint.d
RUN chmod +x /docker-entrypoint.d/agent
RUN git config --global core.autocrlf input # For Windows agents.
RUN git config --global core.sparseCheckout true # Faster, and also helps Windows agents.
