#!/bin/bash -e
PIVNET_TOKEN=$1
version=$(bosh interpolate ../config/versions/p-rabbitmq.yml --path /product-version)
glob=$(bosh interpolate ../config/versions/p-rabbitmq.yml --path /pivnet-file-glob)
slug=$(bosh interpolate ../config/versions/p-rabbitmq.yml --path /pivnet-product-slug)

mkdir -p p-rabbitmq-tcg
tmpdir=p-rabbitmq-tcg
tile-config-generator generate --base-directory=${tmpdir} --do-not-include-product-version --include-errands pivnet --token ${PIVNET_TOKEN} --product-slug ${slug} --product-version ${version} --product-glob ${glob}
bosh int ${tmpdir}/product.yml \
  -o ${tmpdir}/features/syslog_selector-disabled.yml \
  > ../config/templates/p-rabbitmq.yml

rm -rf ../config/defaults/p-rabbitmq.yml
touch ../config/defaults/p-rabbitmq.yml
cat ${tmpdir}/product-default-vars.yml >> ../config/defaults/p-rabbitmq.yml
cat ${tmpdir}/errand-vars.yml >> ../config/defaults/p-rabbitmq.yml
cat ${tmpdir}/resource-vars.yml >> ../config/defaults/p-rabbitmq.yml
