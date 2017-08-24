#!/bin/bash
sed   -i  's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config       #Disable selinux

###Nginx installation and configuration ####
rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm 
yum   -y install nginx
systemctl enable nginx
systemctl start nginx

### Adding configuration for proxy pass ###
cat << 'EOF' > /etc/nginx/conf.d/default.conf
server {
        listen   80; 

        root /usr/share/nginx/html/; 
        index index.php index.html index.htm;

        server_name _; 

        location / {
        try_files $uri $uri/ /index.php;
        }

        location ~ \.php$ {
        
        proxy_set_header X-Real-IP  $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header Host $host;
        proxy_pass http://127.0.0.1:8080;

         }

         location ~ /\.ht {
                deny all;
        }
}
EOF

#### Apache installation ###
yum -y install httpd
sed -i  's/^Listen.*/Listen 127.0.0.1:8080/g'   /etc/httpd/conf/httpd.conf
sed -i 's/^DocumentRoot.*/DocumentRoot \"\/usr\/share\/nginx\/html\/\"/g' /etc/httpd/conf/httpd.conf
systemctl enable httpd
systemctl start httpd
setsebool -P httpd_can_network_connect 1

###PHP installation and setting up info page as index.php###
yum -y install php
cat << 'EOF' > /usr/share/nginx/html/index.php
<?php phpinfo(); ?>
EOF
