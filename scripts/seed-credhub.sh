# Redacted set of commands to match what is expected to be stored in credential manager

# Update below to match your credhub api uri
credhub api https://ci.lab.winterfell.live:8844 --skip-tls-validation
credhub login -u admin -p "$CREDHUB_PASSWORD"

# Concourse main team credentials.  These are required for concourse interpolation.  If your concourse
# is leveraging vault for crednetials, you would skip this block and use the vault alternatives.  Remember
# to make cooresponding updates to the variable names in the pipelines
credhub set -t value -n '/concourse/main/s3_access_key_id' -v 'REDACTED_ACCESS_KEY_D'
credhub set -t value -n '/concourse/main/s3_secret_access_key' -v 'REDACTED_SECRET_ACCESS_KEY'
credhub set -t value -n '/concourse/main/pivnet_token' -v 'REDACED_PIVNET_TOKEN'
credhub set -t rsa -n '/concourse/main/configuration_git_repo' -p configuration_private_key.cert
credhub set -t rsa -n '/concourse/main/platform_automation_example_git_repo' -p configuration_private_key2.cert
credhub set -t rsa -n '/concourse/main/platform_automation_example_locks_git_repo' -p configuration_private_key3.cert
credhub set -t certificate -n '/concourse/main/credhub_ca_cert' -c <(bosh int ../homelab-concourse-setup/generated/concourse/concourse-gen-vars.yml --path /atc_tls/ca)
credhub set -t value -n '/concourse/main/credhub_secret' -v $(bosh int ../homelab-concourse-setup/generated/concourse/concourse-gen-vars.yml --path /uaa_users_admin)
credhub set -t value -n '/concourse/main/concourse_to_credhub_secret' -v $(bosh int ../homelab-concourse-setup/generated/concourse/concourse-gen-vars.yml --path /concourse_to_credhub_secret)

# Platform Automation credentials for the lab foundation

## Always required
credhub set -t value -n '/lab-foundation/vsphere_ssh_public_key' -v 'REDACTED_RSA_PUB_KEY'
credhub set -t value -n '/lab-foundation/vsphere_vcenter_password' -v 'REDACTED_VCENTER_PW'
credhub set -t value -n '/lab-foundation/pivnet_token' -v 'REDACTED'
credhub set -t value -n '/lab-foundation/opsman_username' -v 'REDACTED'
credhub set -t value -n '/lab-foundation/opsman_password' -v 'REDACTED'
credhub set -t value -n '/lab-foundation/s3_access_key_id' -v 'REDACTED'
credhub set -t value -n '/lab-foundation/s3_secret_access_key' -v 'REDACTED'

## Required for PKS tile if using wavefront
credhub set -t value -n '/lab-foundation/wavefront_token' -v 'REDACTED_TOKEN'

## Required for PKS and PAS tiles if using ldap authentication
credhub set -t value -n '/lab-foundation/uaa_ldap_password' -v 'REDACTED_PASSWORD'

## Required for PAS tile
credhub set -t value -n '/lab-foundation/properties_credhub_key_encryption_passwords_0_key_secret' -v 'REDACTED_ENCRYPTION_KEY'
