#!/usr/bin/env bash
UNITY_BRANCH=${1:-beta}
UNITY_RELEASES=$(curl https://public-cdn.cloud.unity3d.com/hub/prod/releases-linux.json)
UNITY_RELEASE=$(echo $UNITY_RELEASES | jq ".$UNITY_BRANCH[-1]")
UNITY_VERSION=$(echo $UNITY_RELEASE | jq ".version" | sed "s|\"||g")
SHA1=$(echo $UNITY_RELEASE | jq ".checksum" | sed "s|\"||g")

docker build \
  --build-arg UNITY_VERSION=$UNITY_VERSION \
  --build-arg SHA1=$SHA1 \
  agent/ \
  -t inzania/agent-smith:${UNITY_VERSION} \
  -t inzania/agent-smith:${UNITY_BRANCH}