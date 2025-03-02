#!/usr/bin/env bash

declare PROJECT_ID='' TAG='' domain='us.gcr.io'
declare -i to_shift=0

for arg in "$@"; do
  case "$arg" in
    --project=*) ((++to_shift)); PROJECT_ID="${arg#*=}";;
    --project-id=*) ((++to_shift)); PROJECT_ID="${arg#*=}";;
    --tag=*) ((++to_shift)); TAG="${arg#*=}";;
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
  NPM_TOKEN=$(gcloud secrets versions access latest --secret=engineering11_npm_auth_token --project ${PROJECT_ID})
  if [ $? -ne 0 ]; then
    echo 'Secret engineering11_npm_auth_token needed to continue!' >&2
    return 1
  fi
  docker build \
    --platform linux/x86_64 \
    --build-arg NPM_TOKEN="${NPM_TOKEN}" \
    --ulimit nofile=128000:128000 \
    --tag ${domain}/${PROJECT_ID}/firebase:${TAG} . && \
  docker push ${domain}/${PROJECT_ID}/firebase:${TAG}
}

cmd_spread() {
  for other_project_id in "$@"; do
    docker tag ${domain}/${PROJECT_ID}/firebase:${TAG} ${domain}/${other_project_id}/firebase:${TAG} && \
    docker push ${domain}/${other_project_id}/firebase:${TAG}
  done
}

eval "cmd_$cmd $@"
