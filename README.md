# get-fairport-io

## Table of Contents

- [Create A New Cluster](#create-a-new-cluster)
- [Add Node To Existing Cluster](#add-node-to-existing-cluster)
  - [Using the Helper Script](#using-the-helper-script)
  - [Using FP Node Manager](#using-fp-node-manager)
  - [Manually](#manually)
- [Uninstall](#uninstall)

---

## Create A New Cluster

```shell
curl https://get.fairport.io | sudo bash -
```

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
  name: worker-1
  namespace: fairport
  labels:
    fairport.io/node: "true"
data:
  ip: 127.0.0.1
  role: agent
  ssh_user: admin
  ssh_port: "22"
  ssh_secret: ssh-key
  ssh_secret_value: id_rsa
  pre_install_cmd: |
    echo hi
  post_install_cmd: |
    echo bye
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
