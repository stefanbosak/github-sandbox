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
    --amount) RUNNER_AMOUNT="$2"; shift;;
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

# defaults
RUNNER_AMOUNT=${RUNNER_AMOUNT:-1}

# start containers
docker compose -p "compose-${RUNNER_NAME_PREFIX}" up -d --scale runner=${RUNNER_AMOUNT}
