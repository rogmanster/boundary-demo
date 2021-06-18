output "boundary_public_ip" {
  value = aws_instance.boundary.public_ip
}

output "boundary_private_ip" {
  value = aws_instance.boundary.*.private_ip
}

output "ubuntu_public_ip" {
  value = aws_instance.ubuntu.*.public_ip
}

output "ubuntu_private_ip" {
  value = aws_instance.ubuntu.*.private_ip
}

output "windows_public_ip" {
  value = aws_instance.windows.*.public_ip
}

output "windows_private_ip" {
  value = aws_instance.windows.*.private_ip
}
