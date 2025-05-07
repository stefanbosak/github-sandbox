#!/bin/bash
#
# Act tool (for executing of GitHub Actions workflows locally)
#
# See more (https://github.com/nektos/act/blob/master/README.md)
#
# change parameters, add/modify propagated secrets before first use
#
cwd=$(dirname $(realpath "${0}"))

# check prerequisites (if all required tools are available)
TOOLS="act"

for tool in ${TOOLS}; do
  if [ -z "$(which ${tool})" ]; then
    echo "Tool ${tool} has not been found, please install tool in your system"
    echo "Installer: https://raw.githubusercontent.com/nektos/act/master/install.sh"
    exit 1
  fi
done

# perform job in dry-run mode
time act workflow_dispatch -W "${cwd}/.github/workflows/example-composite-action-use.yml" -s GH_TOKEN=$(cat ~/GHToken.txt) -j test -a "${USER}" --container-options "-v /dev/:/dev" -n
time act workflow_dispatch -W "${cwd}/.github/workflows/example-dependency.yml" -s GH_TOKEN=$(cat ~/GHToken.txt) -j test -a "${USER}" --container-options "-v /dev/:/dev" -n
time act workflow_dispatch -W "${cwd}/.github/workflows/example-linux-x64-arm64.yml" -s GH_TOKEN=$(cat ~/GHToken.txt) -j test -a "${USER}" --container-options "-v /dev/:/dev" -n
time act workflow_dispatch -W "${cwd}/.github/workflows/example-macos-x64-arm64.yml" -s GH_TOKEN=$(cat ~/GHToken.txt) -j test -a "${USER}" --container-options "-v /dev/:/dev" -n
time act workflow_dispatch -W "${cwd}/.github/workflows/example-reusable-workflow-call.yml" -s GH_TOKEN=$(cat ~/GHToken.txt) -j test -a "${USER}" --container-options "-v /dev/:/dev" -n
#time act workflow_dispatch -W "${cwd}/.github/workflows/example-selfhosted-parallel-job.yml" -s GH_TOKEN=$(cat ~/GHToken.txt) -j test -a "${USER}" --container-options "-v /dev/:/dev" -n
#time act workflow_dispatch -W "${cwd}/.github/workflows/example-selfhosted-sequential-job.yml" -s GH_TOKEN=$(cat ~/GHToken.txt) -j test -a "${USER}" --container-options "-v /dev/:/dev" -n
#time act workflow_dispatch -W "${cwd}/.github/workflows/example-windows-x64-arm64.yml" -s GH_TOKEN=$(cat ~/GHToken.txt) -j test -a "${USER}" --container-options "-v /dev/:/dev" -n
