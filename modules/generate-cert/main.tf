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
      export FILE='${var.cert_directory}/${var.ca_public_key_file_name}'
      echo '${tls_self_signed_cert.ca.cert_pem}' > $FILE && \
        chmod ${var.permissions} $FILE && \
        chown ${var.owner} $FILE
    DOC
  }
  provisioner "local-exec" {
    when    = destroy
    command = <<DOC
      export FILE='${var.cert_directory}/${var.ca_public_key_file_name}'
      rm $FILE
    DOC
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A TLS CERTIFICATE SIGNED USING THE CA CERTIFICATE
# ---------------------------------------------------------------------------------------------------------------------

resource "tls_private_key" "cert" {
  for_each = var.certs

  algorithm   = var.private_key_algorithm
  ecdsa_curve = var.private_key_ecdsa_curve
  rsa_bits    = var.private_key_rsa_bits

  # Store the certificate's private key in a file.
  provisioner "local-exec" {
    command = <<DOC
      export FILE='${var.cert_directory}/${each.key}-${var.public_key_file_name_suffix}'
      echo '${tls_private_key.cert[each.key].private_key_pem}' >  $FILE && \
        chmod ${var.permissions} $FILE && \
        chown ${var.owner} $FILE
    DOC
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<DOC
      export FILE='${var.cert_directory}/${each.key}-${var.public_key_file_name_suffix}'
      rm $FILE
    DOC
  }
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

  cert_request_pem = tls_cert_request.cert.cert_request_pem

  ca_key_algorithm   = tls_private_key.ca.algorithm
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = var.validity_period_hours
  allowed_uses          = var.allowed_uses

  # Store the certificate's public key in a file.
  provisioner "local-exec" {
    command = <<DOC
      export FILE='${var.cert_directory}/${each.key}-${var.public_key_file_name_suffix}'
      echo '${tls_locally_signed_cert.cert.cert_pem}' > $FILE && \
        chmod ${var.permissions} $FILE && \
        chown ${var.owner} $FILE
    DOC
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = <<DOC
      export FILE='${var.cert_directory}/${each.key}-${var.public_key_file_name_suffix}'
      rm $FILE
    DOC
  }
}
