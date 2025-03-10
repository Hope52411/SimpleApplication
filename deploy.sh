#!/usr/bin/env bash
set -e  # 发生错误时立即退出

echo "🚀 Starting application deployment..."

# 确保系统更新并安装 Node.js 和 npm
sudo apt-get update -y
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g npm@latest pm2

# 进入应用目录并安装依赖
cd ~/SimpleApplication
npm install --legacy-peer-deps
npm audit fix --force || true

# 生成 HTTPS 证书
echo "$PRIVATE_KEY" | sed 's/\n/\n/g' > privatekey.pem
echo "$SERVER" | sed 's/\n/\n/g' > server.crt

# 使用 pm2 管理应用
pm2 restart simpleapplication || pm2 start ./bin/www --name simpleapplication
pm2 save

# 仅在非 CI 环境中执行 pm2 startup，确保服务随系统启动
[ -z "$CI" ] && sudo pm2 startup

echo "✅ Deployment completed successfully!"
