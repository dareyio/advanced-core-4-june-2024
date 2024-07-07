#External Load balancer for reverse proxy nginx
#---------------------------------

resource "aws_lb" "external-alb" {
  name            = "masterclass-external-alb"
  internal        = false
  security_groups = [aws_security_group.ext-alb-sg.id]

  subnets = [aws_subnet.PublicSubnet-1.id, aws_subnet.PublicSubnet-2.id]

  tags = merge(local.tags,
  { Name = "masterclass-external-alb" })

  ip_address_type    = "ipv4"
  load_balancer_type = "application"
}

#--- create a listener for the load balancer

resource "aws_lb_listener" "nginx-listner" {
  load_balancer_arn = aws_lb.external-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx-tgt.arn
  }
}


#--- create a target group for the external load balancer
resource "aws_lb_target_group" "nginx-tgt" {
  name        = "masterclass-nginx-tgt"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id
  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "nginx-alb-asg-attach" {
  autoscaling_group_name = aws_autoscaling_group.nginx-asg.id
  lb_target_group_arn    = aws_lb_target_group.nginx-tgt.arn
  # Explicitly declare dependencies
  depends_on = [
    aws_lb_target_group.nginx-tgt,
    aws_autoscaling_group.nginx-asg,
  ]
}

