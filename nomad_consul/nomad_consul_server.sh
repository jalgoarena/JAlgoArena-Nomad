#!/usr/bin/env bash
mkdir -p ./jalgoarena-data
mkdir -p ./logs
echo "jalgoarena-data & logs dir created"

nohup consul agent -server -bootstrap-expect=1 -bind=192.168.63.21 -client="192.168.63.21 127.0.0.1" -ui -data-dir=./jalgoarena-data/consul > logs/consul.out 2> logs/consul.err < /dev/null &
echo "Consul started, check http://$(hostname):8500"
consul version

sleep 5
consul kv put jalgoarena/config @config.json

nohup nomad agent -server -bootstrap-expect=1 -data-dir=$(pwd)/jalgoarena-data/nomad -client -config=$(pwd)/nomad-client.hcl > logs/nomad.out 2> logs/nomad.err < /dev/null &
echo "Nomad Started, check http://$(hostname):4646"
nomad version
