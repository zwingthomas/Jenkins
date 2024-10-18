resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-354923279633"

  provider = aws.us_east

  tags = {
    Name        = "Terraform state bucket"
    Environment = "Jenkins"
  }
}

resource "aws_s3_bucket_versioning" "x" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform lock table"
    Environment = "Jenkins"
  }
}
