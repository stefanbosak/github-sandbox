#!/bin/bash

# define GitHub URIs
export GITHUB_URI="https://github.com"
export GITHUB_RAW_URI="https://raw.githubusercontent.com"

# Ubuntu LTS releases URI
export UBUNTU_RELEASES_URI="https://changelogs.ubuntu.com/meta-release-lts"

export RUNNER_PROJECT="actions/runner"
export RUNNER_URI="${GITHUB_URI}/${RUNNER_PROJECT}";

# extract last GitHub runner version
export RUNNER_VERSION=$(git ls-remote --refs --sort='version:refname' --tags "${RUNNER_URI}" | awk -F"/" '!($0 ~ /alpha|beta|rc|dev|nightly|\{/){print $NF}' | tail -n 1 | sed 's/^v//g')

# extract last supported Ubuntu LTS release
export UBUNTU_RELEASE=$(curl -s "${UBUNTU_RELEASES_URI}" | awk '/^Version:/ {if ($2 ~ /^[0-9]{2}\.[0-9]{2}\./) version=substr($2, 1, 5)} /^Supported: 1/ {if (version) print version}' | tail -n 1)

# GitHub action runner organization and repository name
export REPO=${REPO:-"<placeholder>"}

# GitHub action runner registration token
export REG_TOKEN="<placeholder>"

# GitHub action runner name
export RUNNER_NAME="runner-$(cat /proc/sys/kernel/random/uuid)"

# GitHub action runner group name
export RUNNER_GROUP_NAME=${RUNNER_GROUP_NAME:-"default"}

# GitHub action runner labels
export RUNNER_LABELS=${RUNNER_LABELS:-"self-hosted-default"}

# container image name
export CONTAINER_IMAGE_NAME=${CONTAINER_IMAGE_NAME:-"runner-image"}

# default target OS, architecture and platforms
export TARGETOS=${TARGETOS:-linux}
export TARGETARCH=${TARGETARCH:-$(dpkg --print-architecture)}
export TARGETPLATFORM=${TARGETPLATFORM:-"${TARGETOS}/${TARGETARCH}"}

# docker compose settings
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1
export DOCKER_DEFAULT_PLATFORM="${TARGETPLATFORM}"

# set location of workspace directory
# (temporary space within container image)
export WORKSPACE_ROOT_DIR=${WORKSPACE_ROOT_DIR:-"/home/runner"}

# container user and group
export CONTAINER_USER=${CONTAINER_USER:-"runner"}
export CONTAINER_GROUP=${CONTAINER_GROUP:-"runner"}
