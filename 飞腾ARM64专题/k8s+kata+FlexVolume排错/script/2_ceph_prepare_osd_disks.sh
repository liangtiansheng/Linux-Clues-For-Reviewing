#!/bin/bash
#

set -o errexit
set -o nounset
set -o pipefail
set -x

DISK_LABEL="data"
DATA_DIR="/data"

for i in sdb ; do
    echo -e "\n------ ${i} ------"
    mkfs.xfs -f -K -L ${DISK_LABEL}_${i} /dev/${i}
    mkdir -p ${DATA_DIR}/${i}
    echo "/dev/disk/by-label/${DISK_LABEL}_${i}  ${DATA_DIR}/${i}   xfs   rw,noexec,nodev,noatime,nodiratime,nofail    0 0" >> /etc/fstab
    sleep 1
    mount $DATA_DIR
done


