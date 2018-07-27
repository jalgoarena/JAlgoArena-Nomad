job "jalgoarena-auth" {
  datacenters = ["dc1"]

  update {
    max_parallel = 1
    healthy_deadline = "3m"
  }

  group "auth-docker" {
    count = 2

    task "jalgoarena-auth" {
      driver = "docker"

      config {
        image = "jalgoarena/auth:2.4.152"
        network_mode = "host"
      }

      resources {
        cpu    = 500
        memory = 500
        network {
          port "http" {}
        }
      }

      env {
        PORT = "${NOMAD_PORT_http}"
        JAVA_OPTS = "-Xmx400m -Xms50m"
      }

      service {
        name = "jalgoarena-auth"
        tags = ["traefik.frontend.rule=PathPrefixStrip:/auth", "secure=false"]
        port = "http"
        check {
          type          = "http"
          path          = "/actuator/health"
          interval      = "10s"
          timeout       = "1s"
        }
      }
    }
  }
}