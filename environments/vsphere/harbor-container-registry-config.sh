#!/bin/bash -e
PIVNET_TOKEN=$1
version=$(bosh interpolate ../config/versions/harbor-container-registry.yml --path /product-version)
glob=$(bosh interpolate ../config/versions/harbor-container-registry.yml --path /pivnet-file-glob)
slug=$(bosh interpolate ../config/versions/harbor-container-registry.yml --path /pivnet-product-slug)

mkdir -p harbor-container-registry-tcg
tmpdir=harbor-container-registry-tcg
tile-config-generator generate --base-directory=${tmpdir} --do-not-include-product-version --include-errands pivnet --token ${PIVNET_TOKEN} --product-slug ${slug} --product-version ${version} --product-glob ${glob}
bosh int ${tmpdir}/product.yml > ../config/templates/harbor-container-registry.yml

rm -rf ../config/defaults/harbor-container-registry.yml
touch ../config/defaults/harbor-container-registry.yml
cat ${tmpdir}/product-default-vars.yml >> ../config/defaults/harbor-container-registry.yml
cat ${tmpdir}/errand-vars.yml >> ../config/defaults/harbor-container-registry.yml
cat ${tmpdir}/resource-vars.yml >> ../config/defaults/harbor-container-registry.yml
