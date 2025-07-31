const { spawn } = require('child_process');
const path = require('path');
require('dotenv').config();

console.log('🚀 Starting MK BOT System...\n');

// Start the Telegram bot
console.log('📱 Starting Telegram Bot...');
const botProcess = spawn('node', [path.join(__dirname, 'bot/bot.js')], {
    stdio: 'inherit',
    cwd: __dirname
});

// Start the admin server
console.log('🖥️  Starting Admin Server...');
const adminProcess = spawn('node', [path.join(__dirname, 'admin/admin.js')], {
    stdio: 'inherit',
    cwd: __dirname
});

// Handle bot process events
botProcess.on('error', (error) => {
    console.error('❌ Bot process error:', error);
});

botProcess.on('exit', (code, signal) => {
    console.log(`📱 Bot process exited with code ${code} and signal ${signal}`);
    if (code !== 0) {
        console.log('🔄 Restarting bot in 5 seconds...');
        setTimeout(() => {
            const newBotProcess = spawn('node', [path.join(__dirname, 'bot/bot.js')], {
                stdio: 'inherit',
                cwd: __dirname
            });
        }, 5000);
    }
});

// Handle admin process events
adminProcess.on('error', (error) => {
    console.error('❌ Admin process error:', error);
});

adminProcess.on('exit', (code, signal) => {
    console.log(`🖥️  Admin process exited with code ${code} and signal ${signal}`);
    if (code !== 0) {
        console.log('🔄 Restarting admin server in 5 seconds...');
        setTimeout(() => {
            const newAdminProcess = spawn('node', [path.join(__dirname, 'admin/admin.js')], {
                stdio: 'inherit',
                cwd: __dirname
            });
        }, 5000);
    }
});

// Handle graceful shutdown
process.on('SIGINT', () => {
    console.log('\n🛑 Shutting down MK BOT System...');
    
    botProcess.kill('SIGTERM');
    adminProcess.kill('SIGTERM');
    
    setTimeout(() => {
        process.exit(0);
    }, 2000);
});

process.on('SIGTERM', () => {
    console.log('\n🛑 Shutting down MK BOT System...');
    
    botProcess.kill('SIGTERM');
    adminProcess.kill('SIGTERM');
    
    setTimeout(() => {
        process.exit(0);
    }, 2000);
});

console.log('\n✅ MK BOT System started successfully!');
console.log('📱 Telegram Bot: Running');
console.log(`🖥️  Admin Panel: http://localhost:${process.env.ADMIN_PORT || 3001}`);
console.log('🔧 Press Ctrl+C to stop all services\n');

