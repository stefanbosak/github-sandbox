# Intro
Aim of this repository is to offer support for GitHub self-hosted runners operated as Docker environment and share GitHub actions examples. 

# Examples
**setup**
- edit setvariables.sh (modify variables correspondingly if neeed)
- store GitHub classic personal access token in ~/GHToken.txt
- access token is required for automatic obtaining registration/remove token for runner
- currently only personal accounts are supported, organizations would be supported soon 

**Docker compose build, run and scale runners:**
- ./runner_compose_start.sh --group _group_ --labels _labels_

**Docker compose stop runners:**
- ./runners_compose_stop.sh

**Docker build runner:**
- docker build to create runner image:
- ./runner_build.sh

**Docker start runner instance:**
- docker run to start runner (arguments are optional, possible to start any amount as needed):
- ./runner_start.sh --group _group_ --labels _labels_ --amount _amount_

**Docker stop all runners:**
- docker container ls --filter "name=^runner-*" (get list of activated runners)
- docker container stop ^runner-... (stop selected runner)
- ./runners_stop.sh (stop all of previously started runners)

**Docker push runner image:**
- ./runner_push.sh (first setup ~/.docker/config.json accordingly to artifact container remote repositories)

**GitHub actions examples:**
- [![build_status_badge](../../actions/workflows/example-composite-action-use.yml/badge.svg?branch=main)](.github/workflows/example-composite-action-use.yml) composite actions
- [![build_status_badge](../../actions/workflows/example-reusable-workflow-call.yml/badge.svg?branch=main)](.github/workflows/example-reusable-workflow-call.yml) reusable workflows
- [![build_status_badge](../../actions/workflows/example-dependency.yml/badge.svg?branch=main)](.github/workflows/example-dependency.yml) job dependencies (support runner groups only available in organization account)
- [![build_status_badge](../../actions/workflows/example-linux-x64-arm64.yml/badge.svg?branch=main)](.github/workflows/example-linux-x64-arm64.yml) Linux x64, arm64
- [![build_status_badge](../../actions/workflows/example-macos-x64-arm64.yml/badge.svg?branch=main)](.github/workflows/example-macos-x64-arm64.yml) MacOS x64, arm64
- [![build_status_badge](../../actions/workflows/example-windows-x64-arm64.yml/badge.svg?branch=main)](.github/workflows/example-windows-x64-arm64.yml) Windows x64, arm64
- [![build_status_badge](../../actions/workflows/example-selfhosted-parallel-job.yml/badge.svg?branch=main)](.github/workflows/example-selfhosted-parallel-job.yml) self-hosted parallel job
- [![build_status_badge](../../actions/workflows/example-selfhosted-sequential-job.yml/badge.svg?branch=main)](.github/workflows/example-selfhosted-sequential-job.yml) self-hosted sequential job
