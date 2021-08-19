#!/usr/bin/env bash

print_versions() {
  col1_width=20
  printf "%-${col1_width}s %s\n" 'NAME' 'VERSION'
  for i in $(seq 1 72); do
    echo -n '-'
  done
  echo ''
  for arg in "$@"; do
    printf "%-${col1_width}s %s\n" "${arg}" "$($arg --version)"
  done
}
