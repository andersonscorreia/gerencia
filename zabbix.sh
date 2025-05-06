#!/bin/bash

# Baixa o pacote de release do Zabbix
wget https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-5+debian12_all.deb

# Instala o pacote de release do Zabbix
dpkg -i zabbix-release_6.0-5+debian12_all.deb

# Atualiza a lista de pacotes
apt update

# Instala os pacotes necessários do Zabbix e MariaDB
apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent mariadb-server

# MySQL root password (replace with your actual password)
MYSQL_ROOT_PASSWORD="123456"
# Zabbix database password (replace with your desired password)
ZABBIX_DB_PASSWORD="123456"

# Connect to MySQL as root and create the Zabbix database and user
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" << EOF
create database zabbix character set utf8mb4 collate utf8mb4_bin;
create user zabbix@localhost identified by '$ZABBIX_DB_PASSWORD';
grant all privileges on zabbix.* to zabbix@localhost;
set global log_bin_trust_function_creators = 1;
quit
EOF

# Import the Zabbix SQL schema
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p"$ZABBIX_DB_PASSWORD" zabbix

# Reset the log_bin_trust_function_creators variable
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" << EOF
set global log_bin_trust_function_creators = 0;
quit
EOF

# Configure the Zabbix server's database settings
sed -i "s/# DBPassword=.*/DBPassword=$ZABBIX_DB_PASSWORD/" /etc/zabbix/zabbix_server.conf

# Reinicia os serviços
systemctl restart zabbix-server zabbix-agent apache2

# Habilita os serviços para iniciar automaticamente
systemctl enable zabbix-server zabbix-agent apache2

# Exibe informações sobre o status do Zabbix Server
systemctl status zabbix-server

echo "Instalação do Zabbix concluída com sucesso!"
