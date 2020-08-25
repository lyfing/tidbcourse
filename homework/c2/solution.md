HomeWork 2
==========
### 使用sysbench、go-ycsb和go-tpc分别对TiDB进行测试并且产出测试报告。  


## 解答：  
#### 一、规划TiDB集群部署
1. __部署配置__  
通过tiup在AliYun ECS单机部署，ECS配置信息：

    | 项 | 配置 | 说明 |
    |:----:|:----:|:----:|
    |架构|linux/x86_64|CentOS 7.6|
    |CPU|4 vCPU||
    |内存|8 GiB||
    |磁盘|SSD 40GiB||
2. __集群拓扑信息__

    | 实例 | 个数 | 物理机配置 |IP|配置|
    |:----:|:----:|:----:|:----:|:----:|
    |TiDB|1|4 vCPU 8 GiB|172.17.211.167:40001|
    |PD|1|4 vCPU 8 GiB|172.17.211.167:2380|
    |TiKV|3|4 vCPU 8 GiB|172.17.211.167:20170/20171/20172|
    |Monitoring|1|4 vCPU 8 GiB|172.17.211.167:9093|
    |Grafana|1|4 vCPU 8 GiB|172.17.211.167:3000|
    
#### 二、TiUp部署集群
1. __修改配置文件__  
    参考[最小拓扑架构](https://docs.pingcap.com/zh/tidb/stable/production-deployment-using-tiup)参照规划部署拓扑信息调整初始化部署文件，执行部署。  
    由于PD部署为内网IP，需要做Nginx反向代理到公网访问Dashboard，参考[TIDB Dashboard反向代理](https://docs.pingcap.com/zh/tidb/dev/dashboard-ops-reverse-proxy) 配置Dashboard访问。最终，通过Dashboard查阅TIDB集群部署情况：
    ![集群信息](http://g.ifocusad.com/r/c2/topology-dashboard.png)
    
    参考[TiKV线程池优化](https://github.com/pingcap-incubator/tidb-in-action/blob/master/session4/chapter8/threadpool-optimize.md)以及grafana监控图，调整集群部署配置信息。主要调整tikv线程池配置结果常见[tiup集群配置文件](./topology.yaml)。  
    修改后执行`tiup cluster restart tidbc2`重启集群，使用新配置文件。

#### 三、测试
1. __sysbench测试__
* __安装__  
参考[sysbench基准测试](https://github.com/pingcap-incubator/tidb-in-action/blob/master/session4/chapter3/sysbench.md) 安装、配置。
* __测试__  
1). 参考安装文档中数据准备，录入测试数据。  
2). 编写[测试脚本](./sysbench/start.sh)支持点查、只读、索引更新测3种试用例，并对并发线程在8、16、32、64、128测试输出结果。  
3). 整理测试结果。  
  ![sysbench oltp point select数据图](http://g.ifocusad.com/r/c2/sysbench-oltp-point-select-data.png)
  图1 sysbench oltp point select 数据图  

  ![sysbench oltp point selectTPS折线图](http://g.ifocusad.com/r/c2/sysbench-oltp-point-select-trend.png)
  图2 sysbench oltp point select TPS趋势图
  
  ![sysbench oltp update index数据图](http://g.ifocusad.com/r/c2/sysbench-oltp-update-index-data.png)
  图3 sysbench oltp update index 数据图
  
  ![sysbench oltp update indexTPS折线图](http://g.ifocusad.com/r/c2/sysbench-oltp-update-index-trend.png)
  图4 sysbench oltp update index TPS趋势图

  ![sysbench oltp read only数据图](http://g.ifocusad.com/r/c2/sysbench-oltp-read-only-data.png)
  图5 sysbench oltp read only 数据图
  
  ![sysbench oltp read onlyTPS折线图](http://g.ifocusad.com/r/c2/sysbench-oltp-read-only-trend.png)
  图6 sysbench oltp read only TPS趋势图
 
  此时对用dashboard 和 grafana上监控图如下：  
  ![dashboard qps and duration](http://g.ifocusad.com/r/c2/qps-duration-sysbench.png)
  图7 dashboard qps and duration test by sysbench
  
  ![grafana cluster grpc qps duration](http://g.ifocusad.com/r/c2/grafana-cluster-grpc-qps-duration-sysbench.png)
  图8 grafana cluster grpc qps duration test by sysbench
  
  ![grafana cluster serv cpu qps](http://g.ifocusad.com/r/c2/grafana-cluster-serv-cpu-qps-sysbench.png)
  图9 grafana cluster serv cpu qps test by sysbench

1. 隐藏  
2. __go-ycsb测试__
* __安装__
参考[pingcap/go-ycsb](https://github.com/pingcap/go-ycsb)安装、配置。  
*__测试__  
1). 参考安装文档，编写[配置文件](./go-ycsb/ycsb.conf)及[测试脚本](./go-ycsb/start.sh)，测试脚本包含不同workload a-f数据初始化及不同线程测试，并导出结果日志。  
2). 整理测试结果。  

  此时对用dashboard 和 grafana上监控图如下：  
  ![dashboard qps and duration](http://g.ifocusad.com/r/c2/qps-duration-goycsb.png)
  图10 dashboard qps and duration test by go-ycsb
  
  ![grafana cluster grpc qps duration](http://g.ifocusad.com/r/c2/grafana-cluster-grpc-qps-duration-ycsb.png)
  图11 grafana cluster grpc qps duration test by go-ycsb
  
  ![grafana cluster serv cpu qps](http://g.ifocusad.com/r/c2/grafana-cluster-serv-cpu-qps-ycsb.png)
  图12 grafana cluster serv cpu qps test by go-ycsb
