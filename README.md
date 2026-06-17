# 🐧 Linux Fleet Automation & Network Hardening

Proyek ini adalah implementasi **Infrastructure as Code (IaC)** dan **Configuration Management** menggunakan Ansible untuk mengelola, mengonfigurasi, dan mengamankan (hardening) armada server Linux di lingkungan AWS EC2.

---

## 🏗 Arsitektur Sistem

Topologi ini terdiri dari sebuah Ansible Controller (Laptop/Lokal) yang mengelola 3 instance AWS EC2 (Ubuntu 24.04) melalui koneksi SSH yang aman.

```text
 Laptop / Ansible Controller
         |
         | Internet (SSH)
         |
-------------------------------------------------
|               |               |               |
+---------------+---------------+---------------+
|    web1       |    web2       |    web3       |
|   AWS EC2     |   AWS EC2     |   AWS EC2     |
| Ubuntu 24.04  | Ubuntu 24.04  | Ubuntu 24.04  |
|  Public IP    |  Public IP    |  Public IP    |
+---------------+---------------+---------------+

```

---

## 📂 Struktur Repositori

Berdasarkan repositori ini, berikut adalah susunan file dan fungsinya:

```text
linux-fleet-automation/
│
├── scripts/
│   ├── audit.sh            # Skrip bash untuk audit sistem & keamanan
│   └── backup.sh           # Skrip bash untuk backup direktori krusial
│
├── README.md               # Dokumentasi proyek
├── ec2.yml                 # AWS Dynamic Inventory
├── hardening.yml           # Playbook untuk keamanan (SSH, UFW, Fail2ban)
├── inventory.ini           # Static inventory untuk daftar IP server
└── site.yml                # Playbook untuk instalasi paket dasar

```

---

## 🚀 Panduan Instalasi & Penggunaan

### 1. Persiapan Infrastruktur (AWS EC2)

Pastikan Anda memiliki 3 instance EC2 dengan spesifikasi berikut:

* **OS:** Ubuntu 24.04 LTS
* **Type:** `t3.micro`
* **Security Group (Inbound):** `22/tcp` (SSH), `80/tcp` (HTTP), `443/tcp` (HTTPS)
* **Tag (Untuk Dynamic Inventory):** `Role=webserver`

### 2. Setup Static Inventory

Edit file `inventory.ini` dan sesuaikan IP Public serta lokasi *private key* (PEM) Anda:

```ini
[webservers]
server-web1 ansible_host=108.136.40.150 ansible_user=ubuntu ansible_ssh_private_key_file=/path/to/server-web1.pem
server-web2 ansible_host=108.136.249.240 ansible_user=ubuntu ansible_ssh_private_key_file=/path/to/server-web2.pem
server-web3 ansible_host=108.136.44.234 ansible_user=ubuntu ansible_ssh_private_key_file=/path/to/server-web3.pem

```

Uji koneksi ke seluruh armada server:

```bash
ansible all -i inventory.ini -m ping

```

---

## 🛠 Eksekusi Playbook

### 1. Base Setup (`site.yml`)

Playbook ini akan melakukan pembaruan repositori APT dan menginstal paket penting seperti Nginx, Git, Htop, UFW, dan Fail2ban.

```bash
ansible-playbook -i inventory.ini site.yml
```
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ymuo3t26hzlbtak4tbq6.png)

*Verifikasi:* `ansible all -i inventory.ini -m shell -a "systemctl status nginx --no-pager"`

### 2. Server Hardening (`hardening.yml`)

Playbook ini mengunci server dengan menonaktifkan login Root, mematikan autentikasi *password*, mengaktifkan Firewall (UFW), dan menjalankan Fail2ban.

```bash
ansible-playbook -i inventory.ini hardening.yml

```
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/zfm6gb0cc46wpgo5icyb.png)

*Verifikasi:* * Cek UFW: `ansible all -i inventory.ini -b -m shell -a "ufw status"`

* Cek SSH: `ansible all -i inventory.ini -m shell -a "grep PermitRootLogin /etc/ssh/sshd_config"`

---

## ☁️ AWS Dynamic Inventory (Opsional)

Jika Anda sering menambah/menghapus server, gunakan AWS Dynamic Inventory agar Ansible mendeteksi server secara otomatis berdasarkan Tag yang ada di file `ec2.yml`.

Uji *dynamic inventory* (pastikan kredensial AWS CLI sudah diatur):

```bash
ansible-inventory -i ec2.yml --graph

```

---

## 🛡️ Otomatisasi Skrip (Bash)

Di dalam folder `scripts/`, terdapat dua skrip utama yang bisa dijalankan secara manual maupun otomatis:

### 1. Skrip Audit (`audit.sh`)

Digunakan untuk mengekstrak informasi sistem, *uptime*, port yang terbuka, status *firewall*, dan kapasitas disk secara cepat.

```bash
chmod +x scripts/audit.sh
./scripts/audit.sh

```

### 2. Skrip Backup (`backup.sh`)

Melakukan arsip direktori konfigurasi krusial (`/etc`) dengan format `tar.gz` berdasarkan tanggal.

Menambahkan Cronjob untuk *backup* setiap hari pukul 01:00 AM:

```bash
crontab -e
# Tambahkan baris berikut:
0 1 * * * /path/to/scripts/backup.sh

```

```

```
