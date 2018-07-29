job "jalgoarena-ranking" {
  datacenters = ["dc1"]

  update {
    max_parallel = 1
    healthy_deadline = "3m"
  }

  group "jalgoarena-ranking" {
    count = 1

    task "jalgoarena-ranking" {
      driver = "java"

      artifact {
        source  = "https://github.com/jalgoarena/JAlgoArena-Ranking/releases/download/v2.4.3/JAlgoArena-Ranking-2.4.64.zip"
      }

      config {
        jar_path = "local/jalgoarena-ranking-2.4.64.jar"
        jvm_options = ["-Xmx400m", "-Xms50m"]
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