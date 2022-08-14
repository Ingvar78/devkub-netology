
# Домашнее задание к занятию "11.04 Микросервисы: масштабирование"

Вы работаете в крупной компанию, которая строит систему на основе микросервисной архитектуры.
Вам как DevOps специалисту необходимо выдвинуть предложение по организации инфраструктуры, для разработки и эксплуатации.

## Задача 1: Кластеризация

Предложите решение для обеспечения развертывания, запуска и управления приложениями.
Решение может состоять из одного или нескольких программных продуктов и должно описывать способы и принципы их взаимодействия.

Решение должно соответствовать следующим требованиям:
- Поддержка контейнеров;
- Обеспечивать обнаружение сервисов и маршрутизацию запросов;
- Обеспечивать возможность горизонтального масштабирования;
- Обеспечивать возможность автоматического масштабирования;
- Обеспечивать явное разделение ресурсов доступных извне и внутри системы;
- Обеспечивать возможность конфигурировать приложения с помощью переменных среды, в том числе с возможностью безопасного хранения чувствительных данных таких как пароли, ключи доступа, ключи шифрования и т.п.

Обоснуйте свой выбор.


---

[Блеск и нищета Kubernetes: достоинства и недостатки самой популярной DevOps-технологии для Big Data систем](https://www.bigdataschool.ru/blog/plus-disadvantage-kubernetes.html#:~:text=%D0%A1%D1%83%D1%89%D0%B5%D1%81%D1%82%D0%B2%D1%83%D0%B5%D1%82%20%D0%BC%D0%BD%D0%BE%D0%B6%D0%B5%D1%81%D1%82%D0%B2%D0%BE%20%D0%B0%D0%BB%D1%8C%D1%82%D0%B5%D1%80%D0%BD%D0%B0%D1%82%D0%B8%D0%B2%20Kubernetes%3A%20Docker,Azure%20Container%20Service%20%5B3%5D.)

[OpenShift как корпоративная версия Kubernetes](https://habr.com/ru/company/redhatrussia/blog/494254/)

[CERTIFIED KUBERNETES SOFTWARE CONFORMANCE](https://www.cncf.io/certification/software-conformance/)

Одним из решений соответсвующим требованиям является Kubernetes - открытое программное обеспечение для оркестровки контейнеризированных приложений, автоматизации их развёртывания, масштабирования и координации в условиях кластера. 
Поддерживает основные технологии контейнеризации, включая Docker, также возможна поддержка технологий аппаратной виртуализации. Обеспечивает обнаружение сервисов и маршрутизацию запросов, возможность горизонтального и вертикального масштабирования - как в ручном, так и в автоматическом режиме (autoscaling).
Обеспечивает разделение ресурсов доступных извне и внутри системы. Поддерживает возможность конфигурирования приложения с помощью переменных среды, в том числе с возможностью безопасного хранения 'секретов', ключей доступа и паролей.

Kubernetes - не единственный подходящий продукт, существуют разные конкуренты и альтернативы Kubernetes соответсвующие предъявляемым требованиям: Amazon ECS, Docker Swarm, Nomad, Redhat OpenShift - самые популярные альтернативы Kubernetes и конкуренты Kubernetes.

Отдельно стоит остановиться на OpenShift в основе которого лежит сертифицированный Kubernetes и имеет 100% совместимость по API. помимо полной совместимости по API, Openshift предоставляет несколько дополнительных возможностей - в частности: 1) утилита oc (более мощный и удобный вариант Kubectl), 2) Web-UI 3) инструменты разработки 4) полностью законченный продукт для корпоративного применения.

## Задача 2: Распределенный кэш * (необязательная)

Разработчикам вашей компании понадобился распределенный кэш для организации хранения временной информации по сессиям пользователей.
Вам необходимо построить Redis Cluster состоящий из трех шард с тремя репликами.

### Схема:

![11-04-01](https://user-images.githubusercontent.com/1122523/114282923-9b16f900-9a4f-11eb-80aa-61ed09725760.png)

---

1. Из схемы следует что шарды и реплики должны быть разнесены на 3 виртуальные машины, общее количество redis-ов - 6. При создании кластера в докер-контейнераз экземпляры redis можно разделять по физическим/виртуальным машинам.

1. Формирование кластера выполняется путём вызова redis-cli и передачей списка адресов хостов нод кластера.

1. [Docker-compose.yml](../Example/11-microservices-04-scaling/docker-compose.yml)

```
iva@c9v:~/Documents/devkub-netology/DevKub/Example/11-microservices-04-scaling  (11.04 *)$ docker-compose up --build -d 
[+] Running 0/0
 ⠋ Network 11-microservices-04-scaling_app_net  Creating                                                                                                                                                                                                                             0.1s
[+] Running 8/8d orphan containers ([11-microservices-04-scaling-tester-1 11-microservices-04-scaling-redis4-1 11-microservices-04-scaling-redis2-1 11-microservices-04-scaling-redis3-1 11-microservices-04-scaling-redis1-1 11-microservices-04-scaling-redis5-1 11-microservices-04-sca ⠿ Network 11-microservices-04-scaling_app_net            Created                                                                                                                                                                                                                    0.1s
 ⠿ Container 11-microservices-04-scaling-redis-1-1        Started                                                                                                                                                                                                                    0.8s
 ⠿ Container 11-microservices-04-scaling-redis-4-1        Started                                                                                                                                                                                                                    0.6s
 ⠿ Container 11-microservices-04-scaling-redis-5-1        Started                                                                                                                                                                                                                    0.8s
 ⠿ Container 11-microservices-04-scaling-redis-6-1        Started                                                                                                                                                                                                                    0.6s
 ⠿ Container 11-microservices-04-scaling-redis-2-1        Started                                                                                                                                                                                                                    0.9s
 ⠿ Container 11-microservices-04-scaling-redis-3-1        Started                                                                                                                                                                                                                    0.8s
 ⠿ Container 11-microservices-04-scaling-redis-cluster-1  Started                                                                                                                                                                                                                    1.0s
```

```
iva@c9v:~/Documents/devkub-netology/DevKub/Example/11-microservices-04-scaling  (11.04 *)$ docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS          PORTS                                                 NAMES
c1648c27a82d   redis     "docker-entrypoint.s…"   26 seconds ago   Up 25 seconds   6379/tcp                                              11-microservices-04-scaling-redis-cluster-1
bd127ba8327c   redis     "docker-entrypoint.s…"   26 seconds ago   Up 25 seconds   6379/tcp, 0.0.0.0:7007->7007/tcp, :::7007->7007/tcp   11-microservices-04-scaling-redis-6-1
656787f8733e   redis     "docker-entrypoint.s…"   26 seconds ago   Up 25 seconds   6379/tcp, 0.0.0.0:7005->7005/tcp, :::7005->7005/tcp   11-microservices-04-scaling-redis-4-1
3509aa9410d8   redis     "docker-entrypoint.s…"   26 seconds ago   Up 25 seconds   6379/tcp, 0.0.0.0:7004->7004/tcp, :::7004->7004/tcp   11-microservices-04-scaling-redis-3-1
961c327179e6   redis     "docker-entrypoint.s…"   26 seconds ago   Up 25 seconds   6379/tcp, 0.0.0.0:7002->7002/tcp, :::7002->7002/tcp   11-microservices-04-scaling-redis-1-1
9fd1b6d377c6   redis     "docker-entrypoint.s…"   26 seconds ago   Up 25 seconds   6379/tcp, 0.0.0.0:7003->7003/tcp, :::7003->7003/tcp   11-microservices-04-scaling-redis-2-1
f97ddb4f71c1   redis     "docker-entrypoint.s…"   26 seconds ago   Up 25 seconds   6379/tcp, 0.0.0.0:7006->7006/tcp, :::7006->7006/tcp   11-microservices-04-scaling-redis-5-1
```

```
iva@c9v:~/Documents/devkub-netology/DevKub/Example/11-microservices-04-scaling  (11.04 *)$ docker exec -it 11-microservices-04-scaling-redis-cluster-1 /bin/sh
# redis-cli -p 7001 --cluster create 10.0.0.2:7002 10.0.0.3:7003 10.0.0.4:7004 10.0.0.5:7005 10.0.0.6:7006 10.0.0.7:7007 --cluster-replicas 1 --cluster-yes
>>> Performing hash slots allocation on 6 nodes...
Master[0] -> Slots 0 - 5460
Master[1] -> Slots 5461 - 10922
Master[2] -> Slots 10923 - 16383
Adding replica 10.0.0.6:7006 to 10.0.0.2:7002
Adding replica 10.0.0.7:7007 to 10.0.0.3:7003
Adding replica 10.0.0.5:7005 to 10.0.0.4:7004
M: 214dd7f577f4ac9a4fd353d4eeeaf481345f0abf 10.0.0.2:7002
   slots:[0-5460] (5461 slots) master
M: 252bbe42551d29b4f1f4a7806fad514045bf4409 10.0.0.3:7003
   slots:[5461-10922] (5462 slots) master
M: 8ef1f831cffe15c808124f253e68bc76f6770d90 10.0.0.4:7004
   slots:[10923-16383] (5461 slots) master
S: 3c3b2f3323656b5047d1cae1afd3a8d73483a74a 10.0.0.5:7005
   replicates 8ef1f831cffe15c808124f253e68bc76f6770d90
S: 91179f18cce8a66b8a49d26237def1d7c4d62b16 10.0.0.6:7006
   replicates 214dd7f577f4ac9a4fd353d4eeeaf481345f0abf
S: 1ea9f7a83ab8fc701cde9b0cfa960b42a57ce38b 10.0.0.7:7007
   replicates 252bbe42551d29b4f1f4a7806fad514045bf4409
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join
...
>>> Performing Cluster Check (using node 10.0.0.2:7002)
M: 214dd7f577f4ac9a4fd353d4eeeaf481345f0abf 10.0.0.2:7002
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
M: 252bbe42551d29b4f1f4a7806fad514045bf4409 10.0.0.3:7003
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
S: 3c3b2f3323656b5047d1cae1afd3a8d73483a74a 10.0.0.5:7005
   slots: (0 slots) slave
   replicates 8ef1f831cffe15c808124f253e68bc76f6770d90
S: 1ea9f7a83ab8fc701cde9b0cfa960b42a57ce38b 10.0.0.7:7007
   slots: (0 slots) slave
   replicates 252bbe42551d29b4f1f4a7806fad514045bf4409
S: 91179f18cce8a66b8a49d26237def1d7c4d62b16 10.0.0.6:7006
   slots: (0 slots) slave
   replicates 214dd7f577f4ac9a4fd353d4eeeaf481345f0abf
M: 8ef1f831cffe15c808124f253e68bc76f6770d90 10.0.0.4:7004
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
# 

```


[docker-compose redis-cluster](https://itsmetommy.com/2018/05/24/docker-compose-redis-cluster/)

[Set up a Redis Cluster for Production environments](https://success.outsystems.com/Documentation/How-to_Guides/Infrastructure/Configuring_OutSystems_with_Redis_in-memory_session_storage/Set_up_a_Redis_Cluster_for_Production_environments)
