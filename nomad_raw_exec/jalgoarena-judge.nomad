job "jalgoarena-judge" {
  datacenters = ["dc1"]

  update {
    max_parallel = 1
    healthy_deadline = "3m"
  }

  group "judge-docker" {
    count = 1

    task "jalgoarena-judge" {
      driver = "java"

      artifact {
        source  = "https://github.com/jalgoarena/JAlgoArena-Judge/releases/download/v2.4.3/JAlgoArena-Judge-2.4.488.zip"
      }

      config {
        jar_path = "local/jalgoarena-judge-2.4.488.jar"
        class_path  = "${NOMAD_TASK_DIR}"
        jvm_options = ["-Xmx1g", "-Xms512m"]
      }

      resources {
        cpu    = 1000
        memory = 1500
        network {
          port "http" {}
        }
      }

      env {
        PORT = "${NOMAD_PORT_http}"
      }

      service {
        name = "jalgoarena-judge"
        tags = ["traefik.frontend.rule=PathPrefixStrip:/judge/api", "secure=false"]
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
EOH

        destination = "judge/config.env"
        env         = true
      }
    }
  }
}