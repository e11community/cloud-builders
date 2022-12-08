#!/usr/bin/env bash

declare BUILD_WITH_PROJECT='' IMAGE_NAME='' MAIN_VERSION_TAG='' PROJECT_ID='' 
declare -i to_shift=0
declare -a ancestors=()

for arg in "$@"; do
  case "$arg" in
    --ancestor=*) ((++to_shift)); ancestors+=("${arg#*=}");;
    --build-with-project=*) ((++to_shift)); BUILD_WITH_PROJECT+=("${arg#*=}");;
    --image=*) ((++to_shift)); IMAGE_NAME="${arg#*=}";;
    --main-version=*) ((++to_shift)); MAIN_VERSION_TAG="${arg#*=}";;
    --project=*) ((++to_shift)); PROJECT_ID="${arg#*=}";;
  esac
done

shift $to_shift

if [ -z "$IMAGE_NAME" ]; then
  echo "Must pass in --image=IMAGE_NAME" >&2
  exit 1
fi

if [ -z "$PROJECT_ID" ]; then
  echo "Must pass in --project=PROJECT_ID" >&2
  exit 1
fi

if [ -z "$MAIN_VERSION_TAG" ]; then
  echo "Must pass in --main-version=MAIN_VERSION_TAG" >&2
  exit 1
fi

declare cmd="${1:-build}"
shift 1
declare -a valid_cmds=(build spread submit)
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
  declare -a build_args=()
  declare -a more_tags=()
  for ancestor in "${ancestors[@]}"; do
    ancestor_name="${ancestor%%-*}"
    ancestor_version="${ancestor#*-}"
    ancestor_name="$(echo -n $ancestor_name | tr 'a-z' 'A-Z')"
    build_args+=(--build-arg "${ancestor_name}_TAG"="${ancestor_version}")
    more_tags+=(--tag "gcr.io/${PROJECT_ID}/${IMAGE_NAME}:${ancestor}")
  done
  if [ -n "${BUILD_WITH_PROJECT}" ]; then
    build_args+=(--build-arg PROJECT_ID=${PROJECT_ID})
  fi
  docker build \
    --platform linux/x86_64 \
    --ulimit nofile=128000:128000 \
    "${build_args[@]}" \
    --tag gcr.io/${PROJECT_ID}/${IMAGE_NAME}:${MAIN_VERSION_TAG} \
    ${more_tags[@]} \
    . && \
  docker push gcr.io/${PROJECT_ID}/${IMAGE_NAME}:${MAIN_VERSION_TAG}
  for ancestor in "${ancestors[@]}"; do
    docker push gcr.io/${PROJECT_ID}/${IMAGE_NAME}:${ancestor}
  done
}

cmd_spread() {
  for other_project_id in "$@"; do
    docker tag gcr.io/${PROJECT_ID}/${IMAGE_NAME}:${MAIN_VERSION_TAG} gcr.io/${other_project_id}/${IMAGE_NAME}:${MAIN_VERSION_TAG} && \
    docker push gcr.io/${other_project_id}/${IMAGE_NAME}:${MAIN_VERSION_TAG}
    for ancestor in "${ancestors[@]}"; do
      docker tag gcr.io/${PROJECT_ID}/${IMAGE_NAME}:${ancestor} gcr.io/${other_project_id}/${IMAGE_NAME}:${ancestor} && \
      docker push gcr.io/${other_project_id}/${IMAGE_NAME}:${ancestor}
    done
  done
}

cmd_submit() {
  CAPS_IMAGE_NAME="$(echo -n "${IMAGE_NAME}" | tr 'a-z' 'A-Z')"
  declare -a substitutions=("_${CAPS_IMAGE_NAME}_TAG=${MAIN_VERSION_TAG}")
  for ancestor in "${ancestors[@]}"; do
    ancestor_name="${ancestor%%-*}"
    ancestor_version="${ancestor#*-}"
    ancestor_name="$(echo -n $ancestor_name | tr 'a-z' 'A-Z')"
    substitutions+=("_${ancestor_name}_TAG"="${ancestor_version}")
  done
  subsCDL="$(echo -n "${substitutions[@]}" | tr ' ' ',')"
  gcloud builds submit . --substitutions "${subsCDL}" --project=$PROJECT_ID
}

eval "cmd_$cmd $@"

