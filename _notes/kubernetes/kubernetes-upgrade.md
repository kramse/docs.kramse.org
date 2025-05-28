---
title: Upgrading Kubernetes 🌱
permalink: /kubernetes-upgrade
category: kubernetes
---

So, I just upgraded Kubernetes (K8s) and for myself, lets document it.

Basically I followed the instructions from:
* [https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/) because I am using Kubeadm

I upgraded from 1.31 over 1.32 to 1.33, we are in mid May 2025, and 1.33 came out recently.

The process was for each upgrade
1. Update repositories
2. Upgrade `kubeadm` from say 1.32 which you are running to 1.33 which is the version you want
3. Run `kubeadm upgrade plan` to check a few tings
4. perform upgrade on controler to the version you want, like `kubeadm upgrade apply v1.33.1`
5. Upgrade software, CRI-O container, kubectl and kubelet etc. just regular apt update/upgrade
6. Do a reboot, controlled, chaotic, whatever :-D

Expected output at the end:
```
hlk@cheese01:~$ k get node
NAME       STATUS   ROLES           AGE    VERSION
cheese01   Ready    control-plane   218d   v1.33.1
cheese02   Ready    <none>          218d   v1.33.1
```


Yes, I run this small setup with only two nodes, and no dedicated control nodes - all nodes can run pods.

## CRI-O upgrades

Installing the packages is quite easy, by specifying the versions you want:
```
KUBERNETES_VERSION=v1.33
CRIO_VERSION=v1.33
```

The following the instructions from the packaging README.md:<br>
[https://github.com/cri-o/packaging/blob/main/README.md](https://github.com/cri-o/packaging/blob/main/README.md)

Add the Kubernetes repository
```

  curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key |
      gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" |
      tee /etc/apt/sources.list.d/kubernetes.list
```
Add the CRI-O repository
```
  curl -fsSL https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/Release.key |
      gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg

  echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/ /" |
      tee /etc/apt/sources.list.d/cri-o.list
```

## Logs

A few logs

Check and *plan* the upgrade, this is with kubeadm version 1.33 installed and 1.32 running:
```
# kubeadm upgrade plan
[preflight] Running pre-flight checks.
[upgrade/config] Reading configuration from the "kubeadm-config" ConfigMap in namespace "kube-system"...
[upgrade/config] Use 'kubeadm init phase upload-config --config your-config-file' to re-upload it.
W0525 20:44:37.362442  833945 configset.go:78] Warning: No kubeproxy.config.k8s.io/v1alpha1 config is loaded. Continuing without it: configmaps "kube-proxy" not found
[upgrade] Running cluster health checks
[upgrade] Fetching available versions to upgrade to
[upgrade/versions] Cluster version: 1.32.5
[upgrade/versions] kubeadm version: v1.33.1
[upgrade/versions] Target version: v1.33.1
[upgrade/versions] Latest version in the v1.32 series: v1.32.5

W0525 20:44:44.068842  833945 configset.go:78] Warning: No kubeproxy.config.k8s.io/v1alpha1 config is loaded. Continuing without it: configmaps "kube-proxy" not found
Components that must be upgraded manually after you have upgraded the control plane with 'kubeadm upgrade apply':
COMPONENT   NODE       CURRENT   TARGET
kubelet     cheese01   v1.32.5   v1.33.1
kubelet     cheese02   v1.32.5   v1.33.1

Upgrade to the latest stable version:

COMPONENT                 NODE       CURRENT    TARGET
kube-apiserver            cheese01   v1.32.5    v1.33.1
kube-controller-manager   cheese01   v1.32.5    v1.33.1
kube-scheduler            cheese01   v1.32.5    v1.33.1
kube-proxy                           1.32.5     v1.33.1
CoreDNS                              v1.11.3    v1.12.0
etcd                      cheese01   3.5.16-0   3.5.21-0

You can now apply the upgrade by executing the following command:

	kubeadm upgrade apply v1.33.1

_____________________________________________________________________


The table below shows the current state of component configs as understood by this version of kubeadm.
Configs that have a "yes" mark in the "MANUAL UPGRADE REQUIRED" column require manual config upgrade or
resetting to kubeadm defaults before a successful upgrade can be performed. The version to manually
upgrade to is denoted in the "PREFERRED VERSION" column.

API GROUP                 CURRENT VERSION   PREFERRED VERSION   MANUAL UPGRADE REQUIRED
kubeproxy.config.k8s.io   -                 v1alpha1            no
kubelet.config.k8s.io     v1beta1           v1beta1             no
_____________________________________________________________________
```

Performing the control node upgrade:
```
# kubeadm upgrade apply v1.33.1
[upgrade] Reading configuration from the "kubeadm-config" ConfigMap in namespace "kube-system"...
[upgrade] Use 'kubeadm init phase upload-config --config your-config-file' to re-upload it.
W0525 20:45:25.889642  833956 configset.go:78] Warning: No kubeproxy.config.k8s.io/v1alpha1 config is loaded. Continuing without it: configmaps "kube-proxy" not found
[upgrade/preflight] Running preflight checks
[upgrade] Running cluster health checks
[upgrade/preflight] You have chosen to upgrade the cluster version to "v1.33.1"
[upgrade/versions] Cluster version: v1.32.5
[upgrade/versions] kubeadm version: v1.33.1
[upgrade] Are you sure you want to proceed? [y/N]: y
[upgrade/preflight] Pulling images required for setting up a Kubernetes cluster
[upgrade/preflight] This might take a minute or two, depending on the speed of your internet connection
[upgrade/preflight] You can also perform this action beforehand using 'kubeadm config images pull'
[upgrade/control-plane] Upgrading your static Pod-hosted control plane to version "v1.33.1" (timeout: 5m0s)...
[upgrade/staticpods] Writing new Static Pod manifests to "/etc/kubernetes/tmp/kubeadm-upgraded-manifests543074948"
[upgrade/staticpods] Preparing for "etcd" upgrade
[upgrade/staticpods] Renewing etcd-server certificate
[upgrade/staticpods] Renewing etcd-peer certificate
[upgrade/staticpods] Renewing etcd-healthcheck-client certificate
[upgrade/staticpods] Moving new manifest to "/etc/kubernetes/manifests/etcd.yaml" and backing up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2025-05-25-20-45-52/etcd.yaml"
[upgrade/staticpods] Waiting for the kubelet to restart the component
[upgrade/staticpods] This can take up to 5m0s
[apiclient] Found 1 Pods for label selector component=etcd
[upgrade/staticpods] Component "etcd" upgraded successfully!
[upgrade/etcd] Waiting for etcd to become available
[upgrade/staticpods] Preparing for "kube-apiserver" upgrade
[upgrade/staticpods] Renewing apiserver certificate
[upgrade/staticpods] Renewing apiserver-kubelet-client certificate
[upgrade/staticpods] Renewing front-proxy-client certificate
[upgrade/staticpods] Renewing apiserver-etcd-client certificate
[upgrade/staticpods] Moving new manifest to "/etc/kubernetes/manifests/kube-apiserver.yaml" and backing up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2025-05-25-20-45-52/kube-apiserver.yaml"
[upgrade/staticpods] Waiting for the kubelet to restart the component
[upgrade/staticpods] This can take up to 5m0s
[apiclient] Found 1 Pods for label selector component=kube-apiserver
[upgrade/staticpods] Component "kube-apiserver" upgraded successfully!
[upgrade/staticpods] Preparing for "kube-controller-manager" upgrade
[upgrade/staticpods] Renewing controller-manager.conf certificate
[upgrade/staticpods] Moving new manifest to "/etc/kubernetes/manifests/kube-controller-manager.yaml" and backing up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2025-05-25-20-45-52/kube-controller-manager.yaml"
[upgrade/staticpods] Waiting for the kubelet to restart the component
[upgrade/staticpods] This can take up to 5m0s
[apiclient] Found 1 Pods for label selector component=kube-controller-manager
[upgrade/staticpods] Component "kube-controller-manager" upgraded successfully!
[upgrade/staticpods] Preparing for "kube-scheduler" upgrade
[upgrade/staticpods] Renewing scheduler.conf certificate
[upgrade/staticpods] Moving new manifest to "/etc/kubernetes/manifests/kube-scheduler.yaml" and backing up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2025-05-25-20-45-52/kube-scheduler.yaml"
[upgrade/staticpods] Waiting for the kubelet to restart the component
[upgrade/staticpods] This can take up to 5m0s
[apiclient] Found 1 Pods for label selector component=kube-scheduler
[upgrade/staticpods] Component "kube-scheduler" upgraded successfully!
[upgrade/control-plane] The control plane instance for this node was successfully upgraded!
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
[upgrade/kubeconfig] The kubeconfig files for this node were successfully upgraded!
W0525 20:48:50.565503  833956 postupgrade.go:117] Using temporary directory /etc/kubernetes/tmp/kubeadm-kubelet-config3246343065 for kubelet config. To override it set the environment variable KUBEADM_UPGRADE_DRYRUN_DIR
[upgrade] Backing up kubelet config file to /etc/kubernetes/tmp/kubeadm-kubelet-config3246343065/config.yaml
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[upgrade/kubelet-config] The kubelet configuration for this node was successfully upgraded!
[upgrade/bootstrap-token] Configuring bootstrap token and cluster-info RBAC rules
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[addons] Applied essential addon: CoreDNS
[upgrade/addon] Skipping the addon/kube-proxy phase. The addon is disabled.

[upgrade] SUCCESS! A control plane node of your cluster was upgraded to "v1.33.1".

[upgrade] Now please proceed with upgrading the rest of the nodes by following the right order.
```

Software upgrading, expect the new version of the repositories to be in place:
```
#  apt upgrade
  Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
Calculating upgrade... Done
The following packages will be upgraded:
  cri-o cri-tools kubectl kubelet
4 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
Need to get 66.5 MB of archives.
After this operation, 13.2 MB of additional disk space will be used.
Get:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.33/deb  cri-tools 1.33.0-1.1 [17.3 MB]
Get:2 https://ftp.gwdg.de/pub/opensuse/repositories/isv%3A/cri-o%3A/stable%3A/v1.33/deb  cri-o 1.33.0-2.1 [21.6 MB]
Get:3 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.33/deb  kubectl 1.33.1-1.1 [11.7 MB]
Get:4 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.33/deb  kubelet 1.33.1-1.1 [15.9 MB]
Fetched 66.5 MB in 1s (76.9 MB/s)                           
apt-listchanges: Reading changelogs...
(Reading database ... 37844 files and directories currently installed.)
Preparing to unpack .../cri-o_1.33.0-2.1_amd64.deb ...
Unpacking cri-o (1.33.0-2.1) over (1.32.1-1.1) ...
Preparing to unpack .../cri-tools_1.33.0-1.1_amd64.deb ...
Unpacking cri-tools (1.33.0-1.1) over (1.32.0-1.1) ...
Preparing to unpack .../kubectl_1.33.1-1.1_amd64.deb ...
Unpacking kubectl (1.33.1-1.1) over (1.32.5-1.1) ...
Preparing to unpack .../kubelet_1.33.1-1.1_amd64.deb ...
Unpacking kubelet (1.33.1-1.1) over (1.32.5-1.1) ...
Setting up cri-o (1.33.0-2.1) ...
Setting up kubectl (1.33.1-1.1) ...
Setting up cri-tools (1.33.0-1.1) ...
Setting up kubelet (1.33.1-1.1) ...
Processing triggers for man-db (2.11.2-2) ...
```
