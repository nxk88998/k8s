  该项目安装只需在 k8sadmin-install.sh脚本中将，network_vip虚拟地址，master和node IP地址填写完毕即可。
一，确认安装k8s集群架构，是否为多master架构，推荐3 Master。
   master01    192.168.1.3
   master02    192.168.1.4
   master03    192.168.1.5
   node01      192.168.1.6
   node02      192.168.1.7
   VIP         192.168.1.2
   
二，配置服务器免秘钥登入
  ssh-keygen
  ssh-copy-id -p $sshport root@$host_m
  ssh-copy-id -p $sshport root@$host_n
三，配置服务器hostname主机名
  ssh root@$host_m hostnamectl set-hostname master-$host_m
  ssh root@$host_m hostnamectl set-hostname master-$host_n
四，安装下载k8s环境初始化（本项目内置离线安装包 tools）

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
  (有点low，后期会用ansible优化)
 
  这里注意需要注意在每个master节点将keepalived的权重配置默认为master的IP地址结尾，如需自定义请自行修改！
 五，将证书分发到各个服务器

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

六，手动执行集群安装
kubeadm init --config=kubeadm-master.config
如果需要将master也配置为node计算节点，删除污点即可
#删除master污点标签，使其作为计算节点
#kubectl taint node master-192.168.1.171 node-role.kubernetes.io/master-
