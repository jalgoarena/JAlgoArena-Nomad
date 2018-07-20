job "jalgoarena-cockroach-master" {
  datacenters = ["dc1"]

  update {
    max_parallel = 1
    healthy_deadline = "3m"
  }

  group "cockroach-master" {
    count = 1

    ephemeral_disk {
      size = 1000
    }

    task "cockroach-master-node" {
      driver = "raw_exec"

      artifact {
        source  = "https://binaries.cockroachdb.com/cockroach-v2.0.4.linux-amd64.tgz"
        destination = "local/"
      }

      config {
        command = "local/cockroach-v2.0.4.linux-amd64/cockroach"
        args    = [
          "start",
          "--insecure",
          "--store=node1",
          "--host", "${NOMAD_IP_tcp}",
          "--port", "${NOMAD_PORT_tcp}",
          "--http-port", "${NOMAD_PORT_http}"
        ]
      }

      resources {
        cpu    = 500
        memory = 500
        network {
          port "http" {}
          port "tcp" {}
        }
      }

      service {
        name = "cockroach"
        tags = ["traefik.enable=false"]
        port = "tcp"
        check {
          name      = "service: cockroach http check"
          type      = "tcp"
          port      = "http"
          interval  = "10s"
          timeout   = "1s"
        }
        check {
          name      = "service: cockroach tcp check"
          type      = "tcp"
          port      = "tcp"
          interval  = "10s"
          timeout   = "1s"
        }
      }
    }
  }
}