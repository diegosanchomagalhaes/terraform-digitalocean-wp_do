# variable "do_token" { #É somente declarado no MAIN e VARIABLES raiz

#   type = string
# }

variable "region" {
  type    = string
  default = "nyc1"
}

variable "wp_vm_count" { #Réplicas das VMs do WP (WordPress). Dessa forma garante a Alta Disponibilidade do WP.
  default = 2
  description = "QTD de máquinas para o WordPress"
  validation {
    condition = var.wp_vm_count > 1 #Validar se sempre terá mais que 1 máquina declarada, para ter a redundância. Essa seria a validação.
    error_message = "Mínimo de 2 máquinas para ter redundância"
  }
}

variable "vms_ssh" {
  type = string
  description = "Chave SSH para as VMs !!!"
}