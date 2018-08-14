job "jalgoarena-cockroach" {
  datacenters = ["dc1"]

  update {
    max_parallel = 1
    healthy_deadline = "3m"
  }

  group "cockroach-master" {
    ephemeral_disk {
      migrate = true
      size = 1500
      sticky = true
    }

    task "cockroach-node" {
      driver = "raw_exec"
      leader = true

      artifact {
        source = "https://binaries.cockroachdb.com/cockroach-v2.0.4.${attr.kernel.name}-${attr.cpu.arch}.tgz"
      }

      config {
        command = "local/cockroach-v2.0.4.${attr.kernel.name}-${attr.cpu.arch}/cockroach"
        args = [
          "start",
          "--insecure",
          "--store", "node-master-${NOMAD_ALLOC_INDEX}",
          "--host", "${NOMAD_IP_tcp}",
          "--port", "${NOMAD_PORT_tcp}",
          "--http-port", "${NOMAD_PORT_http}",
          "--join", "${COCKROACH_JOIN}"
        ]
      }

      resources {
        cpu = 500
        memory = 1000
        network {
          port "http" {}
          port "tcp" {}
        }
      }

      service {
        name = "cockroach"
        tags = [
          "traefik.enable=false", "master"]
        port = "tcp"
        check {
          name = "service: cockroach http check"
          type = "tcp"
          port = "http"
          interval = "10s"
          timeout = "1s"
        }
        check {
          name = "service: cockroach tcp check"
          type = "tcp"
          port = "tcp"
          interval = "10s"
          timeout = "1s"
        }
      }

      template {
        data = <<EOH
COCKROACH_JOIN = {{ range $index, $cockroach := service "cockroach" }}{{ if eq $index 0 }}{{ $cockroach.Address }}:{{ $cockroach.Port }}{{ else}},{{ $cockroach.Address }}:{{ $cockroach.Port }}{{ end }}{{ end }}
EOH

        destination = "local/config.env"
        change_mode = "noop"
        env         = true
      }
    }
  }

  group "cockroach" {
    count = 2

    ephemeral_disk {
      migrate = true
      size = 1500
      sticky = true
    }

    task "cockroach-node" {
      driver = "raw_exec"
      leader = true

      artifact {
        source  = "https://binaries.cockroachdb.com/cockroach-v2.0.4.${attr.kernel.name}-${attr.cpu.arch}.tgz"
      }

      config {
        command = "local/cockroach-v2.0.4.${attr.kernel.name}-${attr.cpu.arch}/cockroach"
        args    = [
          "start",
          "--insecure",
          "--store", "node-${NOMAD_ALLOC_INDEX}",
          "--host", "${NOMAD_IP_tcp}",
          "--port", "${NOMAD_PORT_tcp}",
          "--http-port", "${NOMAD_PORT_http}",
          "--join", "${COCKROACH_JOIN}"
        ]
      }

      resources {
        cpu    = 500
        memory = 1000
        network {
          port "http" {}
          port "tcp" {}
        }
      }

      service {
        name = "cockroach"
        tags = ["traefik.enable=false"]
        port = "tcp"
        check {
          name      = "service: cockroach http check"
          type      = "tcp"
          port      = "http"
          interval  = "10s"
          timeout   = "1s"
        }
        check {
          name      = "service: cockroach tcp check"
          type      = "tcp"
          port      = "tcp"
          interval  = "10s"
          timeout   = "1s"
        }
      }

      template {
        data = <<EOH
COCKROACH_JOIN = {{ range $index, $cockroach := service "master.cockroach" }}{{ if eq $index 0 }}{{ $cockroach.Address }}:{{ $cockroach.Port }}{{ else}},{{ $cockroach.Address }}:{{ $cockroach.Port }}{{ end }}{{ end }}
EOH

        destination = "local/config.env"
        env         = true
      }
    }
  }
}