output "ca_files" {
  value = {
    pub_pem = "${var.cert_directory}/${var.cert_file_prefix}${var.ca_public_key_file_name}.pem"
    pub_cer = "${var.cert_directory}/${var.cert_file_prefix}${var.ca_public_key_file_name}.crt"
  }
}

output "cert_files" {
  value = {
    for cn in keys(var.certs) :
    cn => {
      pub_pem  = "${var.cert_directory}/${var.cert_file_prefix}${cn}${var.public_key_file_name_suffix}.pem"
      pub_cer  = "${var.cert_directory}/${var.cert_file_prefix}${cn}${var.public_key_file_name_suffix}.cer"
      priv_pem = "${var.cert_directory}/${var.cert_file_prefix}${cn}${var.private_key_file_name_suffix}.pem"
      priv_pfx = "${var.cert_directory}/${var.cert_file_prefix}${cn}${var.private_key_file_name_suffix}.pfx"
    }
  }
}

output "cert_pfx_password" {
  value    = random_password.cert_pfx_password.result
  senitive = true
}