#!/bin/bash
#
# Configuration of versions and other variables
#
# changed: 2025-May-10
#
# NOTEs:
# - any execution and modification(s) is only in responsibility of user
# - add container volume mapping(s) based on user preference
# - modify/align to fit user needs/requirements at your own
# - if needed use environment variables with same naming
#   (following variables have default/pre-defined values
#    and can be overrided by environment variables)
#
cwd=$(dirname $(realpath "${0}"))

# GitHub Actions workflow environment tail file
export GITHUB_ENV_TAIL_FILE=${GITHUB_ENV_TAIL_FILE:-"/tmp/github_env_tail"}

# automatically recognize and set latest available tools versions
# (any tool version can be overrided via corresponding variable)
source "${cwd}/set_latest_versions_strings.sh"

# site prefix
export GH_SITE="github.com"
export GH_URI_PREFIX="https://${GH_SITE}/"
export GH_API_URI_PREFIX="https://api.${GH_SITE}/"
export GH_API_VERSION=$(curl -s -L -H "Accept: application/vnd.github+json" "${GH_API_URI_PREFIX}versions" | jq -r '.[-1]')

# GitHub personal token
GH_PERSONAL_TOKEN=$(cat ~/GHToken.txt)

# gathering information about user of personal GitHub account via GitHub API
export USER=$(curl -s -L -H "Accept: application/vnd.github+json" \
                         -H "Authorization: Bearer ${GH_PERSONAL_TOKEN}" \
                         -H "X-GitHub-Api-Version: ${GH_API_VERSION}" \
                         -X GET "${GH_API_URI_PREFIX}user" | jq -r '.login')

# gathering information about organization of personal GitHub account via GitHub API
#
# NOTES:
# - supported only when GitHub account is member of one organization
# - when there are more memberships across several organizations set organization name manually as variable value
#
export ORGANIZATION=${ORGANIZATION:-$(curl -s -L -H "Accept: application/vnd.github+json" \
                                                 -H "Authorization: Bearer ${GH_PERSONAL_TOKEN}" \
                                                 -H "X-GitHub-Api-Version: ${GH_API_VERSION}" \
                                                 -X GET "${GH_API_URI_PREFIX}user/orgs" | jq -r '.[-1].login')}

if [ "${REPOSITORY}" != "null" ]; then
  # GitHub action runner URI <owner>/<repository name> (runner for repository)
  export RUNNER_SCOPE_PREFIX="repos"
  export GH_TOKEN=${GH_PERSONAL_TOKEN}
  REPOSITORY=${REPOSITORY:-"$(basename ${cwd})"}

  for repository_scope in "${USER}" "${ORGANIZATION}"; do
    repository_owner=$(curl -s -L -H "Accept: application/vnd.github+json" \
                                  -H "Authorization: Bearer ${GH_PERSONAL_TOKEN}" \
                                  -H "X-GitHub-Api-Version: ${GH_API_VERSION}" \
                                  -X GET "${GH_API_URI_PREFIX}repos/${repository_scope}/${REPOSITORY}" | jq -r '.owner.login')

    if [ "${repository_owner}" != "null" ]; then
      export RUNNER_SCOPE=${RUNNER_SCOPE:-"${repository_owner}/${REPOSITORY}"}
    fi
  done
else
  # GitHub action runner URI <oganization> (runner for organization)
  export RUNNER_SCOPE_PREFIX="orgs"
  export RUNNER_SCOPE=${RUNNER_SCOPE:-"${ORGANIZATION}"}
  export GH_TOKEN=$(cat ~/GHTokenOrg.txt)
fi

export RUNNER_CLI_VERSION=${RUNNER_CLI_VERSION:-2.324.0}

# GitHub action runner name
export RUNNER_NAME_PREFIX="runner-${RUNNER_SCOPE_PREFIX}-${REPOSITORY}-"
export RUNNER_NAME="${RUNNER_NAME_PREFIX}$(cat /proc/sys/kernel/random/uuid)"

# GitHub action runner group name
export RUNNER_GROUP_NAME=${RUNNER_GROUP_NAME:-"default"}

# GitHub action runner labels
export RUNNER_LABELS=${RUNNER_LABELS:-"self-hosted-${RUNNER_GROUP_NAME}"}

# Ubuntu releases URI
export UBUNTU_RELEASES_URI="https://changelogs.ubuntu.com/meta-release"

# Ubuntu LTS releases URI (comment if prefer non-LTS)
export UBUNTU_RELEASES_URI="${UBUNTU_RELEASES_URI}-lts"

# extract last supported Ubuntu LTS release
export UBUNTU_RELEASE=$(curl -s "${UBUNTU_RELEASES_URI}" | awk '/^Version:/ {if ($2 ~ /^[0-9]{2}\.[0-9]{2}\./) version=substr($2, 1, 5)} /^Supported: 1/ {if (version) print version}' | tail -n 1)

# default target OS, architecture and platforms
export TARGETOS=${TARGETOS:-linux}
export TARGETARCH=${TARGETARCH:-$(dpkg --print-architecture)}
export TARGETPLATFORM=${TARGETPLATFORM:-"${TARGETOS}/${TARGETARCH}"}

# container user and group
export CONTAINER_USER=${CONTAINER_USER:-$(id -n -u)}
export CONTAINER_GROUP=${CONTAINER_GROUP:-$(id -n -g)}

# container user ID and group ID
export CONTAINER_USER_ID=${CONTAINER_USER_ID:-$(id -u)}
export CONTAINER_GROUP_ID=${CONTAINER_GROUP_ID:-$(id -g)}

# container image name
export CONTAINER_IMAGE_NAME=${CONTAINER_IMAGE_NAME:-"$(basename ${cwd})"}

# it is crutial to have ":" in the beginning of the string
export CONTAINER_IMAGE_TAG=${CONTAINER_IMAGE_TAG:-":initial"}

# it is crutial to have "/" at the end of the string
# - if empty use local containers
# - GitHub package container image example: ghcr.io/<organization> or ghcr.io/<owner>/
# - DockerHub container image example: docker.io/<organization>/
export CONTAINER_REPOSITORY=${CONTAINER_REPOSITORY:-""}

# set location of workspace directory
# (temporary space within container image)
export WORKSPACE_ROOT_DIR=${WORKSPACE_ROOT_DIR:-"/home/${CONTAINER_USER}"}

# docker compose settings
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1
export DOCKER_DEFAULT_PLATFORM="${TARGETPLATFORM}"
