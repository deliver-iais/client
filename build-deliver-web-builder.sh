WEB_BUILDER=2.1.0

sudo docker build -t 172.17.4.40:443/deliver-web-builder:$WEB_BUILDER -f builder.dockerfile .
docker push 172.17.4.40:443/deliver-web-builder:$WEB_BUILDER