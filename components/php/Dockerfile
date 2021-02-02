FROM php:7.3-fpm-alpine
RUN docker-php-ext-install pdo pdo_mysql
COPY sendJob.php /public
COPY sendSession.php /public