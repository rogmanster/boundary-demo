output "Boundary_Connection-Info" {
  value = <<README

export BOUNDARY_ADDR=http://${module.compute.boundary_public_ip}:9200
boundary authenticate password -auth-method-id=ampw_1234567890 -login-name=admin -password=password -keyring-type=none -format=json | jq -r ".item.attributes.token" > boundary_token.txt
export BOUNDARY_TOKEN=$(cat boundary_token.txt)

Linux Target Private IPs: ${join(", ", module.compute.ubuntu_private_ip)}
Windows Target Private IPs: ${join(", ", module.compute.windows_private_ip)}

Boundary Server:
username: admin
password: password

README
}
