variable "name_prefix" {
  description = "Prefix of the name of Google Cloud Storage bucket, followed by 10 random characters"
  default     = "paloaltonetworks-firewall-bootstrap-"
  type        = string
}

variable "files" {
  description = "Map of all files to copy to bucket. The keys are local paths, the values are remote paths. For example `{\"dir/my.txt\" = \"config/init-cfg.txt\"}`"
  default     = {}
  type        = map(string)
}

variable "service_account" {
  description = "Optional IAM Service Account (just an email) that will be granted read-only access to this bucket"
  default     = null
  type        = string
}

variable "location" {
  description = "Location in which the GCS Bucket will be deployed. Available locations can be found under https://cloud.google.com/storage/docs/locations."
  type        = string
}


variable "bootstrap_files_dir" {
  description = "Bootstrap file directory. More information can be found at https://docs.paloaltonetworks.com/vm-series/9-1/vm-series-deployment/bootstrap-the-vm-series-firewall/bootstrap-package"
  type        = string
  default     = ""
}


variable "folders" {
  description = <<-EOF
  List of folder paths that will be used to create dedicated boostrap package folder sets per firewall or firewall group (for example to distinguish configuration per region, per inbound/obew role, etc) within the created storage bucket.

  A default value (empty list) will result in the creation of a single bootstrap package folder set in the bucket top-level directory.
  EOF
  default     = []
  type        = list(any)
}

