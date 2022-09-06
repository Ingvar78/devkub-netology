
```
+----------------------+-------+---------------+---------+---------------+--------------+
|          ID          | NAME  |    ZONE ID    | STATUS  |  EXTERNAL IP  | INTERNAL IP  |
+----------------------+-------+---------------+---------+---------------+--------------+
| epdevcisdn0kggjlffvu | cp1   | ru-central1-b | RUNNING | 51.250.96.69  | 192.168.0.11 |
| epdh4hn5ic0n82njiuhp | node2 | ru-central1-b | RUNNING | 62.84.121.234 | 192.168.0.21 |
| epdiulpf4j8b0mblsvhp | node1 | ru-central1-b | RUNNING | 51.250.27.141 | 192.168.0.30 |
+----------------------+-------+---------------+---------+---------------+--------------+

iva@c9v:~ $ ssh yc-user@51.250.96.69
Welcome to Ubuntu 20.04.4 LTS (GNU/Linux 5.4.0-124-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
Last login: Tue Sep  6 16:19:17 2022 from 95.31.137.252
yc-user@cp1:~$ {
>     sudo apt-get update
>     sudo apt-get install -y apt-transport-https ca-certificates curl
>     sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
>     echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
>     
>     sudo apt-get update
>     sudo apt-get install -y kubelet kubeadm kubectl containerd
>     sudo apt-mark hold kubelet kubeadm kubectl
> }

....

Processing triggers for man-db (2.9.1-1) ...
kubelet set on hold.
kubeadm set on hold.
kubectl set on hold.
yc-user@cp1:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether d0:0d:ef:b2:5c:6d brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.11/24 brd 192.168.0.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::d20d:efff:feb2:5c6d/64 scope link 
       valid_lft forever preferred_lft forever
yc-user@cp1:~$ sudo su
root@cp1:/home/yc-user# modprobe br_netfilter 
root@cp1:/home/yc-user# echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
root@cp1:/home/yc-user# echo "net.bridge.bridge-nf-call-iptables=1" >> /etc/sysctl.conf
root@cp1:/home/yc-user# echo "net.bridge.bridge-nf-call-arptables=1" >> /etc/sysctl.conf
root@cp1:/home/yc-user# echo "net.bridge.bridge-nf-call-ip6tables=1" >> /etc/sysctl.conf
root@cp1:/home/yc-user# 
root@cp1:/home/yc-user# sysctl -p /etc/sysctl.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-arptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
root@cp1:/home/yc-user# kubeadm init \
>   --apiserver-advertise-address=192.168.0.11 \
>   --pod-network-cidr 10.244.0.0/16 \
>   --apiserver-cert-extra-sans=51.250.96.69
[init] Using Kubernetes version: v1.25.0
[preflight] Running pre-flight checks
...


Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.0.11:6443 --token eiufn1.tftfi62t1dlfeu5f \
    --discovery-token-ca-cert-hash sha256:e764d5cf2bd8b4b96aff8f745cafbf8eaf48702074409e85c1f4702d87a5b858 
root@cp1:/home/yc-user# exit
yc-user@cp1:~$ {
>     mkdir -p $HOME/.kube
>     sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
>     sudo chown $(id -u):$(id -g) $HOME/.kube/config
> }
yc-user@cp1:~$ kubectl get nodes
NAME   STATUS     ROLES           AGE     VERSION
cp1    NotReady   control-plane   2m31s   v1.25.0
yc-user@cp1:~$ kubectl describe nodes cp1 | grep KubeletNotReady
  Ready            False   Tue, 06 Sep 2022 16:28:58 +0000   Tue, 06 Sep 2022 16:28:52 +0000   KubeletNotReady              container runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:Network plugin returns error: cni plugin not initialized
yc-user@cp1:~$ kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
namespace/kube-flannel created
clusterrole.rbac.authorization.k8s.io/flannel created
clusterrolebinding.rbac.authorization.k8s.io/flannel created
serviceaccount/flannel created
configmap/kube-flannel-cfg created
daemonset.apps/kube-flannel-ds created
yc-user@cp1:~$ kubectl get nodes
NAME   STATUS   ROLES           AGE     VERSION
cp1    Ready    control-plane   5m39s   v1.25.0


```

Настраиваем подлючения с локального компа и проверяем

```
iva@c9v:~/.kube $ kubectl get node
NAME   STATUS   ROLES           AGE   VERSION
cp1    Ready    control-plane   10m   v1.25.0

```

настраиваем Worker nodes

```
iva@c9v:~ $ ssh yc-user@62.84.121.234
Welcome to Ubuntu 20.04.4 LTS (GNU/Linux 5.4.0-124-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
Last login: Tue Sep  6 16:20:41 2022 from 95.31.137.252
yc-user@node2:~$ {
>     sudo apt-get update
>     sudo apt-get install -y apt-transport-https ca-certificates curl
>     sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
>     echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
>     
>     sudo apt-get update
>     sudo apt-get install -y kubelet kubeadm kubectl containerd
>     sudo apt-mark hold kubelet kubeadm kubectl
> }
...

kubectl set on hold.
yc-user@node2:~$ ыгвщ ыг
ыгвщ: command not found
yc-user@node2:~$ sudo su
root@node2:/home/yc-user# modprobe br_netfilter 
root@node2:/home/yc-user# echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
root@node2:/home/yc-user# echo "net.bridge.bridge-nf-call-iptables=1" >> /etc/sysctl.conf
root@node2:/home/yc-user# echo "net.bridge.bridge-nf-call-arptables=1" >> /etc/sysctl.conf
root@node2:/home/yc-user# echo "net.bridge.bridge-nf-call-ip6tables=1" >> /etc/sysctl.conf
root@node2:/home/yc-user# 
root@node2:/home/yc-user# sysctl -p /etc/sysctl.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-arptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
root@node2:/home/yc-user# kubeadm join 192.168.0.11:6443 --token eiufn1.tftfi62t1dlfeu5f \
>     --discovery-token-ca-cert-hash sha256:e764d5cf2bd8b4b96aff8f745cafbf8eaf48702074409e85c1f4702d87a5b858
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.

root@node2:/home/yc-user# 


```

Аналогично настраивается и первая нода. Проверяем

```
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2/source  (12.4)$ kubectl get node
NAME    STATUS   ROLES           AGE     VERSION
cp1     Ready    control-plane   17m     v1.25.0
node1   Ready    <none>          2m24s   v1.25.0
node2   Ready    <none>          2m15s   v1.25.0

```

добавим несколько новых worker node в кластер 

+----------------------+-------+---------------+---------+----------------+--------------+
|          ID          | NAME  |    ZONE ID    | STATUS  |  EXTERNAL IP   | INTERNAL IP  |
+----------------------+-------+---------------+---------+----------------+--------------+
| epddv2ik3sda2u56leup | node4 | ru-central1-b | RUNNING | 51.250.109.151 | 192.168.0.13 |
| epdehrg0sahbdqbct8ql | node3 | ru-central1-b | RUNNING | 51.250.24.54   | 192.168.0.25 |
| epdevcisdn0kggjlffvu | cp1   | ru-central1-b | RUNNING | 51.250.96.69   | 192.168.0.11 |
| epdh4hn5ic0n82njiuhp | node2 | ru-central1-b | RUNNING | 62.84.121.234  | 192.168.0.21 |
| epdiulpf4j8b0mblsvhp | node1 | ru-central1-b | RUNNING | 51.250.27.141  | 192.168.0.30 |
+----------------------+-------+---------------+---------+----------------+--------------+


```
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2/source  (12.4)$ kubectl get node
NAME    STATUS     ROLES           AGE   VERSION
cp1     Ready      control-plane   33m   v1.25.0
node1   Ready      <none>          18m   v1.25.0
node2   Ready      <none>          18m   v1.25.0
node3   NotReady   <none>          2s    v1.25.0
node4   NotReady   <none>          21s   v1.25.0

va@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2/source  (12.4)$ kubectl apply -f ./10-usage/templates/20-deployment-main.yaml 
deployment.apps/main created
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2/source  (12.4)$ kubectl get pods
NAME                    READY   STATUS              RESTARTS   AGE
main-54b4695555-5hhbs   0/1     ContainerCreating   0          17s
```

поиграемся с количеством реплик изменяя yaml

```
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2  (12.4)$ 
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2/source  (12.4)$ kubectl apply -f ./10-usage/templates/20-deployment-main.yaml 
deployment.apps/main configured
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2/source  (12.4)$ kubectl get pods
NAME                    READY   STATUS              RESTARTS   AGE
main-54b4695555-5hhbs   1/1     Running             0          79s
main-54b4695555-5wd5m   0/1     ContainerCreating   0          3s
main-54b4695555-dccnx   0/1     ContainerCreating   0          3s
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2/source  (12.4)$ kubectl apply -f ./10-usage/templates/20-deployment-main.yaml 
deployment.apps/main configured
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2/source  (12.4)$ kubectl get pods
NAME                    READY   STATUS    RESTARTS   AGE
main-54b4695555-5hhbs   1/1     Running   0          4m15s
main-54b4695555-5wd5m   1/1     Running   0          2m59s
main-54b4695555-986sz   1/1     Running   0          2m1s
main-54b4695555-dccnx   1/1     Running   0          2m59s
main-54b4695555-dqvmw   1/1     Running   0          2m1s

iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2/source  (12.4)$ kubectl apply -f ./10-usage/templates/20-deployment-main.yaml 
deployment.apps/main configured
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2/source  (12.4)$ kubectl get pods
NAME                    READY   STATUS    RESTARTS   AGE
main-54b4695555-5wd5m   1/1     Running   0          3m42s
main-54b4695555-dccnx   1/1     Running   0          3m42s

```

```
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2/source  (12.4)$ kubectl create ns netology
namespace/netology created
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2/source  (12.4)$ kubectl apply -f ./10-usage/templates/21-deployment-resizer.yaml 
deployment.apps/resizer created
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2/source  (12.4)$ kubectl get pods
NAME                    READY   STATUS    RESTARTS   AGE
main-54b4695555-5wd5m   1/1     Running   0          6m22s
main-54b4695555-dccnx   1/1     Running   0          6m22s
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2/source  (12.4)$ kubectl get pods -A -o wide
NAMESPACE      NAME                          READY   STATUS    RESTARTS   AGE    IP             NODE    NOMINATED NODE   READINESS GATES
default        main-54b4695555-5wd5m         1/1     Running   0          7m5s   10.244.2.2     node2   <none>           <none>
default        main-54b4695555-dccnx         1/1     Running   0          7m5s   10.244.1.2     node1   <none>           <none>
kube-flannel   kube-flannel-ds-2jmlb         1/1     Running   0          36m    192.168.0.30   node1   <none>           <none>
kube-flannel   kube-flannel-ds-44pbt         1/1     Running   0          17m    192.168.0.13   node4   <none>           <none>
kube-flannel   kube-flannel-ds-7rqdd         1/1     Running   0          46m    192.168.0.11   cp1     <none>           <none>
kube-flannel   kube-flannel-ds-tcpl5         1/1     Running   0          35m    192.168.0.21   node2   <none>           <none>
kube-flannel   kube-flannel-ds-xgh29         1/1     Running   0          17m    192.168.0.25   node3   <none>           <none>
kube-system    coredns-565d847f94-66fgx      1/1     Running   0          50m    10.244.0.2     cp1     <none>           <none>
kube-system    coredns-565d847f94-ggxgs      1/1     Running   0          50m    10.244.0.3     cp1     <none>           <none>
kube-system    etcd-cp1                      1/1     Running   0          50m    192.168.0.11   cp1     <none>           <none>
kube-system    kube-apiserver-cp1            1/1     Running   0          50m    192.168.0.11   cp1     <none>           <none>
kube-system    kube-controller-manager-cp1   1/1     Running   0          50m    192.168.0.11   cp1     <none>           <none>
kube-system    kube-proxy-67qvg              1/1     Running   0          50m    192.168.0.11   cp1     <none>           <none>
kube-system    kube-proxy-9b5t2              1/1     Running   0          36m    192.168.0.30   node1   <none>           <none>
kube-system    kube-proxy-9n46w              1/1     Running   0          17m    192.168.0.25   node3   <none>           <none>
kube-system    kube-proxy-kskxl              1/1     Running   0          35m    192.168.0.21   node2   <none>           <none>
kube-system    kube-proxy-pcsv2              1/1     Running   0          17m    192.168.0.13   node4   <none>           <none>
kube-system    kube-scheduler-cp1            1/1     Running   0          50m    192.168.0.11   cp1     <none>           <none>
netology       resizer-54c4ccc55f-pwdc5      1/1     Running   0          46s    10.244.3.4     node4   <none>           <none>
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2/source  (12.4)$ kubectl config get-contexts
CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
*         kubernetes-admin@kubernetes   kubernetes   kubernetes-admin  
```

удалим две ноды из кластера и посмотрим что произойдёт

```
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2/source/99-misc  (12.4)$ ./delete-vms-2.sh 
...1s...6s...12s...17s...22s...28s...33s...39s...44s...done (49s)
...1s...6s...11s...16s...22s...27s...32s...38s...43s...48s...done (53s)
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2/source/99-misc  (12.4)$ ./list-vms.sh 
+----------------------+-------+---------------+---------+---------------+--------------+
|          ID          | NAME  |    ZONE ID    | STATUS  |  EXTERNAL IP  | INTERNAL IP  |
+----------------------+-------+---------------+---------+---------------+--------------+
| epdevcisdn0kggjlffvu | cp1   | ru-central1-b | RUNNING | 51.250.96.69  | 192.168.0.11 |
| epdh4hn5ic0n82njiuhp | node2 | ru-central1-b | RUNNING | 62.84.121.234 | 192.168.0.21 |
| epdiulpf4j8b0mblsvhp | node1 | ru-central1-b | RUNNING | 51.250.27.141 | 192.168.0.30 |
+----------------------+-------+---------------+---------+---------------+--------------+

iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2/source/99-misc  (12.4)$ kubectl get pods
NAME                    READY   STATUS    RESTARTS   AGE
main-54b4695555-5wd5m   1/1     Running   0          20m
main-54b4695555-dccnx   1/1     Running   0          20m
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2/source/99-misc  (12.4)$ kubectl get nodes
NAME    STATUS     ROLES           AGE   VERSION
cp1     Ready      control-plane   64m   v1.25.0
node1   Ready      <none>          50m   v1.25.0
node2   Ready      <none>          49m   v1.25.0
node3   NotReady   <none>          31m   v1.25.0
node4   NotReady   <none>          31m   v1.25.0

iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2/source  (12.4)$ kubectl drain node4 --ignore-daemonsets --delete-local-data
Flag --delete-local-data has been deprecated, This option is deprecated and will be deleted. Use --delete-emptydir-data.
node/node4 already cordoned
WARNING: ignoring DaemonSet-managed Pods: kube-flannel/kube-flannel-ds-44pbt, kube-system/kube-proxy-pcsv2
evicting pod netology/resizer-54c4ccc55f-pwdc5
^C
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2/source  (12.4)$ kubectl delete node node4
node "node4" deleted
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2/source  (12.4)$ kubectl get nodes 
NAME    STATUS     ROLES           AGE   VERSION
cp1     Ready      control-plane   73m   v1.25.0
node1   Ready      <none>          58m   v1.25.0
node2   Ready      <none>          58m   v1.25.0
node3   NotReady   <none>          40m   v1.25.0
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2/source  (12.4)$ kubectl delete node node3
node "node3" deleted
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2/source  (12.4)$ kubectl get pods -A -o wide
NAMESPACE      NAME                          READY   STATUS        RESTARTS   AGE     IP             NODE    NOMINATED NODE   READINESS GATES
default        main-54b4695555-5wd5m         1/1     Running       0          30m     10.244.2.2     node2   <none>           <none>
default        main-54b4695555-dccnx         1/1     Running       0          30m     10.244.1.2     node1   <none>           <none>
kube-flannel   kube-flannel-ds-2jmlb         1/1     Running       0          59m     192.168.0.30   node1   <none>           <none>
kube-flannel   kube-flannel-ds-44pbt         1/1     Running       0          40m     192.168.0.13   node4   <none>           <none>
kube-flannel   kube-flannel-ds-7rqdd         1/1     Running       0          69m     192.168.0.11   cp1     <none>           <none>
kube-flannel   kube-flannel-ds-tcpl5         1/1     Running       0          59m     192.168.0.21   node2   <none>           <none>
kube-flannel   kube-flannel-ds-xgh29         1/1     Running       0          40m     192.168.0.25   node3   <none>           <none>
kube-system    coredns-565d847f94-66fgx      1/1     Running       0          73m     10.244.0.2     cp1     <none>           <none>
kube-system    coredns-565d847f94-ggxgs      1/1     Running       0          73m     10.244.0.3     cp1     <none>           <none>
kube-system    etcd-cp1                      1/1     Running       0          74m     192.168.0.11   cp1     <none>           <none>
kube-system    kube-apiserver-cp1            1/1     Running       0          74m     192.168.0.11   cp1     <none>           <none>
kube-system    kube-controller-manager-cp1   1/1     Running       0          74m     192.168.0.11   cp1     <none>           <none>
kube-system    kube-proxy-67qvg              1/1     Running       0          73m     192.168.0.11   cp1     <none>           <none>
kube-system    kube-proxy-9b5t2              1/1     Running       0          59m     192.168.0.30   node1   <none>           <none>
kube-system    kube-proxy-9n46w              1/1     Running       0          40m     192.168.0.25   node3   <none>           <none>
kube-system    kube-proxy-kskxl              1/1     Running       0          59m     192.168.0.21   node2   <none>           <none>
kube-system    kube-proxy-pcsv2              1/1     Running       0          40m     192.168.0.13   node4   <none>           <none>
kube-system    kube-scheduler-cp1            1/1     Running       0          74m     192.168.0.11   cp1     <none>           <none>
netology       resizer-54c4ccc55f-2485w      1/1     Running       0          4m44s   10.244.2.3     node2   <none>           <none>
netology       resizer-54c4ccc55f-pwdc5      1/1     Terminating   0          24m     10.244.3.4     node4   <none>           <none>
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2/source  (12.4)$ kubectl get pods -A -o wide
NAMESPACE      NAME                          READY   STATUS    RESTARTS   AGE     IP             NODE    NOMINATED NODE   READINESS GATES
default        main-54b4695555-5wd5m         1/1     Running   0          31m     10.244.2.2     node2   <none>           <none>
default        main-54b4695555-dccnx         1/1     Running   0          31m     10.244.1.2     node1   <none>           <none>
kube-flannel   kube-flannel-ds-2jmlb         1/1     Running   0          61m     192.168.0.30   node1   <none>           <none>
kube-flannel   kube-flannel-ds-7rqdd         1/1     Running   0          71m     192.168.0.11   cp1     <none>           <none>
kube-flannel   kube-flannel-ds-tcpl5         1/1     Running   0          60m     192.168.0.21   node2   <none>           <none>
kube-system    coredns-565d847f94-66fgx      1/1     Running   0          75m     10.244.0.2     cp1     <none>           <none>
kube-system    coredns-565d847f94-ggxgs      1/1     Running   0          75m     10.244.0.3     cp1     <none>           <none>
kube-system    etcd-cp1                      1/1     Running   0          75m     192.168.0.11   cp1     <none>           <none>
kube-system    kube-apiserver-cp1            1/1     Running   0          75m     192.168.0.11   cp1     <none>           <none>
kube-system    kube-controller-manager-cp1   1/1     Running   0          75m     192.168.0.11   cp1     <none>           <none>
kube-system    kube-proxy-67qvg              1/1     Running   0          75m     192.168.0.11   cp1     <none>           <none>
kube-system    kube-proxy-9b5t2              1/1     Running   0          61m     192.168.0.30   node1   <none>           <none>
kube-system    kube-proxy-kskxl              1/1     Running   0          60m     192.168.0.21   node2   <none>           <none>
kube-system    kube-scheduler-cp1            1/1     Running   0          75m     192.168.0.11   cp1     <none>           <none>
netology       resizer-54c4ccc55f-2485w      1/1     Running   0          6m17s   10.244.2.3     node2   <none>           <none>

```