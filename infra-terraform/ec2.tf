data "aws_ami" "ubuntu" {
	most_recent	= true
	owners		= ["099720109477"]

	filter {
		name	= "name"
		values	= ["ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-*"]
	}
}
# K3s SERVER NODE (Public subnet, ingress + control plane)
data "aws_iam_role" "k3s_server_role" {
  name = "${var.project_name}-k3s-server-role"
}

data "aws_iam_instance_profile" "k3s_server_profile" {
	name	= "${var.project_name}-k3s-server-profile"
}

# STATIC PUBLIC IP FOR THE NODE SO DNS/WHITELISTING STAYS STABLE ACCROSS REBOOTS
resource "aws_eip" "k3s_server" {
	domain	= "vpc"

	tags = {
		Name = "${var.project_name}-k3s-server-eip"
	}
}

resource "aws_instance" "k3s_server" {
	ami			= data.aws_ami.ubuntu.id
	instance_type		= var.instance_type
	subnet_id		= aws_subnet.public[0].id
	key_name		= var.key_pair_name
	vpc_security_group_ids	= [aws_security_group.k3s_node.id]
	iam_instance_profile	= data.aws_iam_instance_profile.k3s_server_profile.name

	user_data = templatefile("${path.module}/user_data/k3s-server-install.sh.tpl", {
    k3s_token = random_password.k3s_token.result
    public_ip = aws_eip.k3s_server.public_ip
  })

	root_block_device {
		volume_size	= 30
		volume_type	= "gp3"
	}

	tags = {
		Name = "${var.project_name}-k3s-server"
	}
}

resource "aws_eip_association" "k3s_server" {
  instance_id  = aws_instance.k3s_server.id
  allocation_id = aws_eip.k3s_server.id
}

# K3s AGENT node (private subnet, app + DB + Jenkins workloads)
data "aws_iam_role" "k3s_agent_role" {
  name = "${var.project_name}-k3s-agent-role"
}

data "aws_iam_instance_profile" "k3s_agent_profile" {
  name        = "${var.project_name}-k3s-agent-profile"
}

resource "aws_instance" "k3s_agent" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private[0].id
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.k3s_node.id]
  iam_instance_profile   = data.aws_iam_instance_profile.k3s_agent_profile.name

  user_data = templatefile("${path.module}/user_data/k3s-agent-install.sh.tpl", {
    k3s_token             = random_password.k3s_token.result
    server_private_ip     = aws_instance.k3s_server.private_ip
  })

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags  = {
    Name  = "${var.project_name}-k3s-agent"
  }

  depends_on = [aws_instance.k3s_server]
}
