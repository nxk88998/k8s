# 额外内容：
1. server服务：关于pod之间内部DNS访问。

    pod之间访问为保证高可用性，它们之间不可能用自己的容器ip地址来互相访问，不然当pod宕机重建后已并非源ip，因此需要通过server自动发现服务，
那么有人会提出如果server服务挂后ip不也会改变么？那么k8s内部安装了服务组件coredns，他会以内部域名的方式绑定server当前的ip，因此pod之间的访问方式为：

格式：

(podsvcname).(podnamespace).svc.cluster.local:5000

podserver名称.命名空间名称.svc.cluster.local:端口
