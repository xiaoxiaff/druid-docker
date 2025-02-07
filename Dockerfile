# VERSION 0.12.3-2
FROM anapsix/alpine-java:8_server-jre_unlimited

MAINTAINER Maciej Brynski <maciek@brynski.pl>
# Forked from https://github.com/saidimu/druid-docker

# ENV DB_HOST            mysql
# ENV DB_PORT            3306
# ENV DB_DBNAME          druid
# ENV DB_USERNAME        druid
# ENV DB_PASSWORD        druid
# ENV ZOOKEEPER_HOST     zookeeper
# ENV S3_STORAGE_BUCKET  druid-deep-storage
# ENV S3_INDEXING_BUCKET druid-indexing
# ENV S3_ACCESS_KEY      xxxxxxxxxxxx
# ENV S3_ACCESS_KEY      xxxxxxxxxxxx
ENV DRUID_VERSION      0.12.3

# Druid env variable
ENV DRUID_XMX          '-'
ENV DRUID_XMS          '-'
ENV DRUID_NEWSIZE      '-'
ENV DRUID_MAXNEWSIZE   '-'
ENV DRUID_HOSTNAME     '-'
ENV DRUID_LOGLEVEL     '-'
ENV DRUID_USE_CONTAINER_IP '-'
ENV DRUID_SEGMENTCACHE_LOCATION  '-'
ENV DRUID_DEEPSTORAGE_LOCAL_DIR  '-'

RUN apk update \
    && apk add --no-cache bash curl \
    && mkdir /tmp/druid \
    && curl \
    http://apache.claz.org/incubator/druid/0.14.2-incubating/apache-druid-0.14.2-incubating-bin.tar.gz  | tar -xzf - -C /opt \
    && ln -s /opt/apache-druid-0.14.2-incubating /opt/druid
RUN curl http://static.druid.io/artifacts/releases/mysql-metadata-storage-$DRUID_VERSION.tar.gz | tar -xzf - -C /tmp
RUN cp /tmp/mysql-metadata-storage/mysql-connector-java-5.1.38.jar /opt/druid/extensions/mysql-metadata-storage/

COPY conf /opt/druid/conf
COPY start-druid.sh /start-druid.sh

ENTRYPOINT ["/start-druid.sh"]
