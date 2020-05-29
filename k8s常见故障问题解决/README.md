> 生产安装是由kubeadm方式安装，因此集群故障一般较低发生

# 集群故障

```
[root@m1 tmp]# kubectl get node
NAME    STATUS   ROLES    AGE   VERSION
m1      Ready    master   18d   v1.16.9
m2      NotReady    master   18d   v1.16.9
m3      Ready    master   18d   v1.16.9
node1   Ready    <none>   18d   v1.16.9
node2   NotReady    <none>   17d   v1.16.9
node3   Ready    <none>   17d   v1.16.9
```

**1. master节点故障**

检查docker是否启动

> systemctl status docker


> 解决方式: systemctl restart docker || 失败则分析报错信息

检查etcd是否正常
> kubectl get csr

> 解决方式: 找对对应的etcd宿主机，重启etcd（docker start \`docker ps -qa\`） || 如果失败请分析报错日志

检查flannel网络是否正常

> ip add |grep flannel 

> 解决方式: 请查看docker是否正常启动

检查本地haproxy代理是否正常

>  ping \`cat ~/.kube/config | grep server | awk -F "/" '{print $3}' | cut -d : -f 1\`

> 解决方式: 请查看docker容器haproxy是否正常启动

检查时间是否同步
> date
> 解决方法：1. 同步时间 yum install -y ntp && systemctl restart ntpd &&  systemctl enable ntpd 
            2. 配置时区： timedatectl set-timezone 'Asia/Shanghai'

检查证书是否是否一致
> kubeadm reset

> 解决方式:  重新加入集群


**2. node节点故障**

检查kubelet服务是否正常

> netstat -lnp | grep kubelet

> 解决方法：一般是由于flannel网络故障以及证书不一致导致。

按照master故障检查一遍

**3. 重要组件无法启动**

# pod故障
1. yaml文件格式错误
2. pod创建故障
3. pod运行故障

# 异常现象
1. pod拉取镜像失败
2. 一直处于状态
3. pod无法上网