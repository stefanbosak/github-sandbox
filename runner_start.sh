#!/bin/bash
cwd=$(dirname $(realpath "${0}"))

# extract parameters from command-line
while [[ $# -gt 0 ]]; do
  case "${1}" in
    --organization|--org)
      # create temporary workspace
      TMP_DIR=$(mktemp -d)
      TMP_SCRIPT="${TMP_DIR}/script.sh"

      # register cleanup handler for removing temporary workspace
      trap 'rm -fr ${TMP_DIR}' EXIT

      # generate temporary script
      echo "#!/bin/bash" > "${TMP_SCRIPT}"
      echo "export ORGANIZATION=${2}" >> "${TMP_SCRIPT}"

      # make script executable
      chmod +x "${TMP_SCRIPT}"

      # source content of temporary script
      # publish exports to who called me
      # (this script)
      source "${TMP_SCRIPT}"
      shift
    ;;

    --repository|--repo)
      # create temporary workspace
      TMP_DIR=$(mktemp -d)
      TMP_SCRIPT="${TMP_DIR}/script.sh"

      # register cleanup handler for removing temporary workspace
      trap 'rm -fr ${TMP_DIR}' EXIT

      # generate temporary script
      echo "#!/bin/bash" > "${TMP_SCRIPT}"
      echo "export REPOSITORY=${2}" >> "${TMP_SCRIPT}"

      # make script executable
      chmod +x "${TMP_SCRIPT}"

      # source content of temporary script
      # publish exports to who called me
      # (this script)
      source "${TMP_SCRIPT}"
      shift
    ;;

    --group) RUNNER_GROUP_NAME="$2"; shift;;
    --labels) RUNNER_LABELS="$2"; shift;;
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

# start unique standalone GitHub runner Docker container (optionally with labels, group name)
docker container run --platform "${TARGETPLATFORM}" -ti -v /dev:/dev \
                     --env GH_TOKEN="${GH_TOKEN}" \
                     --env GH_API_VERSION="${GH_API_VERSION}" \
                     --env GH_API_URI_PREFIX="${GH_API_URI_PREFIX}" \
                     --env RUNNER_SCOPE_PREFIX="${RUNNER_SCOPE_PREFIX}" \
                     --env RUNNER_SCOPE="${RUNNER_SCOPE}" \
                     --env RUNNER_NAME="${RUNNER_NAME}" \
                     --env RUNNER_GROUP_NAME="${RUNNER_GROUP_NAME}" \
                     --env RUNNER_LABELS="${RUNNER_LABELS}" \
                     --env WORKSPACE_ROOT_DIR="${WORKSPACE_ROOT_DIR}" \
                     --network=host --detach --rm --name "${RUNNER_NAME}" \
                     "${CONTAINER_REPOSITORY}${CONTAINER_IMAGE_NAME}${CONTAINER_IMAGE_TAG}"
