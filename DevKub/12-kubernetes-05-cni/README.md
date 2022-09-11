# Домашнее задание к занятию "12.5 Сетевые решения CNI"
После работы с Flannel появилась необходимость обеспечить безопасность для приложения. Для этого лучше всего подойдет Calico.
## Задание 1: установить в кластер CNI плагин Calico
Для проверки других сетевых решений стоит поставить отличный от Flannel плагин — например, Calico. Требования: 
* установка производится через ansible/kubespray;
* после применения следует настроить политику доступа к hello-world извне. Инструкции [kubernetes.io](https://kubernetes.io/docs/concepts/services-networking/network-policies/), [Calico](https://docs.projectcalico.org/about/about-network-policy)

--------------

Кластер разворачивался по аналогии с предыдущим ДЗ, так же настроено взаимодействие с локального хоста.

1) Создаем неймспейс

iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-05-cni  (12.5 *)$ kubectl create ns netology-ns
namespace/netology-ns created

2) Используя шаблоны из "kubernetes-for-beginners/16-networking/20-network-policy/" развертываем 3 деплоймента, предварительно поменяв неймспейс на netology-ns

```
iva@c9v:~/Documents/DevKub/kubernetes-for-beginners/16-networking/20-network-policy  (master *)$ kubectl apply -f ./manifests/main/
deployment.apps/frontend created
service/frontend created
deployment.apps/backend created
service/backend created
deployment.apps/cache created
service/cache created
iva@c9v:~/Documents/DevKub/kubernetes-for-beginners/16-networking/20-network-policy  (master *)$ kubectl get pods --namespace=netology-ns
NAME                       READY   STATUS    RESTARTS   AGE
backend-869fd89bdc-hcqwj   1/1     Running   0          25s
cache-b7cbd9f8f-q4fnf      1/1     Running   0          25s
frontend-c74c5646c-blxnz   1/1     Running   0          25s

iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-05-cni  (12.5 *)$ kubectl config set-context --current --namespace=netology-ns
Context "kubernetes-admin@cluster.local" modified.

iva@c9v:~/Documents/DevKub/kubernetes-for-beginners/16-networking/20-network-policy  (master *)$  kubectl config get-contexts
CURRENT   NAME                             CLUSTER         AUTHINFO           NAMESPACE
*         kubernetes-admin@cluster.local   cluster.local   kubernetes-admin   netology-ns
iva@c9v:~/Documents/DevKub/kubernetes-for-beginners/16-networking/20-network-policy  (master *)$ kubectl get nodes
NAME    STATUS   ROLES           AGE   VERSION
cp1     Ready    control-plane   87m   v1.24.4
node1   Ready    <none>          86m   v1.24.4
node2   Ready    <none>          86m   v1.24.4
iva@c9v:~/Documents/DevKub/kubernetes-for-beginners/16-networking/20-network-policy  (master *)$ kubectl get pods
NAME                       READY   STATUS    RESTARTS   AGE
backend-869fd89bdc-hcqwj   1/1     Running   0          5m11s
cache-b7cbd9f8f-q4fnf      1/1     Running   0          5m11s
frontend-c74c5646c-blxnz   1/1     Running   0          5m11s

```

3) Выполним проверку доступов между подами

```
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-05-cni  (12.5 *)$ kubectl exec backend-869fd89bdc-hcqwj -- curl -s -m 1 cache
Praqma Network MultiTool (with NGINX) - cache-b7cbd9f8f-q4fnf - 10.233.75.2
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-05-cni  (12.5 *)$ kubectl exec backend-869fd89bdc-hcqwj -- curl -s -m 1 frontend
Praqma Network MultiTool (with NGINX) - frontend-c74c5646c-blxnz - 10.233.75.1
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-05-cni  (12.5 *)$ kubectl exec backend-869fd89bdc-hcqwj -- curl -s -m 1 backend
Praqma Network MultiTool (with NGINX) - backend-869fd89bdc-hcqwj - 10.233.102.130
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-05-cni  (12.5 *)$ kubectl exec cache-b7cbd9f8f-q4fnf -- curl -s -m 1 backend
Praqma Network MultiTool (with NGINX) - backend-869fd89bdc-hcqwj - 10.233.102.130
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-05-cni  (12.5 *)$ kubectl exec cache-b7cbd9f8f-q4fnf -- curl -s -m 1 cach
command terminated with exit code 6
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-05-cni  (12.5 *)$ kubectl exec cache-b7cbd9f8f-q4fnf -- curl -s -m 1 cache
Praqma Network MultiTool (with NGINX) - cache-b7cbd9f8f-q4fnf - 10.233.75.2
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-05-cni  (12.5 *)$ kubectl exec cache-b7cbd9f8f-q4fnf -- curl -s -m 1 frontend
Praqma Network MultiTool (with NGINX) - frontend-c74c5646c-blxnz - 10.233.75.1
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-05-cni  (12.5 *)$ 

```

4) применяем политику запрета ingress, выполним проверку доступности, трафик должен быть заблокирован.

```
iva@c9v:~/Documents/DevKub/kubernetes-for-beginners/16-networking/20-network-policy  (master *)$ kubectl apply -f manifests/network-policy/00-default.yaml
networkpolicy.networking.k8s.io/default-deny-ingress created
iva@c9v:~/Documents/DevKub/kubernetes-for-beginners/16-networking/20-network-policy  (master *)$ 
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-05-cni  (12.5 *)$ kubectl exec cache-b7cbd9f8f-q4fnf -- curl -s -m 1 frontend
command terminated with exit code 28
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-05-cni  (12.5 *)$ kubectl exec cache-b7cbd9f8f-q4fnf -- curl -s -m 1 cache
command terminated with exit code 28
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-05-cni  (12.5 *)$ kubectl exec backend-869fd89bdc-hcqwj -- curl -s -m 1 backend
command terminated with exit code 28
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-05-cni  (12.5 *)$ kubectl exec backend-869fd89bdc-hcqwj -- curl -s -m 1 cache
command terminated with exit code 28
```

4) Удаляем ранее добавленную политику, доступность должна восстановиться, трафик должен разблокироваться

```
iva@c9v:~/Documents/DevKub/kubernetes-for-beginners/16-networking/20-network-policy  (master *)$ kubectl delete networkpolicy default-deny-ingress
networkpolicy.networking.k8s.io "default-deny-ingress" deleted
iva@c9v:~/Documents/DevKub/kubernetes-for-beginners/16-networking/20-network-policy  (master *)$ kubectl get networkpolicy
No resources found in netology-ns namespace.
iva@c9v:~/Documents/DevKub/kubernetes-for-beginners/16-networking/20-network-policy  (master *)$ kubectl exec backend-869fd89bdc-hcqwj -- curl -s -m 1 cache
Praqma Network MultiTool (with NGINX) - cache-b7cbd9f8f-q4fnf - 10.233.75.2
iva@c9v:~/Documents/DevKub/kubernetes-for-beginners/16-networking/20-network-policy  (master *)$ kubectl exec backend-869fd89bdc-hcqwj -- curl -s -m 1 backend
Praqma Network MultiTool (with NGINX) - backend-869fd89bdc-hcqwj - 10.233.102.130
iva@c9v:~/Documents/DevKub/kubernetes-for-beginners/16-networking/20-network-policy  (master *)$ kubectl exec cache-b7cbd9f8f-q4fnf -- curl -s -m 1 frontend
Praqma Network MultiTool (with NGINX) - frontend-c74c5646c-blxnz - 10.233.75.1

```


5) Применим все политики, предварительно не забыв поменять нэймспэйс,  после чего должны получить следующую доступность:
    Будут доступны поды только по нашей схеме.
    - frontend -> backend
    - backend -> cache

проверяем:

```
iva@c9v:~/Documents/DevKub/kubernetes-for-beginners/16-networking/20-network-policy  (master *)$ kubectl apply -f manifests/network-policy
networkpolicy.networking.k8s.io/default-deny-ingress created
networkpolicy.networking.k8s.io/frontend created
networkpolicy.networking.k8s.io/backend created
networkpolicy.networking.k8s.io/cache created
iva@c9v:~/Documents/DevKub/kubernetes-for-beginners/16-networking/20-network-policy  (master *)$ kubectl exec cache-b7cbd9f8f-q4fnf -- curl -s -m 1 frontend
command terminated with exit code 28
iva@c9v:~/Documents/DevKub/kubernetes-for-beginners/16-networking/20-network-policy  (master *)$ kubectl exec cache-b7cbd9f8f-q4fnf -- curl -s -m 1 backend
command terminated with exit code 28
iva@c9v:~/Documents/DevKub/kubernetes-for-beginners/16-networking/20-network-policy  (master *)$ kubectl exec cache-b7cbd9f8f-q4fnf -- curl -s -m 1 cache
command terminated with exit code 28
iva@c9v:~/Documents/DevKub/kubernetes-for-beginners/16-networking/20-network-policy/manifests  (master *)$ 
iva@c9v:~/Documents/DevKub/kubernetes-for-beginners/16-networking/20-network-policy  (master *)$ kubectl apply -f manifests/network-policy
networkpolicy.networking.k8s.io/default-deny-ingress unchanged
networkpolicy.networking.k8s.io/frontend created
networkpolicy.networking.k8s.io/backend created
networkpolicy.networking.k8s.io/cache created
iva@c9v:~/Documents/DevKub/kubernetes-for-beginners/16-networking/20-network-policy  (master *)$ kubectl get networkpolicy
NAME                   POD-SELECTOR   AGE
backend                app=backend    3s
cache                  app=cache      3s
default-deny-ingress   <none>         10m
frontend               app=frontend   3s

iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-05-cni  (12.5 *)$ kubectl exec backend-869fd89bdc-hcqwj -- curl -s -m 1 frontend
command terminated with exit code 28
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-05-cni  (12.5 *)$ kubectl exec backend-869fd89bdc-hcqwj -- curl -s -m 1 cache
Praqma Network MultiTool (with NGINX) - cache-b7cbd9f8f-q4fnf - 10.233.75.2
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-05-cni  (12.5 *)$ kubectl exec backend-869fd89bdc-hcqwj -- curl -s -m 1 backend
command terminated with exit code 28


iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-05-cni  (12.5 *)$ kubectl exec frontend-c74c5646c-blxnz -- curl -s -m 1 frontend
command terminated with exit code 28
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-05-cni  (12.5 *)$ kubectl exec frontend-c74c5646c-blxnz -- curl -s -m 1 cache
command terminated with exit code 28
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-05-cni  (12.5 *)$ kubectl exec frontend-c74c5646c-blxnz -- curl -s -m 1 backend
Praqma Network MultiTool (with NGINX) - backend-869fd89bdc-hcqwj - 10.233.102.130

iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-05-cni  (12.5 *)$ kubectl exec cache-b7cbd9f8f-q4fnf -- curl -s -m 1 frontend
command terminated with exit code 28
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-05-cni  (12.5 *)$ kubectl exec cache-b7cbd9f8f-q4fnf -- curl -s -m 1 cache
command terminated with exit code 28
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-05-cni  (12.5 *)$ kubectl exec cache-b7cbd9f8f-q4fnf -- curl -s -m 1 backend
command terminated with exit code 28

```


## Задание 2: изучить, что запущено по умолчанию
Самый простой способ — проверить командой calicoctl get <type>. Для проверки стоит получить список нод, ipPool и profile.
Требования: 
* установить утилиту calicoctl;
* получить 3 вышеописанных типа в консоли.

из-за несоответсвия текущей (локальной версии) и используемой при развёртывании кластера необходимо указывать дополнительный ключ --allow-version-mismatch

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

```
iva@c9v:~ $ calicoctl get profile --allow-version-mismatch
NAME                                                 
projectcalico-default-allow                          
kns.default                                          
kns.kube-node-lease                                  
kns.kube-public                                      
kns.kube-system                                      
ksa.default.default                                  
ksa.kube-node-lease.default                          
ksa.kube-public.default                              
ksa.kube-system.attachdetach-controller              
ksa.kube-system.bootstrap-signer                     
ksa.kube-system.calico-node                          
ksa.kube-system.certificate-controller               
ksa.kube-system.clusterrole-aggregation-controller   
ksa.kube-system.coredns                              
ksa.kube-system.cronjob-controller                   
ksa.kube-system.daemon-set-controller                
ksa.kube-system.default                              
ksa.kube-system.deployment-controller                
ksa.kube-system.disruption-controller                
ksa.kube-system.dns-autoscaler                       
ksa.kube-system.endpoint-controller                  
ksa.kube-system.endpointslice-controller             
ksa.kube-system.endpointslicemirroring-controller    
ksa.kube-system.ephemeral-volume-controller          
ksa.kube-system.expand-controller                    
ksa.kube-system.generic-garbage-collector            
ksa.kube-system.horizontal-pod-autoscaler            
ksa.kube-system.job-controller                       
ksa.kube-system.kube-proxy                           
ksa.kube-system.namespace-controller                 
ksa.kube-system.node-controller                      
ksa.kube-system.nodelocaldns                         
ksa.kube-system.persistent-volume-binder             
ksa.kube-system.pod-garbage-collector                
ksa.kube-system.pv-protection-controller             
ksa.kube-system.pvc-protection-controller            
ksa.kube-system.replicaset-controller                
ksa.kube-system.replication-controller               
ksa.kube-system.resourcequota-controller             
ksa.kube-system.root-ca-cert-publisher               
ksa.kube-system.service-account-controller           
ksa.kube-system.service-controller                   
ksa.kube-system.statefulset-controller               
ksa.kube-system.token-cleaner                        
ksa.kube-system.ttl-after-finished-controller        
ksa.kube-system.ttl-controller                       

iva@c9v:~ $ calicoctl get nodes -o wide --allow-version-mismatch
NAME    ASN       IPV4              IPV6   
cp1     (64512)   192.168.0.16/24          
node1   (64512)   192.168.0.14/24          
node2   (64512)   192.168.0.12/24          

iva@c9v:~ $ calicoctl get ipPool --allow-version-mismatch
NAME           CIDR             SELECTOR   
default-pool   10.233.64.0/18   all()      

iva@c9v:~ $ 

```

* после создания нэймспэйса и добавления правил:

```
va@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-05-cni  (12.5 *)$ calicoctl get profile --allow-version-mismatch
NAME                                                 
projectcalico-default-allow                          
kns.default                                          
kns.kube-node-lease                                  
kns.kube-public                                      
kns.kube-system                                      
kns.netology-ns                                      
ksa.default.default                                  
ksa.kube-node-lease.default                          
ksa.kube-public.default                              
ksa.kube-system.attachdetach-controller              
ksa.kube-system.bootstrap-signer                     
ksa.kube-system.calico-node                          
ksa.kube-system.certificate-controller               
ksa.kube-system.clusterrole-aggregation-controller   
ksa.kube-system.coredns                              
ksa.kube-system.cronjob-controller                   
ksa.kube-system.daemon-set-controller                
ksa.kube-system.default                              
ksa.kube-system.deployment-controller                
ksa.kube-system.disruption-controller                
ksa.kube-system.dns-autoscaler                       
ksa.kube-system.endpoint-controller                  
ksa.kube-system.endpointslice-controller             
ksa.kube-system.endpointslicemirroring-controller    
ksa.kube-system.ephemeral-volume-controller          
ksa.kube-system.expand-controller                    
ksa.kube-system.generic-garbage-collector            
ksa.kube-system.horizontal-pod-autoscaler            
ksa.kube-system.job-controller                       
ksa.kube-system.kube-proxy                           
ksa.kube-system.namespace-controller                 
ksa.kube-system.node-controller                      
ksa.kube-system.nodelocaldns                         
ksa.kube-system.persistent-volume-binder             
ksa.kube-system.pod-garbage-collector                
ksa.kube-system.pv-protection-controller             
ksa.kube-system.pvc-protection-controller            
ksa.kube-system.replicaset-controller                
ksa.kube-system.replication-controller               
ksa.kube-system.resourcequota-controller             
ksa.kube-system.root-ca-cert-publisher               
ksa.kube-system.service-account-controller           
ksa.kube-system.service-controller                   
ksa.kube-system.statefulset-controller               
ksa.kube-system.token-cleaner                        
ksa.kube-system.ttl-after-finished-controller        
ksa.kube-system.ttl-controller                       
ksa.netology-ns.default                   

```

Все используемые политики приведены в [репозитории](./source/) там же приведен порядок настройки кластера

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
