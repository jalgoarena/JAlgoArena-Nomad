job "jalgoarena-submissions" {
  datacenters = ["dc1"]

  update {
    max_parallel = 1
    healthy_deadline = "3m"
  }

  group "submissions-docker" {
    count = 2

    task "jalgoarena-submissions" {
      driver = "docker"

      config {
        image = "jalgoarena/submissions:2.4.225"
        network_mode = "host"
      }

      resources {
        cpu    = 500
        memory = 1200
        network {
          port "http" {}
        }
      }

      env {
        PORT = "${NOMAD_PORT_http}"
        JAVA_OPTS = "-Xmx1g -Xms200m"
      }

      service {
        name = "jalgoarena-submissions"
        tags = ["traefik.frontend.rule=PathPrefixStrip:/submissions/api", "secure=false"]
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
BOOTSTRAP_SERVERS = "{{ range $index, $kafka := service "kafka" }}{{ if eq $index 0 }}{{ $kafka.Address }}:{{ $kafka.Port }}{{ else}},{{ $kafka.Address }}:{{ $kafka.Port }}{{ end }}{{ end }}"
JALGOARENA_API_URL = "http://{{ range $index, $traefik := service "traefik" }}{{ if eq $index 0 }}{{ $traefik.Address }}:{{ $traefik.Port }}{{ end }}{{ end }}"
DB_HOST= "{{ range $index, $cockroach := service "cockroach" }}{{ if eq $index 0 }}{{ $cockroach.Address }}:{{ $cockroach.Port }}{{ end }}{{ end }}"
EOH

        destination = "local/config.env"
        env         = true
      }
    }
  }
}