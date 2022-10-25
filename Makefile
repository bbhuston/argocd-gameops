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

# Source Makefile utils and default values
include .hack/make-utils/Makefile
include .hack/make-utils/make-defaults

# Source important environmental variables that need to be persisted and are easy to forget about
-include make_env

##@ Overview

# The help target prints out all targets with their descriptions organized
# beneath their categories. The categories are represented by '##@' and the
# target descriptions by '##'. The awk commands is responsible for reading the
# entire set of makefiles included in this invocation, looking for lines of the
# file as xyz: ## something, and then pretty-format the target and help. Then,
# if there's a line with ##@ something, that gets pretty-printed as a category.
# More info on the usage of ANSI control characters for terminal formatting:
# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_parameters
# More info on the awk command:
# http://linuxcommand.org/lc3_adv_awk.php

help: ##              Display help prompt
	@awk 'BEGIN {FS = ":.*##"; printf "\n########################################################################\n#             AMAZING! YOU ARE A SUPER GAMEOPS HACKERMAN!              #\n########################################################################\n\nUsage:\n\n  make \033[36m<command>\033[0m                For example, `make help` \n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Life-Cycle Management

prepare-gcp-environment: validate-environment-settings validate-auth-token ##      Configure all the boring admin stuff
	@echo '-----------------------------------------------------------------------------------------------------'
	@echo
	@echo 	Preparing your Google Cloud environment...
	@echo
	@echo '-----------------------------------------------------------------------------------------------------'
	@sleep 3s
	@make -s assign-super-user-permissions
	@make -s create-gcp-project
	@make -s create-google-identity-groups
	@make -s assign-super-user-group-permissions
	@make -s configure-cloud-build
	@make -s run-gameops-provisioner -e CLOUD_BUILD_FILE=prepare-gcp-environment.yaml

delete-admin-cluster:  set-gcp-project ##         Delete your ArgoCD admin cluster
	@echo '-----------------------------------------------------------------------------------------------------'
	@echo
	@echo 	Deleting your ArgoCD admin cluster...
	@echo
	@echo '-----------------------------------------------------------------------------------------------------'
	@sleep 3s
	@gcloud container clusters delete ${ARGOCD_CLUSTER_NAME} --project ${PROJECT_ID} --region ${ARGOCD_REGION}

delete-gcp-project:  set-gcp-project ##           Delete your GCP landing zone project
	@echo '-----------------------------------------------------------------------------------------------------'
	@echo
	@echo 	Deleting your GCP project...
	@echo
	@echo '-----------------------------------------------------------------------------------------------------'
	@sleep 3s
	@make -s delete-lien
	@gcloud projects delete ${PROJECT_ID} ${OPTIONS}

##@ Utilities

authenticate-google-account:  ##  Generate a new Google ADC access token
	@echo '-----------------------------------------------------------------------------------------------------'
	@echo
	@echo 	Generating a new Google ADC access token.  Please authenticate using the following URL...
	@echo
	@echo '-----------------------------------------------------------------------------------------------------'
	@sleep 1s
	# ADC access tokens are valid for 60 minutes
	@gcloud auth login --no-launch-browser --brief --update-adc --quiet
	@gcloud beta auth application-default print-access-token > access-token-file

set-gcp-project:  ##              Set your default GCP project context
	@echo '-----------------------------------------------------------------------------------------------------'
	@echo
	@echo 	Connecting to your GCP landing zone project...
	@echo
	@echo '-----------------------------------------------------------------------------------------------------'
	@sleep 1s
	@gcloud config set project ${PROJECT_ID}

connect-to-argocd: set-gcp-project  ##            Connect to ArgoCD
	@echo '-----------------------------------------------------------------------------------------------------'
	@echo
	@echo 	Connecting to ArgoCD..
	@echo
	@echo '-----------------------------------------------------------------------------------------------------'
	@sleep 1s
	gcloud container clusters get-credentials ${ARGOCD_CLUSTER_NAME} --region ${ARGOCD_REGION} --project ${PROJECT_ID}

restart-argocd:  connect-to-argocd  ##              Restart ArgoCD
	@echo '-----------------------------------------------------------------------------------------------------'
	@echo
	@echo 	Restarting ArgoCD...
	@echo
	@echo '-----------------------------------------------------------------------------------------------------'
	@sleep 1s
	@kubectl -n argocd delete pod --all
	@kubectl wait -n argocd --timeout=300s --for=condition=Ready pod --all

show-all-gcp-resources:  connect-to-argocd ##       Show status of GCP KRM resources
	@echo '-----------------------------------------------------------------------------------------------------'
	@echo
	@echo 	Checking status of GCP KRM resources...
	@echo
	@echo '-----------------------------------------------------------------------------------------------------'
	@sleep 1s
	@kubectl get gcp -A