#!/bin/sh

TEST_IP="187.2.2.3"

rm -rf ./logs-success
rm -rf ./logs-success-toml
rm -rf ./logs-success-yml
rm -rf ./logs-fail
rm -rf ./logs-fail-toml
rm -rf ./logs-fail-yml
rm -rf ./logs-invalid
rm -rf ./logs-invalid-toml
rm -rf ./logs-invalid-yml

# TODO: this should pull a version from a variable allowing for specific versions to be tested against over time...
docker pull traefik/whoami:latest
docker pull traefik:latest

sleep 1s

# Get latest tag
LATEST_PLUGIN_VERSION=$(git describe --match "v*" --abbrev=0 --tags HEAD)

sed -i "s/  version = \".*/  version = \"${LATEST_PLUGIN_VERSION}\"/g" ./traefik-prod.toml

echo "Updated version of plugin to latest tag: ${LATEST_PLUGIN_VERSION}"

mv docker-compose.yml docker-compose.yml.bak
cp docker-compose-prod.yml docker-compose.yml

sleep 1s

bash test-base.sh success toml "${1}" $TEST_IP

sleep 1s

mv ./logs ./logs-success-toml
mv ./tempconfig ./logs-success-toml/config

sleep 1s

bash test-base.sh fail toml "${1}" $TEST_IP

sleep 1s

mv ./logs ./logs-fail-toml
mv ./tempconfig ./logs-fail-toml/config

sleep 1s

bash test-base.sh invalid toml "${1}" "1522.20.2"

sleep 1s

mv ./logs ./logs-invalid-toml
mv ./tempconfig ./logs-invalid-toml/config

sleep 1s

bash ./test-verify.sh toml $TEST_IP

sleep 1s

bash test-base.sh success yml "${1}" $TEST_IP

sleep 1s

mv ./logs ./logs-success-yml
mv ./tempconfig ./logs-success-yml/config

sleep 1s

bash test-base.sh fail yml "${1}" $TEST_IP

sleep 1s

mv ./logs ./logs-fail-yml
mv ./tempconfig ./logs-fail-yml/config

sleep 1s

bash test-base.sh invalid yml "${1}" "1522.20.2"

sleep 1s

mv ./logs ./logs-invalid-yml
mv ./tempconfig ./logs-invalid-yml/config

sleep 1s

bash ./test-verify.sh yml $TEST_IP

rm docker-compose.yml
mv docker-compose.yml.bak docker-compose.yml
