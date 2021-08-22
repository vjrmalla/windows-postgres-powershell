provider "aws" {
  region = "eu-west-2"
}
resource "aws_instance" "web" {
  ami           = "ami-0be8cb286eca791c5"
  instance_type = "t2.micro"
  user_data = file("postgres.ps1")
  key_name = "jenkins"
  tags = {
    Name = "windows-postgres"
  }
}