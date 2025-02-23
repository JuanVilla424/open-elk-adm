#!/bin/sh

. "$(dirname "$0")/../.env"

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
if [ -e "${SCRIPT_DIR}/.deployed" ]; then
    echo "Uninstall First using uninstall.sh. Exiting with status 1."
    exit 1
fi

# Start core services
docker compose up -d portainer es01 es02
echo "Waiting for Elasticsearch to Come Up..."
CA_CERT=$(docker volume inspect elk-adm_certs | jq -r '.[0].Mountpoint')
until curl -s -k --cacert "${CA_CERT}"/ca/ca.crt https://es01:"${ES_PORT}" | grep -q "missing authentication"; do sleep 30; done
sleep 40
# Generate Kibana Service Account Token (When ES ready)
echo "Generating Kibana service account token..."
KIBANA_TOKEN_JSON=$(curl -s -k -u elastic:"${ELASTIC_PASSWORD}" \
  -X POST "https://es01:${ES_PORT}/_security/service/elastic/kibana/credential/token" \
  --cacert "${CA_CERT}"/ca/ca.crt \
  -H "Content-Type: application/json")
KIBANA_SERVICE_ACCOUNT_TOKEN=$(echo "$KIBANA_TOKEN_JSON" | jq -r '.token.value')
export KIBANA_SERVICE_ACCOUNT_TOKEN
echo "KIBANA_SERVICE_ACCOUNT_TOKEN=${KIBANA_SERVICE_ACCOUNT_TOKEN}" >> .env
# Now start Kibana with the token
docker compose up -d kibana
echo "Waiting for Kibana to Come Up..."
until curl -s -I http://localhost:"${KIBANA_PORT}" | grep -q "302 Found"; do sleep 30; done
sleep 20
# Generate Fleet Server token
echo "Generating Fleet Server service account token..."
FLEET_TOKEN_JSON=$(curl -s -k -u elastic:"${ELASTIC_PASSWORD}" -X POST \
  "https://es01:${ES_PORT}/_security/service/elastic/fleet-server/credential/token" \
  --cacert "${CA_CERT}"/ca/ca.crt -H "Content-Type: application/json")
FLEET_SERVER_SERVICE_TOKEN=$(echo "$FLEET_TOKEN_JSON" | jq -r '.token.value')
export FLEET_SERVER_SERVICE_TOKEN
echo "FLEET_SERVER_SERVICE_TOKEN=${FLEET_SERVER_SERVICE_TOKEN}" >> .env
# Create Agent Policy
curl -k -u "elastic:${ELASTIC_PASSWORD}" -X POST \
  "http://localhost:${KIBANA_PORT}/api/fleet/agent_policies" \
  -H "kbn-xsrf: true" -H "Content-Type: application/json" \
  -d'{
    "name": "bare-metal-default-policy",
    "description": "Bare Metal Fleet Server Policy",
    "namespace": "default",
    "monitoring_enabled": ["logs", "metrics"],
    "has_fleet_server": true
  }'
echo
curl -k -u "elastic:${ELASTIC_PASSWORD}" -X POST \
  "http://localhost:${KIBANA_PORT}/api/fleet/agent_policies" \
  -H "kbn-xsrf: true" -H "Content-Type: application/json" \
  -d'{
    "name": "container-default-policy",
    "description": "Container Fleet Server Policy",
    "namespace": "default",
    "monitoring_enabled": ["logs", "metrics"],
    "has_fleet_server": true
  }'
echo
# Configure Fleet Settings
curl -k -u "elastic:${ELASTIC_PASSWORD}" -X PUT \
  "http://localhost:${KIBANA_PORT}/api/fleet/settings" \
  -H "kbn-xsrf: true" -H "Content-Type: application/json" \
  -d "{
    \"fleet_server_hosts\": [
      \"https://localhost:${FLEET_SERVER_PORT}\",
      \"https://fleet-server01:${INTERNAL_FLEET_SERVER_PORT}\"
    ]
  }"
echo
# Configure Fleet Server Output
curl -k -u "elastic:${ELASTIC_PASSWORD}" -X POST \
  "http://localhost:${KIBANA_PORT}/api/fleet/outputs" \
  -H 'kbn-xsrf: true' -H 'content-type: application/json' \
  -d "{
    \"name\": \"bare-metal\",
    \"type\": \"elasticsearch\",
    \"is_default\": true,
    \"is_default_monitoring\": true,
    \"hosts\": [
      \"https://es01:${ES_PORT}\"
    ],
    \"config_yaml\": \"ssl.certificate_authorities: ['${CA_CERT}/ca/ca.crt']\"
  }"
echo
curl -k -u "elastic:${ELASTIC_PASSWORD}" -X POST \
  "http://localhost:${KIBANA_PORT}/api/fleet/outputs" \
  -H 'kbn-xsrf: true' -H 'content-type: application/json' \
  -d "{
    \"name\": \"container\",
    \"type\": \"elasticsearch\",
    \"is_default\": false,
    \"is_default_monitoring\": false,
    \"hosts\": [
      \"https://es01:${ES_PORT}\"
    ],
    \"config_yaml\": \"ssl.certificate_authorities: ['${CA_CERT}/ca/ca.crt']\"
  }"
echo
docker compose up -d logstash01
sleep 10
if [ "${SMTP_RELAY_EXTERNAL_SMTP_HOST}" != "smtp.example.com" ]; then
    echo "Deploying SMTP Relay..."
    docker compose up -d "smtp-relay"
else
    echo "SMTP Relay not yet configured"
fi
sleep 10
echo "Setting-Up Agent..."
cd /tmp || exit 1
rm -rf /tmp/elastic-agent*
curl -L -o /tmp/elastic-agent-"$STACK_VERSION"-linux-x86_64.tar.gz \
  https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-"$STACK_VERSION"-linux-x86_64.tar.gz
tar xzvf /tmp/elastic-agent-"$STACK_VERSION"-linux-x86_64.tar.gz
echo "Deploying Agent..."
/tmp/elastic-agent-"$STACK_VERSION"-linux-x86_64/./elastic-agent install --fleet-server-es=https://es01:"${ES_PORT}" \
  --fleet-server-service-token="${FLEET_SERVER_SERVICE_TOKEN}" \
  --fleet-server-policy=fleet-server-policy --fleet-server-port="${FLEET_SERVER_PORT}" \
  --fleet-server-es-ca="${CA_CERT}"/ca/ca.crt --insecure; \
touch "${SCRIPT_DIR}/.deployed"
echo "ELK ADM Successfully Deployed, access 'http://localhost:5601' using .env elastic password."
