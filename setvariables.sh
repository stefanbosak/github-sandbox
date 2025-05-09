#!/bin/bash

# define GitHub URIs
export GITHUB_URI="https://github.com"
export GITHUB_RAW_URI="https://raw.githubusercontent.com"

# GitHub runner project repository
export RUNNER_PROJECT="actions/runner"
export RUNNER_URI="${GITHUB_URI}/${RUNNER_PROJECT}";

# extract last GitHub runner version
export RUNNER_VERSION=$(git ls-remote --refs --sort='version:refname' --tags "${RUNNER_URI}" | awk -F"/" '!($0 ~ /alpha|beta|rc|dev|nightly|\{/){print $NF}' | tail -n 1 | sed 's/^v//g')

# GitHub action runner organization and repository name
export REPO=${REPO:-"<placeholder>"}

# GitHub action runner registration token
export REG_TOKEN="<placeholder>"

# GitHub action runner name
export RUNNER_NAME_PREFIX="runner-"
export RUNNER_NAME="${RUNNER_NAME_PREFIX}$(cat /proc/sys/kernel/random/uuid)"

# GitHub action runner group name
export RUNNER_GROUP_NAME=${RUNNER_GROUP_NAME:-"default"}

# GitHub action runner labels
export RUNNER_LABELS=${RUNNER_LABELS:-"self-hosted-default"}

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
export CONTAINER_IMAGE_NAME=${CONTAINER_IMAGE_NAME:-"github-sandbox"}

# it is crutial to have ":" in the beginning of the string
export CONTAINER_IMAGE_TAG=${CONTAINER_IMAGE_TAG:-":initial"}

# it is crutial to have "/" at the end of the string
# - if empty use local containers
export CONTAINER_REPOSITORY=${CONTAINER_REPOSITORY:-""}

# set location of workspace directory
# (temporary space within container image)
export WORKSPACE_ROOT_DIR=${WORKSPACE_ROOT_DIR:-"/home/${CONTAINER_USER}"}

# docker compose settings
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1
export DOCKER_DEFAULT_PLATFORM="${TARGETPLATFORM}"
