## 部署后需要的调整

flink-jobmanager和taskmanager节点运行如下命令，否则streampark作业运行出错
```sh
cp opt/flink-table-planner_2.12-1.17.2.jar lib/
mv lib/flink-table-planner-loader-1.17.2.jar opt/
```

hive节点运行beeline
```sql
-- 创建数据库
create database ods; create database dwd; create database dim; create database dws; show databases;
-- 单节点mapreduce workaround
set mapreduce.task.io.sort.mb=10;
```

hive目录要改权限，让flink能写
```sh
docker exec -u root -it flink-taskmanager chmod -R 777 /opt/hive/data/warehouse
```

streampark节点需要安装flink_1.17.2

dolphinscheduler节点需要安装flink_1.17.2，配置FLINK_HOME

flink-jobmanager节点的`${FLINK_HOME}/conf`需要复制到dolphinscheduler节点，并在conf/flink-conf.yaml里面修正/取消注释如下变量
<listen_host>::</listen_host>
rest.port: 8081
rest.address: flink-jobmanager

将flink-pom.xml里列出的jar包全部下载，复制到flink-jobmanager、flink-taskmanager、streampark、dolphinscheduler节点的`${FLINK_HOME}/lib/`下

hive节点的/opt/hive/conf需要复制到flink-jobmanager、flink-taskmanager、streampark、dolphinscheduler节点

调整容器时区（尤其是taskmanager）`ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime`


## Flink slot总数 调整方法

1. 增加单个 TaskManager 的 slot 数量

修改 flink-taskmanager 服务的 FLINK_PROPERTIES

增加 slot 时建议同步调整内存，否则每个 slot 分到的内存会变少

flink-taskmanager:
  environment:
    - |
      FLINK_PROPERTIES=
      jobmanager.rpc.address: flink-jobmanager
      taskmanager.numberOfTaskSlots: 4    # 改为需要的数量
      taskmanager.memory.process.size: 4096m

2. 增加 TaskManager 实例数量

使用 docker compose up --scale 启动多个 TaskManager：

docker compose up -d --scale flink-taskmanager=3

这样总 slot 数 = numberOfTaskSlots × TaskManager数量
