# get-fairport-io

## Create A New Cluster

```shell
curl https://get.fairport.io | sudo bash -
```

## Add Node To Existing Cluster Using the Helper Script

Log into a control-plane/server node and run one of the following commands to generate a script used to join the cluster.  Run the script on the node you want to add to the cluster.

- Agent/Worker: `/usr/local/bin/fp-add-agent`
- Server/Control-plane: `/usr/local/bin/fp-add-server`

## Add a Node Using FP Node Manager

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
    fairport.io: "node"
data:
  ip: 127.0.0.1
  type: agent
  ssh_user: admin
  ssh_port: 22
  ssh_secret: ssh-key
  ssh_secret_value: id_rsa
  pre_install_cmd: |
    echo hi
  post_install_cmd: |
    echo bye
```

## Add Node To Existing Cluster Manually

You can also generate your own join script by using the following method:

```shell
export RKE2_TYPE=""   # Options: [agent|server] where server is a control-plane node or agent is a worker
export RKE2_SERVER="" # Format: 'https://<SERVER_IP>:9345' where <SERVER_IP> is an ip of an existing server node
export RKE2_TOKEN=""  # The content of /var/lib/rancher/rke2/server/node-token from an existing server node
curl https://get.fairport.io | sudo -E bash -
```

## Uninstall

```shell
curl https://get.fairport.io/ | sudo bash -s -- uninstall
```
