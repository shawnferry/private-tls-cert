# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "cert_directory" {
  description = "Write the certificate files to this directory (e.g. /etc/tls/)."
}

variable "owner" {
  description = "The OS user who should be given ownership over the certificate files."
}

## CA
variable "ca_public_key_file_name" {
  description = "Write the PEM-encoded CA certificate public key to this path (e.g. ca.crt.pem)."
}

variable "ca_common_name" {
  description = "The common name to use in the subject of the CA certificate (e.g. acme.co root cert)."
}

variable "organization_name" {
  description = "The name of the organization to associate with the certificates (e.g. Acme Co)."

}
variable "ca_validity_period_hours" {
  description = "The number of hours after initial issuing that the CA certificate will become invalid."
}

# Certs
variable "certs" {
  type = map
  description = <<DOC
  Map of lists defining certificates to create
    {
      common_name {
        dns_names = [],
        ip_addresses = [],
        allowed_uses = [],
        validity_hours = [12], # Single Item List
      },
      "acme.com" {
        dns_names = ["www.acme.com", "acme.com", "ftp.acme.com"]
      },
    }
  DOC
}

variable "validity_period_hours_default" {
  description = "The number of hours after initial issuing that the certificate will become invalid."
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "public_key_file_name_suffix" {
  description = "Create certificate public keys with this suffix (e.g. <my-app>.crt.pem)."
  default = ".crt.pem"
}

variable "private_key_file_name_suffix" {
  description = "Write the PEM-encoded certificate private key to this path (e.g. <my-app>.key.pem)."
  default = ".key.pem"
}

variable "ca_allowed_uses" {
  description = "List of keywords from RFC5280 describing a use that is permitted for the CA certificate. For more info and the list of keywords, see https://www.terraform.io/docs/providers/tls/r/self_signed_cert.html#allowed_uses."
  type        = list

  default = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
  ]
}

variable "allowed_uses" {
  description = "List of keywords from RFC5280 describing a use that is permitted for the issued certificate. For more info and the list of keywords, see https://www.terraform.io/docs/providers/tls/r/self_signed_cert.html#allowed_uses."
  type        = list

  default = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

variable "permissions" {
  description = "The Unix file permission to assign to the cert files (e.g. 0600)."
  default     = "0600"
}

variable "private_key_algorithm" {
  description = "The name of the algorithm to use for private keys. Must be one of: RSA or ECDSA."
  default     = "RSA"
}

variable "private_key_ecdsa_curve" {
  description = "The name of the elliptic curve to use. Should only be used if var.private_key_algorithm is ECDSA. Must be one of P224, P256, P384 or P521."
  default     = "P256"
}

variable "private_key_rsa_bits" {
  description = "The size of the generated RSA key in bits. Should only be used if var.private_key_algorithm is RSA."
  default     = "2048"
}
