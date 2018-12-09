#!/usr/bin/env bash

if [[ -z "$MG_SHR" ]]; then
  echo "No MG_SHR env var"
  exit 1
fi

# # MG_SRC, MG_SHR, MG_ENV, SN
# cat ./docker-compose.template > ./docker-compose.yml
# fn="./docker-compose.yml"
# smith=$(cat ./dockerfile-smith.template)
# cp ./docker-compose.template $fn
# echo "$smith" | sed "s/{SN}/1/"  >> $fn

df="docker-compose.yml"

docker-compose stop || true

echo "version: '3.3'" > "$df"
echo "services:" >> "$df"

for smith_target in "$@"; do
  cat "agent.yml" >> "$df"
  sed -i "s/{{SMITH_TARGET}}/${smith_target}/g" "$df"
done

docker-compose up
