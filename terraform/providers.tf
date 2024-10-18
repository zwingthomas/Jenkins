provider "aws" {
  alias = "us_east"
  region = var.aws_region
}

provider "aws" {
  alias  = "eu_central"
  region = "eu-central-1"
}
