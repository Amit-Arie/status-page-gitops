data "aws_route53_zone" "main" {
	count		= var.domain_name != "" ? 1 : 0
	name		= var.domain_name
	private_zone	= true
}

resource "aws_route53_record" "app" {
	count	= var.domain_name != "" ? 1 : 0
	zone_id	= data.aws_route53_zone.main[0].zone_id
	name	= "${var.subdomain}.${var.domain_name}"
	type	= "A"
	ttl	= 300
	records	= [aws_eip.k3s_server.public_ip]
}
