# Nmapalooza

![nmaplooza](/img/nmapalooza.png)


**Nmapalooza** is a Bash-based toolkit that automates a multi-stage network reconnaissance process using Nmap. It’s designed to quickly discover live hosts, scan ports, and detect services and versions, all while offering stealth options and decoy support for more evasive scanning.

---

## 🛠 Features

- **Network Discovery**

  - ICMP and multiple TCP/UDP probe scans to identify live hosts.
  
- **Port Scanning**

  - TCP SYN and UDP scans.
  - Adjustable speed and stealth levels.
  - Decoy IP support for evasion.

- **Version and Service Detection**

  - Identifies services, versions, products, and OS fingerprints.
  - Extracts banners with Nmap scripts.
  - Generates XML and HTML reports for easier analysis.

- **Automated Workflow**

  - `main.sh` orchestrates the entire scanning pipeline.

---

## 📂 Project Structure

```

nmapalooza/
├── scripts/
│   ├── main.sh
│   ├── network-scan.sh
│   ├── port-scan.sh
│   └── version-scan.sh
└── results/

```

- **scripts/** → All Bash scripts.
- **results/** → XML, HTML and text outputs for each scan.

---

## 🚀 How to Use

### Quick Start

Run the full pipeline:

```bash
./scripts/main.sh <network> [stealth|stealth_slow] [decoy_ip[,decoy_ip2,...]]
````

Example:

```bash
./scripts/main.sh 192.168.1.0/24 stealth 1.2.3.4,5.6.7.8
```

---

## ⚙️ Individual Scripts

### Network Discovery

Scans a network to identify live hosts.

```bash
./scripts/network-scan.sh <network>
```

**Output:**

* `results/<network>_<date>_live_hosts.txt`

---

### Port Scan

Scans discovered hosts for open TCP and UDP ports.

```bash
./scripts/port-scan.sh <hosts_file> [stealth|stealth_slow] [decoy_ip[,decoy_ip2,...]]
```

**Output:**

* `results/<network>_<date>_open_ports.txt`

---

### Version Scan

Performs version and service detection on discovered open ports.

```bash
./scripts/version-scan.sh <open_ports_file> [stealth|stealth_slow] [decoy_ip[,decoy_ip2,...]]
```

**Outputs:**

* XML files per host.
* HTML reports per host.
* Aggregated services list:

  * `results/<network>_<date>_services.txt`

---

## 🔍 Modes

* **Default (fastest):** T4 timing, no special stealth.
* **stealth:** Lower timing (T2), fixed source port 53 for evasion.
* **stealth\_slow:** Slowest (T1), minimal traffic footprint.
* **Decoys:** Add fake source IPs to mask scanning origin.

Example with decoys:

```bash
./scripts/main.sh 10.0.0.0/24 stealth_slow 8.8.8.8,1.1.1.1
```

---

## 📄 Dependencies

* [Nmap](https://nmap.org)
* [xmlstarlet](http://xmlstar.sourceforge.net/)
* [xsltproc](http://xmlsoft.org/XSLT/xsltproc.html)

Install them on Debian/Ubuntu:

```bash
sudo apt update
sudo apt install nmap xmlstarlet xsltproc
```

---

## 📝 Output Examples

* Live hosts list:

  ```
  192.168.1.10
  192.168.1.20
  ```

* Open ports list:

  ```
  192.168.1.10:22
  192.168.1.10:80
  ```

* Services list:

  ```
  192.168.1.10:22:ssh:OpenSSH:8.2p1::Linux:
  192.168.1.10:80:http:Apache:httpd:2.4.41:::
  ```

---

## 📢 Disclaimer

This tool is intended for **authorized security testing and learning purposes only**. Always ensure you have permission to scan networks and systems.

---

Happy scanning with Nmapalooza! 🎉


