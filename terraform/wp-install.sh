#!/bin/bash
#sudo su - root

wpdir=/var/www/html
content=$wpdir/wp-content

# AUTOMATIC WORDPRESS INSTALLER IN  AWS LINUX 2 AMI

# install LAMP Server
yum update -y
#install apache server
yum install -y httpd amazon-efs-utils
 
#since amazon ami 2018 is no longer supported ,to install latest php and mysql we have to do some tricks.
#first enable php7.xx from  amazon-linux-extra and install it

amazon-linux-extras enable php7.4
yum clean metadata
yum install -y php php-{pear,cgi,common,curl,mbstring,gd,mysqlnd,gettext,bcmath,json,xml,fpm,intl,zip,imap,devel}
#install imagick extension
yum -y install gcc ImageMagick ImageMagick-devel ImageMagick-perl
pecl install imagick
chmod 755 /usr/lib64/php/modules/imagick.so
cat <<EOF >>/etc/php.d/20-imagick.ini

extension=imagick

EOF

systemctl restart php-fpm.service

#and download mysql package to yum  and install mysql server from yum
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum localinstall -y https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
yum install -y mysql-community-server

sleep 1m

# Mounting EFS
mkdir -p $content/

mount -t efs ${EFS_NAME}:/ $content/
# Edit fstab so EFS automatically loads on reboot
echo ${EFS_NAME}:/ $content efs defaults,_netdev 0 0 >> /etc/fstab

echo "$(hostname -I)" > $wpdir/health

systemctl start httpd
systemctl start mysqld

# Change OWNER and permission of directory /var/www
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;

# Download wordpress package and extract
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* $wpdir

mysql -u"${DB_USER}" -p"${DB_PASSWORD}" -h "${DB_HOST}" -e "create database ${DB_NAME}";

# AWSAuthenticationPlugin supported only for Aurora
#mysql -u"${DB_USER}" -p"${DB_PASSWORD}" -h "${DB_HOST}" -e "CREATE USER '${DB_IAM}' IDENTIFIED WITH AWSAuthenticationPlugin as 'RDS' REQUIRE SSL";

# Create wordpress configuration file and update database value
cd $wpdir
cp wp-config-sample.php wp-config.php

sed -i "s/database_name_here/${DB_NAME}/g" wp-config.php
sed -i "s/username_here/${DB_USER}/g" wp-config.php
sed -i "s/password_here/${DB_PASSWORD}/g" wp-config.php
sed -i "s/localhost/${DB_HOST}/g" wp-config.php

cat <<EOF >>$wpdir/wp-config.php

define('FS_METHOD', 'direct');
define('WP_MEMORY_LIMIT', '256M');
EOF

# wp-cli easy way install
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
mv wp-cli.phar wp
chmod +x wp
./wp core install --url="${ELB_NAME}" --title="${WP_TITLE}" --admin_user="${WP_USER}" --admin_password="${WP_PASS}" --admin_email="${WP_EMAIL}" --allow-root
rm -rf ./wp

# Change permission of /var/www/html/
chown -R ec2-user:apache $wpdir
chmod -R 774 $content

#  enable .htaccess files in Apache config using sed command
sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride all/' /etc/httpd/conf/httpd.conf

#Make apache and mysql to autostart and restart apache
systemctl enable  httpd.service
systemctl enable mysqld.service
systemctl restart httpd.service