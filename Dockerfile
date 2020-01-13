FROM php:7.4.1-fpm-alpine

USER root

RUN apk update
RUN apk add --no-cache openssl bash nodejs npm postgresql-dev
RUN docker-php-ext-install pdo pdo_pgsql

# Add a non-root user to prevent files being created with root permissions on host machine.
ENV USER=laravel
ENV UID=1000
ENV GID=1000

RUN addgroup --gid "$GID" "$USER" \
    && adduser \
    --disabled-password \
    --gecos "" \
    --home "$(pwd)" \
    --ingroup "$USER" \
    --no-create-home \
    --uid "$UID" \
    "$USER"

###########################################################################
# Set Timezone
###########################################################################
ARG TZ=Etc/Gmt+3
ENV TZ ${TZ}
      
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /var/www

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=/usr/bin --filename=composer

COPY .docker/nginx/nginx.conf /etc/nginx/conf.d/

EXPOSE 80
ENTRYPOINT ["php-fpm"]
