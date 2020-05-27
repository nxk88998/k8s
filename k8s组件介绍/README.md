# Master 组件：
## kube-apiserver :
　　Kubernetes API 集群的统一通过证书认证入口，各组件的协调者，以RESTful API提供接口方式，所有的对象资源增删改查和监听操作都交给APIServer处理后再提交给etcd数据库做持久化存储。
## Kube-controller-manager
　　处理集群中常规后台任务，一个资源对应一个控制器，而controllerManager就是负责处理这些控制器的。
## kube-scheduler
　　根据调度算法为新创建的pod选择一个Node节点，可以任意部署，可以部署在同一个节点上，也可以部署在不同的节点上。
## etcd
　　分布式键值存储系统，用于保存集群状态数据，比如Pod，Service等对象信息。
# Node组件：
## kubelet:
　　kubelet 是Master在Node节点上的Agent，管理本机运行容器的生命周期，比如创建容器，Pod挂载数据卷，下载secret，获取容器和节点状态等工作，kubelet 将每个Pod转换成一组容器
## kube-proxy:
　　在Node节点上实现Pod网络代理，维护网络规则和四层负载均衡工作。实现让Pod节点（一个或者多个容器）对外提供服务
## docker或rocket
　　容器引擎，运行容器