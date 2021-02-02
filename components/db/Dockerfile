FROM mariadb:latest
COPY veeamAPI.sql /
ENV MYSQL_ALLOW_EMPTY_PASSWORD: "yes"
ENV MYSQL_ROOT_PASSWORD: ""
CMD mysql start
RUN mysql -uroot -p  < veeamAPI.sql