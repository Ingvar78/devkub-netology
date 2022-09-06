#!/bin/bash

set -e

function delete_vm {
  local NAME=$1
  $(yc compute instance delete --name="$NAME")
}

delete_vm "node3"
delete_vm "node4"
