output "ec2_ip" {
  value = aws_instance.public.*.public_ip
}