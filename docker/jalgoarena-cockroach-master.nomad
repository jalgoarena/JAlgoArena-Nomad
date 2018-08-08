job "jalgoarena-cockroach-master" {
  datacenters = ["dc1"]

  update {
    max_parallel = 1
    healthy_deadline = "3m"
    canary = 1
  }

  group "cockroach" {
    ephemeral_disk {
      migrate = true
      size = 1500
      sticky = true
    }

    task "cockroach-node" {
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
          "--store", "node-${NOMAD_ALLOC_INDEX}",
          "--host", "${NOMAD_IP_tcp}",
          "--port", "${NOMAD_PORT_tcp}",
          "--http-port", "${NOMAD_PORT_http}"
        ]
      }

      resources {
        cpu    = 500
        memory = 1000
        network {
          port "http" {}
          port "tcp" {}
        }
      }

      service {
        name = "cockroach"
        tags = ["traefik.enable=false", "master"]
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