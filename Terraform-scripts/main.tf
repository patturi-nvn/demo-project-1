# Generate key pair
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair
resource "aws_key_pair" "generated_key" {
  key_name   = "terraform-key"
  public_key = tls_private_key.key_pair.public_key_openssh
}

# Create Jump Server (Bastion Host)
resource "aws_instance" "jump_server" {
  ami           = "ami-0fc82f4dabc05670b"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public[0].id
  key_name      = aws_key_pair.generated_key.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.jump_server_sg.id]

  tags = {
    Name = "jump-server"
  }
}

# Create Jenkins Server
resource "aws_instance" "jenkins_server" {
  ami           = "ami-0fc82f4dabc05670b"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.public[0].id
  key_name      = aws_key_pair.generated_key.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.jenkins_server_sg.id]

  user_data = file("user_data.sh")

  tags = {
    Name = "jenkins-server"
  }
} 