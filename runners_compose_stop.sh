#!/bin/bash
cwd=$(dirname $(realpath "${0}"))

# extract parameters from command-line
while [[ $# -gt 0 ]]; do
  case "${1}" in
    --organization|--org) export ORGANIZATION="${2}"; shift;;
    --repository|--repo) export REPOSITORY="${2}"; shift;;
    --group) export RUNNER_GROUP_NAME="${2}"; shift;;
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

IFS=',' read -ra PLATFORMS <<< "${TARGETPLATFORM}"

for platform in "${PLATFORMS[@]}"; do
  arch="${platform#linux/}"  # remove "linux/" prefix
  arch="${arch%%/*}"         # extract only the architecture part
  arch="${arch/64/}"         # remove 64

  # create runner name
  runner_name="c-${arch}-${RUNNER_NAME_PREFIX}"

  # stop all standalone Docker containers
  if [ ! -z "$(docker container ls --filter "name=^${runner_name}*" -qa)" ]; then
    docker container stop --timeout 360 $(docker container ls --filter "name=^${runner_name}*" -qa)
    docker container rm -f $(docker container ls --filter "name=^${runner_name}*" -qa)
  fi
done

# runner groups are only in organizations
if [ "${RUNNER_SCOPE_PREFIX}" == "orgs" ]; then
  # obtain runner group id
  runner_group_id=$(curl -sL -H "Accept: application/vnd.github+json" \
                             -H "Authorization: Bearer ${GH_TOKEN}" \
                             -H "X-GitHub-Api-Version: ${GH_API_VERSION}" \
                             -X GET "${GH_API_URI_PREFIX}${RUNNER_SCOPE_PREFIX}/${RUNNER_SCOPE}/actions/runner-groups" | jq -r ".runner_groups[] | select(.name == \"${RUNNER_GROUP_NAME}\") | .id")

  # proceed only if given runner id exists
  if [ ! -z "${runner_group_id}" ]; then
    runner_group_members=$(curl -sL -H "Accept: application/vnd.github+json" \
                                    -H "Authorization: Bearer ${GH_TOKEN}" \
                                    -H "X-GitHub-Api-Version: ${GH_API_VERSION}" \
                                    -X GET "${GH_API_URI_PREFIX}${RUNNER_SCOPE_PREFIX}/${RUNNER_SCOPE}/actions/runner-groups/${runner_group_id}/runners" | jq -r ".total_count")

    if [[ "${runner_group_members}" -eq 0 ]]; then
      runner_group=$(curl -sL -H "Accept: application/vnd.github+json" \
                              -H "Authorization: Bearer ${GH_TOKEN}" \
                              -H "X-GitHub-Api-Version: ${GH_API_VERSION}" \
                              -X DELETE "${GH_API_URI_PREFIX}${RUNNER_SCOPE_PREFIX}/${RUNNER_SCOPE}/actions/runner-groups/${runner_group_id}")
    fi
  fi
fi
