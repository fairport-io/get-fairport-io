ovariable "bootstrap_node_ip" {
  type        = string
  description = "IP address of the bootstrap node"
}

variable "server_node_ips" {
  type        = list(string)
  description = "List of IP addresses for server nodes"
  default     = []
}

variable "agent_node_ips" {
  type        = list(string)
  description = "List of IP addresses for agent nodes"
  default     = []
}

variable "ssh_user" {
  type        = string
  description = "SSH username for connection"
  default     = "root"
}

variable "ssh_private_key" {
  type        = string
  description = "SSH private key content"
}

variable "fairport_installer_values_configmap_override" {
  type        = string
  description = "Content for the configmap override"
  default     = ""
}

# 1. Bootstrap the first node and prepare installer commands
resource "null_resource" "bootstrap_node" {
  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = var.ssh_private_key
    host        = var.bootstrap_node_ip
  }

  provisioner "remote-exec" {
    inline = [
      "curl https://get.fairport.io | sudo bash -",
      "I=0",
      "until fpk -n fairport get cm fairport-installer-values > /dev/null 2>&1; do",
      "  I=$(($I + 1))",
      "  [ $I -gt 300 ] && echo 'Failed to initialize in time' && exit 1",
      "  sleep 1",
      "done",
      "cat << 'EOYAML' | fpk apply -f -",
      "${var.fairport_installer_values_configmap_override}",
      "EOYAML",
      # Generate join tokens for other nodes
      "[ ! -f /usr/local/bin/fp-add-server ] && echo 'Installer not found' && exit 1",
      "[ ! -f /usr/local/bin/fp-add-agent ] && echo 'Installer not found' && exit 1",
      "/usr/local/bin/fp-add-server > /tmp/join_server.sh",
      "/usr/local/bin/fp-add-agent > /tmp/join_agent.sh"
    ]
  }
}

# 2. Fetch the join command for servers
data "external" "fetch_server_join_command" {
  depends_on = [null_resource.bootstrap_node]
  program = ["bash", "-c", <<EOT
    CMD=$(ssh -o StrictHostKeyChecking=no -i <(echo "${var.ssh_private_key}") ${var.ssh_user}@${var.bootstrap_node_ip} "cat /tmp/join_server.sh")
    jq -n --arg cmd "$CMD" '{"command":$cmd}'
  EOT
  ]
}

# 3. Fetch the join command for agents
data "external" "fetch_agent_join_command" {
  depends_on = [null_resource.bootstrap_node]
  program = ["bash", "-c", <<EOT
    CMD=$(ssh -o StrictHostKeyChecking=no -i <(echo "${var.ssh_private_key}") ${var.ssh_user}@${var.bootstrap_node_ip} "cat /tmp/join_agent.sh")
    jq -n --arg cmd "$CMD" '{"command":$cmd}'
  EOT
  ]
}

# 4. Provision Server Nodes
resource "null_resource" "server_nodes" {
  count = length(var.server_node_ips)

  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = var.ssh_private_key
    host        = var.server_node_ips[count.index]
  }

  provisioner "remote-exec" {
    inline = [
      data.external.fetch_server_join_command.result.command
    ]
  }
}

# 5. Provision Agent Nodes
resource "null_resource" "agent_nodes" {
  count = length(var.agent_node_ips)

  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = var.ssh_private_key
    host        = var.agent_node_ips[count.index]
  }

  provisioner "remote-exec" {
    inline = [
      data.external.fetch_agent_join_command.result.command
    ]
  }
}
