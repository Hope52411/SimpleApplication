#!/usr/bin/env bash
set -e  # 发生错误时立即退出

echo "🚀 Starting application deployment..."

# 更新系统并安装 Node.js 和 npm
sudo apt update -y
sudo apt install -y nodejs npm

# 安装 pm2
sudo npm install -g pm2

# 停止已有应用
pm2 stop simpleapplication || true

# 进入应用目录
cd ~/SimpleApplication

# 安装依赖
npm install --legacy-peer-deps
npm audit fix --force || true  # 修复潜在的 npm 安全问题

# 生成 HTTPS 证书
echo "$PRIVATE_KEY" | sed 's/\\n/\n/g' > privatekey.pem
echo "$SERVER" | sed 's/\\n/\n/g' > server.crt

# 启动应用
pm2 restart simpleapplication || pm2 start ./bin/www --name simpleapplication
pm2 save  # 使应用保持在 `pm2 list` 中

# 确保 pm2 开机自启（仅在非 CI/CD 环境下执行）
[ -z "$CI" ] && sudo pm2 startup

echo "✅ Deployment completed successfully!"
