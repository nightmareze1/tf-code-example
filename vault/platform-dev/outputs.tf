output "subordinate_ca_arn" {
  description = "The ARN of the Subordinate CA"
  value       = module.cas_certs_route53.*.subordinate_ca_arn
}
