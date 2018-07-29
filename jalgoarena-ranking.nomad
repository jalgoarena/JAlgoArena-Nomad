job "jalgoarena-ranking" {
  datacenters = ["dc1"]

  update {
    max_parallel = 1
    healthy_deadline = "3m"
  }

  group "ranking-docker" {
    count = 2

    task "jalgoarena-ranking" {
      driver = "docker"

      config {
        image = "jalgoarena/ranking:2.4.64"
        network_mode = "host"
      }

      resources {
        cpu    = 1000
        memory = 512
        network {
          port "http" {}
        }
      }

      env {
        PORT = "${NOMAD_PORT_http}"
        JAVA_OPTS = "-Xmx400m -Xms50m"
      }

      service {
        name = "jalgoarena-ranking"
        tags = ["traefik.frontend.rule=PathPrefixStrip:/ranking/api", "secure=false"]
        port = "http"
        check {
          type          = "http"
          path          = "/actuator/health"
          interval      = "10s"
          timeout       = "1s"
        }
      }

      template {
        data = <<EOH
JALGOARENA_API_URL = "http://{{ range $index, $traefik := service "traefik" }}{{ if eq $index 0 }}{{ $traefik.Address }}:{{ $traefik.Port }}{{ end }}{{ end }}"
EOH

        destination = "local/config.env"
        env         = true
      }
    }
  }
}