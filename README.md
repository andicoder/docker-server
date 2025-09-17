# Docker Server Stack

A comprehensive Docker Compose setup for self-hosted services including Nextcloud, Paperless-ngx, Bitwarden, Home Assistant, Teslamate, and more.

## 🚀 Services Included

### Core Infrastructure

- **Nginx Proxy** - Reverse proxy with automatic SSL certificate management
- **Let's Encrypt Companion** - Automatic SSL certificate generation and renewal
- **MariaDB** - Database server for various applications
- **Redis** - Caching and session storage
 - **PostgreSQL** - Database server for Teslamate

### File & Document Management

- **Nextcloud** - Self-hosted cloud storage and file sharing platform
- **Paperless-ngx** - Document management and archiving system
- **Gotenberg** - PDF conversion service for Paperless
- **Tika** - Content extraction service for Paperless

### Security & Privacy

- **Bitwarden** - Password manager and secure vault

### Home Automation

- **Home Assistant** - Open-source home automation platform

### Vehicle Telemetry

- **Teslamate** - Data logger and visualizer for Tesla vehicles
- **Grafana (Teslamate)** - Prebuilt dashboards for Teslamate

## 📋 Prerequisites

- Docker and Docker Compose installed
- Domain names configured for your services
- Proper DNS setup pointing to your server
- Sufficient storage space (recommended: 100GB+)
 - Optional: MQTT broker available for Teslamate integrations

## 🛠️ Installation

1. **Clone or download this repository**

   ```bash
   git clone <repository-url>
   cd docker-server
   ```

2. **Create environment variables**
   Copy the template and create a `.env` file in the root directory:
   ```bash
   cp env.template .env
   ```
   Then edit the `.env` file with your values. The template includes all necessary variables:

   ```bash
   # Database Configuration
   DB_ROOT_PASSWORD=your_secure_root_password_here
   DB_NAME=nextcloud
   DB_USERNAME=nextcloud_user
   DB_PASSWORD=your_secure_db_password_here

   # Service Domains
   OC_DOMAIN=your-nextcloud-domain.com
   BITWARDEN_DOMAIN=your-bitwarden-domain.com
   PAPERLESS_DOMAIN=your-paperless-domain.com

   # Bitwarden Configuration
   BITWARDEN_ADMIN_TOKEN=your_admin_token_here
   BITWARDEN_DATABASE_URL=mysql://bitwarden_user:your_bitwarden_db_password@mariadb:3306/bitwarden

   # Paperless Database Configuration
   PAPERLESS_DBUSER=paperless
   PAPERLESS_DBPASS=your_paperless_db_password_here
   PAPERLESS_DBPORT=3306

   # Paperless Advanced Configuration
   USERMAP_UID=1003
   USERMAP_GID=1003
   PAPERLESS_OCR_LANGUAGES=deu
   PAPERLESS_OCR_LANGUAGE=deu
   PAPERLESS_TIME_ZONE=Europe/Berlin
   PAPERLESS_SECRET_KEY=your_very_long_random_secret_key_here
   PAPERLESS_CONSUMER_ASN_BARCODE_PREFIX=ASN
   PAPERLESS_CONSUMER_ENABLE_ASN_BARCODE=true
   PAPERLESS_CONSUMER_ENABLE_BARCODES=true
   PAPERLESS_CONSUMER_BARCODE_SCANNER=ZXING

   # Teslamate Configuration
   TESLAMATE_ENCRYPTION_KEY=your_key
   TESLAMATE_DATABASE_PASS=your_teslamate_db_password_here
   MQTT_HOST=
   MQTT_USERNAME=
   MQTT_PASSWORD=

   # Host Configuration
   # IP address of the host to bind Teslamate and Grafana to (LAN IP)
   HOST_IP=192.168.1.100

   # Admin Configuration
   ADMIN_EMAIL=admin@your-domain.com
   ```

3. **Create base data directory**

   ```bash
   sudo mkdir -p /data
   sudo chown -R $USER:$USER /data
   ```

   Docker will create all required service subdirectories on first run.

4. **Start the services**

   ```bash
   docker-compose up -d
   ```

## 🔧 Configuration

### Environment Variables
The project includes an `env.template` file with all necessary environment variables. This template:
- Contains all required variables for all services (Nextcloud, Bitwarden, Paperless-ngx, Home Assistant, Teslamate)
- Includes security best practices (placeholder passwords)
- Provides German language support for Paperless
- Includes Paperless OCR and consumer settings
- Has proper UID/GID mapping for file permissions
- Includes Teslamate settings (encryption key, PostgreSQL password, optional MQTT)

### MariaDB Configuration

The MariaDB service uses a custom configuration file located in `mariadb-config/my.cnf` with optimized settings for:

- InnoDB buffer pool size: 4GB
- InnoDB log file size: 512MB
- Optimized for performance and reliability

### Nextcloud Configuration

- Uses PHP-FPM with Nginx
- Redis caching enabled
- Custom Nginx configuration for optimal performance
- Automatic SSL certificate management

### Paperless-ngx Configuration

- German language support for OCR
- Custom timezone (Europe/Berlin)
- Integration with Gotenberg for PDF conversion
- Tika for content extraction

### Teslamate Configuration

- Uses a dedicated PostgreSQL database
- Exposes the Teslamate web UI on port 4000 (bound to host IP)
- Grafana dashboards available on port 4001
- Optional MQTT integration via environment variables

## 🌐 Accessing Services

Once the services are running, you can access them at:

- **Nextcloud**: `https://your-nextcloud-domain.com`
- **Bitwarden**: `https://your-bitwarden-domain.com`
- **Paperless**: `https://your-paperless-domain.com`
- **Home Assistant**: `http://${HOST_IP}:8123`
- **Teslamate**: `http://${HOST_IP}:4000`
- **Grafana (Teslamate)**: `http://${HOST_IP}:4001`

## 📁 Data Persistence

All data is persisted in the `/data` directory or named volumes:

- `/data/nextcloud` - Nextcloud files and configuration
- `/data/mysql` - MariaDB database files
- `/data/bitwarden` - Bitwarden data
- `/data/paperless` - Paperless documents and configuration
- `/data/homeassistant` - Home Assistant configuration
- `/data/nginx` - Nginx configuration and SSL certificates
 - `/data/teslamate` - Teslamate import folder
 - `/data/teslamate-postgres` - Teslamate PostgreSQL data
 - `teslamate-grafana-data` (Docker named volume) - Grafana data

## 🔒 Security Considerations

1. **Change default passwords** for all services
2. **Use strong passwords** for database and admin accounts
3. **Keep your system updated** regularly
4. **Monitor logs** for any suspicious activity
5. **Backup your data** regularly
6. **Use firewall rules** to restrict access if needed
7. **Expose only required ports on your host** (Teslamate 4000, Grafana 4001, Home Assistant 8123) and secure access as needed

## 🚨 Important Notes

- Home Assistant runs in host network mode for device discovery
- All services use automatic SSL certificate management via Let's Encrypt
- The nginx proxy auto-discovers containers via Docker labels/environment and terminates TLS
- Teslamate and Grafana are bound to the host IP on ports 4000 and 4001 by default

## 🔄 Maintenance

### Updating Services

```bash
# Pull latest images
docker-compose pull

# Restart services
docker-compose up -d
```

### Backup Strategy

```bash
# Backup MariaDB
docker exec mariadb mysqldump -u root -p --all-databases > backup.sql

# Backup Nextcloud data
tar -czf nextcloud-backup.tar.gz /data/nextcloud

# Backup Paperless data
tar -czf paperless-backup.tar.gz /data/paperless

# Backup Bitwarden data
tar -czf bitwarden-backup.tar.gz /data/bitwarden
```

### Logs

```bash
# View all logs
docker-compose logs

# View specific service logs
docker-compose logs nextcloud-app
docker-compose logs paperless
```

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## ⚠️ Disclaimer

This setup is for personal use. Please ensure you comply with all applicable laws and regulations when hosting these services. 