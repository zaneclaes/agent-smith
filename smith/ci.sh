#!/bin/bash

targ="$1"
proj="$2"
cache="$3"
lf="$4"
if [[ ! -d "$proj" ]]; then
  echo "$proj is not a directory"
  exit 126
fi

ws="/ws_${targ}"
rm -rf "${ws}/*"
if [[ ! -d "$ws" ]]; then mkdir "$ws"; fi
echo "Copying $proj/ to $ws"
cp -fuR "${proj}/" "${ws}"

if [[ ! -z "$cache" ]]; then
  echo "Copying library from $cache/${targ}/Library"
  cp -fuR "$cache/${targ}/Library/" "${ws}/Library"
fi

cd "${ws}"
echo "Running as $(whoami) w/ logs $lf in $(pwd) using ${targ} ${proj} ${cache}; contents: $(ls ./)"
xvfb-run --auto-servernum --server-args='-screen 0 640x480x24' \
  /opt/Unity/Editor/Unity -projectPath . -quit -logFile $lf -batchmode -nographics \
  -executeMethod Agent.Smith.CI -cmdDir /cmddir

# wd=
# docker exec smith bash /bin/ci.sh UnityServer /buildkite/builds/agent-smith-inZania-MBP-local/moongate/build-ecs-service/unity /buildkite/builds /buildkite/builds/agent-smith-inZania-MBP-local/moongate/build-ecs-service/bin/build_unity_server.log