output "ec2_ip_public" {
  value = aws_instance.public.*.public_ip
}

output "ec2_ip_private" {
  value = aws_instance.private.*.private_ip
}