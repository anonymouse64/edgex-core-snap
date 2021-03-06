#!/bin/sh
set -x

if [ `arch` = "aarch64" ] ; then
    ARCH="arm64"
elif [ `arch` = "x86_64" ] ; then
    ARCH="amd64"
else
    echo "Unsupported architecture: `arch`"
    exit 1
fi

JAVA="$SNAP/usr/lib/jvm/java-8-openjdk-$ARCH/jre/bin/java"

MAX_TRIES=10

while [ "$MAX_TRIES" -gt 0 ] ; do
    CONSUL_RUNNING=`curl http://localhost:8500/v1/catalog/service/consul`

    if [ $? -ne 0] ||
       [ -z $CONSUL_RUNNING ] ||
       [ "$CONSUL_RUNNING" = "[]" ] || [ "$CONSUL_RUNNING" = "" ]; then
	echo "core-config-seed: consul not running; remaing tries: $MAX_TRIES\n"
	sleep 5
	MAX_TRIES=`expr $MAX_TRIES - 1`
    else
	break
    fi
done

# start config-seed if consul is up
#
# TODO: this success check could be improved...
if [ $CONSUL_RUNNING != "[]" ] ; then
    cd $SNAP/jar/config-seed/

    $JAVA -jar -Djava.security.egd=file:/dev/urandom -Xmx100M \
        $SNAP/jar/config-seed/core-config-seed.jar


fi

    




