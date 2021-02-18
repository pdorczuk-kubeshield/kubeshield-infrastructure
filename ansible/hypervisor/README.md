# kubeshield-infrastructure

Very simple Ansible playbook that prepares a vanilla Ubuntu 20.04 server to host Kubernetes demo environments.

## Getting Started

Since I am doing a lot of experimentation, I designed this setup to be really easy to tear down to the studs and rebuild at both the cluster and application level. I am running a single physical server and this playbook prepares it with all the tools and settings that I use to run the Kubeshield demo Kubernetes clusters.

### Prerequisites

Make sure you have Ansible installed and SSH access to an Ubuntu server.

1. Configure the hosts file with the correct connection information for your target server.

<HOSTNAME> ansible_connection=ssh  ansible_user=<TARGET_USER> ansible_host=<TARGET_IP> ansible_password=<TARGET_USER_PASSWORD> ansible_become_password=<TARGET_USER_PASSWORD> ansible_become_user=root

2. Edit the site.yml file to match your configuration.


Install Galaxy roles.
```
ansible-galaxy install -r requirements.yaml
```


### Installing

Almost all of the applications are managed with GitOps in ArgoCD. There is a chicken and egg problem so ArgoCD and its associated deployments need to be installed manually. 

Install Hashicorp Vault

```
cd sealedsecrets
kustomize build . | kubectl create -f-
```

Install ArgoCD

```
kustomize build ./argocd | kubectl create -f-
```
