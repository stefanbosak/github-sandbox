#!/bin/bash
cwd=$(dirname $(realpath "${0}"))

# extract parameters from command-line
while [[ $# -gt 0 ]]; do
  case "${1}" in
    --organization|--org) export ORGANIZATION="${2}"; shift;;
    --repository|--repo) export REPOSITORY="${2}"; shift;;
    --group) RUNNER_GROUP_NAME="$2"; shift;;
    --labels) RUNNER_LABELS="$2"; shift;;
    *) echo "Unknown option: $1";;
  esac

  shift
done

source "${cwd}/setvariables.sh"

# check prerequisites (if all required tools are available)
TOOLS="docker"

for tool in ${TOOLS}; do
  if [ -z "$(which ${tool})" ]; then
    echo "Tool ${tool} has not been found, please install tool in your system"
    exit 1
  fi
done

if [ ! -z "${CONTAINER_REPOSITORY}" ]; then
  docker pull "${CONTAINER_REPOSITORY}${CONTAINER_IMAGE_NAME}${CONTAINER_IMAGE_TAG}"
fi

# runner groups are only in organizations
if [ "${RUNNER_SCOPE_PREFIX}" == "orgs" ]; then
  # check if the runner group already exists
  runner_group=$(curl -sL -H "Accept: application/vnd.github+json" \
                          -H "Authorization: Bearer ${GH_TOKEN}" \
                          -H "X-GitHub-Api-Version: ${GH_API_VERSION}" \
                          -X GET "${GH_API_URI_PREFIX}${RUNNER_SCOPE_PREFIX}/${RUNNER_SCOPE}/actions/runner-groups" | jq -r ".runner_groups[] | select(.name == \"${RUNNER_GROUP_NAME}\")")

  if [ -z "${runner_group}" ]; then
    # create runner group
    runner_group=$(curl -sL -H "Accept: application/vnd.github+json" \
                            -H "Authorization: Bearer ${GH_TOKEN}" \
                            -H "X-GitHub-Api-Version: ${GH_API_VERSION}" \
                            -d "{\"name\": \"${RUNNER_GROUP_NAME}\", \"visibility\": \"all\"}" \
                            -X POST "${GH_API_URI_PREFIX}${RUNNER_SCOPE_PREFIX}/${RUNNER_SCOPE}/actions/runner-groups")
  fi
fi

IFS=',' read -ra PLATFORMS <<< "${TARGETPLATFORM}"

for platform in "${PLATFORMS[@]}"; do
  arch="${platform#linux/}"  # remove "linux/" prefix
  arch="${arch%%/*}"         # extract only the architecture part
  arch="${arch/64/}"         # remove 64

  # create runner name
  runner_name="s-${arch}-${RUNNER_NAME}"

  if [ ! -z "$(docker image ls --filter "reference=${CONTAINER_REPOSITORY}${CONTAINER_IMAGE_NAME}${CONTAINER_IMAGE_TAG}" --format "{{.Repository}}:{{.Tag}}")" ]; then
    # start unique standalone GitHub runner Docker container (optionally with labels, group name)
    # - privileged mode is required for DinD (Docker in Docker)
    docker container run --platform "${platform}" -v /dev:/dev \
                         --privileged \
                         --env GH_TOKEN="${GH_TOKEN}" \
                         --env GH_API_VERSION="${GH_API_VERSION}" \
                         --env GH_API_URI_PREFIX="${GH_API_URI_PREFIX}" \
                         --env RUNNER_SCOPE_PREFIX="${RUNNER_SCOPE_PREFIX}" \
                         --env RUNNER_SCOPE="${RUNNER_SCOPE}" \
                         --env RUNNER_NAME="${runner_name}" \
                         --env RUNNER_GROUP_NAME="${RUNNER_GROUP_NAME}" \
                         --env RUNNER_LABELS="${RUNNER_LABELS}" \
                         --env WORKSPACE_ROOT_DIR="${WORKSPACE_ROOT_DIR}" \
                         --network=host --detach --rm --name "${runner_name}" \
                         --group-add "docker" \
                         "${CONTAINER_REPOSITORY}${CONTAINER_IMAGE_NAME}${CONTAINER_IMAGE_TAG}"
  fi
done
