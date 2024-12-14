resource "aws_key_pair" "jenkins_key_pair" {
  key_name   = var.key_pair_name
  public_key = file("~/.ssh/${var.key_pair_name}.pub")
}

