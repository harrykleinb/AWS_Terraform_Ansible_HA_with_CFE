#!/bin/bash

sudo docker network create internal

sudo docker run -dit -h mainapp --name=mainapp --net=internal registry.gitlab.com/arcadia-application/main-app/mainapp:latest

sudo docker run -dit -h backend --name=backend --net=internal registry.gitlab.com/arcadia-application/back-end/backend:latest

sudo docker run -dit -h app2 --name=app2 --net=internal registry.gitlab.com/arcadia-application/app2/app2:latest

sudo docker run -dit -h app3 --name=app3 --net=internal registry.gitlab.com/arcadia-application/app3/app3:latest

sudo touch /home/ubuntu/default.conf

sudo cat > /home/ubuntu/default.conf << EOF

# NGINX config file to publish the 4 micro services in dockers

upstream mainapp {
        server mainapp;
}

upstream backend {
        server backend;
}

upstream app2 {
        server app2;
}

upstream app3 {
        server app3;
}

server {
    listen       80 default_server;

    #charset koi8-r;
    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        proxy_pass http://mainapp/;
    }

    location /files {
        proxy_pass http://backend/files/;
    }

    location /api {
        proxy_pass http://app2/api/;
    }

    location /app3 {
        proxy_pass http://app3/app3/;
    }

    #error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    # proxy the PHP scripts to Apache listening on 127.0.0.1:80
    #
    #location ~ \.php$ {
    #    proxy_pass   http://127.0.0.1;
    #}
    }

EOF


sudo docker run -dit -h nginx --name=nginx --net=internal -p 80:80 -v /home/ubuntu/default.conf:/etc/nginx/conf.d/default.conf registry.gitlab.com/arcadia-application/nginx/nginxoss:latest


