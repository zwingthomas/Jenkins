resource "aws_instance" "jenkins_server" {
  ami                         = data.aws_ami.ubuntu.id  # Use Ubuntu AMI
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  key_name                    = var.key_pair_name
  iam_instance_profile        = aws_iam_instance_profile.jenkins_instance_profile.name
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-instance"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}
