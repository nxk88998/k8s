#!/bin/bash
######################################################
master="xxx.xxx.xxx
xxx.xxx.xxxx"
node="xxx.xxx.xxx
xxx.xxx.xxxx"
all="$master
$node"
#高可用地址或者单master地址
network_vip="xxxx.xxx.xxx"

#####################################################

version=1.19.6
sshport=22

network_name=`ip link | grep -v lo: | grep UP | awk '{print $2}' | cut -d \: -f 1 | grep -v docker`
#ssh-keygen
##主机名

for host_m in $master
do
echo $host_m
echo  "$host_m master-$host_m" >> hosts
ssh-copy-id -p $sshport root@$host_m
ssh root@$host_m hostnamectl set-hostname master-$host_m
scp kubeadm root@$host_m:/usr/local/
scp keepalived.conf root@$i:/etc/keepalived/keepalived.conf
ssh root@$i "systemctl restart keepalived"
done

for host_n in $node
do
echo $host_n
echo  "$host_n node-$host_n" >> hosts
ssh-copy-id -p $sshport root@$host_n
ssh root@$host_n  hostnamectl set-hostname node-$host_n
done
#sshd秘钥

for i in $all
do

####################################################################################
################################初始化环境设置######################################
scp ./hosts root@$i:/etc/hosts
scp -r tools root@$i:/tmp
ssh root@$i "systemctl stop firewalld &&
systemctl disable firewalld &&
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux &&
setenforce 0 &&
swapoff -a && sysctl -w vm.swappiness=0 &&
yum install -y /tmp/tools/*  &&
sed -i '/swap/d' /etc/fstab &&
systemctl restart docker"
ssh root@$i "sed -i s/network_ip/$i/g /etc/keepalived/keepalived.conf &&
sed -i s/network_vip/$network_vip/g /etc/keepalived/keepalived.conf &&
sed -i s/network_name/$network_name/g /etc/keepalived/keepalived.conf "
#后期ansible优化
echo "手动配置keepalived权重"
done
rm -rf hosts
#################################################################################
#################################################################################
#如遇错误情况，重置kubeadm reset
kubeadm init --config=kubeadm-master.config
#删除master污点标签，使其作为计算节点
#kubectl taint node master-192.168.1.171 node-role.kubernetes.io/master-

USER=root
CONTROL_PLANE_IPS="$master $node"
for host in ${CONTROL_PLANE_IPS}; do
    scp /etc/kubernetes/pki/ca.crt "${USER}"@$host:
    scp /etc/kubernetes/pki/ca.key "${USER}"@$host:
    scp /etc/kubernetes/pki/sa.key "${USER}"@$host:
    scp /etc/kubernetes/pki/sa.pub "${USER}"@$host:
    scp /etc/kubernetes/pki/front-proxy-ca.crt "${USER}"@$host:
    scp /etc/kubernetes/pki/front-proxy-ca.key "${USER}"@$host:
    scp /etc/kubernetes/pki/etcd/ca.crt "${USER}"@$host:etcd-ca.crt
    scp /etc/kubernetes/pki/etcd/ca.key "${USER}"@$host:etcd-ca.key
    scp /etc/kubernetes/admin.conf "${USER}"@$host:
    scp ~/kubeadm1.19.6/kubeadm root@$host:/usr/local/bin/
    ssh ${USER}@${host} 'mkdir -p /etc/kubernetes/pki/etcd'
    ssh ${USER}@${host} 'mv /${USER}/ca.crt /etc/kubernetes/pki/'
    ssh ${USER}@${host} 'mv /${USER}/ca.key /etc/kubernetes/pki/'
    ssh ${USER}@${host} 'mv /${USER}/sa.pub /etc/kubernetes/pki/'
    ssh ${USER}@${host} 'mv /${USER}/sa.key /etc/kubernetes/pki/'
    ssh ${USER}@${host} 'mv /${USER}/front-proxy-ca.crt /etc/kubernetes/pki/'
    ssh ${USER}@${host} 'mv /${USER}/front-proxy-ca.key /etc/kubernetes/pki/'
    ssh ${USER}@${host} 'mv /${USER}/etcd-ca.crt /etc/kubernetes/pki/etcd/ca.crt'
    ssh ${USER}@${host} 'mv /${USER}/etcd-ca.key /etc/kubernetes/pki/etcd/ca.key'
    ssh ${USER}@${host} 'mv /${USER}/admin.conf /etc/kubernetes/admin.conf'
    ssh ${USER}@${host} 'mkdir /${USER}/.kube'
    ssh ${USER}@${host} 'cp /etc/kubernetes/admin.conf /${USER}/.kube/config'
done

