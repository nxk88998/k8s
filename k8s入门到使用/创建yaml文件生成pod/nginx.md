## 创建nginx附带+nfs+configmap配置

> 无状态pod不推荐使用nfs等ceph存储挂载

```
#创建nfs-PV
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ucitydatabigscreen-pv
  labels:
    pv: ucitydatabigscreen-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    path: /data/ucitydatabigscreen
    server: 192.168.1.11
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: ucitydatabigscreen-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  selector:
    matchLabels:
      pv: ucitydatabigscreen-pv
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: nginx-config
data:
  default.conf: |-
    server {
        listen       80;
        server_name  localhost;
        location / {
          root   /usr/share/nginx/html;
          index  index.html index.htm;
        }
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/share/nginx/html;
        }
    }
#部署应用Nginx
---
apiVersion: v1
kind: ReplicationController
metadata:
  name: ucitydatabigscreen
  labels:
    name: ucitydatabigscreen
spec:
  replicas: 1
  selector:
    name: ucitydatabigscreen
  template:
    metadata:
      labels:
       name: ucitydatabigscreen
    spec:
      containers:
      - name: ucitydatabigscreen
        image: docker.io/nginx
        volumeMounts:
        - name: nginx-data
          mountPath: /usr/share/nginx/html
        - name: nginx-configmap
          mountPath: /etc/nginx/conf.d/default.conf
          subPath: default.conf
        ports:
        - containerPort: 80
      volumes:
      - name: nginx-data
        persistentVolumeClaim:
          claimName: ucitydatabigscreen-pvc
      - name: nginx-configmap
        configMap:
          name: nginx-config
          items:
            - key: default.conf
              path: default.conf
#创建Service
---
apiVersion: v1
kind: Service
metadata:
  name: ucitydatabigscreen
  labels:
   name: ucitydatabigscreen
spec:
  type: NodePort
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
    name: http
    nodePort: 15002
  selector:
    name: ucitydatabigscreen
```
