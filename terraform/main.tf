terraform {
    required_providers {
      docker = {
        source = "kreuzwerker/docker"
        version = "~> 3.0.0"
      }
    }
}

provider "docker" {
    host = "tcp://192.168.252.6:2375"
}

resource "docker_network" "pinger_net" {
    name = "pinger_net"
}

resource "docker_volume" "postgres_data" {
  name = "postgres_data"
}

resource "docker_container" "postgres" {
  name = "postgres_db"
  image = "postgres:15-alpine"

  networks_advanced {
    name = docker_network.pinger_net.name
  }

  env = [
      "POSTGRES_USER=pinger_user",
      "POSTGRES_PASSWORD=${var.db_password}",
      "POSTGRES_DB=pinger_base"
  ]

  volumes {
    volume_name = docker_volume.postgres_data.name
    container_path = "/var/lib/postgresql/data"
  }

  ports {
        internal = 5432
        external = 5432
  }
}

resource "docker_container" "vault" {
  name = "vault_server"
  image = "hashicorp/vault:latest"

  networks_advanced {
    name = docker_network.pinger_net.name
  }

  env = [
    "VAULT_DEV_ROOT_TOKEN_ID=${var.vault_root_token}",
    "VAULT_ADDR=http://0.0.0.0:8200"
  ]

  ports {
    internal = 8200
    external = 8200
  }
}