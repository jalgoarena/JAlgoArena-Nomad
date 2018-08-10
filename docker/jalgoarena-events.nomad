job "jalgoarena-events" {
  datacenters = ["dc1"]

  update {
    max_parallel = 1
    healthy_deadline = "3m"
  }

  group "events-docker" {
    count = 2

    task "jalgoarena-events" {
      driver = "docker"

      config {
        image = "jalgoarena/events:2.4.43"
        network_mode = "host"
      }

      resources {
        cpu    = 500
        memory = 512
        network {
          port "events" {}
        }
      }

      env {
        KAFKA_CONSUMER_GROUP_ID = "events-${NOMAD_ALLOC_INDEX}"
        PORT = "${NOMAD_PORT_events}"
        JAVA_OPTS = "-Xmx400m -Xms50m"
      }

      service {
        name = "jalgoarena-events"
        tags = ["traefik.frontend.entryPoints=ws", "traefik.frontend.rule=PathPrefix:/", "secure=false"]
        port = "events"
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
EOH

        destination = "local/config.env"
        env         = true
      }
    }
  }
}