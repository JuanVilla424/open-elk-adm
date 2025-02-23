# 🛰️ ELK Stack with Docker

![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=fff)
![Elasticsearch](https://img.shields.io/badge/Elasticsearch-005571?logo=elasticsearch&logoColor=fff)
![Logstash](https://img.shields.io/badge/Logstash-005571?logo=logstash&logoColor=fff)
![Kibana](https://img.shields.io/badge/Kibana-005571?logo=kibana&logoColor=fff)
![Status](https://img.shields.io/badge/Status-Development-blue.svg)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.en.html)

Welcome to the **ELK Stack with Docker** repository! This project provides a **Docker Compose** setup for deploying an **ELK Stack** (Elasticsearch, Logstash, Kibana) for centralized logging and data visualization. It is designed to be easy to set up and use for development, testing, and production environments.

<img src="https://imgs.search.brave.com/CsZXpPEgnW3zqi0ON_AeDAxrk0HvIc8UhMyl2DJnlI4/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9zdGF0/aWMtMDAuaWNvbmR1/Y2suY29tL2Fzc2V0/cy4wMC9lbGFzdGlj/c2VhcmNoLWljb24t/MjMweDI1Ni0weTVs/dTFtei5wbmc" width="112" alt="ELK Stack">

## 📚 Table of Contents

- [Features](#-features)
- [Getting Started](#-getting-started)
  - [Prerequisites](#-prerequisites)
  - [Installation](#-installation)
- [Usage](#-usage)
- [Contributing](#-contributing)
- [License](#-license)
- [Contact](#-contact)

## 🌟 Features

- **Elasticsearch**: Distributed search and analytics engine.
- **Logstash**: Data processing pipeline for ingesting and transforming logs.
- **Kibana**: Visualization and exploration tool for Elasticsearch data.
- **Docker Compose**: Easy deployment and management of the ELK Stack.
- **Pre-configured Setup**: Ready-to-use configuration files for quick setup.

## 🚀 Getting Started

### 📋 Prerequisites

**Before you begin, ensure you have met the following requirements**:

- **Docker**: Install [Docker](https://docs.docker.com/get-docker/).
- **Docker Compose**: Install [Docker Compose](https://docs.docker.com/compose/install/).

### 🔨 Installation

1. **Clone the Repository**

   ```bash
   git clone https://github.com/JuanVilla424/elk-adm.git
   cd elk-adm
   ```

2. **Set Up Environment Variables**

   - Rename the `.env.example` file to `.env`:
     ```bash
     cp .env.example .env
     ```
   - Open the `.env` file and configure the environment variables as needed.

3. **Set Security Values**

   ```bash
   python scripts/init_security_config/main.py --files=.env
   ```

4. **Start the ELK Stack**

   ```bash
   sudo sh bin/install.sh
   ```

   This will start Elasticsearch, Logstash, and Kibana in detached mode.

5. **Access Kibana**

   Open your browser and navigate to [http://localhost:5601](http://localhost:5601) to access Kibana.

## 🛠️ Usage

### View Logs in Kibana

1. Open Kibana at [http://localhost:5601](http://localhost:5601).
2. Navigate to **Discover** to view and search logs ingested by Logstash.

### Stop the ELK Stack

To stop the ELK Stack, run:

```bash
docker-compose down
```

### Uninstall the ELK Stack

To **uninstall** the ELK Stack, run:

```bash
sudo sh bin/uninstall.sh
```

### Customize Configuration

You can customize the configuration files for Elasticsearch, Logstash, and Kibana located in the `config/` directory.

## 🤝 Contributing

**Contributions are welcome! To contribute to this repository, please follow these steps**:

1. **Fork the Repository**

2. **Create a Feature Branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Commit Your Changes**

   ```bash
   git commit -m "feat(<scope>): your feature commit message - lower case"
   ```

4. **Push to the Branch**

   ```bash
   git push origin feature/your-feature-name
   ```

5. **Open a Pull Request into** `dev` **branch**

Please ensure your contributions adhere to the Code of Conduct and Contribution Guidelines.

## 📫 Contact

For any inquiries or support, please open an issue or contact [r6ty5r296it6tl4eg5m.constant214@passinbox.com](mailto:r6ty5r296it6tl4eg5m.constant214@passinbox.com).

---

## 📜 License

2025 - This project is licensed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html). You are free to use, modify, and distribute this software under the terms of the GPL-3.0 license. For more details, please refer to the [LICENSE](LICENSE) file included in this repository.
