---
title: Welcome to Kubernetes 🌱
permalink: /kubernetes-welcome
category: kubernetes
---


I have decided to look into Kubernetes, and this happened a few years back. The whole world seemed to be talking about cloud and something named Kubernetes popped up.

What is Kubernetes?!


> Kubernetes, also known as K8s, is an open-source system for automating deployment, scaling, and management of containerized applications.
> It groups containers that make up an application into logical units for easy management and discovery. Kubernetes builds upon 15 years of experience of running production workloads at Google, combined with best-of-breed ideas and practices from the community.

Source:
The main web page for the project [`Kubernetes.io`](https://kubernetes.io/)

This is all fine and when people say they run K8s they actually say, I run lots of projects on top of Kubernetes. I run my own applications, but to do that I need a lot of supporting software from a community of projects.

Try going to the list of Cloud Native Computing Foundation (CNCF) projects on the landscape site:
[https://landscape.cncf.io/](https://landscape.cncf.io/) -- which will show a huge page of logos from all sorts of projects in multiple categories.

### This K8s installation

I am running this web site along with other web sites on Kubernetes using multiple products. My background is in Unix and networking, so my choices for components are influenced greatly by this. YMMV.

First I made two virtual machines, they are quite small and use a standard [Debian Linux](https://www.debian.org/). I also use a network with a router based on BGP. I have my own IP space and control everything routing, so it makes it easy to run K8s myself.

* Main installation was done using [kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm/) for initialisation of the cluster
* Then I installed a [Container Network Interface (CNI)](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/) named  [Cilium](https://cilium.io/) chosen because it supported ingress and egress filtering of network traffic, plus it can act as a host firewall -- even though that part took way longer than expected! It is also mature and has excellent documentation. See more in the note [[Kubernetes Networking on Premise 🌱]]
* I added NFS server to the Debian Linux layer, exporting a part of the file system to NFS. This allowed me to provide storage by using the [NFS provisioner](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner/) which I think is a simple way to have easy access and backup becomes a matter of old skool Unix file backups
* Certificates for [Transport Layer Security (TLS)](https://en.wikipedia.org/wiki/Transport_Layer_Security) are from [Let's Encrypt](https://letsencrypt.org/) and are managed using [cert-manager](https://cert-manager.io/)
* Things are mostly installed using kubectl apply but I also use the [Helm](https://helm.sh/) package manager, which I recommend

On top of the K8s installation I currently run basic Nginx as a web server.

I other notes I will detail parts of the installation, documenting it for myself, but you may be inspired to try something similar.

|[<img width=100px alt="Debian Linux logo" src="{{ site.baseurl }}/assets/debian-logo.png"/>](https://www.debian.org/) |[<img width=100px alt="Cilium logo" src="{{ site.baseurl }}/assets/kubeadm-stacked-color.png"/>](https://kubernetes.io/docs/reference/setup-tools/kubeadm/) |[<img width=400px alt="Cilium logo" src="{{ site.baseurl }}/assets/cillium-logo.svg"/>](https://cilium.io/) | [<img width=100px alt="Cert Manager logo" src="{{ site.baseurl }}/assets/cert-manager-logo.svg"/>](https://cert-manager.io/) |  [<img width=100px alt="Helm Package Manager logo" src="{{ site.baseurl }}/assets/helm.svg"/>](https://helm.sh/) |
