# Домашнее задание к занятию "13.1 контейнеры, поды, deployment, statefulset, services, endpoints"
Настроив кластер, подготовьте приложение к запуску в нём. Приложение стандартное: бекенд, фронтенд, база данных. Его можно найти в папке 13-kubernetes-config.

## Задание 1: подготовить тестовый конфиг для запуска приложения
Для начала следует подготовить запуск приложения в stage окружении с простыми настройками. Требования:
* под содержит в себе 2 контейнера — фронтенд, бекенд;
* регулируется с помощью deployment фронтенд и бекенд;
* база данных — через statefulset.

------------------------


[Namespace](.//src/kub/stage/10-namespace.yml)

[PersistentVolume](./src/kub/stage/20-PersistentVolume.yml)

[Postgres](./src/kub/stage/30-postgres.yml)

[Back+Front](./src/kub/stage/40-front-back.yml)


```bash
va@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects  (13.1 *)$ kubectl get po -o wide
NAME                              READY   STATUS    RESTARTS   AGE     IP               NODE    NOMINATED NODE   READINESS GATES
app-front-back-5c888cb9cb-z698g   2/2     Running   0          3m50s   10.233.102.148   node1   <none>           <none>
postgres-sts-0                    1/1     Running   0          32m     10.233.75.29     node2   <none>           <none>
iva@c9v:~/Documents/devkub-netology/DevKub/13-kubernetes-config-01-objects  (13.1 *)$ kubectl get deployment -o wide
NAME             READY   UP-TO-DATE   AVAILABLE   AGE    CONTAINERS         IMAGES                                             SELECTOR
app-front-back   1/1     1            1           4m1s   frontend,backend   egerpro/13frontend:0.0.1,egerpro/13backend:0.0.1   app=front-back
```

[Ход выполнения](src/kub/stage/ReadMe.md)

### Дополнительные материалы

[How I create new namespace in Kubernetes](https://stackoverflow.com/questions/52901435/how-i-create-new-namespace-in-kubernetes)

[Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

[Using Kubernetes to Deploy PostgreSQL](https://severalnines.com/blog/using-kubernetes-deploy-postgresql/)


## Задание 2: подготовить конфиг для production окружения
Следующим шагом будет запуск приложения в production окружении. Требования сложнее:
* каждый компонент (база, бекенд, фронтенд) запускаются в своем поде, регулируются отдельными deployment’ами;
* для связи используются service (у каждого компонента свой);
* в окружении фронта прописан адрес сервиса бекенда;
* в окружении бекенда прописан адрес сервиса базы данных.

```
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

[Namespace](./src/kub/prod/10-namespace.yml)

[PersistentVolume](./src/kub/prod/20-PersistentVolume.yml)

[Postgres](./src/kub/prod/30-postgres.yml)

[Back](./src/kub/prod/40-back.yml)

[Front](./src/kub/prod/50-front.yml)


## Задание 3 (*): добавить endpoint на внешний ресурс api
Приложению потребовалось внешнее api, и для его использования лучше добавить endpoint в кластер, направленный на это api. Требования:
* добавлен endpoint до внешнего api (например, геокодер).

---



### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

В качестве решения прикрепите к ДЗ конфиг файлы для деплоя. Прикрепите скриншоты вывода команды kubectl со списком запущенных объектов каждого типа (pods, deployments, statefulset, service) или скриншот из самого Kubernetes, что сервисы подняты и работают.

---
