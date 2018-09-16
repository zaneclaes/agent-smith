#!/bin/bash

set -euo pipefail

eval "$(ssh-agent -s)"
ssh-add -k /ss3/agent_smith
