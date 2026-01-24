#!/bin/bash
#
# Wrapper for recognizing latest available tools versions
#
cwd=$(dirname $(realpath "${0}"))

# site prefix
GH_SITE="github.com"
GH_URI_PREFIX="https://${GH_SITE}/"
GH_API_URI_PREFIX="https://api.${GH_SITE}/"

# check prerequisites (if all required tools are available)
TOOLS="curl git jq"

for tool in ${TOOLS}; do
  if [ -z "$(which ${tool})" ]; then
    echo "Tool ${tool} has not been found, please install tool in your system"
    exit 1
  fi
done

# array of special version resources (need specific version handling)
declare -a resources_array=("RUNNER_CLI_VERSION"
                           )

declare -A resources_dictionary

resources_dictionary["RUNNER_CLI_VERSION"]="actions/runner"

# sort resources dictionary keys
keys=$(echo "${!resources_dictionary[@]}" | tr ' ' '\n' | sort -V | tr '\n' ' ')

for key in ${keys}; do
  echo "${key}:"

  special_version_string_handling=0

  for resource in "${resources_array[@]}"; do
    if [ "${resource}" == "${key}" ]; then
      special_version_string_handling=1
      break
    fi
  done

  # extract tool version for git tag
  tool_version=$(git ls-remote --refs --sort='version:refname' --tags "${GH_URI_PREFIX}${resources_dictionary[$key]}" | grep -vE 'alpha|beta|rc|dev|None|list|nightly|\{' | cut -d'/' -f3 | tail -n 1)

  # try to extract release url
  tool_uri=$(curl -s -H "Accept: application/vnd.github+json" "${GH_API_URI_PREFIX}repos/${resources_dictionary[$key]}/releases/tags/${tool_version}" | jq -r '.html_url')

  # if no release url recognized change tool version based on data in PUSHED_CLI_VERSIONS.txt
  #
  # NOTE: release assets of given tool might be not ready but tool git tag already exists
  #
  if [ "${tool_uri}" = "null" ]; then
    if [ -f "${cwd}/PUSHED_CLI_VERSIONS.txt" ]; then
      # extract tool version from lastly pushed versions
      tool_version=$(awk -F "=" '/'"${key}"'/ {print $NF}' "${cwd}/PUSHED_CLI_VERSIONS.txt")
    fi
  fi

  if [ ${special_version_string_handling} -eq 1 ]; then
    # specific handling of version string is required ("v" at the beggining has to be removed from version string)
    echo "${tool_version#v}"
  else
    echo "${tool_version}"
  fi

  echo ";"
done
