# platform-automation-example

Example Repository for using platform-automation

## Login

fly -t lab login -k

## Ops Manager and Director

fly -t lab set-pipeline -p lab-deploy-om-and-director -c environments/vsphere/om-and-director-pipeline.yml -l environments/vsphere/common.yml

fly -t lab unpause-pipeline -p deploy-om-and-director

## PAS

fly -t lab set-pipeline -p deploy-cf -c lab/cf-pipeline.yml -l lab/common.yml -n

fly -t lab unpause-pipeline -p deploy-cf

## Harbor

fly -t lab set-pipeline -p deploy-harbor -c environments/vsphere/harbor-container-registry-pipeline.yml -l environments/vsphere/common.yml -n

fly -t lab unpause-pipeline -p deploy-harbor

## PKS

fly -t lab set-pipeline -p deploy-pks -c lab/pivotal-container-service-pipeline.yml -l lab/common.yml -n

fly -t lab unpause-pipeline -p deploy-pks

## Rabbit MQ

fly -t lab set-pipeline -p deploy-rabbit -c lab/p-rabbitmq-pipeline.yml -l lab/common.yml -n

fly -t lab unpause-pipeline -p deploy-rabbit

## Setting up for a new tile

When creating configuration for a product for the first time

- Start with the example platformation automation config
- Copy version file and update
- Copy config script and update based upon product name
- Run tile config generator
- Review options and update interpolate
- Run the tile config generator again
- Run `om interpolate` passing in --config template --vars-files defaults to identify what values - need to be set
- Create a vars file for the remaining values (or add them to credhub)

## Updating a version of a tile

1. Update the product version
2. Run the scripts and identify any changes to the configurations
3. Run om interpolate passing in the tile config, defaults, and vars to see if there are any new vars you have to supply
