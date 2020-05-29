rancher官网
https://rancher.com/quick-start/

# 在线安装
## 系统环境
systemctl

## 安装docker

yum install docker -y

systemctl enable docker && systemctl start docker

## docker安装
docker run -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher

# 离线安装
1. 离线百度云地址k8s1.16.9

> 链接：https://pan.baidu.com/s/1t8mnSl8Dsj0xPA8_6bVLSQ 

> 提取码：gvli 

> 此包为离线包

**离线包中直接运行 bash install.sh 文件即可**