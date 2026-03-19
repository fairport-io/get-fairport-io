# get-fairport-io

## Table of Contents

- [Create A New Cluster](#create-a-new-cluster)
- [Add Node To Existing Cluster](#add-node-to-existing-cluster)
  - [Using the Helper Script](#using-the-helper-script)
  - [Using FP Node Manager](#using-fp-node-manager)
  - [Manually](#manually)
- [Uninstall](#uninstall)
- [Infrastructure As Code](#infrastructure-as-code)
  - [Ansible](#Ansible)
  - [Terraform](#Terraform)

---

## Create A New Cluster

```shell
curl https://get.fairport.io | sudo bash -
```

> [!NOTE]
> By default, the cluster will use `100.64.0.0/10` (CGNAT Range) for pods and services in a configuration which allows for up to 4096 nodes per cluster.  If this overlaps with any of your internal networks or apps like Tailscale, you can set a different range like this example:
> `curl https://get.fairport.io | sudo RKE2_CLUSTER_CIDR="10.144.0.0/12" RKE2_SERVICE_CIDR="10.160.0.0/12" bash -`

## Add Node To Existing Cluster

### Using the Helper Script

Log into a control-plane/server node and run one of the following commands to generate a script used to join the cluster. Run the script on the node you want to add to the cluster.

- **Agent/Worker**: `/usr/local/bin/fp-add-agent`
- **Server/Control-plane**: `/usr/local/bin/fp-add-server`

### Using FP Node Manager

> [!NOTE]
> Work in progress

The kubernetes cluster can also add nodes if a SSH public key is installed on the target nodes.

```shell
cat << EOF | kubectl apply -f -
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: worker-1                     # Required (Unique name)
  namespace: fairport                # Required: fairport
  labels:
    fairport.io/node: 'true'         # Required ('true')
data:
  ip: '127.0.0.1'                    # Required
  type: 'agent'                      # Default: agent
  ssh_user: 'fairport'               # Default: fairport
  ssh_port: '22'                     # Default: 22
  ssh_secret_name: 'fp-ssh-keys'     # Default: fp-ssh-keys
  ssh_secret_namespace: 'tinkerbell' # Default: tinkerbell
  ssh_secret_key: 'id_rsa'           # Default: id_rsa
  pre_install_cmd: |
    echo hi                          # Default: ''
  post_install_cmd: |
    echo bye                         # Default: ''
EOF
```

### Manually

You can also generate your own join script by using the following method:

```shell
export RKE2_TYPE=""   # Options: [agent|server]
export RKE2_SERVER="" # Format: https://<SERVER_IP>:9345
export RKE2_TOKEN=""  # Content of /var/lib/rancher/rke2/server/node-token
curl https://get.fairport.io | sudo -E bash -
```

## Uninstall

```shell
curl https://get.fairport.io | sudo bash -s -- uninstall
```

## Infrastrcture As Code

People and/or organizations may want to manage their clusters using Infrastructure as Code (IaC) tools such as Ansible and Terraform.  You can find samples of both in this repository.

### Ansible

- [Ansible Playbook](iac/ansible/sample-playbook.yml)
- [Ansible Inventory](iac/ansible/sample-inventory.yml)

### Terraform

- [Terraform Configuration](iac/terraform/main.tf)
