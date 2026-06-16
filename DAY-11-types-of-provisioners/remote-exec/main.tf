resource "aws_key_pair" "my_key" {
  key_name   = "my-key"
  public_key = file("my-key.pub")
}
resource "aws_instance" "web" {
   ami           = "ami-0521cb2d60cfbb1a6"
  instance_type = "t3.micro"
  key_name = "my-key"

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("my-key.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install httpd -y",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd"
    ]
  }
  provisioner "local-exec" {
    command = "echo Instance created with IP: ${self.public_ip} >> instance-log.txt"
  }
}