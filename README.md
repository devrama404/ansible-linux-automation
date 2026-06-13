# Linux Fleet Automation & Network Hardening

Repositori ini berisi kumpulan playbook Ansible, skrip otomatisasi, dan dokumentasi untuk melakukan *provisioning*, manajemen konfigurasi, dan *security hardening* pada armada server Linux (AWS EC2 Ubuntu 24.04).

Proyek ini dirancang untuk memastikan setiap server yang di-deploy memiliki standar keamanan dasar (CIS Compliance yang disederhanakan), paket esensial yang terinstal, dan sistem *backup* otomatis.

## 🏗 Arsitektur & Topologi

```text
Laptop / Ansible Controller
         |
         | (SSH)
      Internet
         |
---------------------------------
|               |               |
web1          web2             web3
AWS EC2       AWS EC2          AWS EC2
Ubuntu        Ubuntu           Ubuntu
Public IP     Public IP        Public IP

```

## 📂 Struktur Repositori

```text
linux-fleet-automation/
│
├── README.md                 # Dokumentasi utama
├── inventory/                
│   ├── inventory.ini         # Static inventory untuk server spesifik
│   └── aws_ec2.yml           # Dynamic inventory AWS berdasarkan Tag (Role=webserver)
├── playbooks/
│   ├── site.yml              # Playbook untuk instalasi paket dasar & web server
│   ├── hardening.yml         # Playbook untuk implementasi standar keamanan
│   └── backup.yml            # (Opsional) Playbook untuk manajemen backup
├── scripts/
│   ├── audit.sh              # Skrip bash untuk audit sistem dan port
│   └── backup.sh             # Skrip bash otomatisasi backup direktori konfigurasi
├── docs/                     
│   ├── security-audit-report.md # Laporan hasil audit keamanan
│   ├── backup-report.md      # Laporan jadwal dan status backup
│   └── topology.png          # Gambar topologi jaringan
└── ansible.cfg               # Konfigurasi default Ansible

```

## ✨ Fitur Utama

1. **Base Provisioning (`site.yml`)**: Menginstal paket-paket penting seperti `nginx`, `git`, `htop`, `fail2ban`, `ufw`, `curl`, dan `unzip`.
2. **Security Hardening (`hardening.yml`)**:
* Menonaktifkan akses login *root* via SSH.
* Menonaktifkan otentikasi berbasis *password* (hanya menggunakan SSH Key).
* Mengonfigurasi UFW Firewall (Hanya mengizinkan port 22, 80, dan 443).
* Mengaktifkan `fail2ban` untuk mencegah serangan *brute-force*.


3. **AWS Dynamic Inventory (`aws_ec2.yml`)**: Kemampuan membaca *instance* EC2 secara dinamis berdasarkan tag `Role: webserver`.
4. **Automation Scripts**: Skrip bash bawaan untuk melakukan audit sistem secara cepat (`audit.sh`) dan *backup* harian menggunakan Cron (`backup.sh`).

## 🚀 Panduan Penggunaan

### 1. Prasyarat

* Ansible terinstal di *Controller Machine*.
* Akses SSH Key (`.pem`) ke semua *instance* EC2.
* (Opsional) Boto3 dan kredensial AWS CLI terkonfigurasi jika ingin menggunakan *Dynamic Inventory*.

### 2. Uji Koneksi (Ping Test)

Pastikan Ansible dapat berkomunikasi dengan seluruh *node*:

```bash
ansible all -i inventory/inventory.ini -m ping

```

### 3. Menjalankan Base Setup

Untuk menginstal *web server* dan utilitas dasar pada semua server:

```bash
ansible-playbook -i inventory/inventory.ini playbooks/site.yml

```

*Verifikasi instalasi Nginx:*

```bash
ansible all -i inventory/inventory.ini -m shell -a "systemctl status nginx --no-pager"

```

### 4. Menjalankan Security Hardening

Untuk mengamankan SSH dan mengaktifkan Firewall:

```bash
ansible-playbook -i inventory/inventory.ini playbooks/hardening.yml

```

*Verifikasi Firewall & Fail2ban:*

```bash
ansible all -i inventory/inventory.ini -b -m shell -a "ufw status"
ansible all -i inventory/inventory.ini -m shell -a "systemctl status fail2ban --no-pager"

```

### 5. Menggunakan AWS Dynamic Inventory

Pastikan *instance* AWS EC2 Anda memiliki tag `Role: webserver`.

```bash
ansible-inventory -i inventory/aws_ec2.yml --graph

```

## 🛠 Penggunaan Skrip Bawaan

### System Audit (`audit.sh`)

Skrip ini akan menampilkan Hostname, versi OS, Uptime, Open Ports, status Firewall, Disk Space, dan status Fail2ban.

```bash
cd scripts/
chmod +x audit.sh
./audit.sh

```

### Auto Backup (`backup.sh`)

Skrip ini membuat *archive* dari direktori `/etc` dengan format tanggal untuk memudahkan *rollback* konfigurasi.

```bash
cd scripts/
chmod +x backup.sh
sudo ./backup.sh

```

**Konfigurasi Cron Job (Harian pukul 01:00 AM):**

```bash
crontab -e
# Tambahkan baris berikut:
0 1 * * * /path/to/scripts/backup.sh

```

---
