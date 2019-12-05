# Random names for all resources
resource "random_pet" "env" {
  length    = 2
  separator = "-"
}
