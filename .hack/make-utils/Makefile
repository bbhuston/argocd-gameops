# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

.ONESHELL:
.SILENT:
.EXPORT_ALL_VARIABLES:
SHELL := /bin/bash

## GCP Configuration (•̀o•́)ง

assign-super-user-permissions:
	# Assign Org and Project-level IAM permissions to your Argolis super-user
	@echo '-----------------------------------------------------------------------------------------------------'
	@echo
	@echo 	Assigning super user permissions...
	@echo
	@echo '-----------------------------------------------------------------------------------------------------'
	@sleep 3s
	gcloud organizations add-iam-policy-binding ${ORGANIZATION_ID} --condition=None --member="user:${GCP_SUPER_USER}" --role="roles/resourcemanager.organizationAdmin" ${ACCESS_TOKEN_FILE}
	gcloud organizations add-iam-policy-binding ${ORGANIZATION_ID} --condition=None --member="user:${GCP_SUPER_USER}" --role="roles/orgpolicy.policyAdmin" ${ACCESS_TOKEN_FILE}
	gcloud organizations add-iam-policy-binding ${ORGANIZATION_ID} --condition=None --member="user:${GCP_SUPER_USER}" --role="roles/owner" ${ACCESS_TOKEN_FILE}
	gcloud organizations add-iam-policy-binding ${ORGANIZATION_ID} --condition=None --member="user:${GCP_SUPER_USER}" --role="roles/resourcemanager.projectCreator" ${ACCESS_TOKEN_FILE}
	gcloud organizations add-iam-policy-binding ${ORGANIZATION_ID} --condition=None --member="user:${GCP_SUPER_USER}" --role="roles/billing.admin" ${ACCESS_TOKEN_FILE}

create-gcp-project:
	# Create a GCP landing zone project
	@gcloud projects create ${PROJECT_ID} --organization=${ORGANIZATION_ID} ${ACCESS_TOKEN_FILE}
	@gcloud beta billing projects link ${PROJECT_ID} --billing-account=${BILLING_ACCOUNT_ID} ${ACCESS_TOKEN_FILE}
	@make -s add-project-number

create-google-identity-groups:
	# Wait for Identity API to fully initialize
	@make -s set-gcp-project
	@gcloud --project ${PROJECT_ID} services enable cloudresourcemanager.googleapis.com cloudidentity.googleapis.com ${ACCESS_TOKEN_FILE}
	@echo '-----------------------------------------------------------------------------------------------------'
	@echo
	@echo 	Waiting for the Google Identity API to finish initializing...
	@echo
	@echo '-----------------------------------------------------------------------------------------------------'
	@sleep 130s
	@echo '-----------------------------------------------------------------------------------------------------'
	@echo
	@echo 	Creating Google Identity Groups...
	@echo
	@echo '-----------------------------------------------------------------------------------------------------'
	@sleep 3s
	# Create Google Identity Groups (aka Google Workspace Admin Groups)
	@gcloud beta identity groups create ${GCP_ORG_ADMIN_GROUP} --quiet --display-name="GCP Organization Admin Group" --description="Google Group used to provide GCP users with GCP org admin permissions"  --organization=${ORGANIZATION_ID}
	@gcloud beta identity groups create ${GCP_BILLING_ADMIN_GROUP} --quiet --display-name="GCP Billing Admin Group" --description="Google Group used to provide GCP users with GCP billing admin permissions" --organization=${ORGANIZATION_ID} 
	@gcloud beta identity groups create ${GKE_SECURITY_GROUP} --quiet --display-name="GKE Security Group" --description="Google Group used to provide GCP users with GKE RBAC permissions" --organization=${ORGANIZATION_ID}

assign-super-user-group-permissions:  set-gcp-project
	# Assign Org and Project-level IAM permissions to your Argolis Org's GCP Workspace 'gcp-org-admin-group' and 'gcp-billing-admin-group'
	@echo '-----------------------------------------------------------------------------------------------------'
	@echo
	@echo 	Assigning group-level super user permissions...
	@echo
	@echo '-----------------------------------------------------------------------------------------------------'
	@sleep 3s
	gcloud organizations add-iam-policy-binding ${ORGANIZATION_ID} --condition=None --member="group:${GCP_ORG_ADMIN_GROUP}" --role="roles/resourcemanager.organizationAdmin" ${ACCESS_TOKEN_FILE}
	gcloud organizations add-iam-policy-binding ${ORGANIZATION_ID} --condition=None --member="group:${GCP_ORG_ADMIN_GROUP}" --role="roles/orgpolicy.policyAdmin" ${ACCESS_TOKEN_FILE}
	gcloud organizations add-iam-policy-binding ${ORGANIZATION_ID} --condition=None --member="group:${GCP_ORG_ADMIN_GROUP}" --role="roles/resourcemanager.folderAdmin" ${ACCESS_TOKEN_FILE}
	gcloud organizations add-iam-policy-binding ${ORGANIZATION_ID} --condition=None --member="group:${GCP_ORG_ADMIN_GROUP}" --role="roles/owner" ${ACCESS_TOKEN_FILE}
	gcloud organizations add-iam-policy-binding ${ORGANIZATION_ID} --condition=None --member="group:${GCP_ORG_ADMIN_GROUP}" --role="roles/resourcemanager.projectCreator" ${ACCESS_TOKEN_FILE}
	gcloud organizations add-iam-policy-binding ${ORGANIZATION_ID} --condition=None --member="group:${GCP_ORG_ADMIN_GROUP}" --role="roles/compute.xpnAdmin" ${ACCESS_TOKEN_FILE}
	gcloud organizations add-iam-policy-binding ${ORGANIZATION_ID} --condition=None --member="group:${GCP_BILLING_ADMIN_GROUP}" --role="roles/billing.admin" ${ACCESS_TOKEN_FILE}
	# Assign Org and Project-level IAM permissions to your Argolis Org's GCP Workspace 'gke-security-group'
	gcloud organizations add-iam-policy-binding ${ORGANIZATION_ID} --condition=None --member="group:${GKE_SECURITY_GROUP}" --role="roles/viewer" ${ACCESS_TOKEN_FILE}

# TODO:  Configure Google OAuth ArgoCD SSO 
# create-iap-auth2-client:
# 	# Create an Identity Aware Proxy (IAP) OAuth2 client
# 	@echo '-----------------------------------------------------------------------------------------------------'
# 	@echo
# 	@echo 	Creating Google Identity OAuth2 client...
# 	@echo
# 	@echo '-----------------------------------------------------------------------------------------------------'
# 	@sleep 3s
# 	# Enable Identity Aware Proxy (IAP) API
# 	@gcloud --project ${PROJECT_ID} services enable \
# 		iap.googleapis.com
# 	# Create OAuth2 brand
# 	@gcloud alpha iap oauth-brands create --application_title=ArgoCD --support_email=${GCP_ORG_ADMIN_GROUP}  --project=$(PROJECT_ID)
# 	# Create OAuth2 client
# 	@gcloud alpha iap oauth-clients create projects/${PROJECT_NUMBER}/brands/${PROJECT_NUMBER} --display_name=ArgoCD  --project=$(PROJECT_ID)
# 	@gcloud alpha iap oauth-brands list  --project=$(PROJECT_ID)
# 	@gcloud alpha iap oauth-clients list projects/${PROJECT_NUMBER}/brands/${PROJECT_NUMBER}  --project=$(PROJECT_ID)
# 	# Write QAuth2 client CLIENT_ID and CLIENT_SECRET to local config file
# 	@export CLIENT_ID=$$(gcloud alpha iap oauth-clients list projects/${PROJECT_NUMBER}/brands/${PROJECT_NUMBER}  --project=$(PROJECT_ID) --filter="displayName=ArgoCD" --format="value(name)" | cut -d '/' -f6 )
# 	@export CLIENT_SECRET=$$(gcloud alpha iap oauth-clients list projects/${PROJECT_NUMBER}/brands/${PROJECT_NUMBER}  --project=$(PROJECT_ID) --filter="displayName=ArgoCD" --format="value(secret)" )
# 	@if grep -wq "CLIENT_ID" make_env; then echo "CLIENT_ID already exists. Skipping..."; else echo -e CLIENT_ID=$$CLIENT_ID >> make_env; fi
# 	@if grep -wq "CLIENT_SECRET" make_env; then echo "CLIENT_SECRET already exists. Skipping..."; else echo -e CLIENT_SECRET=$$CLIENT_SECRET >> make_env; fi

configure-cloud-build: add-project-number set-gcp-project
	# Bootstrap the Cloud Build provisioning pipeline
	@echo '-----------------------------------------------------------------------------------------------------'
	@echo
	@echo 	Configuring Cloud Build...
	@echo
	@echo '-----------------------------------------------------------------------------------------------------'
	@sleep 3s
	# Enable Cloud Build, Secret Manager, Resource Manager APIs
	@gcloud --project ${PROJECT_ID} services enable \
		cloudbuild.googleapis.com  \
		secretmanager.googleapis.com 
	# Wait for APIs to initialize
	@sleep 20s
	# Bind IAM permissions to the default Cloud Build service account
	@gcloud organizations add-iam-policy-binding ${ORGANIZATION_ID} --role=roles/owner --condition=None --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" 
	@gcloud organizations add-iam-policy-binding ${ORGANIZATION_ID} --role=roles/billing.user --condition=None --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
	@gcloud organizations add-iam-policy-binding ${ORGANIZATION_ID} --role=roles/resourcemanager.folderAdmin --condition=None --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
	@gcloud organizations add-iam-policy-binding ${ORGANIZATION_ID} --role=roles/resourcemanager.organizationAdmin --condition=None --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
	@gcloud organizations add-iam-policy-binding ${ORGANIZATION_ID} --role=roles/orgpolicy.policyAdmin --condition=None --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
	# Write configs to Secret Manager
	@make -s create-secret
	@make -s persist-configs

enable-gcp-apis:
	#  Enable GCP APIs
	@echo '-----------------------------------------------------------------------------------------------------'
	@echo
	@echo 	Activating Google Cloud APIs...
	@echo
	@echo '-----------------------------------------------------------------------------------------------------'
	@sleep 3s
	# Cloud Operations
	@gcloud --project ${PROJECT_ID} services enable \
		monitoring.googleapis.com
	# Config Controller
	@gcloud --project ${PROJECT_ID} services enable \
		krmapihosting.googleapis.com \
		container.googleapis.com
	# Blueprints
	@gcloud --project ${PROJECT_ID} services enable \
		orgpolicy.googleapis.com \
		sourcerepo.googleapis.com
	# Cloud Domains, Cloud DNS
	@gcloud --project ${PROJECT_ID} services enable \
		domains.googleapis.com \
		dns.googleapis.com
	# Primary Anthos API (WARNING: ensures a charge!)
	@gcloud --project ${PROJECT_ID} services enable \
			anthos.googleapis.com
	# Anthos Service Mesh
	@gcloud --project ${PROJECT_ID} services enable \
		mesh.googleapis.com
	# GKE Backup
	@gcloud --project ${PROJECT_ID} services enable \
		gkebackup.googleapis.com
	# GKE Protect
	@gcloud --project ${PROJECT_ID} services enable \
		containersecurity.googleapis.com
	# Anthos Config Management
	@gcloud beta container hub config-management enable

configure-iam:
	# Bind IAM permissions to a service account
	@echo '-----------------------------------------------------------------------------------------------------'
	@echo
	@echo 	Configuring IAM permissions...
	@echo
	@echo '-----------------------------------------------------------------------------------------------------'
	@sleep 3s	
	# Cloud Monitoring metrics
	@gcloud projects add-iam-policy-binding ${PROJECT_ID} --role=roles/monitoring.metricWriter --condition=None --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"
	# Cloud Logging
	@gcloud projects add-iam-policy-binding ${PROJECT_ID} --role=roles/logging.logWriter --condition=None --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"
	# Cloud Monitoring metadata
	@gcloud projects add-iam-policy-binding ${PROJECT_ID} --role=roles/stackdriver.resourceMetadata.writer --condition=None --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"
	@gcloud projects add-iam-policy-binding ${PROJECT_ID} --role=roles/opsconfigmonitoring.resourceMetadata.writer --condition=None --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"
	# Cloud Trace
	@gcloud projects add-iam-policy-binding ${PROJECT_ID} --role=roles/cloudtrace.agent --condition=None --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"	

configure-org-policies:
	#  Update existing GCP Org policies
	@echo '-----------------------------------------------------------------------------------------------------'
	@echo
	@echo 	Configuring organization policies...
	@echo
	@echo '-----------------------------------------------------------------------------------------------------'
	@sleep 3s
	@make -s patch-org-policies

create-cloud-domain:
	# Purchase a Cloud Domain domain name
	@echo '-----------------------------------------------------------------------------------------------------'
	@echo
	@echo 	Registering a new Cloud Domain...
	@echo
	@echo '-----------------------------------------------------------------------------------------------------'
	@sleep 3s
	# Create a Cloud DNS zone
	@gcloud dns managed-zones create argocd-dns-zone --dns-name ${ARGOCD_DOMAIN}. --description "ArgoCD DNS zone"  --project=${PROJECT_ID}
	# Purchase a Cloud Domain domain name
	@gcloud domains registrations get-register-parameters ${ARGOCD_DOMAIN} --project=${PROJECT_ID}
	@find .hack/cloud-domains/ -type f -name "*.yaml" -print0 | xargs -0 sed -i 's/DOMAIN_VERIFICATION_EMAIL_ADDRESS/${DOMAIN_VERIFICATION_EMAIL_ADDRESS}/'
	@gcloud domains registrations register ${ARGOCD_DOMAIN} --contact-data-from-file=.hack/cloud-domains/contacts.yaml --contact-privacy=private-contact-data --yearly-price="12.00 USD" --cloud-dns-zone=argocd-dns-zone --quiet --project=${PROJECT_ID}
	@find .hack/cloud-domains/ -type f -name "*.yaml" -print0 | xargs -0 sed -i 's/${DOMAIN_VERIFICATION_EMAIL_ADDRESS}/DOMAIN_VERIFICATION_EMAIL_ADDRESS/'

create-vpc:
	# Create a Cloud VPC
	@echo '-----------------------------------------------------------------------------------------------------'
	@echo
	@echo 	Creating VPC resources...
	@echo
	@echo '-----------------------------------------------------------------------------------------------------'
	@sleep 3s
	# Cloud VPC
	@gcloud compute networks create config-admin-vpc --subnet-mode=auto --mtu=1460 --bgp-routing-mode=global --project=${PROJECT_ID}
	# Firewall Rules
	@gcloud compute firewall-rules create allow-internal --network=projects/${PROJECT_ID}/global/networks/config-admin-vpc  --direction=INGRESS --source-ranges=10.0.0.0/8 --action=ALLOW --rules=all --project=${PROJECT_ID} 
	@gcloud compute firewall-rules create allow-internal-ssh-rdp --network config-admin-vpc --allow tcp:22,tcp:3389,icmp --direction=INGRESS --source-ranges=10.0.0.0/8 --project=${PROJECT_ID} 
	@gcloud compute firewall-rules create allow-all-egress --network config-admin-vpc --action allow --direction egress --rules tcp,udp,icmp --destination-ranges 0.0.0.0/0 --project=${PROJECT_ID}
	# Cloud Router
	@gcloud compute routers create router-config-admin-vpc --network config-admin-vpc --region ${ARGOCD_REGION} --project ${PROJECT_ID}
	# Cloud NAT
	@gcloud compute routers nats create nat-config-admin-vpc --router-region ${ARGOCD_REGION} --router router-config-admin-vpc --auto-allocate-nat-external-ips --nat-all-subnet-ip-ranges --enable-logging --project ${PROJECT_ID}

create-admin-cluster:
	@echo '-----------------------------------------------------------------------------------------------------'
	@echo
	@echo 	Creating an admin cluster with the name ${ARGOCD_CLUSTER_NAME}...
	@echo
	@echo '-----------------------------------------------------------------------------------------------------'
	@sleep 3s
	# BQ dataset
	bq --location=US mk -d --default_table_expiration 3600 --description "GKE utilization dataset" ${ARGOCD_BQ_DATASET_NAME} 
	# Pub/Sub notification topic
	gcloud pubsub topics create ${ARGOCD_PUBSUB_TOPIC} --project ${PROJECT_ID}
	# GKE cluster
	gcloud beta container --project ${PROJECT_ID} clusters create ${ARGOCD_CLUSTER_NAME} --region ${ARGOCD_REGION} --no-enable-basic-auth --release-channel "rapid" --machine-type "e2-highcpu-4" --image-type "COS_CONTAINERD" --disk-type "pd-standard" --disk-size "100" --metadata disable-legacy-endpoints=true --num-nodes "2" --enable-autoscaling --min-nodes "0" --max-nodes "3" --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --max-pods-per-node "110" --enable-private-nodes --master-ipv4-cidr "172.16.0.0/28" --enable-ip-alias --network "projects/${PROJECT_ID}/global/networks/config-admin-vpc" --subnetwork "projects/${PROJECT_ID}/regions/${ARGOCD_REGION}/subnetworks/config-admin-vpc" --cluster-ipv4-cidr "192.168.0.0/16" --services-ipv4-cidr "192.169.0.0/16" --no-enable-intra-node-visibility --default-max-pods-per-node "110" --enable-dataplane-v2 --enable-master-authorized-networks --master-authorized-networks 0.0.0.0/0 --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver,ConfigConnector,BackupRestore --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --labels mesh_id=proj-${PROJECT_NUMBER} --resource-usage-bigquery-dataset ${ARGOCD_BQ_DATASET_NAME} --enable-resource-consumption-metering --workload-pool "${PROJECT_ID}.svc.id.goog" --enable-shielded-nodes --security-group "gke-security-groups@${GOOGLE_ADMIN_DOMAIN}" --notification-config=pubsub=ENABLED,pubsub-topic=projects/${PROJECT_ID}/topics/${ARGOCD_PUBSUB_TOPIC} --enable-image-streaming --logging=SYSTEM,WORKLOAD  --monitoring=SYSTEM,API_SERVER,SCHEDULER,CONTROLLER_MANAGER --enable-managed-prometheus --enable-workload-config-audit
	# Register cluster with GKE Fleet/Hub
	gcloud container hub memberships register ${ARGOCD_CLUSTER_NAME} --gke-cluster=${ARGOCD_REGION}/${ARGOCD_CLUSTER_NAME} --project ${PROJECT_ID} --enable-workload-identity --quiet
	# Enable Anthos Servie Mesh with Managed Controlplane
	gcloud container fleet mesh enable --project ${PROJECT_ID}
	gcloud container fleet mesh update --control-plane automatic --memberships ${ARGOCD_CLUSTER_NAME}  --project ${PROJECT_ID}
	# gcloud organizations add-iam-policy-binding ${ORGANIZATION_ID} --role=roles/container.admin --condition=None --member="serviceAccount:service-${PROJECT_NUMBER}@gcp-sa-meshcontrolplane.iam.gserviceaccount.com"
	gcloud container fleet mesh describe --project ${PROJECT_ID}
	# Update ConfigConnector CRD
	make -s patch-config-connector-crd
	# Grant Config Connector super-user org-level admin privledges
	gcloud iam service-accounts create cnrm-system --project ${PROJECT_ID}
	gcloud iam service-accounts add-iam-policy-binding cnrm-system@${PROJECT_ID}.iam.gserviceaccount.com --member="serviceAccount:${PROJECT_ID}.svc.id.goog[cnrm-system/cnrm-controller-manager]" --role="roles/iam.workloadIdentityUser"
	gcloud organizations add-iam-policy-binding ${ORGANIZATION_ID} --role=roles/owner --condition=None --member="serviceAccount:cnrm-system@${PROJECT_ID}.iam.gserviceaccount.com" 
	gcloud organizations add-iam-policy-binding ${ORGANIZATION_ID} --role=roles/billing.admin --condition=None --member="serviceAccount:cnrm-system@${PROJECT_ID}.iam.gserviceaccount.com"
	gcloud organizations add-iam-policy-binding ${ORGANIZATION_ID} --role=roles/compute.xpnAdmin --condition=None --member="serviceAccount:cnrm-system@${PROJECT_ID}.iam.gserviceaccount.com"
	gcloud organizations add-iam-policy-binding ${ORGANIZATION_ID} --role=roles/resourcemanager.folderAdmin --condition=None --member="serviceAccount:cnrm-system@${PROJECT_ID}.iam.gserviceaccount.com"
	gcloud organizations add-iam-policy-binding ${ORGANIZATION_ID} --role=roles/resourcemanager.organizationAdmin --condition=None --member="serviceAccount:cnrm-system@${PROJECT_ID}.iam.gserviceaccount.com"
	# Create backup and restore plans for GKE
	make -s configure-gke-backup-and-restore
	# Enable Policy Controller
	make -s configure-policy-controller

bootstrap-argocd: connect-to-argocd
	# Install ArgoCD on the designated admin cluster
	@echo '-----------------------------------------------------------------------------------------------------'
	@echo
	@echo 	Installing ArgoCD version ${ARGOCD_VERSION} in ${ARGOCD_CLUSTER_NAME}...
	@echo
	@echo '-----------------------------------------------------------------------------------------------------'
	@sleep 3s
	# Apply a pinned version of ArgoCD
	@kubectl create namespace argocd
	@kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/ha/install.yaml
	# Create DNS, certificate, and ingress sources for ArgoCD
	@make -s patch-argocd-networking-resources
	# Enable Anthos Service Mesh (aka Istio) automatic sidecar injection
	@kubectl label namespace argocd istio-injection=enabled istio.io/rev- --overwrite
	@kubectl label namespace cnrm-system istio-injection=enabled istio.io/rev- --overwrite
	# Restart Config Connector
	@kubectl -n cnrm-system delete pod --all
	# Restart ArgoCD
	@make -s restart-argocd
	# Display ArgoCD UI connection details
	@make -s display-argocd-ui-info

## Testing (•̀o•́)ง

create-and-destroy-everything: validate-auth-token validate-environment-settings 
	# Test end-to-end lifecyle management.
	# Example usage: `make -s create-and-destroy-everything -e SUBSTITUTIONS=--substitutions=...`
	make -s run-gameops-provisioner -e CLOUD_BUILD_FILE=create-and-destroy-everything.yaml \
		 -e SUBSTITUTIONS=--substitutions=_PROJECT_ID=${PROJECT_ID},_ORGANIZATION_ID=${ORGANIZATION_ID},_BILLING_ACCOUNT_ID=${BILLING_ACCOUNT_ID},_GOOGLE_ADMIN_DOMAIN=${GOOGLE_ADMIN_DOMAIN},_GCP_SUPER_USER=${GCP_SUPER_USER}

run-smoke-test:
	## Add your smoke test logic here...
	## Example usage: `make -s run-smoke-test  -e SUBSTITUTIONS=--substitutions=_COMMAND="echo ..."`
	make -s run-gameops-provisioner -e CLOUD_BUILD_FILE=smoke-test.yaml

## Patches (•̀o•́)ง

patch-org-policies:
	# Patch resource manager org policies
	@find .hack/resource-manager/ -type f -name "*.yaml" -print0 | xargs -0 sed -i 's/PROJECT_ID/${PROJECT_ID}/'
	@gcloud org-policies set-policy .hack/resource-manager/${ORG_POLICY_NAME}.yaml ${ACCESS_TOKEN_FILE}
	@find .hack/resource-manager/ -type f -name "*.yaml" -print0 | xargs -0 sed -i 's/${PROJECT_ID}/PROJECT_ID/'

patch-config-connector-crd:
	# Patch the Config Connector CRD to use 'cluster-mode'
	@find .hack/config-connector/config-connector.yaml -type f -name "*.yaml" -print0 | xargs -0 sed -i 's/PROJECT_ID/${PROJECT_ID}/'
	@kubectl apply -f .hack/config-connector/config-connector.yaml
	@find .hack/config-connector/config-connector.yaml -type f -name "*.yaml" -print0 | xargs -0 sed -i 's/${PROJECT_ID}/PROJECT_ID/'

patch-argocd-networking-resources:
	# Patch DNS networking resouces used to bootstrap the ArgoCD UI
	@find .hack/argocd-bootstrap/ -type f -name "*.yaml" -print0 | xargs -0 sed -i 's/PROJECT_ID/${PROJECT_ID}/'
	@find .hack/argocd-bootstrap/ -type f -name "*.yaml" -print0 | xargs -0 sed -i 's/ARGOCD_DOMAIN/${ARGOCD_DOMAIN}/'
	@find .hack/argocd-bootstrap/ -type f -name "*.yaml" -print0 | xargs -0 sed -i 's/ARGOCD_SUBDOMAIN/${ARGOCD_SUBDOMAIN}/'
	@kubectl apply -f .hack/argocd-bootstrap/
	@echo '-----------------------------------------------------------------------------------------------------'
	@echo
	@echo 	Provisioning an External IP address...
	@echo
	@echo '-----------------------------------------------------------------------------------------------------'
	# Wait for External IP Address to finish provisioning
	@kubectl wait --for=condition=READY --timeout=120s -f .hack/argocd-bootstrap/compute-address.yaml
	# Update A record for ArgoCD ingress 
	@ARGOCD_IP_ADDRESS=$$(kubectl -n argocd get ComputeAddress -o=jsonpath='{.items[*].spec.address}')
	@find .hack/argocd-bootstrap/ -type f -name "*.yaml" -print0 | xargs -0 sed -i "s/ARGOCD_IP_ADDRESS/$$ARGOCD_IP_ADDRESS/"
	@kubectl apply -f .hack/argocd-bootstrap/dns.yaml
	@sleep 5s
	# Wait for ManagedCertificate to finish provisioning
	@echo '-----------------------------------------------------------------------------------------------------'
	@echo
	@echo 	Provisioning a Managed Certificate.  WARNING: This process can sometimes take up to 30 minutes...
	@echo
	@echo '-----------------------------------------------------------------------------------------------------'
	@kubectl wait --for=jsonpath='{.status.certificateStatus}'="Active" --timeout=2400s -f .hack/argocd-bootstrap/managed-certificate.yaml
	# Revert to default values
	@find .hack/argocd-bootstrap/ -type f -name "*.yaml" -print0 | xargs -0 sed -i 's/${PROJECT_ID}/PROJECT_ID/'
	@find .hack/argocd-bootstrap/ -type f -name "*.yaml" -print0 | xargs -0 sed -i 's/${ARGOCD_DOMAIN}/ARGOCD_DOMAIN/'
	@find .hack/argocd-bootstrap/ -type f -name "*.yaml" -print0 | xargs -0 sed -i 's/${ARGOCD_SUBDOMAIN}/ARGOCD_SUBDOMAIN/'
	@find .hack/argocd-bootstrap/ -type f -name "*.yaml" -print0 | xargs -0 sed -i "s/$$ARGOCD_IP_ADDRESS/ARGOCD_IP_ADDRESS/"

## Additional Utils (•̀o•́)ง

run-gameops-provisioner:
	@gcloud builds submit . --config .hack/cloud-build/${CLOUD_BUILD_FILE} ${SUBSTITUTIONS}

add-project-number:
	@if grep -wq PROJECT_NUMBER make_env; then echo ""; else echo -e PROJECT_NUMBER=$$(gcloud projects list --filter=${PROJECT_ID} --format="value(PROJECT_NUMBER)") >> make_env; fi

invoke-build-trigger:
	@gcloud alpha builds triggers run source-repo-cicd-trigger --branch=master --project=${PROJECT_ID}

create-resource-sha:
	@if grep -wq "SHA" make_env; then echo ""; else echo -e SHA=$$(echo $$RANDOM | md5sum | head -c 4) >> make_env; fi

refresh-resource-sha:
	@sed -i 's/SHA=${SHA}//' make_env
	@make -s create-resource-sha

create-pre-shared-key:
	# PRE_SHARED_KEY is created as per: https://cloud.google.com/network-connectivity/docs/vpn/how-to/generating-pre-shared-key#openssl
	@if grep -wq "PRE_SHARED_KEY" make_env; then echo ""; else echo -e PRE_SHARED_KEY=$$(echo -e $$(openssl rand -base64 24)) >> make_env; fi

commit-and-push:
	# Commit and push source-repo code
	@cd source-repo
	@git add ${COMMIT_PATH}
	@git commit -m '${COMMIT_MESSAGE}'
	@git push
	@cd ../ && sleep 15s

assign-billing-accounts:
	@gcloud beta billing projects link "logging-${SHA}" --billing-account=${BILLING_ACCOUNT_ID} ${ACCESS_TOKEN_FILE}
	@declare -a USER_GROUPS=(${USER_GROUPS})
	@declare -a ENVIRONMENTS_SHA=(${ENVIRONMENTS_SHA})
	for i in "$${USER_GROUPS[@]}"; 
		do
			for j in "$${ENVIRONMENTS_SHA[@]}"; 
				do 
					@gcloud beta billing projects link "$$i-$$j" --billing-account=${BILLING_ACCOUNT_ID} ${ACCESS_TOKEN_FILE}
			done;
	done;

poll-cloud-build:
	# Wait for Cloud Build hydration pipeline to complete before running additional provisioning steps
	@cd source-repo; export GIT_COMMIT_ID=$$(git log --pretty=format:'%H' -n 1); cd ../
	@export CLOUD_BUILD_ID=$$(gcloud builds list --filter="source.repoSource.commitSha=$$GIT_COMMIT_ID" --format=json | jq -r '.[] .id')
	@export CLOUD_BUILD_ID=$$(echo $$CLOUD_BUILD_ID | tr -d \'\"\' | cut -d' ' -f1)
	@echo '-----------------------------------------------------------------------------------------------------'
	@echo
	@echo
	@echo 	Waiting for build $$CLOUD_BUILD_ID to complete...
	@echo
	@echo
	@echo	To view your build in the GCP Cloud Console, please open the following link in your browser:
	@echo
	@echo
	@echo	https://console.cloud.google.com/cloud-build/builds\;region=global/$$CLOUD_BUILD_ID\?authuser=0\&project=${PROJECT_ID}
	@echo
	@echo
	@echo '-----------------------------------------------------------------------------------------------------'
	@sleep 2s
	@gcloud beta builds log --stream $$CLOUD_BUILD_ID > temp
	@sleep 20s

force-remove-custom-resources:  connect-to-argocd
	# Remove the cnrm finalizer from Kubernetes custom resources that are stuck in a deletion state
	@echo '-----------------------------------------------------------------------------------------------------'
	@echo
	@echo 	Removing GCP KRM resources the ${NAMESPACE} namespace...
	@echo
	@echo '-----------------------------------------------------------------------------------------------------'
	@sleep 3s
	@kubectl -n ${NAMESPACE} get gcp -o yaml | sed -e '/creationTimestamp:/d' \
		\-e '/deletionTimestamp:/d' \
		\-e '/selfLink: [a-z0-9A-Z/]\+/d' \
		\-e '/resourceVersion: "[0-9]\+"/d' \
		\-e '/phase:/d' -e '/uid: [a-z0-9-]\+/d' \
		\-e '/observedGeneration: [a-z0-9-]\+/d' \
		\-e '/generation: [a-z0-9-]\+/d' \
			> delete-me.yaml
	@sed -i 's/- cnrm.cloud.google.com\/finalizer//' delete-me.yaml
	@kubectl -n ${NAMESPACE} apply -f delete-me.yaml
	@rm delete-me.yaml

show-code-changes:
	@cd source-repo/ && git status && cd ..

clone-source:
	@gcloud source repos clone source-repo --project=${PROJECT_ID}
	@cd source-repo
	@git config user.email $$(gcloud auth list --filter=status:ACTIVE --format='value(account)')
	@cd ../	

remove-source:
	@rm -rf source-repo

clone-deployment:
	@gcloud source repos clone deployment-repo --project=${PROJECT_ID}
	@cd deployment-repo
	@git config user.email $$(gcloud auth list --filter=status:ACTIVE --format='value(account)')
	@cd .

build-and-push-gameops-provisioner-image:
	@docker login 
	@docker build -t ${GAMEOPS_IMAGE} .  -f .hack/cloud-build/images/Dockerfile
	@docker push ${GAMEOPS_IMAGE}

delete-bq-logging-sync:
	@gcloud beta logging sinks delete ${ORGANIZATION_ID}-bqsink --organization=${ORGANIZATION_ID} --quiet
	@gcloud beta logging sinks list --organization=${ORGANIZATION_ID}

validate-environment-settings:
	# Confirm that the environment variables required by GNU Make are present
	@echo '-----------------------------------------------------------------------------------------------------'
	@echo
	@echo 	Checking your environment settings...
	@echo
	@echo '-----------------------------------------------------------------------------------------------------'
	@sleep 3s
	# Check that `make_env` file exists AND is not empty
	if [ ! -s make_env ]
	then
		@echo '-----------------------------------------------------------------------------------------------------'
		@echo
		@echo 	Could not find any environment settings.  Please provide this information...
		@echo
		@echo '-----------------------------------------------------------------------------------------------------'
		@sleep 1s
		make -s input-environment-settings -e SETTTING=PROJECT_ID
		make -s input-environment-settings -e SETTTING=ORGANIZATION_ID
		make -s input-environment-settings -e SETTTING=BILLING_ACCOUNT_ID
		make -s input-environment-settings -e SETTTING=GOOGLE_ADMIN_DOMAIN
		make -s input-environment-settings -e SETTTING=GCP_SUPER_USER
		make -s input-environment-settings -e SETTTING=DOMAIN_VERIFICATION_EMAIL_ADDRESS
	# TODO: Add linting to confirm that pre-existing `make_env` settings are valid
	# elif [...]
	# then ...
	fi

input-environment-settings:
	# Remove unfinished `make_env` file if user quits session
	@trap "rm make_env; exit" SIGHUP SIGINT SIGTERM
	# Write user input to `make_env`
	@read -e -p "Please input your ${SETTTING}:   " USER_INPUT
	@echo ${SETTTING}=$$USER_INPUT >> make_env

validate-auth-token:
	@echo '-----------------------------------------------------------------------------------------------------'
	@echo
	@echo 	Checking for a valid Google ADC access token...
	@echo
	@echo '-----------------------------------------------------------------------------------------------------'
	@sleep 3s
	# If an auth token is not present, prompt user to authenticate
	if [ ! -s ${ACCESS_TOKEN_FILE_PATH} ]
	then
		@echo '-----------------------------------------------------------------------------------------------------'
		@echo
		@echo 	Could not find a pre-existing access token...
		@echo
		@echo '-----------------------------------------------------------------------------------------------------'
		@sleep 1s
		make -s authenticate-google-account
	# If the auth token will expire soon, prompt user to re-authenticate
	elif [ $$(find ${ACCESS_TOKEN_FILE_PATH} -mmin +20) ]
	then
		@echo '-----------------------------------------------------------------------------------------------------'
		@echo
		@echo 	Your access token will expire soon...
		@echo
		@echo '-----------------------------------------------------------------------------------------------------'
		@sleep 1s
		@make -s authenticate-google-account
	fi

display-argocd-ui-info:
	# Retrieve the default ArgoCD password
	ARGOCD_DEFAULT_PASSWORD=$$(kubectl -n argocd get secret argocd-initial-admin-secret -o=jsonpath='{.data.password}' | base64 -d)
	# Print the intial login details for the ArgoCD UI
	@echo '-----------------------------------------------------------------------------------------------------'
	@echo
	@echo 	Open the following URL in your browser to connect to the ArgoCD console.
	@echo
	@echo 	"	https://${ARGOCD_SUBDOMAIN}.${ARGOCD_DOMAIN}"
	@echo
	@echo
	@echo   Your default login credentials are listed below:
	@echo
	@echo	"	USERNAME: admin"
	@echo	"	PASSWORD: $$ARGOCD_DEFAULT_PASSWORD"
	@echo
	@echo
	@echo   Read the following docs to learn how you can update these default credentials.
	@echo
	@echo	"	https://argo-cd.readthedocs.io/en/stable/getting_started/#4-login-using-the-cli"
	@echo
	@echo '-----------------------------------------------------------------------------------------------------'
	@sleep 1s

delete-lien:
	# Delete a project lien
	export LIEN_NAME=$$(gcloud alpha resource-manager liens list --project ${PROJECT_ID} --format=json | jq -r '.[] .name')
	export LIEN_NAME=$$(echo $$LIEN_NAME | tr -d \'\"\/\' | sed 's/liens//' )
	echo $$LIEN_NAME
	@gcloud alpha resource-manager liens delete $$LIEN_NAME

create-secret:
	# Initialize a Secret Manager secret
	@gcloud secrets create gameops-configs --replication-policy="automatic"

persist-configs:  add-project-number create-resource-sha
	# Write local configs to Secret Manager
	@gcloud secrets versions add gameops-configs --data-file=make_env

refresh-local-configs:
	# Upate local configs with Secret Manager values
	@gcloud secrets versions access "latest" --secret=gameops-configs > make_env

create-wildcard-certificate:
	# Create a wildcard certificate using GCP Certificate Manager
	@gcloud certificate-manager dns-authorizations create gameops-dns-authorization --domain="${ARGOCD_DOMAIN}"
	@gcloud beta certificate-manager certificates create gameops-wildcard-certificate --domains="${ARGOCD_DOMAIN},*.${ARGOCD_DOMAIN}" --dns-authorizations="gameops-dns-authorization"
	gcloud certificate-manager maps create gameops-certificate-map
	gcloud certificate-manager maps entries create gameops-certificate-map-001 --map="gameops-certificate-map" --certificates="gameops-wildcard-certificate" --hostname="info.demo-7879.xyz"
	gcloud compute target-http-proxies list
	gcloud compute target-http-proxies update PROXY_NAME --certificate-map="gameops-certificate-map"

configure-gke-backup-and-restore:
	# Create backup and restore plans for GKE
	gcloud alpha container backup-restore backup-plans create ${ARGOCD_CLUSTER_NAME}-backup-plan --project=${PROJECT_ID} --location=${ARGOCD_REGION} --cluster=projects/${PROJECT_ID}/locations/${ARGOCD_REGION}/clusters/${ARGOCD_CLUSTER_NAME} --all-namespaces --include-secrets --include-volume-data --cron-schedule="10 3 * * *" --backup-retain-days=30 --backup-delete-lock-days 7
	gcloud alpha container backup-restore restore-plans create ${ARGOCD_CLUSTER_NAME}-restore-plan --project=${PROJECT_ID} --location=${ARGOCD_REGION}  --backup-plan=projects/${PROJECT_ID}/locations/${ARGOCD_REGION}/backupPlans/${ARGOCD_CLUSTER_NAME}-backup-plan --cluster=projects/${PROJECT_ID}/locations/${ARGOCD_REGION}/clusters/${ARGOCD_CLUSTER_NAME} --cluster-resource-conflict-policy=USE_BACKUP_VERSION --namespaced-resource-restore-mode=DELETE_AND_RESTORE  --cluster-resource-restore-scope="" --all-namespaces

configure-policy-controller:
	# Enable Policy Controller
	gcloud beta container hub config-management apply --membership=${ARGOCD_CLUSTER_NAME} --config=.hack/policy-controller/policy-controller.yaml --project=${PROJECT_ID}
