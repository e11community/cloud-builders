#!/usr/bin/env bash
PROJECT_ID=''
declare -i do_build=1

for arg in "$@"; do
  case "$arg" in
    build) do_build=0;;
    --project=*) PROJECT_ID="${arg#*=}";;
  esac
done

if [ $do_build -eq 0 ] && [ -z "$PROJECT_ID" ]; then
  echo "Cannot extract secrets for build command without --project=PROJECT_ID" >&2
  exit 1
fi

if [ $do_build -eq 0 ]; then
  engineering11_npm_auth_token="$(gcloud secrets versions access latest --secret=engineering11_npm_auth_token --project=$PROJECT_ID)"

  if [ $? -ne 0 ]; then
    echo "Could not retrieve secret for build command!" >&2
    exit 1
  fi

  ../common/build.sh --image=engineering11 --build-with-project=true \
    --custom-build-arg="ENGINEERING11_NPM_AUTH_TOKEN=${engineering11_npm_auth_token}"
    "$@"
else
  ../common/build.sh --image=engineering11 --build-with-project=true "$@"
fi
