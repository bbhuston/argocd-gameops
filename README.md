![](https://raw.githubusercontent.com/bbhuston/gameops/assets/.assets/gameops-bling.png)

## INTRODUCTION

`GameOps` is a collection of Google Cloud blueprints that provide users with out-of-the-box solutions for building, testing, deploying, and operating AAA game tech on [Google Cloud](https://cloud.google.com).

## How it works

GameOps uses the workflow shown below to provision an initial GCP environment and other various supportive tooling.  The main components of this overall workflow are as follows:

- A GameOps Platform Admin bootstraps a [Cloud Build](https://cloud.google.com/build) *'provisioning pipeline'* and then uses this to create a GCP landing zone project and a hardened GKE cluster which has been pre-provisioned with [ArgoCD](https://argoproj.github.io/cd/) (aka an 'ArgoCD admin cluster').
- The ArgoCD admin cluster instance uses several powerful Kubernetes frameworks, such as [Policy Controller](https://cloud.google.com/anthos-config-management/docs/concepts/policy-controller), to create and manage Google Cloud resources using [Kubernetes Resource Model](https://github.com/kubernetes/design-proposals-archive/blob/main/architecture/resource-management.md) (KRM) tooling and a GitOps-centric approach to declarative configuration management.
- Once the intial GCP landing zone environment is ready, the GameOps Platform Admin can proceed to customize and bundle (think [Kustomize](https://kustomize.io/) or [Helm](https://helm.sh/)) Kubernetes manifests into curated Kubernetes packages, commonly referred to as ['blueprints'](https://cloud.google.com/anthos-config-management/docs/concepts/blueprints), using the Cloud Build provisioning pipeline.  These blueprints should be staged in a source code repository (aka *source repo*) and actively monitored by ArgoCD.
- When ArgoCD detects changes to this source repo, it automatically applies this new configuration to your GCP Organization.  This process serves as the basis of a [GitOps reconcilation loop](https://thenewstack.io/kubecon-cloud-native-patterns-of-the-gitops-pipeline/) that is used to continually create and manage the specific GCP resources which are defined in the various Kubernetes blueprint packages that GameOps relies upon.

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

#### Prepare your GCP environment

Let's get started by running the following command in your Cloud Shell terminal to start the provisioning process.

```
make prepare-gcp-environment
```

You will immediately be prompted to authenicate and to enter some important GCP environment variables into your terminal.  Behind the scenes, these values will be locally persisted to a file named `make_env`.

```
PROJECT_ID:  Enter your desired new GCP landing zone Project ID (e.g., amazing-example-gcp-project-001)
ORGANIZATION_ID:  Enter your GCP Organization ID (e.g., 561908118928)
BILLING_ACCOUNT_ID:  Enter your GCP Billing Account ID (e.g., 01B0F5-7AF23D-AC4712)
GOOGLE_ADMIN_DOMAIN:  Enter the Google Admin Domain used by your GCP Organization (e.g., gc-trial-9090.orgtrials.ongcp.co)
GCP_SUPER_USER:  Enter your Google Admin Super Admin email address (e.g., admin@gc-trial-9090.orgtrials.ongcp.co)
DOMAIN_VERIFICATION_EMAIL_ADDRESS:  Enter an email address that can be used to verify a domain name (e.g., your-email@example.com)
```

Once these environment variables have been provided, the provisioning process will automatically proceed ahead by creating a hardened GKE cluster, installing ArgoCD on it, and doing tons of other random (but important) stuff.  This process will take about 90 minutes to complete, so feel free to take a break and check back in later.

#### Access the ArgoCD admin console

Once the initial provisioning process has completed, navigate to final step of the Cloud Build provisoning pipeline that was created in your landing zone project for details on how to connect to the ArgoCD admin console for the first time.  

- These connection details include, the ArgoCD admin console URL, the default admin username, and the default admin password.
- Please be sure to change your intial admin password at some point by following [these instructions](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_account_update-password/)
- Both the ArgoCD URLs and passwords are randomly generated as part of the provisioning process.

![](https://raw.githubusercontent.com/bbhuston/argocd-gameops/main/.assets/argocd-login-details.png)

Finally, open the ArgoCD admin console URL (e.g., `https://gameops.demo-87ff.xyz`) that you see in your browser and use the auto-generated login details to get started with ArgoCD.
![](https://raw.githubusercontent.com/bbhuston/argocd-gameops/main/.assets/argocd-login-screen.png)

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