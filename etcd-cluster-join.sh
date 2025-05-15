ETCD_NAME=sme-etcd-01 \
ETCD_IP=10.101.207.13 \
ETCD_INITIAL_CLUSTER="sme-etcd-01=http://10.101.207.13:2380" \
ETCD_INITIAL_CLUSTER_STATE=new \
./install_etcd_cluster.sh join

etcdctl --endpoints=http://10.101.207.13:2379 member add sme-etcd-02 --peer-urls=http://10.101.207.14:2380

ETCD_NAME="sme-etcd-02" \
ETCD_IP=10.101.207.14 \
ETCD_INITIAL_CLUSTER="sme-etcd-01=http://10.101.207.13:2380,sme-etcd-02=http://10.101.207.14:2380" \
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://10.101.207.14:2380" \
ETCD_INITIAL_CLUSTER_STATE="existing" \
./install_etcd_cluster.sh join

etcdctl --endpoints=http://10.101.207.13:2379 member add sme-etcd-03 --peer-urls=http://10.101.207.15:2380

ETCD_NAME="sme-etcd-03" \
ETCD_IP=10.101.207.15 \
ETCD_INITIAL_CLUSTER="sme-etcd-01=http://10.101.207.13:2380,sme-etcd-02=http://10.101.207.14:2380,sme-etcd-03=http://10.101.207.15:2380" \
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://10.101.207.15:2380" \
ETCD_INITIAL_CLUSTER_STATE="existing" \
./install_etcd_cluster.sh join

etcdctl --endpoints=http://10.101.207.13:2379,http://10.101.207.14:2379,http://10.101.207.15:2379 endpoint health
