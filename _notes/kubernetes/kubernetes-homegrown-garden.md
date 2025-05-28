---
title: Homegrown Digital Garden using Kubernetes 🌱
permalink: /kubernetes-homegrown-garden
category: kubernetes
---

This digital garden is built using [`Kubernetes.io`](https://kubernetes.io/) and Jekyll

You can read more about the server on the page [[Welcome to Kubernetes 🌱]] and this page is about the deployment of the web service using Nginx. Setting up a digital garden for yourself can start with
this [step-by-step guide explaining how to set this up from scratch](https://maximevaillancourt.com/blog/setting-up-your-own-digital-garden-with-jekyll).

## Pre-requisites

This is aimed at a web site being presented from *flat files* like thos coming from static code generators like [Jekyll](https://jekyllrb.com/), [Hugo](https://gohugo.io/) - and not a deployment of Wordpress on Kubernetes!

It is definitely NOT a tutorial or instructions for you to paste into your own setup. You can use it for inspiration, to build your own but no promises or warranties about the end results.

So it is expected that you have this in place:
* You have some HTML files, along with pictures, CSS style sheet etc. I used Jekyll but basically you could use any static code generator
* A Kubernetes setup on-line with public reachable IPs, see my take on setting this up with Cilium and K8s on [[Kubernetes Networking on Premise 🌱]]
* A way to provide storage volumes for your pods, see below what I use


## Selecting a storage method

Your files need to be available to the pods that serve them, and for this we will mount a volume , for more information about Kubernetes volumes go to [https://kubernetes.io/docs/concepts/storage/volumes/](https://kubernetes.io/docs/concepts/storage/volumes/)

These volumes are provided by a *storage provider* or *provisioner* of which there are several!

I choose the *Kubernetes NFS Subdir External Provisioner* which can use an already configured NFS server to support the persistent volumes, and claims
https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner

This is the *shortest version possible* - a volume provided by something. The full story and all the alternatives are available at:
[https://kubernetes.io/docs/concepts/storage/](https://kubernetes.io/docs/concepts/storage/)
but if you have a hosted K8s somewhere it may make more sense to just use what they suggest and provide.

## My NFS storage

I use two Linux virtual machines for my K8s nodes, very small, and another virtual machine as NFS server.

A small script `install-nfs.sh `
```
#! /bin/sh
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
kubectl create ns nfs-provisioner
export NFS_SERVER=185.129.xx.xx   // IP address removed
export NFS_EXPORT_PATH=/userdata/

helm -n  nfs-provisioner install nfs-provisioner-01 nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
  --set nfs.server=$NFS_SERVER 	--set nfs.path=$NFS_EXPORT_PATH 	--set storageClass.defaultClass=true \
	--set replicaCount=1 	--set storageClass.name=nfs-01    --set storageClass.provisionerName=nfs-provisioner-01
```

Afterwards the nfs-provisioner has been deployed, and is available
```
hlk@cheese01:~/bin$ kubectl get pods -n nfs-provisioner
NAME                                                              READY   STATUS    RESTARTS        AGE
nfs-provisioner-01-nfs-subdir-external-provisioner-8d577bdt5ddm   1/1     Running   13 (144d ago)   216d
hlk@cheese01:~/bin$ kubectl describe pods -n nfs-provisioner
Name:             nfs-provisioner-01-nfs-subdir-external-provisioner-8d577bdt5ddm
Namespace:        nfs-provisioner
Priority:         0
Service Account:  nfs-provisioner-01-nfs-subdir-external-provisioner
Node:             cheese02/185.129.62.147
Start Time:       Sat, 19 Oct 2024 15:01:50 +0200
Labels:           app=nfs-subdir-external-provisioner
                  pod-template-hash=8d577bdd
                  release=nfs-provisioner-01
Annotations:      <none>
Status:           Running
IP:               10.50.1.162
IPs:
  IP:           10.50.1.162
  IP:           2a06:d380:9984::1:b4c
Controlled By:  ReplicaSet/nfs-provisioner-01-nfs-subdir-external-provisioner-8d577bdd
Containers:
  nfs-subdir-external-provisioner:
    Container ID:   cri-o://3ba6dd0f17431b21f9a8d483cfe8c994abca38ecb365a2c4070f613fec69e35e
    Image:          registry.k8s.io/sig-storage/nfs-subdir-external-provisioner:v4.0.2
    Image ID:       registry.k8s.io/sig-storage/nfs-subdir-external-provisioner@sha256:374f80dde8bbd498b1083348dd076b8d8d9f9b35386a793f102d5deebe593626
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Mon, 30 Dec 2024 22:05:48 +0100
    Last State:     Terminated
      Reason:       Error
      Exit Code:    255
      Started:      Mon, 30 Dec 2024 22:03:54 +0100
      Finished:     Mon, 30 Dec 2024 22:04:24 +0100
    Ready:          True
    Restart Count:  13
    Environment:
      PROVISIONER_NAME:  nfs-provisioner-01
      NFS_SERVER:        185.129.xx.xx
      NFS_PATH:          /userdata/
    Mounts:
      /persistentvolumes from nfs-subdir-external-provisioner-root (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-2chqg (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  nfs-subdir-external-provisioner-root:
    Type:      NFS (an NFS mount that lasts the lifetime of a pod)
    Server:    185.129.xx.xx
    Path:      /userdata/
    ReadOnly:  false
  kube-api-access-2chqg:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:                      <none>
```

## My gateway and deployment

More to come
