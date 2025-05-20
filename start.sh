#!/bin/bash

# GitHub runner name
RUNNER_NAME=${RUNNER_NAME:-"runner-${RUNNER_SCOPE_PREFIX}-$(cat /proc/sys/kernel/random/uuid)"}

# GitHub runner group name
RUNNER_GROUP_NAME=${RUNNER_GROUP_NAME:-"default"}

# GitHub runner labels
RUNNER_LABELS=${RUNNER_LABELS:-"self-hosted-${RUNNER_GROUP_NAME}"}

cd "${WORKSPACE_ROOT_DIR}/actions-runner" || exit

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
./config.sh --url "https://github.com/${RUNNER_SCOPE}" --unattended --token "${RUNNER_TOKEN}" --name "${RUNNER_NAME}" --runnergroup "${RUNNER_GROUP_NAME}" --labels "${RUNNER_LABELS}"

# start Docker service
# - following approach is not working: sudo systemctl restart docker.service
sudo /etc/init.d/docker restart

# start GitHub runner
./run.sh & wait ${!}
