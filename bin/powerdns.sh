#!/bin/bash

action=$1; shift
params=$@; shift

docker_name="powerdns"
#powerdns_data_dir="/data/PowerDNS/data"
zone="ru-nsk-1.dev.k8s"
ns_ip="10.0.4.1"

powerdns_running=$(docker ps -f name=${docker_name} -f status=running -q)
powerdns_exited=$(docker ps -f name=${docker_name} -f status=exited -q)

#        -v ${powerdns_data_dir}:/data \

function START_CONTAINER {
    echo -en "The containtr id = "
    docker run -d \
        --name ${docker_name} \
        -e ENABLE_CATCH_ALL=yes \
        -e API_KEY=dQyXnZDLCRi3qyKB7vWN \
        -e ZONE=${zone} \
        -e NS1_IP=${ns_ip} \
        -p 0.0.0.0:53000:53000 \
        -p 0.0.0.0:8053:53/udp \
        -p 0.0.0.0:8053:53 \
        -p 0.0.0.0:8081:8081 \
        powerdns_sqlite3_edge --gsqlite3-pragma-foreign-keys=yes
}

#if [ ! -d ${powerdns_data_dir} ]; then
#    mkdir -p ${powerdns_data_dir}
#    chown 100:102 ${powerdns_data_dir}
#fi

if [ "X${action}" == "Xcreate-zone" ]; then
    docker exec -it ${docker_name} sh -c "pdnsutil create-zone ${zone} ns1.${zone}; pdnsutil add-record ${zone} ns1 A ${ns_ip}"
#    chown 100:102 ${powerdns_data_dir}/*
    ## example
    ## powerdns.sh create-zone
    exit 0
elif [ "X${action}" == "Xlist-zone" ]; then
    docker exec -it ${docker_name} sh -c "pdnsutil list-zone ${zone}"
    ## example
    ## powerdns.sh list-zone
    exit 0
elif [ "X${action}" == "Xcheck-zone" ]; then
    docker exec -it ${docker_name} sh -c "pdnsutil check-zone ${zone}"
    ## example
    ## powerdns.sh check-zone
    exit 0
elif [ "X${action}" == "Xadd-record" ]; then
    docker exec -it ${docker_name} sh -c "pdnsutil add-record ${zone} ${params}"
    ## example
    ## powerdns.sh add-record ns1 A 10.0.4.1
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
