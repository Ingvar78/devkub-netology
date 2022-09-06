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

## Установка кластера после билдера 

```bash
yc-user@cp1:~/kubespray$ ansible-playbook -i inventory/mycluster/hosts.yaml cluster.yml -b -v

...

PLAY RECAP ************************************************************************************************************************
cp1                        : ok=146  changed=42   unreachable=0    failed=0    skipped=355  rescued=0    ignored=1   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
node1                      : ok=689  changed=126  unreachable=0    failed=0    skipped=1204 rescued=0    ignored=8   
node2                      : ok=499  changed=94   unreachable=0    failed=0    skipped=739  rescued=0    ignored=2   
node3                      : ok=499  changed=94   unreachable=0    failed=0    skipped=739  rescued=0    ignored=2   
node4                      : ok=499  changed=94   unreachable=0    failed=0    skipped=739  rescued=0    ignored=2   

Tuesday 06 September 2022  20:30:03 +0000 (0:00:00.104)       0:18:01.794 ***** 
=============================================================================== 
download : download_container | Download image if required ---------------------------------------------------------------- 61.70s
network_plugin/calico : Wait for calico kubeconfig to be created ---------------------------------------------------------- 58.69s
kubernetes/preinstall : Install packages requirements --------------------------------------------------------------------- 41.27s
kubernetes/control-plane : kubeadm | Initialize first master -------------------------------------------------------------- 35.64s
download : download_container | Download image if required ---------------------------------------------------------------- 32.48s
download : download_container | Download image if required ---------------------------------------------------------------- 32.40s
kubernetes/kubeadm : Join to cluster -------------------------------------------------------------------------------------- 32.34s
download : download_file | Validate mirrors ------------------------------------------------------------------------------- 26.79s
download : download_container | Download image if required ---------------------------------------------------------------- 25.18s
download : download_container | Download image if required ---------------------------------------------------------------- 21.25s
download : download_container | Download image if required ---------------------------------------------------------------- 19.26s
download : download_container | Download image if required ---------------------------------------------------------------- 18.64s
download : download_container | Download image if required ---------------------------------------------------------------- 15.20s
download : download_container | Download image if required ---------------------------------------------------------------- 14.72s
kubernetes-apps/ansible : Kubernetes Apps | Start Resources --------------------------------------------------------------- 12.94s
kubernetes/preinstall : Update package management cache (APT) ------------------------------------------------------------- 12.64s
network_plugin/calico : Calico | Create ipamconfig resources -------------------------------------------------------------- 11.73s
kubernetes/preinstall : Preinstall | restart kube-apiserver crio/containerd ----------------------------------------------- 10.22s
kubernetes/node : install | Copy kubelet binary from download dir ---------------------------------------------------------- 8.35s
etcd : reload etcd --------------------------------------------------------------------------------------------------------- 8.01s

```

## Задание 2 (*): подготовить и проверить инвентарь для кластера в AWS
Часть новых проектов хотят запускать на мощностях AWS. Требования похожи:
* разворачивать 5 нод: 1 мастер и 4 рабочие ноды;
* работать должны на минимально допустимых EC2 — t3.small.

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
