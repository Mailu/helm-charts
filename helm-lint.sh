#!/bin/sh

set -e 

helm lint --strict --values mailu/helm-lint-values.yaml mailu
