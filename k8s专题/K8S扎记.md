# 前世今生
## Borg 简介
> Borg 是谷歌内部的大规模集群管理系统，负责对谷歌内部很多核心服务的调度和管理。Borg 的目的是让用户能够不必操心资源管理的问题，让他们专注于自己的核心业务，并且做到跨多个数据中心的资源利用率最大化。   
> Borg 主要由 BorgMaster、Borglet、borgcfg 和 Scheduler 组成，如下图所示   
![Borg架构](./images/Borg架构.png)