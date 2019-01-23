#!/bin/bash -ex
PIVNET_TOKEN=$1
version=$(bosh interpolate ../config/versions/cf.yml --path /product-version)
glob=$(bosh interpolate ../config/versions/cf.yml --path /pivnet-file-glob)
slug=$(bosh interpolate ../config/versions/cf.yml --path /pivnet-product-slug)

tmpdir=$(mktemp -d)
tile-config-generator generate --base-directory=${tmpdir} --do-not-include-product-version --include-errands pivnet --token ${PIVNET_TOKEN} --product-slug ${slug} --product-version ${version} --product-glob ${glob}
cat ${tmpdir}/product.yml
bosh int ${tmpdir}/product.yml \
  -o ${tmpdir}/features/haproxy_forward_tls-disable.yml \
  -o ${tmpdir}/resource/router_additional_vm_extensions.yml > ../config/templates/cf.yml
