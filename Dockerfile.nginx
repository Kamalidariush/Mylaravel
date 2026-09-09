FROM nginx:alpine

WORKDIR /var/www/html

COPY public /var/www/html/public

COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80