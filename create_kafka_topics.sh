#!/usr/bin/env bash
export PATH=/Users/jacek/kafka_2.12-1.1.0/bin:$PATH
kafka-topics.sh --create --zookeeper localhost:2181 --if-not-exists --replication-factor 3 --partitions 9 --topic submissions
kafka-topics.sh --create --zookeeper localhost:2181 --if-not-exists --replication-factor 2 --partitions 2 --topic results
kafka-topics.sh --create --zookeeper localhost:2181 --if-not-exists --replication-factor 2 --partitions 2 --topic events
