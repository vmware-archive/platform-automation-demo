# PA Hack-a-thon

## Attendees

- 23 yes from East Area PA team

## What we will do

- Quick review customer facing deck: https://docs.google.com/presentation/d/1_psDHqzm8WUUTxM2VFTDCaa0HTdum5vGJDgcymHVLHo/edit#slide=id.g5c982695bd_0_0
- View Dodd's platform automation scripts and configuration (heavy on the demo)
- Setup platform automation for your lab (home or public cloud)
- Choose from PAS, MySql, RabbitMQ, PKS, and/or Harbor tiles
- Ask questions and learn from each other
- Have fun!

## Collaboration Suggestions

- Leverage the slack channel #pa-hackathon-7-2
- If want to pair up with someone, start another zoom
- Ask for help on Dodd's zoom link, or in the slack channel.  Dodd or someone else can pair with you to keep going

## Demo

- Review docs website
  - Concepts
  - References
  - Compatibility & Versioning
- Explore this reference repository
  - View readme
- Explore pipelines in concourse UI
  - deploy-om-and-director
    - general overview
    - concepts of locks
    - the jobs are essentially no-ops if steps are not required.  Explained in readme
  - standard-tile-pipeline
    - general overview
    - ad-hoc taks e.g. extract-staged-config
- Directory structure in vscode
- Review process of setting up a new tile
  - delete the generated files
- Review process of bumping patch
  - pks 1.4.1
- Review process of bumping minor
  - pks 2.6.0

## How to best make use of this hack-a-thon

- prerequites
  - concourse + uaa + credhub deployed
  - paved iaas
  - object store (eg. s3)
- if you already have OM with at least one product deployed...
  - suggest creating automation to exactly replace the existing deployed product (same version, same config)
  - suggest starting with a product that deploys quickly (like harbor, rabbitmq, pks)
  - this will get you used to the concepts
  - from here you can upgrade the product, or start working on the opsman pipeline
  - once opsman pipeline is working, you could manually destroy your environment and then re-run pipelines to ensure intial install is working
- if you don't have OM deployed
  - give it a go by starting with the opsman pipeline.  If you face challenges, then consider manually deploying opsman first as a canary
  - now it's time to add a product, suggest starting with something small like harbor (start with patch version n-1)
  - add additional products, try deploying minor version n-1 and then upgrade
  - from here you can upgrade the product, or start working on the opsman pipeline
  - once opsman pipeline is working, you could manually destroy your environment and then re-run pipelines to ensure intial install is working
