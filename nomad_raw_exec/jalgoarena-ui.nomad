job "jalgoarena-ui" {
  datacenters = ["dc1"]

  update {
    max_parallel = 1
    healthy_deadline = "3m"
  }

  group "jalgoarena-ui" {
    count = 1

    ephemeral_disk {
      size = 500
    }

    task "jalgoarena-ui" {
      driver = "raw_exec"

      artifact {
        source  = "https://github.com/jalgoarena/JAlgoArena-UI/releases/download/v2.4.8/JAlgoArena-UI-2.4.8.518.zip"
      }

      config {
        command = "node"
        args    = [
          "local/server.js"
        ]
      }

      resources {
        cpu    = 750
        memory = 750
        network {
          port "http" {
            static = 3000
          }
        }
      }

      service {
        name = "jalgoarena-ui"
        tags = ["ui", "traefik.enable=false"]
        port = "http"
        check {
          type      = "tcp"
          interval  = "10s"
          timeout   = "1s"
        }
      }

      template {
        data = <<EOH
JALGOARENA_API_HTTP_URL = "http://{{ range $index, $traefik := service "traefik" }}{{ if eq $index 0 }}{{ $traefik.Address }}:5001{{ end }}{{ end }}"
JALGOARENA_API_WS_URL = "http://{{ range $index, $traefik := service "traefik" }}{{ if eq $index 0 }}{{ $traefik.Address }}:5005{{ end }}{{ end }}"
EOH

        destination = "local/config.env"
        env         = true
      }
    }
  }
}
