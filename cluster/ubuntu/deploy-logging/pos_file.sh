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
