#terraform {
#  required_providers {
#    boundary = {
#      source = "hashicorp/boundary"
      #version = "0.1.2"
#    }
#  }
#}

resource "boundary_scope" "global" {
  global_scope = true
  description  = "My first global scope!"
  scope_id     = "global"
}

resource "boundary_scope" "corp" {
  name                     = "Corp One"
  description              = "My first scope!"
  scope_id                 = boundary_scope.global.id
  auto_create_admin_role   = true
  auto_create_default_role = true
}

## Use password auth method
resource "boundary_auth_method" "password" {
  name     = "Corp Password"
  scope_id = boundary_scope.corp.id
  type     = "password"
}

## Create user accounts with password: password
resource "boundary_account" "users_acct" {
  for_each       = var.users
  name           = each.key
  description    = "User account for ${each.key}"
  type           = "password"
  login_name     = lower(each.key)
  password       = "password"
  auth_method_id = boundary_auth_method.password.id
}

resource "boundary_account" "readonly_users_acct" {
  for_each       = var.readonly_users
  name           = each.key
  description    = "User account for ${each.key}"
  type           = "password"
  login_name     = lower(each.key)
  password       = "password"
  auth_method_id = boundary_auth_method.password.id
}

resource "boundary_user" "users" {
  for_each    = var.users
  name        = each.key
  description = "User resource for ${each.key}"
  scope_id    = boundary_scope.corp.id
}

resource "boundary_user" "readonly_users" {
  for_each    = var.readonly_users
  name        = each.key
  description = "User resource for ${each.key}"
  scope_id    = boundary_scope.corp.id
}

resource "boundary_group" "readonly" {
  name        = "read-only"
  description = "Organization group for readonly users"
  member_ids  = [for user in boundary_user.readonly_users : user.id]
  scope_id    = boundary_scope.corp.id
}

resource "boundary_role" "organization_readonly" {
  name          = "Read-only"
  description   = "Read-only role"
  principal_ids = [boundary_group.readonly.id]
  grant_strings = ["id=*;type=*;actions=read"]
  scope_id      = boundary_scope.corp.id
}

resource "boundary_role" "organization_admin" {
  name        = "admin"
  description = "Administrator role"
  principal_ids = concat(
    [for user in boundary_user.users : user.id]
  )
  grant_strings = ["id=*;type=*;actions=create,read,update,delete"]
  scope_id      = boundary_scope.corp.id
}

resource "boundary_scope" "core_infra" {
  name                   = "Core infrastrcture"
  description            = "My first project!"
  scope_id               = boundary_scope.corp.id
  auto_create_admin_role = true
}

resource "boundary_host_catalog" "backend_servers" {
  name        = "backend_servers"
  description = "Backend servers host catalog"
  type        = "static"
  scope_id    = boundary_scope.core_infra.id
}

resource "boundary_host" "linux_servers" {
  for_each        = var.backend_server_ips
  type            = "static"
  name            = "linux_server_service_${each.value}"
  description     = "Linux server host"
  address         = each.key
  host_catalog_id = boundary_host_catalog.backend_servers.id
}

resource "boundary_host" "windows_servers" {
  for_each        = var.backend_windows_server_ips
  type            = "static"
  name            = "windows_server_service_${each.value}"
  description     = "Windows server host"
  address         = each.key
  host_catalog_id = boundary_host_catalog.backend_servers.id
}

resource "boundary_host" "boundary_server" {
  for_each        = var.boundary_server_ip
  type            = "static"
  name            = "boundary_server_service_${each.value}"
  description     = "Boundary server host"
  address         = each.key
  host_catalog_id = boundary_host_catalog.backend_servers.id
}

resource "boundary_host_set" "linux_servers_ssh" {
  type            = "static"
  name            = "linux_servers_ssh"
  description     = "Host set for linux servers"
  host_catalog_id = boundary_host_catalog.backend_servers.id
  host_ids        = [for host in boundary_host.linux_servers : host.id]
}

resource "boundary_host_set" "windows_servers_rdp" {
  type            = "static"
  name            = "windows_servers_rdp"
  description     = "Host set for Windows servers"
  host_catalog_id = boundary_host_catalog.backend_servers.id
  host_ids        = [for host in boundary_host.windows_servers : host.id]
}

resource "boundary_host_set" "boundary_server_http" {
  type            = "static"
  name            = "boundary_server_http"
  description     = "Host set for Boundary server console"
  host_catalog_id = boundary_host_catalog.backend_servers.id
  host_ids        = [for host in boundary_host.boundary_server : host.id]
}

# create target for accessing backend servers on port :8080
// resource "boundary_target" "backend_servers_service" {
//   type         = "tcp"
//   name         = "Backend service"
//   description  = "Backend service target"
//   scope_id     = boundary_scope.core_infra.id
//   default_port = "8080"

//   host_set_ids = [
//     boundary_host_set.backend_servers_ssh .id
//   ]
// }

# create target for accessing backend servers on port :22
resource "boundary_target" "linux_servers_ssh" {
  type         = "tcp"
  name         = "Linux SSH"
  description  = "Linux SSH target"
  scope_id     = boundary_scope.core_infra.id
  default_port = "22"

  host_set_ids = [
    boundary_host_set.linux_servers_ssh.id
  ]
}

# create target for accessing backend servers on port :3389
resource "boundary_target" "windows_servers_rdp" {
  type                     = "tcp"
  name                     = "Windows RDP"
  description              = "Windows RDP target"
  scope_id                 = boundary_scope.core_infra.id
  default_port             = "3389"
  session_connection_limit = 2
  host_set_ids = [
    boundary_host_set.windows_servers_rdp.id
  ]
}

# create target for accessing boundary server :9200
resource "boundary_target" "boundary_server_http" {
  type                     = "tcp"
  name                     = "Boundary HTTP"
  description              = "Boundary HTTP target"
  scope_id                 = boundary_scope.core_infra.id
  default_port             = "9200"
  session_connection_limit = -1
  host_set_ids = [
    boundary_host_set.boundary_server_http.id
  ]
}
