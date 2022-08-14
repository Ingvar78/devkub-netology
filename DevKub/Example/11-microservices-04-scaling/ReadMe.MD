
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


redis-cli --cluster create 10.0.0.2:7002 10.0.0.3:7003 10.0.0.4:7004 10.0.0.5:7005 10.0.0.6:7006 10.0.0.7:7007 --cluster-replicas 1 --cluster-yes
redis-cli -p 7001 --cluster create 10.0.0.2:7002 10.0.0.3:7003 10.0.0.4:7004 10.0.0.5:7005 10.0.0.6:7006 10.0.0.7:7007 --cluster-replicas 1 --cluster-yes
