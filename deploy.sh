#!/usr/bin/env bash
set -e  # 让脚本遇到错误立即退出

echo "🚀 开始部署应用..."

# 1️⃣ 彻底删除旧版本 nodejs 和 npm，防止依赖冲突
sudo apt-get remove --purge -y nodejs npm || true
sudo apt-get autoremove -y
sudo apt-get autoclean
sudo rm -rf /usr/lib/node_modules ~/.npm ~/.node-gyp /usr/local/lib/node_modules /usr/local/bin/npm /usr/local/bin/node /usr/bin/node

# 2️⃣ 确保系统更新
sudo apt-get update -y

# 3️⃣ 安装 Node.js 和 npm（从 Nodesource 官方源安装）
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# 4️⃣ 确保 npm 可用
sudo npm install -g npm@latest

# 5️⃣ 确保 pm2 可用
sudo npm install -g pm2

# 6️⃣ 进入应用目录
cd ~/SimmpleApplication

# 7️⃣ 安装 npm 依赖
npm install --legacy-peer-deps

# 8️⃣ 解决 npm 安全漏洞（⚠️ 避免影响 CircleCI 执行）
npm audit fix --force || true

# 9️⃣ 重新创建 HTTPS 证书文件
echo "$PRIVATE_KEY" | sed 's/\\n/\n/g' > privatekey.pem
echo "$SERVER" | sed 's/\\n/\n/g' > server.crt

# 🔟 停止旧进程，启动新的进程
pm2 stop simpleapplication || true
pm2 restart simpleapplication || pm2 start ./bin/www --name simpleapplication

# 1️⃣1️⃣ 持久化 PM2（防止服务器重启后丢失进程）
pm2 save

# 1️⃣2️⃣ 只有在 EC2 服务器上才运行 `pm2 startup`
if [ -z "$CI" ]; then
  sudo pm2 startup
fi

echo "✅ 部署完成！"
