## Задание 1: подготовить тестовый конфиг для запуска приложения
Для начала следует подготовить запуск приложения в stage окружении с простыми настройками. Требования:
* под содержит в себе 2 контейнера — фронтенд, бекенд;
* регулируется с помощью deployment фронтенд и бекенд;
* база данных — через statefulset.



```
va@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/stage  (13.1)$ kubectl get pv 
No resources found
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/stage  (13.1)$ kubectl apply -f 20-PersistentVolume.yml 
persistentvolume/pv-stage created
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/stage  (13.1)$ kubectl get pv
NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
pv-stage   512Mi      RWO            Retain           Available                                   11s
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/stage  (13.1)$ kubectl describe pv
Name:            pv-stage
Labels:          <none>
Annotations:     <none>
Finalizers:      [kubernetes.io/pv-protection]
StorageClass:    
Status:          Available
Claim:           
Reclaim Policy:  Retain
Access Modes:    RWO
VolumeMode:      Filesystem
Capacity:        512Mi
Node Affinity:   <none>
Message:         
Source:
    Type:          HostPath (bare host directory volume)
    Path:          /stage/testpath
    HostPathType:  
Events:            <none>
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/stage  (13.1)$ kubectl delete pv pv-stage
persistentvolume "pv-stage" deleted
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/stage  (13.1)$ kubectl get pv 
No resources found
```

[How to Deploy PostgreSQL on Kubernetes](https://phoenixnap.com/kb/postgresql-kubernetes)

```
va@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/stage  (13.1)$ kubectl apply -f 30-postgres.yml 
statefulset.apps/postgres-sts created
service/pgsql-svc created
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/stage  (13.1)$ kubectl get po
NAME             READY   STATUS    RESTARTS   AGE
postgres-sts-0   0/1     Pending   0          8s
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/stage  (13.1)$ kubectl describe pod postgres-sts-0 
Name:           postgres-sts-0
Namespace:      stage
Priority:       0
Node:           <none>
Labels:         app=postgres-db
                controller-revision-hash=postgres-sts-dfdd47bc7
                statefulset.kubernetes.io/pod-name=postgres-sts-0
Annotations:    <none>
Status:         Pending
IP:             
IPs:            <none>
Controlled By:  StatefulSet/postgres-sts
Containers:
  postgres-db:
    Image:      postgres:13-alpine
    Port:       5432/TCP
    Host Port:  0/TCP
    Limits:
      cpu:     500m
      memory:  512Mi
    Requests:
      cpu:     250m
      memory:  265Mi
    Environment:
      POSTGRES_USER:      postgres
      POSTGRES_PASSWORD:  postgres
      POSTGRES_DB:        news
    Mounts:
      /var/lib/postgres/data from pgres-disk (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-zqbzg (ro)
Conditions:
  Type           Status
  PodScheduled   False 
Volumes:
  pgres-disk:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  pgres-disk-postgres-sts-0
    ReadOnly:   false
  kube-api-access-zqbzg:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason            Age    From               Message
  ----     ------            ----   ----               -------
  Warning  FailedScheduling  2m42s  default-scheduler  0/3 nodes are available: 3 pod has unbound immediate PersistentVolumeClaims. preemption: 0/3 nodes are available: 3 Preemption is not helpful for scheduling.

```

```
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/stage  (13.1)$ watch kubectl get po
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/stage  (13.1)$ watch kubectl apply -f 20-PersistentVolume.yml 
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/stage  (13.1)$ watch kubectl get po
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/stage  (13.1)$ kubectl get po
NAME             READY   STATUS    RESTARTS   AGE
postgres-sts-0   1/1     Running   0          6m24s

```

```
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/stage  (13.1)$ kubectl describe pod postgres-sts-0 
Name:         postgres-sts-0
Namespace:    stage
Priority:     0
Node:         node2/192.168.0.34
Start Time:   Wed, 28 Sep 2022 01:10:53 +0300
Labels:       app=postgres-db
              controller-revision-hash=postgres-sts-dfdd47bc7
              statefulset.kubernetes.io/pod-name=postgres-sts-0
Annotations:  cni.projectcalico.org/containerID: 0b4e8c3fe20ba75cbdd57f81040a21dae45532f78dbb868738c745ec1aa4d4b6
              cni.projectcalico.org/podIP: 10.233.75.29/32
              cni.projectcalico.org/podIPs: 10.233.75.29/32
Status:       Running
IP:           10.233.75.29
IPs:
  IP:           10.233.75.29
Controlled By:  StatefulSet/postgres-sts
Containers:
  postgres-db:
    Container ID:   containerd://6ff32ddaf9d53537ba88ff4f6db43cb47fe49b868de3132344f6d41e048bbcc2
    Image:          postgres:13-alpine
    Image ID:       docker.io/library/postgres@sha256:fc3670fa23119159394dfdb98eee89b30ef5a506791aea6ff7d8a4e73a8cd4a4
    Port:           5432/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 28 Sep 2022 01:10:53 +0300
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     500m
      memory:  512Mi
    Requests:
      cpu:     250m
      memory:  265Mi
    Environment:
      POSTGRES_USER:      postgres
      POSTGRES_PASSWORD:  postgres
      POSTGRES_DB:        news
    Mounts:
      /var/lib/postgres/data from pgres-disk (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-zqbzg (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  pgres-disk:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  pgres-disk-postgres-sts-0
    ReadOnly:   false
  kube-api-access-zqbzg:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason            Age                 From               Message
  ----     ------            ----                ----               -------
  Warning  FailedScheduling  57s (x5 over 7m4s)  default-scheduler  0/3 nodes are available: 3 pod has unbound immediate PersistentVolumeClaims. preemption: 0/3 nodes are available: 3 Preemption is not helpful for scheduling.
  Normal   Scheduled         43s                 default-scheduler  Successfully assigned stage/postgres-sts-0 to node2
  Normal   Pulled            43s                 kubelet            Container image "postgres:13-alpine" already present on machine
  Normal   Created           43s                 kubelet            Created container postgres-db
  Normal   Started           43s                 kubelet            Started container postgres-db

```

```
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/stage  (13.1)$ kubectl apply -f 40-front-back.yml 
deployment.apps/main created
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/stage  (13.1)$ kubectl get po
NAME                    READY   STATUS    RESTARTS   AGE
main-5c888cb9cb-x28tp   2/2     Running   0          4s
postgres-sts-0          1/1     Running   0          19m
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/stage  (13.1)$ kubectl get po
NAME                    READY   STATUS    RESTARTS   AGE
main-5c888cb9cb-x28tp   2/2     Running   0          10s
postgres-sts-0          1/1     Running   0          19m

```