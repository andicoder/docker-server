# Docker Server Stack

A comprehensive Docker Compose setup for self-hosted services including Nextcloud, Paperless-ngx, Bitwarden, Home Assistant, and more.

## 🚀 Services Included

### Core Infrastructure

- **Nginx Proxy** - Reverse proxy with automatic SSL certificate management
- **Let's Encrypt Companion** - Automatic SSL certificate generation and renewal
- **MariaDB** - Database server for various applications
- **Redis** - Caching and session storage

### File & Document Management

- **Nextcloud** - Self-hosted cloud storage and file sharing platform
- **Paperless-ngx** - Document management and archiving system
- **Gotenberg** - PDF conversion service for Paperless
- **Tika** - Content extraction service for Paperless

### Security & Privacy

- **Bitwarden** - Password manager and secure vault
- **AdGuard Home** - Network-wide ad blocking and DNS filtering

### Home Automation

- **Home Assistant** - Open-source home automation platform

## 📋 Prerequisites

- Docker and Docker Compose installed
- Domain names configured for your services
- Proper DNS setup pointing to your server
- Sufficient storage space (recommended: 100GB+)

## 🛠️ Installation

1. **Clone or download this repository**

   ```bash
   git clone <repository-url>
   cd docker-server
   ```

2. **Create environment variables**
   Create a `.env` file in the root directory with the following variables:

   ```bash
   # Database Configuration
   DB_ROOT_PASSWORD=your_secure_root_password
   DB_NAME=nextcloud
   DB_USERNAME=nextcloud_user
   DB_PASSWORD=your_secure_db_password

   # Nextcloud Configuration
   OC_DOMAIN=your-nextcloud-domain.com

   # Bitwarden Configuration
   BITWARDEN_DOMAIN=your-bitwarden-domain.com
   BITWARDEN_ADMIN_TOKEN=your_admin_token
   BITWARDEN_DATABASE_URL=mysql://bitwarden_user:your_bitwarden_db_password@mariadb-***REMOVED***:3306/bitwarden

   # Paperless Configuration
   PAPERLESS_DOMAIN=your-paperless-domain.com
   ```

3. **Create required directories**

   ```bash
   sudo mkdir -p /data/{nginx,nextcloud,mysql,bitwarden,paperless,homeassistant,adguard}
   sudo chown -R $USER:$USER /data
   ```

4. **Start the services**

   ```bash
   docker-compose up -d
   ```

## 🔧 Configuration

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

## 🌐 Accessing Services

Once the services are running, you can access them at:

- **Nextcloud**: `https://your-nextcloud-domain.com`
- **Bitwarden**: `https://your-bitwarden-domain.com`
- **Paperless**: `https://your-paperless-domain.com`
- **Home Assistant**: `http://your-server-ip:8123` *(Internal WireGuard network only)*
- **AdGuard Home**: `http://your-server-ip:3000` *(Internal WireGuard network only)*

## 📁 Data Persistence

All data is persisted in the `/data` directory:

- `/data/nextcloud` - Nextcloud files and configuration
- `/data/mysql` - MariaDB database files
- `/data/bitwarden` - Bitwarden data
- `/data/paperless` - Paperless documents and configuration
- `/data/homeassistant` - Home Assistant configuration
- `/data/adguard` - AdGuard Home configuration
- `/data/nginx` - Nginx configuration and SSL certificates

## 🔒 Security Considerations

1. **Change default passwords** for all services
2. **Use strong passwords** for database and admin accounts
3. **Keep your system updated** regularly
4. **Monitor logs** for any suspicious activity
5. **Backup your data** regularly
6. **Use firewall rules** to restrict access if needed
7. **Home Assistant and AdGuard Home are protected by UFW firewall** - only accessible from the internal WireGuard network

## 🚨 Important Notes

- The MariaDB service is configured to bind to a specific IP (10.7.0.1) - adjust this in the docker-compose.yml if needed
- AdGuard Home runs in host network mode for DNS functionality
- Home Assistant runs in host network mode for device discovery
- All services use automatic SSL certificate management via Let's Encrypt
- **Home Assistant and AdGuard Home are only accessible from the internal WireGuard network**, secured by UFW firewall rules

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
docker exec mariadb-***REMOVED***mysqldump -u root -p --all-databases > backup.sql

# Backup Nextcloud data
tar -czf nextcloud-backup.tar.gz /data/nextcloud

# Backup Paperless data
tar -czf paperless-backup.tar.gz /data/paperless
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