#!/bin/bash
cwd=$(dirname $(realpath "${0}"))

# extract parameters from command-line
while [[ $# -gt 0 ]]; do
  case "${1}" in
    --organization|--org) export ORGANIZATION="${2}"; shift;;
    --repository|--repo) export REPOSITORY="${2}"; shift;;
    --group) RUNNER_GROUP_NAME="$2"; shift;;
    --labels) RUNNER_LABELS="$2"; shift;;
    --amount) RUNNER_AMOUNT="$2"; shift;;
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

# defaults
RUNNER_AMOUNT=${RUNNER_AMOUNT:-1}

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

runner_name_ext="${RUNNER_NAME}"
IFS=',' read -ra PLATFORMS <<< "${TARGETPLATFORM}"

for platform in "${PLATFORMS[@]}"; do
  arch="${platform#linux/}"  # remove "linux/" prefix
  arch="${arch%%/*}"         # extract only the architecture part
  arch="${arch/64/}"         # remove 64

  # start containers
  export RUNNER_NAME="c-${arch}-${runner_name_ext}"
  export COMPOSE_FILE="${cwd}/docker-compose-${arch}.yml"
  docker compose -p "${RUNNER_NAME}" up -d --scale runner=${RUNNER_AMOUNT}
done
