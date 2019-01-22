providee "aws" {
    use_backend: yum
  region     = "us-east-1"
}

resource "aws_instance" "myserver" {
  ami = "ami-cfe4b2b0"
  instance_type = "t2.micro"
  key_name = "HomeLaptop"
  vpc_security_group_ids = ["sg-023e46cd6251b6519"]

  tags {
    Name = "helloworld"
  }

  provisioner "remote-exec" {
    connection {
      user = "ec2-user"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
    inline = [
      "sudo yum install --enablerepo=epel -y git",
      "sudo pip install ansible",
      "sudo /usr/local/bin/ansible-pull -U https://github.com/songdet/EffectiveDevops helloworld/ansible/helloworld.yml -i localhost",
    ]
  }
}

output "myserver" {
 value = "${aws_instance.myserver.public_ip}"
}
