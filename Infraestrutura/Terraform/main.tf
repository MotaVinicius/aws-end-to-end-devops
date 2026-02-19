resource "aws_instance" "nginx_lb" {
  ami                    = "ami-05efc83cb5512477c"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.subnet_public.id
  vpc_security_group_ids = [aws_security_group.sg_nginx_public.id]
  key_name               = "<Chave_Privada>"

    user_data = templatefile("${path.module}/nginx_setup.tpl", {
    app1_ip = aws_instance.app_1.private_ip
    app2_ip = aws_instance.app_2.private_ip
  })

  tags = {
    Name = "nginx-load-balancer"
  }
}
resource "aws_instance" "app_1" {
  ami                    = "ami-05efc83cb5512477c"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.subnet_private.id
  vpc_security_group_ids = [aws_security_group.sg_app_private.id]
  iam_instance_profile   = "ECR_SSM_Role"
  key_name = "<Chave_Privada>"

    user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "app-1"
  }
}
resource "aws_instance" "app_2" {
  ami                    = "ami-05efc83cb5512477c"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.subnet_private.id
  vpc_security_group_ids = [aws_security_group.sg_app_private.id]
  iam_instance_profile   = "ECR_SSM_Role"
  key_name               = "<Chave_Privada>"

    user_data = file("${path.module}/user_data.sh")  
  
  tags = {
    Name = "app-2"
  }
}




resource "aws_security_group" "sg_nginx_public" {
  name   = "nginx-public"
  vpc_id = aws_vpc.vpc_pipelines.id
}
resource "aws_vpc_security_group_ingress_rule" "nginx_http" {
  security_group_id = aws_security_group.sg_nginx_public.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "nginx_ssh" {
  security_group_id = aws_security_group.sg_nginx_public.id
  cidr_ipv4         = "<Meu_IP>"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "nginx_all_out" {
  security_group_id = aws_security_group.sg_nginx_public.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}




resource "aws_security_group" "sg_app_private" {
  name   = "app-private"
  vpc_id = aws_vpc.vpc_pipelines.id
}
resource "aws_vpc_security_group_ingress_rule" "app_from_nginx" {
  security_group_id            = aws_security_group.sg_app_private.id
  referenced_security_group_id = aws_security_group.sg_nginx_public.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "ssh_from_nginx" {
  security_group_id            = aws_security_group.sg_app_private.id
  referenced_security_group_id = aws_security_group.sg_nginx_public.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "app_all_out" {
  security_group_id = aws_security_group.sg_app_private.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}




