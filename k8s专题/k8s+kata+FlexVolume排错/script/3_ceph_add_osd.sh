#!/bin/bash
#
#

set -o errexit
set -o nounset
set -o pipefail
set -x


theHostname=$(hostname)

ceph osd crush add-bucket ${theHostname} host
ceph osd crush move ${theHostname} root=default

DATA_DIR="$1"

for dataDir in "$DATA_DIR"  ; do
    echo -e "\n------ ${dataDir} ------"
    num=`ceph osd create`
    mkdir -p ${dataDir}/osd/ceph-${num}
    ln -sf ${dataDir}/osd/ceph-${num} /var/lib/ceph/osd/ceph-${num}
    ceph-osd -i ${num} --mkfs --mkkey
    ceph auth add osd.${num} osd 'allow *' mon 'allow profile osd' -i /var/lib/ceph/osd/ceph-${num}/keyring
    ceph osd crush add osd.${num} 1.0 host=$(hostname)
    chown ceph:ceph /var/lib/ceph/osd ${dataDir}/osd -R
    systemctl start ceph-osd@${num} 
    systemctl enable ceph-osd@${num}
    systemctl enable ceph.target
    sleep 2
done


