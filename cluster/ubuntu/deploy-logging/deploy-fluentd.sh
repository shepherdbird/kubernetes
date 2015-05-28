#!/bin/bash
kubectl get nodes | awk '{
  if(NR>=2){
    system("kubectl label nodes "$1" node_id=m"NR-1" --overwrite=true");
    system("sed -r -i s/m[0-9]+/m"NR-1"/g ./newfluentd.json");
    system("sed -r -i s/fluentd[0-9]+/fluentd"NR-1"/g ./newfluentd.json");
    system("sed -r -i s/fluentd-logging[0-9]+/fluentd-logging"NR-1"/g ./newfluentd.json");
    system("./ex.sh "$1);
    system("kubectl create -f ./newfluentd.json");
  }
}'
#system("./ex.sh "$1);
