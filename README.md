# platform-automation-example

Example Repository for using platform-automation

## Harbor

fly -t lab set-pipeline -p deploy-harbor -c lab/harbor-container-registry-pipeline.yml -v foundation=lab -v credhub_server=https://ci.lab.winterfell.live:8844
fly -t lab unpause-pipeline -p deploy-harbor
