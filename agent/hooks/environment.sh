#!/bin/bash
set -euo pipefail

echo "Configuring for Next building and S3 uploading."
BUILDKITE_S3_ACCESS_KEY_ID=${AWS_KEY_ID}
BUILDKITE_S3_SECRET_ACCESS_KEY=${AWS_KEY_SEC}
BUILDKITE_S3_ACL=private
BUILDKITE_GIT_CLONE_FLAGS="--config core.autocrlf=input --config core.sparseCheckout=true"

eval "$(ssh-agent -s)"
ssh-add -k /ss3/agent_smith
