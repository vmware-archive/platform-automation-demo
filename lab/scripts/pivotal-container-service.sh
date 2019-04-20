#!/bin/bash -e
PIVNET_TOKEN=$1
version=$(bosh interpolate ../config/versions/pivotal-container-service.yml --path /product-version)
glob=$(bosh interpolate ../config/versions/pivotal-container-service.yml --path /pivnet-file-glob)
slug=$(bosh interpolate ../config/versions/pivotal-container-service.yml --path /pivnet-product-slug)

mkdir -p pivotal-container-service-tcg
tmpdir=pivotal-container-service-tcg
tile-config-generator generate --base-directory=${tmpdir} --do-not-include-product-version --include-errands pivnet --token ${PIVNET_TOKEN} --product-slug ${slug} --product-version ${version} --product-glob ${glob}
bosh int ${tmpdir}/product.yml \
  -o ${tmpdir}/features/cloud_provider-vsphere.yml \
  -o ${tmpdir}/features/uaa-ldap.yml \
  -o ${tmpdir}/optional/add-uaa-ldap-first_name_attribute.yml \
  -o ${tmpdir}/optional/add-uaa-ldap-last_name_attribute.yml \
  -o ${tmpdir}/optional/add-uaa-ldap-group_search_base.yml \
  -o ${tmpdir}/optional/add-uaa-ldap-external_groups_whitelist.yml \
  -o ${tmpdir}/features/telemetry_selector-enabled.yml \
  -o ${tmpdir}/optional/add-plan1_selector-active-master_vm_type.yml \
  -o ${tmpdir}/optional/add-plan1_selector-active-master_persistent_disk_type.yml \
  -o ${tmpdir}/optional/add-plan1_selector-active-worker_vm_type.yml \
  -o ${tmpdir}/optional/add-plan1_selector-active-worker_persistent_disk_type.yml \
  -o ${tmpdir}/optional/add-plan1_selector-active-errand_vm_type.yml \
  -o ${tmpdir}/features/plan2_selector-active.yml \
  -o ${tmpdir}/optional/add-plan1_selector-active-master_vm_type.yml \
  -o ${tmpdir}/optional/add-plan1_selector-active-master_persistent_disk_type.yml \
  -o ${tmpdir}/optional/add-plan1_selector-active-worker_vm_type.yml \
  -o ${tmpdir}/optional/add-plan1_selector-active-worker_persistent_disk_type.yml \
  -o ${tmpdir}/optional/add-plan1_selector-active-errand_vm_type.yml \
  -o ${tmpdir}/features/wavefront-enabled.yml \
  -o ${tmpdir}/optional/add-wavefront-enabled-wavefront_alert_targets.yml \
   > ../config/templates/pivotal-container-service.yml

rm -rf ../config/defaults/pivotal-container-service.yml
touch ../config/defaults/pivotal-container-service.yml
cat ${tmpdir}/product-default-vars.yml >> ../config/defaults/pivotal-container-service.yml
cat ${tmpdir}/errand-vars.yml >> ../config/defaults/pivotal-container-service.yml
cat ${tmpdir}/resource-vars.yml >> ../config/defaults/pivotal-container-service.yml
