# get-fairport-io

## Install

### Server / Control-Plane Mode
```shell
curl https://get.fairport.io | sudo bash -
```

### Agent / Worker Mode
```shell
export RKE2_TYPE=agent                         # Valid options: agent|server
export RKE2_SERVER="https://<SERVER_IP>:9345"  # Replace <SERVER_IP> with the ip of an existing server node
export RKE2_TOKEN="<TOKEN>"                    # Replace <TOKEN> with the content of /var/lib/rancher/rke2/server/node-token from an existing server node
curl https://get.fairport.io | sudo bash -
```

## Uninstall
```shell
curl https://get.fairport.io/ | sudo bash -s -- uninstall
```
