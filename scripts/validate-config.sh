#!/bin/bash -e
if [ ! $# -eq 3 ]; then
  echo "Must supply product name as arg and iaas and environment"
  exit 1
fi

product=$1
iaas=$2
environment_name=$3
echo "Validating configuration for product $product"

deploy_type=$(bosh int environments/${iaas}/${environment_name}/config/${product}/${product}-version.yml --path /pivnet-file-glob)

vars_files_args=("")
if [[ "${deploy_type}" == "*.tgz" ]]; then
  vars_files_args+=("--vars-file environments/${iaas}/${environment_name}/config/${product}/${product}-version.yml")
fi
if [ -f "environments/${iaas}/${environment_name}/config/${product}/${product}-defaults.yml" ]; then
  vars_files_args+=("--vars-file environments/${iaas}/${environment_name}/config/${product}/${product}-defaults.yml")
fi
if [ -f "environments/${iaas}/${environment_name}/config/${product}/${product}-vars.yml" ]; then
  vars_files_args+=("--vars-file environments/${iaas}/${environment_name}/config/${product}/${product}-vars.yml")
fi
if [ -f "environments/${iaas}/${environment_name}/config/${product}/${product}-secrets.yml" ]; then
  vars_files_args+=("--vars-file environments/${iaas}/${environment_name}/config/${product}/${product}-secrets.yml")
fi

bosh int --var-errs environments/${iaas}/${environment_name}/config/${product}/${product}-template.yml ${vars_files_args[@]}

