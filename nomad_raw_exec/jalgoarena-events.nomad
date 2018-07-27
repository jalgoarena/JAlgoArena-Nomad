job "jalgoarena-events" {
  datacenters = ["dc1"]

  update {
    max_parallel = 1
    healthy_deadline = "3m"
  }

  group "jalgoarena-events" {
    count = 1

    task "jalgoarena-events" {
      driver = "java"

      artifact {
        source  = "https://github.com/jalgoarena/JAlgoArena-Events/releases/download/v2.4.1/JAlgoArena-Events-2.4.34.zip"
      }

      config {
        jar_path = "local/jalgoarena-events-2.4.34.jar"
        jvm_options = ["-Xmx400m", "-Xms50m"]
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