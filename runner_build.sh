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

# build custom GitHub self-hosted runner Docker container
docker buildx build --network=host --force-rm --rm \
                    --platform "${TARGETPLATFORM}" \
                    --build-arg TARGETOS="${TARGETOS}" \
                    --build-arg RUNNER_VERSION="${RUNNER_VERSION}" \
                    --build-arg UBUNTU_RELEASE="${UBUNTU_RELEASE}" \
                    --build-arg CONTAINER_USER="${CONTAINER_USER}" \
                    --build-arg CONTAINER_GROUP="${CONTAINER_GROUP}" \
                    --build-arg CONTAINER_USER_ID="${CONTAINER_USER_ID}" \
                    --build-arg CONTAINER_GROUP_ID="${CONTAINER_GROUP_ID}" \
                    --build-arg WORKSPACE_ROOT_DIR="${WORKSPACE_ROOT_DIR}" \
                    -t "${CONTAINER_IMAGE_NAME}${CONTAINER_IMAGE_TAG}" \
                    -f "${cwd}/Dockerfile" "${cwd}"

# clean temporary images
docker image prune -f --filter label="stage=github-sandbox-*" --filter "dangling=true"
