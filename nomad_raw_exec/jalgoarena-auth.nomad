job "jalgoarena-auth" {
  datacenters = ["dc1"]

  update {
    max_parallel = 1
    healthy_deadline = "3m"
  }

  group "jalgoarena-auth" {
    count = 1

    task "jalgoarena-auth" {
      driver = "java"

      artifact {
        source  = "https://github.com/jalgoarena/JAlgoArena-Auth/releases/download/v2.4.5/JAlgoArena-Auth-2.4.152.zip"
      }

      config {
        jar_path = "local/jalgoarena-auth-2.4.152.jar"
        jvm_options = ["-Xmx400m", "-Xms50m"]
      }

      resources {
        cpu    = 500
        memory = 500
        network {
          port "http" {}
        }
      }

      env {
        PORT = "${NOMAD_PORT_http}"
      }

      service {
        name = "jalgoarena-auth"
        tags = ["traefik.frontend.rule=PathPrefixStrip:/auth", "secure=false"]
        port = "http"
        check {
          type          = "http"
          path          = "/actuator/health"
          interval      = "10s"
          timeout       = "1s"
        }
      }
    }
  }
}