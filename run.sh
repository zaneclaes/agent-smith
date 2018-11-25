#!/usr/bin/env bash

mg_env=${MG_ENV:-DEV}

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

dc() {
  MG_ENV="$mg_env" \
    BUILDKITE_ARTIFACT_UPLOAD_DESTINATION="s3://mg-buildkite-artifacts/${BUILDKITE_JOB_ID}" \
    BUILDKITE_AGENT_NAME="agent_smith-$HOSTNAME" \
    BUILDKITE_S3_DEFAULT_REGION="us-east-1" \
    docker-compose $@
}

dc stop
dc build
dc up
