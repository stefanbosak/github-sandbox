<div align="center">

# GitHub sandbox
**GitHub runner**

[![build_status_badge](../../actions/workflows/docker-image-native-multiplatform-runner.yaml/badge.svg?branch=main)](.github/workflows/docker-image-native-multiplatform-runner.yaml)
[![GitHub_runner](https://img.shields.io/badge/GitHub-runner-blue)](https://github.com/actions/runner)

</div>

---

# Latest Build

<!-- VERSION_INFO_START -->
| Component | Version |
|-----------|---------|
| **Runner** | [`2.336.0`](https://github.com/actions/runner/releases/tag/v2.336.0) |
| **Ant** | [`1.10.17`](https://github.com/apache/ant/releases/tag/rel/1.10.17) |
| **Gradle** | [`9.6.1`](https://github.com/gradle/gradle/releases/tag/v9.6.1) |
| **Groovy** | [`5.0.7`](https://github.com/apache/groovy/releases/tag/GROOVY_5_0_7) |
| **JDK** | [`21.0.11-tem`](https://sdkman.io/jdks) |
| **Kotlin** | [`2.4.10`](https://github.com/JetBrains/kotlin/releases/tag/v2.4.10) |
| **Maven** | [`3.9.16`](https://github.com/apache/maven/releases/tag/maven-3.9.16) |

> 🔄 Last updated: 2026-07-24T12:59:29+02:00 · [Build #39](https://github.com/stefanbosak/github-sandbox/actions/runs/30094346806)
<!-- VERSION_INFO_END -->

---
Aim of this repository is to offer support for GitHub self-hosted runners operated as Docker environment and share GitHub actions examples. 

covered tools:
- [GitHub Actions runner](https://github.com/actions/runner)
- [Docker](https://docker.com)
- [SDKMAN](https://sdkman.io/)

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
- emulated ARM64 is not supported on (require ARM64 kernel on host system)

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
- [![build_status_badge](../../actions/workflows/docker-image-native-multiplatform-runner.yaml/badge.svg?branch=main)](.github/workflows/docker-image-native-multiplatform-runner.yaml) native multi-platform (AMD64/ARM64) Docker image build, merge, test, scan and README update
- [![build_status_badge](../../actions/workflows/example-composite-action-use.yaml/badge.svg?branch=main)](.github/workflows/example-composite-action-use.yaml) composite actions
- [![build_status_badge](../../actions/workflows/example-reusable-workflow-call.yaml/badge.svg?branch=main)](.github/workflows/example-reusable-workflow-call.yaml) reusable workflows
- [![build_status_badge](../../actions/workflows/example-dependency.yaml/badge.svg?branch=main)](.github/workflows/example-dependency.yaml) job dependencies (support runner groups only available in organization account)
- [![build_status_badge](../../actions/workflows/example-linux-x64-arm64.yaml/badge.svg?branch=main)](.github/workflows/example-linux-x64-arm64.yaml) Linux x64, arm64
- [![build_status_badge](../../actions/workflows/example-macos-x64-arm64.yaml/badge.svg?branch=main)](.github/workflows/example-macos-x64-arm64.yaml) MacOS x64, arm64
- [![build_status_badge](../../actions/workflows/example-windows-x64-arm64.yaml/badge.svg?branch=main)](.github/workflows/example-windows-x64-arm64.yaml) Windows x64, arm64
- [![build_status_badge](../../actions/workflows/example-selfhosted-parallel-job.yaml/badge.svg?branch=main)](.github/workflows/example-selfhosted-parallel-job.yaml) self-hosted parallel job
- [![build_status_badge](../../actions/workflows/example-selfhosted-sequential-job.yaml/badge.svg?branch=main)](.github/workflows/example-selfhosted-sequential-job.yaml) self-hosted sequential job

<div align="center">

<span style="color: #8250df;">**Made with ❤ for ☁ GitHub ecosystem and 🔒 security**</span>

</div>
