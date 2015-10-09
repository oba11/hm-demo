#!/bin/bash
set -e

export CONSUL_JOIN_SERVERS=

ENV_FILE=/run/consul/options.env

# -------------

function init_config {
    local REQUIRED=('ADVERTISE_IP' 'CONSUL_JOIN_SERVERS' )

    if [ -f $ENV_FILE ]; then
        export "$(cat $ENV_FILE | xargs)"
    fi

    if [ -z $ADVERTISE_IP ]; then
        export ADVERTISE_IP=$(awk -F= '/COREOS_PUBLIC_IPV4/ {print $2}' /etc/environment)
    fi

    for REQ in "${REQUIRED[@]}"; do
        if [ -z "$(eval echo \$$REQ)" ]; then
            echo "Missing required config value: ${REQ}"
            exit 1
        fi
    done
}

function init_templates {
    local TEMPLATE=/etc/systemd/system/consul-agent.service
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
  -e SERVICE_IGNORE=1 \
  progrium/consul -advertise ${ADVERTISE_IP} ${CONSUL_JOIN_SERVERS}'
Restart=always
RestartSec=10
ExecStop=/usr/bin/docker stop consul

[Install]
WantedBy=multi-user.target
EOF
    }

    local TEMPLATE=/etc/systemd/system/registrator.service
    [ -f $TEMPLATE ] || {
        echo "TEMPLATE: $TEMPLATE"
        mkdir -p $(dirname $TEMPLATE)
        cat << EOF > $TEMPLATE
[Unit]
Requires=consul-agent.service
After=consul-agent.service

[Service]
ExecStartPre=-/usr/bin/docker kill registrator
ExecStartPre=-/usr/bin/docker rm registrator
ExecStartPre=/usr/bin/docker pull gliderlabs/registrator
ExecStart=/bin/bash -c '\
  /usr/bin/docker run \
  --name registrator -h registrator \
  -v /var/run/docker.sock:/tmp/docker.sock \
  gliderlabs/registrator -ip=${ADVERTISE_IP} consul://${ADVERTISE_IP}:8500'
Restart=always
RestartSec=10
ExecStop=/usr/bin/docker stop registrator

[Install]
WantedBy=multi-user.target
EOF
    }

}

init_config
init_templates

systemctl stop update-engine; systemctl mask update-engine

systemctl daemon-reload
systemctl enable consul-agent; systemctl start consul-agent
systemctl enable registrator; systemctl start registrator
echo "DONE"
