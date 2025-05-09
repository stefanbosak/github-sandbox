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

# stop all standalone Docker containers
if [ ! -z "$(docker container ls --filter "name=${RUNNER_NAME_PREFIX}*" -q)" ]; then
  docker container stop $(docker container ls --filter "name=${RUNNER_NAME_PREFIX}*" -q)
fi
