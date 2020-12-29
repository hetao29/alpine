FROM alpine:3.10
LABEL maintainer="Hetao<hetao@hetao.name>"
RUN buildDeps='nginx php7-fpm php7-imap php7-mbstring php7-json php7-common php7-ldap php7-pecl-redis php7-pecl-mcrypt php7-ldap php7-pdo_mysql php7-mysqlnd php7-mysqli php7-bcmath php7-curl php7-opcache php7-gd php7-xml php7-simplexml php7-iconv php7-openssl php7-pecl-imagick php7-session php7-zip php7-ftp php7-pcntl php7-sockets php7-gettext php7-exif php7-tokenizer tzdata make g++ m4 automake libtool linux-headers gcc autoconf php7-pear php7-dev zip composer git' \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update \
    && apk add $buildDeps  \ 
	&& pecl install protobuf \
	&& pecl install grpc \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && mkdir -p /data/www

WORKDIR /data/www/
COPY docker/start.sh start.sh
COPY docker/nginx/nginx.conf /etc/nginx/
COPY docker/nginx/sites-enabled/* /etc/nginx/sites-enabled/
COPY docker/fpm/php.ini /etc/php7/php.ini
COPY docker/fpm/php-fpm.conf /etc/php7/php-fpm.conf
COPY docker/fpm/pool.d/www.conf /etc/php7/php-fpm.d/www.conf
RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

HEALTHCHECK --interval=5s --timeout=5s --retries=3 \
    CMD ps aux | grep "php-fpm:" | grep -v "grep" > /dev/null; if [ 0 != $? ]; then exit 1; fi
EXPOSE 80
CMD ["/bin/sh","/data/www/start.sh"]
