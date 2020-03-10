output "cert_directory" {
  value = var.cert_directory
}

output "ca_priv_key" {
  value = tls_private_key.ca
}
output "ca_cert" {
  value = tls_self_signed_cert.ca
}

# output "cert_priv_key" {
#   value = tls_private_key.cert
# }
# output "cert_local" {
#   value = tls_locally_signed_cert.cert
# }
# output "cert_csr" {
#   value = tls_cert_request.cert
# }

output "certs" {
  value = {
    for cn in keys(var.certs) :
      cn => {
        priv_key = tls_private_key.cert[cn]
        pub_key = tls_locally_signed_cert.cert[cn]
        csr = tls_cert_request.cert[cn]
      }
  }
}