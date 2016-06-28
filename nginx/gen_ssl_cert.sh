#! /bin/sh

mkdir -p ssl/seafile.example.com/

openssl req -x509 -newkey rsa:2048 -keyout ssl/seafile.example.com/privkey.pem -out ssl/seafile.example.com/fullchain.pem -days 365 -nodes -subj "/C=JP/L=Tokyo/O=Weyland-Yutani/OU=Org/CN=www.example.com"
