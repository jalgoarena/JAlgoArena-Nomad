job "jalgoarena-elasticsearch" {
  datacenters = [
    "dc1"]

  update {
    max_parallel = 1
    healthy_deadline = "3m"
  }

  group "jalgoarena-elasticsearch" {

    ephemeral_disk {
      size = 2000
    }

    task "elasticsearch" {
      driver = "raw_exec"

      artifact {
        source = "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.3.2.tar.gz"
      }

      config {
        command = "local/elasticsearch-6.3.2/bin/elasticsearch"
      }

      resources {
        cpu = 1000
        memory = 3000
        network {
          port "http" {
            static = 9200
          }
        }
      }

      service {
        name = "elasticsearch"
        tags = [
          "elk",
          "traefik.enable=false"]
        port = "http"
        check {
          type = "tcp"
          interval = "10s"
          timeout = "1s"
        }
      }

      template {
        data = <<EOH
network.host: {{ env "NOMAD_IP_http" }}
EOH

        destination = "local/elasticsearch-6.3.2/config/elasticsearch.yml"
      }
    }
  }
}
