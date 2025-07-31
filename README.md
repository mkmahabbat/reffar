# MK BOT - Telegram Referral Bot System

A complete Telegram referral bot system with admin panel for managing users, referrals, and withdrawals.

## Features

✅ **Telegram Bot Features:**
- Channel subscription verification
- Unique referral link generation
- ₹5 per successful referral
- Wallet system with ₹100 minimum withdrawal
- UPI ID setup for payouts
- User-friendly interface with menu buttons

✅ **Admin Panel Features:**
- Secure admin authentication
- Real-time statistics dashboard
- User management and search
- Withdrawal request approval/rejection
- Manual balance adjustments
- Responsive design with TailwindCSS

✅ **Technical Features:**
- MongoDB database with proper indexing
- Session-based authentication
- RESTful API endpoints
- Error handling and logging
- Graceful shutdown handling
- Auto-restart on failures

## Prerequisites

- Node.js (v14 or higher)
- MongoDB (local or cloud)
- Telegram Bot Token
- Telegram Channel

## Installation

### 1. Clone or Extract Project
```bash
# If you have the zip file, extract it
unzip telegram-referral-bot.zip
cd telegram-referral-bot

# Or clone from repository
git clone <repository-url>
cd telegram-referral-bot
```

### 2. Install Dependencies
```bash
npm install
```

### 3. Configure Environment
Edit the `.env` file with your settings:

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

### 4. Setup MongoDB

**Option A: Local MongoDB**
```bash
# Install MongoDB on Ubuntu/Debian
sudo apt update
sudo apt install mongodb

# Start MongoDB service
sudo systemctl start mongodb
sudo systemctl enable mongodb
```

**Option B: MongoDB Atlas (Cloud)**
1. Create account at https://cloud.mongodb.com
2. Create a cluster
3. Get connection string
4. Update `MONGODB_URI` in `.env`

### 5. Setup Telegram Bot

1. **Create Bot:**
   - Message @BotFather on Telegram
   - Send `/newbot`
   - Choose bot name and username
   - Copy the bot token

2. **Configure Bot:**
   - Update `BOT_TOKEN` in `.env`
   - Set bot commands (optional):
     ```
     /setcommands
     start - Start the bot
     ```

3. **Setup Channel:**
   - Create a Telegram channel
   - Add your bot as admin
   - Update `CHANNEL_USERNAME` and `CHANNEL_LINK` in `.env`

## Running the Application

### Development Mode
```bash
# Start both bot and admin server
npm start

# Or start individually
npm run bot    # Start only the bot
npm run admin  # Start only the admin server
```

### Production Mode
```bash
# Using PM2 (recommended)
npm install -g pm2
pm2 start index.js --name "mk-bot"
pm2 startup
pm2 save

# Or using nohup
nohup npm start > app.log 2>&1 &
```

## Deployment

### cPanel Deployment

1. **Upload Files:**
   - Zip the project folder
   - Upload to cPanel File Manager
   - Extract in public_html or subdirectory

2. **Install Dependencies:**
   ```bash
   # In cPanel Terminal or SSH
   cd /path/to/your/project
   npm install --production
   ```

3. **Configure Environment:**
   - Update `.env` with production settings
   - Use MongoDB Atlas for database

4. **Start Application:**
   ```bash
   # Using PM2 (if available)
   pm2 start index.js --name "mk-bot"
   
   # Or using nohup
   nohup node index.js > app.log 2>&1 &
   ```

5. **Setup Domain/Subdomain:**
   - Point domain to your project directory
   - Configure SSL certificate

### VPS/Cloud Deployment

1. **Server Setup:**
   ```bash
   # Update system
   sudo apt update && sudo apt upgrade -y
   
   # Install Node.js
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   sudo apt-get install -y nodejs
   
   # Install MongoDB
   sudo apt install mongodb
   
   # Install PM2
   sudo npm install -g pm2
   ```

2. **Deploy Application:**
   ```bash
   # Upload and extract project
   cd /var/www
   sudo git clone <your-repo> mk-bot
   cd mk-bot
   
   # Install dependencies
   sudo npm install --production
   
   # Configure environment
   sudo nano .env
   
   # Start with PM2
   sudo pm2 start index.js --name "mk-bot"
   sudo pm2 startup
   sudo pm2 save
   ```

3. **Setup Nginx (optional):**
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
           proxy_cache_bypass $http_upgrade;
       }
   }
   ```

## Usage

### For Users
1. Start the bot: `/start`
2. Join the required channel
3. Get referral link and share with friends
4. Set UPI ID for withdrawals
5. Request withdrawal when balance ≥ ₹100

### For Admins
1. Access admin panel: `http://your-domain:3001`
2. Login with admin credentials
3. Monitor statistics and users
4. Approve/reject withdrawal requests
5. Manage user balances

## API Endpoints

### Authentication
- `POST /api/admin/login` - Admin login
- `POST /api/admin/logout` - Admin logout
- `GET /api/admin/check-auth` - Check authentication

### Statistics
- `GET /api/admin/stats` - Get system statistics

### User Management
- `GET /api/admin/users` - Get all users
- `GET /api/admin/users/recent` - Get recent users
- `GET /api/admin/users/:id` - Get specific user
- `PUT /api/admin/users/:id/balance` - Update user balance

### Withdrawals
- `GET /api/admin/withdrawals` - Get withdrawal requests
- `PUT /api/admin/withdrawals/:id/approve` - Approve withdrawal
- `PUT /api/admin/withdrawals/:id/reject` - Reject withdrawal

## Database Schema

### User Model
```javascript
{
  telegramId: Number,
  username: String,
  firstName: String,
  lastName: String,
  referralCode: String,
  referredBy: Number,
  referredUsers: [Number],
  walletBalance: Number,
  upiId: String,
  isActive: Boolean,
  joinedAt: Date,
  withdrawalRequests: [WithdrawalRequest]
}
```

### Withdrawal Request
```javascript
{
  amount: Number,
  upiId: String,
  requestedAt: Date,
  status: String, // 'pending', 'approved', 'rejected'
  processedAt: Date,
  processedBy: String,
  notes: String
}
```

## Security Features

- Session-based authentication
- Password hashing with bcrypt
- Rate limiting on login attempts
- Account lockout after failed attempts
- CORS protection
- Input validation and sanitization

## Monitoring and Logs

### View Logs
```bash
# PM2 logs
pm2 logs mk-bot

# Application logs
tail -f app.log

# MongoDB logs
sudo tail -f /var/log/mongodb/mongod.log
```

### Monitor Performance
```bash
# PM2 monitoring
pm2 monit

# System resources
htop
```

## Troubleshooting

### Common Issues

1. **Bot not responding:**
   - Check bot token
   - Verify bot is started
   - Check MongoDB connection

2. **Channel verification failing:**
   - Ensure bot is admin in channel
   - Check channel username format
   - Verify channel is public

3. **Admin panel not loading:**
   - Check admin server is running
   - Verify port is not blocked
   - Check browser console for errors

4. **Database connection issues:**
   - Verify MongoDB is running
   - Check connection string
   - Ensure database permissions

### Reset Admin Password
```bash
# Connect to MongoDB
mongo telegram-referral-bot

# Update admin password
db.admins.updateOne(
  { username: "mkmahabbat" },
  { $set: { password: "$2a$10$newhashedpassword" } }
)
```

## Support

For support and questions:
- Check the logs for error messages
- Verify all environment variables are set correctly
- Ensure all dependencies are installed
- Check MongoDB connection and permissions

## License

This project is licensed under the ISC License.

## Credits

Developed by Mahabbat
Powered by Node.js, MongoDB, Express.js, and TailwindCSS

