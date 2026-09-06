resource "aws_security_group" "k3s_node" {
	name 		= "${var.project_name}-k3s-node-sg"
	description	= "K3s server + agent: SSH/API whitelisted"
	vpc_id 		= aws_vpc.main.id

	ingress {
		description	= "SSH from whitelisted IPs"
		from_port	= 22
		to_port 	= 22
		protocol 	= "tcp"
		cidr_blocks	= var.whitelisted_ips
	}

	ingress {
		description 	= "K8s API from whitelisted IPs"
		from_port	= 6443
		to_port		= 6443
		protocol	= "tcp"
		cidr_blocks	= var.whitelisted_ips
	}

	ingress	{
		description	= "HTTP public"
		from_port	= 80
		to_port		= 80
		protocol	= "tcp"
		cidr_blocks	= ["0.0.0.0/0"]
	}

	ingress	{
		description	= "HTTPS public"
		from_port	= 443
		to_port		= 443
		protocol	= "tcp"
		cidr_blocks	= ["0.0.0.0/0"]
	}

	ingress	{
		description	= "NodePort range from whitelisted IPs"
		from_port	= 30000
		to_port		= 32767
		protocol	= "tcp"
		cidr_blocks	= var.whitelisted_ips
	}

	ingress {
		description	= "K8s API from cluster members (agent joining/staying connected)"
		from_port	= 6443
		to_port		= 6443
		protocol	= "tcp"
		self		= true
	}

	ingress {
		description	= "Flannel VXLAN between cluster members (pod-to-pod networking)"
		from_port	= 8472
		to_port		= 8472
		protocol	= "udp"
		self		= true
	}

	ingress	{
		description	= "Kubelet from cluster members"
		from_port	= 10250
		to_port		= 10250
		protocol	= "tcp"
		self		= true
	}

	egress {
		description	= "All outbound"
		from_port	= 0
		to_port		= 0
		protocol	= "-1"
		cidr_blocks	= ["0.0.0.0/0"]
	}

	tags = {
		Name = "${var.project_name}-k3s-node-sg"
	}
}
