#! /bin/bash

echo "Installing and Configuring MariaDB"

yum -y install mariadb mariadb-server
/usr/bin/mysql_install_db --user=mysql
systemctl start mariadb
sleep 5
  mysql -uroot << EOF
  create database zabbix character set utf8 collate utf8_bin;
  grant all privileges on zabbix.* to zabbix@localhost identified by 'mishok';
EOF

echo "Installing and Configuring Zabbix Server"

yum -y install http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
yum -y install zabbix-server-mysql zabbix-web-mysql
zcat /usr/share/doc/zabbix-server-mysql-*/create.sql.gz | mysql -uzabbix -pmishok zabbix
sed -i -e '/DBPassword=/s/#\ DBPassword=/DBPassword=mishok/' /etc/zabbix/zabbix_server.conf
systemctl start zabbix-server
sleep 10

echo "Front-end Configuration"

sed -i -e '/date.timezone/s/#\ php_value\ date.timezone\ Europe\/Riga/php_value\ date.timezone\ Europe\/Minsk/' /etc/httpd/conf.d/zabbix.conf
sed -i -e "\$a\<VirtualHost\ *:80>\nDocumentRoot\ \/usr\/share\/zabbix\n<\/VirtualHost>" /etc/httpd/conf.d/zabbix.conf
cp /vagrant/zabbix.conf.php /etc/zabbix/web
systemctl start httpd
sleep 5

echo "Zabbix Agent Installation and Configuration on the Server"

yum -y install zabbix-agent
sed -i -e '/ServerActive=127.0.0.1/s/^/#\ /' /etc/zabbix/zabbix_agentd.conf
systemctl start zabbix-agent





