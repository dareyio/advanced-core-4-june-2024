
resource "aws_security_group_rule" "allow_nginx_ingress_port80" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = aws_security_group.nginx-sg.id
  security_group_id = aws_security_group.int-alb-sg.id
}


resource "aws_security_group_rule" "allow_all_int_alb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.int-alb-sg.id
}

