#!/usr/bin/env bash
mkdir -p ./jalgoarena-data
echo "jalgoarena-data dir created"

CONSUL_UI_BETA=true nohup ./bin/consul agent -server -bootstrap-expect=1 -bind=192.168.63.21 -ui -data-dir=./jalgoarena-data/consul > logs/consul.out 2> logs/consul.err < /dev/null &
echo "Consul started, check http://localhost:8500"
./bin/consul version

nohup ./bin/nomad agent -server -bootstrap-expect=1 -data-dir=$(pwd)/jalgoarena-data/nomad -client > logs/nomad.out 2> logs/nomad.err < /dev/null &
echo "Nomad Started, check http://localhost:4646"
./bin/nomad version
