# run on node 1
./install_etcd_cluster.sh install

ETCD_NAME=etcd1 \
ETCD_IP=10.67.1.122 \
ETCD_INITIAL_CLUSTER="etcd1=http://10.67.1.122:2380" \
ETCD_INITIAL_CLUSTER_STATE=new \
./install_etcd_cluster.sh join

etcdctl --endpoints=http://10.67.1.122:2379 member add etcd2 --peer-urls=http://10.67.2.181:2380

#run on node 2
ETCD_NAME=etcd2 \
ETCD_IP=10.67.2.181 \
ETCD_INITIAL_CLUSTER="etcd1=http://10.67.1.122:2380,etcd2=http://10.67.2.181:2380" \
ETCD_INITIAL_CLUSTER_STATE=existing \
./install_etcd_cluster.sh join

etcdctl --endpoints=http://10.67.1.122:2379,http://10.67.2.181:2379 endpoint health

etcdctl --endpoints=http://10.67.1.122:2379,http://10.67.2.181:2379 member add etcd3 --peer-urls=http://10.67.1.157:2380

#run on node 3
ETCD_NAME=etcd3 \
ETCD_IP=10.67.1.157 \
ETCD_INITIAL_CLUSTER="etcd1=http://10.67.1.122:2380,etcd2=http://10.67.2.181:2380,etcd3=http://10.67.1.157:2380" \
ETCD_INITIAL_CLUSTER_STATE=existing \
./install_etcd_cluster.sh join

etcdctl --endpoints=http://10.67.1.122:2379,http://10.67.2.181:2379,http://10.67.1.157:2379 endpoint health

etcdctl --endpoints=http://10.67.1.122:2379,http://10.67.2.181:2379,http://10.67.1.157:2379 member list

etcdctl --endpoints=http://10.67.1.122:2379,http://10.67.2.181:2379,http://10.67.1.157:2379 member add etcd4 --peer-urls=http://10.67.2.102:2380

#run on node 4
ETCD_NAME=etcd4 \
ETCD_IP=10.67.2.102 \
ETCD_INITIAL_CLUSTER="etcd1=http://10.67.1.122:2380,etcd2=http://10.67.2.181:2380,etcd3=http://10.67.1.157:2380,etcd4=http://10.67.2.102:2380" \
ETCD_INITIAL_CLUSTER_STATE=existing \
./install_etcd_cluster.sh join

etcdctl --endpoints=http://10.67.1.122:2379,http://10.67.2.181:2379,http://10.67.1.157:2379,http://10.67.2.102:2379 endpoint health

etcdctl --endpoints=http://10.67.1.122:2379,http://10.67.2.181:2379,http://10.67.1.157:2379,http://10.67.2.102:2379 member list
