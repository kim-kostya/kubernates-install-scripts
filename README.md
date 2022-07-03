# kubernetes install tool
Small scripts to make installation of kubernetes easier.

## Before starts
+ Works only for debian like distros with systemd.
+ Check configs folder.

## Config tree
---
configs\
├ kubernetes -> /etc/kubernetes\
├ runtimes \
| ├ containerd.toml -> /etc/containerd/config.toml \
| └ crio.conf -> /etc/crio/crio.conf \
└ kubeadm (kubeadm init config)

## Usage
`chmod +x ./install.sh; sudo ./install.sh`.
