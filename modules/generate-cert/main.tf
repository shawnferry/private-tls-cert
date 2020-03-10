# Cert password for uploading...
resource "random_password" "cert_pfx_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# ---------------------------------------------------------------------------------------------------------------------
#  CREATE A CA CERTIFICATE
# ---------------------------------------------------------------------------------------------------------------------

resource "tls_private_key" "ca" {
  algorithm   = var.private_key_algorithm
  ecdsa_curve = var.private_key_ecdsa_curve
  rsa_bits    = var.private_key_rsa_bits
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm     = tls_private_key.ca.algorithm
  private_key_pem   = tls_private_key.ca.private_key_pem
  is_ca_certificate = true

  validity_period_hours = var.ca_validity_period_hours
  allowed_uses          = var.ca_allowed_uses

  subject {
    common_name  = var.ca_common_name
    organization = var.organization_name
  }

  # Store the CA public key in a file.
  provisioner "local-exec" {
    command = <<DOC
      export PUB='${var.cert_directory}/${var.cert_file_prefix}${var.ca_public_key_file_name}.pem'
      export CERT='${var.cert_directory}/${var.cert_file_prefix}${var.ca_public_key_file_name}.crt'
      echo '${tls_self_signed_cert.ca.cert_pem}' > $PUB && \
        chmod ${var.permissions} $PUB && \
        chown ${var.owner} $PUB
      openssl x509 -outform der -in $PUB -out $CERT
    DOC
  }
  # provisioner "local-exec" {
  #   when    = destroy
  #   command = <<DOC
  #     export PUB='${var.cert_directory}/${var.ca_public_key_file_name}'
  #     rm $PUB
  #   DOC
  # }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A TLS CERTIFICATE SIGNED USING THE CA CERTIFICATE
# ---------------------------------------------------------------------------------------------------------------------

resource "tls_private_key" "cert" {
  for_each = var.certs

  algorithm   = var.private_key_algorithm
  ecdsa_curve = var.private_key_ecdsa_curve
  rsa_bits    = var.private_key_rsa_bits


  depends_on = [tls_self_signed_cert.ca]
}

resource "tls_cert_request" "cert" {
  for_each = var.certs

  key_algorithm   = tls_private_key.cert[each.key].algorithm
  private_key_pem = tls_private_key.cert[each.key].private_key_pem

  dns_names    = each.value.dns_names
  ip_addresses = each.value.ip_addresses

  subject {
    common_name  = each.key
    organization = var.organization_name
  }
  depends_on = [tls_self_signed_cert.ca]
}

resource "tls_locally_signed_cert" "cert" {
  for_each = var.certs

  cert_request_pem      = tls_cert_request.cert[each.key].cert_request_pem
  validity_period_hours = each.value.validity_period_hours[0]
  allowed_uses          = var.allowed_uses

  # static ca references
  ca_key_algorithm   = tls_private_key.ca.algorithm
  ca_private_key_pem = tls_private_key.ca.ttttttttttttttt
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  depends_on = [tls_self_signed_cert.ca]
}

resource "null_resource" "output_certs" {
  for_each = var.certs
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cert_id = tls_self_signed_cert.ca.id
  }

  provisioner "local-exec" {
    # Bootstrap script called with private_ip of each node in the clutser
    command = <<-DOC
      export PUB='${var.cert_directory}/${var.cert_file_prefix}${each.key}-${var.public_key_file_name_suffix}.pem'
      export CERT='${var.cert_directory}/${var.cert_file_prefix}${each.key}-${var.public_key_file_name_suffix}.cer'
      export PRIV='${var.cert_directory}/${var.cert_file_prefix}${each.key}-${var.private_key_file_name_suffix}.pem'
      export PFX='${var.cert_directory}/${var.cert_file_prefix}${each.key}-${var.private_key_file_name_suffix}.pfx'
      # Pubkey
      echo '${tls_locally_signed_cert.cert[each.key].cert_pem}' > $PUB && \
        chmod ${var.permissions} $PUB && \
        chown ${var.owner} $PUB
      openssl x509 -outform der -in $PUB -out $CERT
      # Privkey
      echo '${tls_private_key.cert[each.key].private_key_pem}' > $PRIV && \
        chmod ${var.permissions} $PRIV && \
        chown ${var.owner} $PRIV
      openssl pkcs12 \
        -export \
        -in $PUB \
        -inkey $PRIV \
        -out $PFX \
        -password "pass:${random_password.cert_pfx_password.result}"
    DOC
  }
}
