
```
+----------------------+--------+---------------+---------+----------------+--------------+
|          ID          |  NAME  |    ZONE ID    | STATUS  |  EXTERNAL IP   | INTERNAL IP  |
+----------------------+--------+---------------+---------+----------------+--------------+
| epd190k27lictjkbr0si | wnode1 | ru-central1-b | RUNNING | 51.250.108.183 | 192.168.0.14 |
| epdd4t0ugtn3hb8us5cj | wnode2 | ru-central1-b | RUNNING | 51.250.98.241  | 192.168.0.12 |
| epdvkug6tpn4f7cndoqg | cp1    | ru-central1-b | RUNNING | 51.250.96.160  | 192.168.0.16 |
+----------------------+--------+---------------+---------+----------------+--------------+

```

настройка кластера:

```
sudo apt-get update && sudo apt-get install git mc python3-pip
cd .ssh/
chmod 600 id_rsa
ls -la
clear
cd
ssh yc-user@192.168.0.14
ssh yc-user@192.168.0.12
ssh yc-user@192.168.0.16

git clone https://github.com/kubernetes-sigs/kubespray
cd kubespray/
sudo pip3 install -r requirements.txt
cp -rfp inventory/sample inventory/mycluster
declare -a IPS=(192.168.0.14 192.168.0.12 192.168.0.16)
CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
cd inventory/mycluster/

cat hosts.yaml 
all:
  hosts:
    node1:
      ansible_host: 192.168.0.14
      ip: 192.168.0.14
      access_ip: 192.168.0.14
      ansible_user: yc-user
    node2:
      ansible_host: 192.168.0.12
      ip: 192.168.0.12
      access_ip: 192.168.0.12
      ansible_user: yc-user
    node3:
      ansible_host: 192.168.0.16
      ip: 192.168.0.16
      access_ip: 192.168.0.16
      ansible_user: yc-user
  children:
    kube_control_plane:
      hosts:
        cp1:
    kube_node:
      hosts:
        node1:
        node2:
    etcd:
      hosts:
        cp1:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}

```

```
yc-user@cp1:~/kubespray$ history 
ansible-playbook -i inventory/mycluster/hosts.yaml cluster.yml -b -v
{     mkdir -p $HOME/.kube;     sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config;     sudo chown $(id -u):$(id -g) $HOME/.kube/config; }
kubectl get pods -n kube-system
kubectl get nodes

```

```
PLAY RECAP *******************************************************************************************************************************************************************************************************************************************************************************
cp1                        : ok=713  changed=139  unreachable=0    failed=0    skipped=1239 rescued=0    ignored=9   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
node1                      : ok=477  changed=88   unreachable=0    failed=0    skipped=742  rescued=0    ignored=2   
node2                      : ok=477  changed=88   unreachable=0    failed=0    skipped=741  rescued=0    ignored=2   

Sunday 11 September 2022  19:55:25 +0000 (0:00:00.075)       0:18:38.003 ****** 
=============================================================================== 
download : download_file | Validate mirrors -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 78.61s
download : download_container | Download image if required ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 64.33s
network_plugin/calico : Wait for calico kubeconfig to be created ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 57.76s
kubernetes/preinstall : Install packages requirements ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 47.52s
kubernetes/kubeadm : Join to cluster --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 38.64s
kubernetes/control-plane : kubeadm | Initialize first master --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 36.54s
download : download_container | Download image if required ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 33.22s
download : download_container | Download image if required ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 30.67s
download : download_file | Validate mirrors -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 27.06s
download : download_container | Download image if required ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 25.25s
download : download_container | Download image if required ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 21.22s
download : download_container | Download image if required ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 20.84s
download : download_container | Download image if required ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 18.52s
download : download_container | Download image if required ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 18.22s
download : download_container | Download image if required ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 16.94s
download : download_file | Validate mirrors -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 16.35s
kubernetes-apps/ansible : Kubernetes Apps | Start Resources ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 16.27s
kubernetes/preinstall : Update package management cache (APT) -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 12.58s
download : download_container | Remove container image from cache ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 10.01s
kubernetes/node : install | Copy kubelet binary from download dir ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 8.69s
yc-user@cp1:~/kubespray$ kubectl get nodes
The connection to the server localhost:8080 was refused - did you specify the right host or port?
yc-user@cp1:~/kubespray$ {     mkdir -p $HOME/.kube;     sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config;     sudo chown $(id -u):$(id -g) $HOME/.kube/config; }
yc-user@cp1:~/kubespray$ kubectl get nodes
NAME    STATUS   ROLES           AGE   VERSION
cp1     Ready    control-plane   16m   v1.24.4
node1   Ready    <none>          15m   v1.24.4
node2   Ready    <none>          15m   v1.24.4
yc-user@cp1:~/kubespray$ kubectl get nodes -o wide
NAME    STATUS   ROLES           AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
cp1     Ready    control-plane   40m   v1.24.4   192.168.0.16   <none>        Ubuntu 20.04.4 LTS   5.4.0-124-generic   containerd://1.6.8
node1   Ready    <none>          39m   v1.24.4   192.168.0.14   <none>        Ubuntu 20.04.4 LTS   5.4.0-124-generic   containerd://1.6.8
node2   Ready    <none>          39m   v1.24.4   192.168.0.12   <none>        Ubuntu 20.04.4 LTS   5.4.0-124-generic   containerd://1.6.8
yc-user@cp1:~/kubespray$ kubectl get netpol -A
No resources found
```


для удобства настроил доступ с локальной машины где установлен calicoctl.

```
iva@c9v:~ $ calicoctl get nodes
Failed to get resources: Version mismatch.
Client Version:   v3.24.1
Cluster Version:  3.23.3
Use --allow-version-mismatch to override.

iva@c9v:~ $ calicoctl get nodes --allow-version-mismatch
NAME    
cp1     
node1   
node2   

```