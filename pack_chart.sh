#!/bin/sh

set -e

# 1st detect the helm variants downloaded by travis-ci

if [ -x "helm2" ]; then
  HELM2="$(pwd)/helm2"
  HELM=${HELM2}
  echo "Found helm v2 at ${HELM2}"
fi

if [ -x "helm3" ]; then
  HELM3="$(pwd)/helm3"
  HELM=${HELM3}
  echo "Found helm v3 at ${HELM3}"
fi

if [ -z "${HELM}" ]; then
  set +e
  HELM=$( which helm )
  if [ -z "${HELM}" ]; then
    echo "Command helm not found!"
    exit 1
  fi
  if ${HELM} version -c | grep -e 'Version:"v2.' > /dev/null; then
    HELM2="${HELM}"
    echo "Found helm v2 at ${HELM2}"
  elif ${HELM} version -c | grep -e 'Version:"v3.' > /dev/null; then
    HELM3="${HELM}"
    echo "Found helm v3 at ${HELM3}"
  else
    echo "Unsuported helm version: $(${HELM} version -c)"
    exit 1
  fi
  set -e
fi

if [ -z "${HELM2}" ]; then
  set +e
  HELM2=$( which helm2 )
  if [ ! -z "${HELM2}" ]; then
    echo "Found helm v2 at ${HELM2}"
  fi
  set -e
fi

if [ -z "${HELM3}" ]; then
  set +e
  HELM2=$( which helm3 )
  if [ ! -z "${HELM3}" ]; then
    echo "Found helm v3 at ${HELM3}"
  fi
  set -e
fi

if [ ! -z "${HELM2}" ]; then
  echo "Running lint with helm v2"
  ${HELM2} lint --strict --values mailu/helm-lint-values.yaml mailu
fi

if [ ! -z "${HELM3}" ]; then
  echo "Running lint with helm v3"
  ${HELM3} lint --strict --values mailu/helm-lint-values.yaml mailu
fi

echo "Cloning gh-pages"
rm -rf gh-pages
git clone --single-branch --branch gh-pages https://github.com/Mailu/helm-charts.git gh-pages
( cd gh-pages && git remote set-url origin git@github.com:Mailu/helm-charts.git)

echo "Packing helm chart"
${HELM} package mailu -d gh-pages
echo "Updating repo index"
${HELM} repo index --url https://mailu.github.io/helm-charts/ gh-pages
echo "Updating gh-pages html"
( cd gh-pages && ./index.html.sh > index.html )

echo "Rendering helm chart to yaml"
VERSION=$( grep mailu/Chart.yaml -e '^version:' | awk '{ print $2 }' )
mkdir -p gh-pages/yaml
rm -rf gh-pages/yaml/${VERSION}
${HELM} template mailu --values mailu/helm-lint-values.yaml --release-name mailu --namespace mailu --output-dir gh-pages/yaml/${VERSION}
