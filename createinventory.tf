resource "local_file" "private_key" {
  #sensitive_content = tls_private_key.key.private_key_pem
  filename          =  "AWS_Alan_KP.pem"
  file_permission   = "0600"
}
resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tmpl", {
      ip          = data.aws_instances.workers.public_ip,
      ssh_keyfile = local_file.private_key.filename
  })
  filename = "inventory.yaml"
}