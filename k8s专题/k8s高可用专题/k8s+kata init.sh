#!/bin/bash
set -x
set -o errexit

#######################Copy k8s files to every node#########################
for i in master1 master2 master3 compute1 compute2;do 
    scp -r /root/k8s_kata/ $i:/root/
done

#######################Deploy master1#######################################
ssh master1 "source /root/k8s_kata/deploy_kata.bash &&\
packages_resolving &&\
resolve_kernel_parameters &&\
stop_swap &&\
deploy_etcd &&\
ha_deploy &&\
distribute_k8s_images"

#######################Deploy master2#######################################
ssh master2 "source /root/k8s_kata/deploy_kata.bash &&\
packages_resolving &&\
resolve_kernel_parameters &&\
stop_swap &&\
deploy_etcd &&\
ha_deploy &&\
distribute_k8s_images"

#######################Deploy master3#######################################
ssh master3 "source /root/k8s_kata/deploy_kata.bash &&\
packages_resolving &&\
resolve_kernel_parameters &&\
stop_swap &&\
deploy_etcd &&\
ha_deploy &&\
distribute_k8s_images"

#######################Deploy compute1######################################
ssh compute1 "source /root/k8s_kata/deploy_kata.bash &&\
packages_resolving &&\
resolve_kernel_parameters &&\
stop_swap &&\
distribute_k8s_images"

#######################Deploy compute2######################################
ssh compute2 "source /root/k8s_kata/deploy_kata.bash &&\
packages_resolving &&\
resolve_kernel_parameters &&\
stop_swap &&\
distribute_k8s_images"

#######################Health checking for etcd#############################
for i in master1 master2 master3;do 
	ssh $i "source /root/k8s_kata/deploy_kata.bash && etcd_health_check"
done

#######################Deploy master needs on master1#######################
ssh master1 "source /root/k8s_kata/deploy_kata.bash && deploy_k8s_master"
#######################Deploy master needs on master2#######################
ssh master2 "if [ ! -d /etc/kubernetes/pki/ ];then mkdir /etc/kubernetes/pki/ -pv;fi"
scp /etc/kubernetes/pki/* master2:/etc/kubernetes/pki/
ssh master2 "source /root/k8s_kata/deploy_kata.bash && deploy_k8s_master"
#######################Deploy master needs on master3#######################
ssh master3 "if [ ! -d /etc/kubernetes/pki/ ];then mkdir /etc/kubernetes/pki/ -pv;fi"
scp /etc/kubernetes/pki/* master3:/etc/kubernetes/pki/
ssh master3 "source /root/k8s_kata/deploy_kata.bash && deploy_k8s_master"

#######################Deploy flannel network for cluster###################
ssh master1 "source /root/k8s_kata/deploy_kata.bash && deploy_flannel"

#######################Init mon and deploy osd on master1###################
ssh master1 "source /root/k8s_kata/deploy_kata.bash && deploy_ceph_mon"
ssh master1 "source /root/k8s_kata/deploy_kata.bash && deploy_ceph_prepare_osd && deploy_ceph_add_osd"
#######################Copy cephx key to all other nodes####################
ssh master2 "mkdir /etc/ceph -pv"
ssh master3 "mkdir /etc/ceph -pv"
ssh compute1 "mkdir /etc/ceph -pv"
ssh compute2 "mkdir /etc/ceph -pv"
scp /etc/ceph/{ceph.conf,ceph.client.admin.keyring} master2:/etc/ceph
scp /etc/ceph/{ceph.conf,ceph.client.admin.keyring} master3:/etc/ceph
scp /etc/ceph/{ceph.conf,ceph.client.admin.keyring} compute1:/etc/ceph
scp /etc/ceph/{ceph.conf,ceph.client.admin.keyring} compute2:/etc/ceph
#######################Deploy osd on master2################################
ssh master2 "source /root/k8s_kata/deploy_kata.bash && deploy_ceph_prepare_osd && deploy_ceph_add_osd"
#######################Deploy osd on master3################################
ssh master3 "source /root/k8s_kata/deploy_kata.bash && deploy_ceph_prepare_osd && deploy_ceph_add_osd"
#######################Deploy osd on compute1###############################
ssh compute1 "source /root/k8s_kata/deploy_kata.bash && deploy_ceph_prepare_osd && deploy_ceph_add_osd"
#######################Deploy osd on compute2###############################
ssh compute2 "source /root/k8s_kata/deploy_kata.bash && deploy_ceph_prepare_osd && deploy_ceph_add_osd"

#######################Deploy compute node needs on compute1################
ssh compute1 "source /root/k8s_kata/deploy_kata.bash && deploy_compute_node"
#######################Deploy compute node needs on compute2################
ssh compute2 "source /root/k8s_kata/deploy_kata.bash && deploy_compute_node"

#######################Join compute nodes compute1 compute2 into cluster####
JOINCMD=`ssh master1 kubeadm token create --print-join-command`
ssh compute1 ${JOINCMD}
ssh compute2 ${JOINCMD}

#######################Authentication for cluster###########################
ssh master1 "source /root/k8s_kata/deploy_kata.bash && authentication"

#######################Configure environments for cluster###################
ssh master1 apt install bash-completion -y
ssh master1 "echo \"export KUBECONFIG=/etc/kubernetes/admin.conf\" > /etc/profile.d/k8s_env.sh"
ssh master1 "echo \"source <(kubectl completion bash)\" > /etc/profile.d/k8s_bash_completion.sh"






