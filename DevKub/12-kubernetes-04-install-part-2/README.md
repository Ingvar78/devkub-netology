# Домашнее задание к занятию "12.4 Развертывание кластера на собственных серверах, лекция 2"
Новые проекты пошли стабильным потоком. Каждый проект требует себе несколько кластеров: под тесты и продуктив. Делать все руками — не вариант, поэтому стоит автоматизировать подготовку новых кластеров.

## Задание 1: Подготовить инвентарь kubespray
Новые тестовые кластеры требуют типичных простых настроек. Нужно подготовить инвентарь и проверить его работу. Требования к инвентарю:
* подготовка работы кластера из 5 нод: 1 мастер и 4 рабочие ноды;
* в качестве CRI — containerd;
* запуск etcd производить на мастере.


----

Созданы 5 ВМ в YC со следующими характеристиками: CPU 2/RAM 4/HDD 20 Gb (размер CPU/RAM определялись с учётом полученных ранее замечаний по HCL kubernetes)

iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2  (12.4 *)$ yc compute instance list

+----------------------+--------+---------------+---------+----------------+--------------+
|          ID          |  NAME  |    ZONE ID    | STATUS  |  EXTERNAL IP   | INTERNAL IP  |
+----------------------+--------+---------------+---------+----------------+--------------+
| epd37ilde4nrpr1sumvv | cp1    | ru-central1-b | RUNNING | 51.250.96.56   | 192.168.0.28 |
| epd53bh32ivnfuda00r9 | wnode1 | ru-central1-b | RUNNING | 51.250.26.109  | 192.168.0.34 |
| epdeu8i050e6ivq7lb41 | wnode2 | ru-central1-b | RUNNING | 62.84.123.222  | 192.168.0.8  |
| epdo29k7drevfj5an28c | wnode3 | ru-central1-b | RUNNING | 62.84.123.63   | 192.168.0.11 |
| epdd3331mokn7a0j46ub | wnode4 | ru-central1-b | RUNNING | 51.250.100.224 | 192.168.0.12 |
+----------------------+--------+---------------+---------+----------------+--------------+


```bash
iva@c9v:~ $ ssh yc-user@51.250.96.56

yc-user@cp1:~$ sudo apt-get update && sudo apt-get install git
yc-user@cp1:~$ sudo apt-get install python3-pip

yc-user@cp1:~$ cd ~/.ssh/
yc-user@cp1:~/.ssh$ touch id_rsa
yc-user@cp1:~/.ssh$ vi id_rsa
yc-user@cp1:~/.ssh$ chmod 600 id_rsa
yc-user@cp1:~/.ssh$ touch id_rsa.pub
yc-user@cp1:~/.ssh$ vi id_rsa.pub

yc-user@cp1:~$ git clone https://github.com/kubernetes-sigs/kubespray
yc-user@cp1:~$ cd kubespray/
yc-user@cp1:~/kubespray$ cp -rfp inventory/sample inventory/mycluster
yc-user@cp1:~/kubespray$ sudo pip3 install -r requirements.txt
Collecting ansible==5.7.1
....
yc-user@cp1:~/kubespray$ declare -a IPS=(192.168.0.34 192.168.0.8 192.168.0.11 192.168.0.12 192.168.0.28)
yc-user@cp1:~/kubespray$ CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
...

```

После получения [inventory/mycluster/hosts.yaml](./source/mycluster/hosts.yaml) было проведено ревью получившегося файла, в котором etcd был оставлен только на первой ноде (как и control plane).

Согласно требованиям необходимо использовать в качестве container runtime - containerd. Для этого необходимо внести соответсвующие правки описанные в [инструкции](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/containerd.md)

Для доступа из-вне необходимо раскоментировать соответствующую настройку в файле [k8s-cluster.yml](./source/mycluster/k8s-cluster.yml).

```
iva@c9v:~/Documents/devkub-netology/DevKub/12-kubernetes-04-install-part-2/source/mycluster  (12.4 *)$ cat k8s-cluster.yml | grep suppl
supplementary_addresses_in_ssl_keys: [51.250.96.56]
```

## Установка кластера после билдера 

```bash
yc-user@cp1:~/kubespray$ ansible-playbook -i inventory/mycluster/hosts.yaml cluster.yml -b -v

...

PLAY RECAP ***************************************************************************************************************
cp1                        : ok=743  changed=100  unreachable=0    failed=0    skipped=1246 rescued=0    ignored=9   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
node1                      : ok=496  changed=54   unreachable=0    failed=0    skipped=728  rescued=0    ignored=2   
node2                      : ok=496  changed=55   unreachable=0    failed=0    skipped=727  rescued=0    ignored=2   
node3                      : ok=496  changed=54   unreachable=0    failed=0    skipped=727  rescued=0    ignored=2   
node4                      : ok=496  changed=55   unreachable=0    failed=0    skipped=727  rescued=0    ignored=2   

Tuesday 06 September 2022  22:20:00 +0000 (0:00:00.135)       0:19:34.259 ***** 
=============================================================================== 
download : download_container | Download image if required ------------------------------------------------------------- 56.81s
network_plugin/calico : Wait for calico kubeconfig to be created ------------------------------------------------------- 52.98s
kubernetes/control-plane : kubeadm | Initialize first master ----------------------------------------------------------- 40.56s
download : download_container | Download image if required ------------------------------------------------------------- 33.72s
kubernetes/kubeadm : Join to cluster ----------------------------------------------------------------------------------- 33.64s
download : download_container | Download image if required ------------------------------------------------------------- 26.72s
download : download_file | Validate mirrors ---------------------------------------------------------------------------- 24.72s
download : download_container | Download image if required ------------------------------------------------------------- 23.30s
download : download_container | Download image if required ------------------------------------------------------------- 23.04s
download : download_container | Download image if required ------------------------------------------------------------- 20.82s
download : download_container | Download image if required ------------------------------------------------------------- 19.03s
kubernetes-apps/ansible : Kubernetes Apps | Start Resources ------------------------------------------------------------ 18.88s
download : download_container | Download image if required ------------------------------------------------------------- 15.06s
download : download_container | Download image if required ------------------------------------------------------------- 14.87s
kubernetes/preinstall : Preinstall | wait for the apiserver to be running ---------------------------------------------- 9.65s
kubernetes/node : install | Copy kubelet binary from download dir ------------------------------------------------------ 8.44s
download : extract_file | Unpacking archive ---------------------------------------------------------------------------- 8.17s
etcd : reload etcd ----------------------------------------------------------------------------------------------------- 8.06s
download : download_container | Download image if required ------------------------------------------------------------- 7.97s
adduser : User | Create User ------------------------------------------------------------------------------------------- 7.36s
yc-user@cp1:~/kubespray$ mkdir -p $HOME/.kube
yc-user@cp1:~/kubespray$     sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
yc-user@cp1:~/kubespray$     sudo chown $(id -u):$(id -g) $HOME/.kube/config
yc-user@cp1:~/kubespray$ kubectl get nodes
NAME    STATUS   ROLES           AGE     VERSION
cp1     Ready    control-plane   6m55s   v1.24.4
node1   Ready    <none>          5m48s   v1.24.4
node2   Ready    <none>          5m48s   v1.24.4
node3   Ready    <none>          5m48s   v1.24.4
node4   Ready    <none>          5m48s   v1.24.4

```


```bash
iva@c9v:~/Documents $ kubectl get nodes
NAME    STATUS   ROLES           AGE   VERSION
cp1     Ready    control-plane   12m   v1.24.4
node1   Ready    <none>          11m   v1.24.4
node2   Ready    <none>          11m   v1.24.4
node3   Ready    <none>          11m   v1.24.4
node4   Ready    <none>          11m   v1.24.4

```

## Задание 2 (*): подготовить и проверить инвентарь для кластера в AWS
Часть новых проектов хотят запускать на мощностях AWS. Требования похожи:
* разворачивать 5 нод: 1 мастер и 4 рабочие ноды;
* работать должны на минимально допустимых EC2 — t3.small.

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---

----------

[Дополнительно пример ручной настройки кластера из 5 ВМ](./source/ReadMe.md)