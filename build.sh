#!/usr/bin/env bash
UNITY_RELEASES=$(curl https://public-cdn.cloud.unity3d.com/hub/prod/releases-linux.json)
UNITY_BRANCH=${1:-beta}
UNITY_VERSION="$2"
ALL_VERSIONS=$(echo $UNITY_RELEASES | jq ".[][].version")
if [[ -z "$UNITY_VERSION" ]]; then
  UNITY_RELEASE=$(echo $UNITY_RELEASES | jq ".${UNITY_BRANCH}[-1]")
  UNITY_VERSION=$(echo $UNITY_RELEASE | jq ".version" | sed "s|\"||g")
fi
# SHA1=$(echo $UNITY_RELEASE | jq ".checksum" | sed "s|\"||g")

IMG="inzania/agent-smith"

echo "Unity $UNITY_BRANCH v.$UNITY_VERSION"
if [[ "$(docker images -q ${IMG}:${UNITY_VERSION} 2> /dev/null)" != "" ]]; then
  read -p "${IMG}:${UNITY_VERSION} already exists. Are you sure? [Y/n] " rebuild
  if [[ $rebuild != "Y" ]]; then
    exit 0
  fi
fi

# kubectl delete secret agent-smith
# kubectl create secret generic agent-smith \
#   --from-literal=buildkite-agent-token=${BUILDKITE_AGENT_TOKEN}

docker build \
  --build-arg UNITY_VERSION=$UNITY_VERSION \
  agent/ \
  -t ${IMG}:${UNITY_VERSION} \
  -t ${IMG}:${UNITY_BRANCH}

docker push ${IMG}
