#!/bin/bash
set -e

export CONSUL_INITIAL_SERVER=
export CONSUL_CLUSTER_SIZE=
export CONSUL_POST_COMMAND=

ENV_FILE=/run/consul/options.env

# -------------

function init_config {
    local REQUIRED=('ADVERTISE_IP' 'CONSUL_INITIAL_SERVER' 'CONSUL_CLUSTER_SIZE' 'CONSUL_POST_COMMAND' )

    if [ -f $ENV_FILE ]; then
        export $(cat $ENV_FILE | xargs)
    fi

    if [ -z $ADVERTISE_IP ]; then
        export ADVERTISE_IP=$(awk -F= '/COREOS_PUBLIC_IPV4/ {print $2}' /etc/environment)
    fi

    if [ $CONSUL_INITIAL_SERVER == $ADVERTISE_IP ]; then
        export CONSUL_POST_COMMAND="-server -advertise ${ADVERTISE_IP} -bootstrap-expect ${CONSUL_CLUSTER_SIZE} -ui-dir /ui"
    else
        export CONSUL_POST_COMMAND="-server -advertise ${ADVERTISE_IP} -join ${CONSUL_INITIAL_SERVER} -ui-dir /ui"
    fi

    for REQ in "${REQUIRED[@]}"; do
        if [ -z "$(eval echo \$$REQ)" ]; then
            echo "Missing required config value: ${REQ}"
            exit 1
        fi
    done
}

function init_templates {
    local TEMPLATE=/etc/systemd/system/consul-server.service
    [ -f $TEMPLATE ] || {
        echo "TEMPLATE: $TEMPLATE"
        mkdir -p $(dirname $TEMPLATE)
        cat << EOF > $TEMPLATE
[Unit]
Requires=docker.service
After=docker.service

[Service]
ExecStartPre=-/usr/bin/docker kill consul
ExecStartPre=-/usr/bin/docker rm consul
ExecStartPre=/usr/bin/docker pull progrium/consul
ExecStart=/bin/bash -c '\
  /usr/bin/docker run \
  --name consul -h %H \
  -v /mnt:/data \
  -p ${ADVERTISE_IP}:8300:8300 \
  -p ${ADVERTISE_IP}:8301:8301 \
  -p ${ADVERTISE_IP}:8301:8301/udp \
  -p ${ADVERTISE_IP}:8302:8302 \
  -p ${ADVERTISE_IP}:8302:8302/udp \
  -p ${ADVERTISE_IP}:8400:8400 \
  -p ${ADVERTISE_IP}:8500:8500 \
  -p ${ADVERTISE_IP}:53:53 \
  -p ${ADVERTISE_IP}:53:53/udp \
  progrium/consul ${CONSUL_POST_COMMAND}'
Restart=always
RestartSec=10
ExecStop=/usr/bin/docker stop consul

[Install]
WantedBy=multi-user.target
EOF
    }

}

init_config
init_templates

systemctl stop update-engine; systemctl mask update-engine

systemctl daemon-reload
systemctl enable consul-server; systemctl start consul-server
echo "DONE"
