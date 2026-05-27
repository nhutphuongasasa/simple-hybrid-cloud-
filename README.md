Hybrid Cloud Lab — GCP + On-Premises (VMware Workstation)

Lab triển khai hạ tầng hybrid cloud kết hợp Google Cloud Platform và môi trường On-Premises chạy trên VMware Workstation, kết nối qua HA VPN IPSec + BGP.

Mục tiêu

Xây dựng một hệ thống web app thực tế với:

- Frontend và Backend chạy trên GCP, đóng gói bằng Docker Compose, image được build sẵn qua Packer + Ansible
- Database (PostgreSQL) đặt on-premises, backend GCP kết nối về qua VPN tunnel
- HA VPN 2 tunnel + BGP đảm bảo kết nối không bị gián đoạn khi một tunnel lỗi
- pfSense HA (CARP) on-premises để VPN không có single point of failure

1.Kiến trúc


<img width="826" height="758" alt="image" src="https://github.com/user-attachments/assets/722333a4-0b43-4918-82cb-f22c200d0d3d" />

2.Cấu trúc thư mục

<img width="410" height="736" alt="image" src="https://github.com/user-attachments/assets/9da31abd-ae20-4d5f-8a84-c87eb4e64ba1" />


3.Hướng dẫn triển khai

Bước 1 — Build GCP images với Packer + Ansible

  Packer tạo VM tạm trên GCP, Ansible chạy playbook để cài đặt app, rồi đóng gói thành custom image.

    packer init frontend.pkr.hcl && packer build frontend.pkr.hcl   

    packer init backend.pkr.hcl  && packer build backend.pkr.hcl    

  Ansible thực hiện theo thứ tự trong mỗi playbook:

<img width="774" height="280" alt="image" src="https://github.com/user-attachments/assets/bdd7f703-2093-4783-b163-97667adba8b6" />


Nginx (port 80) làm reverse proxy:

    /api/* → Backend VM 192.168.1.100:3001 (qua internal VPC)

    / → Frontend container localhost:3000

    Backend kết nối PostgreSQL on-prem qua VPN:

    Host: 192.168.10.33, Port: 5432, DB: immutiblecloud

Bước 2 — Tạo hạ tầng GCP với Terraform

    terraform init

    terraform plan

    terraform apply --auto-approve

Bước 3 — Cấu hình pfSense On-Premises

    IPSec: IKEv2, pre-shared key khớp với vpn_shared_secret, bind vào CARP VIP 192.168.175.190

    Tạo 2 tunnel tương ứng với 2 interface của GCP HA VPN.

    Dam bao dien dung peer ip va local ip duoc GCP HA VPN cung cap 

    Dam bao thiet lap udng chi so phase 1 va phase 2 

4.Luồng traffic

<img width="721" height="191" alt="image" src="https://github.com/user-attachments/assets/4869fa49-b30a-4667-81a1-4a701331e05c" />

5.pfsense HA — CARP Failover

Node primary: <IP_PRIMARY> Master
Node Secondary: <IP_SECONDARY> Standby
CARP VIP: 192.168.175.190 VIP

6.pfsense HA - vpn

7. trien kahi logic web tren cloud

8. loi gap phai trong qua trinh trien khai 
