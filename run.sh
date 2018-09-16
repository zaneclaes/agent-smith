#!/usr/bin/env bash

mg_env=${MG_ENV:-DEV}

if [[ -z "$MG_SHR" ]]; then
  echo "No MG_SHR env var"
  exit 1
fi

aws ecr get-login --no-include-email > ${MG_SHR}/.ss3/ecr_login

# # MG_SRC, MG_SHR, MG_ENV, SN
# cat ./docker-compose.template > ./docker-compose.yml
# fn="./docker-compose.yml"
# smith=$(cat ./dockerfile-smith.template)
# cp ./docker-compose.template $fn
# echo "$smith" | sed "s/{SN}/1/"  >> $fn

dc() {
  MG_ENV="$mg_env" BUILDKITE_AGENT_NAME="agent_smith-$HOSTNAME" docker-compose $@
}

dc stop
dc build
dc up
