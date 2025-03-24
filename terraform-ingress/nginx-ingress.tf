# Fetch EKS Cluster details
data "aws_eks_cluster" "cluster" {
  name = "Freshfarm-cluster"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "Freshfarm-cluster"
}


provider "helm" {
  kubernetes {
    host                   = "https://3C83B40614911694BBB50D8BB38CA498.gr7.eu-north-1.eks.amazonaws.com"  # Terraform output will provide the endpoint url
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode("LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJUVFtekdHWFR6WTR3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBek1qUXdPREE0TlRSYUZ3MHpOVEF6TWpJd09ERXpOVFJhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURVazRSMlZjdXhHbGpRai84Y2N4RVFQOG80bTJ5dmtqVHovMVZCeW5LOFNvb3MwcTRjcU9DbS9Eb3QKdmMrREpyemhySFNEUXBTWVpDVm5PRnhXT1NwRFJ5REU3Sk15UjI4eFNQcGdKRTFtZWxZMXlZWWhObmJuYVNOTwpSS0tyTWFhczZUbzNKS3RGR0xsOU85NmI2NG9LcWxqSWFFOXdlc2pjVExQUmI5emJpNUNIOXQwRU1QNXJKS0ttCkNlOUYvNmFEaDJkUUxNd1lwVUtjRHdVWUxkc1F0b1VldDlJdnVuekllczhSMkdTOVJDSVFKU0F5N3poeDZyRzYKWkdYMmV0WVZJNUt4SmR2MmNtbzAzdEZBSVFJejhzZWI3VXdBeUJVazFIZS9weTBwK1d5U0lsaFEzUkc5bno2MAp5dWQ1WVhUdmp1K01VWG1BMVNDVVlUa0M3dlRGQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJRL0VsTWFzVCs0emxwSllSd3c5ODFnYTJJSUhqQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQkt0TjB4ZjEvSQo4Zkd1eXlvNUhoZnJCTzEwaEZ1UWlrTDA1eDcwTzR3SVZuUUZZQ3M4MERrTEdYYk9DcHREMElPelJKcUpPZG8yCm1TQUJWVm5PdlVmU0FyQjhxUDdyUXR4emdZNVVCWkZ2bGRhQVJyeWFXSGRIL1R5UUZYdFo0ZzFLTndYUkQ0N2sKb1JZMnJpaTVqQVI2VG8vSmJudjlWN3R6T1NpaHBScGlJd2d5eVIxUk5kZk95cW0yOXVWWlpsRjBzT1pydWRJWQpkMVBDREdEU05GVFlLd1MveUZZTDNtTHRUaWlaKzE5a1MwSzhzQnkrNElqNWdhbGVFOG90b2RHM1ZaVG1qckF2CjJTOU5Tc2ZHV1JnOWRmS0NMdFdqU2xrWi9GSEl6RC9YVlZ0anJGeEJjTXZ2SDhHVGs2SFE2c3VVb2lMSm84NVQKbnJQMVNwM0FXams5Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K") # Terraform output will provide the certificate
  }
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"

  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
}