#! /bin/bash

#echo "Zabbix Agent Installation and Configuration"

yum -y install http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
yum -y install zabbix-agent
sed -i -e '/ServerActive=127.0.0.1/s/^/#\ /' /etc/zabbix/zabbix_agentd.conf
sed -i -e '/Server=127.0.0.1/s/127.0.0.1/192.168.33.14/' /etc/zabbix/zabbix_agentd.conf
systemctl start zabbix-agent

path=/home/vagrant
hostname=$(hostname)

#Generate an authentication token
curl -d '{"jsonrpc": "2.0","method": "user.login","params": {"user":"Admin","password":"zabbix"},"id": 1}' -H "Content-Type: application/json-rpc" -X POST http://192.168.33.13/api_jsonrpc.php > $path/token.tmp
token=$(sed -e 's/^.*"result":"\([^"]*\)".*$/\1/' $path/token.tmp)

#Create Host Group CloudHosts if it does not exist
curl -d '{"jsonrpc": "2.0","method": "hostgroup.get","params": {"output": "extend","filter": {"name":"CloudHosts"}},"auth": "'$token'","id": 1}' -H "Content-Type: application/json-rpc" -X POST http://192.168.33.13/api_jsonrpc.php > $path/group.tmp

if ! grep 'CloudHosts' $path/group.tmp; 
  then
    curl -d '{"jsonrpc": "2.0","method": "hostgroup.create","params": {"name":"CloudHosts"},"auth": "'$token'","id": 1}' -H "Content-Type: application/json-rpc" -X POST http://192.168.33.13/api_jsonrpc.php > $path/group.tmp
    group=$(sed -e 's/^.*"groupids":\["\([^"]*\)"\].*$/\1/' $path/group.tmp)
fi

#Create a Custom template
curl -d '{"jsonrpc": "2.0","method": "template.create","params":{"host":"CustomTemplate","groups": {"groupid": "'$group'"}},"auth": "'$token'","id":1}' -H "Content-Type: application/json-rpc" -X POST http://192.168.33.13/api_jsonrpc.php > $path/template.tmp
template=$(sed -e 's/^.*"templateids":\["\([^"]*\)"\].*$/\1/' $path/template.tmp)

#Create a Host
curl -d '{"jsonrpc": "2.0","method": "host.create","params":{"host":"'$hostname'","interfaces": [{"type": 1,"main": 1,"useip": 1,"ip": "192.168.33.14","dns": "","port": "10050"}],"groups":[{"groupid": "'$group'"}],"templates": [{"templateid":"'$template'"}]},"auth": "'$token'","id": 1}' -H "Content-Type: application/json-rpc" -X POST http://192.168.33.13/api_jsonrpc.php


