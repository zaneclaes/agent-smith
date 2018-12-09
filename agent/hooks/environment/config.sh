#!/bin/bash
set -euo pipefail

echo "Configuring Env."
BUILDKITE_S3_ACL=${S3_ACL:-private}
BUILDKITE_GIT_CLONE_FLAGS="--config core.autocrlf=input --config core.sparseCheckout=true"

eval "$(ssh-agent -s)"
ssh-add -k /ss3/agent_smith
