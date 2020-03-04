output "ca_public_key_file_path" {
  value = var.ca_public_key_file_path
}

output "public_key_file_path" {
  value = var.public_key_file_path
}

output "private_key_file_path" {
  value = var.private_key_file_path
}

output "ca_priv_key" {
  value = tls_private_key.ca
}
output "ca_cert" {
  value = tls_self_signed_cert.ca
}

output "cert_priv_key" {
  value = tls_private_key.cert
}
output "cert_local" {
  value = tls_locally_signed_cert.cert
}
