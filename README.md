## Boundary Demo
This repo provisions compute instances in AWS for Boundary:
* Boundary Server
* Linux Server target
* Windows Server target

The repo also configures the Boundary server in dev mode.

Terraform Apply Compute:
```
terraform apply -target=module.compute
```

Terraform Apply Boundary Configurations. Note: Wait for Boundary server to full bootstrap.

```
terraform apply -target=module.boundary
```

## SSH to Linux Target

Boundary Client App:

![Boundary Client](/images/boundary_linux.png)



```
ssh -i awskey.pem ubuntu@127.0.0.1 -p58266
```

Boundary Command with SSH:

```
boundary connect ssh -target-id <target-id> username ubuntu  -- -i awskey.pem
```
```
boundary connect ssh -target-id <target-id>  -- -i awskey.pem -l ubuntu
```

Boundary Command with static listener:

```
boundary connect -listen-port=12345 -target-id <target-id>
ssh -i awskey.pem ubuntu@127.0.0.1 -p12345
```

## RDP to Windows Target


Generate RDP password using 'awskey.pem':
![AWS Consule](/images/aws_console.png)

Create Boundary RDP session -
Boundary CLI:
```
boundary connect -target-id <target-id>
```
Note: `boundary connect rdp` wrapper renders mstsc (doesn't launch RDP client for MAC). Could optionally use `boundary connect exec` to launch a client of choice.

Create Boundary RDP session - Boundary Client:
![Boundary Session Client](/images/rdp_session.png)

Connect via RDP - MS RDP Client:
![RDP Client](/images/rdp_client.png)

## HTTP to Boundary Server

Create Boundary HTTP session - Boundary Client:
![HTTP Client](/images/boundary_http_session.png)

Connect via HTTP - Browser:

![HTTP Client Session](/images/boundary_http.png)

## References
Sam Gabrail - https://github.com/samgabrail/boundary-intro

Boundary Learn Guide - https://learn.hashicorp.com/boundary

Boundary Docs - https://www.boundaryproject.io/docs
