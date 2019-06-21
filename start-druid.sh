#!/bin/bash
set -e

# Abort if no server type is given
if [ "${1:0:1}" = '' ]; then
    echo "Aborting: No druid server type set!"
    exit 1
fi

DB_CONNECT_URI="jdbc:${DB_TYPE}\:\/\/${DB_HOST}\:${DB_PORT}\/${DB_DBNAME}"

sed -ri 's#druid.zk.service.host.*#druid.zk.service.host='${ZOOKEEPER_HOST}'#g' /opt/druid/conf/druid/_common/common.runtime.properties
sed -ri 's#druid.metadata.storage.type.*#druid.metadata.storage.type='${DB_TYPE}'#g' /opt/druid/conf/druid/_common/common.runtime.properties
sed -ri 's#druid.metadata.storage.connector.connectURI.*#druid.metadata.storage.connector.connectURI='${DB_CONNECT_URI}'#g' /opt/druid/conf/druid/_common/common.runtime.properties
sed -ri 's#druid.metadata.storage.connector.user.*#druid.metadata.storage.connector.user='${DB_USERNAME}'#g' /opt/druid/conf/druid/_common/common.runtime.properties
sed -ri 's#druid.metadata.storage.connector.password.*#druid.metadata.storage.connector.password='${DB_PASSWORD}'#g' /opt/druid/conf/druid/_common/common.runtime.properties

if [ "$DRUID_S3_ACCESS_KEY" != "" ]; then
    sed -ri 's#druid.s3.accessKey.*#druid.s3.accessKey='${DRUID_S3_ACCESS_KEY}'#g' /opt/druid/conf/druid/_common/common.runtime.properties
fi
if [ "$DRUID_S3_SECRET_KEY" != "" ]; then
    sed -ri 's#druid.s3.secretKey.*#druid.s3.secretKey='${DRUID_S3_SECRET_KEY}'#g' /opt/druid/conf/druid/_common/common.runtime.properties
fi

if [ "$DRUID_HOSTNAME" != "-" ]; then
    sed -ri 's/druid.host=.*/druid.host='${DRUID_HOSTNAME}'/g' /opt/druid/conf/druid/$1/runtime.properties
fi

if [ "$DRUID_LOGLEVEL" != "-" ]; then
    sed -ri 's/druid.emitter.logging.logLevel=.*/druid.emitter.logging.logLevel='${DRUID_LOGLEVEL}'/g' /opt/druid/conf/druid/_common/common.runtime.properties
fi

if [ "$DRUID_USE_CONTAINER_IP" != "-" ]; then
    ipaddress=`ip a|grep "global eth0"|awk '{print $2}'|awk -F '\/' '{print $1}'`
    sed -ri 's/druid.host=.*/druid.host='${ipaddress}'/g' /opt/druid/conf/druid/$1/runtime.properties
fi

if [ "$DRUID_STORAGE_TYPE" == "s3" ]; then
    sed -ri 's/druid.storage.type.*/druid.storage.type='${DRUID_STORAGE_TYPE}'/g' /opt/druid/conf/druid/_common/common.runtime.properties
    sed -ri 's#druid.storage.bucket.*#druid.storage.bucket='${DRUID_STORAGE_BUCKET}'#g' /opt/druid/conf/druid/_common/common.runtime.properties
    sed -ri 's#druid.storage.baseKey.*#druid.storage.baseKey='${DRUID_STORAGE_BASE_KEY}'#g' /opt/druid/conf/druid/_common/common.runtime.properties
fi

if [ "$DRUID_INDEXER_LOGS_TYPE" == "s3" ]; then
    sed -ri 's/druid.indexer.logs.type.*/druid.indexer.logs.type='${DRUID_INDEXER_LOGS_TYPE}'/g' /opt/druid/conf/druid/_common/common.runtime.properties
    sed -ri 's#druid.indexer.logs.s3Bucket.*#druid.indexer.logs.s3Bucket='${DRUID_INDEXER_LOGS_S3_BUCKET}'#g' /opt/druid/conf/druid/_common/common.runtime.properties
    sed -ri 's#druid.indexer.logs.s3Prefix.*#druid.indexer.logs.s3Prefix='${DRUID_INDEXER_LOGS_S3_PREFIX}'#g' /opt/druid/conf/druid/_common/common.runtime.properties
fi

# if [ "$DRUID_SEGMENTCACHE_LOCATION" != "-" ]; then
#     # sed -ri 's/druid.segmentCache.locations=[{"path":*,"maxSize"\:100000000000}]/druid.segmentCache.locations=[{"path":'${DRUID_SEGMENTCACHE_LOCATION}',"maxSize"\:100000000000}]/g' /opt/druid/conf/druid/$1/runtime.properties
#     sed -ri 's/var\/druid\/segment-cache/'${DRUID_SEGMENTCACHE_LOCATION}'/g' /opt/druid/conf/druid/$1/runtime.properties
# fi
#
# if [ "$DRUID_DEEPSTORAGE_LOCAL_DIR" != "-" ]; then
#     sed -ri 's/druid.storage.storageDirectory=.*/druid.storage.storageDirectory='${DRUID_DEEPSTORAGE_LOCAL_DIR}'/g' /opt/druid/conf/druid/_common/common.runtime.properties
# fi

java ${JAVA_OPTS} -cp /opt/druid/conf/druid/_common:/opt/druid/conf/druid/$1:/opt/druid/lib/* io.druid.cli.Main server $@
