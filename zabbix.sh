#!/bin/bash

# Baixa o pacote de release do Zabbix
wget https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-5+debian12_all.deb

# Instala o pacote de release do Zabbix
dpkg -i zabbix-release_6.0-5+debian12_all.deb

# Atualiza a lista de pacotes
apt update

# Instala os pacotes necessários do Zabbix e MariaDB
apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent mariadb-server

# Configura o MariaDB
mysql -uroot -p <<MYSQL_SCRIPT
123456
create database zabbix character set utf8mb4 collate utf8mb4_bin;
create user zabbix@localhost identified by '123456';
grant all privileges on zabbix.* to zabbix@localhost;
set global log_bin_trust_function_creators = 1;
quit;
MYSQL_SCRIPT

# Importa o esquema do banco de dados do Zabbix
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix

# Desativa a opção log_bin_trust_function_creators
mysql -uroot -p <<MYSQL_SCRIPT
set global log_bin_trust_function_creators = 0;
quit;
MYSQL_SCRIPT

# Atualiza a senha no arquivo de configuração do Zabbix Server
sed -i 's/# DBPassword=/DBPassword=123456/' /etc/zabbix/zabbix_server.conf

# Reinicia os serviços
systemctl restart zabbix-server zabbix-agent apache2

# Habilita os serviços para iniciar automaticamente
systemctl enable zabbix-server zabbix-agent apache2

echo "Instalação do Zabbix concluída com sucesso!"