# JAlgoArena Nomad

Nomad jobs to run JAlgoArena microservices

## Step 0

In order to successfully run nomad scheduler plus all microservices, we have to run Consul and Nomad agents on every host where we want to deploy JAlgoArena

## Step 1

Now we are ready to run external services that JAlgoArena is using for it's own purpose
- kafka cluster (plus zookeeper)
- elastic search, logstash and kibana for logs monitoring
- prometheus (will be added in a near future ...)
- traefik - edge service and load balancer for rest and websocket calls
- cockroachDB - persistent storage for JAlgoArena (will be added in a near future ...)

Here, single manual step is to run [create_kafka_topics.sh](create_kafka_topics.sh) in order to properly set kafka topics replication and partitions (To Be Automated!).

## Step 2

We can start running JAlgoArena specific services - which depends on external services:
- auth
- queue
- events
- judge
- submissions
- ranking
- ui

All services are deployed in Highly Available mode keeping some set of replication

![Component Diagram](https://github.com/spolnik/JAlgoArena/raw/master/design/JAlgoArena_Logo.png)
