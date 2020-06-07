# lnmp
Linux nginx+php+mysql for centos7 build script.

### docker创建并启动容器
docker run -d --name lnmp --privileged centos:centos7 /usr/sbin/init
docker exec -it lnmp bash -l

### 在lnmp容器的控制台执行如下命令(setup.sh要进行nginx,php和mysql的编译，执行时间比较长，具体要看机器的配置)：
```sh
yum install git
git clone https://github.com/talent518/lnmp.git
pushd lnmp
chmod +x *.sh
./setup.sh
popd
```

