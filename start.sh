#!/bin/bash

# GitHub runner name
RUNNER_NAME="${RUNNER_NAME}_$(cat /proc/sys/kernel/random/uuid | head -c 8)"

# GitHub runner group name
RUNNER_GROUP_NAME=${RUNNER_GROUP_NAME:-"default"}

# GitHub runner labels
RUNNER_LABELS=${RUNNER_LABELS:-"$(hostname -s),$(date +"%s"),${RUNNER_GROUP_NAME}"}

cd "${HOME}/actions-runner" || exit

# cleanup handler
cleanup() {
  echo "Removing runner..."
  # obtain runner registration token
  RUNNER_TOKEN=$(curl -s -L -H "Accept: application/vnd.github+json" \
                            -H "Authorization: Bearer ${GH_TOKEN}" \
                            -H "X-GitHub-Api-Version: ${GH_API_VERSION}" \
                            -X POST "${GH_API_URI_PREFIX}${RUNNER_SCOPE_PREFIX}/${RUNNER_SCOPE}/actions/runners/remove-token" | jq -r '.token')
  ./config.sh remove --token "${RUNNER_TOKEN}"
}

# register cleanup handler
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

# obtain runner removal token
export RUNNER_TOKEN=$(curl -s -L -H "Accept: application/vnd.github+json" \
                                 -H "Authorization: Bearer ${GH_TOKEN}" \
                                 -H "X-GitHub-Api-Version: ${GH_API_VERSION}" \
                                 -X POST "${GH_API_URI_PREFIX}${RUNNER_SCOPE_PREFIX}/${RUNNER_SCOPE}/actions/runners/registration-token" | jq -r '.token')

# perform GitHub runner registration and activation
./config.sh --url "https://github.com/${RUNNER_SCOPE}" \
            --unattended --disableupdate \
            --token "${RUNNER_TOKEN}" --name "${RUNNER_NAME}" --runnergroup "${RUNNER_GROUP_NAME}" --labels "${RUNNER_LABELS}"

# start GitHub runner
./run.sh & wait ${!}
