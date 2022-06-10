#!/usr/bin/env bash

declare PROJECT_ID='' TAG=''
declare -i to_shift=0

for arg in "$@"; do
  case "$arg" in
    --project-id=*) to_shift=$(( $to_shift + 1 )); PROJECT_ID="${arg#*=}";;
    --tag=*) to_shift=$(( $to_shift + 1 )); TAG="${arg#*=}";;
  esac
done

shift $to_shift

if [ -z "$PROJECT_ID" ]; then
  echo "Must pass in --project-id=PROJECT_ID" >&2
  exit 1
fi

if [ -z "$TAG" ]; then
  echo "Must pass in --tag=TAG" >&2
  exit 1
fi

declare cmd="${1:-build}"
shift 1
declare -a valid_cmds=(build spread)
declare -i cmd_match=1

for to_match in "${valid_cmds[@]}"; do
  if [ "$cmd" = "$to_match" ]; then
    cmd_match=0
    break
  fi
done

if [ $cmd_match -ne 0 ]; then
  echo "Must be a valid cmd [$cmd] from [${valid_cmds[@]}]" >&2
  exit 1
fi

cmd_build() {
  docker build \
    --platform linux/x86_64
    --build-arg NPM_TOKEN=$(gcloud secrets versions access latest --secret=engineering11_npm_auth_token --project ${PROJECT_ID}) \
    --ulimit nofile=128000:128000 \
    --tag gcr.io/${PROJECT_ID}/firebase:${TAG} . && \
  docker push gcr.io/${PROJECT_ID}/firebase:${TAG}
}

cmd_spread() {
  for other_project_id in "$@"; do
    docker tag gcr.io/${PROJECT_ID}/firebase:${TAG} gcr.io/${other_project_id}/firebase:${TAG} && \
    docker push gcr.io/${other_project_id}/firebase:${TAG}
  done
}

eval "cmd_$cmd $@"

