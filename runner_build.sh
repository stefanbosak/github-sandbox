#!/bin/bash
cwd=$(dirname $(realpath "${0}"))

# directory for storing capture of pushed versions
PUSHED_CLI_VERSIONS_FILE_DIR=$(mktemp -d)

# set variables
source "${cwd}/setvariables.sh"

# check if previous environment file exists and remove
if [ -f "${GITHUB_ENV_TAIL_FILE}" ]; then
  rm -f "${GITHUB_ENV_TAIL_FILE}"
fi

# cleanup
trap 'rm -fr "${PUSHED_CLI_VERSIONS_FILE_DIR}"' EXIT

# set variables
source "${cwd}/setvariables.sh"

# check prerequisites (if all required tools are available)
TOOLS="docker"

for tool in ${TOOLS}; do
  if [ -z "$(which ${tool})" ]; then
    echo "Tool ${tool} has not been found, please install tool in your system"
    exit 1
  fi
done

# build custom GitHub self-hosted runner Docker container
docker buildx build --network=host --force-rm --rm \
                    --platform "${TARGETPLATFORM}" \
                    --build-arg TARGETOS="${TARGETOS}" \
                    --build-arg RUNNER_CLI_VERSION="${RUNNER_CLI_VERSION}" \
                    --build-arg UBUNTU_RELEASE="${UBUNTU_RELEASE}" \
                    --build-arg CONTAINER_USER="${CONTAINER_USER}" \
                    --build-arg CONTAINER_GROUP="${CONTAINER_GROUP}" \
                    --build-arg CONTAINER_USER_ID="${CONTAINER_USER_ID}" \
                    --build-arg CONTAINER_GROUP_ID="${CONTAINER_GROUP_ID}" \
                    --build-arg WORKSPACE_ROOT_DIR="${WORKSPACE_ROOT_DIR}" \
                    -t "${CONTAINER_IMAGE_NAME}${CONTAINER_IMAGE_TAG}" \
                    -f "${cwd}/Dockerfile" "${cwd}"

# clean temporary stage images
# - regexp in container image filters are still not supported in Docker
docker image prune -f --filter "label=stage=${CONTAINER_IMAGE_NAME}-image"
