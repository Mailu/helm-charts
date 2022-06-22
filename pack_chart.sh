#!/bin/sh

set -e

# 1st detect helm downloaded by ci

if [ -x "helm3" ]; then
  HELM3"$(pwd)/helm3"
  echo "Found helm v3 at ${HELM}"
fi

if [ -z "${HELM}" ]; then
  set +e
  HELM=$( which helm )
  if [ -z "${HELM}" ]; then
    echo "Command helm not found!"
    exit 1
  fi
  if ${HELM} version -c | grep -e 'Version:"v3.' > /dev/null; then
    HELM3="${HELM}"
    echo "Found helm v3 at ${HELM3}"
  else
    echo "Unsuported helm version: $(${HELM} version -c)"
    exit 1
  fi
  set -e
fi

echo "Running helm lint"
${HELM} lint --strict --values mailu/helm-lint-values.yaml mailu

echo "Cloning gh-pages"
rm -rf gh-pages
git clone --single-branch --branch gh-pages https://github.com/xMAC94x/mailu-helm-charts.git gh-pages
( cd gh-pages && git remote set-url origin git@github.com:xMAC94x/mailu-helm-charts.git)

echo "Packing helm chart"
${HELM} package mailu -d gh-pages
echo "Updating repo index"
${HELM} repo index --url https://xmac94x.github.io/mailu-helm-charts/ gh-pages
echo "Updating gh-pages html"
( cd gh-pages && ./index.html.sh > index.html )

echo "Rendering helm chart to yaml"
VERSION=$( grep mailu/Chart.yaml -e '^version:' | awk '{ print $2 }' )
mkdir -p gh-pages/yaml
rm -rf gh-pages/yaml/${VERSION}
${HELM} template mailu --values mailu/helm-lint-values.yaml --release-name mailu --namespace mailu --output-dir gh-pages/yaml/${VERSION}
