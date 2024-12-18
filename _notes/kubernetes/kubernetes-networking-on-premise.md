---
title: Kubernetes Networking on Premise 🌱
permalink: /kubernetes-networking
category: kubernetes
---

### Kubernetes Networking -- for people that want to run their own clusters 🌱

So this page is about the setup of this Kubernetes (K8s) cluster, specifically the networking parts. I also describe the on-premise setup I use in my own rack and network in AS57860, where I have my own prefixes for both IPv4 and IPv6. If you want to create a lab, then look into RFC1918 addresses. Please don't copy my public IPs and use them in your configurations!

I use a basic [`Kubernetes.io`](https://kubernetes.io/) cluster installed on top of Debian Linux, installed with Kubeadm

Then I install a [Container Network Interface (CNI)](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/) named  [Cilium](https://cilium.io/) chosen because it supported ingress and egress filtering of network traffic, plus it can act as a host firewall -- even though that part took way longer than expected! It is also mature and has excellent documentation

## Installing K8s and Cilium
This script is expected to be run by a regular user with Sudo rights, I call it install-kubernetes.sh:
```
#! /bin/sh
# K8s cluster installed with Kubeadm and prepared for Cilium

# IPv4 only
#sudo kubeadm init --pod-network-cidr=10.50.0.0/16 --skip-phases=addon/kube-proxy

# IPv4 and IPv6
sudo kubeadm init --pod-network-cidr=10.50.0.0/16,2a06:d380:9984:0::/56 --service-cidr=10.96.0.0/16,2a06:d380:9985::/108 --skip-phases=addon/kube-proxy


mkdir -p $HOME/.kube
sudo cp -fi /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl taint nodes --all node-role.kubernetes.io/control-plane-

kubectl label nodes --all node.kubernetes.io/exclude-from-external-load-balancers-

kubectl label nodes --all bgp=router
```

Note: The process includes a few taints and labels, to allow me to run a cluster with only two nodes. I dont want to have a dedicated control plane node. The bgp=router is important for Cilium BGP to start running on at least some nodes.

After installing the first thing I do is install Cilium with this script, I call it install-cilium.sh, and it starts by uninstalling Cilium, as I have done soo many runs with changing options etc. YMMV and this was tested and works, for me.

```
#! /bin/sh
# Find releases with:
# cilium install --list-versions

cilium uninstall

echo waiting 15 seconds
sleep 15

API_SERVER_IP=::1
# Kubeadm default is 6443
API_SERVER_PORT=6443

VERSION=1.16.3

# Gateway API CRDs
# Read on https://isovalent.com/blog/post/tutorial-getting-started-with-the-cilium-gateway-api/ it needs to be installed FIRST
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/experimental-install.yaml


# Kubernetes was installed using these:
# So make sure to set the same!
NATIVE_CIDR=10.50.0.0/16
NATIVE_CIDR6="2a06:d380:9984:0::/96"

cilium install --version=$VERSION --helm-set ipam.mode=cluster-pool --helm-set bgpControlPlane.enabled=true --helm-set k8s.requireIPv4PodCIDR=true --helm-set kube-proxy-replacement=strict 		--helm-set prometheus.enabled=true 	--helm-set operator.prometheus.enabled=true 	--helm-set hubble.relay.enabled=true 	--helm-set hubble.ui.enabled=true 	--helm-set hubble.metrics.enabled="{dns,drop,tcp,flow,icmp,http}" --helm-set --policy-audit-mode=true --helm-set hostFirewall.enabled=true  --helm-set devices='{enp1s0}' --helm-set namespace=kube-system --helm-set ipv6.enabled=true --set enableIPv6Masquerade=false  --helm-set ipam.operator.clusterPoolIPv4PodCIDRList=$NATIVE_CIDR --helm-set ipam.operator.clusterPoolIPv6PodCIDRList=$NATIVE_CIDR6 --helm-set ipam.operator.clusterPoolIPv4MaskSize=24 --helm-set ipam.operator.clusterPoolIPv6MaskSize=112  --helm-set bpf.masquerade=true --helm-set gatewayAPI.enabled=true



#kubectl rollout restart daemonset -n kube-system cilium
kubectl -n kube-system rollout restart deployment/cilium-operator

```

A few notes:

* This uses the new Gateway API -- if you want the older and mature ingress, you will have to remove that part
* I use the Border Gateway Protocol (BGP) in my setup, as I find it easy to work with. I have a home router running OpenBSD which includes OpenBGP, and in the data center I also have a BGP router
* Make sure to set the networks used in Kubeadm and Cilium install to the same prefixes, or problems may arise

I recommend that you look up the documentation for Cilium options, according to the version you choose! I started with Cilium version 13, and now I am running version 16 which seems a nice compromise between stable and supporting the features I want to test and play with.






You can read more about the server on the page [[kubernetes-welcome]] and this page is about the deployment of the web service using Nginx
