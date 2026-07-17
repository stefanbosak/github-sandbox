# user in container
ARG CONTAINER_USER=user
ARG CONTAINER_GROUP=user

ARG CONTAINER_USER_ID=1000
ARG CONTAINER_GROUP_ID=1000

# JDKs, SDKs
ARG ANT_VERSION=1.10.17
ARG JDK_8_VERSION=8.0.492-tem
ARG JDK_21_VERSION=21.0.11-tem
ARG GRADLE_VERSION=9.6.1
ARG GROOVY_VERSION=5.0.6
ARG MAVEN_VERSION=3.9.16
ARG KOTLIN_VERSION=2.4.0

# set location of workspace directory
# (temporary space within container image)
ARG WORKSPACE_ROOT_DIR="/home/${CONTAINER_USER}"

# Debian release version
ARG DEBIAN_RELEASE=stable-slim
ARG DEBIAN_FRONTEND=noninteractive

# set the GitHub runner version
ARG RUNNER_CLI_VERSION=2.335.1

# builder
FROM alpine:latest AS github-sandbox-builder

LABEL stage="github-sandbox-builder" \
      description="Debian-based container builder for preparing GitHub tools self-hosted runner" \
      org.opencontainers.image.description="Debian-based container builder for preparing GitHub tools self-hosted runner" \
      org.opencontainers.image.source=https://github.com/stefanbosak/github-sandbox

ARG TARGETOS
ARG TARGETARCH

ARG RUNNER_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}/actions-runner"

# download and unpack the github actions runner
RUN apk --no-cache add curl && uri=$(echo "https://github.com/actions/runner/releases/download/v${RUNNER_CLI_VERSION}/actions-runner-${TARGETOS}-${TARGETARCH}-${RUNNER_CLI_VERSION}.tar.gz" | \
    sed -e 's/amd64/x64/g') && curl -sSL "${uri}" -o "${WORKSPACE_ROOT_DIR}/actions-runner/actions-runner.tar.gz" && \
    cd "${WORKSPACE_ROOT_DIR}/actions-runner" && \
    tar -xvf "actions-runner.tar.gz" -C "." && \
    rm -f "actions-runner.tar.gz"

# base for image
FROM debian:${DEBIAN_RELEASE} AS github-sandbox-image

LABEL stage="github-sandbox-image" \
      description="Debian-based container GitHub tools self-hosted runner" \
      org.opencontainers.image.description="Debian-based container GitHub tools self-hosted runner" \
      org.opencontainers.image.source=https://github.com/stefanbosak/github-sandbox

ARG DEBIAN_FRONTEND

# set locales
ENV LANG=C.UTF-8
ENV TZ=UTC

ARG TARGETOS
ARG TARGETARCH

ARG CONTAINER_USER
ARG CONTAINER_GROUP

ARG CONTAINER_USER_ID
ARG CONTAINER_GROUP_ID

# JDKs, SDKs
ARG ANT_VERSION
ARG JDK_8_VERSION
ARG JDK_21_VERSION
ARG GRADLE_VERSION
ARG GROOVY_VERSION
ARG MAVEN_VERSION
ARG KOTLIN_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# update the base packages
RUN apt-get update -y && apt-get dist-upgrade -y \
# install packages
    && apt-get install -y --no-install-recommends \
      apt-transport-https apt-utils bash-completion bc build-essential ca-certificates curl dnsutils \
      file gh git git-lfs gnupg2 gpg iproute2 iputils-ping jq kmod less libicu-dev libicu76 libkrb5-3 locales lzma lz4 \
      nano net-tools netcat-openbsd openssh-client pigz postgresql-client procps psmisc python-is-python3 p7zip-full \
      rsync ripgrep sqlite3 socat sudo unzip vim-tiny wget yq xz-utils zip zlib1g zstd zsync \
    && apt-get autoremove -y &&  apt-get autoclean -y && apt-get clean && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-c"]

# Set up the runner user
RUN echo "${CONTAINER_USER} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${CONTAINER_USER}" && \
# install SDKMAN
    export SDKMAN_DIR="/usr/local/sdkman" && curl -s "https://get.sdkman.io?ci=true&rcupdate=false" | bash && \
    . "/usr/local/sdkman/bin/sdkman-init.sh" && \
# install JDKs and SDKs
    sdk install java ${JDK_8_VERSION} && \
    sdk install java ${JDK_21_VERSION} && \
    sdk install ant ${ANT_VERSION} && \
    sdk install gradle ${GRADLE_VERSION} && \
    sdk install groovy ${GROOVY_VERSION} && \
    sdk install maven ${MAVEN_VERSION} && \
    sdk install kotlin ${KOTLIN_VERSION} && \
# Install uv (Python package manager)
    curl -sSfL "https://astral.sh/uv/install.sh" \
      | UV_INSTALL_DIR=/usr/local/bin bash && \
# Install bun (all-in-one JS toolkit)
    curl -fsSL "https://bun.com/install" \
      | BUN_INSTALL=/usr/local bash

RUN if getent group "${CONTAINER_GROUP_ID}" > /dev/null; then \
      _existing_group="$(getent group "${CONTAINER_GROUP_ID}" | cut -d: -f1)"; \
      if [ "${_existing_group}" != "${CONTAINER_GROUP}" ]; then \
        groupmod -n "${CONTAINER_GROUP}" "${_existing_group}"; \
      fi; \
    else \
      groupadd --gid "${CONTAINER_GROUP_ID}" "${CONTAINER_GROUP}"; \
    fi \
    && if getent passwd "${CONTAINER_USER_ID}" > /dev/null; then \
         _existing_user="$(getent passwd "${CONTAINER_USER_ID}" | cut -d: -f1)"; \
         if [ "${_existing_user}" != "${CONTAINER_USER}" ]; then \
           if [ -d "/home/${_existing_user}" ]; then \
             mv "/home/${_existing_user}" "/home/${CONTAINER_USER}"; \
           fi; \
           usermod -d "/home/${CONTAINER_USER}" -l "${CONTAINER_USER}" "${_existing_user}"; \
         fi; \
       else \
         useradd \
           --uid "${CONTAINER_USER_ID}" \
           --gid "${CONTAINER_GROUP_ID}" \
           --groups "${CONTAINER_GROUP}" \
           -M -d "${WORKSPACE_ROOT_DIR}" \
           -s /bin/bash \
           "${CONTAINER_USER}"; \
       fi \
    && chown -R "${CONTAINER_USER}:${CONTAINER_GROUP}" "${WORKSPACE_ROOT_DIR}"

# copy scripts
COPY start.sh "/start.sh"

# copy data from builder
COPY --from=github-sandbox-builder "${WORKSPACE_ROOT_DIR}/actions-runner" "${WORKSPACE_ROOT_DIR}/actions-runner"

# make the script executable
RUN chown "${CONTAINER_USER}:${CONTAINER_GROUP}" "/start.sh" && \
    chmod +x "/start.sh" && \
# Install dependencies
    cd "${WORKSPACE_ROOT_DIR}/actions-runner" && \
    ./bin/installdependencies.sh && \
    chown -R "${CONTAINER_USER}:${CONTAINER_GROUP}" "${WORKSPACE_ROOT_DIR}" && \
# DiD (Docker in Docker)
# - DinD via QEMU on ARM64 is not supported
#   (ARM64 requires ARM64 kernel from host system which is not present on AMD64 host)
    curl -fsSL https://get.docker.com | sh && \
    if ! getent group docker > /dev/null 2>&1; then \
      groupadd docker; \
    fi && \
    usermod -aG docker,sudo "${CONTAINER_USER}"

# since the config and run script for actions are not allowed to be run by root,
# set the user to "runner" so all subsequent commands are run as the user
USER "${CONTAINER_USER}:${CONTAINER_GROUP}"

RUN cp /etc/skel/.bashrc "${HOME}" && \
    echo 'export SDKMAN_DIR="/usr/local/sdkman"' >> "${HOME}/.bashrc" && \
    echo 'source "/usr/local/sdkman/bin/sdkman-init.sh"' >> "${HOME}/.bashrc"

# set the entrypoint to the start.sh script
ENTRYPOINT ["/start.sh"]
