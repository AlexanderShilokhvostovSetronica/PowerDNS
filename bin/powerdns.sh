#!/bin/bash

action=$1; shift
params=$@; shift

docker_name="powerdns"
powerdns_data_dir="/opt/PowerDNS/data"
zone="ru-nsk-1.test.k8s.tradeshift.net"

powerdns_running=$(docker ps -f name=${docker_name} -f status=running -q)
powerdns_exited=$(docker ps -f name=${docker_name} -f status=exited -q)

function START_CONTAINER {
    echo -en "The containtr id = "
    docker run -d \
        --name ${docker_name} \
        -v ${powerdns_data_dir}:/data \
        --env ENABLE_CATCH_ALL=yes \
        -p 0.0.0.0:53000:53000 \
        -p 0.0.0.0:8053:53/udp \
        -p 0.0.0.0:8053:53 \
        -p 0.0.0.0:8081:8081 \
        powerdns:sqlite3 --gsqlite3-pragma-foreign-keys=yes
}

if [ ! -d ${powerdns_data_dir} ]; then
    mkdir -p ${powerdns_data_dir}
fi

if [ "X${action}" == "Xcreate-zone" ]; then
    docker exec -it ${docker_name} sh -c "pdnsutil create-zone ${zone} ns1.${zone}; pdnsutil add-record ${zone} ns1 A 10.0.4.1"
    exit 0
elif [ "X${action}" == "Xlist-zone" ]; then
    docker exec -it ${docker_name} sh -c "pdnsutil list-zone ${zone}"
    ## example
    ## powerdns.sh list-zone zone.local
    exit 0
elif [ "X${action}" == "Xadd-record" ]; then
    docker exec -it ${docker_name} sh -c "pdnsutil add-record ${zone} ${params}"
    ## example
    ## powerdns.sh add-record zone.local ns1 A 10.0.4.1
    exit 0
elif [ "${action}" ]; then
    docker ${action} ${params} ${docker_name}
    exit 0
fi

if [ ${powerdns_running} ]; then
    echo "The container '${docker_name}' is running. Exited."
    exit 0
elif [ ${powerdns_exited} ]; then
    echo "The container'${docker_name}' is stoped. Running ..."
    docker start ${docker_name}
    exit 0
elif [ -z ${powerdns_running} -a -z ${powerdns_exited} ]; then
    echo "The container '${docker_name}' id not running. Starting ... "
    START_CONTAINER
    exit 0
fi

echo "Something went wrong."
exit 1
