output "private_ip" {
  description = "Private IP of the instance"
  value       = "${aws_instance.instance.private_ip}"
}
