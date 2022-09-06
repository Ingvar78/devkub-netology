#!/bin/bash

set -e

function create_vm {
  local NAME=$1

  YC=$(cat <<END
    yc compute instance create \
      --name $NAME \
      --hostname $NAME \
      --zone ru-central1-b \
      --network-interface subnet-name=neto_subnet,nat-ip-version=ipv4 \
      --memory 4 \
      --cores 2 \
      --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-2004-lts,type=network-ssd,size=20 \
      --ssh-key /home/iva/.ssh/id_rsa.pub
END
)
#  echo "$YC"
  eval "$YC"
}

create_vm "node3"
create_vm "node4"


yc compute instance list
