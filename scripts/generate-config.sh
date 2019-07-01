#!/bin/bash -e
: ${PIVNET_TOKEN?"Need to set PIVNET_TOKEN"}

INITIAL_FOUNDATION=lab
if [ ! $# -eq 2 ]; then
  echo "Must supply product name as arg and iaas"
  exit 1
fi

product=$1
iaas=$2
echo "Generating configuration for product $product"
versionfile="environments/${iaas}/${INITIAL_FOUNDATION}/config/$product/$product-version.yml"
if [ ! -f ${versionfile} ]; then
  echo "Must create ${versionfile}"
  exit 1
fi
version=$(bosh interpolate ${versionfile} --path /product-version)
glob=$(bosh interpolate ${versionfile} --path /pivnet-file-glob)
slug=$(bosh interpolate ${versionfile} --path /pivnet-product-slug)

tmpdir=environments/${iaas}/tile-configs/${product}-config
mkdir -p ${tmpdir}
om config-template --output-directory=${tmpdir} --pivnet-api-token ${PIVNET_TOKEN} --pivnet-product-slug  ${slug} --product-version ${version} --product-file-glob ${glob}
wrkdir=$(find ${tmpdir}/${product} -name "${version}*")
if [ ! -f ${wrkdir}/product.yml ]; then
  echo "Something wrong with configuration as expecting ${wrkdir}/product.yml to exist"
  exit 1
fi

ops_files="environments/${iaas}/config/${product}/${product}-operations"
touch ${ops_files}

ops_files_args=("")
while IFS= read -r var
do
  ops_files_args+=("-o ${wrkdir}/${var}")
done < "$ops_files"
bosh int ${wrkdir}/product.yml ${ops_files_args[@]} > environments/${iaas}/${INITIAL_FOUNDATION}/config/${product}/${product}-template.yml

rm -rf environments/${iaas}/${INITIAL_FOUNDATION}/config/${product}/${product}-defaults.yml
touch environments/${iaas}/${INITIAL_FOUNDATION}/config/${product}/${product}-defaults.yml
if [ -f ${wrkdir}/product-default-vars.yml ]; then
  cat ${wrkdir}/product-default-vars.yml >> environments/${iaas}/${INITIAL_FOUNDATION}/config/${product}/${product}-defaults.yml
fi
if [ -f ${wrkdir}/errand-vars.yml ]; then
  cat ${wrkdir}/errand-vars.yml >> environments/${iaas}/${INITIAL_FOUNDATION}/config/${product}/${product}-defaults.yml
fi
if [ -f ${wrkdir}/resource-vars.yml ]; then
  cat ${wrkdir}/resource-vars.yml >> environments/${iaas}/${INITIAL_FOUNDATION}/config/${product}/${product}-defaults.yml
fi

touch environments/${iaas}/${INITIAL_FOUNDATION}/config/${product}/${product}-secrets.yml
touch environments/${iaas}/${INITIAL_FOUNDATION}/config/${product}/${product}-vars.yml
