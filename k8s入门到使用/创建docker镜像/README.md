# 创建docker（Dockerfile）


**选择底层镜像**

FROM microsoft/dotnet:2.2-sdk

**添加导入程序文件**

ADD name.tar.gz  /opt

**配置环境变量**

ENV ASPNETCORE_ENVIRONMENT=Production

**选择工作目录**

WORKDIR /opt

**启动程序命令**

ENTRYPOINT ["dotnet", "UCity.Module.PayGateway.dll"]

## 生成docker镜像 
> docker上传需要提前登入 docker login http://XXXX

docker build -t "dockername" .

> 举例docker build -t 10.1.205.153/itps/test:v$time .

## 上传docker镜像

docker push dockername:Version

> 举例docker push 10.1.205.153/itps/test:v$time


## 需要注意:
上传登入非https协议的需要配置信任列表，否则会报错不信任，自动跳转连接https
> "insecure-registries": ["http://111.2.9.178:12346"]

添加阿里云加速地址：
> "registry-mirrors": ["https://k51dnsjw.mirror.aliyuncs.com"]
