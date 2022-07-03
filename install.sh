#!/bin/sh

# Check if running as root
if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    exit 1
fi

# Add kubernetes repos
echo "Adding kubernetes dependencies"

# Sure that needed dependencies is installed
mkdir -p /usr/share/keyrings

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Installing kubernetes deployment tools
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

# Installations scripts for runtimes
function install_containerd() {
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -y containerd.io
    mkdir -p /etc/containerd/
    cp ./configs/runtimes/containerd.toml /etc/containerd/
}

function install_crio() {
    echo "deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
    echo "deb [signed-by=/usr/share/keyrings/libcontainers-crio-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list

    mkdir -p /usr/share/keyrings
    curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-archive-keyring.gpg
    curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-crio-archive-keyring.gpg

    apt-get update
    apt-get install cri-o cri-o-runc
}

# Choosing which container runtime to install
PS3="Choose container runtime to install: "
select runtime in containerd CRI-0
do
    case $REPLY in
        0) install_containerd; break ;;
        1) install_crio; break ;;
    esac
done

mkdir -p /etc/kubernetes/
cp -r ./configs/kubernetes/* /etc/kubernetes/

kubeadm init --config

function install_rancher {

}

while true; do

read -p "Do you want install rancher (y/n) " yn

case $yn in 
	[yY] ) install_rancher;
		exit;;
	[nN] ) echo exiting...;
		exit;;
	* ) echo Only y/n: ;;
esac

done