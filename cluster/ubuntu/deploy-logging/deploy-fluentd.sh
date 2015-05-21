#!/bin/bash
kubectl get nodes | awk '{
  if(NR>=2){
    system("kubectl label nodes "$1" node_id=m"NR-1" --overwrite=true");
    system("sed -i s/node_id:.*$/node_id:\\ m"NR-1"/g ./fluentdv3.yaml");
    system("sed -i s/fluentd[0-9]+*$/fluentd"NR-1"/g ./fluentdv3.yaml");
    system("sed -i s/fluentd-logging.*$/fluentd-logging"NR-1"/g ./fluentdv3.yaml");
    system("kubectl create -f ./fluentdv3.yaml");
  }
}'
#system("./ex.sh "$1);
