#!/bin/bash

with_offline=${1:-no_offline}
enable_isolation=${2:-no_isolation}
stress_num=${3:-10}
concurrency=10
timeout=30
output=/tmp/result.json
online_container=
offline_container=

exec_sql="echo \"SELECT * FROM system.numbers LIMIT 10000000 OFFSET 10000000\" | clickhouse-benchmark -i 10000 -c $concurrency -t $timeout"

function prepare()
{
    echo "Launch clickhouse container."
    online_container=$(docker run -itd \
            -v /tmp:/tmp:rw \
            --ulimit nofile=262144:262144 \
            -p 34424:34424 \
            yandex/clickhouse-server)

    sleep 3
    echo "Clickhouse container lauched."
}

function clickhouse()
{
    echo "Start clickhouse benchmark test."
    docker exec $online_container bash -c "$exec_sql --json $output"
    echo "Clickhouse benchmark test done."
}

function stress()
{
    echo "Launch stress container."
    offline_container=$(docker run -itd joedval/stress --cpu $stress_num)
    echo "Stress container launched."

    if [ $enable_isolation == "enable_isolation" ]; then
        echo "Set stress container qos level to -1."
        echo -1 > /sys/fs/cgroup/cpu/docker/$offline_container/cpu.qos_level
    fi
}

function benchmark()
{
    if [ $with_offline == "with_offline" ]; then
    	stress
    	sleep 3
	fi
    clickhouse
    echo "Remove test containers."
    docker rm -f $online_container
    docker rm -f $offline_container
    echo "Finish benchmark test for clickhouse(online) and stress(offline) colocation."
    echo "===============================clickhouse benchmark=================================================="
    cat $output
    echo "===============================clickhouse benchmark=================================================="
}

prepare
benchmark
