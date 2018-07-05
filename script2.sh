#! /bin/bash

# yum -y install vim net-tools

echo "Zabbix Agent Installation and Configuration"

yum -y install http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
yum -y install zabbix-agent
sed -i -e '/ServerActive=127.0.0.1/s/^/#\ /' /etc/zabbix/zabbix_agentd.conf
sed -i -e '/Server=127.0.0.1/s/127.0.0.1/192.168.33.11/' /etc/zabbix/zabbix_agentd.conf
systemctl start zabbix-agent

