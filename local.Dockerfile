FROM nginx:1.23.3-alpine

COPY ./build/web/ /usr/share/nginx/html/
