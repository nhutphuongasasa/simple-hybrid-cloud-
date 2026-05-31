# Hybrid Cloud Lab — GCP + On-Premises (VMware Workstation)

Lab triển khai hạ tầng **hybrid cloud** kết hợp Google Cloud Platform và môi trường On-Premises chạy trên VMware Workstation, kết nối qua **HA VPN IPSec + BGP**.

---

## Mục tiêu

Xây dựng hệ thống web app thực tế với:

- **Frontend & Backend** chạy trên GCP, đóng gói bằng Docker Compose, image build sẵn qua Packer + Ansible
- **Database (PostgreSQL)** đặt on-premises, backend GCP kết nối về qua VPN tunnel
- **HA VPN 2 tunnel + BGP** đảm bảo kết nối không gián đoạn khi một tunnel lỗi
- **pfSense HA (CARP)** on-premises để VPN không có single point of failure

---

## 1.Kiến trúc tổng quan


<img width="826" height="758" alt="image" src="https://github.com/user-attachments/assets/722333a4-0b43-4918-82cb-f22c200d0d3d" />

**Luồng traffic:**
User → nginx:80 → /api/* → Backend:3001 → VPN Tunnel → PostgreSQL on-prem:5432

User → /      → Frontend:3000

---

## Cấu trúc thư mục

<img width="410" height="736" alt="image" src="https://github.com/user-attachments/assets/9da31abd-ae20-4d5f-8a84-c87eb4e64ba1" />

---

## 3.Stack công nghệ

| Layer | Công nghệ |
|---|---|
| Cloud Provider | Google Cloud Platform (asia-east2) |
| IaC | Terraform ~> 5.0 |
| Image Build | Packer + Ansible |
| Container Runtime | Docker Compose |
| VPN | GCP HA VPN + IPSec IKEv2 + BGP |
| On-prem Firewall | pfSense HA (CARP failover) |
| Routing Protocol | BGP (GCP ASN 65001 ↔ pfSense ASN 65002) |
| OS | Ubuntu 22.04 LTS |
| Database | PostgreSQL (on-premises) |

---

## 4.Hướng dẫn triển khai

### Yêu cầu

- `gcloud` CLI đã xác thực (`gcloud auth application-default login`)
- `terraform >= 1.5.0`
- `packer` đã cài
- `ansible` đã cài, đã chạy `ansible-galaxy install -r requirements.yml`
- Service Account `packer@<project-id>.iam.gserviceaccount.com` có role `Compute Admin`

---

### Bước 1 — Build GCP images với Packer + Ansible

Packer tạo VM tạm trên GCP, Ansible chạy playbook cài app, rồi đóng gói thành custom image.

```bash
cd infrastructure/packer

packer init frontend.pkr.hcl && packer build frontend.pkr.hcl
packer init backend.pkr.hcl  && packer build backend.pkr.hcl
```

Ansible thực hiện theo thứ tự trong mỗi playbook:

1. `docker_role` — Cài Docker CE + Docker Compose plugin
2. `frontend_role` / `backend_role` — Render config từ template J2, tạo thư mục `/opt/app`
3. `post_provisioning_role` — Thêm user `ubuntu` vào group `docker`

---

### Bước 2 — Tạo hạ tầng GCP với Terraform

```bash
cd infrastructure/terraform

terraform init
terraform plan
terraform apply --auto-approve
```

Tài nguyên được tạo:

- VPC `main-vpc`, subnet `192.168.1.0/24`
- Cloud Router (BGP ASN 65001), Cloud NAT
- VM frontend (public IP) + VM backend (static internal IP `192.168.1.100`)
- HA VPN Gateway (2 interfaces), 2 VPN tunnels, 2 BGP peers
- Firewall rules (SSH, HTTP, HTTPS, BGP port 179, on-prem traffic)

---

### Bước 3 — Cấu hình pfSense On-Premises

Sau khi `terraform apply` xong, lấy IP của 2 VPN interface từ Google Cloud Console.

**Cấu hình IPSec:**

| Thông số | Giá trị |
|---|---|
| IKE Version | IKEv2 |
| Pre-shared Key | Giá trị `vpn_shared_secret` trong tfvars |
| Local IP (pfSense) | CARP VIP `192.168.175.190` |
| Remote Gateway Tunnel 1 | IP interface 0 của GCP HA VPN |
| Remote Gateway Tunnel 2 | IP interface 1 của GCP HA VPN |
| Phase 2 Traffic Selector | `192.168.10.0/24` ↔ `192.168.1.0/24` |

**Cấu hình BGP:**

| Thông số | Giá trị |
|---|---|
| Local ASN | 65002 |
| Neighbor 1 | `169.254.128.41` (GCP tunnel 1) |
| Neighbor 2 | `169.254.151.181` (GCP tunnel 2) |
| Remote ASN | 65001 |
| Advertise | `192.168.10.0/24` |

---

### Bước 4 — Kiểm tra kết nối

```bash
# Ping PostgreSQL on-prem từ backend VM
ping 192.168.10.33

# Kiểm tra kết nối DB
psql -h 192.168.10.33 -p 5432 -U dev_user -d immutiblecloud

```

---

## 5.pfSense HA — CARP Failover
