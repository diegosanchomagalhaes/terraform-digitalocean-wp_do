output "wp_lb_ip" {
  value = digitalocean_loadbalancer.wp_lb.ip
  description = "IP do Load Balancer"
}

output "wp_vm_ips" {
  value = digitalocean_droplet.vm_wp[*].ipv4_address
  description = "IPs das VMs do Wordpress [*]"
}

output "nfs_vm_ip" {
  value = digitalocean_droplet.vm_nfs.ipv4_address
  description = "IP da VM NFS"
}

output "database_username" {
  value     = digitalocean_database_user.wp_database_user.name
  description = "Usuário do Banco de Dados !!!"
}

output "database_pass"{
  value     = digitalocean_database_user.wp_database_user.password
  description = "Senha do Banco de Dados !!!"
  sensitive = true #Valor como 'true" para permitir que a senha (Dado Sensível) possa ser exposta no Output. Para expor o dados sensível, na linha de comando "terraform output <nome_campo_sensível_output>"
}