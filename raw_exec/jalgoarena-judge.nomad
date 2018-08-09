job "jalgoarena-judge" {
  datacenters = ["dc1"]

  update {
    max_parallel = 1
    healthy_deadline = "3m"
  }

  group "jalgoarena-judge" {
    count = 2

    task "jalgoarena-judge" {
      driver = "raw_exec"

      artifact {
        source  = "https://github.com/jalgoarena/JAlgoArena-Judge/releases/download/20180809151701-7790121/JAlgoArena-Judge-2.4.511.zip"
      }

      config {
        command = "java"
        args = [
          "-Xmx1g", "-Xms512m",
          "-jar", "local/jalgoarena-judge-2.4.511.jar"
        ]
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
        JUDGE_CLASSPATH = "local/build/classes/kotlin/main"
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