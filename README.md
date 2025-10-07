# get-fairport-io

## Install

### Create a New Cluster

```shell
curl https://get.fairport.io | sudo bash -
```

### Add Node To Existing Cluster

```shell
export RKE2_TYPE=""   # Options: [agent|server] where server is a control-plane node or agent is a worker
export RKE2_SERVER="" # Format: 'https://<SERVER_IP>:9345' where <SERVER_IP> is an ip of an existing server node
export RKE2_TOKEN=""  # The content of /var/lib/rancher/rke2/server/node-token from an existing server node
curl https://get.fairport.io | sudo bash -
```

## Uninstall

```shell
curl https://get.fairport.io/ | sudo bash -s -- uninstall
```
