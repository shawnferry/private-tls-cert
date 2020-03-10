output "cert_directory" {
  value = var.cert_directory
}

output "ca_priv_key" {
  value = tls_private_key.ca
}
output "ca_public_cert" {
  value = tls_self_signed_cert.ca
}

output "certs" {
  value = {
    for cn in keys(var.certs) :
    cn => {
      priv_key = tls_private_key.cert[cn]
      pub_key  = tls_locally_signed_cert.cert[cn]
      csr      = tls_cert_request.cert[cn]
    }
  }
}

output "ca_files" {
  value = {
    pub_pem = "${var.cert_directory}/${var.cert_file_prefix}${var.ca_public_key_file_name}.pem"
    pub_cer = "${var.cert_directory}/${var.cert_file_prefix}${var.ca_public_key_file_name}.crt"
  }
}

output "pfx_password" {
  value = random_password.cert_pfx_password.result
}
output "cert_files" {
  value = {
    for cn in keys(var.certs) :
    cn => {
      dns_names = var.certs.cn.domain_names
      pub_pem   = "${var.cert_directory}/${var.cert_file_prefix}${cn}${var.public_key_file_name_suffix}.pem"
      pub_cer   = "${var.cert_directory}/${var.cert_file_prefix}${cn}${var.public_key_file_name_suffix}.cer"
      priv_pem  = "${var.cert_directory}/${var.cert_file_prefix}${cn}${var.private_key_file_name_suffix}.pem"
      priv_pfx  = "${var.cert_directory}/${var.cert_file_prefix}${cn}${var.private_key_file_name_suffix}.pfx"
    }
  }
}