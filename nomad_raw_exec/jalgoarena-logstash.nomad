job "jalgoarena-logstash" {
  datacenters = ["dc1"]

  type = "system"

  update {
    max_parallel = 1
    healthy_deadline = "3m"
  }

  group "logstash-docker" {

    ephemeral_disk {
      size = 1000
    }

    task "logstash" {
      driver = "raw_exec"

      artifact {
        source  = "https://artifacts.elastic.co/downloads/logstash/logstash-6.3.2.tar.gz"
      }

      config {
        command = "local/bin/logstash"
        args    = [
          "-f",
          "local/logstash.conf"
        ]
      }

      resources {
        cpu    = 500
        memory = 750
        network {
          port "tcp" {
            static = 4560
          }
          port "http" {
            static = 9600
          }
        }
      }

      service {
        name = "logstash"
        tags = ["elk", "traefik.enable=false"]
        port = "tcp"
        check {
          type      = "tcp"
          interval  = "10s"
          timeout   = "1s"
        }
      }

      template {
        data = <<EOH
input {
    tcp {
        port => 4560
        codec => json_lines
    }
}

filter {
  date {
    match => [ "timestamp" , "yyyy-MM-dd HH:mm:ss.SSS" ]
  }

  mutate {
    remove_field => ["@version"]
  }
}

output {
  stdout {
    codec => rubydebug
  }

  elasticsearch {
    hosts => [
      {{ range $index, $elasticsearch := service "elasticsearch" }}"{{ if eq $index 0 }}{{ $elasticsearch.Address }}:{{ $elasticsearch.Port }}"{{ else}},"{{ $elasticsearch.Address }}:{{ $elasticsearch.Port }}"{{ end }}{{ end }}
    ]
  }
}
EOH

        destination = "local/logstash.conf"
      }
    }
  }
}
