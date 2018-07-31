#!/usr/bin/env bash
mkdir -p ./jalgoarena-data
mkdir -p ./logs
echo "jalgoarena-data & logs dir created"

nohup consul agent -ui -retry-join "192.168.63.21"> logs/consul.out 2> logs/consul.err < /dev/null &
echo "Consul client started, check http://localhost:8500"
consul version

nohup nomad agent -client -data-dir=$(pwd)/jalgoarena-data/nomad -client -servers="192.168.63.21:4648" -config=$(pwd)/nomad-client.hcl > logs/nomad.out 2> logs/nomad.err < /dev/null &
echo "Nomad Started, check http://localhost:4646"
nomad version
