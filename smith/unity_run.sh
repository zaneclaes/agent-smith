#!/bin/bash

proj="$1"
bin="$2"
if [[ ! -d "$proj" ]]; then
  echo "$proj is not a directory"
  exit 126
fi
if [[ ! -d "$bin" ]]; then
  if [[ -z "$bin" ]]; then
    echo "$bin is not a directory"
    exit 127
  fi
  mkdir "$bin"
fi
cd "$proj"
shift 2

verb="$1"
target="$2"
method="Agent.Smith.${verb}"
od="$bin/$target"
shift 2

# Cache library
cd="/buildkite/builds/${target}"
if [[ -d "$cd" ]]; then
  echo "Copying Unity cache from $cd ..."
  cp -fuR "$cd/Library/." "./Library/" || true
fi

lf="${bin}/${verb}-${target}.log"
/opt/Unity/Editor/Unity -projectPath . -quit -logFile $lf -batchmode -nographics \
  -executeMethod $method -target $target -output $od $@

echo "Copying ./Library cache back to $cd ..."
rm -rf "$cd/Library/*"
cp -fuR "./Library/." "$cd/Library/" || true

log=$(cat $lf)
success=$(echo "$log" | grep -c "*** Completed 'Build.Player.")
if [[ $success == 0 ]]; then
  echo "No completed statement in Unity log file $lf:"
  echo "$log"
  exit 126
fi

# Is Unity already running?
# docker exec -it smith pgrep /opt/Unity/Editor/Unity
