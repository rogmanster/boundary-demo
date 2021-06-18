data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    #values = ["ubuntu/images/hvm-ssd/ubuntu-disco-19.04-amd64-server-*"]
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "random_id" "name" {
  byte_length = 4
}

resource "aws_key_pair" "awskey" {
  key_name   = "${var.name}-awskwy-${random_id.name.hex}"
  public_key = tls_private_key.awskey.public_key_openssh
}

resource "aws_security_group" "allow_all" {
  name        = "${var.name}-allow-all-${random_id.name.hex}"
  description = "Allow all inbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//Boundary Instance
resource "aws_instance" "boundary" {
  ami               = data.aws_ami.ubuntu.id
  instance_type     = var.instance_type
  key_name          = aws_key_pair.awskey.key_name
  security_groups   = [aws_security_group.allow_all.name]

  tags = merge(var.tags, {
    Name        = var.name
  })

  user_data = data.template_file.boundary-init.rendered
}

data "template_file" "boundary-init" {
  template = file("${path.module}/configs/boundary_config.tpl")
}

//Linux Target
resource "aws_instance" "ubuntu" {
  count             = var.linux_count
  ami               = data.aws_ami.ubuntu.id
  instance_type     = var.instance_type
  key_name          = aws_key_pair.awskey.key_name
  security_groups   = [aws_security_group.allow_all.name]

  tags = merge(var.tags, {
    Name        = var.name
  })
}

//Windows Target
resource "aws_instance" "windows" {
  count             = var.windows_count
  ami               = "ami-0bcf6f46e3bbdfbac" #Window Server 2012
  instance_type     = var.instance_type
  key_name          = aws_key_pair.awskey.key_name
  security_groups   = [aws_security_group.allow_all.name]

  tags = merge(var.tags, {
    Name        = var.name
  })
}

//Clean-up
//https://github.com/hashicorp/boundary/issues/1055
/*
resource "null_resource" "destroy" {
  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
    rm keys.json
    rm awskey.pem
    rm bootstrap.txt
    rm bob.txt
    rm alice.txt
EOF
  }
}*/
