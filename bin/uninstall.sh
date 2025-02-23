#!/bin/sh

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
if [ ! -e "${SCRIPT_DIR}/.deployed" ]; then
    echo "ELK ADM is not installed yet. Please install it first..."
    exit 1
fi

sudo /opt/Elastic/Agent/elastic-agent uninstall
docker compose down -v
sudo rm -rf /usr/share/elastic-agent/
sudo rm -f /usr/bin/elastic-agent*
sudo rm -f /usr/lib/systemd/system/elastic-agent.service
sudo rm -f /etc/rc.d/init.d/elastic-agent
sudo rm -r /etc/elastic-agent
sudo rm -r /var/lib/elastic-agent
sudo rm -r /opt/Elastic/Agent
sudo rm -f /etc/systemd/system/elastic-agent.service
rm -rf "${SCRIPT_DIR}/.deployed"
sed -i '/KIBANA_SERVICE_ACCOUNT_TOKEN/d' ".env"
sed -i '/FLEET_SERVER_SERVICE_TOKEN/d' ".env"
