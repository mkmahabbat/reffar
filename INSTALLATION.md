# MK BOT - Installation Guide

This guide will help you install and deploy the MK BOT Telegram referral system.

## Quick Start

1. **Extract the project files**
2. **Configure environment variables**
3. **Run the deployment script**

```bash
# Make deployment script executable
chmod +x deploy.sh

# Run deployment script
./deploy.sh
```

## Manual Installation

### Prerequisites

- **Node.js** (v14 or higher)
- **MongoDB** (v4.4 or higher)
- **npm** (comes with Node.js)

### Step 1: Install Node.js

#### Ubuntu/Debian:
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

#### CentOS/RHEL:
```bash
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs
```

#### Windows:
Download and install from [nodejs.org](https://nodejs.org/)

#### macOS:
```bash
# Using Homebrew
brew install node

# Or download from nodejs.org
```

### Step 2: Install MongoDB

#### Ubuntu/Debian:
```bash
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod
```

#### CentOS/RHEL:
```bash
# Create repository file
sudo tee /etc/yum.repos.d/mongodb-org-6.0.repo << EOF
[mongodb-org-6.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/6.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc
EOF

sudo yum install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod
```

#### Windows:
Download and install from [mongodb.com](https://www.mongodb.com/try/download/community)

#### macOS:
```bash
# Using Homebrew
brew tap mongodb/brew
brew install mongodb-community
brew services start mongodb/brew/mongodb-community
```

#### MongoDB Atlas (Cloud):
1. Create account at [cloud.mongodb.com](https://cloud.mongodb.com)
2. Create a cluster
3. Get connection string
4. Update `MONGODB_URI` in `.env`

### Step 3: Configure Environment

1. **Copy environment file:**
```bash
cp .env.example .env  # If .env.example exists
# Or edit the existing .env file
```

2. **Edit `.env` file:**
```bash
nano .env
```

3. **Configure the following variables:**

```env
# Telegram Bot Configuration
BOT_TOKEN=your_bot_token_here
CHANNEL_USERNAME=@YourChannelUsername
CHANNEL_LINK=https://t.me/YourChannelLink

# Database Configuration
MONGODB_URI=mongodb://localhost:27017/telegram-referral-bot

# Server Configuration
PORT=3000
ADMIN_PORT=3001

# Admin Credentials
ADMIN_USERNAME=your_admin_username
ADMIN_PASSWORD=your_admin_password

# JWT Secret (change this!)
JWT_SECRET=your-super-secret-jwt-key-here

# Referral Settings
REFERRAL_AMOUNT=5
MIN_WITHDRAWAL=100
```

### Step 4: Install Dependencies

```bash
npm install
```

### Step 5: Start the Application

#### Option 1: Using PM2 (Recommended for Production)

```bash
# Install PM2 globally
npm install -g pm2

# Start with ecosystem file
pm2 start ecosystem.config.js

# Save PM2 configuration
pm2 save

# Setup auto-start on boot
pm2 startup
```

#### Option 2: Using Docker

```bash
# Build and start containers
docker-compose up -d --build

# View logs
docker-compose logs -f

# Stop containers
docker-compose down
```

#### Option 3: Manual Start

```bash
# Start both bot and admin server
npm start

# Or start individually
npm run bot    # Start only the bot
npm run admin  # Start only the admin server
```

## Telegram Bot Setup

### 1. Create Bot

1. Message [@BotFather](https://t.me/BotFather) on Telegram
2. Send `/newbot`
3. Choose bot name: `MK BOT`
4. Choose username: `Mk_Kombat_bot` (or your preferred username)
5. Copy the bot token

### 2. Configure Bot Commands (Optional)

Send to @BotFather:
```
/setcommands

start - Start the bot and get referral link
```

### 3. Setup Channel

1. Create a Telegram channel
2. Add your bot as administrator
3. Get channel username (e.g., @MKClubOfficial)
4. Update `CHANNEL_USERNAME` and `CHANNEL_LINK` in `.env`

## cPanel Deployment

### 1. Prepare Files

```bash
# Create deployment package
zip -r mk-bot-deployment.zip . -x "node_modules/*" "logs/*" ".git/*"
```

### 2. Upload to cPanel

1. Login to cPanel
2. Go to File Manager
3. Navigate to `public_html` or subdirectory
4. Upload and extract the zip file

### 3. Install Dependencies

In cPanel Terminal or SSH:
```bash
cd /path/to/your/project
npm install --production
```

### 4. Configure Environment

```bash
# Edit environment file
nano .env

# Update with production settings
```

### 5. Start Application

```bash
# Using PM2 (if available)
npm install -g pm2
pm2 start ecosystem.config.js

# Or using nohup
nohup npm start > app.log 2>&1 &
```

### 6. Setup Domain

1. Create subdomain in cPanel
2. Point to project directory
3. Configure SSL certificate

## VPS/Cloud Deployment

### 1. Server Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install MongoDB
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod

# Install PM2
sudo npm install -g pm2
```

### 2. Deploy Application

```bash
# Upload project files
scp -r mk-bot-deployment.zip user@your-server:/var/www/
ssh user@your-server

# Extract and setup
cd /var/www
unzip mk-bot-deployment.zip
cd telegram-referral-bot

# Install dependencies
npm install --production

# Configure environment
nano .env

# Start with PM2
pm2 start ecosystem.config.js
pm2 startup
pm2 save
```

### 3. Setup Nginx (Optional)

```bash
# Install Nginx
sudo apt install nginx

# Create configuration
sudo nano /etc/nginx/sites-available/mkbot
```

Nginx configuration:
```nginx
server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/mkbot /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Setup SSL with Let's Encrypt
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com
```

## Monitoring and Maintenance

### PM2 Commands

```bash
# View status
pm2 status

# View logs
pm2 logs

# Restart applications
pm2 restart all

# Stop applications
pm2 stop all

# Monitor resources
pm2 monit

# Update PM2
npm install -g pm2@latest
pm2 update
```

### Docker Commands

```bash
# View containers
docker-compose ps

# View logs
docker-compose logs -f

# Restart services
docker-compose restart

# Update containers
docker-compose pull
docker-compose up -d --build

# Cleanup
docker-compose down
docker system prune -f
```

### Database Backup

```bash
# MongoDB backup
mongodump --uri="mongodb://localhost:27017/telegram-referral-bot" --out=backup/

# Restore
mongorestore --uri="mongodb://localhost:27017/telegram-referral-bot" backup/telegram-referral-bot/
```

## Troubleshooting

### Common Issues

1. **Port already in use:**
```bash
# Find process using port
sudo lsof -i :3001
# Kill process
sudo kill -9 <PID>
```

2. **MongoDB connection failed:**
```bash
# Check MongoDB status
sudo systemctl status mongod
# Restart MongoDB
sudo systemctl restart mongod
```

3. **Bot not responding:**
- Check bot token
- Verify bot is started
- Check logs for errors

4. **Permission denied:**
```bash
# Fix permissions
sudo chown -R $USER:$USER /path/to/project
chmod +x deploy.sh
```

### Log Files

- **PM2 logs:** `~/.pm2/logs/`
- **Application logs:** `./logs/`
- **MongoDB logs:** `/var/log/mongodb/mongod.log`

### Reset Admin Password

```bash
# Connect to MongoDB
mongosh telegram-referral-bot

# Update admin password (replace with bcrypt hash)
db.admins.updateOne(
  { username: "mkmahabbat" },
  { $set: { password: "$2a$10$newhashedpassword" } }
)
```

## Security Considerations

1. **Change default credentials**
2. **Use strong JWT secret**
3. **Enable MongoDB authentication**
4. **Setup firewall rules**
5. **Use HTTPS in production**
6. **Regular security updates**

## Support

For issues and support:
1. Check logs for error messages
2. Verify environment configuration
3. Ensure all services are running
4. Check network connectivity

## License

This project is licensed under the ISC License.

