#!/bin/bash

set -e

function delete_vm {
  local NAME=$1
  $(yc compute instance delete --name="$NAME")
}

delete_vm "cp1"
delete_vm "wnode1"
delete_vm "wnode2"
delete_vm "wnode3"
delete_vm "wnode4"
