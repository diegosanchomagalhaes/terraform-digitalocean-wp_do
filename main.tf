#Lembrar de criar a variável de ambiente com o TOKEN da Digital Ocean

terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~>2.0.0"
    }
  }
}

resource "digitalocean_vpc" "wp_net" { #rede privada na Digital Ocean
  name   = "wp-network"
  region = var.region
}

resource "digitalocean_loadbalancer" "wp_lb" { #Faz balanceamento de carga entre servidores da Digital Ocean
  name   = "wp-lb"
  region = var.region
  vpc_uuid = digitalocean_vpc.wp_net.id #Vinculando a VPC no atributo da digitalocean
  droplet_ids = digitalocean_droplet.vm_wp[*].id #As máquinas vituais da DigitalOcean. [*] significa várias VMs. Antes era: [digitalocean_droplet.vm_wp.id]

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 80
    target_protocol = "http"
  }

  healthcheck { #Verifica a saúde da aplicação
    port     = 80
    protocol = "http"
    path     = "/"
  }
}

resource "digitalocean_droplet" "vm_wp" { #Várias instâncias de VMs
  name     = "vm-wp-${count.index + 1}" #Antes para uma máquina era: "vm-wp". O "+ 1" é para começar em "1" e não em "0".
  size     = "s-2vcpu-2gb"
  image    = "ubuntu-22-04-x64"
  region   = var.region
  vpc_uuid = digitalocean_vpc.wp_net.id
  count = var.wp_vm_count #Criar réplicas para redundância de VM. As linhas superiores criariam somente 1(uma) única VM.
  ssh_keys = [var.vms_ssh]
}

resource "digitalocean_droplet" "vm_nfs" { #Uma única instância de NFS
  name     = "vm-nfs"
  size     = "s-2vcpu-2gb"
  image    = "ubuntu-22-04-x64"
  region   = var.region
  vpc_uuid = digitalocean_vpc.wp_net.id
  ssh_keys = [var.vms_ssh]
}

resource "digitalocean_database_db" "wp_database" {
  cluster_id = digitalocean_database_cluster.wp_mysql.id
  name       = "wp-database"
}

resource "digitalocean_database_cluster" "wp_mysql" {
  name                 = "wp-mysql"
  engine               = "mysql"
  version              = "8"
  size                 = "db-s-1vcpu-1gb"
  region               = var.region
  node_count           = 1
  private_network_uuid = digitalocean_vpc.wp_net.id
}

resource "digitalocean_database_user" "wp_database_user" {
  cluster_id = digitalocean_database_cluster.wp_mysql.id
  name       = "wordpress"
}
