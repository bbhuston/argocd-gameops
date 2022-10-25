![](https://raw.githubusercontent.com/bbhuston/gameops/assets/.assets/gameops-bling.png)

## INTRODUCTION

`GameOps` is a collection of Google Cloud blueprints that provide users with out-of-the-box solutions for building, testing, deploying, and operating AAA game tech on [Google Cloud](https://cloud.google.com).

## How it works

GameOps uses the workflow shown below to provision an initial GCP environment and other various supportive tooling.  The main components of this overall workflow are as follows:

- A GameOps Platform Admin bootstraps a [Cloud Build](https://cloud.google.com/build) *'provisioning pipeline'* and then uses this to create a GCP landing zone project and a hardened GKE cluster which has been pre-provisioned with [ArgoCD](https://argoproj.github.io/cd/) (aka an 'ArgoCD admin cluster').
- The ArgoCD admin cluster instance uses several powerful Kubernetes frameworks, such as [Policy Controller](https://cloud.google.com/anthos-config-management/docs/concepts/policy-controller), to create and manage Google Cloud resources using [Kubernetes Resource Model](https://github.com/kubernetes/design-proposals-archive/blob/main/architecture/resource-management.md) (KRM) tooling and a GitOps-centric approach to declarative configuration management.
- Once the intial GCP landing zone environment is ready, the GameOps Platform Admin customizes and bundles (think [Kustomize](https://kustomize.io/) or [Helm](https://helm.sh/)) Kubernetes manifests into curated Kubernetes packages, commonly referred to as ['blueprints'](https://cloud.google.com/anthos-config-management/docs/concepts/blueprints), using the Cloud Build provisioning pipeline.  These blueprints are staged in a *'source repo'* code repository, instantiated using the hydration trigger, and then finally committed to a *'deployment repo'* code repository which is monitored by ArgoCD.
- When ArgoCD detects changes to the deployment repo, it automatically applies this new configuration to your GCP Organization.  This process serves as the basis of a [GitOps reconcilation loop](https://thenewstack.io/kubecon-cloud-native-patterns-of-the-gitops-pipeline/) that is used to continually create and manage the specific GCP resources which are defined in the various Kubernetes blueprint packages that GameOps relies upon.

![](https://raw.githubusercontent.com/bbhuston/argocd-gameops/main/.assets/how-it-works.png)

## Getting started with GameOps

#### Open the GameOps repo in Google Cloud Shell

Click on the following link to clone this repository into a fresh Google Cloud Shell development environment.

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https%3A%2F%2Fgithub.com%2Fbbhuston%2Fargocd-gameops.git&cloudshell_git_branch=main&cloudshell_open_in_editor=README.md&cloudshell_workspace=.)

#### Check out the latest stable version of the GameOps blueprint

Run the following command to ensure you are using the [latest stable version](https://github.com/bbhuston/argocd-gameops/releases) of GameOps.
```
GAMEOPS_VERSION=v0.1.0
git checkout ${GAMEOPS_VERSION}
```

#### Prepare your metadata

First, define some important GCP environment variables and paste this information into your terminal.
```
PROJECT_ID="Enter your new GCP landing zone Project ID"
ORGANIZATION_ID="Enter your GCP Organization ID"
BILLING_ACCOUNT_ID="Enter your GCP Billing Account ID"
GOOGLE_ADMIN_DOMAIN="Enter the Google Workspace Admin Domain used by your GCP Organization (e.g., your-gcp-username.altostrat.com)"
GCP_SUPER_USER="Enter your GCP Organization super-user's email alias (e.g., admin@your-gcp-username.altostrat.com)"
DOMAIN_VERIFICATION_EMAIL_ADDRESS="Enter an email address that can be used to verify a domain name (e.g., your-real-email@example.com)
```

Now persist these values by writing them locally to `make_env`.
```
cat << EOF > make_env
PROJECT_ID=${PROJECT_ID}
ORGANIZATION_ID=${ORGANIZATION_ID}
BILLING_ACCOUNT_ID=${BILLING_ACCOUNT_ID}
GOOGLE_ADMIN_DOMAIN=${GOOGLE_ADMIN_DOMAIN}
GCP_SUPER_USER=${GCP_SUPER_USER}
DOMAIN_VERIFICATION_EMAIL_ADDRESS=${DOMAIN_VERIFICATION_EMAIL_ADDRESS}
EOF
```

#### Prepare your GCP environment

Next, create a hardened GKE cluster and install ArgoCD on it.

```
make prepare-gcp-environment
```

#### Access the ArgoCD admin console

Once the initial provisioning process has completed, navigate to final step of the Cloud Build provisoning pipeline that was created in your landing zone project for details on how to connect to the ArgoCD admin console for the first time.  

- These connection details include, the ArgoCD admin console URL, the default admin username, and the default admin password.
- Please be sure to change your intial admin password at some point by following [these instructions](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_account_update-password/)
- Both the ArgoCD URLs and passwords are randomly generated as part of the provisioning process.

![](https://raw.githubusercontent.com/bbhuston/argocd-gameops/main/.assets/argocd-login-details.png)

Finally, open the ArgoCD admin console URL (e.g., `https://gameops.demo-87ff.xyz`) that you see in your browser and use the auto-generated login details to get started with ArgoCD.
![](https://raw.githubusercontent.com/bbhuston/argocd-gameops/main/.assets/argocd-login-details.png)

## Cleaning up

Run the following commands to remove all the Google Cloud resources that were created by following this GameOps blueprint README. 

#### Delete ArgoCD admin cluster
```
make delete-admin-cluster
```

#### Delete your GCP landing zone project
```
make delete-gcp-project
```

## Miscellaneous
The `help` argument will show you some additional commands that are available.  Please be aware that running some commands outside of the order prescribed in this README could cause your GCP project's resources to get stuck in an unstable state! 💩💩💩
```
make help
```

![](https://raw.githubusercontent.com/bbhuston/gameops/assets/.assets/make-help-output.png)

## Getting help
Please use the issues page to provide feedback or submit a bug report.

## Disclaimer
This project is totally awesome (•̀o•́)ง but is it ***not*** an officially supported Google product.  Please use it wisely!