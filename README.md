# Intro
Aim of this repository is to offer support for GitHub self-hosted runners operated as Docker environment and share GitHub actions examples. 

covered tool:
- [GitHub Actions runner](https://github.com/actions/runner)
- [Docker in Docker for AMD64](https://www.docker.com/resources/docker-in-docker-containerized-ci-workflows-dockercon-2023/)

> [!NOTE]
> Every script and file would be reasonable well commented and relevant details can be found there.

> [!IMPORTANT]
> Check details before taking any action.

> [!CAUTION]
> User is responsible for any modification and execution of any parts from this repository.

# Examples
## setup
- edit setvariables.sh (modify variables correspondingly if neeed)
- store GitHub classic personal access token in ~/GHToken.txt
- store GitHub fine-grained personal access token for organization in ~/GHTokenOrg.txt

## Multi-architecture support
- on host system with QEMU ARM64 binfmt enabled capablities build can generate multi-architecture images (AMD64 & ARM64)

## DinD (Docker in Docker) support
- AMD64 image contains Docker installation
- ARM64 is not supported (require ARM64 kernel on host system)

## Docker compose build, run and scale runners
- for registration of runner as shared under organization use parameter --repo null
`./runner_compose_start.sh --org <organization> --repo <repository> --group <group> --labels <label1,label2> --amount <amount>`

## Docker compose stop runners
`./runners_compose_stop.sh --org <organization> --repo <repository>`

## Docker build runner
- docker build to create runner image: `./runner_build.sh`

## Docker start runner instance
- docker run to start runner (arguments are optional, possible to start any amount as needed)
- for registration of runner as shared under organization use parameter --repo null
`./runner_start.sh --org <organization> --repo <repository> --group <group> --labels <labels1,label2> `

## Docker stop all runners
- stop all of previously started runners
`./runners_stop.sh --org <organization> --repo <repository>`

## Docker push runner image
- first setup ~/.docker/config.json accordingly to artifact container remote repositories
`./runner_push.sh`

## GitHub actions examples
- [![build_status_badge](../../actions/workflows/example-composite-action-use.yml/badge.svg?branch=main)](.github/workflows/example-composite-action-use.yml) composite actions
- [![build_status_badge](../../actions/workflows/example-reusable-workflow-call.yml/badge.svg?branch=main)](.github/workflows/example-reusable-workflow-call.yml) reusable workflows
- [![build_status_badge](../../actions/workflows/example-dependency.yml/badge.svg?branch=main)](.github/workflows/example-dependency.yml) job dependencies (support runner groups only available in organization account)
- [![build_status_badge](../../actions/workflows/example-linux-x64-arm64.yml/badge.svg?branch=main)](.github/workflows/example-linux-x64-arm64.yml) Linux x64, arm64
- [![build_status_badge](../../actions/workflows/example-macos-x64-arm64.yml/badge.svg?branch=main)](.github/workflows/example-macos-x64-arm64.yml) MacOS x64, arm64
- [![build_status_badge](../../actions/workflows/example-windows-x64-arm64.yml/badge.svg?branch=main)](.github/workflows/example-windows-x64-arm64.yml) Windows x64, arm64
- [![build_status_badge](../../actions/workflows/example-selfhosted-parallel-job.yml/badge.svg?branch=main)](.github/workflows/example-selfhosted-parallel-job.yml) self-hosted parallel job
- [![build_status_badge](../../actions/workflows/example-selfhosted-sequential-job.yml/badge.svg?branch=main)](.github/workflows/example-selfhosted-sequential-job.yml) self-hosted sequential job
