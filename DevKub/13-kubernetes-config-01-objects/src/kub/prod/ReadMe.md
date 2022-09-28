## Задание 2: подготовить конфиг для production окружения
Следующим шагом будет запуск приложения в production окружении. Требования сложнее:
* каждый компонент (база, бекенд, фронтенд) запускаются в своем поде, регулируются отдельными deployment’ами;
* для связи используются service (у каждого компонента свой);
* в окружении фронта прописан адрес сервиса бекенда;
* в окружении бекенда прописан адрес сервиса базы данных.


---

```bash
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/prod  (13.1 *)$ kubectl patch svc pgsql-svc -p '{"spec":{"externalIPs":["51.250.105.74"]}}'
service/pgsql-svc patched
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/prod  (13.1 *)$ kubectl get svc -o wide
NAME        TYPE        CLUSTER-IP     EXTERNAL-IP     PORT(S)    AGE   SELECTOR
pgsql-svc   ClusterIP   10.233.7.193   51.250.105.74   5432/TCP   86s   app=postgres-db
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/prod  (13.1 *)$ kubectl apply -f 30-postgres.yml -f 40-back.yml -f 50-front.yml 
statefulset.apps/postgres-sts configured
service/pgsql-svc unchanged
deployment.apps/app-back created
service/back-svc created
deployment.apps/app-front created
service/front-svc created
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/prod  (13.1 *)$ kubectl get svc -o wide
NAME        TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE    SELECTOR
back-svc    ClusterIP      10.233.45.176   <none>          9000/TCP       4s     app=back
front-svc   LoadBalancer   10.233.3.89     <pending>       80:30071/TCP   3s     app=front
pgsql-svc   ClusterIP      10.233.7.193    51.250.105.74   5432/TCP       8m6s   app=postgres-db
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/prod  (13.1 *)$ kubectl patch svc front-svc -p '{"spec":{"externalIPs":["51.250.105.74"]}}'
service/front-svc patched
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/prod  (13.1 *)$ kubectl patch svc front-svc -p '{"spec":{"externalIPs":["192.168.0.7"]}}'
service/front-svc patched
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/prod  (13.1 *)$ kubectl get svc -o wide
NAME        TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE     SELECTOR
back-svc    ClusterIP      10.233.45.176   <none>          9000/TCP       92s     app=back
front-svc   LoadBalancer   10.233.3.89     192.168.0.7     80:30071/TCP   91s     app=front
pgsql-svc   ClusterIP      10.233.7.193    51.250.105.74   5432/TCP       9m34s   app=postgres-db
va@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/prod  (13.1 *)$ kubectl get pods -o wide
NAME                         READY   STATUS    RESTARTS   AGE    IP               NODE    NOMINATED NODE   READINESS GATES
app-back-54575dbff7-mqjks    1/1     Running   0          4m9s   10.233.102.158   node1   <none>           <none>
app-front-759d8c446c-vghzf   1/1     Running   0          4m8s   10.233.102.159   node1   <none>           <none>
postgres-sts-0               1/1     Running   0          14m    10.233.75.39     node2   <none>           <none>
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects/src/kub/prod  (13.1 *)$ kubectl get deploy -o wide
NAME        READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES                     SELECTOR
app-back    0/1     1            0           4m35s   backend      egerpro/13backend:0.0.1    app=back
app-front   0/1     1            0           4m34s   front        egerpro/13frontend:0.0.1   app=front

```