# platform-automation-example

Example Repository for using platform-automation

## Login

fly -t lab login -k

## Ops Manager and Director

fly -t lab set-pipeline -p deploy-om-and-director -c lab/om-and-director-pipeline.yml -l lab/common.yml

fly -t lab unpause-pipeline -p deploy-om-and-director

## PAS

fly -t lab set-pipeline -p deploy-cf -c lab/cf-pipeline.yml -l lab/common.yml

fly -t lab unpause-pipeline -p deploy-cfr

## Harbor

fly -t lab set-pipeline -p deploy-harbor -c lab/harbor-container-registry-pipeline.yml -l lab/common.yml

fly -t lab unpause-pipeline -p deploy-harbor
