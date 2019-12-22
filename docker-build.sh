#!/usr/bin/env bash
image="inzania/agent-smith"
docker_dir="docker/"
tag="official" # or "beta"
version=""
push=false
list=false
while [[ ! -z "$@" ]]; do
  if [[ "$1" == "-p" ]]; then
    push=true
  elif [[ "$1" == "-l" ]]; then
    list=true
  elif [[ "$1" == "official" || "$1" == "beta" ]]; then
    tag="$1"
  else
    version="$1"
  fi
  shift
done

releases=$(curl -s https://public-cdn.cloud.unity3d.com/hub/prod/releases-linux.json)
if $list; then
  echo "Official:"
  echo $(echo $releases | jq ".official[].version" | sed "s|\"||g")
  echo "Beta:"
  echo $(echo $releases | jq ".beta[].version" | sed "s|\"||g")
  exit 0;
fi
if [[ -z "$version" ]]; then
  release=$(echo $releases | jq ".${tag}[-1]")
  version=$(echo $release | jq ".version" | sed "s|\"||g")
else
  versions=$(echo $releases | jq ".[][].version")
  if [[ $versions != *"\"$version\""* ]]; then
    echo "Version $version is not availible. Valid versions are:"
    echo "$versions"
    exit 1
  fi
fi
# sha1=$(echo $release | jq ".checksum" | sed "s|\"||g")

echo "Unity $tag v.$version"
echo "Docker image: ${image}:${version}"
if [[ "$(docker images -q ${image}:${version} 2> /dev/null)" != "" ]]; then
  read -p "The image already exists. Rebuild? [y/N] " rebuild
  if [[ $rebuild != "Y" ]]; then
    if $push; then
      docker push ${image}
    fi
    exit 0
  fi
fi

# kubectl delete secret agent-smith
# kubectl create secret generic agent-smith \
#   --from-literal=buildkite-agent-token=${BUILDKITE_AGENT_TOKEN}

if (docker build --build-arg UNITY_VERSION=$version "$docker_dir" -t ${image}:${version} -t ${image}:${tag}); then
  if $push; then
    docker push ${image}
  fi
fi
