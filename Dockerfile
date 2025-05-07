# user in container
ARG CONTAINER_USER=runner
ARG CONTAINER_GROUP=runner

# set location of workspace directory
# (temporary space within container image)
ARG WORKSPACE_ROOT_DIR="/home/${CONTAINER_USER}"


# Debian release version
ARG DEBIAN_RELEASE=stable-slim
ARG DEBIAN_FRONTEND=noninteractive

# set the GitHub runner version
ARG RUNNER_VERSION=2.323.0

# base for image
FROM debian:${DEBIAN_RELEASE} AS runner-image

ARG DEBIAN_FRONTEND

ARG RUNNER_VERSION

ARG CONTAINER_USER
ARG CONTAINER_GROUP

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}/actions-runner"

# setup user profile
RUN groupadd --gid 1000 ${CONTAINER_USER} && \
    useradd --gid ${CONTAINER_GROUP} --groups sudo,${CONTAINER_USER} --create-home --uid 1000 ${CONTAINER_USER} -s /bin/bash && \
# update the base packages
    apt-get update -y && apt-get dist-upgrade -y && \
# install packages
    apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    libicu72 libkrb5-3 zlib1g \
    curl \
    jq \
    sudo \
    unzip && \
    apt-get clean &&  rm -rf /var/lib/apt/lists/* && \
# Set up the runner user
    echo "${CONTAINER_USER} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${CONTAINER_USER}"

# cd into the user directory, download and unpack the github actions runner
ADD "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" "${WORKSPACE_ROOT_DIR}/actions-runner/"

# copy over the start.sh script
COPY start.sh "/start.sh"

# make the script executable
RUN chown ${CONTAINER_USER}:${CONTAINER_GROUP} "/start.sh" && \
    chmod +x "/start.sh" && \
# Install dependencies
    cd "${WORKSPACE_ROOT_DIR}/actions-runner" && \
    tar -xvf "actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" -C "." && \
    ./bin/installdependencies.sh

# since the config and run script for actions are not allowed to be run by root,
# set the user to "runner" so all subsequent commands are run as the user
USER "${CONTAINER_USER}:${CONTAINER_GROUP}"

# set the entrypoint to the start.sh script
#ENTRYPOINT ["sh", "-c", "${WORKSPACE_ROOT_DIR}/start.sh"]
ENTRYPOINT ["/start.sh"]
