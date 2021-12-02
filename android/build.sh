#!/usr/bin/env bash

GITINFO=$( git describe --long --abbrev=6 --dirty=+ )
( cat manifest.template; \
  sed -e "s#\\\$GITINFO#$GITINFO#" ../manifest.shared
) > manifest

echo '[mei] Building Android Plot Projects module via Titanium SDK'


TI_SDK_VERSION="9.3.0.GA"
NODE_VERSION=10

echo '[mei] selecting node version via `n`'
n $NODE_VERSION

rm dist/*

echo '[mei] building via Ti sdk'
ti build  -p android -c --build-only --sdk $TI_SDK_VERSION

echo ''
echo '[mei] build complete'
