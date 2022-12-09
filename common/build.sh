#!/usr/bin/env bash
# chore: custom build args

declare BUILD_WITH_PROJECT='' IMAGE_NAME='' MAIN_VERSION_TAG='' PROJECT_ID='' RAW_SUBSTITUTIONS=''
declare -i to_shift=0 main_version_sub=0 do_output=0
declare -a ancestors=()
declare -a custom_build_args=()

for arg in "$@"; do
  case "$arg" in
    --ancestor=*) ((++to_shift)); ancestors+=("${arg#*=}");;
    --build-with-project=*) ((++to_shift)); BUILD_WITH_PROJECT+=("${arg#*=}");;
    --custom-build-arg=*) ((++to_shift)); custom_build_args+=(--build-arg "${arg#*=}");;
    --image=*) ((++to_shift)); IMAGE_NAME="${arg#*=}";;
    --main-version=*) ((++to_shift)); MAIN_VERSION_TAG="${arg#*=}";;
    --no-main-version-sub) ((++to_shift)); main_version_sub=1;;
    --no-output) ((++to_shift)); do_output=1;;
    --project=*) ((++to_shift)); PROJECT_ID="${arg#*=}";;
    --raw-substitutions=*) ((++to_shift)); RAW_SUBSTITUTIONS="${arg#*=}";;
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
    "${custom_build_args[@]}" \
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
  declare -a substitutions=()
  if [ $main_version_sub -eq 0 ]; then
    CAPS_IMAGE_NAME="$(echo -n "${IMAGE_NAME}" | tr 'a-z' 'A-Z')"
    substitutions+=("_${CAPS_IMAGE_NAME}_TAG=${MAIN_VERSION_TAG}")
  fi
  for ancestor in "${ancestors[@]}"; do
    ancestor_name="${ancestor%%-*}"
    ancestor_version="${ancestor#*-}"
    ancestor_name="$(echo -n $ancestor_name | tr 'a-z' 'A-Z')"
    substitutions+=("_${ancestor_name}_TAG"="${ancestor_version}")
  done
  subsCDL="$(echo -n "${substitutions[@]}" | tr ' ' ',')"
  if [ -n "${RAW_SUBSTITUTIONS}" ]; then
    if [ -n "${subsCDL}" ]; then
      subsCDL="${subsCDL},${RAW_SUBSTITUTIONS}"
    else
      subsCDL="${RAW_SUBSTITUTIONS}"
    fi
  fi
  declare -a more_args=()
  if [ $do_output -ne 0 ]; then
    more_args+=(--async --suppress-logs)
  fi
  gcloud builds submit . --substitutions "${subsCDL}" --project=$PROJECT_ID "${more_args[@]}"
}

eval "cmd_$cmd $@"

