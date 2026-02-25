# Three-Tier Architecture 

**A highly available and scalable three-tier architecture is implemented on Amazon Web Services, with domain and DNS management handled by Cloudflare. The infrastructure is fully managed using Terraform, enabling version control, modular configuration, and consistent deployments across dev, staging, and production environments.**

## Implementation

### 1. [Infrastructure as code - Terraform](./terraform)
### 2. [Demo Application Deployment](./DEMO.md)
### 3. [Demo Application Code](./django_s3_storage_app)

## Three-Architecture overview

The architecture follows the standard three-tier design:

1. **Web Layer** – Handles incoming HTTP/HTTPS traffic via an Application Load Balancer.  
2. **Application Layer** – Runs the business logic on scalable (with Auto Scaling Groups) EC2 instances within private subnets.  
3. **Database Layer** – Provides managed, highly available RDS instances for persistent data storage.  

![alt text](./images/architecture.svg)

## Architecture Components

- **VPC** - The infrastructure is deployed within a dedicated Virtual Private Cloud (VPC) for network isolation and security.
- **Multi-AZ** - Resources are distributed across multiple Availability Zones to ensure high availability and fault tolerance.
- **Subnets** - The VPC contains public subnets, private subnets for the web layer, and private subnets for the database layer.
- **Internet Gateway** - An Internet Gateway provides outbound internet access for resources in public subnets.
- **Regional NAT Gateway** - NAT Gateways allow private subnets to access the internet securely without exposing instances directly.
- **Security Groups** - Security groups are defined for the ALB, web application instances in the ASG, and the database for controlled access.
- **Network ACLs** - Network ACLs are applied per subnet type (public, private web, private DB) for additional network-level security.
- **RDS Instance** - Amazon RDS  provides a managed, highly available, and secure database layer for storing application data in private subnets.
- **Auto Scaling Group** - Web application servers are deployed in an Auto Scaling Group for dynamic scaling based on demand.
- **Application Load Balancer** - An ALB distributes incoming traffic across the web servers for improved performance and reliability.
- **Cloudflare** - Cloudflare manages the domain and DNS records, providing fast resolution, SSL, and security features.
 
---

##  Features

- High availability across multiple Availability Zones  
- Auto Scaling for web/application servers  
- Application Load Balancer for traffic distribution  
- Modular Terraform configuration for easy management  
- Managed RDS for database layer  
- Cloudflare DNS and domain management  
- Secure network with VPC, subnets, security groups, and NACLs

---

##  Tech Stack

- **Cloud Provider:** AWS  
- **DNS & Domain Management:** Cloudflare  
- **Infrastructure as Code:** Terraform  
- **Compute:** EC2 instances in Auto Scaling Groups  
- **Load Balancing:** Application Load Balancer  
- **Database:** Amazon RDS  
- **Version Control:** Git/GitHub  

--- 
##  Setup & Deployment Steps : [Demo Application Deployment](./DEMO.md)

###  Prerequisites

Make sure you have the following configured before deployment:

- **AWS CLI** installed and configured with proper credentials and region
- **Terraform** installed (recommended version >= 1.5)
- **Cloudflare Zone ID** for your domain
- **Cloudflare API Token/Key** with permission to manage DNS records
- **User data script (`userdata.sh`)** prepared for application deployment

---

##  Security Considerations

* All database instances reside in private subnets with restricted access.
* Security groups enforce strict inbound/outbound rules per component.
* Network ACLs provide additional layer of network control.
* Cloudflare ensures SSL, DDoS protection, and secure DNS resolution.

---

##  References

* [Terraform Documentation](https://www.terraform.io/docs)
* [AWS VPC Guide](https://docs.aws.amazon.com/vpc/latest/userguide/)
* [Cloudflare DNS Setup](https://developers.cloudflare.com/dns/)

---

##  License

This project is licensed under the MIT License.


---

