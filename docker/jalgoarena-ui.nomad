job "jalgoarena-ui" {
  datacenters = ["dc1"]

  update {
    max_parallel = 1
    healthy_deadline = "3m"
  }

  group "ui-docker" {

    ephemeral_disk {
      size = 500
    }

    task "jalgoarena-ui" {
      driver = "docker"

      config {
        image = "jalgoarena/ui:2.5.623"
        network_mode = "host"
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
        tags = ["traefik.frontend.entryPoints=ui", "traefik.frontend.rule=PathPrefix:/"]
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
CONSUL_URL = http://{{ env "NOMAD_IP_http"}}:8500
EOH

        destination = "local/config.env"
        env         = true
      }
    }
  }
}
