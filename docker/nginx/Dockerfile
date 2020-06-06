FROM nginx:1.17.9-alpine

RUN apk add --update apache2-utils

ENV NGINX_DIR /nginx

EXPOSE 80 443

COPY docker/nginx/ssl/*.pem /etc/ssl/certs/
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

WORKDIR $NGINX_DIR

COPY docker/nginx/docker-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
