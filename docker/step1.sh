#!/usr/bin/env bash
nomad job run jalgoarena-elasticsearch.nomad
nomad job run jalgoarena-logstash.nomad
nomad job run jalgoarena-kibana.nomad
nomad job run jalgoarena-kafka.nomad
nomad job run jalgoarena-traefik.nomad
nomad job run jalgoarena-cockroach-master.nomad
sleep 10
nomad job run jalgoarena-cockroach.nomad