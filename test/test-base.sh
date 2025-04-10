#!/bin/sh

echo "";
echo "";
echo "*** STARTING TEST FOR : ${1}-${2}-${3}";
echo "";
echo "";

rm -rf ./logs;
rm -rf ./tempconfig;

mkdir ./logs;
mkdir ./tempconfig;

touch ./logs/access.log;
touch ./logs/debug.log;
touch ./logs/traefik.log;
touch ./logs/output.log;

cp -r "./config/${1}.${2}" "./tempconfig/config.${2}"

chmod -R 7777 ./logs;
chmod -R 7777 ./tempconfig;

sleep 2s;


docker compose up -d;
sleep 1s;

iterations=0
while ! grep -q "Starting TCP Server" "./logs/debug.log" && [ $iterations -lt 30 ]; do
  sleep 1s
  echo "Waiting for Traefik to be ready [${iterations}s/30]"
  let iterations++
done

iterations=0
while ! grep -q "Provider connection established with docker" "./logs/debug.log" && [ $iterations -lt 30 ]; do
  sleep 1s
  echo "Waiting for Traefik to connect to docker [${iterations}s/30]"
  let iterations++
done

iterations=0
while ! grep -q "Creating middleware" "./logs/debug.log" && [ $iterations -lt 30 ]; do
  sleep 1s
  echo "Waiting for Traefik to finish setup [${iterations}s/30]"
  let iterations++
done

curl -H "CF-Connecting-IP:${4}" -H "CF-Visitor:{\"scheme\":\"https\"}" http://localhost:4008/ >> ./logs/output.log;
echo "Headers:\nCF-Connecting-IP:${4}\nCF-Visitor:{\"scheme\":\"https\"}" >> ./logs/request.log
cat ./logs/output.log;

sleep 1s;
docker compose down;
