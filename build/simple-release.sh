#!/usr/bin/env bash

readonly KUBE_SUPPORTED_CLIENT_PLATFORMS=(
  linux/amd64
  linux/386
  linux/arm
  linux/arm64
  linux/s390x
  linux/ppc64le
  darwin/amd64
  darwin/arm64
  windows/amd64
  windows/386
  windows/arm64
)

kube::version::ldflags() {
  KUBECTL_ROOT=$(dirname "${BASH_SOURCE[0]}")
  # TODO(xxxx): Put actual versions here
  KUBE_VERSION=v0.99.0
  KUBE_GIT_COMMIT=$(git rev-parse HEAD)
  KUBE_GIT_VERSION=v0.99.0


  local -a ldflags
  function add_ldflag() {
    local key=${1}
    local val=${2}
    ldflags+=(
      "-X '${KUBECTL_ROOT}/vendor/k8s.io/client-go/pkg/version.${key}=${val}'"
      "-X '${KUBECTL_ROOT}/vendor/k8s.io/kubectl/pkg/util/version.${key}=${val}'"
      "-X 'k8s.io/client-go/pkg/version.${key}=${val}'"
      "-X 'k8s.io/kubectl/pkg/util/version.${key}=${val}'"
    )
  }

  add_ldflag "buildDate" "$(date ${SOURCE_DATE_EPOCH:+"--date=@${SOURCE_DATE_EPOCH}"} -u +'%Y-%m-%dT%H:%M:%SZ')"
  if [[ -n ${KUBE_GIT_COMMIT-} ]]; then
    add_ldflag "gitCommit" "${KUBE_GIT_COMMIT}"
    add_ldflag "gitTreeState" "${KUBE_GIT_TREE_STATE}"
  fi

  if [[ -n ${KUBE_GIT_VERSION-} ]]; then
    add_ldflag "gitVersion" "${KUBE_GIT_VERSION}"
  fi

  if [[ -n ${KUBE_GIT_MAJOR-} && -n ${KUBE_GIT_MINOR-} ]]; then
    add_ldflag "gitMajor" "${KUBE_GIT_MAJOR}"
    add_ldflag "gitMinor" "${KUBE_GIT_MINOR}"
  fi

  # The -ldflags parameter takes a single string, so join the output.
  echo "${ldflags[*]-}"
}

for platform in "${KUBE_SUPPORTED_CLIENT_PLATFORMS[@]}"
do
    splits=(${platform//\// })
    GOOS=${splits[0]}
    GOARCH=${splits[1]}
    output_path=bin/${GOOS}/${GOARCH}
    if [ ${GOOS} = "windows" ]; then
        output_name+='.exe'
    fi

    goldflags="-s -w $(kube::version::ldflags)"

    echo ${goldflags}

    env GOOS=${GOOS} GOARCH=${GOARCH} go build -o ${output_path}/kubectl -ldflags="${goldflags}" ./cmd/kubectl
    if [ $? -ne 0 ]; then
        echo 'An error has occurred! Aborting the script execution...'
        exit 1
    fi
done
