#!/usr/bin/env bash
set -e  # Exit the script immediately if any command fails
echo "🚀 Starting application deployment..."
# 1️ Completely remove old versions of Node.js and npm to prevent dependency conflicts
sudo apt-get remove --purge -y nodejs npm || true
sudo apt-get autoremove -y
sudo apt-get autoclean
sudo rm -rf /usr/lib/node_modules ~/.npm ~/.node-gyp /usr/local/lib/node_modules /usr/local/bin/npm /usr/local/bin/node /usr/bin/node
# 2️ Ensure the system is up to date
sudo apt-get update -y
# 3️ Install Node.js and npm (from the official Nodesource repository)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
# 4️ Ensure npm is available
sudo npm install -g npm@latest
# 5️ Ensure pm2 is installed
sudo npm install -g pm2
# 6️ Navigate to the application directory
cd ~/SimpleApplication
# 7️ Install npm dependencies
npm install --legacy-peer-deps
# 8️ Fix npm security vulnerabilities
npm audit fix --force || true
# 9️ Recreate HTTPS certificate files
echo "$PRIVATE_KEY" | sed 's/\\n/\n/g' > privatekey.pem
echo "$SERVER" | sed 's/\\n/\n/g' > server.crt
# 10 Stop the old process and start a new one
pm2 stop simpleapplication || true
pm2 restart simpleapplication || pm2 start ./bin/www --name simpleapplication
# 11 Persist PM2 process (prevents process loss after a server reboot)
pm2 save
# 12 Run `pm2 startup` only on an EC2 server
if [ -z "$CI" ]; then
  sudo pm2 startup
fi
echo "✅ Deployment completed successfully!"
