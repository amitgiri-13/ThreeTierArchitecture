# Cost Analysis

This is a rough **cost estimate for a development environment and small-scale infrastructure**. Actual costs may vary based on region, usage, and time—refer to the **[AWS Pricing Calculator](https://calculator.aws/)** for up-to-date pricing.


## Three Tier Architecture Cost Estimation

| Segment | Resources Included | Dev Cost | 10K Users Cost |
|--------|--------------------|----------|----------------|
| Networking | VPC, Subnets, NAT Gateway, ALB, Cloudflare DNS | $50 | $57 |
| Application | EC2 (ASG t2.micro instances) | $8 | $16 |
| Database | RDS MySQL (db.t3.micro + storage + backups) | $19 | $22 |
| Storage | EC2 EBS volumes + snapshots | $3 | $6 |
| Data Transfer | Internet egress + inter-AZ traffic | $7 | $40 |
| **TOTAL (Core Infra)** |  | **≈ $87 / month** | **≈ $141 / month** |

---

## Optional Cost Estimation

| Category | Item | Estimated Monthly Cost | Notes |
|---------|------|------------------------|------|
| Monitoring | CloudWatch logs & metrics | $2 – $5 | depends on log volume |
| Object Storage | S3 (user uploads/backups) | $1 – $10 | depends on usage |
| CDN (optional) | Cloudflare caching | $0 | free tier |
| Domain | Domain registration | ~$1/month ($10–15/year) | via registrar |
| Backups | Extra snapshots / DB backup | $1 – $3 | optional |
| **TOTAL (Additional)** |  | **≈ $5 – $20 / month** | variable usage |

---