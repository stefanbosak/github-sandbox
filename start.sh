#!/bin/bash

# GitHub organization and repository name
REPO="${REPO}"

# GitHub actions runner registration token for organization/repository
REG_TOKEN="${REG_TOKEN}"

# GitHub runner name
RUNNER_NAME=${RUNNER_NAME:="runner-$(cat /proc/sys/kernel/random/uuid)"}

# GitHub runner group name
RUNNER_GROUP_NAME=${RUNNER_GROUP_NAME:="default"}

# GitHub runner labels
RUNNER_LABELS=${RUNNER_LABELS:="self-hosted-default"}

cd "${WORKSPACE_ROOT_DIR}/actions-runner" || exit

# cleanup handler
cleanup() {
  echo "Removing runner..."
  ./config.sh remove --token "${REG_TOKEN}"
}

# register cleanup handler
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

# perform GitHub runner registration and activation
./config.sh --url "https://github.com/${REPO}" --unattended --token "${REG_TOKEN}" --name "${RUNNER_NAME}" --runnergroup "${RUNNER_GROUP_NAME}" --labels "${RUNNER_LABELS}"

# start GitHub runner
./run.sh & wait ${!}
