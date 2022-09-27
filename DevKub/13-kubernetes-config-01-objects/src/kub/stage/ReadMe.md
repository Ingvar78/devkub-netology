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
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/stage  (13.1 *)$ kubectl get deploy
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
main      1/1     1            1           8m16s
mainapp   1/1     1            1           23s
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/stage  (13.1 *)$ kubectl delete deploy --all
deployment.apps "main" deleted
deployment.apps "mainapp" deleted
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/stage  (13.1 *)$ kubectl apply -f 40-front-back.yml 
deployment.apps/app-front-back created
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/stage  (13.1 *)$ kubectl get po
NAME                              READY   STATUS        RESTARTS   AGE
app-front-back-5c888cb9cb-z698g   2/2     Running       0          14s
main-5c888cb9cb-x28tp             2/2     Terminating   0          9m33s
mainapp-5c888cb9cb-n8946          2/2     Terminating   0          100s
postgres-sts-0                    1/1     Running       0          29m
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/stage  (13.1 *)$ kubectl get po
NAME                              READY   STATUS    RESTARTS   AGE
app-front-back-5c888cb9cb-z698g   2/2     Running   0          30s
postgres-sts-0                    1/1     Running   0          29m
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/stage  (13.1 *)$ kubectl get deployment
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
app-front-back   1/1     1            1           43s
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/stage  (13.1 *)$ kubectl get deployment -o wide
NAME             READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS         IMAGES                                             SELECTOR
app-front-back   1/1     1            1           52s   frontend,backend   egerpro/13frontend:0.0.1,egerpro/13backend:0.0.1   app=front-back
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/stage  (13.1 *)$ kubectl describe po app-front-back-5c888cb9cb-z698g
Name:         app-front-back-5c888cb9cb-z698g
Namespace:    stage
Priority:     0
Node:         node1/192.168.0.7
Start Time:   Wed, 28 Sep 2022 01:33:18 +0300
Labels:       app=front-back
              pod-template-hash=5c888cb9cb
Annotations:  cni.projectcalico.org/containerID: a404dbb39a2a4af23596427022df4a125460109508403dc9bdd2ddbae19622aa
              cni.projectcalico.org/podIP: 10.233.102.148/32
              cni.projectcalico.org/podIPs: 10.233.102.148/32
Status:       Running
IP:           10.233.102.148
IPs:
  IP:           10.233.102.148
Controlled By:  ReplicaSet/app-front-back-5c888cb9cb
Containers:
  frontend:
    Container ID:   containerd://014e45a160cc7cc6894c26ea78fdf98c77872a12653ac4ff0057320b7c6a7421
    Image:          egerpro/13frontend:0.0.1
    Image ID:       docker.io/egerpro/13frontend@sha256:3c1cbbb8ec77a9299cb34493baf4ba952d0de6e4b100f60cd6c4371e082b204c
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Wed, 28 Sep 2022 01:33:19 +0300
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-kfq7c (ro)
  backend:
    Container ID:   containerd://e8c8069c96990e621203633be2899a78b26e9be703b682c2f5cf900b2de9eb6b
    Image:          egerpro/13backend:0.0.1
    Image ID:       docker.io/egerpro/13backend@sha256:cfad3fd72c6ce735814d68af1d31ccd685d7e329b14aba79239d507965562c67
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Wed, 28 Sep 2022 01:33:19 +0300
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-kfq7c (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-kfq7c:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  2m24s  default-scheduler  Successfully assigned stage/app-front-back-5c888cb9cb-z698g to node1
  Normal  Pulled     2m23s  kubelet            Container image "egerpro/13frontend:0.0.1" already present on machine
  Normal  Created    2m23s  kubelet            Created container frontend
  Normal  Started    2m23s  kubelet            Started container frontend
  Normal  Pulled     2m23s  kubelet            Container image "egerpro/13backend:0.0.1" already present on machine
  Normal  Created    2m23s  kubelet            Created container backend
  Normal  Started    2m23s  kubelet            Started container backend

```