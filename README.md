# get-fairport-io

# Table of Contents

- [Minimum Requirements](#minimum-requirements)
- [Operations](#operations)
  - [Create A New Cluster](#create-a-new-cluster)
  - [Add Node To Existing Cluster](#add-node-to-existing-cluster)
    - [Using the Helper Script](#using-the-helper-script)
    - [Using FP Node Manager](#using-fp-node-manager)
    - [Manually](#manually)
  - [Upgrades](Upgrades)
  - [Uninstall](#uninstall)
  - [Infrastructure As Code](#infrastructure-as-code)
    - [Ansible](#Ansible)
    - [Terraform](#Terraform)
- [Architecture](#Architecture)
  - Diagrams
  - Capabilities
  - Limitations

# Minimum Requirements

- Minimal (no components): 2 CPU, 4GB Memory
- Recommended: 4 CPU, 8GB Memory (More is always better!)

# Operations

## Create A New Cluster

```shell
curl https://get.fairport.io | sudo bash -
```

> [!NOTE]
> By default, the cluster will use `100.64.0.0/10` (CGNAT Range) for pods and services in a configuration which allows for up to 4096 nodes per cluster.  If this overlaps with any of your internal networks or apps like Tailscale, you can set a different range like this example:
>
> `curl https://get.fairport.io | sudo RKE2_CLUSTER_CIDR="10.144.0.0/12" RKE2_SERVICE_CIDR="10.160.0.0/12" bash -`

> [!NOTE]
> To override default values from the Fairport helm chart during installation by defining them in a file and then setting the `FAIRPORT_CONFIG_FILE` environment variable.  Here is a simple example:
>
> `export FAIRPORT_CONFIG_FILE=/opt/fp-values.yaml && echo "kube-vip:\n  enabled: false" > $FAIRPORT_CONFIG_FILE`

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

## Upgrades

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

# Architecture

## Diagrams

![Architecture](architecture.svg)

## Capabilities

| Capabilities                 | Description |
| :---                         | :--- |
| **High Availability**        | Both the control-plane and worker nodes can have redundant nodes to ensure high availability.  This means that if there are 3 control-plane nodes and one dies, the cluster will continue to work without intervention.  This also means that if your app has 3 replicas and one dies, it will continue to run normally if properly configured. This also means you can migrate control-plane nodes and workloads without downtime |
| **Service Discovery**        | Workloads inside the cluster can use service discovery to find and connect to other containers and services using names. |
| **Scaling/Autoscaling**      | Policies can be configured to either manually or automatically add or remove containers to a workload. |
| **Isolation**                | Workloads can be isolated from each other using namespaces and resource quotas.<br><br>Containers can also be isolated from each other with network policies that act like cluster firewalls. |
| **Self-Healing**             | The cluster can automatically restart failed containers, and reschedule them to healthy nodes to maintain availability. |
| **Load Balancing**           | The cluster can automatically distribute network traffic across healthy nodes to ensure optimal performance and availability. |
| **Job Scheduling**           | Runs batched or scheduled jobs (non-continuous workloads) with fine-grained capabilities. |
| **Topology Awareness**       | The cluster can schedule pods across multiple nodes based on their topology requirements.<br><br>This can include: CPU, memory, Corsair (AIP), rack, region, datacenter, etc. |
| **Configuration Management** | Operators can manage and update the cluster using yaml configurations. These can be applied from a repo such as an IAC (Infrastructure as Code) git repository using a CI/CD system or manually with the kubectl tool. |
| **Secret Management**        | The cluster can store and manage sensitive information such as passwords, API keys, and other secrets in a secure and centralized manner. |
| **Role-Based Access Control (RBAC)** | Provides fine-grained access control to manage user permissions and access to cluster resources. |

## Limitations


| Limitation                       | Value     | Configurable | Description |
| :---                             | :---      | :---         | :---        |
| **Nodes Per Cluster**            | 4,096     | Yes          | The maximum number of nodes supported in the default configuration is 4096 based on the IPv4 CIDR block. In reality the control-plane IO will likely be more of a bottleneck well before  4096 nodes. |
| **Pods Per Node**                | 256       | Yes          | The maximum number of pods supported in the default configuration per node. |
| **Pods Per Cluster**             | 1,048,576 | Yes          | The maximum number of pods supported in the default configuration per cluster. |
| **Services Per Cluster**         | 4,194,304 | Yes          | The maximum number of services supported in the default configuration per cluster. |
| **Minimum CPUs Per Node**        | 2         | Auto         | The recommended absolute minimum number of CPUs a node should have. |
| **Minimum Memory (GB) Per Node** | 8         | Auto         | The recommended absolute minimum number of Memory a node should have. |

