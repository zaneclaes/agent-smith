#!/bin/bash

proj="$1"
if [[ ! -d "$proj" ]]; then
  echo "$proj is not a directory"
  exit 126
fi
cd "$proj"
shift 1
/opt/Unity/Editor/Unity -projectPath . -quit -logFile -batchmode -nographics -executeMethod "$@"
