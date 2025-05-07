#!/bin/bash
cwd=$(dirname $(realpath "${0}"))

source "${cwd}/setvariables.sh"

# check prerequisites (if all required tools are available)
TOOLS="docker"

for tool in ${TOOLS}; do
  if [ -z "$(which ${tool})" ]; then
    echo "Tool ${tool} has not been found, please install tool in your system"
    exit 1
  fi
done

# extract parameters from command-line
while [[ $# -gt 0 ]]; do
    case "${1}" in
        --group) RUNNER_GROUP_NAME="$2"; shift;;
        --labels) RUNNER_LABELS="$2"; shift;;
        *) echo "Unknown option: $1";;
    esac
    shift
done

# start unique standalone GitHub runner Docker container with label
docker container run --platform ${TARGETPLATFORM} -ti -v /dev:/dev \
                     --env REPO="${REPO}" \
                     --env REG_TOKEN="${REG_TOKEN}" \
                     --env RUNNER_NAME="${RUNNER_NAME}" \
                     --env RUNNER_GROUP_NAME="${RUNNER_GROUP_NAME}" \
                     --env RUNNER_LABELS="${RUNNER_LABELS}" \
                     --env WORKSPACE_ROOT_DIR="${WORKSPACE_ROOT_DIR}" \
                     --network=host --detach --rm --name "${RUNNER_NAME}" "${CONTAINER_IMAGE_NAME}"
