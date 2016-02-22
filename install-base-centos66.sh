#!/bin/bash
# Huong dan: Go lenh curl o duoi trong terminal ssh
# curl https://raw.githubusercontent.com/phc-itt/Linux-Tools/master/install-base-centos66.sh | sh
dbUsername="postgres"
dbPassword="123456"

cd ~
curl -O http://vault.centos.org/RPM-GPG-KEY-CentOS-6

#Install base package
yum install -y wget nano git tree zip unzip tar man gcc gcc-c++ make

#Add repo
cd /etc/yum.repos.d
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
wget http://rpms.famillecollet.com/enterprise/remi.repo
wget https://raw.githubusercontent.com/kimthangatm/linux-tools/master/src/nginx.repo
rpm -Uvh epel-release-6*.rpm
echo "y" | yum localinstall http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-centos94-9.4-1.noarch.rpm
echo "y" | yum --enablerepo=remi,remi-php56 install -y perl zip unzip nginx redis postgresql94-server postgresql94-contrib postgresql94-libs postgresql94-devel memcached php php-devel pcre-devel php-fpm php-pdo php-mcrypt php-redis php-pgsql php-gd php-xml php-recode php-mbstring php-mysql php-intl php-opcache php-pear php-pecl-memcache php-pecl-memcached php-apc libxml2-devel

service postgresql-9.4 initdb
sed -i '18iexclude=postgresql*' /etc/yum.repos.d/CentOS-Base.repo
sed -i '28iexclude=postgresql*' /etc/yum.repos.d/CentOS-Base.repo
sed -i '10i-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT' /etc/sysconfig/iptables
sed -i '10i-A INPUT -p tcp -m state --state NEW -m tcp --dport 3001 -j ACCEPT' /etc/sysconfig/iptables
sed -i '11i-A INPUT -p tcp -m state --state NEW -m tcp --dport 5432 -j ACCEPT' /etc/sysconfig/iptables
perl -i -pe 's/ident/md5/g' /var/lib/pgsql/9.4/data/pg_hba.conf
echo "host  all  all  0.0.0.0/0  md5" >> /var/lib/pgsql/9.4/data/pg_hba.conf
echo "listen_addresses='*'" >> /var/lib/pgsql/9.4/data/postgresql.conf
ln -s /usr/pgsql-9.4/bin/pg_config /usr/bin/pg_config
chkconfig postgresql-9.4 on
service postgresql-9.4 start
su postgres -c "psql --command \"ALTER USER $dbUsername WITH PASSWORD '$dbPassword'\"";
setsebool -P httpd_can_network_connect 1
service iptables restart
service redis start

rm -fr /etc/php.ini
cd /etc/
wget https://raw.githubusercontent.com/kimthangatm/linux-tools/master/src/php.ini

chkconfig php-fpm on
chkconfig redis on
chkconfig postgresql-9.4 on
chkconfig nginx on

cd ~
wget https://nodejs.org/dist/v4.3.1/node-v4.3.1-linux-x64.tar.gz
tar -xvzf node-v4.3.1-linux-x64.tar.gz
mv node-v4.3.1-linux-x64 /opt/nodejs

ln -s /opt/nodejs/bin/node /usr/bin/node
ln -s /opt/nodejs/bin/npm /usr/bin/npm

npm install express-generator -g
npm install pm2 -g
npm install nodemon -g

ln -s /opt/nodejs/bin/pm2 /usr/bin/pm2
ln -s /opt/nodejs/bin/nodemon /usr/bin/nodemon

echo "-----------------------------------------------"
echo "-----------  INSTALL SUCCESSFULLY  ------------"
echo "-----------------------------------------------"
echo "-----------------------------------------------"
echo "- DB INFO:                                    -"
echo "- DB USERNAME   : postgres                    -"
echo "- DB PASSWORD   : 123456                      -"
echo "-----------------------------------------------"
