@'
resource "aws_security_group" "bad_example" {
  name        = "test_security_group"
  description = "Security group with open SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # This is a policy violation
  }
}
'@ | Out-File -FilePath "C:\CheckovTest\main.tf" -Encoding utf8

