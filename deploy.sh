#!/bin/bash

# MK BOT Deployment Script
# This script helps deploy the Telegram referral bot system

set -e

echo "🚀 MK BOT Deployment Script"
echo "=========================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_warning "This script should not be run as root for security reasons"
   exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
print_status "Checking prerequisites..."

if ! command_exists node; then
    print_error "Node.js is not installed. Please install Node.js 14 or higher."
    exit 1
fi

if ! command_exists npm; then
    print_error "npm is not installed. Please install npm."
    exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 14 ]; then
    print_error "Node.js version 14 or higher is required. Current version: $(node --version)"
    exit 1
fi

print_success "Node.js $(node --version) is installed"

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_error ".env file not found. Please create and configure the .env file."
    exit 1
fi

print_success ".env file found"

# Install dependencies
print_status "Installing dependencies..."
npm install

if [ $? -eq 0 ]; then
    print_success "Dependencies installed successfully"
else
    print_error "Failed to install dependencies"
    exit 1
fi

# Create logs directory
print_status "Creating logs directory..."
mkdir -p logs
print_success "Logs directory created"

# Check MongoDB connection
print_status "Checking MongoDB connection..."
if command_exists mongosh; then
    MONGO_URI=$(grep MONGODB_URI .env | cut -d '=' -f2)
    if mongosh "$MONGO_URI" --eval "db.runCommand('ping')" >/dev/null 2>&1; then
        print_success "MongoDB connection successful"
    else
        print_warning "MongoDB connection failed. Please ensure MongoDB is running and accessible."
    fi
elif command_exists mongo; then
    MONGO_URI=$(grep MONGODB_URI .env | cut -d '=' -f2)
    if mongo "$MONGO_URI" --eval "db.runCommand('ping')" >/dev/null 2>&1; then
        print_success "MongoDB connection successful"
    else
        print_warning "MongoDB connection failed. Please ensure MongoDB is running and accessible."
    fi
else
    print_warning "MongoDB client not found. Cannot test connection."
fi

# Install PM2 if not present
if ! command_exists pm2; then
    print_status "Installing PM2..."
    npm install -g pm2
    print_success "PM2 installed successfully"
else
    print_success "PM2 is already installed"
fi

# Deployment options
echo ""
echo "Choose deployment method:"
echo "1) PM2 (Recommended for production)"
echo "2) Docker Compose"
echo "3) Manual start (Development)"
echo "4) Exit"

read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        print_status "Deploying with PM2..."
        
        # Stop existing processes
        pm2 delete mk-bot-telegram mk-bot-admin 2>/dev/null || true
        
        # Start with ecosystem file
        pm2 start ecosystem.config.js
        
        # Save PM2 configuration
        pm2 save
        
        # Setup startup script
        pm2 startup
        
        print_success "Deployment completed with PM2!"
        print_status "Use 'pm2 status' to check application status"
        print_status "Use 'pm2 logs' to view logs"
        print_status "Use 'pm2 monit' for monitoring"
        ;;
        
    2)
        print_status "Deploying with Docker Compose..."
        
        if ! command_exists docker; then
            print_error "Docker is not installed. Please install Docker first."
            exit 1
        fi
        
        if ! command_exists docker-compose; then
            print_error "Docker Compose is not installed. Please install Docker Compose first."
            exit 1
        fi
        
        # Build and start containers
        docker-compose up -d --build
        
        print_success "Deployment completed with Docker!"
        print_status "Use 'docker-compose logs -f' to view logs"
        print_status "Use 'docker-compose ps' to check container status"
        ;;
        
    3)
        print_status "Starting manually..."
        
        # Start the application
        npm start &
        
        print_success "Application started manually!"
        print_status "Bot and admin server are running in the background"
        print_status "Check logs in the logs/ directory"
        ;;
        
    4)
        print_status "Exiting..."
        exit 0
        ;;
        
    *)
        print_error "Invalid choice. Exiting..."
        exit 1
        ;;
esac

echo ""
print_success "🎉 MK BOT deployment completed successfully!"
echo ""
echo "📱 Telegram Bot: Running"
echo "🖥️  Admin Panel: http://localhost:3001"
echo "👤 Admin Username: $(grep ADMIN_USERNAME .env | cut -d '=' -f2)"
echo "🔑 Admin Password: $(grep ADMIN_PASSWORD .env | cut -d '=' -f2)"
echo ""
print_status "Make sure to:"
print_status "1. Configure your bot token in .env"
print_status "2. Set up your Telegram channel"
print_status "3. Test the bot functionality"
print_status "4. Monitor the logs for any issues"
echo ""
print_success "Happy bot running! 🤖"

