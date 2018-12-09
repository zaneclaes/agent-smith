#!/bin/bash

echo "[Smith] checking that Unity is running"
running=$(ps -ef | grep "/opt/Unity/Editor/Unity" | grep -v "grep")
echo "[Smith] Running? ${running}"
if [[ ! -z "$running" ]]; then
  echo "[Smith] Unity is already running."
  exit 0
fi

cd "/smith"
lf="ci.log"
rm -rf "$lf"
rm -rf "smith.lock" # In case the prior version did not shut down.
rm -rf "smith.cmd" # In case the prior version did not shut down.
echo "[Smith] Running as $(whoami) for ${SMITH_TARGET} in $(pwd) [$lf]"
xvfb-run --auto-servernum --server-args='-screen 0 640x480x24' /opt/Unity/Editor/Unity \
  -nographics \
  -batchmode \
  -quit \
  -projectPath ./ \
  -logFile "$lf" \
  -androidSdkRoot /root/Android \
  -JdkPath /usr/lib/jvm/java-8-oracle \
  -executeMethod Agent.Smith.CI &
