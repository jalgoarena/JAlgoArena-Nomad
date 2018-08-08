job "jalgoarena-kafka" {
  datacenters = [
    "dc1"]

  update {
    max_parallel = 1
    healthy_deadline = "3m"
  }

  group "jalgoarena-zk" {

    ephemeral_disk {
      migrate = true
      size = 1500
      sticky = true
    }

    task "zookeeper" {
      driver = "raw_exec"

      artifact {
        source  = "http://ftp.man.poznan.pl/apache/kafka/1.1.1/kafka_2.12-1.1.1.tgz"
        destination = "local/"
      }

      config {
        command = "local/kafka_2.12-1.1.1/bin/zookeeper-server-start.sh"
        args    = [
          "local/zookeeper.properties"
        ]
      }

      resources {
        cpu = 500
        memory = 500
        network {
          port "zk" {}
        }
      }

      env {
        ZOOKEEPER_CLIENT_PORT = "${NOMAD_PORT_zk}"
      }

      service {
        name = "zookeeper"
        tags = [
          "zookeeper",
          "traefik.enable=false"]
        port = "zk"
        check {
          type = "tcp"
          interval = "10s"
          timeout = "1s"
        }
      }

      template {
        data = <<EOH
dataDir=local/zookeeper
clientPort={{ env "NOMAD_PORT_zk" }}
# disable the per-ip limit on the number of connections since this is a non-production config
maxClientCnxns=0
EOH

        destination = "local/zookeeper.properties"
      }
    }
  }

  group "jalgoarena-kafka" {
    count = 3

    ephemeral_disk {
      migrate = true
      size = 1500
      sticky = true
    }

    task "kafka" {
      driver = "raw_exec"

      artifact {
        source  = "http://ftp.man.poznan.pl/apache/kafka/1.1.1/kafka_2.12-1.1.1.tgz"
        destination = "local/"
      }

      config {
        command = "local/kafka_2.12-1.1.1/bin/kafka-server-start.sh"
        args    = [
          "local/kafka.properties"
        ]
      }

      resources {
        cpu = 750
        memory = 1000
        network {
          port "kafka" {}
        }
      }

      service {
        name = "kafka"
        tags = [
          "kafka",
          "traefik.enable=false"]
        port = "kafka"
        check {
          type = "tcp"
          interval = "10s"
          timeout = "1s"
        }
      }

      template {
        data = <<EOH
KAFKA_ZOOKEEPER_CONNECT = "{{ range $index, $zk := service "zookeeper" }}{{ if eq $index 0 }}{{ $zk.Address }}:{{ $zk.Port }}{{ end }}{{ end }}"
EOH

        destination = "local/config.env"
        env = true
      }

      template {
        data = <<EOH
broker.id={{ env "NOMAD_ALLOC_INDEX" }}
listeners=PLAINTEXT://{{ env "NOMAD_IP_kafka" }}:{{ env "NOMAD_PORT_kafka" }}
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=local/kafka-logs
num.partitions=1
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect={{ range $index, $zk := service "zookeeper" }}{{ if eq $index 0 }}{{ $zk.Address }}:{{ $zk.Port }}{{ end }}{{ end }}
zookeeper.connection.timeout.ms=6000
group.initial.rebalance.delay.ms=0
EOH

        destination = "local/kafka.properties"
      }
    }
  }
}
