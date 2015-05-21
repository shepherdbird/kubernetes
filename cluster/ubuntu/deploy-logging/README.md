Automated deploy fluentd and elasticsearch on ubuntu.
We assume the node name of kubernetes cluster is ip address.Every nodes'username and password are vcap and password,you can change them in pos_file.sh.
fluentd-elasticsearch version:1.5
elasticsearch version:1.0
Step 0:
run sudo ./deploy-fluentd.sh will Automated deploy fluentd.
deploy-fluentd.sh:
#!/bin/bash
kubectl get nodes | awk '{
  if(NR>=2){
    system("kubectl label nodes "$1" node_id=m"NR-1" --overwrite=true");
    system("sed -i s/node_id:.*$/node_id:\\ m"NR-1"/g ./fluentdv3.yaml");
    system("sed -i s/fluentd[0-9]+*$/fluentd"NR-1"/g ./fluentdv3.yaml");
    system("sed -i s/fluentd-logging.*$/fluentd-logging"NR-1"/g ./fluentdv3.yaml");
    system("./pos_file.sh "$1);
    system("kubectl create -f ./fluentdv3.yaml");
  }
}'
Firstly,we will add the label(node_id=m*) for every node.For example,we will add the label node_id=m1 for first node.Secondly,we will modify fluentdv3.yaml to deploy fluentd for every node.Thirdly,excute pos_file.sh to create /varlog for every node.At last,run kubectl create -f ./fluentdv3.yaml to create ReplicationController.
pos_file.sh:
#!/bin/bash
ip="$1"
/usr/bin/expect <<-EOF
set timeout 3
spawn ssh vcap@$ip
expect {
    "yes/no" {send "yes\r";exp_continue}
    "password" {send "password\r";exp_continue}
    "login" {send "sudo mkdir -p /varlog && sudo touch -f  /varlog/es-kubelet.log.pos && sudo touch -f  /varlog/es-containers.log.pos\r";exp_continue}
   eof exit
}
EOF
pos_file.sh will login every node through username and password,then create directory /varlog and file es-kubelet.log.pos,es-containers.log.pos in /varlog.We do that to ensure the container fluentd's normal opration.
Step 1:
kubectl create ./es-controller.yaml to run elasticsearch.
Step 2:
kubectl create ./es-service.yaml15.yaml to create service for elasticsearch.
