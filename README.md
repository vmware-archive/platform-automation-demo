# Platform Automation Example

Example repository for using [Platform Automation for PCF](http://docs.pivotal.io/platform-automation/v3.0/).  I am using this repo for my personal lab environment.  

There are two approaches to managing product tile configuration: reverse engineering and forward engineering.  The concepts used in this repo are heavily influenced by Caleb Washburn's [platform-automation-reference](https://github.com/calebwashburn/platform-automation-reference).  This approach uses the *forward engineering* process for manage product tile configuration.

I chose this approache because:

- There is an tool defined opinionated structure for the product configuration.  It's based upon the tile metadata.
- I can clearly see what default configuration values and isolate my explicit configuration
- Allows for identification of any tile changes associated with a new version (patch or minor) of the tile prior to attempting to run the pipeline
- Gives me good insight into the configuration dependencies with tile options and features

Of note, there are differences in Caleb's repo:

- Caleb has setup his structure for *promoting* configuration amoung foundations.  Think sandbox, non-prod, production.  I've kept the directory structure, but removed the scripts as I only have one foundation
- Due to the multiple foundations, he has a concept of common configuration across foundations, I removed this
- I have decided to put all configuration for a product in a single directory.  This allows me to watch changes only for that location in my configuration git resource and made it easier for me as I built out new products.  I could just copy and paste a single directory
- I've moved the scripts outside of the environments directory.  This just made more sense to me and allowed me to easily run the scripts from the root
- I have seperate pipelines for each product
- I've added helper pipeline to generate self signed certs
- Caleb has an approach that seperates out the execution of errands from the apply changes for a tile.  This was explained to me as way to have the pipeline be more resiliant to errand failures and allows for re-execution of errands without having to re-install the product.  I may consider this in the future, but have not followed the approach right now due to simplicity.

## Repo Directory Structure

```ascii
├── environments
│   ├── vsphere
│   │   ├── foundation-1
│   │   │   ├── config-common
│   │   │   │   ├── secrets
│   │   │   │   │   └── env.yml
│   │   │   │   │   └── pivnet.yml
│   │   │   ├── config
│   │   │   │   ├── cf
│   │   │   │   │     cf-template.yml
│   │   │   │   │     cf-vars.yml
│   │   │   │   │     cf-defaults.yml
│   │   │   │   │     cf-secrets.yml
│   │   │   │   │     cf-version.yml
│   │   │   │   │     cf-stemcell-version.yml
│   │   │   │   │     cf-operation
│   │   │   │   └── ...
│   │   │   ├── config-director
│   │   │   │   ├── secrets
│   │   │   │   │   └── director.yml
│   │   │   │   │   └── opsman.yml
│   │   │   │   │   └── auth.yml
│   │   │   │   ├── templates
│   │   │   │   │   └── director.yml
│   │   │   │   │   └── opsman.yml
│   │   │   │   ├── vars
│   │   │   │   │   └── director.yml
│   │   │   │   │   └── opsman.yml
│   │   │   │   ├── versions
│   │   │   │   │   └── opsman.yml
│   │   │   ├── state
│   │   │   │   └── state.yml
├── pipelines
│   └── ...
├── proposed-tasks
│   └── ...
├── scripts
│   └── ...
```

## Pipelines Explained

### General Concepts

- Each pipeline leverages locks to ensure that only one pipeline is working on the foundation at any given point.  If a pipeline is triggered while another pipeline has the lock, then it will poll every 1 minute waiting for the lock to be released.  Check out info on the concourse [pool-resource](https://github.com/concourse/pool-resource).  The corresponding lock repository used in my lab is [platform-automation-example-locks](https://github.com/doddatpivotal/platform-automation-example-locks)

### Ops Manager and Director Pipeline

The ops manager and director pipeline is a single pipeline used for both installation and upgrade of ops manager and director pair.

1. `lock-director` - Claim the lock for the specific foundation.  Waits untile the lock is unclaimed before it progresses.
2. `validate-director-configuration` - Validation the configuration.  Essentially just executing an canary credhub interpolation task which establishes re-usable parameters and ensures secrets are in correct location
3. `install-opsman` - Checks to see if opsman is aready installed.  If so, skips download and creation.  If not does download and installs.  Ensures that the current version is configured as expected and applies changes.  This is so that you don't introduce configuration changes and new version at one time.  If install did occur, then it puts state.yml file in the config directory
4. `export-installation` - Exports the opsmanager and tile configuration and pushes it to s3 bucket
5. `upgrade-opsman` - If existing opsman version is different than current, it will download and upgrade opsman.  Else it will skip.  Will always apply director changes, which will go fast if there were no changes
6. `unlock-director` - Releases the lock on the foundation.

The following notable configuration files exist:

- `state.yml` - Stores an id associated with the opsmanager.  Required for opsman upgrades.  This file must exist and can be blank for an intial install.  The pipeline will update the file after the pipeline is run.  Located in `enviornment/<iaas>/<foundation>/state` folder
- `enviornment/<iaas>/<foundation>/config-director` folder - Contains configuration files used by the pipeline.  Secret mappings are stored in the `secrets` folder and this directory has the credhub interpolate task run against it.
- `...\versions\opsman.yml` contains opsman version information and is where you will bump versions

### Product Tile Pipelines

There is a single standard product pipeline configuration that is used for all product tiles.  This enables re-use and consistancy.  Each tile uses the same configuration with a different pipeline name and product variable.  This pipline is used for both installation and upgrade of the tile.

Two groups are defined in the pipeline.  `deployment-pipeline` is the primary pipeline, while `ad-hoc-jobs` contains one-off jobs that can be executed.

Following jobs within the `deployment-pipeline` group

1. `lock-tiles` - Claim the lock for the specific foundation.  Waits untile the lock is unclaimed before it progresses.
2. `validate-tile-configuration` - Validation the configuration.  Essentially just executing an canary credhub interpolation task which establishes re-usable parameters and ensures secrets are in correct location
3. `download-stage-tile-stemcell` - This job has an custom aggregate task that combines a number of platform automation commands.  It checks to see if the desired stemcell and tile version have already been uploaded and staged.  If not, it downloads, stages, and assigns the stemcell
4. `configure-and-apply` - Configures the tile and selectively applies only changes to that product.  Again, uses a custom task.
5. `unlock-tile` - Releases the lock on the foundation.

The following notable configuration files exist:

- `enviornment/<iaas>/<foundation>/config` folder - Contains configuration files used by the pipeline.  Secret mappings are stored in the `secrets` folder and this directory has the credhub interpolate task run against it.
- `versions` - this folder contains `<product>.yml` and `<product>-stemcell.yml` files with configuration information for the product and its desired stemcell version
- `templates` - this folder contains the resulting interpolated template based on operations files that have been applied to the output of om config-template. This is created by scripts/generate-config.sh
- `defaults` - this folder contains the default values for a given tile. This is generated by om config-template
- `vars` - this folder contains environment specific variables per product that is being deployed.
- `secrets` - this folder contains the templates that can be interpolated using credhub interpolate to be used as secrets inputs to other tasks
- `versions` - this folder contains both the product version and stemcell version per product.

Following jobs within the `ad-hoc-jobs` group

1. `force-unlock` - Releases lock on the foundation.  Used when there is a failure at somepoint in the pipeline
2. `export-staged-config` - Exports the current staged config for the tile and puts it into the configured s3 bucket. This could be useful when you are first getting used to tile configuraiton and are unsure about optional and feature operations files

### Generate Certs Pipeline

This pipeline contians tasks to generate the requried certs for the tiles and place them in credhub.

## Automation Activities

### Setting up for a new tile

When creating configuration for a product for the first time

1. Configuration Setup
    1. Create `environments/<iaas>/<foundation>/config/<product> folder
    2. Go to pivnet and identify product version and stemcell version you want to use
    3. Copy <product>-version.yml and <product>-stemcell-version.yml from another products config directory and put it in new folder
    4. Update the version files appropriately
    5. Run `./scripts/generate-config.sh <product> <iaas>`.  This will generate tile-config folder for the product as well as operation, template, defaults, vars, and secreate files in the product folder
2. Customization
    1. Review features and options in the tile-config folder for the product
    2. Add desired features and options to the products operations file `<product>-operations`
    3. Re-run `./scripts/generate-config.sh <product> <iaas>`.  This will now update template and defaults files for the product
    4. Run `./scripts/validate-config.sh <product> <iaas> <foundation>`.  This will identify variables that need to be satisfied.
        1. Sensitive variables should be added to secrets file while referencing credhub credential name.
        2. Standard variables should be put into var file
    5. Review the default values.  Any values you want to override, add to the products vars file
    6. Re-run `./scripts/validate-config.sh <product> <iaas> <foundation>` to ensure all variables are satisfied
3. Credentials
    1. Add all required credentials into credhub
4. Deploy
    1. Commit the configuration changes and push to code repo
    2. Fly the pipeline
        1. fly standard-product-pipeline.yml passing in the product name.
        2. Update `./scripts/fly-pipelines.sh` script appropriately

>Note: There is a helper pipeline, `generate-certs-pipeline.yml`, to generate self-signed certs.

## Updating a version of a tile

1. Bump the versions
    1. Update the <product>-version.yml
    2. Update the <product>-stemcell-version.yml
2. Inspect Deferences
    1. Run `./scripts/validate-config.sh <product> <iaas> <foundation>`.  This may result in updated template, config, or default files.
    2. Identify if any changes were made via `git diff`
        1. Yes: manually review and make any necessary changes
        2. No: continue
    3. Run  `./scripts/validate-config.sh <product> <iaas> <foundation>` to ensure all variables are satisfied
3. Deploy
    1. Commit the configuration changes and push to code repo

## Proposed Tasks

- `apply-product-changes` - task to allow specifying selective deploy for a single product
- `download-create-opsman` this task is an aggregate that will try to short-circuit and not download opsmanager if state file has content otherwise with download opsmanager via om download-product and create it via p-automator create-vm
- `download-upgrade-opsman` this task is an aggregate that will short-circuit and not download opsmanager if the version installed is the version expected. This optimization only works in 2.5.x due to how opsmanager versioning worked prior to 2.5.x. If version mismatches it will download product via om download-product and update vm via p-automator upgrade-opsman
- `download-stage-tile-stemcell` this task is an aggregrate that will only download the tile if that version is not already staged. It will also only download the expected stemcell if that version hasn't already been uploaded. Otherwise it will download both tile and stemcell using om download-product, upload tile and stemcell, stage tile and assign the specified stemcell version to the tile (always regardless of download)
- `make-commit` - this task avoids committing state.yml using porcelain option, PR has been accepted so this task will be replace with platform-automation task once it's shipped
- `generate-cert` - this task will generage certs for the provided domain using opsman api and then put the cert in credhut at the specified location

## Fly Pipelines

Use the `./scripts/fly-pipelines.sh` script to set and unpause all pipelines.  Optionally, you can view that script to extract the commands to fly or unpause a specific pipeline.  The scirpt assumes you have already logged into concourse.  If not, use `fly -t lab login -k` to login.
