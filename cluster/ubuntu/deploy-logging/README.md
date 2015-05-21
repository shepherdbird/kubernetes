Automated deploy fluentd and elasticsearch on ubuntu.<br>
We assume the node name of kubernetes cluster is ip address.Every nodes'username and password are vcap and password,you can change them in pos_file.sh.<br>
fluentd-elasticsearch version:1.5<br>
elasticsearch version:1.0<br>
Step 0:<br>
run sudo ./deploy-fluentd.sh will Automated deploy fluentd.<br>
deploy-fluentd.sh:<br>
\#!/bin/bash<br>
kubectl get nodes | awk '{<br>
  if(NR>=2){<br>
    system("kubectl label nodes "$1" node_id=m"NR-1" --overwrite=true");<br>
    system("sed -i s/node_id:.\*$/node_id:\\\ m"NR-1"/g ./fluentdv3.yaml");<br>
    system("sed -i s/fluentd[0-9]+\*$/fluentd"NR-1"/g ./fluentdv3.yaml");<br>
    system("sed -i s/fluentd-logging.\*$/fluentd-logging"NR-1"/g ./fluentdv3.yaml");<br>
    system("./pos_file.sh "$1);<br>
    system("kubectl create -f ./fluentdv3.yaml");<br>
  }<br>
}'<br>
Firstly,we will add the label(node_id=m*) for every node.For example,we will add the label node_id=m1 for first node.Secondly,we will modify fluentdv3.yaml to deploy fluentd for every node.Thirdly,excute pos_file.sh to create /varlog for every node.At last,run kubectl create -f ./fluentdv3.yaml to create ReplicationController.<br>
pos_file.sh:<br>
\\#!/bin/bash
ip="$1"<br>
/usr/bin/expect <<-EOF<br>
set timeout 3<br>
spawn ssh vcap@$ip<br>
expect {<br>
    "yes/no" {send "yes\r";exp_continue}<br>
    "password" {send "password\r";exp_continue}<br>
    "login" {send "sudo mkdir -p /varlog && sudo touch -f  /varlog/es-kubelet.log.pos && sudo touch -f <br> /varlog/es-containers.log.pos\r";exp_continue}<br>
   eof exit<br>
}<br>
EOF<br>
pos_file.sh will login every node through username and password,then create directory /varlog and file es-kubelet.log.pos,es-containers.log.pos in /varlog.We do that to ensure the container fluentd's normal opration.<br>
Step 1:<br>
kubectl create ./es-controller.yaml to run elasticsearch.<br>
Step 2:<br>
kubectl create ./es-service.yaml15.yaml to create service for elasticsearch.<br>
