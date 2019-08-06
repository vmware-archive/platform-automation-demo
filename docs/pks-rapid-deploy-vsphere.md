# PKS Rapid Deploy w/ Vsphere

The following flow is to leverage PKS deployment from scratch on vsphere using Platform Automation.

## Prerequities

### Determine naming conventions

Determine a base domain name to tha describes the foundation.  For instance, I use lab.winterfell.live.

Identify the ops man IP to use and create an DNS A record.  Example: opsman.lab.winterfell.live.

Later we will create an DNS A record for the PKS API, api.pks.lab.winterfell.live.

Additionally, we will need to create A records for each cluster created. For example, cluster1.clusters.pks.lab.winterfell.live.

### Prep Git Repos

You will need to clone/fork custom git repos

- Config Repository: https://github.com/doddatpivotal/platform-automation-example
- Lock Repository: https://github.com/doddatpivotal/platform-automation-example-locks

Depending on your preference you will need a UN/PW with r/w access to these repos or a deploy key from git.

### Prep S3 Buckets

You will need to create an S3 bucket to put the installation.zip and exported configs.

Gather region and bucket name information for later.

### Concourse Setup

Assumes a control plane is already in place with concourse and credhub.

### Download cli's

- pks cli - download from pivnet following steps in Pivnet Activity section below
- uaac cli - https://github.com/cloudfoundry-incubator/uaa-cli/releases/tag/0.5.0
- om cli - https://github.com/pivotal-cf/om/releases
- credhub cli - https://github.com/cloudfoundry-incubator/credhub-cli/releases
- fly cli - https://github.com/concourse/concourse/releases

### Pivnet Activity

- Access with browser: https://network.pivotal.io
- Retrieve the legacy api token.  Get this by selecting your name in upper right hand corner and choosing "Edit Profile".  Retrieve the legacy token value at the bottom of the page.
- Accept the following EULAs.  Initial a downlod from pivnet page for the specified version, accept EULA and then cancel download
  - Platform Automation for PCF 3.0.5: https://network.pivotal.io/products/platform-automation/
  - Ops Manager 2.6:  https://network.pivotal.io/products/ops-manager/
  - Stemcell for PKS - Stemcells for PCF (Ubuntu Xenial) 250.25: https://network.pivotal.io/products/stemcells-ubuntu-xenial/
- Download pks cli from the PKS page on pivnet: https://network.pivotal.io/products/pivotal-container-service/ .  Change version to your desired version.

>If you do not accept a EULA, then you will see a failed job in concourse pipeline asking you to go to pivnet to accept the EULA.  Here are the examples of what we found:
Platform Automation for PCF: https://network.pivotal.io/products/237/releases/417731/eulas/120 
Operations Manager: https://network.pivotal.io/products/78/releases/412373/eulas/120
Stemcell for PKS:  https://network.pivotal.io/products/233/releases/331971/eulas/120

### Seed credential manager

Leverage `/scripts/seed-credhub.sh` commands to put credentials into credhub that will be used later by concourse an Platform Automation.

## Flow

### Deploy OM

- edit following files within /environments/vsphere/lab/config-common/secrets
  - env.yml
    - set `target` to your opsman hostname identfied above
- edit following files within /environments/vsphere/lab/config-director
  - vars/director.yml
  - vars/opsman.yml
- edit `pipelines/om-and-director-pipeline.yml`
  - update the state, director-configuration, and lock resource git parameters
- fly the `pipelines/om-and-director-pipeline.yml` and trigger
- optional: May need to add additional availability zones, by editing /environments/vsphere/lab/config-director/templates/opsman.yml and directory.yml

### Generate Certs

- edit following files within /pipelines/generate-certs-pipeline.yml
  - remove all tasks except the pks cert task
- fly the `pipelines/generate-certs-pipeline.yml` and trigger

### Deploy PKS

- export PIVNET_TOKEN=????
- execute `./scripts/generate-config.sh pivotal-container-service vsphere`
  - this will pull down tile meta-data and put in /environments/vsphere/tile-configs
- edit following files within /environments/vsphere/lab/config/pivotal-container-service
  - pivotal-container-service-vars.yml
- optional: May need to modify operations files for things like ldaps cert or wavefront given specific needs.  And then update ...vars.yml or ...secrets.yml and credhub acordingly
