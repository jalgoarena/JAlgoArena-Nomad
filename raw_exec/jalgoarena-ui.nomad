job "jalgoarena-ui" {
  datacenters = ["dc1"]

  update {
    max_parallel = 1
    healthy_deadline = "3m"
  }

  group "jalgoarena-ui" {
    count = 2

    ephemeral_disk {
      size = 500
    }

    task "jalgoarena-ui" {
      driver = "raw_exec"

      artifact {
        source  = "https://github.com/jalgoarena/JAlgoArena-UI/releases/download/20180818204428-bddfe37/JAlgoArena-UI-2.5.611.zip"
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
          port "http" {}
        }
      }

      service {
        name = "jalgoarena-ui"
        tags = ["traefik.frontend.entryPoints=ui", "traefik.frontend.rule=PathPrefix:/"]
        port = "http"
        check {
          type      = "tcp"
          interval  = "10s"
          timeout   = "1s"
        }
      }

      env {
        PORT = "${NOMAD_PORT_http}"
      }

      template {
        data = <<EOH
JALGOARENA_API_HTTP_URL = "http://{{ range $index, $traefik := service "traefik" }}{{ if eq $index 0 }}{{ $traefik.Address }}:5001{{ end }}{{ end }}"
JALGOARENA_API_WS_URL = "http://{{ range $index, $traefik := service "traefik" }}{{ if eq $index 0 }}{{ $traefik.Address }}:5005{{ end }}{{ end }}"
CONSUL_URL = http://{{ env "NOMAD_IP_http"}}:8500
EOH

        destination = "local/config.env"
        env         = true
      }
    }
  }
}
